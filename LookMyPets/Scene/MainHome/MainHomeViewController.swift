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
    }
    
    let testButton = UIButton().then { button in
        button.setTitle("tokenTest", for: .normal)
        button.backgroundColor = .blue
    }
    
    //MARK: - LifeCycle
    override func configure() {
        configureHierarchy()
        configureConstraints()
    }
    
    override func configureNavigation() {
        
    }
    
    override func bind() {
        let input = MainHomeViewModel.Input(tap: testButton.rx.tap)
        
        let output = viewModel.transform(input)
    }
    //MARK: - UI Configuration
    private func configureHierarchy(){
        self.view.backgroundColor = .systemBackground
//        self.view.addSubview(collectionView)
        self.view.addSubview(testButton)
    }
    
    private func configureConstraints(){
//        collectionView.snp.makeConstraints { make in
//            make.edges.equalTo(self.view.safeAreaLayoutGuide)
//        }
        
        testButton.snp.makeConstraints { make in
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    //MARK: - Helper
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
}


