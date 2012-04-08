-module(remotter_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, Args) ->
   remotter_sup:start_link(Args).

stop(_State) ->
   ok.

