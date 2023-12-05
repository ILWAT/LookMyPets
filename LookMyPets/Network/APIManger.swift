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

final class APIManger {
    //MARK: - Properties
    static let shared = APIManger()
    
    let provider = MoyaProvider<Router>()

    //MARK: - initialize
    private init() {}
    
    //MARK: - requestFunction
    func requestValidEmail(email: ValidationEmailBodyModel) -> Single<Result<ValidationEmailResult, Error>> {
        
        return Single.create { single -> Disposable in
            self.provider.request(.validation_Email(email: email)) { result in
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
    
    func reqeustJoin(signupData: SignupBodyModel) -> Single<Result<SignupResult, Error>> {
        return Single<Result<SignupResult, Error>>.create { (single) -> Disposable in
            self.provider.request(.signup(signupData: signupData)) { result in
                switch result {
                case .success(let response):
                    print("success", response.statusCode)
                    do{
                        let decodedData = try JSONDecoder().decode(SignupResult.self, from: response.data)
                        single(.success(.success(decodedData)))
                    } catch {
                        single(.failure(error))
                    }
                case .failure(let moyaError):
                    let statusCode = moyaError.response?.statusCode ?? 0
                    
                    print("failure \(statusCode)")
                    
                    if let error = CommonError(rawValue: statusCode) {
                        single(.success(.failure(error)))
                    } else if let error = FetchSignupError(rawValue: statusCode){
                        single(.success(.failure(error)))
                    } else {
                        single(.success(.failure(moyaError)))
                    }
                    
                }
                
            }
            return Disposables.create()
        }
    }
    
    func requestJSONPost<D: Decodable>(requestType: Router, decodableType: D.Type) -> Single<Result<D,Error>> {
        return Single.create { single -> Disposable in
            self.provider.request(requestType) { result in
                switch result{
                case .success(let response):
                    print("success", response.statusCode)
                    do{
                        let decodedData = try JSONDecoder().decode(decodableType, from: response.data)
                        single(.success(.success(decodedData)))
                    } catch (let error) {
                        single(.success(.failure(error)))
                    }
                    
                case .failure(let error):
                    let statusCode = error.response?.statusCode ?? 0
                    
                    print("failure \(statusCode)")
                    
                    if let error = requestType.emitError(statusCode: statusCode) {
                        single(.success(.failure(error)))
                    } else {
                        single(.success(.failure(error)))
                    }
                }
            }
            return Disposables.create()
        }
    }
}

