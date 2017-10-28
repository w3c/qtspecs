<?xml version="1.0"?>
<!--
 * Copyright (c) 2002 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<!-- Stylesheet to translate a document that conforms to grammar.dtd
     into a yacc file.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://www.w3.org/2001/03/XPath/grammar">

    <!-- Many of the constructs for the yaccification are the same as
       for lex, so we essentially derive from that stylesheet. -->
    <xsl:import href="lex.xsl"/>

    <!-- The root element template, which will be matched first. -->
    <xsl:template match="g:grammar">
        <xsl:call-template name="definitions"/>
        <xsl:call-template name="rules"/>
        <xsl:call-template name="user-code"/>
    </xsl:template>

    <!-- Default command line function -->
    <xsl:template name="command-line-main"><!--
        <xsl:text><![CDATA[extern FILE *yyin;
extern void initXPathScanner(char*, int len);

int main(int c, char **v)
{
  int maxsz = 1028*4;
  char* buf = (char*)malloc(maxsz+1);
  int bufPos = 0;
  char ch;

  fprintf(stdout, "]]></xsl:text>
        <xsl:value-of select="$spec"/>
        <xsl:text><![CDATA[ parser!");

  yydebug=0;

  while(1) {
    fprintf(stdout, "\nEnter expression:\n");

  while(((ch = fgetc(stdin)) != '\n') && (bufPos < maxsz))
    {
      buf[bufPos++] = ch;
    }
    buf[bufPos] = '\0';

    if(0 == bufPos)
      break;

    initXPathScanner(buf, bufPos);
    yyparse();
    bufPos = 0;
  }

  return 0;
}
]]></xsl:text>
    --></xsl:template>

  <xsl:template name="literal-block">
    <xsl:text>%{&#10;</xsl:text>
    <xsl:call-template name="includes"/>
    <xsl:call-template name="decls"/>
    <xsl:text>&#10;%}&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="additional-user-code"/>

  <!-- Template for user code. -->
  <xsl:template name="user-code">
        <xsl:call-template name="command-line-main"/>
        <xsl:call-template name="additional-user-code"/>
        <!--<xsl:text>char* getProdName(int i) { return
            (char*)yytname[YYTRANSLATE(i)]; } int yyerror(char *s) {
            fprintf(stdout, "ERROR! %s\n", s); return 0; } int yywrap() {
            return 1; } </xsl:text>-->
        <xsl:text>
<![CDATA[
  /* a reference to the lexer object */
  private XQueryLexer lexer;

  /* interface to the lexer */
  private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
    }
    catch (java.io.IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }

    String _error = null;

    /* error reporting */
    public void yyerror(String error) {
        _error = error;
        System.out.flush();
        System.err.println("XQuery Syntax Error: " + error);
        System.err.println(
            "Current lexer position: line #"
                + (lexer.getLinePos()+1)
                + ", column #"
                + lexer.getColumnPos());
        System.err.print("yychar is "+yychar);
        if(yychar >= 0 && yychar < yyname.length)
        {
            System.err.print(", ");
            System.err.print(yyname[yychar]);
        }
        System.err.println();
        System.err.println("============");
        System.err.flush();
        System.out.println();
        System.out.flush();
    }

  /* lexer is created in the constructor */
  public Parser(java.io.Reader r) {
    lexer = new XQueryLexer(r, this);
  }

  public int dumpTableSizes()
  {
    final int sizeOfByte = 1;
    final int sizeOfChar = 2;
    final int sizeOfShort = 2;
    final int sizeOfInt = 4;
    final int sizeOfRef = 4;
    System.out.println("Parser table sizes");

    System.out.println("  yylhs: "+(yylhs.length * sizeOfShort));
    System.out.println("  yylen: "+(yylen.length * sizeOfShort));
    System.out.println("  yydefred: "+(yydefred.length * sizeOfShort));
    System.out.println("  yydgoto: "+(yydgoto.length * sizeOfShort));
    System.out.println("  yysindex: "+(yysindex.length * sizeOfShort));
    System.out.println("  yyrindex: "+(yyrindex.length * sizeOfShort));
    System.out.println("  yygindex: "+(yygindex.length * sizeOfShort));
    System.out.println("  yytable: "+(yytable.length * sizeOfShort));
    System.out.println("  yycheck: "+(yycheck.length * sizeOfShort));
    System.out.println("  yyname: "+(yyname.length * sizeOfRef));
    System.out.println("  yyrule: "+(yyrule.length * sizeOfRef));
    System.out.print("        Total parser table sizes: ");
    int total = (
        ((yylhs.length
            + yylen.length
            + yydefred.length
            + yydgoto.length
            + yysindex.length
            + yyrindex.length
            + yygindex.length
            + yytable.length
            + yycheck.length)
            * sizeOfShort)
            + ((yyname.length + yyrule.length) * sizeOfRef));

    System.out.println(total);
    return total;
  }


/* Command line function for testing. */
public static void main(String args[]) throws java.io.IOException {
    int positionIndicator = -1;
    try {

        String filename = null;
        boolean dumpTree = false;
        boolean echo = false;
        String expression = null;
        boolean isQueryFile = false;
        java.util.Vector expressionStrings = new java.util.Vector();
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-sizes")) {
                Parser dummyParser = new Parser(new StringReader("foo"));
                int parseSizes = dummyParser.dumpTableSizes();
                int lexerSizes = dummyParser.lexer.dumpTableSizes();
                System.out.println("total static table sizes: "+(parseSizes+lexerSizes)+" bytes");
                System.out.println("                          "+((parseSizes+lexerSizes)/1024)+" k");
            }
            else if (args[i].equals("-dump")) {
                dumpTree = true;
            }
            else if (args[i].equals("-echo")) {
                echo = true;
            }
            else if (args[i].equals("-f")) {
                i++;
                filename = args[i];
            }
            else if (args[i].endsWith(".xquery")) {
                filename = args[i];
                isQueryFile = true;
            }
            else
            {
                expressionStrings.add(args[i]);
            }
        }
        Parser yyparser = null;

        for (java.util.Iterator iter = expressionStrings.iterator(); iter.hasNext();) {
            String path = (String) iter.next();
            positionIndicator++;
            yyparser = new Parser(new StringReader(path));
            // yyparser.yydebug=true;
            yyparser.yyparse();
            SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
            if (dumpTree)
                tree.dump("|");
        }

        if (null != filename) {
            if (filename.endsWith(".xquery") || filename.endsWith(".xq")) {
                System.out.println("Running test for: " + filename);
                File file = new File(filename);
                FileInputStream fis = new FileInputStream(file);
                yyparser = new Parser(new InputStreamReader(fis));
                // yyparser.yydebug=true;
                yyparser.yyparse();
                SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
                if (dumpTree)
                    tree.dump("|");
            }
            else {
                DocumentBuilderFactory dbf =
                    DocumentBuilderFactory.newInstance();
                DocumentBuilder db = dbf.newDocumentBuilder();
                Document doc = db.parse(filename);
                Element tests = doc.getDocumentElement();
                NodeList testElems = tests.getChildNodes();
                int nChildren = testElems.getLength();
                int testid = 0;
                for (int i = 0; i < nChildren; i++) {
                    positionIndicator = i;
                    org.w3c.dom.Node node = testElems.item(i);
                    if (org.w3c.dom.Node.ELEMENT_NODE == node.getNodeType()) {
                        testid++;
                        String xpathString =
                            ((Element) node).getAttribute("value");
                        if (dumpTree || echo)
                            System.out.println(
                                "Test[" + testid + "]: " + xpathString);
                        yyparser = new Parser(new StringReader(xpathString));
                        yyparser.yyparse();
                        SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
                        if (dumpTree)
                            tree.dump("|");
                    }
                }
            }
        }
        if ((yyparser != null) && (null == yyparser._error))
            System.out.println("Test successful!!!");
    }
    catch (Exception e) {
        System.out.println(e.getMessage());
        e.printStackTrace();
        if(positionIndicator >= 0)
            System.out.println("positionIndicator: "+positionIndicator);
    }
}
]]>
        </xsl:text>
    </xsl:template>

    <!-- Definitions occur before the rules section. It can include
       a literal block, and there may also be %union, %start, %token,
       %type, %left, %right, and %nonassoc declarations. -->
    <xsl:template name="definitions">
        <xsl:call-template name="literal-block"/>
        <xsl:call-template name="decls-start"/>
        <xsl:call-template name="decls-union"/>
        <xsl:call-template name="decls-type"/>
        <xsl:call-template name="decls-tokens"/>
    </xsl:template>

    <!-- The rules section contains pattern lines and C code.  A line
       that starts with whitespace, or material enclosed in %{ and %} is
       C code.  A line that starts with anything else is a pattern line. -->
    <xsl:template name="rules">
        <xsl:text>&#10;%%&#10;</xsl:text>
        <xsl:variable name="non-terminals"
            select="g:production  |
              g:exprProduction/g:level/*"/>
              <!-- g:exprProduction | -->
        <xsl:for-each select="$non-terminals">
            <xsl:value-of select="@name"/>
            <xsl:text>: </xsl:text>
            <xsl:apply-templates select=".">
                <xsl:with-param name="prod-name" select="@name"/>
            </xsl:apply-templates>
            <xsl:text>;&#10;&#10;</xsl:text>
        </xsl:for-each>
        <!-- This next section constructs all the rules we have to
         "manufacture", that can not be represented in yacc by things like
         (foo)*.-->
        <xsl:variable name="non-terminal-productions"
            select="g:production  |
              g:exprProduction/g:level/*
              "/>
        <xsl:variable name="manufactured-rules"
            select="($non-terminal-productions//g:zeroOrMore
              | $non-terminal-productions//g:oneOrMore
              | $non-terminal-productions//g:optional
              | $non-terminal-productions//g:choice)
              [child::*]"/>
        <xsl:call-template name="declare-unique-manufactured-rules">
            <xsl:with-param name="refs" select="$manufactured-rules"/>
        </xsl:call-template>
        <xsl:text>&#10;%%&#10;</xsl:text>
    </xsl:template>

    <!-- Declare the unique manufactured rules. -->
    <xsl:template name="declare-unique-manufactured-rules">
        <xsl:param name="refs"/>
        <!-- required, list of nodes to make
                                  manufactured rules for. -->
        <xsl:param name="node-index" select="1"/>
        <xsl:param name="refs-str" select="''"/>
        <xsl:param name="last" select="count($refs)"/>
        <xsl:if test="$node-index &lt;= $last">
            <xsl:variable name="m-rule-node" select="$refs[$node-index]"/>
            <xsl:variable name="m-name">
                <xsl:for-each select="$m-rule-node">
                    <xsl:call-template
                        name="manufactured-recursive-production-name"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="m-name-padded">
                <xsl:text>
                </xsl:text>
                <xsl:value-of select="$m-name"/>
                <xsl:text>
                </xsl:text>
            </xsl:variable>
            <xsl:if test="not(contains($refs-str, $m-name-padded))">
                <xsl:apply-templates select="$m-rule-node"
                    mode="manufactured-rules">
                    <xsl:with-param name="prod-name" select="$m-name"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:call-template name="declare-unique-manufactured-rules">
                <xsl:with-param name="refs-str"
                    select="concat($refs-str, $m-name-padded)"/>
                <xsl:with-param name="refs" select="$refs"/>
                <xsl:with-param name="node-index" select="$node-index+1"/>
                <xsl:with-param name="last" select="$last"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Declare any variable declarations here.  Importing stylesheets
       may override. -->
    <xsl:template name="decls">
        <!-- xsl:text>#define YYPURE 1&#10;</xsl:text -->
        <!--<xsl:text>int yyerror(char *s);&#10;</xsl:text>
        <xsl:text>int yylex(void*, void*);&#10;</xsl:text>
        <xsl:text>#define YYPARSE_PARAM parm&#10;</xsl:text>
        <xsl:text>#define YYLEX_PARAM parm&#10;</xsl:text>
        <xsl:text>#define YYERROR_VERBOSE 1&#10;</xsl:text>-->
    </xsl:template>

    <!-- Declare any C #include declarations here.  Importing stylesheets
       may override. -->
    <xsl:template name="includes">
        <!--<xsl:text>#include &lt;stdlib.h>&#10;</xsl:text>
        <xsl:text>#include &lt;string.h>&#10;</xsl:text>-->
    </xsl:template>

    <!-- The %union declaration identifies all the possible C types
       that a symbol value can have. -->
    <xsl:template name="decls-union">
    </xsl:template>

    <!-- You declare types of non-terminals using %type.  The type name
       must have first been declared by a %union. -->
    <xsl:template name="decls-type">
    </xsl:template>

    <!-- Normally, the start rule, the one that the parser starts
       trying to parse, is the one named in the first rule.  If you
       want to start with some other rule, you can name that rule
       with the %start declaration. -->
    <xsl:template name="decls-start">
        <!--<xsl:text>%pure_parser&#10;</xsl:text>-->
        <xsl:text>%start </xsl:text>
        <xsl:value-of select="g:start/@name"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Declare tokens that will be shared with lex with the %token
       declaration.  Tokens can also be declared by the %left, %right,
       or %nonassoc declarations. -->
    <xsl:template name="decls-tokens">
        <xsl:apply-templates select="g:token[not(@exposition-only='yes') and not(@is-macro='yes')]"/>
    </xsl:template>

    <xsl:template name="input">
    </xsl:template>

    <xsl:template name="outputChoices">
        <xsl:param name="choices" select="/.."/>
        <xsl:param name="lookahead" select="ancestor-or-self::*/@lookahead"/>
        <xsl:if test="count($choices)>1"></xsl:if>
        <xsl:for-each select="$choices">
            <xsl:if test="position()!=1"> | </xsl:if>
            <xsl:if test="count(*)>1"></xsl:if>
            <xsl:for-each select="*">
                <xsl:if test="position()!=1">
                    <xsl:text>
                    </xsl:text>
                </xsl:if>
                <xsl:apply-templates select=".">
                    <xsl:with-param name="lookahead" select="$lookahead"/>
                </xsl:apply-templates>
            </xsl:for-each>
            <xsl:if test="count(*)>1"></xsl:if>
        </xsl:for-each>
        <xsl:if test="count($choices)>1"></xsl:if>
    </xsl:template>

    <!-- =============== Element Handlers ================== -->
    <xsl:template match="g:exprProduction">
        <xsl:value-of select="g:level/*/@name"/>
        <!-- <xsl:for-each
          select="g:level/
          *">
            <xsl:if test="position()!=1">
                <br/>
                <xsl:text> |&#10;          </xsl:text>
            </xsl:if>
        <xsl:value-of select="@name"/>
        </xsl:for-each> -->
    </xsl:template>

    <xsl:template match="g:production|g:primary">
        <xsl:param name="prod-name" select="'#error'"/>
        <xsl:choose>
            <xsl:when
                test="count(*) = 1 and
                        (g:choice
                        |g:zeroOrMore)">
                <xsl:call-template name="group">
                    <xsl:with-param name="conn-cur" select="$conn-top"/>
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                    <xsl:with-param name="prod" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="*">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                    </xsl:apply-templates>
                    <xsl:text>
                    </xsl:text>
                </xsl:for-each>
                <xsl:call-template name="action-production">
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                    <xsl:with-param name="prod" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- In case this is not the last primary expression in the
           cascade... -->
        <xsl:if test="self::g:primary">
            <xsl:variable name="next-rule">
                <xsl:call-template name="next-rule-in-expr-production"/>
            </xsl:variable>
            <xsl:if test="normalize-space($next-rule)">
                <xsl:text>&#10; | </xsl:text>
                <xsl:value-of select="$next-rule"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:binary">
        <xsl:param name="prod-name"
            select="'#error - no prod-name in g:binary'"/>
        <xsl:variable name="nextProd">
            <xsl:call-template name="next-rule-in-expr-production"/>
        </xsl:variable>
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="prod" select="."/>
        <!-- Hmmm... I'm a little worried about operators at the same
           precedence level here. -sb -->
        <!-- Matter of fact, I'm sure of it. -sb -->
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="self::g:choice">
                    <xsl:for-each select="*">
                        <xsl:variable name="pat">
                            <xsl:value-of select="$name"/>
                            <xsl:text>
                            </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text>
                            </xsl:text>
                            <xsl:value-of select="$nextProd"/>
                        </xsl:variable>
                        <xsl:value-of select="$pat"/>
                        <xsl:call-template name="action-production">
                            <xsl:with-param name="prod" select="$prod"/>
                            <xsl:with-param name="prod-name"
                                select="$prod-name"/>
                        </xsl:call-template>
                        <xsl:text>&#10; | </xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="pat">
                        <xsl:value-of select="$name"/>
                        <xsl:text>
                        </xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text>
                        </xsl:text>
                        <xsl:value-of select="$nextProd"/>
                    </xsl:variable>
                    <xsl:value-of select="$pat"/>
                    <xsl:call-template name="action-production">
                        <xsl:with-param name="prod" select="$prod"/>
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                    </xsl:call-template>
                    <xsl:text>&#10; | </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:value-of select="$nextProd"/>
    </xsl:template>

    <xsl:template name="next-rule-in-expr-production">
        <xsl:param name="name" select="@name"/>
        <xsl:variable name="levels" select="../../g:level[*]"/>
        <xsl:variable name="productions" select="$levels/*"/>
        <xsl:for-each select="$productions">
            <xsl:if test="@name=$name">
                <xsl:variable name="position" select="position()"/>
                <xsl:value-of select="$productions[$position+1]/@name"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="g:prefix">
        <xsl:param name="prod" select="."/>
        <xsl:variable name="mainExprName" select="../../@name"/>
        <xsl:variable name="nextProd">
            <xsl:call-template name="next-rule-in-expr-production"/>
        </xsl:variable>
        <xsl:variable name="children" select="*"/>
        <xsl:choose>
            <xsl:when
                test="(count($children) = 1) and ($children/self::g:choice)">
                <xsl:call-template name="group">
                    <xsl:with-param name="conn-cur" select="$conn-seq"/>
                    <xsl:with-param name="prod" select="$prod"/>
                    <xsl:with-param name="prod-name" select="@name"/>
                    <xsl:with-param name="postfix" select="@name"/>
                    <xsl:with-param name="refset" select="$children/*"/>
                </xsl:call-template>
                <!-- xsl:text> </xsl:text>
                <xsl:value-of select="@name"/ -->
                <!-- xsl:text> </xsl:text>
                <xsl:call-template name="action-production">
                    <xsl:with-param name="prod" select="$children"/>
                    <xsl:with-param name="prod-name" select="@name"/>
                </xsl:call-template -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="group">
                    <xsl:with-param name="conn-cur" select="$conn-seq"/>
                    <xsl:with-param name="prod" select="$prod"/>
                    <xsl:with-param name="prod-name" select="@name"/>
                </xsl:call-template>
                <xsl:text>
                </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:call-template name="action-production">
                    <xsl:with-param name="prod" select="."/>
                    <xsl:with-param name="prod-name" select="@name"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10; | </xsl:text>
        <xsl:value-of select="$nextProd"/>
    </xsl:template>

    <xsl:template match="g:postfix">
        <xsl:value-of select="@name"/>
        <xsl:text>
        </xsl:text>
        <xsl:call-template name="group">
            <xsl:with-param name="conn-cur" select="$conn-seq"/>
        </xsl:call-template>
        <xsl:text>&#10; | </xsl:text>
        <xsl:variable name="nextProd">
            <xsl:call-template name="next-rule-in-expr-production"/>
        </xsl:variable>
        <xsl:value-of select="$nextProd"/>
    </xsl:template>

    <!-- Creates a name of a production for a oneOrMore, zeroOrMore, or
       optional clause. Can't get much uglier. -->
    <xsl:template name="manufactured-recursive-production-name">
        <xsl:choose>
            <xsl:when test="@name">
                <xsl:value-of select="@name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="local-name()"/>
                <xsl:for-each select=".//*">
                    <xsl:choose>
                        <xsl:when test="@name">
                            <xsl:value-of select="@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:optional" mode="manufactured-rules">
        <xsl:variable name="prod-name">
            <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:variable>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="manufactured-recursive-production-name"/>
        <xsl:text>: </xsl:text>
        <xsl:text>/* Empty */</xsl:text>
        <xsl:call-template name="action-production">
            <xsl:with-param name="prod-name" select="$prod-name"/>
            <xsl:with-param name="prod" select="."/>
            <xsl:with-param name="empty-action" select="1"/>
        </xsl:call-template>
        <xsl:text>&#10; | </xsl:text>
        <xsl:variable name="children" select="*"/>
        <xsl:for-each select="$children">
            <xsl:apply-templates select=".">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="prod" select="."/>
            </xsl:apply-templates>
            <xsl:text>
            </xsl:text>
        </xsl:for-each>
        <xsl:if
            test="not((count($children) = 1)
                  and boolean(g:choice))">
            <xsl:call-template name="action-production">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="prod" select="."/>
            </xsl:call-template>
        </xsl:if>
        <xsl:text>;&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="g:zeroOrMore" mode="manufactured-rules">
        <xsl:variable name="prod-name">
            <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:variable>
        <xsl:if test="count(../*) > 1">
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="manufactured-recursive-production-name"/>
            <xsl:text>: </xsl:text>
            <xsl:text>/* Empty */</xsl:text>
            <xsl:call-template name="action-production">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="prod" select="."/>
                <xsl:with-param name="empty-action" select="1"/>
            </xsl:call-template>
            <xsl:text>&#10; | </xsl:text>
            <xsl:call-template name="manufactured-recursive-production-name"/>
            <xsl:text>
            </xsl:text>
            <xsl:choose>
                <xsl:when test="g:choice and count(*)=1">
                    <xsl:for-each select="*">
                        <xsl:call-template name="manufactured-recursive-production-name"/>
                    </xsl:for-each>
                    <xsl:call-template name="action-production">
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                        <xsl:with-param name="prod" select="."/>
                        <xsl:with-param name="pseudo-variable-number-offset"
                            select="1"/>
                    </xsl:call-template>
                    <xsl:text>;&#10;</xsl:text>

                    <xsl:text>&#10;</xsl:text>
                    <xsl:for-each select="*">
                        <xsl:call-template name="manufactured-recursive-production-name"/>
                        <xsl:text>: </xsl:text>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text>;&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="*">
                        <xsl:apply-templates select="."/>
                        <xsl:text>
                        </xsl:text>
                    </xsl:for-each>
                    <xsl:call-template name="action-production">
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                        <xsl:with-param name="prod" select="."/>
                        <xsl:with-param name="pseudo-variable-number-offset"
                            select="1"/>
                    </xsl:call-template>
                    <xsl:text>;&#10;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:if>
    </xsl:template>

    <xsl:template match="g:oneOrMore" mode="manufactured-rules">
        <xsl:variable name="prod-name">
            <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:variable>
        <xsl:variable name="prod" select="."/>
        <xsl:text>&#10;</xsl:text>
        <xsl:value-of select="$prod-name"/>
        <xsl:text>: </xsl:text>
        <xsl:for-each select="*">
            <xsl:if test="not(self::g:choice)">
                <xsl:value-of select="$prod-name"/>
                <xsl:text>
                </xsl:text>
            </xsl:if>
            <xsl:apply-templates select=".">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="prod" select="$prod"/>
                <xsl:with-param name="recurse-value">
                    <xsl:value-of select="$prod-name"/>
                    <xsl:text>
                    </xsl:text>
                </xsl:with-param>
            </xsl:apply-templates>
            <xsl:text>
            </xsl:text>
        </xsl:for-each>
        <!-- xsl:call-template name="action-production">
            <xsl:with-param name="prod-name" select="$prod-name"/>
            <xsl:with-param name="prod" select="$prod"/>
            <xsl:with-param name="pseudo-variable-number-offset" select="1"/>
        </xsl:call-template -->
        <xsl:text>&#10; | </xsl:text>
        <xsl:for-each select="*">
            <xsl:apply-templates select=".">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="prod" select="$prod"/>
            </xsl:apply-templates>
            <xsl:text>
            </xsl:text>
        </xsl:for-each>
        <!-- xsl:call-template name="action-production">
            <xsl:with-param name="prod-name" select="$prod-name"/>
            <xsl:with-param name="prod" select="."/>
        </xsl:call-template -->
        <xsl:text>;&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="g:choice" mode="manufactured-rules">
        <xsl:param name="prod-name"
            select="'#error no prod-name in g:choice for manufactured rules!'"/>
        <xsl:if test="count(../*) > 1">
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="manufactured-recursive-production-name"/>
            <xsl:text>: </xsl:text>
            <xsl:call-template name="do-choice">
                <xsl:with-param name="prod-name" select="$prod-name"/>
            </xsl:call-template>
            <xsl:text>;&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="do-zeroOrMore">
        <xsl:param name="prod-name">
            <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:param>
        <xsl:text>/* Empty */</xsl:text>
        <xsl:call-template name="action-production">
            <xsl:with-param name="prod-name" select="$prod-name"/>
            <xsl:with-param name="prod" select="."/>
            <xsl:with-param name="empty-action" select="1"/>
        </xsl:call-template>
        <xsl:text>&#10; | </xsl:text>
        <xsl:for-each select="*">
            <!-- I added position()=1 to fix bug with AttributeList. -sb -->
            <xsl:if test="not(self::g:choice) and position()=1">
                <xsl:value-of select="$prod-name"/>
                <xsl:text>
                </xsl:text>
            </xsl:if>
            <xsl:apply-templates select=".">
                <xsl:with-param name="prod-name" select="$prod-name"/>
                <xsl:with-param name="recurse-value">
                    <xsl:value-of select="$prod-name"/>
                    <xsl:text>
                    </xsl:text>
                </xsl:with-param>
                <xsl:with-param name="pseudo-variable-number-offset"
                    select="1"/>
            </xsl:apply-templates>
            <xsl:text>
            </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="do-choice">
        <xsl:param name="prod" select="."/>
        <xsl:param name="prod-name"
            select="'#error no prod-name in do-choice!'"/>
        <xsl:param name="recurse-value" select="''"/>
        <xsl:param name="postfix" select="false()"/>
        <xsl:param name="refset" select="*"/>
        <xsl:for-each select="*">
            <xsl:value-of select="$recurse-value"/>
            <xsl:apply-templates select="."/>
            <xsl:if test="$postfix">
                <xsl:text>
                </xsl:text>
                <xsl:value-of select="$postfix"/>
                <xsl:text>
                </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when
                    test="$recurse-value and ancestor::g:zeroOrMore
                        |ancestor::g:oneOrMore|ancestor::g:optional">
                    <xsl:choose>
                        <xsl:when test="self::g:sequence">
                            <xsl:call-template name="action-production">
                                <xsl:with-param name="prod-name"
                                    select="$prod-name"/>
                                <xsl:with-param name="prod" select="$prod"/>
                                <xsl:with-param
                                    name="pseudo-variable-number-offset"
                                    select="1"/>
                                <xsl:with-param name="qualify-root-creation"
                                    select="true()"/>
                                <xsl:with-param name="refset" select="*"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="action-production">
                                <xsl:with-param name="prod-name"
                                    select="$prod-name"/>
                                <xsl:with-param name="prod" select="$prod"/>
                                <xsl:with-param
                                    name="pseudo-variable-number-offset"
                                    select="1"/>
                                <xsl:with-param name="qualify-root-creation"
                                    select="true()"/>
                                <xsl:with-param name="refset" select="."/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="self::g:sequence">
                    <xsl:call-template name="action-production">
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                        <xsl:with-param name="prod" select="$prod"/>
                        <xsl:with-param name="refset" select="*"/>
                        <!-- xsl:with-param name="pseudo-variable-number-offset" select="1"/>
                        <xsl:with-param name="qualify-root-creation" select="true()"/ -->
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="action-production">
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                        <xsl:with-param name="prod" select="$prod"/>
                        <xsl:with-param name="refset" select="."/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(position()=last())">
                <xsl:text>&#10; | </xsl:text>
                <!-- Added to attempt to handle quotAttributeContent case. -sb -->
                <!--<xsl:if test="parent::g:choice[parent::g:zeroOrMore]">
                    <xsl:for-each select="parent::g:choice/parent::g:zeroOrMore">
                        <xsl:call-template name="manufactured-recursive-production-name"/>
                        <xsl:text>&#10;    </xsl:text>
                    </xsl:for-each>
                </xsl:if>-->
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="g:optional">
        <xsl:call-template name="manufactured-recursive-production-name"/>
    </xsl:template>

    <xsl:template match="g:zeroOrMore">
        <xsl:param name="prod-name" select="../@name"/>
        <xsl:choose>
            <xsl:when test="count(../*) > 1">
                <xsl:call-template
                    name="manufactured-recursive-production-name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="do-zeroOrMore">
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:oneOrMore">
        <xsl:call-template name="manufactured-recursive-production-name"/>
    </xsl:template>

    <xsl:template match="g:choice">
        <xsl:param name="postfix" select="false()"/>
        <!--<xsl:param name="prod-name"
            select="'#error no prod-name in g:choice!'"/>-->
        <xsl:param name="prod-name">
            <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:param>
        <xsl:param name="prod" select=".."/>
        <xsl:param name="recurse-value" select="''"/>
        <xsl:param name="pseudo-variable-number-offset" select="0"/>
        <xsl:if test="starts-with($prod-name, '#error')">
            <xsl:message terminate="yes">
                <xsl:text>Did not get name: </xsl:text>
                <xsl:value-of select="@name"/>
            </xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count(../*) > 1">
                <xsl:call-template
                    name="manufactured-recursive-production-name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="do-choice">
                    <xsl:with-param name="recurse-value"
                        select="$recurse-value"/>
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                    <xsl:with-param name="prod" select="$prod"/>
                    <xsl:with-param name="postfix" select="$postfix"/>
                    <xsl:with-param name="pseudo-variable-number-offset"
                        select="$pseudo-variable-number-offset"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:sequence">
        <xsl:param name="postfix" select="false()"/>
        <xsl:param name="prod-name"
            select="'#error no prod-name in g:sequence!'"/>
        <xsl:param name="pseudo-variable-number-offset" select="0"/>
        <xsl:param name="conn-cur" select="$conn-none"/>
        <xsl:param name="conn-new" select="$conn-seq"/>
        <xsl:call-template name="group">
            <xsl:with-param name="prod" select="."/>
            <xsl:with-param name="prod-name" select="$prod-name"/>
            <xsl:with-param name="postfix" select="$postfix"/>
            <xsl:with-param name="conn-new" select="$conn-seq"/>
            <xsl:with-param name="conn-cur" select="$conn-cur"/>
            <xsl:with-param name="pseudo-variable-number-offset"
                select="$pseudo-variable-number-offset"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="g:ref">
        <xsl:param name="conn-cur" select="$conn-none"/>
        <xsl:param name="conn-new" select="$conn-seq"/>
        <xsl:value-of select="@name"/>
    </xsl:template>

    <!-- template for outputting the token rules. -->
    <xsl:template match="g:token">
        <xsl:text>&#10;%token </xsl:text>
        <xsl:call-template name="token-type">
            <xsl:with-param name="name" select="@name"/>
            <xsl:with-param name="value-type" select="@value-type"/>
        </xsl:call-template>
        <xsl:value-of select="@name"/>
    </xsl:template>

    <xsl:template name="token-type">
        <xsl:param name="name" select="@name"/>
        <!-- empty.  For derived stylesheets. -->
    </xsl:template>

    <xsl:template match="g:string[@ignoreCase]">
        <xsl:call-template name="ignore-case">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:variable name="conn-none" select="0"/>
    <xsl:variable name="conn-or" select="1"/>
    <xsl:variable name="conn-seq" select="2"/>
    <xsl:variable name="conn-top" select="3"/>
    <xsl:template name="group">
        <xsl:param name="postfix" select="false()"/>
        <xsl:param name="prod" select=".."/>
        <xsl:param name="prod-name" select="'#error'"/>
        <xsl:param name="conn-cur" select="$conn-none"/>
        <xsl:param name="conn-new" select="$conn-seq"/>
        <xsl:param name="pseudo-variable-number-offset" select="0"/>
        <xsl:choose>
            <xsl:when
                test="count(*)>1
                      and $conn-new != $conn-cur
                      and $conn-cur != $conn-top">
                <xsl:text></xsl:text>
                <xsl:call-template name="group">
                    <xsl:with-param name="conn-new" select="$conn-new"/>
                    <xsl:with-param name="conn-cur" select="$conn-new"/>
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                    <xsl:with-param name="prod" select="$prod"/>
                    <xsl:with-param name="pseudo-variable-number-offset"
                        select="$pseudo-variable-number-offset"/>
                </xsl:call-template>
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="count(*)>1">
                <xsl:for-each
                    select="*">
                    <xsl:if test="position() != 1">
                        <xsl:choose>
                            <xsl:when test="$conn-new=$conn-seq">
                                <xsl:text>
                                </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#10; | </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="conn-new" select="$conn-new"/>
                        <xsl:with-param name="conn-cur" select="$conn-new"/>
                        <xsl:with-param name="prod-name" select="$prod-name"/>
                        <xsl:with-param name="postfix" select="$postfix"/>
                        <xsl:with-param name="pseudo-variable-number-offset"
                            select="$pseudo-variable-number-offset"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*">
                    <xsl:with-param name="conn-new" select="$conn-new"/>
                    <xsl:with-param name="conn-cur" select="$conn-cur"/>
                    <xsl:with-param name="prod-name" select="$prod-name"/>
                    <xsl:with-param name="postfix" select="$postfix"/>
                    <xsl:with-param name="pseudo-variable-number-offset"
                        select="$pseudo-variable-number-offset"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Action templates for overrides from derived stylesheets -->
    <xsl:template name="action-production">
    </xsl:template>

    <xsl:template name="action-production-end">
    </xsl:template>

    <xsl:template name="action-exprProduction">
    </xsl:template>

    <xsl:template name="action-exprProduction-end">
    </xsl:template>

    <xsl:template name="action-level">
    </xsl:template>

    <xsl:template name="action-level-jjtree-label"></xsl:template>

    <xsl:template name="binary-action-level-jjtree-label"></xsl:template>

    <xsl:template name="action-level-start">
    </xsl:template>

    <xsl:template name="action-level-end">
    </xsl:template>

    <xsl:template name="action-token-ref">
    </xsl:template>
</xsl:stylesheet>
<!-- vim: sw=4 ts=4 expandtab
-->
