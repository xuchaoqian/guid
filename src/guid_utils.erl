%%%-------------------------------------------------------------------
%%% @author xuchaoqian
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Jun 2018 11:20 PM
%%%-------------------------------------------------------------------
-module(guid_utils).
-author('Dietrich Featherston <d@boundary.com>').
-author('Chaoqian Xu <chaoranxu@gmail.com>').

-export([
  encode/3,
  decode/1,
  binary_to_integer/1,
  integer_to_binary/1,
  integer_to_list/2,
  get_current_millis/0
]).

encode(Time, NodeId, Sequence) ->
  <<Time:64/integer, NodeId:16/integer, Sequence:16/integer>>.

decode(BinId) ->
  <<Time:64/integer, NodeId:16/integer, Sequence:16/integer>> = BinId,
  {Time, NodeId, Sequence}.

binary_to_integer(BinId) ->
  <<IntId:96/integer>> = BinId,
  IntId.

integer_to_binary(IntId) ->
  <<IntId:96/integer>>.

%% @spec integer_to_list(Integer :: integer(), Base :: integer()) ->
%%          string()
%% @doc Convert an integer to its string representation in the given
%%      base.  Bases 2-62 are supported.
integer_to_list(I, 10) ->
  erlang:integer_to_list(I);
integer_to_list(I, Base)
  when is_integer(I),
  is_integer(Base),
  Base >= 2,
  Base =< 1 + $Z - $A + 10 + 1 + $z - $a ->
  if
    I < 0 ->
      [$- | integer_to_list(-I, Base, [])];
    true ->
      integer_to_list(I, Base, [])
  end;
integer_to_list(I, Base) ->
  erlang:error(badarg, [I, Base]).

%% @spec integer_to_list(integer(), integer(), stringing()) -> string()
integer_to_list(I0, Base, R0) ->
  D = I0 rem Base,
  I1 = I0 div Base,
  R1 =
    if
      D >= 36 ->
        [D - 36 + $a | R0];
      D >= 10 ->
        [D - 10 + $A | R0];
      true ->
        [D + $0 | R0]
    end,
  if
    I1 =:= 0 ->
      R1;
    true ->
      integer_to_list(I1, Base, R1)
  end.

get_current_millis() ->
  {MegaSec, Sec, MicroSec} = os:timestamp(),
  1000000000 * MegaSec + Sec * 1000 + erlang:trunc(MicroSec / 1000).