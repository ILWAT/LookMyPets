//
//  UserInfoUpViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import Foundation
import RxCocoa
import RxSwift

final class UserInfoUpViewModel: ViewModelType {
    //MARK: - Struct Input/Output
    struct Input {
        let nickName: ControlProperty<String>
        let phoneNumber: ControlProperty<String>
        let birthdayTap: ControlEvent<Void>
        let birthday: BehaviorRelay<Date>
        let nextButtonTap: ControlEvent<Void>
        let email: String
        let password: String
    }
    
    struct Output {
        let birthDayTap: ControlEvent<Void>
        let nickName: Driver<String>
        let phoneNumber: Driver<String>
        let birthdayDriver: Driver<Date>
        let isValid: Driver<Bool>
        let isSuccess: Driver<Bool>
        let failReason: Driver<String>
    }
    
    //MARK: - Properties
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Transform
    func transform(_ input: Input) -> Output {
        
        let nickName = PublishRelay<String>()
        let phoneNumber = BehaviorRelay<String>(value: "")
        let date = BehaviorRelay(value: Date())
        let isValid = PublishRelay<Bool>()
        let isSuccess = PublishRelay<Bool>()
        let failReason = PublishRelay<String>()
        
        let nicknameDriver = input.nickName
            .asDriver(onErrorJustReturn: "")
        
        nicknameDriver
            .drive { nickNameText in
                nickName.accept(nickNameText)
            }
            .disposed(by: disposeBag)
        
        nicknameDriver
            .filter({ $0.count >= 2})
            .drive(with: self) { owner, nicknameText in
                isValid.accept(true)
            }
            .disposed(by: disposeBag)
        
        nicknameDriver
            .filter({ $0.count < 2})
            .drive(with: self) { owner, nicknameText in
                isValid.accept(false)
            }
            .disposed(by: disposeBag)
        
        input.phoneNumber
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, phoneNumberText in
                print(phoneNumberText)
                phoneNumber.accept(phoneNumberText)
            })
            .disposed(by: disposeBag)
        
        input.birthday
            .asDriver()
            .drive(with: self, onNext: { owner, birthday in
                date.accept(birthday)
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTap
            .withLatestFrom(Observable.combineLatest(nickName, phoneNumber, date))
            .debug()
            .flatMapLatest({ [weak self] nickname, phoneNumber, birthday in
                APIManger.shared.reqeustJoin(signupData:
                                                SignupBodyModel(
                                                    email: input.email,
                                                    password: input.password,
                                                    nick: nickname,
                                                    phoneNum: phoneNumber,
                                                    birthDay: self?.dateFormatter.string(from: birthday)
                                                )
                )
            })
            .debug()
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let response):
                    print(response)
                    isSuccess.accept(true)
                case .failure(let error):
                    isSuccess.accept(false)
                    if let error = error as? CommonError {
                        print(error.errorMessage)
                        failReason.accept(error.errorMessage)
                    } else if let error = error as? FetchSignupError{
                        print(error)
                        failReason.accept(error.errorMessage)
                    } else {
                        print("알 수 없는 오류 입니다.")
                        failReason.accept("알 수 없는 오류가 발생했습니다.")
                    }
                }
            }
            .disposed(by: disposeBag)
        
////        let errorReason = Observable.zip(isValid.filter({ !$0 }), failReason)
//            .asDriver(onErrorJustReturn: (false, "알 수 없는 에러가 발생했습니다."))
        
        return Output(
            birthDayTap: input.birthdayTap,
            nickName: nickName.asDriver(onErrorJustReturn: ""),
            phoneNumber: phoneNumber.asDriver(onErrorJustReturn: ""),
            birthdayDriver: date.asDriver(),
            isValid: isValid.asDriver(onErrorJustReturn: false),
            isSuccess: isSuccess.asDriver(onErrorJustReturn: false),
            failReason: failReason.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
}
