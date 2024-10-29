import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

// Import other modules
import ErrorTypes "ErrorTypes.module";

public type CanisterInfo = {
  id: Text;
  owner: Text;
  memory: Nat;
  cycles: Nat;
  created_at: Nat64;
  allocated_to: ?Text;
};

// Main actor that manages canisters
actor QuikDB {
    stable var canisterRegistry: HashMap<Text, CanisterInfo] = HashMap.HashMap();

    // Create a new canister
    public shared func createCanister(initialCycles: Nat, owner: Text): async Result.Result<Text, ErrorTypes.QuikDBError> {
        let create_result = await ic.management.canister_create({cycles: initialCycles});
        let canister_id = create_result.canister_id;

        let canisterInfo: CanisterInfo = {
            id = canister_id;
            owner = owner;
            memory = 0;
            cycles = initialCycles;
            created_at = Time.now();
            allocated_to = null;
        };

        await storeCanister(owner, canister_id, canisterInfo);
        return #ok(canister_id);
    }

    // Store canister information
    public func storeCanister(ownerId: Text, canisterId: Text, info: CanisterInfo): async () {
        canisterRegistry.put(canisterId, info);
    }

    // Retrieve canister information
    public func getCanisterInfo(canisterId: Text): async ?CanisterInfo {
        return canisterRegistry.get(canisterId);
    }

    // Allocate canister to user or project
    public shared func allocateCanister(canisterId: Text, allocatedTo: Text): async Result.Result<Text, ErrorTypes.QuikDBError> {
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
    }

    // Update canister configuration (e.g., memory or cycles)
    public shared func updateCanister(canisterId: Text, newMemory: Nat, newCycles: Nat): async Result.Result<Text, ErrorTypes.QuikDBError> {
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
    }

    // Retrieve all canisters allocated to a specific user or project
    public shared query func getAllocatedCanisters(owner: Text): async [CanisterInfo] {
        return canisterRegistry.values().filter(func(info) { info.owner == owner });
    }
}
