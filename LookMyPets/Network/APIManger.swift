//
//  APIManger.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation
import Moya
import RxSwift
import RxCocoa


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

final class APIManger {
    static let shared = APIManger()

    
    private init() {}
    
    func requestValidEmail(email: ValidationEmail) -> Single<Result<ValidationEmailResult, Error>> {
        let provider = MoyaProvider<Router>()
        
        return Single.create { single -> Disposable in
            provider.request(.validation_Email(email: email)) { result in
                print(email)
                
                switch result{
                case .success(let response):
                    print("success", response.statusCode)
                    do{
                        let decodedData = try JSONDecoder().decode(ValidationEmailResult.self, from: response.data)
                        single(.success(.success(decodedData)))
                    } catch {
                        single(.failure(error))
                    }
                    
                case .failure(let error):
                    let statusCode = error.response?.statusCode ?? 0
                    
                    print("failure \(statusCode)")
                
                    if let commonError = CommonError(rawValue: statusCode) {
                        single(.success(.failure(commonError)))
                    } else if let fetchError = FetchValidationEmailError(rawValue: statusCode) {
                        single(.success(.failure(fetchError)))
                    } else {
                        single(.failure(error))
                    }
                    
                }
            }
            return Disposables.create()
        }
    }
}

