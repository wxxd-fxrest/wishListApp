//
//  HomeViewController.swift
//  wishListApp
//
//

import UIKit

// MARK: - 제품 데이터 구조체
struct ProductData: Codable {
    let id: Int
    let title: String
    let productDescription: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let brand: String
    let category: String
    let thumbnail: String
    let images: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id, title, productDescription = "description", price, discountPercentage, rating, category, thumbnail, images, brand
    }
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    var collectionView: UICollectionView!
    let cellSpacing: CGFloat = 10
    let aspectRatio: CGFloat = 1.4
    let numberOfItemsPerRow = 3
    
    var data: [ProductData] = [] // 제품 데이터 배열
    var shuffledIDs: [Int] = [] // 무작위 ID 배열
    var currentPage = 1 // 현재 페이지
    let itemsPerPage = 10 // 페이지당 아이템 수
    var isFetchingData = false // 데이터 가져오는 중 여부
    var refreshControl: UIRefreshControl! // 리프레시 컨트롤
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shuffledIDs = Array(1...100).shuffled() // 1부터 100까지의 무작위 ID 배열 생성
        setupCollectionView() // 컬렉션 뷰 설정
        fetchData(forPage: currentPage) // 데이터 가져오기
        setupRefreshControl() // 리프레시 컨트롤 설정
    }

    
    // MARK: - Refresh Control 설정
    func setupRefreshControl() {
        refreshControl = UIRefreshControl() // UIRefreshControl 인스턴스 생성
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged) // 리프레시 시 호출될 메서드 지정
        collectionView.refreshControl = refreshControl // 컬렉션 뷰에 리프레시 컨트롤 추가
    }

    
    // MARK: - Refresh Data
    @objc func refreshData() {
        guard !isFetchingData else {
            return
        }
        isFetchingData = true
        data.shuffle() // 데이터 배열 섞기
        collectionView.reloadData() // 컬렉션 뷰 리로드
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing() // 리프레시 종료
            self.isFetchingData = false
        }
    }

    
    // MARK: - CollectionView 설정
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout() // UICollectionViewFlowLayout 인스턴스 생성
        layout.scrollDirection = .vertical // 수직 스크롤
        layout.minimumInteritemSpacing = cellSpacing // 셀 간의 최소 수평 간격
        layout.minimumLineSpacing = 12 // 라인(수직 방향) 간의 최소 간격
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout) // 컬렉션 뷰 생성
        collectionView.backgroundColor = .white // 배경색 설정
        collectionView.dataSource = self // 데이터 소스 설정
        collectionView.delegate = self // 델리게이트 설정
        collectionView.showsVerticalScrollIndicator = false // 수직 스크롤 바 숨기기
        collectionView.register(CollectionCellController.self, forCellWithReuseIdentifier: "collectionCell") // 셀 등록
        
        let margins: CGFloat = 20 // 여백
        collectionView.contentInset = UIEdgeInsets(top: margins, left: 0, bottom: margins + 100, right: 0) // 컨텐츠 인셋 설정
        let collectionViewWidth = view.bounds.width - 2 * margins // 컬렉션 뷰의 너비
        let collectionViewHeight = view.bounds.height // 컬렉션 뷰의 높이
        collectionView.frame = CGRect(x: margins, y: 0, width: collectionViewWidth, height: collectionViewHeight) // 프레임 설정
        
        view.addSubview(collectionView) // 뷰에 컬렉션 뷰 추가
    }

    
    // MARK: - JSON fetchData
    func fetchData(forPage page: Int) {
        let startIndex = (page - 1) * itemsPerPage // 시작 인덱스 계산
        let endIndex = min(page * itemsPerPage, shuffledIDs.count) // 종료 인덱스 계산
        
        guard startIndex < shuffledIDs.count && startIndex <= endIndex else {
            print("Invalid start index or end index")
            return
        }
        
        let randomIDs = Array(shuffledIDs[startIndex..<endIndex]) // 무작위 ID 배열
        
        let dispatchGroup = DispatchGroup() // 디스패치 그룹 생성
        
        for id in randomIDs {
            let urlString = "https://dummyjson.com/products/\(id)" // URL 문자열 생성
            if let url = URL(string: urlString) {
                dispatchGroup.enter() // 진입
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    defer {
                        dispatchGroup.leave() // 나감
                    }
                    
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data received")
                        return
                    }
                    
                    do {
                        let productData = try JSONDecoder().decode(ProductData.self, from: data) // Decode product data
                        self.appendDataSafely(productData) // Add data safely
                        print("🚀 Product Data for ID \(id): \(productData)")

                        // Fetch and output product data
                        let products = CoreDataManager.shared.fetchProducts()

                        // Perform operations using the returned product array
                        for product in products {
                            // Perform processing operations for each product
                            print(product.title ?? "No Title")
                        }

                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                task.resume()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isFetchingData = false
            self.refreshControl.endRefreshing()
            print("Number of items in section after fetching data: \(self.data.count)")
        }
    }

    
    // MARK: - Data 추가
    func appendDataSafely(_ productData: ProductData) {
        DispatchQueue.main.async {
            if !self.data.contains(where: { $0.id == productData.id }) {
                let indexPath = IndexPath(item: self.data.count, section: 0) // 새 인덱스 경로 생성
                self.data.append(productData) // 데이터 추가
                self.collectionView.insertItems(at: [indexPath]) // 셀 삽입
            }
        }
    }

    
    // MARK: - CollectionView 데이터 소스 및 델리게이트
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCellController // 재사용 가능한 셀 가져오기
        
        let product = data[indexPath.item] // 해당 아이템의 제품 데이터
        
        cell.productID.text = String(product.id) // ID 설정
        cell.titleLabel.text = product.title // 제목 설정
        cell.priceLabel.text = String(product.price) + "$" // 가격 설정
        cell.thumbnailImageView.image = nil // 이미지 초기화
        
        if let thumbnailURL = URL(string: product.thumbnail) {
            let task = URLSession.shared.dataTask(with: thumbnailURL) { [weak cell] (data, response, error) in
                guard let cell = cell, let data = data, error == nil else {
                    print("Failed to load image for cell at indexPath: \(indexPath)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
                        cell.thumbnailImageView.image = UIImage(data: data) // 이미지 설정
                    }
                }
            }
            task.resume()
        }
        
        return cell // 셀 반환
    }

    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = cellSpacing * CGFloat(numberOfItemsPerRow - 1) // 전체 간격
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - totalSpacing // 사용 가능한 너비
        let cellWidth = availableWidth / CGFloat(numberOfItemsPerRow) // 셀 너비
        
        let cellHeight = cellWidth * aspectRatio // 셀 높이
        return CGSize(width: cellWidth, height: cellHeight) // 셀 크기 반환
    }

    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y // 수직 스크롤 오프셋
        let contentHeight = scrollView.contentSize.height // 컨텐츠 높이
        
        if offsetY > contentHeight - scrollView.frame.height {
            currentPage += 1 // 다음 페이지로 이동
            fetchData(forPage: currentPage) // 데이터 가져오기
        }
    }
    
}


// MARK: - Segue Handling
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let destinationVC = segue.destination as? DetailViewController,
               let selectedProduct = sender as? ProductData {
                destinationVC.productData = selectedProduct // 제품 데이터 설정
            }
        }
    }
}


// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = data[indexPath.item] // 선택된 제품 데이터
        performSegue(withIdentifier: "showDetailSegue", sender: selectedProduct) // 상세 화면으로 이동
    }
}
