//
//  EmailUpViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EmailUpViewController: BaseViewController{
    //MARK: - Properties
    
    let nextButton = {
        let view = UIButton()
        view.setTitle("다음", for: .normal)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mainTintColor
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 20)
            return outgoing
        })
        view.configuration = config
        view.isEnabled = false
        return view
    }()
    
    let emailTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    let checkValidButton = {
        let view = UIButton()
        view.setTitle("중복 확인", for: .normal)
        var config = UIButton.Configuration.bordered()
        config.baseBackgroundColor = .mainTintColor
        config.baseForegroundColor = .white
        view.configuration = config
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    let errorMessage = {
        let view = UILabel()
        view.textColor = .red
        view.isHidden = true
        view.numberOfLines = 0
        return view
    }()
    
    lazy var hStackView = {
        let view = UIStackView(arrangedSubviews: [emailTextField, checkValidButton])
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 5
        view.alignment = .center
        return view
    }()
    
    lazy var vStackView = {
        let view = UIStackView(arrangedSubviews: [hStackView, errorMessage])
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    //MARK: - RxProperties
    let disposeBag = DisposeBag()
        
    let validChecked = PublishRelay<Bool>()
    let errorMessageText = BehaviorRelay(value: "이미 사용중인 이메일입니다\n다른 이메일을 사용해주세요.")
    let email = BehaviorSubject(value: "")
    
    
    //MARK: - Override
    override func configure() {
        configureView()
        
    }
    
    override func configureNavigation() {
        self.navigationItem.title = "회원가입 - E-mail"
    }
    
    //MARK: - RxBind
    override func bind() {
        validChecked
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, bool in
                owner.errorMessage.rx.isHidden.onNext(bool)
                owner.nextButton.rx.isEnabled.onNext(bool)
            })
            .disposed(by: disposeBag)
        
        errorMessageText
            .asDriver()
            .drive(with: self, onNext: { owner, value in
                owner.errorMessage.text = value
            })
            .disposed(by: disposeBag)
        
        emailTextField
            .rx.text.orEmpty
            .asDriver()
            .drive(with: self) { owner, string in
                owner.email.onNext(string)
            }
            .disposed(by: disposeBag)
        
        
        
        checkValidButton
            .rx.tap
            .withLatestFrom(email)
            .flatMapLatest({ email in
                APIManger.shared.requestValidEmail(email: ValidationEmail(email: email))
            })
            .catch({ error in
                return Observable<Result<ValidationEmailResult, Error>>.just(.failure(error))
            })
            .debug()
            .subscribe(with: self, onNext: { owner, result in
                switch result{
                case .success(_):
                    owner.validChecked.accept(true)
                    
                case .failure(let error):
                    owner.validChecked.accept(false)
                    if let commonError = error as? CommonError {
                        print(commonError.errorMessage)
                    } else if let fetchError = error as? FetchValidationEmailError {
                        owner.errorMessageText.accept(fetchError.getMessage)
                    } else {
                        
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - ConfigureView
    private func configureView(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubviews([vStackView, nextButton])
        setConstraints()
    }
    
    
    private func setConstraints() {
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        vStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }
    }
    

    
    //MARK: - Helper
}
