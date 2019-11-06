//
//  RepositoryListViewController.swift
//  MVVM-WithIO
//
//  Created by PATRICK LESAINT on 28/10/2019.
//  Copyright © 2019 PATRICK LESAINT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class RepositoryListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: RepositoryListViewModel! = RepositoryListViewModel(initialLanguage: "Swift")
    
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
    private let refreshButton = UIBarButtonItem(barButtonSystemItem: .redo, target: nil, action: nil)
    private let refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()

        refreshControl.sendActions(for: .valueChanged)
        viewModel.fetchCurrentLanguage()
    }

    private func setupUI() {
        navigationItem.setRightBarButtonItems([refreshButton, chooseLanguageButton], animated: true)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.insertSubview(refreshControl, at: 0)
        tableView.register(UINib(nibName: "RepositoryListCell", bundle: nil), forCellReuseIdentifier: "RepositoryListCell")
    }

    private func setupBindings() {

        // View Controller UI actions to the View Model
        
        refreshButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.fetchCurrentLanguage()
            })
            .disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap
            .subscribe(onNext: { [weak self] repo in
                self?.viewModel.inputs.displayLanguageList()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RepositoryViewModel.self)
            .subscribe(onNext: { [weak self] repo in
                self?.viewModel.inputs.displayRepository(repo: repo)
            })
            .disposed(by: disposeBag)

        // View Model outputs to the View Controller

        viewModel.outputs.activityIndicator
            .observeOn(MainScheduler.instance)
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.outputs.repositories
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryListCell", cellType: RepositoryListCell.self)) { [weak self] (_, repo, cell) in
                self?.setupRepositoryCell(cell, repository: repo)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.showRepository
            .subscribe(onNext: { [weak self] in self?.openRepository(by: $0) })
            .disposed(by: disposeBag)

        viewModel.outputs.showLanguageList
            .subscribe(onNext: { [weak self] in self?.openLanguageList() })
            .disposed(by: disposeBag)

        viewModel.outputs.alertMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.presentAlert(message: $0)
            })
            .disposed(by: disposeBag)
    }

    private func setupRepositoryCell(_ cell: RepositoryListCell, repository: RepositoryViewModel) {
        cell.selectionStyle = .none
        cell.setName(repository.name)
        cell.setDescription(repository.description)
        cell.setStarsCountTest(repository.starsCountText)
    }

    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }

    // MARK: - Navigation

    private func openRepository(by url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.pushViewController(safariViewController, animated: true)
    }

    private func openLanguageList() {
        let viewController = LanguageListViewController()
        
        let dismiss = Observable.merge([
            viewController.viewModel.outputs.didCancel,
            viewController.viewModel.outputs.didSelectLanguage.map { _ in }
            ])
        
        dismiss
            .subscribe(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: viewController.disposeBag)

        viewController.viewModel.didSelectLanguage
            .subscribe(onNext: { [weak self] language in  self?.viewModel.fetchForLanguage(language: language) })
            .disposed(by: viewController.disposeBag)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
