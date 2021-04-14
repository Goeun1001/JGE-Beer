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
    private let beerListRepository: BeerListRepository
    
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
    
    init(provider: MoyaProvider<BeerAPI> = MoyaProvider<BeerAPI>(), beerListRepository: BeerListRepository) {
        let activityIndicator = ActivityIndicator()
        self.beerListRepository = beerListRepository
        
        input.viewWillAppear
            .asObservable()
            .catchError { error -> Observable<Void> in
                return Observable<Void>.just(())
            }
//            .map { self.pageSize = 1 }
            .trackActivity(activityIndicator)
            .subscribe(onNext: {
                if self.pageSize == 1 {
                    self.beerListRepository.fetchBeerList(page: self.pageSize,
                                                          completion: { result in
                         self.output.list.accept(result)
                    })
                }
            }, onError: { error in
                self.output.errorRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .asObservable()
            .map { self.pageSize = 1 }
            .trackActivity(activityIndicator)
            .subscribe(onNext: {
                self.beerListRepository.fetchBeerList(page: self.pageSize,
                                                      completion: { result in
                     self.output.isLoading.accept(false)
                     self.output.list.accept(result)

                })
            }, onError: { error in
                self.output.errorRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        input.nextPageSignal
            .asObservable()
            .map { self.pageSize += 1 }
            .trackActivity(activityIndicator)
            .subscribe(onNext: {
                self.beerListRepository.fetchBeerList(page: self.pageSize,
                                                      completion: { result in
                       self.output.list.accept(self.output.list.value + result)
                })
            }, onError: { error in
                self.output.errorRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        activityIndicator
            .asObservable()
            .bind(to: output.isLoading)
            .disposed(by: disposeBag)
    }
}
