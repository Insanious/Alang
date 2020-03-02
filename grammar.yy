%skeleton "lalr1.cc"
%defines
%define api.value.type variant
%define api.token.constructor


%code {
	#define YY_DECL yy::parser::symbol_type yylex()
	YY_DECL;

	void log_grammar(std::string message)
	{
		if (debug_grammar)
			std::cout << "GRAMMAR:\t " << message << '\n';
	}

	Statement* root;
}

%code requires{
	#include "globals.h"
	#include "Nodes.h"
}

%token EXIT 0 "end of file"

/* Control-flow */
%token <std::string> IF
%token <std::string> THEN
%token <std::string> ELSEIF
%token <std::string> ELSE

/* Looping */
%token <std::string> FOR
%token <std::string> WHILE
%token <std::string> REPEAT
%token <std::string> DO
%token <std::string> UNTIL
%token <std::string> END
%token <std::string> IN

/* Binary operations */
%token <std::string> PLUS
%token <std::string> MINUS
%token <std::string> MUL
%token <std::string> DIV
%token <std::string> POWER_OF
%token <std::string> MOD
%token <std::string> EQUALS
%token <std::string> NOT_EQUALS
%token <std::string> LESS
%token <std::string> MORE
%token <std::string> LESS_OR_EQUAL
%token <std::string> MORE_OR_EQUAL
%token <std::string> TILDE_EQUAL

/* Unary operations */
%token <std::string> NOT
%token <std::string> AND
%token <std::string> OR
%token <std::string> HASHTAG

/* Scope */
%token <std::string> LOCAL

/* Functions */
%token <std::string> FUNCTION
%token <std::string> CONTAINS
%token <std::string> HAS
%token <std::string> BREAK
%token <std::string> RETURN
%token <std::string> PRINT
%token <std::string> IO_WRITE
%token <std::string> IO_READ
%token <std::string> IO_READ_NUMBER
%token <std::string> IO_READ_LINE
%token <std::string> IO_READ_ALL

/* Values */
%token <std::string> VALUE
%token <std::string> VAR

/* Single-character tokens */
%token <std::string> ASSIGNMENT
%token <std::string> DOT
%token <std::string> COLON
%token <std::string> SEMICOLON
%token <std::string> COMMA
%token <std::string> LARROW
%token <std::string> LROUND
%token <std::string> RROUND
%token <std::string> LSQUARE
%token <std::string> RSQUARE
%token <std::string> LCURLY
%token <std::string> RCURLY

/* Whitespace */
%token <std::string> WHITESPACE
%token <std::string> NEWLINE
%token <std::string> OTHER



%type <Statement*> block
%type <Statement*> chunk
%type <Statement*> stmts
%type <Statement*> stmt
%type <Statement*> assignment
%type <Statement*> exp
%type <Statement*> op
%type <Statement*> op_1
%type <Statement*> op_2
%type <Statement*> op_3
%type <Statement*> op_last
%type <Statement*> varlist
%type <Statement*> vardot
%type <Statement*> vararrow
%type <Statement*> var




%%

block		: chunk										{ log_grammar("block:chunk"); 					$$ = new Statement("Block"); $$->children.push_back($1); root = $$; }

chunk		: stmts										{ log_grammar("chunk:stmts"); 					$$ = $1; }
	 		| stmts SEMICOLON							{ log_grammar("chunk:stmts laststmt ;"); 		$$ = $1; }

stmts		: stmt										{ log_grammar("stmts:stmt"); 					$$ = new Statement("Statements"); $$->children.push_back($1); }
 			| stmt SEMICOLON							{ log_grammar("stmts:stmt;"); 					$$ = new Statement("Statements"); $$->children.push_back($1); }
 			| stmts stmt								{ log_grammar("stmts:stmts stmt"); 				$$ = $1; $$->children.push_back($2); }
 			| stmts SEMICOLON stmt						{ log_grammar("stmts:stmts; stmt"); 			$$ = $1; $$->children.push_back($3); }

stmt 		: assignment								{ log_grammar("stmt:assignment");				$$ = $1; }
			| vararrow									{ log_grammar("stmt:vararrow"); 				$$ = $1; }


assignment	: exp ASSIGNMENT exp						{ log_grammar("assignment:exp = exp");			$$ = new Statement("Binary operation", "'='"); $$->children.push_back($1); $$->children.push_back($3); }
vararrow 	: var LARROW var							{ log_grammar("assignment:exp -> exp");			$$ = new Statement("Arrow operation", "'->'"); $$->children.push_back($1); $$->children.push_back($3); }
			| vararrow LARROW var						{ log_grammar("assignment:vararrow -> exp"); 	$$ = $1; $$->children.push_back($3); }

exp			: op										{ log_grammar("exp:op");						$$ = $1; }

op 			: op_1										{ log_grammar("op:op_1");						$$ = $1; }
			| op EQUALS op_1							{ log_grammar("op:op == op_1");					$$ = new Statement("Binary operation", "'==''"); $$->children.push_back($1); $$->children.push_back($3); }
			| op NOT_EQUALS op_1						{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "!='"); $$->children.push_back($1); $$->children.push_back($3); }
			| op LESS op_1								{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "'<'"); $$->children.push_back($1); $$->children.push_back($3); }
			| op MORE op_1								{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "'>'"); $$->children.push_back($1); $$->children.push_back($3); }

op_1		: op_2										{ log_grammar("op_1:op_2");						$$ = $1; }
			| op_1 PLUS op_2							{ log_grammar("op_1:op_1 + op_2");				$$ = new Statement("Binary operation", "'+'"); $$->children.push_back($1); $$->children.push_back($3); }
			| op_1 MINUS op_2							{ log_grammar("op_1:op_1 - op_2");				$$ = new Statement("Binary operation", "'-'"); $$->children.push_back($1); $$->children.push_back($3); }

op_2		: op_3										{ log_grammar("op_2:op_3"); 					$$ = $1; }
			| op_2 MUL op_3								{ log_grammar("op_2:op_2 * op_3");				$$ = new Statement("Binary operation", "'*'"); $$->children.push_back($1); $$->children.push_back($3); }
			| op_2 DIV op_3								{ log_grammar("op_2:op_2 / op_3");				$$ = new Statement("Binary operation", "'/'"); $$->children.push_back($1); $$->children.push_back($3); }
			| op_2 MOD op_3								{ log_grammar("op_2:op_2 % op_3");				$$ = new Statement("Binary operation", "'%'"); $$->children.push_back($1); $$->children.push_back($3); }

op_3		: op_last									{ log_grammar("op_3:op_last");					$$ = $1; }
			| op_3 POWER_OF op_last						{ log_grammar("op_3:op_3 ^ op_last");			$$ = new Statement("Binary operation", "'^'"); $$->children.push_back($1); $$->children.push_back($3); }

op_last		: var										{ log_grammar("op_last:VAR"); 					$$ = $1; }
			| vardot									{ log_grammar("op_last:vardot"); 				$$ = $1; }
			| VALUE										{ log_grammar("op_last:VALUE"); 				$$ = new Statement("Value", $1); }
			| LROUND VALUE RROUND						{ log_grammar("op_last:(VALUE)"); 				$$ = new Statement("(Value)", $2); }

var 		: VAR										{ log_grammar("op_last:VAR"); 					$$ = new Statement("Variable", $1); }

varlist		: var										{ log_grammar("varlist:var"); 					$$ = new Statement("Variables"); $$->children.push_back($1); }
			| varlist COMMA var							{ log_grammar("varlist:varlist, var"); 			$$ = $1; $$->children.push_back($3); }


vardot : var DOT var									{ log_grammar("vardot:var DOT var");			$$ = new Statement("Dot operation", "'.'"); $$->children.push_back($1);  $$->children.push_back($3); }
	   | vardot DOT var									{ log_grammar("vardot:vardot DOT var");			$$ = $1; $$->children.push_back($3); }
