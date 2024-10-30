
module {
  public type CanisterInfo = {
    id : Text;
    owner : Text;
    memory : Nat;
    cycles : Nat;
    created_at : Nat64;
    allocated_to : ?Text;
  };
};
