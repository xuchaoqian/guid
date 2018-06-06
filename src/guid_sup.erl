%%%-------------------------------------------------------------------
%%% @author xuchaoqian
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Jun 2018 11:14 PM
%%%-------------------------------------------------------------------
-module(guid_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SUP_NAME, ?MODULE).
-define(SPEC(Module, Type, Args), #{
  id => Module,
  start => {Module, start_link, Args},
  restart => permanent,
  shutdown => infinity,
  type => Type,
  modules => [Module]}
).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
  supervisor:start_link({local, ?SUP_NAME}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([]) ->
  NodeId =
    case init:get_argument(node_id) of
      error ->
        exit(no_node_id);
      {ok, [[Value]]} ->
        erlang:list_to_integer(Value)
    end,
  error_logger:info_msg("Using node id: ~p~n", [NodeId]),

  SupFlags = #{strategy => one_for_one, intensity => 10, period => 60},
  ChildSpecs = [?SPEC(guid_generator, worker, [{node_id, NodeId}])],
  {ok, {SupFlags, ChildSpecs}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
