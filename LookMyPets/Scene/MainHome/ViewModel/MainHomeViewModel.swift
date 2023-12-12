//
//  MainHomeViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 12/10/23.
//

import Foundation
import RxCocoa
import RxSwift
import Moya


final class MainHomeViewModel: ViewModelType {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    
    struct Input{
        let tap: ControlEvent<Void>
    }
    
    struct Output{
        
    }
    
    func transform(_ input: Input) -> Output {
        APIManger.shared.requestByRx(requestType: .getPost(getPostData: GetPostBodyModel(next: nil, limit: "5", product_id: PostProductID.all.rawValue)), resultModel: GetPostResultModel.self)
            .debug()
            .subscribe(with: self) { owner, response in
                switch response{
                case .success(let result):
                    print(result)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.tap
            .flatMapLatest { _ in
                APIManger.shared.requestByRx(requestType: .content, resultModel: contentResultModel.self)
            }
            .debug()
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let resultModel):
                    print(resultModel.message)
                case .failure(let error):
                    if let moyaError = error as? MoyaError, let statusCode = moyaError.response?.statusCode{
                        print(statusCode)
                    }
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
        )
    }
}
