# Small scale C compiler

Built a small compiler for C language using Lex and Bison.

**FLEX:**
FLEX (Fast LEXical analyzer generator) is a tool for generating scanners. Instead of writing a scanner from scratch, you only need to identify the vocabulary of a certain language (e.g. Simple), write a specification of patterns using regular expressions (e.g. DIGIT [0-9]), and FLEX will construct a scanner for you. 
First, FLEX reads a specification of a scanner either from an input file *.l, or from standard input, and it generates as output a C source file lex.y.


**Bison:**
Bison is a program that converts the formal description of a computer language grammar into a C language program that can parse the syntax and symbols of that grammar into instructions that the computer can execute. The grammar to be converted must be a Lookahead Left-to-Right (LALR) context-free grammar. 
