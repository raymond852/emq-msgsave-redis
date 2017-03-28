-module(emq_msgsave_redis).

-include_lib("emqttd/include/emqttd.hrl").

-export([load/1, unload/0]).

-export([handle_message_publish/2]).

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

handle_chatroom_message(Message) ->
  emq_msgsave_redis_cli:handle(Message).

get_topic_prefix(Env) ->
  ?ENV(topic_prefix, Env).

load(Env) ->
  emqttd:hook('message.publish', fun ?MODULE:handle_message_publish/2, [Env]).

unload() ->
  emqttd:unhook('message.publish', fun ?MODULE:handle_message_publish/2).



% saved chatroom published mesage to redis
handle_message_publish(Message = #mqtt_message{topic = <<"cr:", _/binary>>}, Env) ->
  TopicPrefix = ?ENV(topic_prefix, Env),
  io:format("test some blood ~s\n", [TopicPrefix]),
  handle_chatroom_message(Message),
  {ok, Message};


handle_message_publish(Message, Env) ->
  TopicPrefix = ?ENV(topic_prefix, Env),
  io:format("test some blood ~s\n", [TopicPrefix]),
  {ok, Message}.
