//
//  PassWordSignUpViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 11/27/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class PassWordSignUpViewController: BaseViewController {
    //MARK: - UIProperties
    private let originPWTextField = {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.borderStyle = .roundedRect
        view.placeholder = "사용할 비밀번호를 입력해주세요."
        return view
    }()
    
    private let checkPWTextField = {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.borderStyle = .roundedRect
        view.placeholder = "사용할 비밀번호를 다시 입력해주세요."
        return view
    }()
    
    private let originPWGuideLabel = {
        let view = UILabel()
        view.isHidden = true
        view.textColor = .red
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    private let checkPWGuideLabel = {
        let view = UILabel()
        view.isHidden = true
        view.textColor = .red
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    private lazy var stackView = {
        let view = UIStackView(arrangedSubviews: [originPWTextField, originPWGuideLabel, checkPWTextField, checkPWGuideLabel])
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    private let nextButton = {
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
    //MARK: - RXProperties
    
    let viewModel = PassWordSignUpViewModel()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Override
    override func configure() {
        configureHierarchy()
    }
    
    override func configureNavigation() {
        self.title = "회원가입 - 비밀번호 설정"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func bind() {
        let input = PassWordSignUpViewModel.Input(
            nextBtnTap: nextButton.rx.tap,
            originPWText: originPWTextField.rx.text.orEmpty,
            checkPWText: checkPWTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input)
        
        output.originPWGuide
            .drive(with: self) { owner, result in
                let label = owner.originPWGuideLabel
                label.isHidden = false
                label.text = result.guideText
                switch result{
                case .success:
                    label.textColor = .systemGreen
                default:
                    label.textColor = .systemRed
                }
            }
            .disposed(by: disposeBag)
        
        output.checkPWGuide
            .drive(with: self) { owner, result in
                let label = owner.checkPWGuideLabel
                label.isHidden = false
                label.text = result.guideText
                switch result{
                case .success:
                    label.textColor = .systemGreen
                default:
                    label.textColor = .systemRed
                }
            }
            .disposed(by: disposeBag)
        
        output.validResult
            .drive(with: self) { owner, bool in
                owner.nextButton.isEnabled = bool
            }
            .disposed(by: disposeBag)
        
        output.nextBtnTap
            .bind(with: self) { owner, _ in
                self.navigationController?.pushViewController(UIViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - View
    private func configureHierarchy(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubviews([stackView, nextButton])
        setConstraints()
    }
    
    private func setConstraints() {
        originPWTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        checkPWTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        stackView.snp.makeConstraints { make in
            make.center.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
}

#Preview {
    PassWordSignUpViewController()
}
