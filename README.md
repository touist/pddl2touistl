# Constraints grammar in PDDL to TWIST tool using Ocaml

## Overview 

In OCaml, ocamllex is a lexer-generator and ocamlyacc a parser-generator for this project. The compiler writer implements two specification files in particular formats that ocamllex and ocamlyacc process, and they generate pure OCaml code that can be executed to lex and parse strings. 

## Constraints Parser file (Parser.mly)

In this file we define the different kinds of tokens for our language, the grammar rules that define legal statements in our language, and how to process the stream of tokens when groups of them match a grammar rule. `ocamlyacc` will read this file and then generate an OCaml file called `Parser.ml`, which will be the complete parser for our language. 

The code between %{ and %} gets copied verbatim into `Parser.ml`, so it is pure OCaml code.

Each %token line defines a kind of token. Note that multiple tokens can be defined on the same line, and you can define a token to carry along with it data of a particular type using <...>. Take a look at `Parser.ml` to see the OCaml datatype that corresponds to these token definitions. 

The %start and %type lines define which of the rules (defined later in the file) should be used as the top-most rule when trying to parse an input string. The remainder of the file after the %% defines the grammar rules. For each rule in the grammar, there is a corresponding { and }. What goes inside there is the OCaml "expression" that gets returned when the particular rule is matched. It is normal OCaml code, with the exception of things like $1 and $2, which correspond to the values returned by the first and second subparts of the rule. For example, when some sequence of tokens matches the fourth atom rule, the expression matched by expr between two parentheses is referred to as $2. 

## Constraints Lexer file (Lexer.mll)

In this file we define how characters in the input string should be broken up into the tokens defined in `Parser.ml`. The code within the { and } at the top is pure OCaml code that gets copied verbatim into a file called `Lexer.ml`. Notice that we open the Parser module (which will be generated by ocamlyacc so that the token datatype is in scope). 

The rest of the file defines how to convert ASCII characters into tokens. We choose the name token for our definition, but we very well could have named in anything. Whatever name we choose, however, we will be the entrypoint to the lexer; look at the file `Lexer.ml` and look for a function called token. 

The input string is matched against a series of string literals and regular expressions. As soon as one of the patterns matches the input string, the OCaml code within the corresponding { and } is added to the list of tokens, and the token function is recursively invoked on what remains of the input string. Note that in the first rule, lexbuf is the implicit name of the input string, so token lexbuf is a recursive call to the lexer that does not add any tokens to the list whenever any whitespace is matched in the input string. 

## Compiling constraints

After running `ocamllex Lexer.mll` and `ocamlyacc Parser.mly`, the modules Lexer and Parser can now be used to lex and parse strings and interpret them as statements in our constraints language. 

This script compile the constraints language into Ocaml modules:

```
#!/bin/sh
ocamllex Lexer.mll && \ # generates Lexer.ml
ocamlyacc Parser.mly && \ # generates Parser.ml and Parser.mli
ocamlc -c Parser.mli && \
ocamlc -c Lexer.ml &&\
ocamlc -c Parser.ml && \


After this step you can start modifying your make file, adding the modules to SOURCES variable. Generating a binary is possible using `make byte-code` as a shell command.

## Ocaml Parser/Lexer

http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual026.html#toc108