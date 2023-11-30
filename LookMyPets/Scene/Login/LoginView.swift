//
//  LoginView.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import UIKit

final class LoginView: BaseView {
    //MARK: - Properties
    
    let appLogoImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "pawprint.circle")
        view.contentMode = .scaleAspectFit
        view.tintColor = .mainTintColor
        return view
    }()
    
    let idTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.placeholder = "E-mail"
        view.returnKeyType = .next
        return view
    }()
    
    let pwTextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.placeholder = "PassWord"
        view.returnKeyType = .done
        return view
    }()
    
    let loginButton = {
        let view = UIButton()
        view.setTitle("로그인", for: .normal)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mainTintColor
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
    
    override func configureHierarchy() {
        self.addSubviews([appLogoImageView, loginStackView, loginButton, signUpButton])
        
    }
    
    override func setConstraints() {
        let componentDefaultOffset = 10
        appLogoImageView.snp.makeConstraints { make in
            make.bottom.equalTo(loginStackView.snp.top).offset(-componentDefaultOffset)
            make.size.equalTo(safeAreaLayoutGuide).multipliedBy(0.3)
            make.centerX.equalTo(loginStackView)
        }
        loginStackView.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(60)
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
