//
//  RepositoryListViewModel.swift
//  MVVM-WithIO
//
//  Created by PATRICK LESAINT on 28/10/2019.
//  Copyright © 2019 PATRICK LESAINT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol RepositoryListViewModelInput {

    func fetchCurrentLanguage()
    func fetchForLanguage(language: String)
    func displayLanguageList()
    func displayRepository(repo : RepositoryViewModel)
}

protocol RepositoryListViewModelOutput {
    var repositories: PublishSubject<[RepositoryViewModel]> { get } // Emits an array of fetched repositories.
    var alertMessage: PublishSubject<String> { get } // Emits an error messages to be shown.
    var showRepository: PublishSubject<URL> { get } // Emits an url of repository page to be shown.
    var showLanguageList: PublishSubject<Void> { get } // Emits when we should show language list.
    var title: Observable<String> { get } // Emits a formatted title for a navigation item.
    var activityIndicator: Observable<Bool> { get }
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
    
    var repositories: PublishSubject<[RepositoryViewModel]> = PublishSubject<[RepositoryViewModel]>()
    var alertMessage: PublishSubject<String> = PublishSubject<String>()
    var showRepository: PublishSubject<URL> = PublishSubject<URL>()
    var showLanguageList: PublishSubject<Void> = PublishSubject<Void>()
    var title: Observable<String>
    var activityIndicator: Observable<Bool>

    // MARK: Private
    
    private var githubService: GithubService!
    private var _currentLanguage: BehaviorSubject<String>
    private var _activityIndicator: ActivityIndicator
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    
    init(initialLanguage: String, githubService: GithubService = GithubService()) {

        self.githubService = githubService
        
        self._currentLanguage = BehaviorSubject<String>(value: initialLanguage)
        self.title = self._currentLanguage.asObservable().map { "\($0)" }
        
        self._activityIndicator = ActivityIndicator()
        self.activityIndicator = self._activityIndicator.asObservable()
        
//        self.repositories
//            .asObservable()
//            .map { repos in
//                return repos.first
//            }
//            .subscribe(onNext: { repo in
//                print("\(repo?.name)")
//                
//            })
//            .disposed(by: disposeBag)
    }
    
    // MARK: - Inputs
    
    func fetchForLanguage(language: String) {

        self._currentLanguage.onNext(language)
        self.repositories.onNext([])
        
        githubService.getMostPopularRepositories(byLanguage: language)
            .trackActivity(self._activityIndicator)
            .asObservable()
            .catchError { error in
                self.alertMessage.onNext(error.localizedDescription)
                return Observable.empty()
            }
            .subscribe(onNext: { repositories in
                let repo = repositories.map(RepositoryViewModel.init)
                self.repositories.onNext(repo)
            })
            .disposed(by: disposeBag)
    }
    
    func displayRepository(repo : RepositoryViewModel) {
        self.showRepository.onNext(repo.url)
    }
    
    func displayLanguageList() {
        self.showLanguageList.onNext(Void())
    }
    
    func fetchCurrentLanguage() {
        self.fetchForLanguage(language: try! self._currentLanguage.value())
    }
}
