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
    
    let viewModel = LoginViewModel()
    
    //MARK: - Rx Properties
    let keyboardAction = PublishRelay<UIReturnKeyType>()
    
    let disposeBag = DisposeBag()
    
    //MARK: - LifeCycle
    override func loadView() {
        view = mainView
    }
    
    deinit{
        print("deinit - LoginViewController")
    }
    
    //MARK: - Configure
    override func configure() {
        [mainView.idTextField.textField, mainView.pwTextField].forEach { view in
            view.delegate = self
        }
        
    }
    
    override func configureNavigation() {
    }
    
    override func bind() {
        let input = LoginViewModel.Input(id: mainView.idTextField.textField.rx.text.orEmpty,
                                         password: mainView.pwTextField.rx.text.orEmpty,
                                         loginTap: mainView.loginButton.rx.tap,
                                         signupTap: mainView.signUpButton.rx.tap)
        
        let output = viewModel.transform(input)
        
        
        output.signupTap.bind(with: self) { owner, _ in
                let nextVC = EmailUpViewController()
                owner.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .drive(with: self) { owner, errorText in
                owner.mainView.idTextField.guideMessage.text = errorText
                owner.mainView.idTextField.guideMessage.isHidden = false
            }
            .disposed(by: disposeBag)
        
        output.presentHome
            .drive(with: self) { owner, bool in
                owner.view.window?.rootViewController = MainTabBarController()
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
