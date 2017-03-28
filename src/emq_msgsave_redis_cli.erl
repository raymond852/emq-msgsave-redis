-module(emq_msgsave_redis_cli).

-behaviour(ecpool_worker).

-include("emq_msgsave_redis.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

-export([connect/1, handle/1]).

%%--------------------------------------------------------------------
%% Redis Connect/Query
%%--------------------------------------------------------------------

connect(Opts) ->
    eredis:start_link(?ENV(host, Opts),
                      ?ENV(port, Opts),
                      ?ENV(database, Opts),
                      ?ENV(password, Opts),
                      no_reconnect).

%% Redis Query.
-spec(handle(mqtt_message()) -> {ok, undefined | binary() | list()} | {error, atom() | binary()}).
handle(Message) ->
  {Mega, Sec, Micro} = Message#mqtt_message.timestamp,
  Timeoffset = (Mega*1000000 + Sec) * 1000 + round(Micro/1000) - 1483228800000,
  Payload = Message#mqtt_message.payload,
  Topic = Message#mqtt_message.topic,
  Keyprefix = <<"m:">>,
  BinList = [<<"ZADD">>, <<Keyprefix/binary, Topic/binary>>, list_to_binary(integer_to_list(Timeoffset)), Payload],
  Cmd = [binary_to_list(X) || X <- BinList],
  ecpool:with_client(?APP, fun(C) -> eredis:q(C, Cmd) end).
