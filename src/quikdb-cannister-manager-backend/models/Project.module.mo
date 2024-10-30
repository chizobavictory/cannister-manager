import Time "mo:base/Time";

module {
  public type Project = {
    projectId : Nat;
    name : Text;
    description : Text;
    createdBy : Principal;
    createdAt : Time.Time;
  };

  public type CanisterInfo = {
    id : Text;
    owner : Text;
    memory : Nat;
    cycles : Nat;
    created_at : Nat64;
    allocated_to : ?Text;
  };
};
