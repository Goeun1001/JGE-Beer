//
//  TabBarController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureTabBarItems()
    }

    func configureTabBarItems() {
        let listVC = ListViewController(viewModel: ListViewModel(beerListRepository: DefaultBeerListRepository()))
        listVC.tabBarItem = UITabBarItem(title: "맥주 리스트", image: UIImage(named: "Multiple Beers"), tag: 0)

        let searchVC = SearchViewController()
        searchVC.tabBarItem = UITabBarItem(title: "ID 검색", image: UIImage(named: "Single Beer with bubble"), tag: 1)
        
        let randomVC = RandomViewController()
        randomVC.tabBarItem = UITabBarItem(title: "아무거나", image: UIImage(named: "Single Beer"), tag: 2)

        let listNavigationVC = UINavigationController(rootViewController: listVC)
        let searchNavigationVC = UINavigationController(rootViewController: searchVC)
        let randomNavigationVC = UINavigationController(rootViewController: randomVC)
        setViewControllers([listNavigationVC, searchNavigationVC, randomNavigationVC], animated: false)
    }
}
