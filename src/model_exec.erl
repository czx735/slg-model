-module(model_exec).
-compile([export_all]).

-include("model.hrl").
-include_lib("eunit/include/eunit.hrl").

%% 统一的超时处理
exec_n(SQL) ->
  io:format("SQL ~p~n", [SQL]),
  Poll = model_config:poll(),
  case catch mysql:fetch(Poll, SQL) of
    {'EXIT', _} -> error_logger:warning_msg("SQL exit ~p", [SQL]), exit;
    {timeout, _}-> error_logger:warning_msg("SQL timeout ~p", [SQL]), timeout;
    {error, R} -> error_logger:warning_msg("SQL error ~p r ~p", [SQL, R]), error;
    _Other -> _Other
  end.
exec_t(SQL) ->
  io:format("SQL ~p~n", [SQL]),
  case catch mysql:fetch(SQL) of
    {'EXIT', _} -> error_logger:warning_msg("SQL exit ~p", [SQL]), exit;
    {timeout, _}-> error_logger:warning_msg("SQL timeout ~p", [SQL]), timeout;
    {error, R} -> error_logger:warning_msg("SQL error ~p r ~p", [SQL, R]), error;
    _Other -> _Other
  end.

%% 普通执行函数以_n为后缀，事务执行以_t为后缀.

%% 不指定poll，用于事务.
select_t(SQL) ->
  {data, Result} = exec_t(SQL),
  mysql:get_result_rows(Result).

%% 不指定poll，用于事务.
select_t(RecordName, SQL) ->
  Rows = select_t(SQL),
  lists:map(fun(R) -> R1=[RecordName | R], list_to_tuple(R1) end, Rows).

%% 执行select语句。
select_n(SQL) ->
  {data, Result} = exec_n(SQL),
  mysql:get_result_rows(Result).

select_n(RecordName, SQL) ->
  Rows = select_n(SQL),
  lists:map(fun(R) -> R1=[RecordName | R], list_to_tuple(R1) end, Rows).

update_t(SQL) ->
  case exec_t(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.

update_n(SQL) ->
  case exec_n(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.

delete_t(SQL) ->
  case exec_t(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.

delete_n(SQL) ->
  case exec_n(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.

insert_t(SQL) ->
  case exec_t(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.

insert_n(SQL) ->
  case exec_n(SQL) of
    {updated, _Result} -> ok;
    R -> R
  end.
