-module(emq_msgsave_redis).

-include_lib("emqttd/include/emqttd.hrl").
-include("emq_msgsave_redis.hrl").

-export([load/1, unload/0]).

-export([handle_message_publish/2]).

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

load(Env) ->
  emqttd:hook('message.publish', fun ?MODULE:handle_message_publish/2, [Env]).

unload() ->
  emqttd:unhook('message.publish', fun ?MODULE:handle_message_publish/2).


% saved chatroom published mesage to redis
handle_message_publish(Message = #mqtt_message{topic = Topic}, _) ->
  TopicPrefixList = application:get_env(?APP, topic_prefix, undefined),
  TopicList = binary:bin_to_list(Topic),
  case lists:prefix(TopicPrefixList, TopicList) of
     true ->
        emq_msgsave_redis_cli:handle(Message);
     _ ->
       ok
  end,
  {ok, Message};

handle_message_publish(Message, _) ->
  {ok, Message}.
