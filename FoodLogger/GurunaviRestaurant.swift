import Foundation

public struct Restaurant: Codable {
    
    public var id: String
    public var name: String
    public var nameKana: String
    public var address: String
    public var url: String
    public var tel: String
    public var latitude: String
    public var longitude: String
    public var urlMobile: String
    public var shopImage1: String?
    public var shopImage2: String?
}

public struct Restaurants: Codable {
    
    public var rest: [Restaurant]
    public var totalHitCount: String
    public var hitPerPage: String
    public var pageOffset: String
}
