-module(doukaku_3rd_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

test(Expression, Expect) ->
  ?assertEqual(Expect, doukaku_3rd:calc(Expression)).

run_test() ->
  test(<<"27:675AED8">>, <<"11:EB4">>),
  test(<<"21:BCE8E0">>, <<"7:D0">>),
  test(<<"21:D1D760">>, <<"11:EA8">>),
  test(<<"22:E676A0">>, <<"15:9BD0">>),
  test(<<"22:E4EFB0">>, <<"2:4">>),
  test(<<"29:AE3B76D8">>, <<"44:5BB733899CC">>),
  test(<<"26:B7BF76C">>, <<"6:68">>),
  test(<<"54:64EDC671DFBAEC">>, <<"11:DF0">>),
  test(<<"49:D35D752FA66E0">>, <<"11:CD2">>),
  test(<<"51:ACD76A39EF354">>, <<"12:B78">>),
  test(<<"58:E2F3BDE73DB5BE4">>, <<"16:D6F9">>),
  test(<<"66:68EDC39D666BBBC6C">>, <<"24:4CE6F9">>),
  test(<<"63:ACB3AF172BBCE2B6">>, <<"18:ACAE0">>),
  test(<<"50:E6FB71C77DE84">>, <<"2:4">>),
  test(<<"94:A26BAEB9E6FAEB8D4EBC1BE0">>, <<"29:EAF1C9C0">>),
  test(<<"63:B9DBB5D77EF57CF0">>, <<"12:9A4">>),
  test(<<"49:6BB47AF13BE50">>, <<"11:9B8">>),
  test(<<"58:E5E9C6BB66FAF30">>, <<"14:BE44">>),
  test(<<"41:E3B76CEDDA0">>, <<"103:ADEF7C734F1A9CE6DD3B39CD70">>),
  test(<<"53:95ACEFDD3BF780">>, <<"4:C">>),
  test(<<"23:9DBB20">>, <<"116:66B7AC341271273637CEB65432B7A">>).
