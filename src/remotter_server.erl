-module(remotter_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

start_link() ->
   gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
   process_flag(trap_exit, true),
   {ok, void}.

handle_call({part, Part}, _From, void) ->
   io:format("receive : ~p~n", [Part]),
   {reply, Part, void}.

handle_cast(_Msg, void) ->
   {noreply, void}.

handle_info(_Info, void) ->
   {noreply, void}.

terminate(_Reason, void) ->
   io:format("~p stopping~n", [?MODULE]),
   ok.

code_change(_OldVsn, void, _Extra) ->
   {ok, void}.

