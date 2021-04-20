

//
//  RandomViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class RandomViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let randomView = BeerView()
    private var viewModel: RandomViewModel?
    
    private lazy var randomButton: UIButton = {
        let randomButton = UIButton()
        randomButton.isHighlighted = false
        randomButton.setImage(UIImage(named: "Dice"), for: .normal)
        randomButton.setImage(UIImage(named: "Dice"), for: .highlighted)
        randomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        randomButton.setTitle("돌려돌려 돌림판", for: .normal)
        randomButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        randomButton.backgroundColor = UIColor.orange
        randomButton.clipsToBounds = true
        randomButton.layer.cornerRadius = 10
        return randomButton
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    // MARK: - Life Cycle
    
    init(viewModel: RandomViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationTitle() {
        self.navigationItem.title = "아무거나"
        self.navigationItem.accessibilityLabel = "아무거나 검색"
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        view.addSubview(randomView)
        randomView.addSubview(indicator)
        randomView.addSubview(randomButton)
        
        randomView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
        
        randomButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.layoutMarginsGuide).offset(-60)
            $0.width.equalTo(view.snp.width).offset(-30)
            $0.height.equalTo(40)
        }
    }
    
    private func bindViewModel() {
        
        
        viewModel?.output.beer
            .subscribe(onNext: { [weak self] beer in
                self?.randomView.configure(with: beer.first ?? Beer(id: nil, name: "", description: "", imageURL: nil))
                self?.setupSubview()
            })
            .disposed(by: disposeBag)
        
        viewModel?output?.isLoading
            .filter { !$0 }
            .emit(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?output?.errorRelay.asObservable()
            .subscribe(onNext: { [weak self] err in
                self?.showErrorAlert(with: err.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
