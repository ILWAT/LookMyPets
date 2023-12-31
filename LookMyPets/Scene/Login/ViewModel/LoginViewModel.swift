//
//  LoginViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 12/5/23.
//

import Foundation
import RxCocoa
import RxSwift

final class LoginViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let id: ControlProperty<String>
        let password: ControlProperty<String>
        let loginTap: ControlEvent<Void>
        let signupTap: ControlEvent<Void>
    }
    
    struct Output{
        let errorMessage: Driver<String>
        let signupTap: ControlEvent<Void>
        let presentHome: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let email = BehaviorRelay(value: "")
        let password = BehaviorRelay(value: "")
        let errorMessage = PublishRelay<String>()
        let presentHome = BehaviorRelay(value: false)
        
        input.id
            .bind(with: self) { owner, emailText in
                email.accept(emailText)
            }
            .disposed(by: disposeBag)
        
        input.password
            .bind(with: self) { owner, passwordText in
                password.accept(passwordText)
            }
            .disposed(by: disposeBag)
        
        input.loginTap
            .withLatestFrom(Observable.combineLatest(email, password))
            .flatMapLatest { email, password in
                APIManger.shared.requestJSONPost(
                    requestType: Router.login(
                        loginBody: LoginBodyModel(email: email,
                                                  password: password)
                    ), decodableType: LoginResult.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let responseResult):
                    DispatchQueue.global().async {
                        TokenManger.shared.changeAccount(account: responseResult._id)
                        
                        TokenManger.shared.addTokenToUserDefaults(
                            tokenType: .accessToken,
                            tokenValue: responseResult.token)
                        
                        TokenManger.shared.addTokenToUserDefaults(
                            tokenType: .refreshToken,
                            tokenValue: responseResult.refreshToken)
                    }
                    
                    presentHome.accept(true)
                    
                case .failure(let error):
                    if let error = error as? ErrorCase.FetchLoginError {
                        errorMessage.accept(error.errorMessage)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            errorMessage: errorMessage.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다."),
            signupTap: input.signupTap,
            presentHome: presentHome.asDriver()
        )
    }
}
