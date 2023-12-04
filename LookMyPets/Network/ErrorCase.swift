//
//  ErrorCase.swift
//  LookMyPets
//
//  Created by 문정호 on 11/30/23.
//

import Foundation

enum CommonError: Int, Error {
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

enum FetchValidationEmailError: Int,  Error {
    case noneBody = 400
    case notInvalid = 409
    
    var getMessage: String{
        switch self {
        case .noneBody:
            return "필수 입력값이 없습니다."
        case .notInvalid:
            return "사용이 불가한 이메일입니다."
        }
    }
}


enum FetchSignupError: Int, Error {
    case existUser = 409
    case noneBody = 400
    
    var getMessage: String {
        switch self {
        case .existUser:
            return "이미 가입되어 있는 회원입니다."
        case .noneBody:
            return "필수 값이 제대로 입력되었는지 확인해주세요."
        }
    }
}
