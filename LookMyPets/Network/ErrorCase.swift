//
//  ErrorCase.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import Foundation

protocol SeSACErrorCase: Error {
    var errorMessage: String { get }
}

enum ErrorCase{
    enum LocalError: SeSACErrorCase{
        case decodeError
        
        var errorMessage: String {
            switch self{
            case .decodeError:
                return "Decoding Error"
            }
        }
    }
    
    enum CommonError: Int, SeSACErrorCase {
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

    enum FetchValidationEmailError: Int, SeSACErrorCase  {
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


    enum FetchSignupError: Int, SeSACErrorCase  {
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

    enum FetchLoginError: Int, SeSACErrorCase  {
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

    enum fetchRefreshError: Int, SeSACErrorCase {
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
    
    enum getPostError: Int, SeSACErrorCase {
        case wrongRequest = 400
        case notValidToken = 401
        case forbidden = 403
        case expireToken = 419
        
        var errorMessage: String {
            switch self {
            case .wrongRequest:
                return "잘못된 요청입니다"
            case .notValidToken:
                return "인증할 수 없는 액세스 토큰입니다."
            case .forbidden:
                return "접근 권한이 없습니다."
            case .expireToken:
                return "액세스 토큰이 만료되었습니다."
            }
        }
    }
    
    enum ContentTestError: Int, SeSACErrorCase {
        case unValidToken = 401
        case Forbidden = 403
        case expireToekn = 419
        
        var errorMessage: String {
            switch self {
            case .unValidToken:
                return "인증할 수 없는 토큰"
            case .Forbidden:
                return "forbidden"
            case .expireToekn:
                return "액세스 토큰 만료"
            }
        }
    }
}


