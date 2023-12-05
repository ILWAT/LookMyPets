//
//  Router.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation
import Moya

protocol DecodableTargetType {
    var resultModel: Decodable.Type { get }
}

enum Router {
    case validation_Email(email: ValidationEmailBodyModel)
    case signup(signupData: SignupBodyModel)
    case login(loginBody: LoginBodyModel)
}


//MARK: - Protocols
extension Router: TargetType, AccessTokenAuthorizable, DecodableTargetType {
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        case .validation_Email, .signup, .login:
            return .bearer
        default:
            return nil
        }
    }
    
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation_Email, .signup, .login:
            return .post
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
        }
        
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation_Email, .signup, .login:
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey
            ]
        }
    }
    
    var validationType: ValidationType {
        switch self {
        case .validation_Email, .signup, .login:
            return .customCodes([200])
        }
    }
    
    //MARK: - Custom
    
    var resultModel: Decodable.Type {
        switch self {
        case .validation_Email:
            return ValidationEmailResult.self
        case .signup:
            return SignupResult.self
        case .login:
            return LoginResult.self
        }
    }
    
    func emitError(statusCode: Int) -> Error? {
        if let error = CommonError(rawValue: statusCode){
            return error
        } else {
            switch self {
            case .validation_Email:
                return FetchValidationEmailError(rawValue: statusCode)
            case .signup:
                return FetchSignupError(rawValue: statusCode)
            case .login:
                return FetchLoginError(rawValue: statusCode)
            }
        }
    }
    
    
}
