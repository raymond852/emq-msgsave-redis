-module(emq_msgsave_redis_app).

-behaviour(application).

-include("emq_msgsave_redis.hrl").

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  {ok, Sup} = emq_msgsave_redis_sup:start_link(),
  emq_msgsave_redis:load(),
  {ok, Sup}.

stop(_State) ->
  emq_msgsave_redis:unload(),
  emqttd_plugin_redis:unload().
