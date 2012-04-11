-module(remotter_server).
-behaviour(gen_server).
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
   {ok, false}.

handle_call(Msg, _From, State) ->
   {reply, Msg, State}.

handle_cast({part, Part}, State) ->
   Decoded = jiffy:decode(Part),
   case dig([<<"user">>, <<"screen_name">>], Decoded) of
      {ok, <<"siritori">>} ->
         handle_own_tweet(Decoded, State);
      {ok, Name} ->
         handle_others_tweet(Name, Decoded, State);
      {error, _} ->
         remote_io:format("~p~n", [Decoded]),
         {noreply, State}
   end.

handle_info(_Info, void) ->
   {noreply, void}.

terminate(_Reason, void) ->
   io:format("~p terminated~n", [?MODULE]),
   ok.

code_change(_OldVsn, void, _Extra) ->
   {ok, void}.

%% internal functions

handle_own_tweet(Decoded, State) ->
   remote_io:format("siritori tweeted!~n", []),
   {ok, Text} = dig([<<"text">>], Decoded),
   case binary:split(Text, <<"cmd&gt;">>) of
      [<<>>, <<"disable notify">>] ->
         direct_msg:send("notify disabled."),
         {noreply, false};
      [<<>>, <<"enable notify">>] ->
         direct_msg:send("notify enabled."),
         {noreply, true};
      [<<>>, _] ->
         direct_msg:send("error: undefined command."),
         {noreply, State};
      _ ->
         {noreply, State}
   end.

handle_others_tweet(Name, Decoded, true) ->
   {ok, Text} = dig([<<"text">>], Decoded),
   remote_io:format("@~s: ~ts~n", [Name, Text]),
   OwnNameList = [<<"えりっく">>, <<"えろりっく">>, <<"えろっく">>],
   case dig([<<"event">>], Decoded) of
      {ok, _} -> do_nothing;
      {error, not_found} ->
         lists:foldl(fun(OwnName, Stat) ->
            case Stat of
               true -> true;
               false -> 
                  case binary:match(Text, OwnName) of
                     {_, _} ->
                        {ok, IdStr} = dig([<<"id_str">>], Decoded),
                        URL   = format("http://twitter.com/#!/~s/status/~s", [Name, IdStr]),
                        remote_io:format("~s called you! ~p~n", [Name, URL]),
                        direct_msg:send(format("~s called you! ~p", [Name, URL])),
                        true;
                     nomatch ->
                        false
                  end
            end
         end, false, OwnNameList)
   end,
   {noreply, true};
handle_others_tweet(_Name, _Decoded, false) ->
   {noreply, false}.

dig([], Val) ->
   {ok, Val};
dig([Key|Rest], {Data}) ->
   case lists:keyfind(Key, 1, Data) of
      {Key, Val} ->
         dig(Rest, Val);
      false ->
         {error, not_found}
   end.

format(Format, Args) ->
   lists:flatten(io_lib:format(Format, Args)).
