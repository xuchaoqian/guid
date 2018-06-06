%%%-------------------------------------------------------------------
%%% @author xuchaoqian
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jun 2018 11:43 AM
%%%-------------------------------------------------------------------
-module(guid_test).
-author('Dietrich Featherston <d@boundary.com>').
-author('Chaoqian Xu <chaoranxu@gmail.com>').
-include_lib("eunit/include/eunit.hrl").

-export ([
  generate/1,
  generate/2,
  timed_generate/1,
  timed_generate/2
]).

setup() ->
  case application:start(guid) of
    ok -> ok;
    {error, {already_started, _}} -> ok;
    Error ->
      Error
  end.

teardown(_SetupResult) ->
  ok = application:stop(guid).

get_test_() ->
  {setup, fun setup/0, fun teardown/1, fun get/1}.

get_by_base_test_() ->
  {setup, fun setup/0, fun teardown/1, fun get_by_base/1}.

get(_SetupResult) ->
  timed_generate(100000),
  [].

get_by_base(_SetupResult) ->
  timed_generate(100000, 62),
  [].

generate(N) ->
  generate_ids(N, undefined, []).

timed_generate(N) ->
  ?debugTime("generating ids", generate(N)).

generate(N, Base) ->
  generate_ids(N, Base, []).

timed_generate(N, Base) ->
  ?debugTime("generating ids", generate(N, Base)).

generate_ids(0, _Base, Acc) ->
  Acc;
generate_ids(N, Base, Acc) ->
  {ok, Id} = case Base of
               undefined ->
                 guid_generator:get();
               _ ->
                 guid_generator:get(Base)
             end,
  generate_ids(N - 1, Base, [Id | Acc]).
