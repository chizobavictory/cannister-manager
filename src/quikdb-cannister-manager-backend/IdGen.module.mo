import Nat "mo:base/Nat";

module {
    public func generateUniqueId(tracker: Nat, prefix: Nat): async Text {
        let uniqueId = Nat.toText(tracker + prefix);
        return uniqueId;
    }
}
