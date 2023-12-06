//
//  KeyChainManger.swift
//  LookMyPets
//
//  Created by 문정호 on 12/6/23.
//

import Security

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

enum JWTokenType: String{
    case accessToken = "token"
    case refreshToken = "refreshToken"
}

final class KeyChainManger {
    //MARK: - Singleton
    static let shared = KeyChainManger()

    private init(){}
    
    func addTokenToKeychain(tokenType: JWTokenType, tokenValue: String) -> Result<Void,KeychainError> {
        guard let tokenAsData = tokenValue.data(using: .utf8, allowLossyConversion: false) else { return .failure(KeychainError.unexpectedPasswordData)}
        
        let itemQuery: [CFString: Any] = [ kSecClass : kSecClassInternetPassword,
                                  kSecAttrServer: SecretKeys.SeSAC_ServerBaseURL,
                                 kSecAttrComment: tokenType.rawValue,
                                   kSecValueData: tokenAsData
        ]
        
        SecItemDelete(itemQuery as CFDictionary)
        
        let status = SecItemAdd(itemQuery as CFDictionary, nil)
        guard status == errSecSuccess else { return .failure(KeychainError.unhandledError(status: status)) }
        return .success(())
    }
    
    
}
