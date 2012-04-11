-module(remote_io).
-behaviour(gen_server).
-export([start_link/0, connect/0, close/1, format/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

start_link() ->
   gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

connect() ->
   {ok, spawn(fun() ->
      gen_server:call(?MODULE, {connect, self()}),
      listen_loop()
   end)}.

close(Pid) ->
   gen_server:call(?MODULE, {disconnect, Pid}),
   Pid ! stop_listen.

format(Format, Args) ->
   String = lists:flatten(io_lib:format(Format, Args)),
   gen_server:call(?MODULE, {send, String}).

%% callback functions

init([]) ->
   io:format("starting ~p~n", [?MODULE]),
   process_flag(trap_exit, true),
   {ok, nobody}.

handle_call({send, _String}, _From, nobody) ->
   {reply, ok, nobody};
handle_call({send, String}, _From, {listener, Pid} = State) ->
   Pid ! {output, String},
   {reply, ok, State};
handle_call({connect, Pid}, _From, _State) ->
   {reply, connected, {listener, Pid}};
handle_call({disconnect, Pid}, _From, {listener, Pid}) ->
   {reply, disconnected, nobody}.

handle_cast(_Msg, State) ->
   {noreply, State}.

handle_info(_Msg, State) ->
   {noreply, State}.

terminate(_Reason, void) ->
   io:format("~p terminated~n", [?MODULE]),
   ok.

code_change(_OldVsn, void, _Extra) ->
   {ok, void}.


%% internal functions
listen_loop() ->
   receive
      {output, String} ->
         io:format("~ts", [String]),
         listen_loop();
      stop_listen ->
         ok
   end.


