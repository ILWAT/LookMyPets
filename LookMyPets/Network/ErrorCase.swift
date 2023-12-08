//
//  ErrorCase.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import Foundation

protocol ErrorMessagesProtocol: Error {
    var errorMessage: String { get }
}

enum ErrorCase{
    enum CommonError: Int, ErrorMessagesProtocol {
        case noneSeSACKey = 420
        case overRequest = 429
        case notExistURL = 444
        case serverError = 500
        
        var errorMessage: String {
            switch self {
            case .noneSeSACKey:
                return "Key가 존재하지 않습니다."
            case .overRequest:
                return "과호출입니다."
            case .notExistURL:
                return "비정상 URL입니다."
            case .serverError:
                return "비정상 요청 및 사전에 정의되지 않는 에러가 발생했습니다."
            }
        }
    }

    enum FetchValidationEmailError: Int, ErrorMessagesProtocol  {
        case noneBody = 400
        case notInvalid = 409
        
        var errorMessage: String{
            switch self {
            case .noneBody:
                return "필수 입력값이 없습니다."
            case .notInvalid:
                return "사용이 불가한 이메일입니다."
            }
        }
    }


    enum FetchSignupError: Int, ErrorMessagesProtocol  {
        case existUser = 409
        case noneBody = 400
        
        var errorMessage: String {
            switch self {
            case .existUser:
                return "이미 가입되어 있는 회원입니다."
            case .noneBody:
                return "필수 값이 제대로 입력되었는지 확인해주세요."
            }
        }
    }

    enum FetchLoginError: Int, ErrorMessagesProtocol  {
        case noneBody = 400
        case checkAccount = 401
        
        var errorMessage: String {
            switch self {
            case .noneBody:
                return "필수 값을 채워주세요."
            case .checkAccount:
                return "계정을 확인해주세요."
            }
        }
    }

    enum fetchRefreshError: Int, ErrorMessagesProtocol {
        case forbidden = 401
        case notValidToken = 403
        case notExpire = 409
        case expiredToken = 418
        
        var errorMessage: String {
            switch self {
            case .forbidden:
                return "접근 권한이 없습니다."
            case .notValidToken:
                return "유효하지 않은 토큰입니다."
            case .notExpire:
                return "토큰이 만료되지 않았습니다."
            case .expiredToken:
                return "리프레시 토큰이 만료되었습니다."
            }
        }
    }
}


