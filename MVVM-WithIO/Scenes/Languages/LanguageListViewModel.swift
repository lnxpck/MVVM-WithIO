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
    var didSelectLanguage: PublishSubject<String> { get }
    var didCancel: PublishSubject<Void> { get }
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
        self.didSelectLanguage.onNext(language)
    }
    
    func cancel() {
        self.didCancel.onNext(Void())
    }

    // MARK: - Outputs
    
    var languages: Observable<[String]>
    var didSelectLanguage: PublishSubject<String> = PublishSubject<String>()
    var didCancel: PublishSubject<Void> = PublishSubject<Void>()
    
    
    init(githubService: GithubService = GithubService()) {
        self.languages = githubService.getLanguageList()
    }
}
