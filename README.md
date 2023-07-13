# Polyglot::Brainfuck

A basic module showing off how Brainfuck can be integrated into Raku.

Instead of using `sub` to declare a subroutine, use `bf` and you can code in BF!

BF subs do not accept signatures. They always have a single optional `buf8` parameter.  

BF subs always output a `buf8`;

```
    use Polyglot::Brainfuck;
    
    bf hi { 
        ++++++++[>++++[>++>+++>+++>+<<<<-]>
        +>+>->>+[<]<-]>>.>---.+++++++..+++.
        >>.<-.<.+++.------.--------.>>+.>++. 
    }
    
    say hi.decode; # Hello World!
    
    bf plus-two {
        ,++.
    }
    
    say plus-two(buf8.new: 40).head; # 42
```

## Version History

 * v0.1 Initial release