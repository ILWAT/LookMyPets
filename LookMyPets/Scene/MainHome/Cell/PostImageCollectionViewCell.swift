//
//  PostImageCollectionViewCell.swift
//  LookMyPets
//
//  Created by 문정호 on 12/11/23.
//

import UIKit

final class PostImageCollectionViewCell: UICollectionViewCell{
    //MARK: - Properties
    let postImage = UIImageView().then { view in
        view.contentMode = .scaleAspectFit
    }
    
    //MARK: - Initializatio
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("can't make by coder")
    }
    
    //MARK: - Configure UI
    private func configureHierarchy() {
        self.contentView.addSubview(postImage)
    }
    
    private func setConstraints(){
        postImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

