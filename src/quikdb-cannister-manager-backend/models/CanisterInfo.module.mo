// models/CanisterInfo.module.mo
import Time "mo:base/Time";
import Principal "mo:base/Principal";

module {
  // Define and export CanisterInfo type
  public type CanisterInfo = {
    id : Text;
    owner : Principal;
    memory : Nat;
    cycles : Nat;
    created_at : Time.Time;
    allocated_to : ?Text;
  };
};
