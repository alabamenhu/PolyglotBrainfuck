unit role BFGrammarMixin;
token BF { <BF-command>* }

proto
token BF-command         {      *     }
token BF-command:sym<+>  {    <sym>   }
token BF-command:sym<->  {    <sym>   }
token BF-command:sym«<»  {    <sym>   }
token BF-command:sym«>»  {    <sym>   }
token BF-command:sym<.>  {    <sym>   }
token BF-command:sym<,>  {    <sym>   }
token BF-command:sym<#>  { <.BF-junk> }
token BF-command:sym<[]> {  '[' ~ ']' <BF-command>* }

# } isn't a junk character, but needed for terminating the block
token BF-junk { <-[-+<>.,[\]}]>+ }

token routine_declarator:sym<bf> {
   # What we want to parse is this format: bf foo { <code> }
    <sym> <.end_keyword> <.ws>            # bf
    $<name> = <[a..zA..Z]>+               #    foo
    <.ws>                                 #
    '{'                                   #        {
    <BF>                                  #          <code>
    '}'                                   #                 }
    <?ENDSTMT>
}