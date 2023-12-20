//
//  NextButton.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import UIKit

final class NextButton: UIButton{
    
    init(title: String) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .mainTintColor
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 20)
            return outgoing
        })
        self.configuration = config
        self.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
