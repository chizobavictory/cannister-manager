import Debug "mo:base/Debug";

module {
  public func logInfo(message : Text) : async () {
    Debug.print("[INFO] " # message);
  };

  public func logError(message : Text) : async () {
    Debug.print("[ERROR] " # message);
  };
};
