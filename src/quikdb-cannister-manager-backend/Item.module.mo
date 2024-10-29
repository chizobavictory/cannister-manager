import Time "mo:base/Time";

module {
  public type Item = {
    itemId : Nat;
    data : Blob;
    createdAt : Time.Time;
  };
};
