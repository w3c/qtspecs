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
     into a lex file.  This is meant to be used with yacc.xsl,
     and also imported by yacc.xsl.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
    <xsl:import href="utils.xsl"/>
    <!-- Conditional to say which specification we should generate. -->
    <xsl:param name="spec" select="'xquery'"/>
    <!-- Strip all extraneous whitespace, except for a character def. -->
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="g:char"/>
    <!-- Output is a .l file, meant to be processed by flex or other
       similar processor. -->
    <xsl:output method="text" encoding="iso-8859-1"/>
    <!-- Key to allow fast lookup of tokens and productions. -->
    <xsl:key name="map_name_to_defn" match="g:token|g:production" use="@name"/>

    <!-- The root element template, which will be matched first. -->
    <xsl:template match="g:grammar">
        <xsl:call-template name="user-code"/>
        <xsl:call-template name="definitions"/>
        <xsl:call-template name="rules"/>
    </xsl:template>

    <!-- Definitions (literal block, substitutions, etc.) occur before
       the rules section. -->
    <xsl:template name="definitions">
        <xsl:call-template name="includes"/>
        <xsl:text>&#10;%%&#10;&#10;</xsl:text>
        <xsl:call-template name="internal-table-declarations"/>
        <xsl:call-template name="literal-block"/>
        <!-- "Options and Macros" start here in jflex -->
        <xsl:call-template name="start-conditions"/>
        <xsl:call-template name="substitutions"/>
        <xsl:call-template name="translations"/>
    </xsl:template>
    <!-- The contents of the literal block are copied verbatim to the
       generated C source file near the beginning, before the beginning
       of yylex(). -->
    <xsl:template name="literal-block">
        <xsl:text>%{&#10;</xsl:text>
        <!--<xsl:call-template name="includes"/>-->
        <xsl:call-template name="decls"/>
        <xsl:text>&#10;%}&#10;</xsl:text>
    </xsl:template>

    <!-- Definitions (Substitutions) allow you to give a name or all or
       part of a regular expression, and refer to it by name in the
       rules section. -->
    <xsl:template name="substitutions">
        <xsl:text>/* macros */&#10;</xsl:text>
        <xsl:variable name="refs"
                select="*[self::g:token
                  ][not(@exposition-only='yes')]//g:ref/@name"/>
        <xsl:for-each select="g:token[@name=$refs]">
                    <xsl:value-of select="@name"/>
                    <xsl:text> = </xsl:text>
                    <!-- added for jflex. -sb -->
                        <xsl:choose>
                            <xsl:when test="@alias-for">
                                <xsl:for-each
                                    select="key('map_name_to_defn', @alias-for)/self::g:token">
                                    <xsl:call-template
                                        name="apply-delimited-children">
                                        <xsl:with-param name="delimeter"
                                            select="' '"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template
                                    name="apply-delimited-children">
                                    <xsl:with-param name="delimeter"
                                        select="' '"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    <xsl:value-of select="'&#10;'"/>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- You increase the sizes of the tables with %a, %e, %k, %n, %o,
       and %p. Normally you don't need anything for this. -->
    <xsl:template name="internal-table-declarations">
        <!--<xsl:text>%option c++&#10;</xsl:text>
    <xsl:text>%option yyclass="XPathLexer"&#10;</xsl:text>-->
        <xsl:text>%class </xsl:text>
        <xsl:call-template name="doClassName"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>%unicode&#10;</xsl:text>
        <xsl:text>%byaccj&#10;</xsl:text>
        <xsl:text>%line&#10;</xsl:text>
        <xsl:text>%column&#10;</xsl:text>
        <!--<xsl:text>%scanerror "exception"</xsl:text>-->
        <!--<xsl:text>%debug&#10;</xsl:text>-->
    </xsl:template>

    <xsl:template name="doClassName">
        <xsl:call-template name="doSpecType"/>
        <xsl:text>Lexer</xsl:text>
    </xsl:template>

    <!-- Start states are used to limit the scope of certain rules, or
       to change the way the lexer treats part of the file.  You declare
       a start state with %lines.  For example:
        %s PREPROC
       Flex and most versions other than AT&T lex also have exclusive
       start states declared with %x.
  -->
    <xsl:template name="start-conditions">
        <xsl:text>&#10;/* Lexical State Declarations */&#10;</xsl:text>
        <xsl:for-each select="/g:grammar/g:state-list/g:state">
            <xsl:text>%state </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Most versions of lex have character translations introduced by
       %T. -->
    <xsl:template name="translations">
        <!-- Empty -->
    </xsl:template>

    <!-- The rules section contains pattern lines and C code.  A line
       that starts with whitespace, or material enclosed in %{ and %} is
       C code.  A line that starts with anything else is a pattern line. -->
    <xsl:template name="rules">
        <xsl:text>&#10;%%&#10;&#10;/* Lexical rules */&#10;</xsl:text>
        <xsl:apply-templates select="g:token[not(@is-macro='yes')]"/>
    </xsl:template>

    <!-- Declare any variable declarations here.  Importing stylesheets
       may override. -->
    <xsl:template name="decls">
        <xsl:text><![CDATA[

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


        ]]></xsl:text>

        <xsl:text>
  /* store a reference to the parser object */
  private Parser yyparser;

  /* constructor taking an additional parser object */
  public </xsl:text>
  <xsl:call-template name="doClassName"/>
  <xsl:text>(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
    yy_lexical_state = DEFAULT;  // Override yy_lexical_state = YYINITIAL;
  }
        </xsl:text>
    </xsl:template>

    <!-- Declare any import declarations here.  Importing stylesheets
       may override. -->
    <xsl:template name="includes">
        <!--<xsl:text> import java.io.*;&#10;</xsl:text>-->
import java.util.Stack;
    </xsl:template>

    <!-- Template for user code.  Importing stylesheets may override. -->
    <xsl:template name="user-code"></xsl:template>

    <xsl:template name="outputAction">
        <xsl:param name="action" select="'#error'"/>
        <xsl:choose>
            <xsl:when test="contains($action, 'input_stream.backup(')">
                <xsl:text>&#10;yypushback(</xsl:text>
                <xsl:value-of
                    select="substring-before(substring-after($action, '('), ')') "/>
                <xsl:text>); </xsl:text>
                <!-- xsl:text>cout &lt;&lt; "pushx: " &lt;&lt; yy_top_state() &lt;&lt; "\n"; </xsl:text -->
            </xsl:when>
            <xsl:when test="contains($action, 'pushState(')">
                <xsl:text>&#10;pushState(</xsl:text>
                <xsl:value-of
                    select="substring-before(substring-after($action, '('), ')') "/>
                <xsl:text>); </xsl:text>
                <!-- xsl:text>cout &lt;&lt; "pushx: " &lt;&lt; yy_top_state() &lt;&lt; "\n"; </xsl:text -->
            </xsl:when>
            <xsl:when test="$action='pushState'">
                <xsl:text>&#10;pushState(</xsl:text>
                <!-- TODO: Shouldn't this be the current state? -->
                <!--<xsl:value-of select="$nextState"/>-->
                <xsl:text>yystate()</xsl:text>
                <xsl:text>); </xsl:text>
                <!-- xsl:text>cout &lt;&lt; "push: " &lt;&lt; yy_top_state() &lt;&lt; "\n";; </xsl:text -->
            </xsl:when>
            <xsl:when test="$action='popState'">
                <!-- xsl:text>cout &lt;&lt; "pop: " &lt;&lt; yy_top_state() &lt;&lt; "\n";; </xsl:text -->
                <xsl:text>&#10;popState(); </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Tokenize a list of strings, delimited by ';',
         and output the unique ones,
         prefixed by $before-output and followed by $after-output. -->
    <xsl:template name="tokenize-and-output-actions">
        <xsl:param name="string" select="''"/>

        <xsl:param name="used-states" select="';'"/> <!-- Private -->

        <xsl:if test="$string">
            <xsl:variable name="token" select="substring-before($string,';')"/>
            <xsl:choose>
                <xsl:when test="$token">

                    <xsl:if test="not(contains($used-states, concat(';', $token, ';')))">
                        <xsl:call-template name="outputAction">
                            <xsl:with-param name="action" select="$token"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:call-template name="tokenize-and-output-actions">
                        <xsl:with-param name="string"
                            select="substring($string, string-length($token)+2)"/>
                        <xsl:with-param name="used-states"
                            select="concat($used-states, $token, ';')"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- The workhorse template for outputting the token rules. -->
    <xsl:template match="g:token">
        <xsl:param name="token-name" select="@name"/>
        <xsl:variable name="lexStateTransitions"
            select="/g:grammar/g:state-list"/>
        <xsl:variable name="lexStatesUnderWhichTokenIsRecognized"
            select="$lexStateTransitions/g:state[g:transition/g:tref[@name=$token-name]]"/>
        <xsl:variable name="transitions" select="$lexStatesUnderWhichTokenIsRecognized/g:transition[g:tref[@name=$token-name]]"/>
        <xsl:variable name="nextState" select="($transitions/@next-state)[1]"/>
        <xsl:variable name="rule">
            <!--<xsl:if test="$lexStatesUnderWhichTokenIsRecognized">
                <xsl:text>&gt;</xsl:text>
            </xsl:if>-->
            <xsl:choose>
                <xsl:when test="@alias-for">
                    <xsl:for-each select="key('map_name_to_defn', @alias-for)/self::g:token">
                        <xsl:call-template name="apply-delimited-children">
                            <xsl:with-param name="delimeter" select="' '"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Double check to make sure there's children to process -->
                    <xsl:if test="not(*)">
                        <xsl:message>ERROR! <xsl:value-of select="@name"/></xsl:message>
                    </xsl:if>
                    <!-- diagnostic:  <xsl:value-of select="@name"/>
                    <xsl:text>:::</xsl:text> -->
                    <xsl:if test="true()">
                        <xsl:call-template name="apply-delimited-children">
                            <xsl:with-param name="delimeter" select="' '"/>
                        </xsl:call-template>
                    </xsl:if>
                    <!--<xsl:text>;;;</xsl:text>-->
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="true()">
                <xsl:text> { </xsl:text>
                <xsl:if test="$transitions/@action">
                    <xsl:call-template name="tokenize-and-output-actions">
                        <xsl:with-param name="string" select="concat($transitions/@action, ';')"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="normalize-space($nextState)">
                    <xsl:text>&#10; yybegin(</xsl:text>
                    <xsl:value-of select="$nextState"/>
                    <xsl:text>);&#10; </xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@token-kind='skip'">
                        <xsl:text> /* ignore */ </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(@value-type)='string'">
                                <xsl:text>yyparser.yylval.sval = yyparser.yytext; </xsl:text>
                            </xsl:when>
                            <xsl:when test="normalize-space(@value-type)='number'">
                                <xsl:text>yyparser.yylval.sval = yyparser.yytext; </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>yyparser.yylval.ival = </xsl:text>
                                <xsl:text>Parser.</xsl:text>
                                <xsl:value-of select="$token-name"/>
                                <xsl:text>; </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#10;return </xsl:text>
                        <xsl:text>Parser.</xsl:text>
                        <xsl:value-of select="$token-name"/>
                        <xsl:text>;&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}</xsl:text>
            </xsl:if>
            <!--<xsl:text>;&#10;</xsl:text>-->
            <xsl:text>&#10;</xsl:text>
        </xsl:variable>
        <!-- Now either tokenize the states and append the rule after
           each state, or just output the rule. -->
        <!--<xsl:if test="$recognizeLexState">
            <xsl:call-template name="tokenize-and-output">
                <xsl:with-param name="string"
                    select="concat(normalize-space($recognizeLexState), ' ')"/>
                <xsl:with-param name="before-output" select="'&lt;'"/>
                <xsl:with-param name="after-output" select="'&gt;'"/>
                <xsl:with-param name="delimit-output" select="','"/>
            </xsl:call-template>
        </xsl:if>-->
        <xsl:if test="not($lexStatesUnderWhichTokenIsRecognized/@name = 'ANY')">
            <xsl:if test="true()">

                <xsl:if test="$lexStatesUnderWhichTokenIsRecognized">
                    <xsl:text>&lt;</xsl:text>
                    <xsl:variable name="refs-count" select="count($lexStatesUnderWhichTokenIsRecognized)"/>
                    <xsl:for-each select="$lexStatesUnderWhichTokenIsRecognized">
                        <xsl:value-of select="@name"/>
                        <xsl:if test="not(position()=$refs-count)">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>&gt;</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:copy-of select="$rule"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:char|g:string">
        <xsl:text>"</xsl:text>
        <xsl:call-template name="replace-char">
            <xsl:with-param name="string" select="."/>
            <xsl:with-param name="from" select="'&quot;'"/>
            <xsl:with-param name="to" select="'\x22'"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <!-- xsl:template match="g:string[.=']]&gt;']">
   ***  ERROR! IN "g:string[.=']]&gt;']" TEMPLATE - UNIMPLEMENTED! ***
  </xsl:template -->

    <xsl:template match="g:string[@ignoreCase]">
        <xsl:call-template name="ignore-case">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

    <xsl:template name="ignore-case">
        <xsl:param name="string" select="''"/>
        <xsl:if test="$string">
            <xsl:variable name="c" select="substring($string,1,1)"/>
            <xsl:variable name="uc" select="translate($c,$lower,$upper)"/>
            <xsl:variable name="lc" select="translate($c,$upper,$lower)"/>
            <xsl:choose>
                <xsl:when test="$lc=$uc">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$c"/>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$uc"/>
                    <xsl:value-of select="$lc"/>
                    <xsl:text>]</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="ignore-case">
                <xsl:with-param name="string" select="substring($string,2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:charCode">
        <xsl:choose>
            <xsl:when test="@value='000A'">
                <xsl:text>\n</xsl:text>
            </xsl:when>
            <xsl:when test="@value='000D'">
                <xsl:text>\r</xsl:text>
            </xsl:when>
            <xsl:when test="@value='0009'">
                <xsl:text>\t</xsl:text>
            </xsl:when>
            <xsl:when test="@value='0020'">
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\u</xsl:text>
                <!-- xsl:value-of select="substring(@value,3,2)"/ -->
                <xsl:value-of select="@value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:charClass[false()]">
        <xsl:param name="not-in" select="''"/>
        <xsl:text>[</xsl:text>
        <!-- For right now, screen out values greater than 255. -->
        <xsl:variable name="char-codes"
            select="*[self::g:charCodeRange[substring(@minValue,1,2) = '00' and substring(@maxValue,1,2) = '00']
              or self::g:charCode[substring(@value,1,2) = '00']
              or self::g:char or self::g:charRange]"/>
        <xsl:choose>
            <xsl:when test="$char-codes">
                <xsl:for-each select="$char-codes">
                    <xsl:if test="position()!=1">
                        <xsl:text></xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$not-in"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- Dummy value -->
                <xsl:text>\u0000</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="g:charClass[true()]">
        <xsl:param name="not-in" select="''"/>
        <xsl:text>[</xsl:text>
        <xsl:variable name="char-codes"
            select="g:charCodeRange | g:charCode | g:char | g:charRange"/>
        <xsl:value-of select="$not-in"/>
        <xsl:choose>
            <xsl:when test="$char-codes">
                <xsl:for-each select="$char-codes">
                    <xsl:if test="position()!=1">
                        <xsl:text></xsl:text>
                    </xsl:if>
                    <!--<xsl:value-of select="$not-in"/>-->
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- Dummy value -->
                <xsl:text>\u0000</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="g:charRange">
        <xsl:value-of select="@minChar"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@maxChar"/>
    </xsl:template>

    <xsl:template match="g:charCodeRange[true()]">
        <xsl:text>\u</xsl:text>
        <xsl:value-of select="@minValue"/>
        <xsl:text>-\u</xsl:text>
        <xsl:value-of select="@maxValue"/>
    </xsl:template>

    <xsl:template match="g:charCodeRange[false()]">
        <xsl:text>\u</xsl:text>
        <xsl:value-of select="substring(@minValue,3,2)"/>
        <xsl:text>-\u</xsl:text>
        <xsl:value-of select="substring(@maxValue,3,2)"/>
    </xsl:template>

    <!-- Not a set of characters. -sb -->
    <xsl:template match="g:complement">
        <xsl:apply-templates>
            <xsl:with-param name="not-in" select="'^'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="g:production">
        <!-- Empty -->
    </xsl:template>

    <xsl:template match="g:exprProduction">
        <!-- Empty -->
    </xsl:template>

    <xsl:template name="outputChoices">
        <xsl:param name="choices" select="/.."/>
        <xsl:if test="count($choices)>1">(</xsl:if>
        <xsl:for-each select="$choices">
            <xsl:if test="position()!=1">|</xsl:if>
            <xsl:if test="count(*)>1">(</xsl:if>
            <xsl:for-each select="*">
                <xsl:if test="position()!=1" xml:space="preserve">  </xsl:if>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:if test="count(*)>1">)</xsl:if>
        </xsl:for-each>
        <xsl:if test="count($choices)>1">)</xsl:if>
    </xsl:template>

    <xsl:template match="g:optional">
        <xsl:text>[</xsl:text>
        <xsl:call-template name="space"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="g:token//g:optional">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="space"/>
        <xsl:text>)?</xsl:text>
    </xsl:template>

    <xsl:template match="g:zeroOrMore">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="space"/>
        <xsl:text>)*</xsl:text>
    </xsl:template>

    <xsl:template match="g:oneOrMore">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="space"/>
        <xsl:text>)+</xsl:text>
    </xsl:template>

    <xsl:template match="g:sequence">(<xsl:call-template
        name="space"/>)</xsl:template>

    <xsl:template match="g:ref">
        <xsl:choose>
            <xsl:when test="key('map_name_to_defn',@name)/self::g:token">
                <xsl:text>{</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
                <xsl:text>()</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:choice">
        <xsl:text>(</xsl:text>
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <xsl:text>|</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template name="space">
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <xsl:text></xsl:text>
                <!-- No spaces allowed in flex grammars! -->
            </xsl:if>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
<!-- vim: sw=4 ts=4 expandtab
-->
