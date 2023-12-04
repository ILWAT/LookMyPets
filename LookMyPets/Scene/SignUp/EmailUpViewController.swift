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
    
    private let emailTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.clearButtonMode = .always
        return view
    }()
    
    private let checkValidButton = {
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
    
    private let errorMessage = {
        let view = UILabel()
        view.textColor = .red
        view.isHidden = true
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var hStackView = {
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
        view.spacing = 4
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    private let nextButton = NextButton(title: "다음")

    
    //MARK: - RxProperties
    let disposeBag = DisposeBag()
        
    let viewModel = EmailUpViewModel()
    
    
    //MARK: - Override
    override func configure() {
        configureView()
        
    }
    
    override func configureNavigation() {
        self.navigationItem.title = "회원가입 - E-mail"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - RxBind
    override func bind() {
        let input = EmailUpViewModel.Input(
            checkButtonTap: checkValidButton.rx.tap,
            nextButtonTap: nextButton.rx.tap,
            emailTextFieldText: emailTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input)
        
        output.validChecked
            .drive(with: self, onNext: { owner, bool in
                owner.nextButton.rx.isEnabled.onNext(bool)
            })
            .disposed(by: disposeBag)
        
        output.isHiddenError
            .drive(with: self) { owner, bool in
                owner.errorMessage.rx.isHidden.onNext(bool)
            }
            .disposed(by: disposeBag)
        
        output.errorMessageText
            .drive(with: self, onNext: { owner, value in
                owner.errorMessage.text = value
            })
            .disposed(by: disposeBag)
    
        
        output.nextButtonTap
            .bind(with: self) { owner, _ in
                print("pushViewController")
                let nextVC = PassWordSignUpViewController()
                nextVC.passingSignupData(email: self.emailTextField.text ?? "")
                owner.navigationController?.pushViewController(nextVC, animated: true)
            }
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
        }
    }
    

    
    //MARK: - Helper
}
