use v6.d;
sub EXPORT(|) {
    use Polyglot::Brainfuck::Grammar;
    use Polyglot::Brainfuck::Actions;

    $*LANG.define_slang:
            'MAIN',
            $*LANG.slang_grammar('MAIN').^mixin(BFGrammarMixin),
            $*LANG.slang_actions('MAIN').^mixin(BFActionMixin);
    Map.new
}