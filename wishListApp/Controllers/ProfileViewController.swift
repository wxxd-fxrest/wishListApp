//
//  ProfileViewController.swift
//  wishListApp
//
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var fetchedResultsController: NSFetchedResultsController<Product>!
    @IBOutlet weak var wishListView: UITableView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        wishListView.dataSource = self
        wishListView.delegate = self
        
        wishListView.rowHeight = UITableView.automaticDimension
        wishListView.estimatedRowHeight = 20
    }
    
    
    // MARK: - Init Controller
    private func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("페치 결과 컨트롤러 초기화 중 오류 발생: \(error)")
        }
    }
    
    
    // MARK: - TableView 데이터 소스
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    
    // MARK: - TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "ShowDetail", sender: selectedProduct)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            // 선택한 상품 데이터 DetailViewController에 전달
            if let detailVC = segue.destination as? DetailViewController,
               let indexPath = wishListView.indexPathForSelectedRow {
                let selectedProduct = fetchedResultsController.object(at: indexPath)
                let productData = detailVC.convertToProductData(selectedProduct)
                detailVC.productData = productData
            }
        }
    }

    
    // MARK: - Controller 델리게이트
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wishListView.reloadData()
    }
    
    
    // MARK: - TableView 델리게이트
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    // MARK: - Cell 구성
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let product = fetchedResultsController.object(at: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let thumbnailImageView = UIImageView()
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.image = UIImage(named: "placeholder_image") // 플레이스홀더 이미지
        cell.contentView.addSubview(thumbnailImageView)
        
        if let thumbnailURLString = product.thumbnail,
           let thumbnailURL = URL(string: thumbnailURLString) {
            URLSession.shared.dataTask(with: thumbnailURL) { (data, _, error) in
                if let error = error {
                    print("썸네일 이미지 가져오기 오류: \(error)")
                    return
                }
                guard let data = data else {
                    print("썸네일 이미지를 위한 데이터가 없습니다.")
                    return
                }
                DispatchQueue.main.async {
                    thumbnailImageView.image = UIImage(data: data)
                }
            }.resume()
        }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = product.title
        titleLabel.numberOfLines = 1 // 여러 줄 허용
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cell.contentView.addSubview(titleLabel)

        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "$\(product.price)"
        priceLabel.numberOfLines = 1
        priceLabel.textAlignment = .left
        priceLabel.font = UIFont.systemFont(ofSize: 16)
        cell.contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            thumbnailImageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 50),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
    }

    
    // MARK: - Item 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "상품 삭제", message: "이 상품을 삭제하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.deleteProduct(at: indexPath)
            }
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }

    private func deleteProduct(at indexPath: IndexPath) {
        let productToDelete = fetchedResultsController.object(at: indexPath)
        let productId = productToDelete.id // 예시: 제품의 ID 속성을 추출하여 저장

        // deleteProductData(withID:) 함수를 호출하여 제품 삭제
        CoreDataManager.shared.deleteProductData(withID: Int(productId))
    }

}
