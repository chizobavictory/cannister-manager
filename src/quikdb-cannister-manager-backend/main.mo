import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

import Project "models/Project.module";
import Database "models/Database.module";
import GroupItemStore "models/Item.module";
import idGen "models/IdGen.module";
import ErrorTypes "models/ErrorTypes.module";
import CanisterInfo "models/CanisterInfo.module";

// Import the IC management interface
import Interface "ic-management-interface";

actor QuikDB {
  // The IC Management Canister ID
  let IC = "aaaaa-aa";
  let ic = actor (IC) : Interface.Self;

  // Stable variable to store canister information
  stable var canisterRegistry: HashMap.HashMap<Text, CanisterInfo> = HashMap.HashMap<Text, CanisterInfo>();

  // Stores the current canister principal for operations
  var canister_principal: Text = "";

  // Create a new canister and allocate cycles
  public shared func createCanister(name: Text, initialCycles: Nat, memory: Nat, owner: Principal): async Result.Result<Text, ErrorTypes.QuikDBError> {
    Cycles.add(initialCycles);

    // Call IC to create a new canister
    let newCanister = await ic.create_canister({ settings = null });

    canister_principal := Principal.toText(newCanister.canister_id);

    let canisterInfo: CanisterInfo = {
      id = canister_principal;
      owner = owner;
      memory = memory;
      cycles = initialCycles;
      created_at = Time.now();
      allocated_to = null;
    };

    // Store the canister information in the registry
    await storeCanister(owner, canister_principal, canisterInfo);

    return #ok(canister_principal);
  };

  // Store canister information in the registry
  public func storeCanister(owner: Principal, canisterId: Text, info: CanisterInfo): async () {
    canisterRegistry.put(canisterId, info);
  };

  // Retrieve canister information by ID
  public func getCanisterInfo(canisterId: Text): async ?CanisterInfo {
    return canisterRegistry.get(canisterId);
  };

  // Retrieve canister status
  public shared func canisterStatus(): async* () {
    let canister_id = Principal.fromText(canister_principal);
    let canisterStatus = await ic.canister_status({ canister_id });
    return canisterStatus;
  };

  // Deposit cycles into a canister
  public shared func depositCycles(amount: Nat): async* () {
    Cycles.add(amount);
    let canister_id = Principal.fromText(canister_principal);
    await ic.deposit_cycles({ canister_id });
  };

  // Update the settings of a canister
  public shared func updateSettings(controllers: [Principal], freezingThreshold: Nat): async* () {
    let settings: Interface.canister_settings = {
      controllers = ?controllers;
      compute_allocation = null;
      memory_allocation = null;
      freezing_threshold = ?freezingThreshold;
    };

    let canister_id = Principal.fromText(canister_principal);
    await ic.update_settings({ canister_id; settings });
  };

  // Uninstall code from a canister
  public shared func uninstallCode(): async* () {
    let canister_id = Principal.fromText(canister_principal);
    await ic.uninstall_code({ canister_id });
  };

  // Stop a running canister
  public shared func stopCanister(): async* () {
    let canister_id = Principal.fromText(canister_principal);
    await ic.stop_canister({ canister_id });
  };

  // Start a stopped canister
  public shared func startCanister(): async* () {
    let canister_id = Principal.fromText(canister_principal);
    await ic.start_canister({ canister_id });
  };

  // Delete a stopped canister
  public shared func deleteCanister(): async* () {
    let canister_id = Principal.fromText(canister_principal);
    await ic.delete_canister({ canister_id });
  };

  // Test function to run through all canister operations
  public shared func icManagementCanisterTest(): async { #OK; #ERR : Text } {
    try {
      await* createCanister("Test Canister", 10 ** 12, 1000, Principal.fromText("aaaaa-aa"));
      await* canisterStatus();
      await* depositCycles(10 ** 12);
      await* updateSettings([Principal.fromText("aaaaa-aa")], 60 * 60 * 24 * 7);
      await* uninstallCode();
      await* stopCanister();
      await* startCanister();
      await* stopCanister();
      await* deleteCanister();
      return #OK;
    } catch (e) {
      return #ERR(Error.message(e));
    }
  };
};
