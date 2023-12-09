//
//  APIManger.swift
//  LookMyPets
//
//  Created by 문정호 on 11/23/23.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import RxCocoa

final class APIManger {
    //MARK: - Properties
    static let shared = APIManger()
    
    let provider = MoyaProvider<Router>(plugins: [TokenAuthPlugin(
        tokenClosure: {
            TokenManger.shared.readCurrentTokenInUserDefaults(tokenType: .accessToken)
        }
    )])

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
                
                    if let commonError = ErrorCase.CommonError(rawValue: statusCode) {
                        single(.success(.failure(commonError)))
                    } else if let fetchError = ErrorCase.FetchValidationEmailError(rawValue: statusCode) {
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
                    
                    if let error = ErrorCase.CommonError(rawValue: statusCode) {
                        single(.success(.failure(error)))
                    } else if let error = ErrorCase.FetchSignupError(rawValue: statusCode){
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
    
    
    
    func requestByRx<D: Decodable>(requestType: Router, resultModel: D.Type) -> Single<Result<D,Error>> {
        return Single.create { single in
            self.provider.rx.request(requestType)
                .catch({ error in //토큰 만료의 에러라면 토큰을 재발급 받아야 함
                    guard let moyaError = error as? MoyaError,
                          let statusCode = moyaError.response?.statusCode,
                          statusCode == 419 else { return Single.error(error) }
                    
                    return Single.create{ refreshSingle in
                        self.provider.request(.refresh(refreshToken: TokenManger.shared.readCurrentTokenInUserDefaults(tokenType: .refreshToken) ?? "")){ result in
                            switch result {
                            case .success(let response):
                                do {
                                    let decodedData = try JSONDecoder().decode(RefreshResult.self, from: response.data)
                                    TokenManger.shared.addTokenToUserDefaults(tokenType: .accessToken, tokenValue: decodedData.token)
                                    return refreshSingle(.failure(error))
                                } catch {
                                    return refreshSingle(.failure(ErrorCase.LocalError.decodeError))
                                }
                            case .failure(let moyaError):
                                return refreshSingle(.failure(moyaError))
                            }
                        }
                        return Disposables.create()
                    }
                })
                .retry(3)
                .subscribe(with: self) { owner, response  in
                    do{
                        let decodedData = try response.map(resultModel)
                        single(.success(.success(decodedData)))
                    } catch let error {
                        single(.success(.failure(error)))
                    }
                   
                } onFailure: { owner, error in
                    single(.success(.failure(error)))
                }
                .dispose()
            
            return Disposables.create()
        }
    }
}

