//
//  RandomViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import RxSwift
import RxCocoa
import Moya

class RandomViewModel: ViewModelType {
   
    // MARK: - ViewModelType
    // 김정빈 다녀갑니다
    
    struct Input {
        let buttonTrigger: Signal<Void>
    }
    
    struct Output {
        let beer: Signal<[Beer]>
        let isLoading: Signal<Bool>
        let errorRelay: PublishRelay<String>
    }
    
    // 현욱이 코드 상당히 많이 참조.. 넘 어려워요..
    init() {
        let activityIndicator = ActivityIndicator()
        let beer: PublishRelay<String> = PublishRelay()
        
        input = Input()
        output = Output(beer: input.buttonTrigger.asObservable().catchError { err -> Observable<String> in
            beer.accept(err.localizedDescription)
            return Observable<String>.just("")
        }.flatMapLatest {
            provider.rx.request(.random)
                .filterSuccessfulStatusCodes()
                .map([Beer.self])
            
        }.asSignal(onErrorJustReturn: []),
        isLoading:
            activityIndicator.asSignal(onErrorJustReturn: false), errorRelay: errorRelay
        )
        
    }
    
    
}
