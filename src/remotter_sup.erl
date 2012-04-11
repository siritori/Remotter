-module(remotter_sup).
-behaviour(supervisor).
-export([start_test/0]).
-export([start/0, start_link/1, init/1]).
-define(ACCESS_TOKEN, "50046492-pL51SlPUuFwqe3Ycbv5UfSpS8H5D9qamNLEZJZQ0").
-define(TOKEN_SECRET, "ujrQBlmiWN75iL0ixm9kI2kqa19vxF3JpaC2lM").

start() ->
   spawn(fun() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []) end).


start_test() ->
   {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
   unlink(Pid).

start_link(Args) ->
   supervisor:start_link({local, ?MODULE}, ?MODULE, Args).

init([]) ->
   RestartStrategy  = {one_for_one, 3, 10},
   RemotterServer   = {remotter_server, {remotter_server, start_link, []},
      permanent, 10000, worker, [remotter_server]},
   UserstreamServer = {userstream_server, {userstream_server, start_link,
         [{remotter_server, handle_part}, ?ACCESS_TOKEN, ?TOKEN_SECRET]},
      permanent, 10000, worker, [userstream_server]},
   RemoteIOServer = {remote_io, {remote_io, start_link, []},
      permanent, 10000, worker, [remote_io]},
   Children = [RemotterServer, UserstreamServer, RemoteIOServer],
   {ok, {RestartStrategy, Children}}.

