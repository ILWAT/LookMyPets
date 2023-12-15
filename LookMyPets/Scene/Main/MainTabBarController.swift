//
//  MainTabBarController.swift
//  LookMyPets
//
//  Created by 문정호 on 12/10/23.
//

import UIKit

final class MainTabBarController: UITabBarController {
    //MARK: - Properties
    let mainHomeVC = UINavigationController(rootViewController: MainHomeViewController())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTabBarItem()
    }
    
    private func configureViewController(){
        self.setViewControllers([mainHomeVC], animated: true)
    }
    
    private func configureTabBarItem(){
        mainHomeVC.tabBarItem.image = UIImage(systemName: "house.fill")
    }
}
