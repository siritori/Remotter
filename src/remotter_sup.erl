-module(remotter_sup).
-behaviour(supervisor).
-export([start_test/0]).
-export([start/0, start_link/1, init/1]).

start() ->
   spawn(fun() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []) end).


start_test() ->
   {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
   unlink(Pid).

start_link(Args) ->
   supervisor:start_link({local, ?MODULE}, ?MODULE, Args).

init([]) ->
   RestartStrategy = {one_for_one, 3, 10},
   RemotterServer  = {remotter_server, 
      {remotter_server, start_link, []},
      permanent, brutal_kill, worker, [remotter_server]},
   {ok, {RestartStrategy, [RemotterServer]}}.

