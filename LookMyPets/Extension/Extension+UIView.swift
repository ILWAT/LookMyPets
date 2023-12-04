//
//  Extension+UIViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/21/23.
//

import UIKit


extension UIView{
    func addSubviews(_ views: [UIView]){
        views.forEach { view in
            self.addSubview(view)
        }
    }
}
