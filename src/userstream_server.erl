-module(userstream_server).
-behaviour(gen_server).
-author("Takahiro Kondo <heartery@gmail.com>").
-export([start_link/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
       terminate/2, code_change/3]).

-record(state, {callback, id}).
-define(CONSUMER_KEY, "tdPkd4z4lvANKT22xqIzng").
-define(CONSUMER_SECRET, "oZjO8LxzGSq4jvWcgRNOFzlJsiMLCiZOVMWJdIKPCsk").


start_link(Callback, AccessToken, AccessTokenSecret) ->
   gen_server:start_link(?MODULE, [Callback, AccessToken, AccessTokenSecret], []).

%% callback functions

init([Callback, AccessToken, AccessTokenSecret]) ->
   process_flag(trap_exit, true),
   application:start(inets),
   ssl:start(),
   Url = "https://userstream.twitter.com/2/user.json",
   Consumer = {?CONSUMER_KEY, ?CONSUMER_SECRET, hmac_sha1},
   Options = [{sync, false}, {stream, self}],
   case oauth:post(Url, [], Consumer, AccessToken, AccessTokenSecret, Options) of
      {ok, Id}        -> {ok, #state{id = Id, callback = Callback}};
      {error, Reason} -> {stop, {http_error, Reason}}
   end.

handle_call(_, _, State) ->
   {noreply, State}.

handle_cast(_Msg, State) ->
   {noreply, State}.

handle_info({http, {Id, stream_start, _Headers}}, #state{id = Id} = State) ->
   {noreply, State};

handle_info({http, {Id, stream, <<"\r\n">>}}, #state{id = Id} = State) ->
   {noreply, State};

handle_info({http, {Id, stream, Part}}, #state{id = Id, callback = {M, F}} = State) ->
   M:F(Part),
   {noreply, State};

handle_info({http, {Id, {error, Reason}}}, #state{id = Id} = State) ->
   httpc:cancel_request(Id),
   {stop, {http_error, Reason}, State}.

terminate(_, #state{id = Id}) ->
   ok = httpc:cancel_request(Id),
   io:format("~p terminated~n", [?MODULE]),
   ok.

code_change(_, State, _) ->
   {ok, State}.

