//
//  KeyChainManger.swift
//  LookMyPets
//
//  Created by 문정호 on 12/6/23.
//

import Security
import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

enum JWTokenType: String{
    case accessToken = "token"
    case refreshToken = "refreshToken"
}

struct Token {
    @UserDefaultsWrapper(account:"", tokenType: .accessToken)
    var accessToken: String?
    
    @UserDefaultsWrapper(account: "", tokenType: .refreshToken)
    var refreshToken: String?
}

final class TokenManger {
    //MARK: - Properties
    private var token: Token = Token()
    //MARK: - Singleton
    static let shared = TokenManger()
    
    private init(){}
    
    //MARK: - Using UserDefaults
    func addTokenToUserDefaults(tokenType: JWTokenType, tokenValue: String) {
        switch tokenType {
        case .accessToken:
            token.accessToken = tokenValue
        case .refreshToken:
            token.refreshToken = tokenValue
        }
    }
    
    func deleteTokenInUserDefaults(tokenType: JWTokenType){
        switch tokenType {
        case .accessToken:
            token.accessToken = nil
        case .refreshToken:
            token.refreshToken = nil
        }
    }
    
    func readCurrentTokenInUserDefaults(tokenType: JWTokenType) -> String?{
        switch tokenType {
        case .accessToken:
            return token.accessToken
        case .refreshToken:
            return token.refreshToken
        }
    }
    
    func currentAccount() -> String {
        return self.token.$accessToken
    }
    
    func changeAccount(account: String){
        self.token.$accessToken = account
        self.token.$refreshToken = account
    }
    
    //MARK: - Using Keychain
    func addTokenToKeychain(tokenType: JWTokenType, tokenValue: String, completionHandler: ((Result<Void,KeychainError>) -> Void)? = nil ) {
        guard let tokenAsData = tokenValue.data(using: .utf8, allowLossyConversion: false) else { completionHandler?(.failure(KeychainError.unexpectedPasswordData))
            return
        }
        
        let itemQuery: [CFString: Any] = [ kSecClass : kSecClassInternetPassword,
                                  kSecAttrServer: SecretKeys.SeSAC_ServerBaseURL,
                                 kSecAttrAccount: tokenType.rawValue,
                                   kSecValueData: tokenAsData
        ]
        
        SecItemDelete(itemQuery as CFDictionary)
        
        let status = SecItemAdd(itemQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            completionHandler?(.failure(KeychainError.unhandledError(status: status)))
            return
        }
        completionHandler?(.success(()))
        return
    }
    
    func readTokenFromKeychain(tokenType: JWTokenType, completionHandler: ((Result<String,KeychainError>) -> Void)? = nil) {
        let itemQuery: [CFString: Any] = [ kSecClass : kSecClassInternetPassword,
                                  kSecAttrServer: SecretKeys.SeSAC_ServerBaseURL,
                                      kSecAttrAccount: tokenType.rawValue,
                                    kSecMatchLimit: kSecMatchLimitOne, //매칭되는 한개의 값만 받음
                                   kSecReturnData: true, // kCFBooleanTrue도 가능, retrurn data만 하게 되면 CFData형태로 return
                                 kSecReturnAttributes: true //이 Attribute를 추가하면 다수의 값이 리턴되어야 하므로 Dictonary 형태로 return
        ]
        
        var result: CFTypeRef? //typealias AnyObject
        
        let status = SecItemCopyMatching(itemQuery as CFDictionary, &result)
        
        guard status != errSecItemNotFound else { 
            completionHandler?(.failure(.noPassword))
            return }
        
        guard status == errSecSuccess else {
            completionHandler?(.failure(.unhandledError(status: status)))
            return}
        
        guard let resultItem = result as? [CFString: Any], let tokenAsData = resultItem[kSecValueData] as? Data, let token = String(data: tokenAsData, encoding: .utf8) else {
            completionHandler?(.failure(.unexpectedPasswordData))
            return
        }
        
        completionHandler?(.success(token))
        return
    }
    
    
    func deleteTokenAtKeychain(tokenType: JWTokenType) -> Result<Void, KeychainError>{
        let query: NSDictionary = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: SecretKeys.SeSAC_ServerBaseURL,
            kSecAttrComment: tokenType.rawValue
        ]
        
        let status = SecItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound else { return .failure(.unhandledError(status: status)) }
        return .success(())
    }
    
    
}
