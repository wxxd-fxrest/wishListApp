//
//  CollectionCellController.swift
//  giftWish
//
//

import UIKit

class CollectionCellController: UICollectionViewCell {
    
    // MARK: Properties
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // 이미지 콘텐츠를 셀 크기에 맞게 조절
        imageView.clipsToBounds = true // 셀 경계를 벗어나는 이미지를 잘라냄
        return imageView
    }()
    
    let productID: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center // 텍스트를 셀 왼쪽에 정렬
        label.numberOfLines = 0 // 여러 줄의 텍스트를 허용
        label.font = UIFont.systemFont(ofSize: 10) // 폰트 설정
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 2 // 4px만큼 모서리 둥글게 설정
        label.clipsToBounds = true // 모서리 둥글게 설정 시 마스킹을 위해 clipToBounds를 true로 설정
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left // 텍스트를 셀 왼쪽에 정렬
        label.font = UIFont.boldSystemFont(ofSize: 12) // 굵은 글꼴로 설정
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .right // 텍스트를 셀 왼쪽에 정렬
        label.font = UIFont.systemFont(ofSize: 12) // 굵은 글꼴로 설정
        return label
    }()
    

    // MARK: - Cell Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add image view, label
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(productID)
        contentView.addSubview(priceLabel) // Add priceLabel to contentView
        
        // cell border radius
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        
        // Auto Layout setting
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        productID.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false // Set priceLabel's translatesAutoresizingMaskIntoConstraints to false
        
        // 제약 설정
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8) // 이미지 뷰 높이
        ])

        NSLayoutConstraint.activate([
            // 상단을 썸네일 이미지 뷰의 하단에 위치하도록 설정
            productID.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 4),
            
            // label의 왼쪽 여백 및 위치 설정
            productID.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            
            // label의 넓이 설정
            productID.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            
            // label의 하단 간격 설정
            productID.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            // 제목 레이블의 상단을 제품 ID 레이블의 상단과 동일하게 설정
            titleLabel.topAnchor.constraint(equalTo: productID.topAnchor),
            
            // label의 위치를 오른쪽에 맞추고 왼쪽 여백 추가
            titleLabel.leadingAnchor.constraint(equalTo: productID.trailingAnchor, constant: 4),
            
            // label의 오른쪽 여백 설정
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            // label의 하단을 productID과 동일하게 설정
            titleLabel.bottomAnchor.constraint(equalTo: productID.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            // 가격 레이블의 상단을 제목 레이블의 하단에 위치하도록 설정
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4), // Add top anchor constraint
            
            // label의 위치를 오른쪽에 맞추고 왼쪽 여백 추가
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            
            // label의 오른쪽 여백 설정
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            // label의 하단을 contentView의 하단에 맞추도록 설정
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    

    // MARK: - Cell 구성
    func configure(with product: ProductData) {
        
        // animations 적용
        UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            // 셀 내용 업데이트
            self.productID.text = String(product.id)
            self.titleLabel.text = product.title
            self.priceLabel.text = String(product.price)
            self.loadImage(from: product.thumbnail)
        }, completion: nil)
    }


    // MARK: - Initialization from Coder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Image Loading
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        // URL에서 이미지 로드
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Failed to load image:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // 이미지 설정
            DispatchQueue.main.async {
                self?.thumbnailImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
