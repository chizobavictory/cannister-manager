import Time "mo:base/Time";

module {
    public type Database = {
        databaseId: Nat;
        projectId: Nat;
        name: Text;
        createdBy: Principal;
        createdAt: Time.Time;
    };
}
