//
//  SearchViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let randomView = BeerView()
    private var viewModel: SearchViewModel?
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Life Cycle
    
    init(viewModel: SearchViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        self.navigationItem.searchController = searchController
        searchController.searchBar.keyboardType = .numbersAndPunctuation
        self.navigationItem.title = "ID 검색"
        self.navigationItem.accessibilityLabel = "맥주 ID 검색"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchBar.rx.searchButtonClicked
            .subscribe(onNext: {
                self.searchController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        view.addSubview(randomView)
        randomView.addSubview(indicator)
        
        randomView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        searchController.searchBar.rx.text.orEmpty
            .bind(to: (viewModel?.input.searchTrigger)!)
            .disposed(by: disposeBag)
        
        viewModel?.output.beer.asObservable()
            .subscribe(onNext: { [weak self] beer in
                self?.randomView.configure(with: beer.first ?? Beer(id: nil, name: "", description: "", imageURL: nil))
                self?.setupSubview()
            })
            .disposed(by: disposeBag)
        
        viewModel?.output.isLoading
            .filter { !$0 }
            .emit(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.output.errorRelay.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.showErrorAlert(with: text)
            }).disposed(by: disposeBag)
    }
}
