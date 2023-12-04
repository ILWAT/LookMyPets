//
//  Extension+UIViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 12/4/23.
//

import UIKit

extension UIViewController {
    func makeDefaultAlert(alertTitle: String, alertMessage: String, okTitle: String, completion: @escaping (UIAlertAction)->Void, cancelAction: @escaping (UIAlertAction)->Void){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: okTitle, style: .default, handler: completion)
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: cancelAction)
        
        [ok, cancel].forEach { action in
            alert.addAction(action)
        }
        
        self.present(alert, animated: true)
    }
}
