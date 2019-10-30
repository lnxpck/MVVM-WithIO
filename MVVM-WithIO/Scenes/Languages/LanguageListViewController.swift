//
//  LanguageListViewController.swift
//  MVVM-WithIO
//
//  Created by PATRICK LESAINT on 28/10/2019.
//  Copyright © 2019 PATRICK LESAINT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LanguageListViewController: UIViewController {

    let disposeBag = DisposeBag()
    var viewModel: LanguageListViewModel! = LanguageListViewModel()

    @IBOutlet private weak var tableView: UITableView!
    
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "Choose a language"

        tableView.rowHeight = 48.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LanguageCell")
        
    }

    private func setupBindings() {
        viewModel.outputs.languages
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "LanguageCell", cellType: UITableViewCell.self)) { (_, language, cell) in
                cell.textLabel?.text = language
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] language in
                self?.viewModel.inputs.selectLanguage(language: language)
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] language in
                self?.viewModel.inputs.cancel()
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            })
            .disposed(by: disposeBag)
    }
}
