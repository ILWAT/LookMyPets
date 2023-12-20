//
//  MainHomeViewController.swift
//  LookMyPets
//
//  Created by 문정호 on 12/10/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit


final class MainHomeViewController: BaseViewController {
    
    //MARK: - Properties
    let viewModel = MainHomeViewModel()
    
    //MARK: - RxProperties
    let requestRequired = BehaviorSubject<Bool>(value: true)
    let disposeBag = DisposeBag()
    
    //MARK: - UIVProperties
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout()).then { view in
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PostCollectionViewCell.self))
        view.isPrefetchingEnabled = true
    }
    
    let addPostButton = UIBarButtonItem().then { view in
        view.image = UIImage(systemName: "plus")
        view.tintColor = .label
    }
    
    
    //MARK: - LifeCycle
    override func configure() {
        configureHierarchy()
        configureConstraints()
    }
    
    override func configureNavigation() {
        self.title = "게시물 보기"
        self.navigationItem.rightBarButtonItem = addPostButton
    }
    
    override func bind() {
        let input = MainHomeViewModel.Input(
            collectionView: collectionView.rx,
            addPostTap: addPostButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.postCellData
            .debug()
            .drive(collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostCollectionViewCell.self), for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                cell.configurePostCellComponent(getPostData: element)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.showToast
            .filter({ $0 })
            .drive(with: self) { owner, bool in
                owner.makeGeneralToast(message: "네트워크 통신간에 에러가 발생했습니다.\n 앱 종료 후. 다시 시도해주세요")
            }
            .disposed(by: disposeBag)
        
        
        addPostButton.rx.tap
            .subscribe(with: self) { owner, _ in
                print("hello")
            }
            .disposed(by: disposeBag)
        

        
//        collectionView.rx.prefetchItems
//            .debug("prefetchItems")
//            .subscribe(with: self) { owner, indexPathArray in
//                for indexPath in indexPathArray {
//                    if indexPath.item == owner.collectionView.numberOfItems(inSection: 0) - 2 {
//                        owner.requestRequired.onNext(true)
//                    }
//                }
//            }
//            .disposed(by: disposeBag)
//        
//        collectionView.rx.didScroll
//            .throttle(.milliseconds(50), scheduler: MainScheduler.instance)
//            .debug("didScroll")
//            .subscribe(with: self) { owner, _ in
//                let contentHeight = owner.collectionView.contentSize.height
//                let yOffset = owner.collectionView.contentOffset.y
//                let heightRemainBottomHeight = contentHeight - yOffset
//                
//                let frameHeight = owner.collectionView.frame.size.height
//                if heightRemainBottomHeight < frameHeight {
//                    owner.requestRequired.onNext(true)
//                }
//            }
//            .disposed(by: disposeBag)
        
    }
    //MARK: - UI Configuration
    private func configureHierarchy(){
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(collectionView)
    }
    
    private func configureConstraints(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        
    }
    
    //MARK: - Helper
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UserDefaults.standard.double(forKey: "ScreenWidth")
        let collectionViewHeight = self.view.bounds.height * 0.65
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: screenWidth, height: collectionViewHeight)
        return layout
    }
    
}
