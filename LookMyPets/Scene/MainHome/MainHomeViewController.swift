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


final class MainHomeViewController: BaseViewController{
    //MARK: - Properties
    let viewModel = MainHomeViewModel()
    
    //MARK: - RxProperties
    let disposeBag = DisposeBag()
    
    //MARK: - UIVProperties
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout()).then { view in
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PostCollectionViewCell.self))
        view.delegate = self
    }

    
    //MARK: - LifeCycle
    override func configure() {
        configureHierarchy()
        configureConstraints()
    }
    
    override func configureNavigation() {
        
    }
    
    override func bind() {
        let input = MainHomeViewModel.Input(
            collectionView: collectionView.rx
        )
        
        let output = viewModel.transform(input)
        
        output.postCellData
            .drive(collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostCollectionViewCell.self), for: indexPath) as! PostCollectionViewCell
                cell.configurePostCellComponent(getPostData: element)
                return cell
            }
            .disposed(by: disposeBag)
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
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = CGSize(width: UserDefaults.standard.double(forKey: "ScreenWidth"), height:UserDefaults.standard.double(forKey: "ScreenWidth"))
        return layout
    }
    
}


extension MainHomeViewController: UICollectionViewDelegate {
    
}

