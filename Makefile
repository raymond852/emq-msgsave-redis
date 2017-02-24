PROJECT = emq_msgsave_redis
PROJECT_DESCRIPTION = Save chatroom message with Redis
PROJECT_VERSION = 2.1.0

DEPS = eredis ecpool

dep_eredis = git https://github.com/wooga/eredis master
dep_ecpool = git https://github.com/emqtt/ecpool master

BUILD_DEPS = emqttd cuttlefish
dep_emqttd = git https://github.com/emqtt/emqttd master
dep_cuttlefish = git https://github.com/emqtt/cuttlefish

NO_AUTOPATCH = cuttlefish

COVER = true

ERLC_OPTS += +'{parse_transform, lager_transform}'

include erlang.mk

app:: rebar.config

app.config::
	deps/cuttlefish/cuttlefish -l info -e etc/ -c etc/emq_msgsave_redis.conf -i priv/emq_msgsave_redis.schema -d data
