//
//  UserInfoUpViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/29/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class UserInfoUpViewController: BaseViewController{
    //MARK: - UIProperties
    private let scrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.bounces = true
        return view
    }()
    
    private lazy var contentView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let nicknameLabel = {
        let view = UILabel()
        view.text = "닉네임"
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    
    private let nicknameVStack = GuideTextFieldVStack(placeHolder: "사용할 닉네임을 입력해주세요.", IsSecure: false, ClearButton: true, GuideLabelHidden: true)
    
    private let phoneNumberLabel = {
        let view = UILabel()
        view.text = "전화 번호"
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    
    private let phoneNumberVStack = GuideTextFieldVStack(placeHolder: "전화번호를 입력해주세요.", IsSecure: false, ClearButton: true, GuideLabelHidden: true)
    
    private let birthdayLabel = {
        let view = UILabel()
        view.text = "생년월일"
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    
    private let birthDayButton = {
        let button = UIButton()
        button.setTitle(Date().formatted(), for: .normal)
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemGreen
        button.configuration = config
        return button
    }()
    
    private let nextButton = NextButton(title: "회원가입 완료하기")
    
    private let datePickerVC = DatePickerViewController()
    
    //MARK: - RXProperties
    private let viewModel = UserInfoUpViewModel()
    
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Properties
    let email: String
    let password: String
    private lazy var birthdayString: String = ""
    
    
    //MARK: - init
    init(email: String, password: String){
        self.email = email
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Override
    override func configure() {
        configureHierarchy()
    }
    
    override func configureNavigation() {
        self.title = "회원가입 - 유저 정보 입력"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func bind() {
        let input = UserInfoUpViewModel.Input(
            nickName: nicknameVStack.textField.rx.text.orEmpty,
            phoneNumber: phoneNumberVStack.textField.rx.text.orEmpty,
            birthdayTap: birthDayButton.rx.tap,
            birthday: datePickerVC.date,
            nextButtonTap: nextButton.rx.tap,
            email: self.email,
            password: self.password
        )
        
        let output = viewModel.transform(input)
        
        output.birthDayTap
            .bind(with: self) { owner, _ in
                if let sheet = owner.datePickerVC.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersGrabberVisible = true
                }

                owner.present(owner.datePickerVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.birthdayDriver
            .drive(with: self) { owner, date in
                owner.birthDayButton.setTitle(date.formatted(date: .numeric, time: .omitted), for: .normal)
            }
            .disposed(by: disposeBag)
        
        output.isValid
            .drive(with: self) { owner, bool in
                owner.nextButton.rx.isEnabled.onNext(bool)
            }
            .disposed(by: disposeBag)
        
        output.isSuccess
            .filter({ $0 })
            .drive(with: self) { owner, bool in
                owner.navigationController?.pushViewController(SignUpCompletionViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isSuccess
            .filter({ !$0 })
            .withLatestFrom(output.failReason)
            .drive(with: self) { owner, string in
                owner.makeDefaultAlert(alertTitle: "회원 가입 불가", alertMessage: string, okTitle: "로그인으로 이동") { [weak owner] action in
                    owner?.navigationController?.popToRootViewController(animated: true)
                } cancelAction: { _ in }
            }
            .disposed(by: disposeBag)
        
        
            
    }
    
    //MARK: - View
    private func configureHierarchy(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubviews([scrollView, nextButton])
        scrollView.addSubview(contentView)
        contentView.addSubviews([self.nicknameLabel, self.nicknameVStack, self.phoneNumberLabel, self.phoneNumberVStack, self.birthdayLabel, self.birthDayButton])
        setConstraints()
    }
    
    private func setConstraints() {
        let componentOffset = 10
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(nextButton.snp.top)
        }
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.top.equalTo(scrollView.contentLayoutGuide)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
        }
        nicknameVStack.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(componentOffset)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        phoneNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameVStack.snp.bottom).offset(componentOffset)
            make.leading.equalTo(nicknameLabel)
        }
        phoneNumberVStack.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberLabel.snp.bottom).offset(componentOffset)
            make.leading.trailing.equalTo(nicknameVStack)
        }
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberVStack.snp.bottom).offset(componentOffset)
            make.leading.equalToSuperview().inset(10)
        }
        birthDayButton.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(componentOffset)
            make.leading.equalTo(birthdayLabel)
            make.bottom.equalToSuperview().inset(10)
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

