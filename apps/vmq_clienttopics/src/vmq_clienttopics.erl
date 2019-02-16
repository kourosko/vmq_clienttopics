-module(vmq_clienttopics).

-include("vernemq_dev.hrl").

-behaviour(on_register_hook).

-behaviour(on_client_wakeup_hook).

-behaviour(on_client_offline_hook).

-behaviour(on_client_gone_hook).

-export([on_client_gone/1, on_client_offline/1,
	 on_client_wakeup/1, on_register/3]).



publish_client_status(SubscriberId, Status) ->
    {ok,{M, F, A}}= application:get_env(vmq_clienttopics,
					  registry_mfa),
    {RegisterFun, PublishFun,
     {SubscribeFun, UnsubscribeFun}} =
	apply(M, F, A),
    true = is_function(RegisterFun, 0),
    true = is_function(PublishFun, 3),
    true = is_function(SubscribeFun, 1),
    true = is_function(UnsubscribeFun, 1),
    PublishFun(subscriber_id(SubscriberId), subscriber_id(SubscriberId), #{qos => 1, retain => false}),
    ok.

%% called as an 'all'-hook, return value is ignored
on_register(Peer, SubscriberId, UserName) ->
     true = publish_client_status(SubscriberId, "register"), ok.

on_client_wakeup(SubscriberId) ->
     true = publish_client_status(SubscriberId, "wakeup"), ok.

on_client_offline(SubscriberId) ->
    true =  publish_client_status(SubscriberId, "wakeup"), ok.

on_client_gone(SubscriberId) ->
    true =  publish_client_status(SubscriberId, "wakeup"), ok.

subscriber_id({_, ClientId}) -> ClientId;
subscriber_id({_, ClientId}) -> ClientId.
