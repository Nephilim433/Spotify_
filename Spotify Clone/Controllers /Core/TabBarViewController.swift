//
//  TabBarViewController.swift
//  Spotify Clone
//
//  Created by Nephilim  on 11/11/22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        vc1.title = "Browse"
        vc2.title = "Search"
        vc3.title = "Library"
        let arrayOfVCs = [vc1,vc2,vc3]
        arrayOfVCs.forEach { vc in
            vc.navigationItem.largeTitleDisplayMode = .always
        }
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let arrayOfNavs = [nav1,nav2,nav3]
        arrayOfNavs.forEach { nav in
            nav.navigationBar.prefersLargeTitles = true
            nav.navigationBar.tintColor = .label

        }
        //changes the color of 'text' for TabBarItems
        self.view.tintColor = .label

        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 1)
        setViewControllers(arrayOfNavs, animated: true)
    }
}
