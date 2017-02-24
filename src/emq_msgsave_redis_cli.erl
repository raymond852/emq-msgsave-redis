-module(emq_msgsave_redis_cli).

-behaviour(ecpool_worker).

-include("emq_msgsave_redis.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

-export([connect/1, q/2]).

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
-spec(q(string(), mqtt_message()) -> {ok, undefined | binary() | list()} | {error, atom() | binary()}).
q(CmdStr, Message) ->
    Cmd = string:tokens(replvar(CmdStr, Message), " "),
    ecpool:with_client(?APP, fun(C) -> eredis:q(C, Cmd) end).

replvar(Cmd, #mqtt_message{topic = Topic, payload = Payload, timestamp = Timestamp}) ->
    replvar(replvar(replvar(Cmd, "%cr_id", Topic), "%ct", Payload), "%t", list_to_binary(integer_to_list(element(2, Timestamp)))).

replvar(S, _Var, undefined) ->
    S;
replvar(S, Var, Val) ->
    re:replace(S, Var, Val, [{return, list}]).
