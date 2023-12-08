//
//  EmailUpViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/27/23.
//

import RxSwift
import RxCocoa
import Foundation

final class EmailUpViewModel: ViewModelType {
    struct Input {
        let checkButtonTap: ControlEvent<Void>
        let nextButtonTap: ControlEvent<Void>
        let emailTextFieldText: ControlProperty<String>
        
    }
    
    struct Output {
        let nextButtonTap: ControlEvent<Void>
        let isHiddenError: Driver<Bool>
        let validChecked: Driver<Bool>
        let errorMessageText: Driver<String>
    }
    
    let disposeBag = DisposeBag()
    
    deinit{
        print("EmailUpViewModel deinit")
    }
    
    
    func transform(_ input: Input) -> Output {
        
        let validChecked = PublishRelay<Bool>()
        let isHiddenError = BehaviorRelay(value: true)
        let errorMessageText = BehaviorRelay(value: "이메일을 입력하세요.")
        let email = PublishRelay<String>()
    

        input.emailTextFieldText
            .asDriver()
            .drive(with: self, onNext: { owner, string in
                email.accept(string)
            })
            .disposed(by: disposeBag)
        
        let emailDrive = email.asDriver(onErrorJustReturn: "")
        
        emailDrive
            .filter({ string in
                !string.isEmpty
            })
            .drive(with: self) { owner, email in
                if owner.isValidEmail(email) {
                    isHiddenError.accept(true)
                    
                } else {
                    isHiddenError.accept(false)
                    errorMessageText.accept("올바르지 않은 이메일 형식입니다.")
                }
            }
            .disposed(by: disposeBag)
        
        emailDrive
            .filter({ string in
                string.isEmpty
            })
            .drive(with: self) { owner, string in
                isHiddenError.accept(false)
                errorMessageText.accept("이메일을 입력하세요.")
            }
            .disposed(by: disposeBag)
        
        
        input.checkButtonTap
            .withLatestFrom(email)
            .filter({ [weak self] email in
                (self?.isValidEmail(email) ?? false)
            })
            .flatMapLatest({ email in
                APIManger.shared.requestValidEmail(email: ValidationEmailBodyModel(email: email))
            })
            .catch({ error in
                return Observable<Result<ValidationEmailResult, Error>>.just(.failure(error))
            })
            .debug()
            .subscribe(with: self, onNext: { owner, result in
                switch result{
                case .success(_):
                    validChecked.accept(true)
                    isHiddenError.accept(true)
                    
                case .failure(let error):
                    validChecked.accept(false)
                    isHiddenError.accept(false)
                    
                    if let commonError = error as? ErrorCase.CommonError {
                        errorMessageText.accept(commonError.errorMessage)
                        print(commonError.errorMessage)
                    } else if let fetchError = error as? ErrorCase.FetchValidationEmailError {
                        errorMessageText.accept(fetchError.errorMessage)
                    } else {
                        errorMessageText.accept("알 수 없는 에러가 발생했습니다.")
                    }
                }
            })
            .disposed(by: disposeBag)

        
        return Output(
            nextButtonTap: input.nextButtonTap, 
            isHiddenError: isHiddenError.asDriver(),
            validChecked: validChecked.asDriver(onErrorJustReturn: false),
            errorMessageText: errorMessageText.asDriver()
        )
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

}
