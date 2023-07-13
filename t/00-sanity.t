use v6.d;
use Polyglot::Brainfuck;
use Test;
bf foo {++.+++++-----}

is foo[0], 2;
done-testing;
