//
//  ListViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import RxSwift
import RxCocoa
import Moya

class ListViewModel {
    
    private var pageSize: Int = 1
    private var disposeBag = DisposeBag()
    
    // MARK: - ViewModelType
    
    struct Input {
        let viewWillAppear = PublishRelay<Void>()
        let refreshTrigger = PublishRelay<Void>()
        let nextPageSignal = PublishRelay<Void>()
    }
    
    struct Output {
        let list = BehaviorRelay<[Beer]>(value: [])
        let isLoading = PublishRelay<Bool>()
        let errorRelay = PublishRelay<Error>()
    }
    
    let input = Input()
    let output = Output()
    
    init(provider: MoyaProvider<BeerAPI> = MoyaProvider<BeerAPI>()) {
        let activityIndicator = ActivityIndicator()
        
        input.viewWillAppear
            .asObservable()
            .catchError { error -> Observable<Void> in
                return Observable<Void>.just(())
            }
            .map { self.pageSize = 1 }
            .flatMapLatest {
                provider.rx.request(.getBeerList(pageSize: self.pageSize))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { self.output.errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .bind(to: output.list)
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .asObservable()
            .map { self.pageSize = 1 }
            .flatMapLatest {
                provider.rx.request(.getBeerList(pageSize: self.pageSize))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { self.output.errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .bind(to: output.list)
            .disposed(by: disposeBag)
        
        input.nextPageSignal
            .asObservable()
            .map { self.pageSize += 1 }
            .flatMapLatest {
                provider.rx.request(.getBeerList(pageSize: self.pageSize))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { self.output.errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .map { self.output.list.value + $0 }
            .bind(to: self.output.list)
            .disposed(by: disposeBag)
        
        activityIndicator
            .asObservable()
            .bind(to: output.isLoading)
            .disposed(by: disposeBag)
    }
}
