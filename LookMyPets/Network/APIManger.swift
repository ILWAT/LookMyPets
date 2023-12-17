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
    var bag = DisposeBag()
    
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
    
    
    /// Rx + Moya를 활용한 API request 메서드
    /// - 인자로 넣은 resultModel의 형태로 Single을 return
    /// - 기존 request 요청 419(토큰만료) 에러시, token 재발급  요청  후, 2번 재시도(retry)
    /// - 만약 기존 reqeust 419 + refreshToken request 418시, Single Error Emit
    /// - refresh 자동화, 고려사항 x  but error는 그대로 방출
    func requestByRx<D: Decodable>(requestType: Router, resultModel: D.Type) -> Single<Result<D,Error>> {
        return Single.create { single in
            self.provider.rx.request(requestType)
                .debug()
                .catch({ error in //토큰 만료의 에러라면 토큰을 재발급 받아야 함

                    guard let moyaError = error as? MoyaError,
                          let statusCode = moyaError.response?.statusCode,
                          statusCode == 419 else {
                        return Single.error(error)
                    }
                    
                    return Single.create{ refreshSingle in
                        self.provider.request(.refresh(refreshToken: TokenManger.shared.readCurrentTokenInUserDefaults(tokenType: .refreshToken) ?? "")){ result in
                            switch result {
                            case .success(let response):
                                do {
                                    let decodedData = try JSONDecoder().decode(RefreshResult.self, from: response.data)
                                    TokenManger.shared.addTokenToUserDefaults(tokenType: .accessToken, tokenValue: decodedData.token)
                                    print("refresh access Token:\(decodedData)")
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
                .debug()
                .subscribe(with: self) { owner, response  in
                    do{
                        print(response.data)
                        let decodedData = try response.map(resultModel)
                        print(decodedData)
                        single(.success(.success(decodedData)))
                    } catch let error {
                        print("api error", error)
                        single(.success(.failure(error)))
                    }
                   
                } onFailure: { owner, error in
                    print("Error")
                    guard let moyaError = error as? MoyaError,
                          let statusCode = moyaError.response?.statusCode,
                          statusCode == 418 else {
                        return single(.success(.failure(error)))
                    }
                    //AccessToken 만료 + RefreshToken 만료시, SingleError를 emit
                    single(.failure(error))
                }
//                .dispose()
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
}

