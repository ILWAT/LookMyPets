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
        let addPostTap: ControlEvent<Void>
    }
    
    struct Output{
        let postCellData: Driver<[GetPostData]>
        let showToast: Driver<Bool>
        let addPostTap: ControlEvent<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let nextCursor = BehaviorSubject<String?>(value: nil)
        let requestedDataSubject = PublishSubject<[GetPostData]>()
        let postData = BehaviorRelay<[GetPostData]>(value: [])
        let requestRequired = BehaviorSubject<Bool>(value: true)
        let allTokensExpired = PublishRelay<Bool>()
        let showToast = PublishRelay<Bool>()
        
    
        
        requestRequired
            .filter({ $0 })
            .withLatestFrom(nextCursor)
            .filter({ $0 != "0" })
            .debug()
            .flatMapLatest({ nextCursor in
                APIManger.shared.requestByRx(
                    requestType: .getPost(getPostData: GetPostBodyModel(next: nextCursor, limit: "5", product_id: PostProductID.all.rawValue)),
                    resultModel: GetPostResultModel.self
                )
            })
            .subscribe(with: self) { owner, requestResult in
                switch requestResult{
                case .success(let result):
                    nextCursor.onNext(result.next_cursor)
                    requestedDataSubject.onNext(result.data)
                    
                case .failure(let error):
                    guard let moyaError = error as? MoyaError, let statusCode = moyaError.response?.statusCode else { return }
                    
                    if statusCode == 418 { //status Code == 418 : 모든 토큰 만료 => 로그인 화면으로 돌아가야함
                        allTokensExpired.accept(true)
                    } else {
                        showToast.accept(true)
                    }
                    return
                }
            }
            .disposed(by: disposeBag)
        
        requestedDataSubject
            .map { getPost in
                var totalPostData = postData.value
                print("totalPostData:",totalPostData)
                totalPostData += getPost
                print("totalPostData", totalPostData)
                return totalPostData
            }
            .debug()
            .subscribe(with: self) { owner, getPostArray in
                print("resultPostData:",getPostArray)
                postData.accept(getPostArray)
            }
            .disposed(by: disposeBag)
        
        input.collectionView.prefetchItems
            .debug("prefetchItems")
            .map({
                for indexPath in $0 {
                    if indexPath.item == postData.value.count - 2 {
                        return true
                    }
                }
                return false
            })
            .filter({ $0 })
            .subscribe(with: self) { owner, value in
                requestRequired.onNext(value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            postCellData: postData.asDriver(onErrorJustReturn: []),
            showToast: showToast.asDriver(onErrorJustReturn: true),
            addPostTap: input.addPostTap
        )
    }
}
