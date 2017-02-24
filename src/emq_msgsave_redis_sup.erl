-module(emq_msgsave_redis_sup).

-behaviour(supervisor).

-include("emq_msgsave_redis.hrl").

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, Server} = application:get_env(?APP, server),
    PoolSpec = ecpool:pool_spec(?APP, ?APP, emq_msgsave_redis_cli, Server),
    {ok, {{one_for_one, 10, 100}, [PoolSpec]}}.
