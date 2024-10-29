import Time "mo:base/Time";

module {
    public type Database = {
        databaseId: Nat;
        name: Text;
        projectId: Nat;
        createdBy: Principal;
        createdAt: Time.Time;
    };
}
