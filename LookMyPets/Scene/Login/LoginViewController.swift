//
//  ViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/21/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift


final class LoginViewController: BaseViewController {
    //MARK: - Properties
    let mainView = LoginView()
    
    //MARK: - Rx Properties
    let keyboardAction = PublishRelay<UIReturnKeyType>()
    
    let disposeBag = DisposeBag()
    
    //MARK: - LifeCycle
    override func loadView() {
        view = mainView
    }
    
    //MARK: - Configure
    override func configure() {
        [mainView.idTextField, mainView.pwTextField].forEach { view in
            view.delegate = self
        }
        
    }
    
    override func configureNavigation() {
        
    }
    
    override func bind() {
        mainView.signUpButton.rx.tap
            .bind(with: self) { owner, _ in
                let nextVC = EmailUpViewController()
                owner.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType{
        case .done:
            textField.resignFirstResponder()
        default:
            if textField == mainView.idTextField{
                mainView.pwTextField.becomeFirstResponder()
            }
        }
        return true
    }
}





//#Preview{
//    LoginViewController()
//}
