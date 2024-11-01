import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Array "mo:base/Array";

// Import necessary modules for canister management
import Interface "models/ic-management-interface";
import PublicFunctions "models/ic-management-public-functions";

actor QuikDB {
    // IC Management Canister ID
    let IC = "aaaaa-aa";
    let ic = actor (IC) : Interface.Self;

    var canister_principal : Text = "";
    var controllers : [Principal] = [];

    // Public function to create a new canister with initial cycles
    public shared func createCanisterWithCycles() : async Text {
        Cycles.add(10 ** 12);
        let newCanister = await ic.create_canister({ settings = null });
        canister_principal := Principal.toText(newCanister.canister_id);
        return "Canister created successfully with ID: " # canister_principal;
    };

    // Public function to get the status of the canister
    public shared func getCanisterStatus() : async Text {
        let canister_id = Principal.fromText(canister_principal);
        let canisterStatus = await ic.canister_status({ canister_id });
        controllers := canisterStatus.settings.controllers;
        let statusText = switch (canisterStatus.status) {
            case (#running) { "Running" };
            case (#stopped) { "Stopped" };
            case (#stopping) { "Stopping" };
        };
        return "Canister status: " # statusText;
    };

    // Public function to deposit cycles into the canister
    public shared func depositCyclesToCanister() : async Text {
        Cycles.add(10 ** 12);
        let canister_id = Principal.fromText(canister_principal);
        await ic.deposit_cycles({ canister_id });
        return "Cycles successfully deposited to canister with ID: " # canister_principal;
    };

    // Public function to update canister settings
    public shared func updateCanisterSettings() : async Text {
        let settings : Interface.canister_settings = {
            controllers = ?controllers;
            compute_allocation = null;
            memory_allocation = null;
            freezing_threshold = ?(60 * 60 * 24 * 7);
        };
        let canister_id = Principal.fromText(canister_principal);
        await ic.update_settings({ canister_id; settings });
        return "Canister settings updated.";
    };

    // Public function to uninstall code from the canister
    public shared func uninstallCode() : async Text {
        let canister_id = Principal.fromText(canister_principal);
        await ic.uninstall_code({ canister_id });
        return "Code uninstalled from canister.";
    };

    // Public function to stop a running canister
    public shared func stopCanister() : async Text {
        let canister_id = Principal.fromText(canister_principal);
        await ic.stop_canister({ canister_id });
        return "Canister stopped.";
    };

    // Public function to start a stopped canister
    public shared func startCanister() : async Text {
        let canister_id = Principal.fromText(canister_principal);
        await ic.start_canister({ canister_id });
        return "Canister started.";
    };

    // Public function to delete a stopped canister
    public shared func deleteCanister() : async Text {
        let canister_id = Principal.fromText(canister_principal);
        await ic.delete_canister({ canister_id });
        return "Canister deleted.";
    };

    // Public function to run a full test of all canister management operations
    public shared func runTest() : async Text {
        try {
            await createCanisterWithCycles();
            await getCanisterStatus();
            await depositCyclesToCanister();
            await updateCanisterSettings();
            await uninstallCode();
            await stopCanister();
            await startCanister();
            await stopCanister();
            await deleteCanister();
            return "All canister operations tested successfully.";
        } catch (e) {
            return "Error during canister operations test: " # Error.message(e);
        }
    };
};
