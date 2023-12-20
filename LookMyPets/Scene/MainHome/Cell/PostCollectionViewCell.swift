//
//  PostCollectionViewCell.swift
//  LookMyPets
//
//  Created by 문정호 on 12/10/23.
//

import UIKit

import Kingfisher
import RxDataSources
import RxCocoa
import RxSwift
import Then


struct PostImageSection: SectionModelType {
    var items: [String]
    
    init(original: PostImageSection, items: [String]) {
        self = original
        self.items = items
    }
}

final class PostCollectionViewCell: UICollectionViewCell {
    //MARK: - UI Properties
    private let screenWidth = UserDefaults.standard.double(forKey: "ScreenWidth")
    
    private let profileImage = UIImageView().then {
        $0.image = UIImage(systemName: "person")
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let profileName = UIButton().then {
        $0.setTitle("사용자", for: .normal)
        var config = UIButton.Configuration.plain()
        config.titleAlignment = .leading
        
        config.baseForegroundColor = .label
        $0.configuration = config
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private let moreInfoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.tintColor = .label
    }
    
    lazy var topHStackView = UIStackView().then { view in
        [profileImage, profileName, moreInfoButton].forEach { element in
            view.addArrangedSubview(element)
        }
        view.axis = .horizontal
        view.spacing = 3
        view.alignment = .fill
        view.distribution = .fill
    }
    
    lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: setCollectionViewLayout()).then{
        $0.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PostImageCollectionViewCell.self))
        $0.decelerationRate = .fast
        $0.isPagingEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    private let likeButton = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
        $0.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        $0.tintColor = .label
    }
    
    private let commentButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .label
    }
    
    private let shareButton = UIButton().then {
        $0.setImage(UIImage(systemName: "paperplane"), for: .normal)
        $0.tintColor = .label
    }
    
    private lazy var interactionStackView = UIStackView().then{ view in
        [self.likeButton, self.commentButton, self.shareButton].forEach { btn in
            view.addArrangedSubview(btn)
        }
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
    }
    
    
    private lazy var imageControlBar = UIPageControl().then{
        $0.numberOfPages = 1
        $0.currentPageIndicatorTintColor = .tintColor
        $0.pageIndicatorTintColor = .systemGray5
        $0.hidesForSinglePage = true
    }

    
    private let bookmarkButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bookmark"), for: .normal)
        $0.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        $0.tintColor = .label
    }
    
    let likeCountButton = UIButton().then {
        $0.setTitle("좋아요 0개 ", for: .normal)
        var config = UIButton.Configuration.plain()
        config.titleAlignment = .center
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incoming in
            var outGoing = incoming
            outGoing.font = .footnote
            return outGoing
        })
        config.baseForegroundColor = .label
        $0.configuration = config
    }
    
    private let postLabel = UILabel().then { label in
        label.numberOfLines = 2
    }
    
    private let moreLookButton = UIButton().then { button in
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.textColor = .systemGray5
    }
    
    //MARK: - RxProperties
    private let postData = PublishRelay<GetPostData>()
    private let imageData = PublishRelay<[String]>()
    
    var disposeBag = DisposeBag()
    
    
    //MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        configureHierarchy()
        setConstraints()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("can't make by coder")
    }
    
    //MARK: - prepareForReuse
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
        bind()
    }
    
    //MARK: - Configure UI
    private func configureHierarchy() {
        self.contentView.addSubviews([topHStackView, imageCollectionView, interactionStackView, likeCountButton, imageControlBar, bookmarkButton, postLabel])
    }
    
    private func setConstraints(){
        let interItemSpacing = 10
        contentView.snp.makeConstraints { make in
            make.width.equalTo(screenWidth)
        }
        topHStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(interItemSpacing)
            make.height.equalTo(30)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topHStackView.snp.bottom).offset(interItemSpacing)
            make.horizontalEdges.equalTo(topHStackView)
            make.height.equalTo(imageCollectionView.snp.width)
        }
        interactionStackView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom)
            make.leading.equalTo(imageCollectionView)
            make.width.equalTo(imageCollectionView).multipliedBy(0.3)
        }
        imageControlBar.snp.makeConstraints { make in
            make.centerX.equalTo(imageCollectionView)
            make.centerY.equalTo(interactionStackView)
        }
        bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(interactionStackView)
            make.trailing.equalToSuperview().inset(interItemSpacing)
        }
        likeCountButton.snp.makeConstraints { make in
            make.leading.equalTo(interactionStackView)
            make.top.equalTo(interactionStackView.snp.bottom).offset(interItemSpacing)
        }
        postLabel.snp.makeConstraints { make in
            make.top.equalTo(likeCountButton.snp.bottom).offset(interItemSpacing)
            make.leading.equalTo(interactionStackView)
            make.trailing.equalToSuperview().inset(interItemSpacing)
            make.bottom.equalToSuperview().inset(interItemSpacing)
        }
    }
    
    private func setCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: screenWidth, height: screenWidth)
        return layout
    }
    
    func configurePostCellComponent(getPostData: GetPostData){
        self.postData.accept(getPostData)
    }
    
    
    //MARK: - RxBinding
    private func bind(){
        postData
            .asDriver(onErrorJustReturn: GetPostData(likes: [], image: [], hashTags: [], comments: [], time: "", _id: "", creator: CreatorInfo(_id: "", nick: "", profile: ""), content: "", content1: "", product_id: ""))
            .drive(with: self) { owner, post in
                if let profileImage = post.creator.profile{
                    let itemSize = owner.profileImage.bounds.size
                    
                    owner.profileImage.kf.setImageWithAuthHeaders(with: URL(string: SecretKeys.SeSAC_ServerBaseURL+"/\(profileImage)"),
                                                                  placeholder: UIImage(systemName: "person"),
                                                                  options: [
                                                                    .processor(DownsamplingImageProcessor(size: itemSize)),
                                                                    .transition(.fade(1)),
                                                                    .cacheOriginalImage,
                                                                    .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(1)))
                                                                  ]
                    )
                }
                owner.profileName.setTitle(post.creator.nick, for: .normal)
                owner.postLabel.text = post.content
                owner.likeCountButton.setTitle("좋아요 \(post.likes.count)개", for: .normal)
                owner.imageControlBar.numberOfPages = post.image.count
                owner.imageData.accept(post.image)
            }
            .disposed(by: disposeBag)
        
        imageData
            .bind(to: imageCollectionView.rx.items(cellIdentifier: String(describing: PostImageCollectionViewCell.self), cellType: PostImageCollectionViewCell.self)) { (row, element, cell) in
                cell.showImage(element: element)
            }
            .disposed(by: disposeBag)
        
        imageControlBar
            .rx.controlEvent(.valueChanged)
            .map({ _ in
                self.imageControlBar.currentPage
            })
            .bind(with: self) { owner, value in
                guard let layout = self.imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
                
                let itemSizeWithSpacing = layout.itemSize.width + layout.minimumInteritemSpacing //여백을 포함한 아이템 너비 구하기

                owner.imageCollectionView.rx.contentOffset.onNext(CGPoint(x: CGFloat(value) * itemSizeWithSpacing, y: 0))
            }
            .disposed(by: disposeBag)
        
        
        imageCollectionView.rx.willEndDragging
            .subscribe(with: self) { owner, delegateParameter in
                guard let layout = owner.imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
                
                let itemSizeWithSpacing = layout.itemSize.width + layout.minimumInteritemSpacing //여백을 포함한 아이템 너비 구하기
                
                let estimateItemIndex = owner.imageCollectionView.contentOffset.x / itemSizeWithSpacing // 현재 좌표가 어느 아이템을 보여주고 있는지 계산
                
                let index: Int
                
                if delegateParameter.velocity.x > 0{
                    index = Int(ceil(estimateItemIndex))
                } else if delegateParameter.velocity.x < 0 {
                    index = Int(floor(estimateItemIndex))
                } else {
                    index = Int(round(estimateItemIndex))
                }
                
                let itemPoint = CGFloat(index) * itemSizeWithSpacing
                
                self.imageControlBar.rx.currentPage.onNext(index)
                
                delegateParameter.targetContentOffset.pointee = CGPoint(x: itemPoint, y: 0)
            }
            .disposed(by: disposeBag)
    }
    
}
