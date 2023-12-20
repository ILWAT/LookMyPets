//
//  UserDefaultsWrapper.swift
//  LookMyPets
//
//  Created by 문정호 on 12/7/23.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper {
    private var account: String
    
    private let tokenType: JWTokenType
    
    //MARK: - initialization
    init(account: String, tokenType: JWTokenType) {
        self.account = account
        self.tokenType = tokenType
    }
    
    var wrappedValue: String? {
        get{ UserDefaults.standard.string(forKey: account+tokenType.rawValue) }
        set{ UserDefaults.standard.setValue(newValue, forKey: account+tokenType.rawValue) }
    }
    
    var projectedValue: String{
        set{ self.account = newValue }
        get{ self.account }
    }
}
