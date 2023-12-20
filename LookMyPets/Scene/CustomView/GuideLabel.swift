//
//  GuideLabel.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import UIKit

///올바르지 않은 값이 입력 되었을 때 사용자에게 가이드를 주기 위해 사용 되는 Label
final class GuideLabel: UILabel {
    
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        self.text = text
        self.textColor = .red
        self.font = .systemFont(ofSize: 15)
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
