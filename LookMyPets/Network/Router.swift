//
//  Router.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation
import Moya

protocol catchErrorTargetType: TargetType {
    var resultModel: Decodable.Type { get }
    var needsToken: Bool { get }
}

enum Router {
    case validation_Email(email: ValidationEmailBodyModel)
    case signup(signupData: SignupBodyModel)
    case login(loginBody: LoginBodyModel)
    case refresh(refreshToken: String)
}


//MARK: - Protocols
extension Router: catchErrorTargetType {
    
    var baseURL: URL {
        URL(string: SecretKeys.SeSAC_ServerBaseURL)!
    }
    
    var path: String {
        switch self {
        case .validation_Email:
            return "/validation/email"
        case .signup:
            return "/join"
        case .login:
            return "/login"
        case .refresh:
            return "/refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation_Email, .signup, .login:
            return .post
        case .refresh:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .validation_Email(let email):
            return .requestJSONEncodable(email)
        case .signup(let joinData):
            return .requestJSONEncodable(joinData)
        case .login(let loginBody):
            return .requestJSONEncodable(loginBody)
        case .refresh:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation_Email, .signup, .login:
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey
            ]
        case .refresh(let refreshToken):
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey,
                "Authorization": refreshToken
            ]
        }
    }
    
    var validationType: ValidationType {
        switch self {
        case .validation_Email, .signup, .login, .refresh:
            return .successCodes
        }
    }
    
    //MARK: - Custom TargetType
    
    var resultModel: Decodable.Type {
        switch self {
        case .validation_Email:
            return ValidationEmailResult.self
        case .signup:
            return SignupResult.self
        case .login:
            return LoginResult.self
        case .refresh:
            return RefreshResult.self
        }
    }
    
    var needsToken: Bool {
        switch self {
        case .login, .signup, .validation_Email, .refresh:
            return false
        default :
            return true
        }
    }
    
    func emitError(statusCode: Int) -> Error? {
        if let error = ErrorCase.CommonError(rawValue: statusCode){
            return error
        } else {
            switch self {
            case .validation_Email:
                return ErrorCase.FetchValidationEmailError(rawValue: statusCode)
            case .signup:
                return ErrorCase.FetchSignupError(rawValue: statusCode)
            case .login:
                return ErrorCase.FetchLoginError(rawValue: statusCode)
            case .refresh:
                return ErrorCase.fetchRefreshError(rawValue: statusCode)
            }
        }
    }
    
    
}
