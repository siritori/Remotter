-module(remotter_server).
-export([start_link/0, handle_part/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

start_link() ->
   gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

handle_part(Part) ->
   gen_server:cast(?MODULE, {part, Part}).

%% callback functions

init([]) ->
   process_flag(trap_exit, true),
   {ok, void}.

handle_call(Msg, _From, void) ->
   {reply, Msg, void}.

handle_cast({part, Part}, void) ->
   io:format("receive: ~p~n", [Part]),
   {noreply, void}.

handle_info(_Info, void) ->
   {noreply, void}.

terminate(_Reason, void) ->
   io:format("~p terminated~n", [?MODULE]),
   ok.

code_change(_OldVsn, void, _Extra) ->
   {ok, void}.

