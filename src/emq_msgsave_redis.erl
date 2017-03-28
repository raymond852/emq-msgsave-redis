-module(emq_msgsave_redis).

-include_lib("emqttd/include/emqttd.hrl").

-export([load/1, unload/0]).

-export([handle_message_publish/2]).

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

load(Env) ->
  emqttd:hook('message.publish', fun ?MODULE:handle_message_publish/2, [Env]).

unload() ->
  emqttd:unhook('message.publish', fun ?MODULE:handle_message_publish/2).


% saved chatroom published mesage to redis
handle_message_publish(Message = #mqtt_message{topic = Topic}, Env) ->
  TopicPrefixList = ?ENV(topic_prefix, Env),
  TopicList = binary:bin_to_list(Topic),
  io:format("prefix ~s", TopicPrefixList),
  io:format("topic ~s", TopicList),
  case lists:prefix(TopicPrefixList, TopicList) of
     true ->
        emq_msgsave_redis_cli:handle(Message);
     _ ->
       ok
  end,
  {ok, Message};

handle_message_publish(Message, Env) ->
  {ok, Message}.
