//
//  BaseViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/21/23.
//

import UIKit


class BaseViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
        configureNavigation()
    }
    
    func configure(){}
    
    func bind(){}
    
    func configureNavigation(){}
    
}
