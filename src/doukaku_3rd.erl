-module(doukaku_3rd).

-export([calc/1]).

-spec calc(binary()) -> binary().
calc(EncodedExpression) ->
    Rpn = to_rpn(decode(EncodedExpression)),
    encode(compile(calc_rpn(Rpn))).

%% Internal functions
hex(Bin) -> integer_to_binary(binary_to_integer(Bin, 2), 16).

bin(Hex) -> integer_to_binary(binary_to_integer(Hex, 16), 2).

-spec decode(binary()) -> list().
decode(EncodedExpression) ->
    [Length, HexExpression] = binary:split(EncodedExpression, <<":">>),
    parse(binary:part(hex_to_bin(HexExpression), 0, binary_to_integer(Length))).

-spec encode(binary()) -> binary().
encode(Result) ->
    Length = integer_to_binary(byte_size(Result)),
    Hex = bin_to_hex(Result),
    <<Length/binary, ":", Hex/binary>>.

-spec hex_to_bin(binary()) -> binary().
hex_to_bin(Hex) -> hex_to_bin(Hex, []).
hex_to_bin(<<>>, Acc) -> list_to_binary(Acc);
hex_to_bin(<<Hex:8, Rest/binary>>, Acc) -> hex_to_bin(Rest, [Acc, padding(bin(<<Hex>>), before_zero)]).

-spec bin_to_hex(binary()) -> binary().
bin_to_hex(Bin) -> hex(padding(Bin, after_zero)).

-spec padding(binary(), atom()) -> binary().
padding(Bin, At) -> padding(Bin, byte_size(Bin) rem 4, At).
padding(Bin, 0, _) -> Bin;
padding(Bin, ByteSize, before_zero) -> list_to_binary([lists:duplicate(4 - ByteSize, $0), Bin]);
padding(Bin, ByteSize, after_zero) -> list_to_binary([Bin, lists:duplicate(4 - ByteSize, $0)]).

-spec parse(binary()) -> list().
parse(Expression) -> parse(Expression, <<>>, []).
parse(<<>>, Read, Acc) -> lists:flatten([Acc, binary_to_integer(Read)]);
parse(<<"00", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "0">>, Acc);
parse(<<"01", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "1">>, Acc);
parse(<<"100", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "2">>, Acc);
parse(<<"1010", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "3">>, Acc);
parse(<<"1011", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "4">>, Acc);
parse(<<"1100", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "5">>, Acc);
parse(<<"11010", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "6">>, Acc);
parse(<<"11011", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "7">>, Acc);
parse(<<"111000", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "8">>, Acc);
parse(<<"111001", Rest/binary>>, Read, Acc) -> parse(Rest, <<Read/binary, "9">>, Acc);
parse(<<"1110100", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"+">>]);
parse(<<"1110101", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"-">>]);
parse(<<"1110110", "1110110", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"**">>]);
parse(<<"1110110", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"*">>]);
parse(<<"1110111", "1110111", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"//">>]);
parse(<<"1110111", Rest/binary>>, Read, Acc) -> parse(Rest, <<>>, [Acc, binary_to_integer(Read), <<"/">>]).

-spec to_rpn(list()) -> list().
to_rpn(Expression) -> to_rpn(Expression, [], []).
to_rpn([], Ops, Acc) -> lists:flatten([Acc, Ops]);
to_rpn([Operand | Tail], Ops, Acc) when is_integer(Operand) -> to_rpn(Tail, Ops, [Acc, Operand]);
to_rpn([<<"**">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"**">>, Ops], Acc);
to_rpn([<<"*">> | Tail], [<<"**">> | Ops], Acc) -> to_rpn(Tail, [<<"*">>, Ops], [Acc, <<"**">>]);
to_rpn([<<"*">> | Tail], [<<"/">> | Ops], Acc) -> to_rpn(Tail, [<<"*">>, Ops], [Acc, <<"/">>]);
to_rpn([<<"*">> | Tail], [<<"*">> | Ops], Acc) -> to_rpn(Tail, [<<"*">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"*">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"*">>, Ops], Acc);
to_rpn([<<"/">> | Tail], [<<"**">> | Ops], Acc) -> to_rpn(Tail, [<<"/">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"/">> | Tail], [<<"*">> | Ops], Acc) -> to_rpn(Tail, [<<"/">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"/">> | Tail], [<<"/">> | Ops], Acc) -> to_rpn(Tail, [<<"/">>, Ops], [Acc, <<"/">>]);
to_rpn([<<"/">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"/">>, Ops], Acc);
to_rpn([<<"//">> | Tail], [<<"**">> | Ops], Acc) -> to_rpn(Tail, [<<"//">>, Ops], [Acc, <<"**">>]);
to_rpn([<<"//">> | Tail], [<<"*">> | Ops], Acc) -> to_rpn(Tail, [<<"//">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"//">> | Tail], [<<"/">> | Ops], Acc) -> to_rpn(Tail, [<<"//">>, Ops], [Acc, <<"/">>]);
to_rpn([<<"//">> | Tail], [<<"//">> | Ops], Acc) -> to_rpn(Tail, [<<"//">>, Ops], [Acc, <<"//">>]);
to_rpn([<<"//">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"//">>, Ops], Acc);
to_rpn([<<"+">> | Tail], [<<"**">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"**">>]);
to_rpn([<<"+">> | Tail], [<<"*">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"+">> | Tail], [<<"/">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"/">>]);
to_rpn([<<"+">> | Tail], [<<"//">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"//">>]);
to_rpn([<<"+">> | Tail], [<<"+">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"+">>]);
to_rpn([<<"+">> | Tail], [<<"-">> | Ops], Acc) -> to_rpn(Tail, [<<"+">>, Ops], [Acc, <<"-">>]);
to_rpn([<<"+">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"+">>, Ops], Acc);
to_rpn([<<"-">> | Tail], [<<"**">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"**">>]);
to_rpn([<<"-">> | Tail], [<<"*">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"*">>]);
to_rpn([<<"-">> | Tail], [<<"/">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"/">>]);
to_rpn([<<"-">> | Tail], [<<"//">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"//">>]);
to_rpn([<<"-">> | Tail], [<<"+">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"+">>]);
to_rpn([<<"-">> | Tail], [<<"-">> | Ops], Acc) -> to_rpn(Tail, [<<"-">>, Ops], [Acc, <<"-">>]);
to_rpn([<<"-">> | Tail], Ops, Acc) -> to_rpn(Tail, [<<"-">>, Ops], Acc).

-spec calc_rpn(list()) -> integer().
calc_rpn(Rpn) -> calc_rpn(Rpn, []).
calc_rpn([], [Result]) -> Result;
calc_rpn([Operand | Tail], Acc) when is_integer(Operand) -> calc_rpn(Tail, [Operand | Acc]);
calc_rpn([<<"-">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [(Lhs - Rhs) | Acc]);
calc_rpn([<<"+">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [(Lhs + Rhs) | Acc]);
calc_rpn([<<"*">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [(Lhs * Rhs) | Acc]);
calc_rpn([<<"/">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [trunc(Lhs / Rhs) | Acc]);
calc_rpn([<<"**">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [pow(Lhs, Rhs) | Acc]);
calc_rpn([<<"//">> | Tail], [Rhs, Lhs | Acc]) -> calc_rpn(Tail, [(Lhs rem Rhs) | Acc]).

-spec compile(integer()) -> binary().
compile(Result) -> compile(integer_to_binary(Result), <<>>).
compile(<<>>, Acc) -> list_to_binary(Acc);
compile(<<"-", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"1110101">>]);
compile(<<"0", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"00">>]);
compile(<<"1", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"01">>]);
compile(<<"2", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"100">>]);
compile(<<"3", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"1010">>]);
compile(<<"4", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"1011">>]);
compile(<<"5", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"1100">>]);
compile(<<"6", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"11010">>]);
compile(<<"7", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"11011">>]);
compile(<<"8", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"111000">>]);
compile(<<"9", Rest/binary>>, Acc) -> compile(Rest, [Acc, <<"111001">>]).

-spec pow(integer(), integer()) -> integer().
pow(X, Y) -> pow(X, Y, 1).
pow(_, 0, Acc) -> Acc;
pow(X, Y, Acc) -> pow(X, Y - 1, Acc * X).
