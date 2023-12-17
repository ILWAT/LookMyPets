//
//  PostImageCollectionViewCell.swift
//  LookMyPets
//
//  Created by 문정호 on 12/11/23.
//

import UIKit
import Kingfisher

final class PostImageCollectionViewCell: UICollectionViewCell{
    //MARK: - Properties
    private let postImage = UIImageView().then { view in
        view.contentMode = .scaleAspectFit
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't make by coder")
    }
    
    
    //MARK: - lifecycle
    override func prepareForReuse() {
        postImage.image = nil
    }
    
    //MARK: - Configure UI
    private func configureHierarchy() {
        self.contentView.addSubview(postImage)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    private func setConstraints(){
        postImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Helper
    func showImage(element: String){
        let itemSize = self.bounds.size
        print(itemSize)
        postImage.kf.setImageWithAuthHeaders(
            with: URL(string: SecretKeys.SeSAC_ServerBaseURL+"/\(element)"),
            options: [
                .processor(DownsamplingImageProcessor(size: itemSize)),
                .transition(.fade(1)),
                .cacheOriginalImage,
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(1)))
            ]
        )
    }
}

