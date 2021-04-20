//
//  SearchViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/28.
//

import RxSwift
import RxCocoa
import Moya


class SearchViewModel {
    let input: Input
    let output: Output
    
    // MARK: - ViewModelType
    
    struct Input {
        let searchTrigger = PublishSubject<String>()
    }
    
    struct Output {
        let beer: Signal<[Beer]>
        let isLoading: Signal<Bool>
        let errorRelay: PublishRelay<String>
    }
    
    init() {
        let activityIndicator = ActivityIndicator()
        
        let beer: PublishRelay<String> = PublishRelay()
        
        input = Input()
        output = Output(beer: input.searchTrigger.asObservable().catchError { error -> Observable<String> in
            beer.accept(error.localizedDescription)
            return Observable<String>.just("")
        }.flatMapLatest {
            provider.rx.request(.searchID(id: Int($0) ?? 0))
                .filterSuccessfulStatusCodes()
                .map([Beer].self)
        }.asSignal(onErrorJustReturn: []),
                        isLoading:
                            activityIndicator.asSignal(onErrorJustReturn: false),
        errorRelay: beer
        )
    }
}
