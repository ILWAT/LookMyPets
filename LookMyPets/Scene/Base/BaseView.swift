//
//  BaseView.swift
//  LookMyPets
//
//  Created by 문정호 on 11/21/23.
//

import UIKit

class BaseView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .systemBackground
        configureHierarchy()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    ///addSubView들을 실행
    func configureHierarchy(){}
    
    
    ///View의 Constraints를 설정
    func setConstraints() {}
}
