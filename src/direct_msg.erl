-module(direct_msg).
-compile(export_all).
-define(CONSUMER_KEY, "tdPkd4z4lvANKT22xqIzng").
-define(CONSUMER_SECRET, "oZjO8LxzGSq4jvWcgRNOFzlJsiMLCiZOVMWJdIKPCsk").
-define(ACCESS_TOKEN, "547781917-jNire46819xGXASVB4FBvlVDvIJWIz6XmvNFs3U8").
-define(TOKEN_SECRET, "vWvZDu80doIoA8yIOeKkQ98t5fMErYgFMvimE7YeMU").

send(Msg) ->
   application:start(inets),
   ssl:start(),
   Consumer = {?CONSUMER_KEY, ?CONSUMER_SECRET, hmac_sha1},
   URL = "https://api.twitter.com/1/direct_messages/new.json",
   Query = [{"screen_name", "siritori"}, {"text", Msg}],
   oauth:post(URL, Query, Consumer, ?ACCESS_TOKEN, ?TOKEN_SECRET, []).

