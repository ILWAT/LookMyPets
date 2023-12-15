//
//  MainHomeViewModel.swift
//  LookMyPets
//
//  Created by 문정호 on 12/10/23.
//

import UIKit
import RxCocoa
import RxSwift
import Moya


final class MainHomeViewModel: ViewModelType {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    
    //MARK: - Input/Output Struct
    struct Input{
        let collectionView: Reactive<UICollectionView>
    }
    
    struct Output{
        let postCellData: Driver<[GetPostData]>
    }
    
    func transform(_ input: Input) -> Output {
        let nextCursor = BehaviorSubject(value: "")
        let postData = PublishSubject<[GetPostData]>()
        
        DispatchQueue.global().async {
            APIManger.shared.requestByRx(requestType: .getPost(getPostData: GetPostBodyModel(next: nil, limit: "5", product_id: "Matchelin"/*PostProductID.all.rawValue*/)), resultModel: GetPostResultModel.self)
                .debug()
                .subscribe(with: self) { owner, response in
                    switch response{
                    case .success(let result):
            
                        nextCursor.onNext(result.next_cursor)
                        postData.onNext(result.data)
                    case .failure(let error):
                        print(error)
                    }
                }
                .disposed(by: self.disposeBag)
        }
        
        
        
        
        
        
        return Output(
            postCellData: postData.asDriver(onErrorJustReturn: [])
        )
    }
}
