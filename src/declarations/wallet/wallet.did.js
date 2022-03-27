export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const Error = IDL.Variant({
    'CanisterNumberWrong' : IDL.Null,
    'ProposeNumberWrong' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : canister_id, 'err' : Error });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const main = IDL.Service({
    'create_canister' : IDL.Func([], [Result_1], []),
    'delete_canister' : IDL.Func([canister_id], [Result], []),
    'install_code' : IDL.Func([IDL.Vec(IDL.Nat8), canister_id], [Result], []),
    'propose' : IDL.Func([IDL.Nat, IDL.Nat], [Result], []),
    'start_canister' : IDL.Func([canister_id], [Result], []),
    'stop_canister' : IDL.Func([canister_id], [Result], []),
    'vote' : IDL.Func([IDL.Nat, IDL.Bool], [Result], []),
  });
  return main;
};
export const init = ({ IDL }) => { return [IDL.Nat, IDL.Vec(IDL.Principal)]; };
