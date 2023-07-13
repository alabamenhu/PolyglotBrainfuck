unit role BFActionMixin;
use experimental :rakuast;

my constant Pointer  = RakuAST::Var::Lexical.new('$pointer');
my constant Memory   = RakuAST::Var::Lexical.new('$memory');
my constant Input    = RakuAST::Var::Lexical.new('$input');
my constant Output   = RakuAST::Var::Lexical.new('$output');
my constant MemLoc = RakuAST::ApplyPostfix.new(
    operand => RakuAST::Var::Lexical.new('$memory'),
    postfix => RakuAST::Postcircumfix::ArrayIndex.new(
        index => RakuAST::SemiList.new(
            RakuAST::Statement::Expression.new(
                expression => RakuAST::Var::Lexical.new('$pointer')
            )
        )
    )
);
method BF (Mu $/) {
    my $pointer-declare = RakuAST::Statement::Expression.new(
        expression => RakuAST::VarDeclaration::Simple.new(
            sigil => '$',
            desigilname => RakuAST::Name.from-identifier('pointer'),
            initializer => RakuAST::Initializer::Assign.new(
                RakuAST::IntLiteral.new(0)
            )
        )
    );
    my $memory-declare = RakuAST::Statement::Expression.new(
        expression => RakuAST::VarDeclaration::Simple.new(
            scope => 'my',
            sigil => '$',
            desigilname => RakuAST::Name.from-identifier('memory'),
            initializer => RakuAST::Initializer::Assign.new(
                RakuAST::ApplyPostfix.new(
                    operand => RakuAST::Type::Simple.new(
                        RakuAST::Name.from-identifier("buf8")
                    ),
                    postfix => RakuAST::Call::Method.new(
                        name => RakuAST::Name.from-identifier("new")
                    )
                )
            )
        )
    );
    my $output-declare = RakuAST::Statement::Expression.new(
        expression => RakuAST::VarDeclaration::Simple.new(
            scope => 'my',
            sigil => '$',
            desigilname => RakuAST::Name.from-identifier('output'),
            initializer => RakuAST::Initializer::Assign.new(
                RakuAST::ApplyPostfix.new(
                    operand => RakuAST::Type::Simple.new(
                        RakuAST::Name.from-identifier("buf8")
                    ),
                    postfix => RakuAST::Call::Method.new(
                        name => RakuAST::Name.from-identifier("new")
                    )
                )
            )
        )
    );
    my @statements = $/.hash.AT-KEY('BF-command').map(*.made);
    my $signature = RakuAST::Signature.new(
        parameters => (
            RakuAST::Parameter.new(
                type => RakuAST::Type::Simple.new(
                    RakuAST::Name.from-identifier('buf8')
                ),
                target => RakuAST::ParameterTarget::Var.new('$input'),
                optional => True
            ),
        )
    );
    my $body = RakuAST::Blockoid.new(
        RakuAST::StatementList.new(
            $pointer-declare,
            $memory-declare,
            $output-declare,
            |@statements,
            RakuAST::Statement::Expression.new(expression => Output)
        )
    );
    make RakuAST::Sub.new(
        name => RakuAST::Name.from-identifier('foo'),
        :$signature,
        :$body
    )
}

proto method BF-command { * }
method BF-command:sym<+> (Mu $/) {
    make RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyPostfix.new(
            postfix => RakuAST::Postfix.new('++'),
            operand => MemLoc
        )
    )
}


method BF-command:sym<-> (Mu $/) {
    make RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyPostfix.new(
           postfix => RakuAST::Postfix.new('--'),
           operand => MemLoc
        )
    )
}
method BF-command:sym«<» (Mu $/) {
    make RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyPostfix.new(
            operand => Pointer,
            postfix => RakuAST::Postfix.new('--')
        )
    )
}
method BF-command:sym«>» (Mu $/) {
    make RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyPostfix.new(
            operand => Pointer,
            postfix => RakuAST::Postfix.new('++')
        )
    )
}
method BF-command:sym<.> (Mu $/) {
    make RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyPostfix.new(
            operand => Output,
            postfix => RakuAST::Call::Method.new(
                name => RakuAST::Name.from-identifier("push"),
                args => RakuAST::ArgList.new(
                    MemLoc
                )
            )
        )
    )
}
method BF-command:sym<,> (Mu $/) {
    make RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyInfix.new(
            left => MemLoc,
            infix => RakuAST::Infix.new('='),
            right => RakuAST::ApplyPostfix.new(
                operand => Input,
                postfix => RakuAST::Call::Method.new(
                    name => RakuAST::Name.from-identifier('shift')
                )
            )
        )
    )
}
method BF-command:sym<#> (Mu $/) { make Empty }
method BF-command:sym<[]> (Mu $/) {
    my @statements = $/.hash.AT-KEY('BF-command').map: *.made;
    make RakuAST::Statement::Loop::While.new(
        condition => MemLoc,
        body => RakuAST::Block.new(
            body => RakuAST::Blockoid.new(
                RakuAST::StatementList.new( |@statements )
            )
        )
    )
}

method routine_declarator:sym<bf> (Mu $/) {
    use MONKEY-SEE-NO-EVAL;
    $*W.install_lexical_symbol:
        $*UNIT,
        '&' ~ $/.hash.AT-KEY('name').Str,
        EVAL $/.hash.AT-KEY('BF').made
}