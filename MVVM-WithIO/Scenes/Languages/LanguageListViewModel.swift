//
//  LanguageListViewModel.swift
//  MVVM-WithIO
//
//  Created by PATRICK LESAINT on 28/10/2019.
//  Copyright © 2019 PATRICK LESAINT. All rights reserved.
//

import RxSwift

protocol  LanguageListViewModelInput {
    func selectLanguage(language: String)
    func cancel()
}

protocol  LanguageListViewModelOutput {
    var languages: Observable<[String]> { get }
    var didSelectLanguage: Observable<String> { get }
    var didCancel: Observable<Void> { get }
}

protocol  LanguageListViewModelType {
    var inputs : LanguageListViewModelInput { get }
    var outputs : LanguageListViewModelOutput { get }
}

class LanguageListViewModel: LanguageListViewModelInput, LanguageListViewModelOutput, LanguageListViewModelType {

    // MARK: Inputs & Outputs

    var inputs: LanguageListViewModelInput { return self }
    var outputs: LanguageListViewModelOutput  { return self }
    
    // MARK: - Inputs
    
    func selectLanguage(language: String) {
        self._selectLanguage.onNext(language)
    }
    
    func cancel() {
        self._cancel.onNext(Void())
    }

    // MARK: - Outputs
    
    var languages: Observable<[String]>
    var didSelectLanguage: Observable<String>
    var didCancel: Observable<Void>
    
    // MARK: Private
    private let _selectLanguage: PublishSubject<String>
    private let _cancel: PublishSubject<Void>
    
    init(githubService: GithubService = GithubService()) {
        
        self.languages = githubService.getLanguageList()

        self._selectLanguage = PublishSubject<String>()
        self.didSelectLanguage = _selectLanguage.asObservable()

        self._cancel = PublishSubject<Void>()
        self.didCancel = _cancel.asObservable()
    }
}
