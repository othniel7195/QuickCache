import XCTest
import QuickKV


struct User: Codable, Equatable {
  let firstName: String
  let lastName: String
  
  enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case lastName = "last_name"
  }
}

func == (lhs: User, rhs: User) -> Bool {
  return lhs.firstName == rhs.firstName
    && lhs.lastName == rhs.lastName
}

class Tests: XCTestCase {
    
    private var cache: QuickCache<User>!
    
    let user = User(firstName: "jimmy", lastName: "##")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache = try! QuickCache(config: QuickCacheConfig(name: "QuickTests"), transformer: TransformerFactory.forCodable(ofType: User.self))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cache.removeAll()
        super.tearDown()
    }
    
    func testExample() {
        let key = "user"
        
        try? cache.setObject(user, forKey: key)
        let cacheObject = try? cache.getObject(forKey: key)
        XCTAssertEqual(cacheObject, user)
        XCTAssert(cache.existsObject(forKey: key))
        XCTAssert(!cache.isExpiredObject(forKey: key))
        
        let cacheObject2 = try? cache.getObjectWithExpiry(forKey: key)
        XCTAssertEqual(cacheObject2?.0, user)
        XCTAssertEqual(cacheObject2?.1, false)

        var keys = [String]()
        cache.forEachKeys { keys += [$0] }
        XCTAssert(keys.contains(key))
        
        cache.removeObjectIfExpired(forKey: key)
        XCTAssert(cache.existsObject(forKey: key))
        
        cache.removeObject(forKey: key)
        XCTAssert(!cache.existsObject(forKey: key))

        try? cache.setObject(user, forKey: key, expiry: CacheExpiry.date(Date(timeIntervalSince1970: 1000)))
        XCTAssert(cache.isExpiredObject(forKey: key))
        
        cache.removeObjectIfExpired(forKey: key)
        XCTAssert(!cache.existsObject(forKey: key))
        
        try? cache.setObject(user, forKey: key)
        cache.removeAll()
        XCTAssert(!cache.existsObject(forKey: key))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
