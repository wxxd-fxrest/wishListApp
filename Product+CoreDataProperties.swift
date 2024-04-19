//
//  Product+CoreDataProperties.swift
//  wishListApp
//
//
//

import Foundation
import CoreData

extension Product {
    // MARK: - Fetch Request
    // Product 엔터티에 대한 fetch 요청 생성
    //
    // - Returns: Product 엔터티에 대한 fetch 요청
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    
    // MARK: - Managed Properties
    @NSManaged public var category: String?
    @NSManaged public var discountPercentage: Int64
    @NSManaged public var id: Int64
    @NSManaged public var images: [String]?
    @NSManaged public var price: Int64
    @NSManaged public var productDescription: String?
    @NSManaged public var rating: Int64
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
}

extension Product : Identifiable {}
