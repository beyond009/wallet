import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import TrieSet "mo:base/TrieSet";
shared(install) actor class main(m : Nat, owners : [Principal]) = self {
     public type canister_id = Principal;
  public type canister_settings = {
    freezing_threshold : ?Nat;
    controllers : ?[Principal];
    memory_allocation : ?Nat;
    compute_allocation : ?Nat;
  };
  public type definite_canister_settings = {
    freezing_threshold : Nat;
    controllers : [Principal];
    memory_allocation : Nat;
    compute_allocation : Nat;
  };
  public type http_header = { value : Text; name : Text };
  public type http_request_error = {
    #dns_error;
    #no_consensus;
    #transform_error;
    #unreachable;
    #bad_tls;
    #conn_timeout;
    #invalid_url;
    #timeout;
  };
  public type http_response = {
    status : Nat;
    body : [Nat8];
    headers : [http_header];
  };
  public type user_id = Principal;
  public type wasm_module = [Nat8];
  public type Self = actor {
    canister_status : shared { canister_id : canister_id } -> async {
        status : { #stopped; #stopping; #running };
        memory_size : Nat;
        cycles : Nat;
        settings : definite_canister_settings;
        module_hash : ?[Nat8];
      };
    create_canister : shared { settings : ?canister_settings } -> async {
        canister_id : canister_id;
      };
    delete_canister : shared { canister_id : canister_id } -> async ();
    deposit_cycles : shared { canister_id : canister_id } -> async ();
    http_request : shared {
        url : Text;
        method : { #get };
        body : ?[Nat8];
        transform : ?{
          #function : shared query http_response -> async http_response;
        };
        headers : [http_header];
      } -> async { #Ok : http_response; #Err : ?http_request_error };
    install_code : shared {
        arg : [Nat8];
        wasm_module : wasm_module;
        mode : { #reinstall; #upgrade; #install };
        canister_id : canister_id;
      } -> async ();
    provisional_create_canister_with_cycles : shared {
        settings : ?canister_settings;
        amount : ?Nat;
      } -> async { canister_id : canister_id };
    provisional_top_up_canister : shared {
        canister_id : canister_id;
        amount : Nat;
      } -> async ();
    raw_rand : shared () -> async [Nat8];
    start_canister : shared { canister_id : canister_id } -> async ();
    stop_canister : shared { canister_id : canister_id } -> async ();
    uninstall_code : shared { canister_id : canister_id } -> async ();
    update_settings : shared {
        canister_id : Principal;
        settings : canister_settings;
      } -> async ();
  };
  private stable var canister_entries : [var (Nat, canister_id)]     = [var];
  private stable var propose_entries  : [var (Nat, (Nat, Nat, Nat))] = [var];
  private stable var vote_buffer_entries : [var (Nat, TrieSet.Set<Principal>)] = [var];
  private stable var M  = m;
  private let N = owners.size();
  private let ic : Self = actor "aaaaa-aa";
  private stable var canister_number: Nat = 0;
  private var canisters = TrieMap.fromEntries<Nat, canister_id>(canister_entries.vals(), Nat.equal, Hash.hash);
  private var proposes = TrieMap.fromEntries<Nat, (Nat, Nat, Nat)>(propose_entries.vals(), Nat.equal, Hash.hash);
  private var votes_buffer = TrieMap.fromEntries<Nat, TrieSet.Set<Principal>>(vote_buffer_entries.vals(), Nat.equal, Hash.hash);
  private type Error = {
    #CanisterNumberWrong;
    #ProposeNumberWrong;
  };
    // public query func getPropose(): async {
    //   proposes;
    // };
    public shared({caller}) func propose(num: Nat,action: Nat) : async Result.Result<Text, Error> {

      switch (canisters.get(num)) {
            case null { #err(#CanisterNumberWrong) };
            case (?canister_id) {
                switch(proposes.get(num)) {
                    case (?agreenum) {
                        #err(#ProposeNumberWrong)
                    };
                    case (null) {
                        proposes.put(num, (0, 0, action));
                        #ok("Created")
                    };
                }
            };
        }
      
    };
    public shared({caller}) func vote(num : Nat, agree : Bool) : async Result.Result<Text, Error> {
        switch(proposes.get(num)) {
            case (?propose) {
                switch(votes_buffer.get(num)) {
                    case null {
                        let set_tmp = TrieSet.empty<Principal>();
                        let set_in = TrieSet.put(set_tmp, caller, Principal.hash(caller), Principal.equal);
                        votes_buffer.put(num, set_in);
                    };
                    case (?set) {
                            let set_in = TrieSet.put(set, caller, Principal.hash(caller), Principal.equal);
                            votes_buffer.put(num, set_in);
                    };
                };
                if (agree) {
                    if ((propose.0 + 1) == M) {
                        proposes.delete(num);
                        return #ok("propose passed");
                    };
                    proposes.put(num, (propose.0 + 1, propose.1, propose.2));
                    return #ok("success");
                } else {
                    let left : Nat = N - M;
                    if ((propose.1 + 1) > left) {
                        proposes.delete(num);
                        return #ok("propose failed");
                    } else {
                        proposes.put(num, (propose.0, propose.1 + 1, propose.2));
                        return #ok("success");
                    };
                };
            };
            case (null) {
                #err(#ProposeNumberWrong)
            };
        }
    };

    public shared(caller) func create_canister() :  async Result.Result<canister_id, Error> {
        let settings = {
            freezing_threshold = ?2592000;
            controllers = ?[Principal.fromActor(self)];
            memory_allocation = ?0;
            compute_allocation = ?0;
        };
        let res = await ic.create_canister({ settings = ?settings;});
        canister_number += 1;
        canisters.put(canister_number, res.canister_id);
        #ok(res.canister_id)
    };

    public shared(caller) func install_code(wsm : [Nat8], canister_id : canister_id) : async Result.Result<Text, Error> {
        await ic.install_code({ 
            arg = [];
            wasm_module = wsm;
            mode = #install;
            canister_id = canister_id;
        });
        #ok("install ok")
    };

    public shared(caller) func start_canister(canister_id : canister_id) : async Result.Result<Text, Error> {
        await ic.start_canister({ canister_id = canister_id;});
        #ok("ok")
    };

    public shared(caller) func stop_canister(canister_id : canister_id) : async Result.Result<Text, Error> {
        await ic.stop_canister({ canister_id = canister_id;});
        #ok("ok")
    };

    public shared(caller) func delete_canister(canister_id : canister_id) : async Result.Result<Text, Error> {
        await ic.delete_canister({ canister_id = canister_id;});
        #ok("ok")
    };

};
