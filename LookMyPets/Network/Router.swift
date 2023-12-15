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
    case getPost(getPostData: GetPostBodyModel)
    case postPost
    case content
    case imageLoad(imagePath: String)
}


//MARK: - Protocols
extension Router: catchErrorTargetType {
    
    var baseURL: URL {
        URL(string: SecretKeys.SeSAC_AuthTestURL)!
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
        case .getPost, .postPost:
            return "/post"
        case .content:
            return "/content"
        case .imageLoad(let imagePath):
            return "/uploads/posts/\(imagePath)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation_Email, .signup, .login, .postPost:
            return .post
        default: //.refresh, .getPost, .content,
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
        case .getPost(let getPostBody):
            return .requestParameters(parameters: ["next": getPostBody.next ?? "",
                                                   "limit": getPostBody.limit ?? "",
                                                   "product_id": getPostBody.product_id ?? ""],
                                      encoding: URLEncoding.queryString)
        default: //postPost, content, refresh
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        switch self {
        case .refresh(let refreshToken):
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey,
                "Refresh": refreshToken
            ]
        default://case .validation_Email, .signup, .login, .postPost, .getPost, .content:
            [
                "Content-Type": "application/json",
                "SesacKey": SecretKeys.SeSAC_ServerKey
            ]
        }
    }
    
    var validationType: ValidationType {
        switch self {
        default: //.validation_Email, .signup, .login, .refresh, .getPost, .postPost, .content
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
        case .getPost:
            return GetPostResultModel.self
        case .postPost:
            return GetPostResultModel.self
        case .content:
            return contentResultModel.self
        case .imageLoad:
            return contentResultModel.self
        }
    }
    
    var needsToken: Bool {
        switch self {
        case .login, .signup, .validation_Email:
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
            case .getPost:
                return ErrorCase.getPostError(rawValue: statusCode)
            case .postPost:
                return nil
            case .content:
                return ErrorCase.ContentTestError(rawValue: statusCode)
            default:
                return ErrorCase.CommonError(rawValue: statusCode)
            }
        }
    }
    
    
}
