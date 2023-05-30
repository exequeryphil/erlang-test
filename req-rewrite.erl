-module(req_rewrite).
-export([rewrite/1, bin_to_hexstr/1, hexstr_to_bin/1]).

% Binary pattern matching is probably more idiomatic and better performance-wise
% But in terms of my performance, I can write regex faster
rewrite(HexStr) ->
    RequestList = binary_to_list(hexstr_to_bin(HexStr)),
    case re:run(RequestList, "Host: www\\.illumio\\.com") of
        {match, _} -> HexStr;
        nomatch -> 
            ReqRewritten = rewrite_parts(RequestList),
            bin_to_hexstr(list_to_binary(ReqRewritten))
    end.

rewrite_parts(RequestList) ->
    WithNewPath = re:replace(RequestList, "^(GET) [^ ]+", "GET /", []),
    WithNewPathAndHost = re:replace(WithNewPath, "Host: .+\n", "Host: www.illumio.com\r\n", []),
    WithNewPathAndHost.

% Boilerplate... 
bin_to_hexstr(Bin) ->
    lists:flatten([io_lib:format("~2.16.0B", [X]) ||
    X <- binary_to_list(Bin)]).

hexstr_to_bin(S) ->
    hexstr_to_bin(S, []).
hexstr_to_bin([], Acc) ->
    list_to_binary(lists:reverse(Acc));
hexstr_to_bin([X,Y|T], Acc) ->
    {ok, [V], []} = io_lib:fread("~16u", [X,Y]),
    hexstr_to_bin(T, [V | Acc]);
hexstr_to_bin([X|T], Acc) ->
    {ok, [V], []} = io_lib:fread("~16u", lists:flatten([X,"0"])),
    hexstr_to_bin(T, [V | Acc]).