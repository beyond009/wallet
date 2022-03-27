import type { Principal } from '@dfinity/principal';
export type Error = { 'CanisterNumberWrong' : null } |
  { 'ProposeNumberWrong' : null };
export type Result = { 'ok' : string } |
  { 'err' : Error };
export type Result_1 = { 'ok' : canister_id } |
  { 'err' : Error };
export type canister_id = Principal;
export interface main {
  'create_canister' : () => Promise<Result_1>,
  'delete_canister' : (arg_0: canister_id) => Promise<Result>,
  'install_code' : (arg_0: Array<number>, arg_1: canister_id) => Promise<
      Result
    >,
  'propose' : (arg_0: bigint, arg_1: bigint) => Promise<Result>,
  'start_canister' : (arg_0: canister_id) => Promise<Result>,
  'stop_canister' : (arg_0: canister_id) => Promise<Result>,
  'vote' : (arg_0: bigint, arg_1: boolean) => Promise<Result>,
}
export interface _SERVICE extends main {}
