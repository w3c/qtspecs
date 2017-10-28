
        
import java.util.Stack;
    
%%

%class XQueryLexer
%unicode
%byaccj
%line
%column
%{

        
  public int dumpTableSizes()
  {
	final int sizeOfByte = 1;
	final int sizeOfChar = 2;
	final int sizeOfShort = 2;
	final int sizeOfInt = 4;
	final int sizeOfRef = 4;
	System.out.println("Lexer table sizes");
	
	System.out.println("  yycmap_packed: "+(yycmap_packed.length() * sizeOfChar));
	System.out.println("  yycmap: "+(yycmap.length * sizeOfChar));
	System.out.println("  yy_rowMap: "+(yy_rowMap.length * sizeOfInt));
	System.out.println("  yy_packed0: "+(yy_packed0.length() * sizeOfChar));
	System.out.println("  yytrans: "+(yytrans.length * sizeOfInt));
	System.out.println("  YY_ATTRIBUTE: "+(YY_ATTRIBUTE.length * sizeOfByte));
	System.out.print("        Total lexer table sizes: ");
    int total =
        (yycmap_packed.length() * sizeOfChar)
            + (yycmap.length * sizeOfChar)
            + (yy_rowMap.length * sizeOfInt)
            + (yy_packed0.length() * sizeOfChar)
            + (yytrans.length * sizeOfInt)
            + (YY_ATTRIBUTE.length * sizeOfByte);
              
	System.out.println(total);
	return total;
  }

        
  private Stack stateStack = new Stack();
  static final int PARENMARKER = 2000;
  
  /**
   * Push the current state onto the state stack.
   */
  private void pushState()
  {
	stateStack.addElement(new Integer(yystate()));
  }
  
  /**
   * Push the given state onto the state stack.
   * @param state Must be a valid state.
   */
  private void pushState(int state)
  {
	stateStack.push(new Integer(state));
  }
  
  /**
   * Pop the state on the state stack, and switch to that state.
   */
  private void popState()
  {
	if (stateStack.size() == 0)
	{
	  printLinePos();
	}

	int nextState = ((Integer) stateStack.pop()).intValue();
	if(nextState == PARENMARKER)
	  printLinePos();
	yybegin(nextState);
  }

  /**
   * Print the current line position.
   */
  public void printLinePos()
  {
	System.err.println("Line: " + yyline);
  }
  
  /**
   * Get the current line position.
   */
  public int getLinePos()
  {
	return yyline;
  } 
  
  /**
   * Get the current line position.
   */
  public int getColumnPos()
  {
	return yycolumn;
  }            
           
              
        
  /* store a reference to the parser object */
  private Parser yyparser;

  /* constructor taking an additional parser object */
  public XQueryLexer(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
    yy_lexical_state = DEFAULT;  // Override yy_lexical_state = YYINITIAL;
  }
        
%}

/* Lexical State Declarations */
%state ANY
%state DUMMY
%state DEFAULT
%state OPERATOR
%state NAMESPACEDECL
%state NAMESPACEKEYWORD
%state XMLSPACE_DECL
%state SINGLETYPE
%state ITEMTYPE
%state VALIDATIONCONTEXT
%state KINDTEST
%state KINDTESTFORPI
%state CLOSEKINDTEST
%state OCCURRENCEINDICATOR
%state SCHEMACONTEXTSTEP
%state VARNAME
%state START_TAG
%state ELEMENT_CONTENT
%state END_TAG
%state XML_COMMENT
%state EXPR_COMMENT
%state EXT_CONTENT
%state EXT_KEY
%state EXT_NAME
%state PROCESSING_INSTRUCTION
%state PROCESSING_INSTRUCTION_CONTENT
%state CDATA_SECTION
%state QUOT_ATTRIBUTE_CONTENT
%state APOS_ATTRIBUTE_CONTENT

/* macros */
Digits = ([0-9])+
PredefinedEntityRef = "&"("lt"|"gt"|"amp"|"quot"|"apos")";"
CharRef = "&#"({Digits}|("x"{HexDigits}))";"
StringLiteral = (("\x22"(({PredefinedEntityRef}|{CharRef}|("\x22""\x22")|[^"\x22""&"]))*"\x22")|("'"(({PredefinedEntityRef}|{CharRef}|("'""'")|[^"'""&"]))*"'"))
URLLiteral = (("\x22"(({PredefinedEntityRef}|{CharRef}|("\x22""\x22")|[^"\x22""&"]))*"\x22")|("'"(({PredefinedEntityRef}|{CharRef}|("'""'")|[^"'""&"]))*"'"))
WhitespaceChar = [\t\r\n ]
SchemaGlobalContext = ({QName}|{SchemaGlobalTypeName})
Slash = "/"
QName = ({Prefix}":")?{LocalPart}
SchemaGlobalTypeName = "type"({skip_})*"("({skip_})*{QName}({skip_})*")"
SchemaContextStep = {QName}
NCName = {Nmstart}({Nmchar})*
Letter = ({BaseChar}|{Ideographic})
CombiningChar = [\u0300-\u0345\u0360-\u0361\u0483-\u0486\u0591-\u05a1\u05a3-\u05b9\u05bb-\u05bd\u05bf\u05c1-\u05c2\u05c4\u064b-\u0652\u0670\u06d6-\u06dc\u06dd-\u06df\u06e0-\u06e4\u06e7-\u06e8\u06ea-\u06ed\u0901-\u0903\u093c\u093e-\u094c\u094d\u0951-\u0954\u0962-\u0963\u0981-\u0983\u09bc\u09be\u09bf\u09c0-\u09c4\u09c7-\u09c8\u09cb-\u09cd\u09d7\u09e2-\u09e3\u0a02\u0a3c\u0a3e\u0a3f\u0a40-\u0a42\u0a47-\u0a48\u0a4b-\u0a4d\u0a70-\u0a71\u0a81-\u0a83\u0abc\u0abe-\u0ac5\u0ac7-\u0ac9\u0acb-\u0acd\u0b01-\u0b03\u0b3c\u0b3e-\u0b43\u0b47-\u0b48\u0b4b-\u0b4d\u0b56-\u0b57\u0b82-\u0b83\u0bbe-\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcd\u0bd7\u0c01-\u0c03\u0c3e-\u0c44\u0c46-\u0c48\u0c4a-\u0c4d\u0c55-\u0c56\u0c82-\u0c83\u0cbe-\u0cc4\u0cc6-\u0cc8\u0cca-\u0ccd\u0cd5-\u0cd6\u0d02-\u0d03\u0d3e-\u0d43\u0d46-\u0d48\u0d4a-\u0d4d\u0d57\u0e31\u0e34-\u0e3a\u0e47-\u0e4e\u0eb1\u0eb4-\u0eb9\u0ebb-\u0ebc\u0ec8-\u0ecd\u0f18-\u0f19\u0f35\u0f37\u0f39\u0f3e\u0f3f\u0f71-\u0f84\u0f86-\u0f8b\u0f90-\u0f95\u0f97\u0f99-\u0fad\u0fb1-\u0fb7\u0fb9\u20d0-\u20dc\u20e1\u302a-\u302f\u3099\u309a]
Extender = [\u00b7\u02d0\u02d1\u0387\u0640\u0e46\u0ec6\u3005\u3031-\u3035\u309d-\u309e\u30fc-\u30fe]
Digit = [\u0030-\u0039\u0660-\u0669\u06f0-\u06f9\u0966-\u096f\u09e6-\u09ef\u0a66-\u0a6f\u0ae6-\u0aef\u0b66-\u0b6f\u0be7-\u0bef\u0c66-\u0c6f\u0ce6-\u0cef\u0d66-\u0d6f\u0e50-\u0e59\u0ed0-\u0ed9\u0f20-\u0f29]
VariableIndicator = "$"
ValidationMode = ("lax"|"strict"|"skip")
Nmstart = ({Letter}|"_")
Nmchar = ({Letter}|{CombiningChar}|{Extender}|{Digit}|"."|"-"|"_")
Prefix = {NCName}
LocalPart = {NCName}
HexDigits = ([0-9a-fA-F])+
Char = [\t\r\n\u0020-\uFFFD]
BaseChar = [\u0041-\u005a\u0061-\u007a\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u00ff\u0100-\u0131\u0134-\u013e\u0141-\u0148\u014a-\u017e\u0180-\u01c3\u01cd-\u01f0\u01f4-\u01f5\u01fa-\u0217\u0250-\u02a8\u02bb-\u02c1\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03ce\u03d0-\u03d6\u03da\u03dc\u03de\u03e0\u03e2-\u03f3\u0401-\u040c\u040e-\u044f\u0451-\u045c\u045e-\u0481\u0490-\u04c4\u04c7-\u04c8\u04cb-\u04cc\u04d0-\u04eb\u04ee-\u04f5\u04f8-\u04f9\u0531-\u0556\u0559\u0561-\u0586\u05d0-\u05ea\u05f0-\u05f2\u0621-\u063a\u0641-\u064a\u0671-\u06b7\u06ba-\u06be\u06c0-\u06ce\u06d0-\u06d3\u06d5\u06e5-\u06e6\u0905-\u0939\u093d\u0958-\u0961\u0985-\u098c\u098f-\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09dc-\u09dd\u09df-\u09e1\u09f0-\u09f1\u0a05-\u0a0a\u0a0f-\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32-\u0a33\u0a35-\u0a36\u0a38-\u0a39\u0a59-\u0a5c\u0a5e\u0a72-\u0a74\u0a85-\u0a8b\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2-\u0ab3\u0ab5-\u0ab9\u0abd\u0ae0\u0b05-\u0b0c\u0b0f-\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32-\u0b33\u0b36-\u0b39\u0b3d\u0b5c-\u0b5d\u0b5f-\u0b61\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99-\u0b9a\u0b9c\u0b9e-\u0b9f\u0ba3-\u0ba4\u0ba8-\u0baa\u0bae-\u0bb5\u0bb7-\u0bb9\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c60-\u0c61\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cde\u0ce0-\u0ce1\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d28\u0d2a-\u0d39\u0d60-\u0d61\u0e01-\u0e2e\u0e30\u0e32-\u0e33\u0e40-\u0e45\u0e81-\u0e82\u0e84\u0e87-\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa-\u0eab\u0ead-\u0eae\u0eb0\u0eb2-\u0eb3\u0ebd\u0ec0-\u0ec4\u0f40-\u0f47\u0f49-\u0f69\u10a0-\u10c5\u10d0-\u10f6\u1100\u1102-\u1103\u1105-\u1107\u1109\u110b-\u110c\u110e-\u1112\u113c\u113e\u1140\u114c\u114e\u1150\u1154-\u1155\u1159\u115f-\u1161\u1163\u1165\u1167\u1169\u116d-\u116e\u1172-\u1173\u1175\u119e\u11a8\u11ab\u11ae-\u11af\u11b7-\u11b8\u11ba\u11bc-\u11c2\u11eb\u11f0\u11f9\u1e00-\u1e9b\u1ea0-\u1ef9\u1f00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u2126\u212a-\u212b\u212e\u2180-\u2182\u3041-\u3094\u30a1-\u30fa\u3105-\u312c\uac00-\ud7a3]
Ideographic = [\u4e00-\u9fa5\u3007\u3021-\u3029]

skip_ = ({WhitespaceChar})+

%%

/* Lexical rules */
<DEFAULT, OPERATOR, NAMESPACEDECL, NAMESPACEKEYWORD, XMLSPACE_DECL, ITEMTYPE, VARNAME, EXPR_COMMENT>"(::" { 
pushState(yystate()); 
 yybegin(EXT_KEY);
  /* ignore */ }
<DEFAULT, OPERATOR, NAMESPACEDECL, NAMESPACEKEYWORD, XMLSPACE_DECL, ITEMTYPE, VARNAME, EXPR_COMMENT>"(:" { 
pushState(yystate()); 
 yybegin(EXPR_COMMENT);
  /* ignore */ }
<EXPR_COMMENT>{Char} {  /* ignore */ }
<EXT_CONTENT>{Char} {  /* ignore */ }
<EXT_CONTENT>"::)" { 
popState();  /* ignore */ }
<EXPR_COMMENT>":)" { 
popState();  /* ignore */ }
<EXT_KEY>"pragma" { 
 yybegin(EXT_NAME);
  /* ignore */ }
<EXT_KEY>"extension" { 
 yybegin(EXT_NAME);
  /* ignore */ }
<DEFAULT>"<!--" { 
pushState(OPERATOR); 
 yybegin(XML_COMMENT);
 yyparser.yylval.ival = Parser.XmlCommentStart; 
return Parser.XmlCommentStart;
}
<ELEMENT_CONTENT>"<!--" { 
pushState(yystate()); 
 yybegin(XML_COMMENT);
 yyparser.yylval.ival = Parser.XmlCommentStartForElementContent; 
return Parser.XmlCommentStartForElementContent;
}
<XML_COMMENT>"-->" { 
popState(); yyparser.yylval.ival = Parser.XmlCommentEnd; 
return Parser.XmlCommentEnd;
}
<DEFAULT>{Digits} { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.IntegerLiteral;
}
<DEFAULT>(("."{Digits})|({Digits}"."([0-9])*)) { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.DecimalLiteral;
}
<DEFAULT>(("."{Digits})|({Digits}("."([0-9])*)?))["e""E"](["+""-"])?{Digits} { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.DoubleLiteral;
}
<DEFAULT, OPERATOR>(("\x22"(({PredefinedEntityRef}|{CharRef}|("\x22""\x22")|[^"\x22""&"]))*"\x22")|("'"(({PredefinedEntityRef}|{CharRef}|("'""'")|[^"'""&"]))*"'")) { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.StringLiteral;
}
<KINDTESTFORPI>(("\x22"(({PredefinedEntityRef}|{CharRef}|("\x22""\x22")|[^"\x22""&"]))*"\x22")|("'"(({PredefinedEntityRef}|{CharRef}|("'""'")|[^"'""&"]))*"'")) { yyparser.yylval.ival = Parser.StringLiteralForKindTest; 
return Parser.StringLiteralForKindTest;
}
<DEFAULT>"xquery"({skip_})*"version"({skip_})*{StringLiteral} { yyparser.yylval.ival = Parser.VersionStringLiteral; 
return Parser.VersionStringLiteral;
}
<DEFAULT, ITEMTYPE>"at"({skip_})*{URLLiteral} { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.AtStringLiteral; 
return Parser.AtStringLiteral;
}
<NAMESPACEDECL, NAMESPACEKEYWORD>(("\x22"(({PredefinedEntityRef}|{CharRef}|("\x22""\x22")|[^"\x22""&"]))*"\x22")|("'"(({PredefinedEntityRef}|{CharRef}|("'""'")|[^"'""&"]))*"'")) { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.URLLiteral; 
return Parser.URLLiteral;
}
<DEFAULT>"module"({skip_})*"namespace" { 
 yybegin(NAMESPACEDECL);
 yyparser.yylval.ival = Parser.ModuleNamespace; 
return Parser.ModuleNamespace;
}
<OCCURRENCEINDICATOR>[^"*""?""+"] { 
yypushback(1); 
 yybegin(OPERATOR);
  /* ignore */ }
<START_TAG, END_TAG>({WhitespaceChar})+ { yyparser.yylval.ival = Parser.S; 
return Parser.S;
}
<PROCESSING_INSTRUCTION>({WhitespaceChar})+ { 
 yybegin(PROCESSING_INSTRUCTION_CONTENT);
 yyparser.yylval.ival = Parser.SForPI; 
return Parser.SForPI;
}
<DEFAULT>"<?" { 
pushState(OPERATOR); 
 yybegin(PROCESSING_INSTRUCTION);
 yyparser.yylval.ival = Parser.ProcessingInstructionStart; 
return Parser.ProcessingInstructionStart;
}
<ELEMENT_CONTENT>"<?" { 
pushState(yystate()); 
 yybegin(PROCESSING_INSTRUCTION);
 yyparser.yylval.ival = Parser.ProcessingInstructionStartForElementContent; 
return Parser.ProcessingInstructionStartForElementContent;
}
<PROCESSING_INSTRUCTION, PROCESSING_INSTRUCTION_CONTENT>"?>" { 
popState(); yyparser.yylval.ival = Parser.ProcessingInstructionEnd; 
return Parser.ProcessingInstructionEnd;
}
<DEFAULT>"child"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisChild;
}
<DEFAULT>"descendant"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisDescendant;
}
<DEFAULT>"parent"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisParent;
}
<DEFAULT>"attribute"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisAttribute;
}
<DEFAULT>"self"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisSelf;
}
<DEFAULT>"descendant-or-self"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisDescendantOrSelf;
}
<DEFAULT>"ancestor"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisAncestor;
}
<DEFAULT>"following-sibling"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisFollowingSibling;
}
<DEFAULT>"preceding-sibling"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisPrecedingSibling;
}
<DEFAULT>"following"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisFollowing;
}
<DEFAULT>"preceding"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisPreceding;
}
<DEFAULT>"ancestor-or-self"({skip_})*"::" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AxisAncestorOrSelf;
}
<DEFAULT>"declare"({skip_})+"function" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.DefineFunction; 
return Parser.DefineFunction;
}
<OPERATOR, ITEMTYPE>"external" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.External; 
return Parser.External;
}
<OPERATOR, ITEMTYPE>"or" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Or; 
return Parser.Or;
}
<OPERATOR, ITEMTYPE>"and" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.And; 
return Parser.And;
}
<OPERATOR, ITEMTYPE>"div" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Div; 
return Parser.Div;
}
<OPERATOR, ITEMTYPE>"idiv" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Idiv; 
return Parser.Idiv;
}
<OPERATOR, ITEMTYPE>"mod" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Mod; 
return Parser.Mod;
}
<OPERATOR>"*" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Multiply; 
return Parser.Multiply;
}
<OPERATOR, ITEMTYPE>"in" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.In; 
return Parser.In;
}
<OPERATOR>("lax"|"strict"|"skip") { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.SchemaModeForDeclareValidate; 
return Parser.SchemaModeForDeclareValidate;
}
<CLOSEKINDTEST>"nillable" { yyparser.yylval.ival = Parser.Nillable; 
return Parser.Nillable;
}
<DEFAULT>"declare"({skip_})+"validation" { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.DeclareValidation;
}
<KINDTEST>{SchemaGlobalContext}({skip_})*{Slash} { 
 yybegin(SCHEMACONTEXTSTEP);
 yyparser.yylval.ival = Parser.SchemaGlobalContextSlash; 
return Parser.SchemaGlobalContextSlash;
}
<KINDTEST>"type"({skip_})*"("({skip_})*{QName}({skip_})*")" { 
 yybegin(SCHEMACONTEXTSTEP);
 yyparser.yylval.ival = Parser.SchemaGlobalTypeName; 
return Parser.SchemaGlobalTypeName;
}
<SCHEMACONTEXTSTEP>{SchemaContextStep}({skip_})*{Slash} { yyparser.yylval.ival = Parser.SchemaContextStepSlash; 
return Parser.SchemaContextStepSlash;
}
<VALIDATIONCONTEXT>"context" { 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.InContextForKindTest; 
return Parser.InContextForKindTest;
}
<VALIDATIONCONTEXT>"global" { 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.Global; 
return Parser.Global;
}
<OPERATOR, ITEMTYPE>"satisfies" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Satisfies; 
return Parser.Satisfies;
}
<OPERATOR, ITEMTYPE>"return" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Return; 
return Parser.Return;
}
<OPERATOR, ITEMTYPE>"then" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Then; 
return Parser.Then;
}
<OPERATOR, ITEMTYPE>"else" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Else; 
return Parser.Else;
}
<OPERATOR>"default" { yyparser.yylval.ival = Parser.Default; 
return Parser.Default;
}
<DEFAULT>"declare"({skip_})+"xmlspace" { 
 yybegin(XMLSPACE_DECL);
 yyparser.yylval.ival = Parser.DeclareXMLSpace; 
return Parser.DeclareXMLSpace;
}
<DEFAULT>"declare"({skip_})+"base-uri" { 
 yybegin(NAMESPACEDECL);
 yyparser.yylval.ival = Parser.DeclareBaseURI; 
return Parser.DeclareBaseURI;
}
<XMLSPACE_DECL>"preserve" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.XMLSpacePreserve; 
return Parser.XMLSpacePreserve;
}
<XMLSPACE_DECL>"strip" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.XMLSpaceStrip; 
return Parser.XMLSpaceStrip;
}
<NAMESPACEKEYWORD>"namespace" { 
 yybegin(NAMESPACEDECL);
 yyparser.yylval.ival = Parser.Namespace; 
return Parser.Namespace;
}
<DEFAULT>"declare"({skip_})+"namespace" { 
 yybegin(NAMESPACEDECL);
 yyparser.yylval.ival = Parser.DeclareNamespace; 
return Parser.DeclareNamespace;
}
<OPERATOR, ITEMTYPE>"to" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.To; 
return Parser.To;
}
<OPERATOR, ITEMTYPE>"where" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Where; 
return Parser.Where;
}
<OPERATOR>"collation" { yyparser.yylval.ival = Parser.Collation; 
return Parser.Collation;
}
<OPERATOR, ITEMTYPE>"intersect" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Intersect; 
return Parser.Intersect;
}
<OPERATOR, ITEMTYPE>"union" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Union; 
return Parser.Union;
}
<OPERATOR, ITEMTYPE>"except" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Except; 
return Parser.Except;
}
<OPERATOR, ITEMTYPE>"as" { 
 yybegin(ITEMTYPE);
 yyparser.yylval.ival = Parser.As; 
return Parser.As;
}
<OPERATOR, ITEMTYPE>"at" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.AtWord; 
return Parser.AtWord;
}
<OPERATOR, ITEMTYPE>"case" { 
 yybegin(ITEMTYPE);
 yyparser.yylval.ival = Parser.Case; 
return Parser.Case;
}
<OPERATOR, ITEMTYPE>"instance"({skip_})+"of" { 
 yybegin(ITEMTYPE);
 yyparser.yylval.ival = Parser.Instanceof; 
return Parser.Instanceof;
}
<OPERATOR, ITEMTYPE>"castable"({skip_})+"as" { 
 yybegin(SINGLETYPE);
 yyparser.yylval.ival = Parser.Castable; 
return Parser.Castable;
}
<DEFAULT, OPERATOR, ITEMTYPE>")"({skip_})*"as" { 
 yybegin(ITEMTYPE);
 yyparser.yylval.ival = Parser.RparAs; 
return Parser.RparAs;
}
<ITEMTYPE>"item"({skip_})*"("({skip_})*")" { 
 yybegin(OCCURRENCEINDICATOR);
 yyparser.yylval.ival = Parser.Item; 
return Parser.Item;
}
<DEFAULT>"element"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.ElementType; 
return Parser.ElementType;
}
<DEFAULT>"attribute"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.AttributeType; 
return Parser.AttributeType;
}
<DEFAULT>"element"({skip_})+{QName}({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.ElementQNameLbrace; 
return Parser.ElementQNameLbrace;
}
<DEFAULT>"attribute"({skip_})+{QName}({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.AttributeQNameLbrace; 
return Parser.AttributeQNameLbrace;
}
<DEFAULT>("namespace"(({skip_})+{NCName})?({skip_})*"{") { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.NamespaceNCNameLbrace; 
return Parser.NamespaceNCNameLbrace;
}
<DEFAULT>"processing-instruction"({skip_})+{NCName}({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.PINCNameLbrace; 
return Parser.PINCNameLbrace;
}
<DEFAULT>"processing-instruction"({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.PILbrace; 
return Parser.PILbrace;
}
<DEFAULT>"comment"({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.CommentLbrace; 
return Parser.CommentLbrace;
}
<DEFAULT>"element"({skip_})*"{" { 
pushState(OPERATOR); 
pushState(DEFAULT); yyparser.yylval.ival = Parser.ElementLbrace; 
return Parser.ElementLbrace;
}
<DEFAULT>"attribute"({skip_})*"{" { 
pushState(OPERATOR); 
pushState(DEFAULT); yyparser.yylval.ival = Parser.AttributeLbrace; 
return Parser.AttributeLbrace;
}
<DEFAULT>"text"({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.TextLbrace; 
return Parser.TextLbrace;
}
<DEFAULT>"declare"({skip_})+"default"({skip_})+"collation" { 
 yybegin(NAMESPACEDECL);
 yyparser.yylval.ival = Parser.DeclareCollation; 
return Parser.DeclareCollation;
}
<NAMESPACEKEYWORD>"default"({skip_})+"element" { yyparser.yylval.ival = Parser.DefaultElement; 
return Parser.DefaultElement;
}
<DEFAULT>"declare"({skip_})+"default"({skip_})+"element" { 
 yybegin(NAMESPACEKEYWORD);
 yyparser.yylval.ival = Parser.DeclareDefaultElement; 
return Parser.DeclareDefaultElement;
}
<DEFAULT>"declare"({skip_})+"default"({skip_})+"function" { 
 yybegin(NAMESPACEKEYWORD);
 yyparser.yylval.ival = Parser.DeclareDefaultFunction; 
return Parser.DeclareDefaultFunction;
}
<ITEMTYPE>"empty"({skip_})*"("({skip_})*")" { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.EmptyTok; 
return Parser.EmptyTok;
}
<DEFAULT>"import"({skip_})+"schema" { 
 yybegin(NAMESPACEKEYWORD);
 yyparser.yylval.ival = Parser.ImportSchemaToken; 
return Parser.ImportSchemaToken;
}
<DEFAULT>"import"({skip_})+"module" { 
 yybegin(NAMESPACEKEYWORD);
 yyparser.yylval.ival = Parser.ImportModuleToken; 
return Parser.ImportModuleToken;
}
<DEFAULT>"*" { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.Star;
}
<KINDTEST>"*" { 
 yybegin(CLOSEKINDTEST);
 yyparser.yylval.ival = Parser.AnyName; 
return Parser.AnyName;
}
<DEFAULT>{NCName}":""*" { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.NCNameColonStar;
}
<DEFAULT>"*"":"{NCName} { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.StarColonNCName;
}
<DEFAULT>"/" { yyparser.yylval.ival = Parser.Root; 
return Parser.Root;
}
<DEFAULT>"//" { yyparser.yylval.ival = Parser.RootDescendants; 
return Parser.RootDescendants;
}
<OPERATOR>"/" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Slash; 
return Parser.Slash;
}
<OPERATOR>"//" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.SlashSlash; 
return Parser.SlashSlash;
}
<OPERATOR, ITEMTYPE>"=" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Equals; 
return Parser.Equals;
}
<NAMESPACEDECL>"=" { yyparser.yylval.ival = Parser.AssignEquals; 
return Parser.AssignEquals;
}
<OPERATOR, ITEMTYPE>"is" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Is; 
return Parser.Is;
}
<OPERATOR, ITEMTYPE>"!=" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.NotEquals; 
return Parser.NotEquals;
}
<OPERATOR, ITEMTYPE>"<=" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.LtEquals; 
return Parser.LtEquals;
}
<OPERATOR, ITEMTYPE>"<<" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.LtLt; 
return Parser.LtLt;
}
<OPERATOR, ITEMTYPE>">=" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.GtEquals; 
return Parser.GtEquals;
}
<OPERATOR, ITEMTYPE>">>" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.GtGt; 
return Parser.GtGt;
}
<OPERATOR, ITEMTYPE>"eq" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranEq; 
return Parser.FortranEq;
}
<OPERATOR, ITEMTYPE>"ne" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranNe; 
return Parser.FortranNe;
}
<OPERATOR, ITEMTYPE>"gt" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranGt; 
return Parser.FortranGt;
}
<OPERATOR, ITEMTYPE>"ge" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranGe; 
return Parser.FortranGe;
}
<OPERATOR, ITEMTYPE>"lt" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranLt; 
return Parser.FortranLt;
}
<OPERATOR, ITEMTYPE>"le" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.FortranLe; 
return Parser.FortranLe;
}
<OPERATOR, ITEMTYPE>":=" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.ColonEquals; 
return Parser.ColonEquals;
}
<OPERATOR, ITEMTYPE>"<" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Lt; 
return Parser.Lt;
}
<OPERATOR, ITEMTYPE>">" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Gt; 
return Parser.Gt;
}
<OPERATOR, ITEMTYPE>"-" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Minus; 
return Parser.Minus;
}
<OPERATOR>"+" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Plus; 
return Parser.Plus;
}
<DEFAULT>"-" { yyparser.yylval.ival = Parser.UnaryMinus; 
return Parser.UnaryMinus;
}
<DEFAULT>"+" { yyparser.yylval.ival = Parser.UnaryPlus; 
return Parser.UnaryPlus;
}
<OPERATOR, OCCURRENCEINDICATOR>"?" { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.OccurrenceZeroOrOne; 
return Parser.OccurrenceZeroOrOne;
}
<OCCURRENCEINDICATOR>"*" { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.OccurrenceZeroOrMore; 
return Parser.OccurrenceZeroOrMore;
}
<OCCURRENCEINDICATOR>"+" { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.OccurrenceOneOrMore; 
return Parser.OccurrenceOneOrMore;
}
<OPERATOR, ITEMTYPE>"|" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Vbar; 
return Parser.Vbar;
}
<DEFAULT, ITEMTYPE>"(" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Lpar; 
return Parser.Lpar;
}
<DEFAULT>"@" { yyparser.yylval.ival = Parser.At; 
return Parser.At;
}
<OPERATOR, ITEMTYPE>"[" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Lbrack; 
return Parser.Lbrack;
}
<OPERATOR>"]" { yyparser.yylval.ival = Parser.Rbrack; 
return Parser.Rbrack;
}
<DEFAULT, OPERATOR>")" { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.Rpar; 
return Parser.Rpar;
}
<KINDTEST, KINDTESTFORPI, CLOSEKINDTEST>")" { 
popState(); yyparser.yylval.ival = Parser.RparForKindTest; 
return Parser.RparForKindTest;
}
<DEFAULT>"some"({skip_})*{VariableIndicator} { 
 yybegin(VARNAME);
 yyparser.yylval.ival = Parser.Some; 
return Parser.Some;
}
<DEFAULT>"every"({skip_})*{VariableIndicator} { 
 yybegin(VARNAME);
 yyparser.yylval.ival = Parser.Every; 
return Parser.Every;
}
<DEFAULT, OPERATOR>"for"({skip_})*{VariableIndicator} { 
 yybegin(VARNAME);
 yyparser.yylval.ival = Parser.ForVariable; 
return Parser.ForVariable;
}
<DEFAULT, OPERATOR>"let"({skip_})*{VariableIndicator} { 
 yybegin(VARNAME);
 yyparser.yylval.ival = Parser.LetVariable; 
return Parser.LetVariable;
}
<OPERATOR, ITEMTYPE>"cast"({skip_})+"as" { 
 yybegin(SINGLETYPE);
 yyparser.yylval.ival = Parser.CastAs; 
return Parser.CastAs;
}
<OPERATOR, ITEMTYPE>"treat"({skip_})+"as" { 
 yybegin(ITEMTYPE);
 yyparser.yylval.ival = Parser.TreatAs; 
return Parser.TreatAs;
}
<DEFAULT>"validate"({skip_})*"{" { 
pushState(OPERATOR); 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.ValidateLbrace; 
return Parser.ValidateLbrace;
}
<DEFAULT>"validate"({skip_})+"context" { 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.ValidateContext; 
return Parser.ValidateContext;
}
<DEFAULT>"validate"({skip_})+"global" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.ValidateGlobal; 
return Parser.ValidateGlobal;
}
<DEFAULT>"validate"({skip_})+{ValidationMode} { 
 yybegin(VALIDATIONCONTEXT);
 yyparser.yylval.ival = Parser.ValidateSchemaMode; 
return Parser.ValidateSchemaMode;
}
<DEFAULT>"document-node"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.DocumentLpar; 
return Parser.DocumentLpar;
}
<ITEMTYPE>"document-node"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.DocumentLparForKindTest; 
return Parser.DocumentLparForKindTest;
}
<DEFAULT>"document"({skip_})*"{" { 
pushState(OPERATOR); yyparser.yylval.ival = Parser.DocumentLbrace; 
return Parser.DocumentLbrace;
}
<DEFAULT>"node"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.NodeLpar; 
return Parser.NodeLpar;
}
<DEFAULT>"comment"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.CommentLpar; 
return Parser.CommentLpar;
}
<DEFAULT>"text"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.TextLpar; 
return Parser.TextLpar;
}
<DEFAULT>"processing-instruction"({skip_})*"(" { 
pushState(OPERATOR); 
 yybegin(KINDTESTFORPI);
 yyparser.yylval.ival = Parser.ProcessingInstructionLpar; 
return Parser.ProcessingInstructionLpar;
}
<ITEMTYPE>"element"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.ElementTypeForKindTest; 
return Parser.ElementTypeForKindTest;
}
<KINDTEST>"element"({skip_})*"(" { 
pushState(KINDTEST); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.ElementTypeForDocumentTest; 
return Parser.ElementTypeForDocumentTest;
}
<ITEMTYPE>"attribute"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.AttributeTypeForKindTest; 
return Parser.AttributeTypeForKindTest;
}
<ITEMTYPE>"processing-instruction"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTESTFORPI);
 yyparser.yylval.ival = Parser.ProcessingInstructionLparForKindTest; 
return Parser.ProcessingInstructionLparForKindTest;
}
<ITEMTYPE>"text"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.TextLparForKindTest; 
return Parser.TextLparForKindTest;
}
<ITEMTYPE>"comment"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.CommentLparForKindTest; 
return Parser.CommentLparForKindTest;
}
<ITEMTYPE>"node"({skip_})*"(" { 
pushState(OCCURRENCEINDICATOR); 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.NodeLparForKindTest; 
return Parser.NodeLparForKindTest;
}
<DEFAULT>"if"({skip_})*"(" { yyparser.yylval.ival = Parser.IfLpar; 
return Parser.IfLpar;
}
<DEFAULT>"typeswitch"({skip_})*"(" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.TypeswitchLpar; 
return Parser.TypeswitchLpar;
}
<DEFAULT, OPERATOR, ITEMTYPE>"," { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Comma; 
return Parser.Comma;
}
<CLOSEKINDTEST>"," { 
 yybegin(KINDTEST);
 yyparser.yylval.ival = Parser.CommaForKindTest; 
return Parser.CommaForKindTest;
}
<DEFAULT, OPERATOR, ITEMTYPE>";" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.SemiColon; 
return Parser.SemiColon;
}
<DEFAULT, OPERATOR>"%%%" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.QuerySeparator; 
return Parser.QuerySeparator;
}
<QUOT_ATTRIBUTE_CONTENT>("\x22""\x22") { yyparser.yylval.ival = Parser.EscapeQuot; 
return Parser.EscapeQuot;
}
<START_TAG>"\x22" { 
 yybegin(QUOT_ATTRIBUTE_CONTENT);
 yyparser.yylval.ival = Parser.OpenQuot; 
return Parser.OpenQuot;
}
<QUOT_ATTRIBUTE_CONTENT>"\x22" { 
 yybegin(START_TAG);
 yyparser.yylval.ival = Parser.CloseQuot; 
return Parser.CloseQuot;
}
<DEFAULT>"." { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.Dot; 
return Parser.Dot;
}
<DEFAULT>".." { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.DotDot; 
return Parser.DotDot;
}
<OPERATOR, ITEMTYPE>"order"({skip_})+"by" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.OrderBy; 
return Parser.OrderBy;
}
<OPERATOR, ITEMTYPE>"stable"({skip_})+"order"({skip_})+"by" { 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.OrderByStable; 
return Parser.OrderByStable;
}
<OPERATOR>"ascending" { yyparser.yylval.ival = Parser.Ascending; 
return Parser.Ascending;
}
<OPERATOR>"descending" { yyparser.yylval.ival = Parser.Descending; 
return Parser.Descending;
}
<OPERATOR>"empty"({skip_})+"greatest" { yyparser.yylval.ival = Parser.EmptyGreatest; 
return Parser.EmptyGreatest;
}
<OPERATOR>"empty"({skip_})+"least" { yyparser.yylval.ival = Parser.EmptyLeast; 
return Parser.EmptyLeast;
}
<PROCESSING_INSTRUCTION>{NCName} { yyparser.yylval.sval = yyparser.yytext; 
return Parser.PITarget;
}
<DEFAULT, OPERATOR, ITEMTYPE>"$" { 
 yybegin(VARNAME);
 yyparser.yylval.ival = Parser.VariableIndicator; 
return Parser.VariableIndicator;
}
<VARNAME>{QName} { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.VarName;
}
<DEFAULT>"declare"({skip_})+"variable"({skip_})*{VariableIndicator} { 
 yybegin(VARNAME);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.DefineVariable;
}
<ITEMTYPE>({Prefix}":")?{LocalPart} { 
 yybegin(OCCURRENCEINDICATOR);
 yyparser.yylval.ival = Parser.QNameForSequenceType; 
return Parser.QNameForSequenceType;
}
<SINGLETYPE>({Prefix}":")?{LocalPart} { 
 yybegin(OPERATOR);
 yyparser.yylval.ival = Parser.QNameForAtomicType; 
return Parser.QNameForAtomicType;
}
<KINDTEST, SCHEMACONTEXTSTEP>({Prefix}":")?{LocalPart} { 
 yybegin(CLOSEKINDTEST);
 yyparser.yylval.ival = Parser.QNameForItemType; 
return Parser.QNameForItemType;
}
<EXT_NAME>({Prefix}":")?{LocalPart} { 
 yybegin(EXT_CONTENT);
  /* ignore */ }
<DEFAULT>({Prefix}":")?{LocalPart} { 
 yybegin(OPERATOR);
 yyparser.yylval.sval = yyparser.yytext; 
return Parser.QName;
}
<DEFAULT>{QName}({skip_})*"(" { yyparser.yylval.sval = yyparser.yytext; 
return Parser.QNameLpar;
}
<NAMESPACEDECL>{Nmstart}({Nmchar})* { yyparser.yylval.ival = Parser.NCNameForPrefix; 
return Parser.NCNameForPrefix;
}
<KINDTESTFORPI>{Nmstart}({Nmchar})* { yyparser.yylval.ival = Parser.NCNameForPI; 
return Parser.NCNameForPI;
}
<DEFAULT>"<![CDATA[" { 
pushState(OPERATOR); 
 yybegin(CDATA_SECTION);
 yyparser.yylval.ival = Parser.CdataSectionStart; 
return Parser.CdataSectionStart;
}
<ELEMENT_CONTENT>"<![CDATA[" { 
pushState(yystate()); 
 yybegin(CDATA_SECTION);
 yyparser.yylval.ival = Parser.CdataSectionStartForElementContent; 
return Parser.CdataSectionStartForElementContent;
}
<CDATA_SECTION>"]]>" { 
popState(); yyparser.yylval.ival = Parser.CdataSectionEnd; 
return Parser.CdataSectionEnd;
}
<ELEMENT_CONTENT, QUOT_ATTRIBUTE_CONTENT, APOS_ATTRIBUTE_CONTENT>"&"("lt"|"gt"|"amp"|"quot"|"apos")";" { yyparser.yylval.ival = Parser.PredefinedEntityRef; 
return Parser.PredefinedEntityRef;
}
<ELEMENT_CONTENT, QUOT_ATTRIBUTE_CONTENT, APOS_ATTRIBUTE_CONTENT>"&#"({Digits}|("x"{HexDigits}))";" { yyparser.yylval.ival = Parser.CharRef; 
return Parser.CharRef;
}
<ELEMENT_CONTENT>"<" { 
pushState(yystate()); 
 yybegin(START_TAG);
 yyparser.yylval.ival = Parser.StartTagOpen; 
return Parser.StartTagOpen;
}
<DEFAULT>"<" { 
pushState(OPERATOR); 
 yybegin(START_TAG);
 yyparser.yylval.ival = Parser.StartTagOpenRoot; 
return Parser.StartTagOpenRoot;
}
<START_TAG>">" { 
 yybegin(ELEMENT_CONTENT);
 yyparser.yylval.ival = Parser.StartTagClose; 
return Parser.StartTagClose;
}
<START_TAG>"/>" { 
popState(); yyparser.yylval.ival = Parser.EmptyTagClose; 
return Parser.EmptyTagClose;
}
<ELEMENT_CONTENT>"</" { 
 yybegin(END_TAG);
 yyparser.yylval.ival = Parser.EndTagOpen; 
return Parser.EndTagOpen;
}
<END_TAG>">" { 
popState(); yyparser.yylval.ival = Parser.EndTagClose; 
return Parser.EndTagClose;
}
<START_TAG>"=" { yyparser.yylval.ival = Parser.ValueIndicator; 
return Parser.ValueIndicator;
}
<START_TAG, END_TAG>{QName} { yyparser.yylval.ival = Parser.TagQName; 
return Parser.TagQName;
}
<ELEMENT_CONTENT, QUOT_ATTRIBUTE_CONTENT, APOS_ATTRIBUTE_CONTENT>"{" { 
pushState(yystate()); 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.Lbrace; 
return Parser.Lbrace;
}
<DEFAULT, OPERATOR, VALIDATIONCONTEXT, KINDTEST, CLOSEKINDTEST, SCHEMACONTEXTSTEP>"{" { 
pushState(OPERATOR); 
 yybegin(DEFAULT);
 yyparser.yylval.ival = Parser.LbraceExprEnclosure; 
return Parser.LbraceExprEnclosure;
}
<ELEMENT_CONTENT, QUOT_ATTRIBUTE_CONTENT, APOS_ATTRIBUTE_CONTENT>"{{" { yyparser.yylval.ival = Parser.LCurlyBraceEscape; 
return Parser.LCurlyBraceEscape;
}
<ELEMENT_CONTENT, QUOT_ATTRIBUTE_CONTENT, APOS_ATTRIBUTE_CONTENT>"}}" { yyparser.yylval.ival = Parser.RCurlyBraceEscape; 
return Parser.RCurlyBraceEscape;
}
<APOS_ATTRIBUTE_CONTENT>"''" { yyparser.yylval.ival = Parser.EscapeApos; 
return Parser.EscapeApos;
}
<START_TAG>"'" { 
 yybegin(APOS_ATTRIBUTE_CONTENT);
 yyparser.yylval.ival = Parser.OpenApos; 
return Parser.OpenApos;
}
<APOS_ATTRIBUTE_CONTENT>"'" { 
 yybegin(START_TAG);
 yyparser.yylval.ival = Parser.CloseApos; 
return Parser.CloseApos;
}
<ELEMENT_CONTENT>{Char} { yyparser.yylval.sval = yyparser.yytext; 
return Parser.ElementContentChar;
}
<QUOT_ATTRIBUTE_CONTENT>{Char} { yyparser.yylval.sval = yyparser.yytext; 
return Parser.QuotAttContentChar;
}
<APOS_ATTRIBUTE_CONTENT>{Char} { yyparser.yylval.sval = yyparser.yytext; 
return Parser.AposAttContentChar;
}
<XML_COMMENT>[\t\r\n\u0020-\uFFFD] { yyparser.yylval.ival = Parser.CommentContentChar; 
return Parser.CommentContentChar;
}
<PROCESSING_INSTRUCTION_CONTENT>[\t\r\n\u0020-\uFFFD] { yyparser.yylval.ival = Parser.PIContentChar; 
return Parser.PIContentChar;
}
<CDATA_SECTION>[\t\r\n\u0020-\uFFFD] { yyparser.yylval.ival = Parser.CDataSectionChar; 
return Parser.CDataSectionChar;
}
<DEFAULT, OPERATOR>"}" { 
popState(); yyparser.yylval.ival = Parser.Rbrace; 
return Parser.Rbrace;
}
<DEFAULT, OPERATOR, NAMESPACEDECL, XMLSPACE_DECL, SINGLETYPE, ITEMTYPE, NAMESPACEKEYWORD, VARNAME, OCCURRENCEINDICATOR, CLOSEKINDTEST, SCHEMACONTEXTSTEP, KINDTEST, VALIDATIONCONTEXT, EXT_KEY, EXT_NAME>({WhitespaceChar})+ { /* ignore */ }