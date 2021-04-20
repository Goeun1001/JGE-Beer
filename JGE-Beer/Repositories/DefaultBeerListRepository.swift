//
//  DefaultBeerListRepository.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/04/13.
//

import Foundation
import Moya

protocol BeerListRepository {
    func fetchBeerList(page: Int,
                       completion: @escaping (Result<[Beer], Error>) -> Void)
}

final class DefaultBeerListRepository {
    private let provider: MoyaProvider<BeerAPI>
    
    init(provider: MoyaProvider<BeerAPI> = MoyaProvider<BeerAPI>()) {
        self.provider = provider
    }
}

extension DefaultBeerListRepository: BeerListRepository {
    public func fetchBeerList(page: Int,
                              completion: @escaping (Result<[Beer], Error>) -> Void) {
        
        provider.request(.getBeerList(pageSize: page)) { result in
            switch result {
            case let .success(success):
                let responseData = success.data
                do {
                    let beerList = try JSONDecoder().decode([Beer].self, from: responseData)
                    return completion(.success(beerList))
                } catch {
                    return completion(.failure(error))
                }
            case let .failure(error):
                print(error)
                return completion(.failure(error))
            }
        }
    }
}
