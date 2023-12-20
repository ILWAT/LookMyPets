//
//  GuideTextFieldStackView.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import UIKit

final class GuideTextFieldVStack: UIStackView {
    let guideMessage = GuideLabel(frame: .zero, text: "")

    let textField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        return view
    }()
    
    init(placeHolder textFieldPlaceHolder: String, IsSecure textFieldIsSecure: Bool, ClearButton showClearBTN: Bool, GuideLabelHidden GuideHidden: Bool){
        super.init(frame: .zero)
        self.axis = .vertical
        self.spacing = 4
        self.alignment = .fill
        self.distribution = .equalSpacing
        self.isUserInteractionEnabled = true
        
        [textField, guideMessage].forEach { view in
            self.addArrangedSubview(view)
        }
        
        self.textField.isSecureTextEntry = textFieldIsSecure
        self.textField.clearButtonMode = showClearBTN ? .always : .never
        self.textField.placeholder = textFieldPlaceHolder
        self.guideMessage.isHidden = GuideHidden
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    
    ///TextField 자리에 다른 뷰를 사용하고자 할때 사용합니다.
    func replaceTextFieldPlace(subView: UIView){
        self.removeArrangedSubview(textField)
        self.insertArrangedSubview(subView, at: 0)
    }
        
    func chageGuideMessage(text: String){
        self.guideMessage.text = text
    }
    
    func chagneGuideMessageTextColor(color: UIColor){
        self.guideMessage.textColor = color
    }
    
    
}
