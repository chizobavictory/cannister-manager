module {
  public type QuikDBError = {
    #CanisterInfoNotFound : Text;
    #GeneralError : Text;
    #ItemNotFound : Text;
    #ProjectNotFound : Text;
    #ValidationError : Text;
  };

  public func errorMessage(err: QuikDBError) : Text {
    switch err {
      case (#CanisterInfoNotFound(msg)) msg;
      case (#GeneralError(msg)) msg;
      case (#ItemNotFound(msg)) msg;
      case (#ProjectNotFound(msg)) msg;
      case (#ValidationError(msg)) msg;
    }
  }
}
