import RealmSwift

extension Results {
    func toArray() -> [Any] {
        return self.map{$0}
    }
}

