import RealmSwift

extension Results {
    func toArray() -> [Any] {
        return self.map{$0}
    }
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 2.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}
