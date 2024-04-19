//
//  DetailViewController.swift
//  wishListApp
//
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - Properties
    var productData: ProductData?
    
    
    // MARK: - Product Data Conversion
    // 제품 데이터 ProductData 형식으로 변환
    // - Parameters:
    //   - product: 변환할 제품
    // - Returns: 변환된 ProductData 객체
    func convertToProductData(_ product: Product) -> ProductData {
        return ProductData(id: Int(product.id), title: product.title ?? "", productDescription: product.productDescription ?? "", price: Double(Int(product.price)), discountPercentage: Double(Int(product.discountPercentage)), rating: Double(Int(product.rating)), brand: "", category: product.category ?? "", thumbnail: product.thumbnail ?? "", images: product.images ?? [])
    }

    
    // MARK: - isFavorited Properties
    var isFavorited: Bool = false {
        didSet {
            updateFavoriteButtonImage()
        }
    }
    
    
    // MARK: - Favorite Button
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemRed
        button.backgroundColor = .clear
        return button
    }()
    
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1 // 한 줄에 제한
        label.adjustsFontSizeToFitWidth = true // 텍스트가 맞게 줄어들도록 허용
        label.minimumScaleFactor = 0.5 // 텍스트에 대한 최소 축소 비율
        label.lineBreakMode = .byTruncatingTail // 텍스트가 맞지 않는 경우 끝에서 잘라냄
        label.backgroundColor = .clear
        return label
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tooltipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(white: 0, alpha: 0.7) // 반투명 검은색 배경
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "위시에 추가해봐요!"
        label.alpha = 0 // 초기에는 숨김
        label.layer.cornerRadius = 8 // 모서리를 둥글게 처리
        label.clipsToBounds = true
        return label
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateFavoriteButtonImage()
        checkIfFavorited()

        if !isFavorited {
            setupTooltipLabel()
            showTooltipLabel()
        }
    }
    
    // MARK: - Tooltip Label 설정
    private func setupTooltipLabel() {
        view.addSubview(tooltipLabel)
        
        NSLayoutConstraint.activate([
            tooltipLabel.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 6), // 하트 버튼 아래에 위치하되 약간의 간격 추가
            tooltipLabel.centerXAnchor.constraint(equalTo: favoriteButton.centerXAnchor, constant: -50), // 하트 버튼과 수평 중앙 정렬
            tooltipLabel.widthAnchor.constraint(equalToConstant: 140), // 필요한 만큼의 너비 조정
            tooltipLabel.heightAnchor.constraint(equalToConstant: 30) // 필요한 만큼의 높이 조정
        ])
        
        let bubblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 150, height: 30), cornerRadius: 4)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = bubblePath.cgPath
        
        tooltipLabel.layer.mask = maskLayer
    }


    // MARK: - Tooltip Label 표시
    private func showTooltipLabel() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.tooltipLabel.alpha = 1
        }, completion: { _ in
            self.hideTooltipLabel()
        })
    }

    // MARK: - Tooltip Label 숨기기
    private func hideTooltipLabel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
                self.tooltipLabel.alpha = 0
            })
        }
    }
    
    // MARK: - UI settings
    private func setupViews() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(favoriteButton)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60) // 필요한 만큼 높이 조정
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -16) // 타이틀과 버튼 사이의 간격 조정
        ])
        
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30), // 필요한 만큼 너비 조정
            favoriteButton.heightAnchor.constraint(equalToConstant: 30) // 필요한 만큼 높이 조정
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16), // 필요한 만큼 간격 조정
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32) // 필요한 만큼 너비 조정
        ])

        
        if let product = productData {
            titleLabel.text = product.title
            
            let thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .scaleAspectFit
            thumbnailImageView.clipsToBounds = true
            thumbnailImageView.layer.cornerRadius = 14 // 필요한 만큼 모서리 조정
            thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(thumbnailImageView)
            if let url = URL(string: product.thumbnail) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let error = error {
                        print("Error loading thumbnail image: \(error)")
                        return
                    }
                    if let data = data {
                        DispatchQueue.main.async {
                            thumbnailImageView.image = UIImage(data: data)
                            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.75).isActive = true
                        }
                    }
                }.resume()
            }
            
            
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.heightAnchor.constraint(equalToConstant: 4).isActive = true // 필요한 만큼 높이 조정
            
            stackView.addArrangedSubview(spacerView)

            priceLabel.text = "Price: $\(product.price)"
            
            stackView.addArrangedSubview(priceLabel)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = product.productDescription
            descriptionLabel.numberOfLines = 0
            stackView.addArrangedSubview(descriptionLabel)

            let topSpacer = UIView()
            topSpacer.translatesAutoresizingMaskIntoConstraints = false
            topSpacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
            stackView.addArrangedSubview(topSpacer)

            let bottomSpacer = UIView()
            bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
            bottomSpacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
            stackView.addArrangedSubview(bottomSpacer)

            let separatorContainerView = UIView()
            separatorContainerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(separatorContainerView)

            let separator = UIView()
            separator.backgroundColor = .lightGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            separatorContainerView.addSubview(separator)

            NSLayoutConstraint.activate([
                separatorContainerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
                separatorContainerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            ])

            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: separatorContainerView.topAnchor),
                separator.leadingAnchor.constraint(equalTo: separatorContainerView.leadingAnchor, constant: 50),
                separator.trailingAnchor.constraint(equalTo: separatorContainerView.trailingAnchor, constant: -50),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])

            
            let additionalImagesLabel = UILabel()
            additionalImagesLabel.text = "Additional Images"
            additionalImagesLabel.font = UIFont.boldSystemFont(ofSize: 18)
            stackView.addArrangedSubview(additionalImagesLabel)
            
            let imagesScrollView = UIScrollView()
            imagesScrollView.translatesAutoresizingMaskIntoConstraints = false
            imagesScrollView.showsHorizontalScrollIndicator = false
            stackView.addArrangedSubview(imagesScrollView)
            
            let imagesStackView = UIStackView()
            imagesStackView.axis = .horizontal
            imagesStackView.spacing = 8
            imagesStackView.translatesAutoresizingMaskIntoConstraints = false
            imagesScrollView.addSubview(imagesStackView)
            
            NSLayoutConstraint.activate([
                imagesScrollView.heightAnchor.constraint(equalToConstant: 150),
                imagesScrollView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                imagesStackView.topAnchor.constraint(equalTo: imagesScrollView.topAnchor),
                imagesStackView.leadingAnchor.constraint(equalTo: imagesScrollView.leadingAnchor),
                imagesStackView.trailingAnchor.constraint(equalTo: imagesScrollView.trailingAnchor),
                imagesStackView.bottomAnchor.constraint(equalTo: imagesScrollView.bottomAnchor),
                imagesStackView.heightAnchor.constraint(equalTo: imagesScrollView.heightAnchor)
            ])
            
            for imageUrl in product.images {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                if let url = URL(string: imageUrl) {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        if let error = error {
                            print("Error loading image: \(error)")
                            return
                        }
                        if let data = data {
                            DispatchQueue.main.async {
                                imageView.image = UIImage(data: data)
                                imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
                                imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
                            }
                        }
                    }.resume()
                }
                imagesStackView.addArrangedSubview(imageView)
            }
                        
            let imageSliderSpacer = UIView()
                imageSliderSpacer.translatesAutoresizingMaskIntoConstraints = false
                imageSliderSpacer.heightAnchor.constraint(equalToConstant: 16).isActive = true // 필요한 만큼 높이 조정
                stackView.addArrangedSubview(imageSliderSpacer)

        }
    }


    // MARK: - Action method
    // 위시 데이터 상태를 확인 후 업데이트
    private func checkIfFavorited() {
        if let productData = productData {
            isFavorited = CoreDataManager.shared.isProductSaved(withID: productData.id)
        }
    }

    // 위시 담기 버튼을 탭할 때 동작 처리
    @objc private func favoriteButtonTapped() {
        if let productData = productData {
            if isFavorited {
                CoreDataManager.shared.deleteProductData(withID: productData.id)
            } else {
                CoreDataManager.shared.saveProductData(productData)
            }
            isFavorited.toggle()
        }
        updateFavoriteButtonImage()
    }

    // MARK: - Product Creation
    // - Parameters:
    //   - productData: 생성할 제품 데이터
    // - Returns: 생성된 제품 객체
    private func createProduct(from productData: ProductData) -> Product {
        let product = Product(context: CoreDataManager.shared.managedObjectContext)
        product.title = productData.title
        return product
    }

    
    // MARK: - Helper method
    // 위시 담기 버튼 이미지 업데이트
    private func updateFavoriteButtonImage() {
        let imageName = isFavorited ? "heart.fill" : "heart"
        let image = UIImage(systemName: imageName)
        favoriteButton.setImage(image, for: .normal)
    }
}
