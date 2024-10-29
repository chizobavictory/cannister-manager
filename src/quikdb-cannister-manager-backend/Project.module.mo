import Time "mo:base/Time";

module {
    public type Project = {
        projectId: Nat;
        name: Text;
        description: Text;
        createdBy: Principal;
        createdAt: Time.Time;
    };
}
