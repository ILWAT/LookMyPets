//
//  CapsuleButton.swift
//  LookMyPets
//
//  Created by 문정호 on 12/4/23.
//

import UIKit

final class CapsuleButton: UIButton {
    init(buttonTitle: String, Background baseBackgroundColor: UIColor, baseForegroundColor: UIColor){
        super.init(frame: .zero)
        
        self.setTitle(buttonTitle, for: .normal)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = baseBackgroundColor
        config.baseForegroundColor = baseForegroundColor
        config.cornerStyle = .capsule
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
}
