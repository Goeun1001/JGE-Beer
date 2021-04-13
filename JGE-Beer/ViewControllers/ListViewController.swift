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
import RxViewController
import SnapKit

class ListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = ListViewModel()
    
    private let tableView = UITableView() // lazy var랑 뭐가 다른지 모르겠음.
    private let refreshControl = UIRefreshControl()
    
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
        self.rx.viewWillAppear.map { $0 } // self.rx.viewDidLoad가 동작하지 않았음.
            .subscribe(onNext: {
                self.viewModel.input.viewWillAppear.accept(())
            }, onError: { error in
                print("ListView ViewAppear Error : \(error)")
            })
            //            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: 120.0)
            .subscribe(onNext: {
                self.viewModel.input.nextPageSignal.accept(())
            }, onError: { error in
                print("ListView ReachBottom Error : \(error)")
            })
            //            .bind(to: viewModel.input.nextPageSignal)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: {
                self.viewModel.input.refreshTrigger.accept(())
            }, onError: { error in
                print("ListView Refresh Error : \(error)")
            })
            //            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.list
            .map { [ListSection(header: "", items: $0)] }
            //            .subscribe(onNext: { data in
            //                tableView.rx.items(dataSource: dataSource)
            //            }, onError: { error in
            //                print("ListView Refresh Error : \(error)")
            //            })
            .catchError{ error in
                print("ListView tableView List Error : \(error)")
                return Observable<[ListSection]>.just([ListSection(header: "", items: [Beer]())])
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .filter { !$0 }
            .subscribe(onNext: { bool in
                self.refreshControl.rx.isRefreshing.on(Event<Bool>.next(bool))
            }, onError: { error in
                print("ListView Refresh Error : \(error)")
            })
            //            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.output.errorRelay
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(with: error.localizedDescription)
            }, onError: { error in
                print("ListView ViewModel ErrorRelay Error : \(error)")
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Beer.self)
            .subscribe(onNext: { [weak self] beer in
                let controller = DetailViewController(beer: beer)
                self?.navigationController?.pushViewController(controller, animated: true)
            }, onError: { error in
                print("ListView tableView ModelSelected Error : \(error)")
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {
                self.tableView.deselectRow(at: $0, animated: true)
            },onError: { error in
                print("ListView tableView ItemSelected Error : \(error)")
            })
            .disposed(by: disposeBag)
    }
}
