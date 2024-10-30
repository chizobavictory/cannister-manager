import Time "mo:base/Time";
module {
  public type CanisterInfo = {
    id : Text;
    owner : Principal;
    memory : Nat;
    cycles : Nat;
    created_at : Time.Time;
    allocated_to : ?Text;
  };
};
