/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

RE_COMMA        ,
RE_SEMICOLON    ;
RE_PLUS         "+"
RE_MINUS        "-"
RE_TIMES        "*"
RE_DIV          "/"
RE_TILDE        "~"
RE_LT           "<"
RE_EQUALS       "="
RE_RPAREN       "("
RE_LPAREN       ")"

RE_DARROW       =>
RE_ASSIGN       "<-"
RE_LE           "<="

RE_CLASS        [Cc][Ll][Aa][Ss][Ss]
RE_ELSE         [Ee][Ll][Ss][Ee]
RE_FI           [Ff][Ii]
RE_IF           [Ii][Ff]
RE_IN           [Ii][Nn]
RE_INHERITS     [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
RE_LET          [Ll][Ee][Tt]
RE_LOOP         [Ll][Oo][Oo][Pp]
RE_POOL         [Pp][Oo][Oo][Ll]
RE_THEN         [Tt][Hh][Ee][Nn]
RE_WHILE        [Ww][Hh][Ii][Ll][Ee]
RE_CASE         [Cc][Aa][Ss][Ee]
RE_ESAC         [Ee][Ss][Aa][Cc]
RE_OF           [Oo][Ff]
RE_NEW          [Nn][Ee][Ww]
RE_ISVOID       [Ii][Ss][Vv][Oo][Ii][Dd]
RE_NOT          [Nn][Oo][Tt]

RE_INTEGER      [0-9]+
RE_BOOL         (t[Rr][Uu][Ee]|f[Aa][Ll][Ss][Ee])
RE_OBJECTID     [a-z][A-Za-z0-9_]*
RE_TYPEID       [A-Z][A-Za-z0-9_]*

RE_WHITESPACE   [ \n\f\r\t\v]+

%%

{RE_WHITESPACE}   ;

 /*
  *  Single-character operators
  */

{RE_COMMA}        |
{RE_SEMICOLON}    |
{RE_PLUS}         |
{RE_MINUS}        |
{RE_TIMES}        |
{RE_DIV}          |
{RE_TILDE}        |
{RE_LT}           |
{RE_EQUALS}       |
{RE_RPAREN}       |
{RE_LPAREN}       { return (int)yytext[0]; }

 /*
  * Bool values
  */
{RE_BOOL} {
    cool_yylval.boolean = yytext[0] == 't' ? 1 : 0;
    return (BOOL_CONST);
}

 /*
  * Int values
  */
{RE_INTEGER} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (INT_CONST);
}

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */
{RE_DARROW}		{ return (DARROW); }
{RE_ASSIGN}		{ return (ASSIGN); }
{RE_LE}			{ return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{RE_CLASS}	{ return (CLASS); }
{RE_ELSE}	{ return (ELSE); }
{RE_FI}		{ return (FI); }
{RE_IF}		{ return (IF); }
{RE_IN}		{ return (IN); }
{RE_INHERITS}	{ return (INHERITS); }
{RE_LET}	{ return (LET); }
{RE_LOOP}	{ return (LOOP); }
{RE_POOL}	{ return (POOL); }
{RE_THEN}	{ return (THEN); }
{RE_WHILE}	{ return (WHILE); }
{RE_CASE}	{ return (CASE); }
{RE_ESAC}	{ return (ESAC); }
{RE_OF}		{ return (OF); }
{RE_NEW}	{ return (NEW); }
{RE_ISVOID}	{ return (ISVOID); }
{RE_NOT}	{ return (NOT); }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */



%%
