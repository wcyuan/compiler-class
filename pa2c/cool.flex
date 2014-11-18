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

int comment_depth = 0;
int string_length = 0;
int string_escape = 0;
int string_error = 0;

%}

%START MULTILINE_COMMENT ONELINE_COMMENT IN_STRING

/*
 * Define names for regular expressions here.
 */

RE_PERIOD       "\."
RE_COMMA        ,
RE_COLON        :
RE_SEMICOLON    ;
RE_PLUS         "+"
RE_MINUS        "-"
RE_TIMES        "*"
RE_DIV          "/"
RE_TILDE        "~"
RE_LT           "<"
RE_EQUALS       "="
RE_LPAREN       "("
RE_RPAREN       ")"
RE_LBRACE       "{"
RE_RBRACE       "}"
RE_ATSIGN       @

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

RE_WHITESPACE   [ \f\r\t\v]+
RE_NEWLINE      \n
RE_NULL_CHAR    \0
RE_BACKSLASH    \\

RE_COMMENTSTART "(*"
RE_COMMENTEND   "*)"

RE_COMMENT_1LN  --

RE_STRING_START "\""
RE_STRING_END   "\""

%%

<IN_STRING>{
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

    {RE_NULL_CHAR} {
        if (!string_error) {
            string_error = 1;
            cool_yylval.error_msg = "String contains null character";
            return (ERROR);
        }
        string_error = 1;
    }
    <<EOF>> {
        BEGIN(INITIAL);
        if (!string_error) {
            cool_yylval.error_msg = "EOF in string constant";
            return (ERROR);
        }
    }

    {RE_NEWLINE}|. {
        char c = yytext[0];
        if (!string_escape && c == '"') {
            BEGIN(INITIAL);
            if (!string_error) {
                string_buf[string_length] = '\0';
                cool_yylval.symbol = stringtable.add_string(string_buf);
                return (STR_CONST);
            }
        }
        if (!string_escape && c == '\n') {
            BEGIN(INITIAL);
            curr_lineno++;
            if (!string_error) {
                cool_yylval.error_msg = "Unterminated string constant";
                return (ERROR);
            }
        }
        if (!string_escape && c == '\\') {
            string_escape = 1;
        }
        else {
            if (c == '\n') {
                curr_lineno++;
            }
            if (string_escape) {
                switch (c) {
                    case 'n':  c = '\n';      break;
                    case 'b':  c = '\b';      break;
                    case 't':  c = '\t';      break;
                    case 'f':  c = '\f';      break;
                }
            }
            string_escape = 0;
            if (!string_error && string_length >= MAX_STR_CONST-1) {
                string_error = 1;
                cool_yylval.error_msg = "String constant too long";
                return (ERROR);
            }
            if (!string_error) {
                string_buf[string_length++] = c;
            }
        }
    }
}

<ONELINE_COMMENT>{
    {RE_NEWLINE} {
        curr_lineno++;
        BEGIN(INITIAL);
    }
    . ;
}


 /*
  *  Nested comments
  */
<MULTILINE_COMMENT>{
    {RE_NEWLINE} { curr_lineno++; }

    {RE_COMMENTSTART} {
        comment_depth++;
    }
    {RE_COMMENTEND} {
        comment_depth--;
	if (comment_depth <= 0) {
	    comment_depth = 0;
 	    BEGIN(INITIAL);
	}
    }
    <<EOF>> {
        cool_yylval.error_msg = "EOF in comment";
        BEGIN(INITIAL);
 	return (ERROR);
    }
    . ;
}

<INITIAL>{

{RE_NEWLINE}      { curr_lineno++; }

{RE_COMMENT_1LN} {
    BEGIN(ONELINE_COMMENT);
}

{RE_COMMENTSTART} {
    BEGIN(MULTILINE_COMMENT);
    comment_depth = 1;
}

{RE_COMMENTEND} {
    cool_yylval.error_msg = "Unmatched *)";
    return (ERROR);
}

{RE_WHITESPACE}   ;

 /*
  *  Single-character operators
  */

{RE_PERIOD}       |
{RE_COMMA}        |
{RE_COLON}        |
{RE_SEMICOLON}    |
{RE_PLUS}         |
{RE_MINUS}        |
{RE_TIMES}        |
{RE_DIV}          |
{RE_TILDE}        |
{RE_LT}           |
{RE_EQUALS}       |
{RE_ATSIGN}       |
{RE_RPAREN}       |
{RE_LPAREN}       |
{RE_RBRACE}       |
{RE_LBRACE}       { return (int)yytext[0]; }

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
  * Object Ids
  */
{RE_OBJECTID} {
    cool_yylval.symbol = idtable.add_string(yytext);
    return (OBJECTID);
}

 /*
  * Type Ids
  */
{RE_TYPEID} {
    cool_yylval.symbol = idtable.add_string(yytext);
    return (TYPEID);
}

{RE_STRING_START} {
    BEGIN(IN_STRING);
    string_length = 0;
    string_escape = 0;
    string_error = 0;
}


 /*
  * Invalid characters are errors where the error message is just the single character
  */
. {
    string_buf[0] = yytext[0];
    string_buf[1] = '\0';
    cool_yylval.error_msg = string_buf;
    return (ERROR);
}

<<EOF>> {
    yyterminate();
}

}

%%
