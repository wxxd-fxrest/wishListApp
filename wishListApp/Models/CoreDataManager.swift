//
//  CoreDataManager.swift
//  giftWish
//
//

import Foundation
import CoreData

class CoreDataManager {
    // MARK: - Singleton Instance
    // CoreDataManager의 싱글톤 인스턴스 반환
    static let shared = CoreDataManager()

    private init() {}

    
    // MARK: - Managed Object Context
    // Core Data의 관리 객체 컨텍스트 초기화
    lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    
    // MARK: - Persistent Container
    // Core Data의 영구 저장 컨테이너 초기화
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "wishListApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    
    // MARK: - Save Context
    // 관리 객체 컨텍스트의 변경 사항 저장
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("🌟 Save Data")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    // MARK: - Save Product Data
    // ProductData를 사용하여 Product를 생성, 저장
    //
    // - Parameter productData: 저장할 ProductData
    func saveProductData(_ productData: ProductData) {
        // 제품을 생성하고 반환하는 createProduct(from:) 메서드를 호출하고 반환값을 사용하지 않습니다.
        _ = createProduct(from: productData)
        // saveContext() 메서드를 호출하여 제품 데이터를 저장합니다.
        saveContext()
    }
    

    // MARK: - Create Product
    // ProductData를 사용하여 Product를 생성
    //
    // - Parameter productData: 생성할 ProductData
    // - Returns: 생성된 Product
    private func createProduct(from productData: ProductData) -> Product {
        let product = Product(context: CoreDataManager.shared.managedObjectContext)
        product.id = Int64(productData.id)
        product.title = productData.title
        product.productDescription = productData.productDescription
        product.price = Int64(productData.price)
        product.discountPercentage = Int64(productData.discountPercentage)
        product.rating = Int64(productData.rating)
        product.category = productData.category
        product.thumbnail = productData.thumbnail
        product.images = productData.images
        return product
    }
    
    
    // MARK: - Fetch Products
    // 모든 Product를 가져오기
    //
    // - Returns: 모든 Product 배열
    func fetchProducts() -> [Product] {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()

        do {
            let products = try managedObjectContext.fetch(fetchRequest)
            print("💡 Products in Core Data:")
            for product in products {
                print("ID: \(product.id), Title: \(product.title ?? ""), Price: \(product.price), Discount Percentage: \(product.discountPercentage), Rating: \(product.rating), Category: \(product.category ?? ""), Thumbnail: \(product.thumbnail ?? ""), Images: \(product.images ?? [])")
            }
            return products
        } catch {
            print("Error fetching products: \(error)")
            return []
        }
    }
    
    
    // MARK: - Check if Product is Saved
    // 주어진 ID를 가진 Product가 저장 여부 확인
    //
    // - Parameter id: 확인할 Product의 ID
    // - Returns: Product가 저장되어 있으면 true, 그렇지 않으면 false
    func isProductSaved(withID id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)

        do {
            let products = try managedObjectContext.fetch(fetchRequest)
            return !products.isEmpty
        } catch {
            print("Error checking product existence: \(error)")
            return false
        }
    }

    
    // MARK: - Delete Product Data by ID
    // 주어진 ID를 가진 Product 삭제
    //
    // - Parameter id: 삭제할 Product의 ID
    func deleteProductData(withID id: Int) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)

        do {
            let products = try managedObjectContext.fetch(fetchRequest)
            for product in products {
                managedObjectContext.delete(product)
            }
            saveContext()
            print("Product deleted successfully")
        } catch {
            print("Error deleting product: \(error)")
        }
    }
}
