//
//  PassWordSignUpViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/29/23.
//

import Foundation
import RxCocoa
import RxSwift

final class PassWordSignUpViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        let nextBtnTap: ControlEvent<Void>
        let originPWText: ControlProperty<String>
        let checkPWText: ControlProperty<String>
    }
    
    struct Output {
        let nextBtnTap: ControlEvent<Void>
        let originPWGuide: Driver<PWValidationResultType>
        let checkPWGuide: Driver<PWValidationResultType>
        let validResult: Driver<Bool>
    }

    enum PWValidationResultType {
        case success
        case notEqual
        case empty
        case cantUse
        
        var guideText: String {
            switch self {
            case .success:
                return "올바른 비밀번호 입니다."
            case .notEqual:
                return "비밀번호가 같지 않습니다."
            case .empty:
                return "비밀번호를 입력해주세요."
            case .cantUse:
                return "잘못된 비밀번호입니다."
            }
        }
    }
    
    func transform(_ input: Input) -> Output {
        let originPWText = PublishRelay<String>()
        let checkPWText = PublishRelay<String>()
        
        let originPWGuide = BehaviorRelay<PWValidationResultType>(value: .empty)
        let checkPWGuide = BehaviorRelay<PWValidationResultType>(value: .empty)
        let validResult = BehaviorRelay<Bool>(value: false)
        
        
        input.originPWText
            .bind(with: self) { owner , string in
                originPWText.accept(string)
            }
            .disposed(by: disposeBag)
        
        input.checkPWText
            .bind(with: self) { owner, string in
                checkPWText.accept(string)
            }
            .disposed(by: disposeBag)
        
        
        Observable
            .combineLatest(originPWText, checkPWText)
            .asDriver(onErrorJustReturn: ("", ""))
            .filter({ !$0.0.isEmpty || !$0.1.isEmpty })
            .debug()
            .drive(with: self) { owner, observableList in
                if observableList.0 == observableList.1 {
                    validResult.accept(true)
                    checkPWGuide.accept(.success)
                } else {
                    validResult.accept(false)
                    checkPWGuide.accept(.notEqual)
                }
            }
            .disposed(by: disposeBag)
        
        
        originPWText
            .bind(with: self) { owner, string in
                switch string.isEmpty{
                case true:
                    validResult.accept(false)
                    originPWGuide.accept(.empty)
                case false:
                    originPWGuide.accept(.success)
                    break
                }
            }
            .disposed(by: disposeBag)
        
        
        checkPWText
            .filter({ $0.isEmpty })
            .bind(with: self, onNext: { owner, string in
                validResult.accept(false)
                checkPWGuide.accept(.empty)
            })
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            nextBtnTap: input.nextBtnTap,
            originPWGuide: originPWGuide.asDriver(),
            checkPWGuide: checkPWGuide.asDriver(),
            validResult: validResult.asDriver()
        )
    }
    
}
