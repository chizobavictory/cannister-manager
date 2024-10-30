import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

import Project "models/Project.module";
import Database "models/Database.module";
import GroupItemStore "models/Item.module";
import idGen "models/IdGen.module";
import ErrorTypes "models/ErrorTypes.module";
import CanisterInfo "models/CanisterInfo.module"

// Main actor managing canisters
actor QuikDB {
  // Stable variable to store canister information
  stable var canisterRegistry : HashMap.HashMap<Text, CanisterInfo> = HashMap.HashMap<Text, CanisterInfo>();

  // Create a new canister, validate the request, and store canister info
  public shared func createCanister(name : Text, initialCycles : Nat, memory : Nat, owner : Principal) : async Result.Result<Text, ErrorTypes.QuikDBError> {
    // Step 1: Validate the request (authentication and quota check)
    if (/* quota exceeded */ false) {
      return #err(ErrorTypes.QuikDBError("Quota exceeded"));
    };

    // Step 2: Interact with ICP to create the canister
    let create_result = await ic.management.canister_create({
      cycles = initialCycles;
    });

    let canister_id = create_result.canister_id;

    // Step 3: Store canister details
    let canisterInfo : CanisterInfo = {
      id = canister_id;
      owner = owner;
      memory = memory;
      cycles = initialCycles;
      created_at = Time.now();
      allocated_to = null;
    };

    await storeCanister(owner, canister_id, canisterInfo);

    // Step 4: Return the canister ID and its configuration
    return #ok(canister_id);
  };

  // Store canister information in the registry
  public func storeCanister(owner : Principal, canisterId : Text, info : CanisterInfo) : async () {
    canisterRegistry.put(canisterId, info);
  };

  // Retrieve canister information by ID
  public func getCanisterInfo(canisterId : Text) : async ?CanisterInfo {
    return canisterRegistry.get(canisterId);
  };

  // Allocate a canister to a user or project
  public shared func allocateCanister(canisterId : Text, allocatedTo : Text) : async Result.Result<Text, ErrorTypes.QuikDBError> {
    let canisterInfo = await getCanisterInfo(canisterId);

    switch canisterInfo {
      case (?info) {
        let updatedInfo = { info with allocated_to = ?allocatedTo };
        canisterRegistry.put(canisterId, updatedInfo);
        return #ok("Canister allocated successfully");
      };
      case null {
        return #err(ErrorTypes.QuikDBError("Canister not found"));
      };
    };
  };

  // Retrieve all canisters allocated to a specific owner
  public shared query func getAllocatedCanisters(owner : Principal) : async [CanisterInfo] {
    return canisterRegistry.values().filter(func(info) { info.owner == owner });
  };

  // Update a canister's memory or cycles
  public shared func updateCanister(canisterId : Text, newMemory : Nat, newCycles : Nat) : async Result.Result<Text, ErrorTypes.QuikDBError> {
    let canisterInfo = await getCanisterInfo(canisterId);
    switch canisterInfo {
      case (?info) {
        let updatedInfo = { info with memory = newMemory; cycles = newCycles };
        canisterRegistry.put(canisterId, updatedInfo);
        return #ok("Canister updated successfully");
      };
      case null {
        return #err(ErrorTypes.QuikDBError("Canister not found"));
      };
    };
  };

  // Query to retrieve allocated canisters
  public shared query func getCanisterInfoByOwner(owner : Principal) : async [CanisterInfo] {
    return canisterRegistry.values().filter(func(info) { info.owner == owner });
  };
};
