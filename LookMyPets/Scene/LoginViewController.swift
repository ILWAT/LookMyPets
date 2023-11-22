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


class LoginViewController: BaseViewController {
    //MARK: - Properties
    
    let idTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.placeholder = "E-mail"
        return view
    }()
    
    let pwTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.placeholder = "PassWord"
        return view
    }()
    
    let loginButton = {
        let view = UIButton()
        view.setTitle("로그인", for: .normal)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .green
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ input in
            var output = input
            output.font = .boldSystemFont(ofSize: 20)
            return output
        })
        config.cornerStyle = .capsule
        view.configuration = config
        return view
    }()
    
    let signUpButton = {
        let view = UIButton()
        view.setTitle("회원가입", for: .normal)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .systemGray3
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ input in
            var outgoing = input
            outgoing.font = UIFont.boldSystemFont(ofSize: 20)
            return outgoing
        })
        view.configuration = config
        return view
    }()
    
    lazy var loginStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fillEqually
        view.alignment = .fill
        view.addArrangedSubview(idTextField)
        view.addArrangedSubview(pwTextField)
        return view
    }()
    
    //MARK: - Configure
    override func configure() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubviews([loginStackView, loginButton, signUpButton])
        setConstraints()
    }
    
    override func configureNavigation() {
        
    }
    
    override func bind() {
        signUpButton.rx.tap
            .bind(with: self) { owner, _ in
                <#code#>
            }
    }
    
    
    
    func setConstraints(){
        let componentDefaultOffset = 10
        loginStackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(loginStackView)
            make.top.equalTo(loginStackView.snp.bottom).offset(componentDefaultOffset)
            make.height.equalTo(50)
        }
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(componentDefaultOffset)
            make.horizontalEdges.height.equalTo(loginButton)
        }
    }

}


//#Preview{
//    LoginViewController()
//}
