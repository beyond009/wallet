import type { Principal } from '@dfinity/principal';
export type Action = { 'Create_Canister' : null } |
  { 'Stop_Canister' : null } |
  { 'Del_Canister' : null } |
  { 'Install' : null } |
  { 'Start_Canister' : null } |
  { 'Del_Owner' : null } |
  { 'Add_Owner' : null };
export interface Canister {
  'name' : string,
  'canister_id' : Principal,
  'wasm' : [] | [Array<number>],
  'description' : string,
}
export interface DeployArgs {
  'preserve_wasm' : boolean,
  'name' : string,
  'wasm' : Array<number>,
  'description' : string,
  'cycle_amount' : bigint,
  'settings' : [] | [canister_settings],
}
export type Error = { 'Transfer_Failed' : null } |
  { 'Invalid_Propose_index' : null } |
  { 'Insufficient_Cycles' : null } |
  { 'Invalid_Propose_Result' : null } |
  { 'No_Record' : null } |
  { 'Invalid_CanisterId' : null } |
  { 'Invalid_Caller' : null } |
  { 'No_Wasm' : null };
export interface Propose {
  'result' : boolean,
  'principal' : Principal,
  'action' : Action,
  'content' : string,
  'wasm' : [] | [Array<number>],
  'file_key' : string,
  'index' : bigint,
}
export interface Record {
  'method' : { 'stop' : null } |
    { 'deposit' : null } |
    { 'deploy' : null } |
    { 'start' : null },
  'times' : Time,
  'canister_id' : Principal,
  'amount' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type Result_1 = { 'ok' : string } |
  { 'err' : string };
export type Result_2 = { 'ok' : Array<number> } |
  { 'err' : Error };
export type Result_3 = { 'ok' : Status } |
  { 'err' : Error };
export type Result_4 = { 'ok' : Array<Record> } |
  { 'err' : Error };
export type Result_5 = { 'ok' : Array<Propose> } |
  { 'err' : Error };
export type Result_6 = { 'ok' : Array<Canister> } |
  { 'err' : Error };
export type Result_7 = { 'ok' : Principal } |
  { 'err' : Error };
export type Result_8 = { 'ok' : bigint } |
  { 'err' : Error };
export interface Status { 'memory' : bigint, 'cycle_balance' : bigint }
export type Time = bigint;
export interface canister_settings {
  'freezing_threshold' : [] | [bigint],
  'controllers' : [] | [Array<Principal>],
  'memory_allocation' : [] | [bigint],
  'compute_allocation' : [] | [bigint],
}
export interface hub {
  'addPropose' : (arg_0: Propose) => Promise<Result_8>,
  'changeOwner' : (arg_0: Principal) => Promise<Result>,
  'delCanister' : (arg_0: Principal, arg_1: [] | [Principal]) => Promise<
      Result
    >,
  'deployCanister' : (arg_0: DeployArgs) => Promise<Result_7>,
  'depositCycles' : (arg_0: Principal, arg_1: bigint) => Promise<Result>,
  'execPropose' : (arg_0: bigint) => Promise<Result>,
  'getCanisters' : () => Promise<Result_6>,
  'getOwner' : () => Promise<Principal>,
  'getProposes' : () => Promise<Result_5>,
  'getRecords' : (arg_0: Principal) => Promise<Result_4>,
  'getStatus' : () => Promise<Result_3>,
  'getWasm' : (arg_0: Principal) => Promise<Result_2>,
  'installCycleWasm' : (arg_0: Array<number>) => Promise<undefined>,
  'putCanister' : (arg_0: Canister) => Promise<Result>,
  'startCanister' : (arg_0: Principal) => Promise<Result_1>,
  'stopCanister' : (arg_0: Principal) => Promise<Result_1>,
  'votePropose' : (arg_0: bigint, arg_1: boolean) => Promise<Result>,
  'wallet_receive' : () => Promise<undefined>,
}
export interface _SERVICE extends hub {}
