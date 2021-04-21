//
//  ViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class ListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private var viewModel: ListViewModel?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    private let dataSource = RxTableViewSectionedReloadDataSource<ListSection>(configureCell: {  (_, tableView, _, user) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerCell") as? BeerTableViewCell ?? BeerTableViewCell(style: .default, reuseIdentifier: "BeerCell")
        cell.configure(with: user)
        return cell
    })
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupSubview()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationTitle() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "맥주리스트"
        self.navigationItem.accessibilityLabel = "맥주리스트"
    }
    
    private func setupSubview() {
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        
        tableView.snp.makeConstraints {
            $0.size.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel = ListViewModel()
        
        let nextPageSignal = tableView.rx.reachedBottom(offset: 120.0).asSignal()
        let refreshTrigger = Signal<Void>.merge(.of(()), refreshControl.rx.controlEvent(.valueChanged).asSignal())
        
        let input = ListViewModel.Input(provider: MoyaProvider<BeerAPI>(),
                                        refreshTrigger: refreshTrigger,
                                        nextPageSignal: nextPageSignal)
        
        let output = viewModel?.transform(input: input)
        
        output?.list
            .map { [ListSection(header: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output?.isLoading
            .filter { !$0 }
            .emit(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output?.errorRelay
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(with: error.localizedDescription)
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Beer.self)
          .subscribe(onNext: { [weak self] (beer) in
            let controller = DetailViewController(beer: beer)
            self?.navigationController?.pushViewController(controller, animated: true)
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected
          .subscribe(onNext: { self.tableView.deselectRow(at: $0, animated: true)})
          .disposed(by: disposeBag)
    }
}
