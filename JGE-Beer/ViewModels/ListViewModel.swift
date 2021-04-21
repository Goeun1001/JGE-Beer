//
//  ListViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import RxSwift
import RxCocoa
import Moya

class ListViewModel: ViewModelType {
    
    private var pageSize: Int = 1
    private var disposeBag = DisposeBag()
    
    // MARK: - ViewModelType
    
    struct Input {
        let provider: MoyaProvider<BeerAPI>
        let refreshTrigger: Signal<Void>
        let nextPageSignal: Signal<Void>
    }
    
    struct Output {
        let list: BehaviorRelay<[Beer]>
        let isLoading: Signal<Bool>
        let errorRelay: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let list = BehaviorRelay<[Beer]>(value: [])
        let errorRelay = PublishRelay<Error>()
        
        input.refreshTrigger
            .asObservable()
            .map { self.pageSize = 1 }
            .flatMapLatest {
                input.provider.rx.request(.getBeerList(pageSize: self.pageSize))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .bind(to: list)
            .disposed(by: disposeBag)
        
        input.nextPageSignal
            .asObservable()
            .map { self.pageSize += 1 }
            .flatMapLatest {
                input.provider.rx.request(.getBeerList(pageSize: self.pageSize))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .map { list.value + $0 }
            .bind(to: list)
            .disposed(by: disposeBag)
        
        return Output(list: list, isLoading: activityIndicator.asSignal(onErrorJustReturn: false), errorRelay: errorRelay)
    }
}
