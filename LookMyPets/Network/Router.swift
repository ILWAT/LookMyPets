//
//  Router.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation
import Moya

enum Router {
    case validation_Email(email: ValidationEmail)
    case signup(signupData: SignupBodyModel)
}

extension Router: TargetType {
    var baseURL: URL {
        URL(string: SecretKeys.SeSAC_ServerBaseURL)!
    }
    
    var path: String {
        switch self {
        case .validation_Email:
            return "/validation/email"
        case .signup:
            return "/join"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation_Email, .signup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .validation_Email(let email):
            return .requestJSONEncodable(email)
        case .signup(let joinData):
            return .requestJSONEncodable(joinData)
        }
        
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation_Email, .signup:
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey
            ]
        }
    }
    
    var validationType: ValidationType {
        switch self {
        case .validation_Email, .signup:
            return .customCodes([200])
        }
    }
    
    
}
