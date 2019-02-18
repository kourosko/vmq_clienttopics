-module(vmq_clienttopics).
-behaviour(on_register_hook).
-behaviour(on_client_wakeup_hook).
-behaviour(on_client_offline_hook).
-behaviour(on_client_gone_hook).

-export([on_client_gone/1, on_client_offline/1,
	 on_client_wakeup/1, on_register/3]).


% create_message(SubscriberId, Status){
%     sub=subscriber_id(SubscriberId),
%     message=sub++"|"++
% }
publish_client_status(SubscriberId, Status) ->
    {ok,{M, F, A}}= application:get_env(vmq_clienttopics,
					  registry_mfa),
    {_, PublishFun,
     {_, _}} =
	apply(M, F, A),
      PublishFun([<<"clients">>],list_to_binary(subscriber_id(SubscriberId)++"|"++Status), #{qos=>1,retain=>false}),
    ok.

%% called as an 'all'-hook, return value is ignored
on_register(_, SubscriberId, _) ->
     publish_client_status(SubscriberId, "register"), ok.

on_client_wakeup(SubscriberId) ->
    publish_client_status(SubscriberId, "wakeup"), ok.

on_client_offline(SubscriberId) ->
   publish_client_status(SubscriberId, "offline"), ok.

on_client_gone(SubscriberId) ->
    publish_client_status(SubscriberId, "gone"), ok.

subscriber_id({_, ClientId}) -> binary_to_list(ClientId).
