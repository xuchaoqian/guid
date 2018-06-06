%%%-------------------------------------------------------------------
%%% @author xuchaoqian
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Jun 2018 11:22 PM
%%%-------------------------------------------------------------------
-module(guid_generator).
-author('Dietrich Featherston <d@boundary.com>').
-author('Chaoqian Xu <chaoranxu@gmail.com>').
-behaviour(gen_server).

%% API
-export([
  start_link/1,
  get/0,
  get/1
]).

%% gen_server callbacks
-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).

-define(SERVER, ?MODULE).

-record(state, {max_time, node_id, sequence}).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Config) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [Config], []).

get() ->
  gen_server:call(?SERVER, get).

get(Base) ->
  case gen_server:call(?SERVER, get) of
    {ok, Id} ->
      {ok, guid_utils:integer_to_list(guid_utils:binary_to_integer(Id), Base)};
    Error ->
      Error
  end.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([{node_id, NodeId}]) ->
  {ok, #state{max_time = guid_utils:get_current_millis(), node_id = NodeId, sequence = 0}}.

handle_call(get, _From, State = #state{max_time = MaxTime, node_id = NodeId, sequence = Sequence}) ->
  {Resp, S0} = get(guid_utils:get_current_millis(), MaxTime, NodeId, Sequence, State),
  {reply, Resp, S0};
handle_call(Request, _From, State) ->
  {reply, {error, {unknown_call, Request}}, State}.

handle_cast(_, State) -> {noreply, State}.

handle_info(_, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_, State, _) -> {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% clock hasn't moved, increment sequence
get(Time, Time, NodeId, Sequence, State) ->
  NewSequence = Sequence + 1,
  {{ok, guid_utils:encode(Time, NodeId, NewSequence)}, State#state{sequence = NewSequence}};
%% clock has progressed, reset sequence
get(CurrTime, MaxTime, NodeId, _, State) when CurrTime > MaxTime ->
  {{ok, guid_utils:encode(CurrTime, NodeId, 0)}, State#state{max_time = CurrTime, sequence = 0}};
%% clock is running backwards
get(CurrTime, MaxTime, _NodeId, _Sequence, State) when CurrTime < MaxTime ->
  {{error, clock_running_backwards}, State}.
