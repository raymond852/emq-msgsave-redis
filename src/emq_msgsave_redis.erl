-module(emq_msgsave_redis).

-include_lib("emqttd/include/emqttd.hrl").

-export([load/1, unload/0]).

-export([handle_message_publish/2]).

handle_chatroom_message(Message) ->
  emq_msgsave_redis_cli:handle(Message).


load(Env) ->
  emqttd:hook('message.publish', fun ?MODULE:handle_message_publish/2, [Env]).

unload() ->
  emqttd:unhook('message.publish', fun ?MODULE:handle_message_publish/2).

% saved chatroom published mesage to redis
handle_message_publish(Message = #mqtt_message{topic = <<"cr:", _/binary>>}, _Env) ->
  handle_chatroom_message(Message),
  {ok, Message};

handle_message_publish(Message, _Env) ->
  {ok, Message}.
