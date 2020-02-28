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
%type <std::vector<Statement*>> chunk
%type <std::vector<Statement*>> stmts
%type <Statement*> stmt
%type <Statement*> assignment
/*
%type <Statement*> laststmt
%type <Statement*> repeatuntil
%type <Statement*> function
%type <Statement*> for
%type <Statement*> assignment
%type <Statement*> if
%type <std::vector<Statement*>> elseifs
%type <Statement*> elseif
%type <Statement*> else

%type <Statement**> ioread
%type <std::vector<Statement**>> explist
%type <std::vector<Statement**>> arglist
*/
%type <Statement*> exp
%type <Statement*> op
%type <Statement*> op_1
%type <Statement*> op_2
%type <Statement*> op_3
%type <Statement*> op_last
%type <Statement*> var



%%

block		: chunk										{ log_grammar("block:chunk"); 					$$ = new Statement("Block", "", $1); root = $$; }

chunk		: stmts										{ log_grammar("chunk:stmts"); 					$$ = $1; }
	 		| stmts SEMICOLON							{ log_grammar("chunk:stmts laststmt ;"); 		$$ = $1; }

stmts		: stmt										{ log_grammar("stmts:stmt"); 					$$.push_back($1); }
 			| stmt SEMICOLON							{ log_grammar("stmts:stmt;"); 					$$.push_back($1); }
 			| stmts stmt								{ log_grammar("stmts:stmts stmt"); 				$$ = $1; $$.push_back($2); }
 			| stmts SEMICOLON stmt						{ log_grammar("stmts:stmts; stmt"); 			$$ = $1; $$.push_back($3); }

stmt 		: assignment								{ log_grammar("stmt:assignment");				$$ = $1; }
			//| exp										{ log_grammar("stmt:exp");						$$ = $1; }
/*
	 | if END										{ log_grammar("stmt:if END");					std::vector<Statement*> expr; expr.push_back($1); $$ = new IfStatementNode(expr); }
	 | if else END									{ log_grammar("stmt:if else END"); 				std::vector<Statement*> expr; expr.push_back($1); expr.push_back($2); $$ = new IfStatementNode(expr); }
	 | if elseifs END								{ log_grammar("stmt:if elseifs END"); 			$2.insert($2.begin(), $1); $$ = new IfStatementNode($2);}
	 | if elseifs else END							{ log_grammar("stmt:ifstatement END");			$2.insert($2.begin(), $1); $2.push_back($3); $$ = new IfStatementNode($2); }
	 | PRINT explist								{ log_grammar("stmt:PRINT explist"); 			$$ = new PrintNode($2); }
	 | PRINT LROUND explist RROUND					{ log_grammar("stmt:PRINT (explist)");			$$ = new PrintNode($3); }
	 | for END										{ log_grammar("stmt:for END"); 					$$ = $1; }
	 | IO_WRITE LROUND explist RROUND				{ log_grammar("stmt:IO_WRITE (explist)");		$$ = new IOWriteNode($3); }
	 | repeatuntil									{ log_grammar("stmt:repeatuntil"); 				$$ = $1; }
	 | function END									{ log_grammar("stmt:function");					$$ = $1; }
	 | VAR explist									{ log_grammar("stmt:functioncall"); 			$$ = new FunctionCallNode(new VariableNode(environment, $1), $2); }*/

assignment	: exp ASSIGNMENT exp						{ log_grammar("assignment:exp = exp");			$$ = new Statement("Binary operation", "'='", $1, $3); }

exp			: op										{ log_grammar("exp:op");						$$ = $1; }

op 			: op_1										{ log_grammar("op:op_1");						$$ = $1; }
			| op EQUALS op_1							{ log_grammar("op:op == op_1");					$$ = new Statement("Binary operation", "'==''", $1, $3); }
			| op NOT_EQUALS op_1						{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "!='", $1, $3); }
			| op LESS op_1								{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "'<'", $1, $3); }
			| op MORE op_1								{ log_grammar("op:op != op_1");					$$ = new Statement("Binary operation", "'>'", $1, $3); }

op_1		: op_2										{ log_grammar("op_1:op_2");						$$ = $1; }
			| op_1 PLUS op_2							{ log_grammar("op_1:op_1 + op_2");				$$ = new Statement("Binary operation", "'+'", $1, $3); }
			| op_1 MINUS op_2							{ log_grammar("op_1:op_1 - op_2");				$$ = new Statement("Binary operation", "'-'", $1, $3); }

op_2		: op_3										{ log_grammar("op_2:op_3"); 					$$ = $1; }
			| op_2 MUL op_3								{ log_grammar("op_2:op_2 * op_3");				$$ = new Statement("Binary operation", "'*'", $1, $3); }
			| op_2 DIV op_3								{ log_grammar("op_2:op_2 / op_3");				$$ = new Statement("Binary operation", "'/'", $1, $3); }
			| op_2 MOD op_3								{ log_grammar("op_2:op_2 % op_3");				$$ = new Statement("Binary operation", "'%'", $1, $3); }

op_3		: op_last									{ log_grammar("op_3:op_last");					$$ = $1; }
			| op_3 POWER_OF op_last						{ log_grammar("op_3:op_3 ^ op_last");			$$ = new Statement("Binary operation", "'^'", $1, $3); }

op_last		: var										{ log_grammar("op_last:VAR"); 					$$ = $1; }
			| VALUE										{ log_grammar("op_last:VALUE"); 				$$ = new Statement("Value", $1); }
			| LROUND VALUE RROUND						{ log_grammar("op_last:(VALUE)"); 				$$ = new Statement("(Value)", $2); }
		//| VAR LSQUARE exp RSQUARE					{ log_grammar("op_last:[exp]"); 				$$ = new VariableNode(environment, $1, $3); }
		//| LROUND exp RROUND							{ log_grammar("op_last:(exp)"); 				$$ = new ParenthesisNode($2); }
		//| HASHTAG VAR 								{ log_grammar("op_last:#VAR");					$$ = new LengthNode(new VariableNode(environment, $2)); }
		//| VAR LROUND explist RROUND					{ log_grammar("op_last:functioncall"); 			$$ = new FunctionCallNode(new VariableNode(environment, $1), $3);}
		//| MINUS VALUE								{ log_grammar("op_last:-exp"); 					$$ = new IntegerNode(-$2); }

var 		: VAR										{ log_grammar("op_last:VAR"); 					$$ = new Statement("Variable", $1); }
			| var DOT var								{ log_grammar("op_last:VAR.VAR"); 				$1->dot($3); $$ = new Statement("Dot", "'.'", $1); }
