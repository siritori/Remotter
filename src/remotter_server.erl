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
   {ok, false}.

handle_call(Msg, _From, State) ->
   {reply, Msg, State}.

handle_cast({part, Part}, State) ->
   Decoded = jiffy:decode(Part),
   case dig([<<"user">>, <<"screen_name">>], Decoded) of
      {ok, <<"siritori">>} ->
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
         end;
      {ok, NameBin} ->
         {ok, Text} = dig([<<"text">>], Decoded),
         case binary:match(Text, <<"えりっく">>) of
            {_, _} ->
               io:format("~s called you!!~n~p~n", [NameBin, Text]),
               direct_msg:send(binary_to_list(NameBin) ++ " called you!"),
               {noreply, State};
            nomatch ->
               {noreply, State}
         end;
      {error, _} ->
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

dig([], Val) ->
   {ok, Val};
dig([Key|Rest], {Data}) ->
   case lists:keyfind(Key, 1, Data) of
      {Key, Val} ->
         dig(Rest, Val);
      false ->
         {error, not_found}
   end.
