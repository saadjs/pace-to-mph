import Testing
@testable import pace_to_mph

struct FavoritesStoreTests {
    
    @Test func addFavorite() {
        let store = FavoritesStore()
        store.clear()
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        #expect(store.favorites.count == 1)
        #expect(store.favorites.first?.input == "8:00")
        store.clear()
    }
    
    @Test func addDuplicateSkipped() {
        let store = FavoritesStore()
        store.clear()
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        #expect(store.favorites.count == 1)
        store.clear()
    }
    
    @Test func removeFavorite() {
        let store = FavoritesStore()
        store.clear()
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        let id = store.favorites.first!.id
        store.remove(id: id)
        #expect(store.favorites.isEmpty)
        store.clear()
    }
    
    @Test func isFavorited() {
        let store = FavoritesStore()
        store.clear()
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        #expect(store.isFavorited(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH"))
        #expect(!store.isFavorited(input: "7:00", inputSuffix: "/mi", result: "8.57", resultSuffix: "MPH"))
        store.clear()
    }
    
    @Test func toggleFavorite() {
        let store = FavoritesStore()
        store.clear()
        store.toggle(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        #expect(store.favorites.count == 1)
        store.toggle(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        #expect(store.favorites.isEmpty)
        store.clear()
    }
    
    @Test func maxFavoritesEnforced() {
        let store = FavoritesStore()
        store.clear()
        for i in 0..<25 {
            store.add(input: "\(i):00", inputSuffix: "/mi", result: "\(60.0/Double(max(i,1)))", resultSuffix: "MPH")
        }
        #expect(store.favorites.count == 20)
        store.clear()
    }
    
    @Test func clearFavorites() {
        let store = FavoritesStore()
        store.add(input: "8:00", inputSuffix: "/mi", result: "7.50", resultSuffix: "MPH")
        store.clear()
        #expect(store.favorites.isEmpty)
    }
}
