//
//  RepositoryListViewModel.swift
//  MVVM-WithIO
//
//  Created by PATRICK LESAINT on 28/10/2019.
//  Copyright © 2019 PATRICK LESAINT. All rights reserved.
//

import Foundation
import RxSwift

protocol RepositoryListViewModelInput {

    func fetchCurrentLanguage()
    func fetchForLanguage(language: String)
    func displayLanguageList()
    func displayRepository(repo : RepositoryViewModel)
}

protocol RepositoryListViewModelOutput {
    var repositories: Observable<[RepositoryViewModel]> { get } // Emits an array of fetched repositories.
    var title: Observable<String> { get } // Emits a formatted title for a navigation item.
    var alertMessage: Observable<String> { get } // Emits an error messages to be shown.
    var showRepository: Observable<URL> { get } // Emits an url of repository page to be shown.
    var showLanguageList: Observable<Void> { get } // Emits when we should show language list.
}

protocol RepositoryListViewModelType {
    var inputs : RepositoryListViewModelInput { get }
    var outputs : RepositoryListViewModelOutput { get }
}

class RepositoryListViewModel: RepositoryListViewModelInput, RepositoryListViewModelOutput, RepositoryListViewModelType {
    
    // MARK: Inputs & Outputs
    
    var inputs: RepositoryListViewModelInput { return self }
    var outputs: RepositoryListViewModelOutput  { return self }
    
    // MARK: - Outputs
    
    var repositories: Observable<[RepositoryViewModel]>
    var title: Observable<String>
    var alertMessage: Observable<String>
    
    var showRepository: Observable<URL>
    var showLanguageList: Observable<Void>
    
    // MARK: Private
    
    private var githubService: GithubService!

    private var _currentLanguage: BehaviorSubject<String>
    private var _repositories: PublishSubject<[RepositoryViewModel]>
    private var _alertMessage: PublishSubject<String>
    private var _displayRepository: PublishSubject<RepositoryViewModel>
    private var _displayLanguageList: PublishSubject<Void>
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    
    init(initialLanguage: String, githubService: GithubService = GithubService()) {

        self.githubService = githubService
        
        self._currentLanguage = BehaviorSubject<String>(value: initialLanguage)
        self.title = self._currentLanguage.asObservable().map { "\($0)" }
        
        self._repositories = PublishSubject<[RepositoryViewModel]>()
        self.repositories = self._repositories.asObservable()

        self._alertMessage = PublishSubject<String>()
        self.alertMessage = self._alertMessage.asObserver()
        
        self._displayRepository = PublishSubject<RepositoryViewModel>()
        self.showRepository = _displayRepository.asObservable().map { $0.url }

        self._displayLanguageList = PublishSubject<Void>()
        self.showLanguageList = self._displayLanguageList.asObserver()

        self.fetchForLanguage(language: initialLanguage)
    }
    
    // MARK: - Inputs
    
    func fetchForLanguage(language: String) {

        self._currentLanguage.onNext(language)

        githubService.getMostPopularRepositories(byLanguage: language)
            .asObservable()
            .catchError { error in
                self._alertMessage.onNext(error.localizedDescription)
                return Observable.empty()
            }
            .subscribe(onNext: { repositories in
                let repo = repositories.map(RepositoryViewModel.init)
                self._repositories.onNext(repo)
            })
            .disposed(by: disposeBag)
    }
    
    func displayRepository(repo : RepositoryViewModel) {
        print("displayRepository : \(repo.name)")
        self._displayRepository.onNext(repo)
    }
    
    func displayLanguageList() {
        print("displayLanguageList...")
        self._displayLanguageList.onNext(Void())
    }
    
    func fetchCurrentLanguage() {
        self.fetchForLanguage(language: try! self._currentLanguage.value())
    }
}
