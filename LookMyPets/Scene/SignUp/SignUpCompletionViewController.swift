//
//  SignUpCompletionViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 12/4/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class SignUpCompletionViewController: BaseViewController {
    //MARK: - UI Properties
    let image = {
        let view = UIImageView()
        view.image = UIImage(systemName: "checkmark.circle")
        view.tintColor = .green
        return view
    }()
    
    let doneTitle = {
        let view = UILabel()
        view.text = "회원 가입이 완료되었습니다!!\n이제 룩마이펫을 즐겨보세요!"
        view.textColor = .label
        view.numberOfLines = 2
        view.contentMode = .scaleAspectFit
        view.font = .boldSystemFont(ofSize: 20)
        return view
    }()
    
    lazy var vStackView = {
        let view = UIStackView(arrangedSubviews: [self.image, self.doneTitle])
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .center
        view.spacing = 8
        return view
    }()
    
    let button = CapsuleButton(buttonTitle: "로그인 창으로 이동", Background: .green, baseForegroundColor: .white)
    
    
    //MARK: - Rx Properties
    
    let disposeBag = DisposeBag()
    
    //MARK: - Override
    override func configure(){
        configureHierarchy()
        configureNavigation()
    }
    
    override func bind(){
        button.rx.tap
            .bind(with: self) { owner, _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Helper
    
    
    //MARK: - UI
    private func configureHierarchy(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubviews([vStackView, button])
        configureConstraints()
    }
    
    private func configureConstraints(){
        image.snp.makeConstraints { make in
            make.width.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.2)
            make.height.equalTo(image.snp.width)
        }
        vStackView.snp.makeConstraints { make in
            make.center.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.8)
        }
        button.snp.makeConstraints { make in
            make.top.equalTo(vStackView.snp.bottom).offset(30)
            make.centerX.equalTo(vStackView)
        }
    }
    
    
}


#Preview{
    SignUpCompletionViewController()
}
