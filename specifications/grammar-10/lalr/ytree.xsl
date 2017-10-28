<?xml version="1.0" encoding="utf-8"?>

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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:g="http://www.w3.org/2001/03/XPath/grammar">

  <!-- Many of the constructs for the yaccification are the same as
       for lex, so we essentially derive from that stylesheet. -->
  <xsl:import href="yacc.xsl"/>

  <!-- Declare any C #include declarations here.  Importing stylesheets
       may override. -->  
  <xsl:template name="includes">
    <!--<xsl:text>#include &lt;stdlib.h>&#10;</xsl:text>
    <xsl:text>#include &lt;string.h>&#10;</xsl:text>
    <xsl:text>#include "xpathyyt.h"&#10;</xsl:text>
    <xsl:text>#include "ASTNodeC.h"&#10;</xsl:text>-->  
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
  </xsl:template>

  <!-- The %union declaration identifies all the possible C types
       that a symbol value can have. -->
  <xsl:template name="decls-union">
  </xsl:template>

  <!-- Declare the type of the token in the token declaration. -->
  <xsl:template name="token-type">
    <xsl:param name="name" select="@name"/>
    <xsl:param name="token-type" select="@value-type"/>
    <xsl:choose>
      <xsl:when test="normalize-space($token-type)='string'">
        <xsl:text>&lt;sval> </xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($token-type)='number'">
        <xsl:text>&lt;sval> </xsl:text>
      </xsl:when>      
      <xsl:otherwise>
        <xsl:text>&lt;ival> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- You declare types of non-terminals using %type.  The type name
       must have first been declared by a %union. -->
  <xsl:template name="decls-type">
    <xsl:text>%token VT_STRING&#10;</xsl:text>
    <xsl:text>%token VT_NUMBER&#10;</xsl:text>
    <xsl:text>%token VT_ID&#10;</xsl:text>

    <xsl:variable name="non-terminals" 
      select="g:production  |
              g:exprProduction/g:level/*"/>
    <!-- g:exprProduction | -->
    
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="$non-terminals">
      <xsl:text>%token </xsl:text>
      <xsl:text>NT</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>%type </xsl:text>
      <!--<xsl:text>&lt;astnode> </xsl:text>-->
      <xsl:text>&lt;obj> </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    
    <!-- This next section constructs all the rules we have to
         "manufacture", that can not be represented in yacc by things like 
         (foo)*.-->
    <xsl:variable name="non-terminal-productions" 
      select="g:production  |
              g:exprProduction/g:level/*"/>
    
    <xsl:variable name="manufactured-rules" 
      select="($non-terminal-productions//g:zeroOrMore
              | $non-terminal-productions//g:oneOrMore
              | $non-terminal-productions//g:optional
              | $non-terminal-productions//g:choice)
              [child::*]"/>
    
    <xsl:call-template name="type-unique-manufactured-rules">
      <xsl:with-param name="refs" select="$manufactured-rules"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Declare the unique manufactured rules and their types.  The iteration has to be done 
       recursively in order to eliminate duplicate rules.-->
  <xsl:template name="type-unique-manufactured-rules">
    <xsl:param name="refs"/> <!-- required, list of nodes to make manufactured rules for. -->
    <xsl:param name="node-index" select="1"/>
    <xsl:param name="refs-str" select="''"/>
    <xsl:param name="last" select="count($refs)"/>

    <xsl:if test="$node-index &lt;= $last">
      <xsl:variable name="m-rule-node" select="$refs[$node-index]"/>

      <xsl:variable name="m-name">
        <xsl:for-each select="$m-rule-node">
          <xsl:call-template name="manufactured-recursive-production-name"/>
        </xsl:for-each>        
      </xsl:variable>
      
      <xsl:variable name="m-name-padded">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$m-name"/>
        <xsl:text> </xsl:text>
      </xsl:variable>

      <!-- TODO: Fix this hack! (g:choice) -->
      <xsl:if test="not(contains($refs-str, $m-name-padded))">
        <xsl:if test="$m-rule-node/self::g:optional
                      or $m-rule-node/self::g:choice[parent::g:zeroOrMore] 
                      or count($m-rule-node/../*) > 1">
          <xsl:text>%token </xsl:text>
          <xsl:text>NT</xsl:text>
          <xsl:value-of select="$m-name"/>
          <xsl:text>&#10;</xsl:text>   
          
          <!-- TODO: Fix this hack! (g:choice) -->
          <xsl:if test="$m-rule-node/self::g:choice[parent::g:zeroOrMore]
                        or count($m-rule-node/../*) > 1">
              <xsl:text>%type </xsl:text>
              <!--<xsl:text>&lt;astnode> </xsl:text>-->
              <xsl:text>&lt;obj> </xsl:text>
              <xsl:value-of select="$m-name"/>
              <xsl:text>&#10;</xsl:text> 
          </xsl:if>  
        </xsl:if>
      </xsl:if>
      
      <xsl:call-template name="type-unique-manufactured-rules">
        <xsl:with-param name="refs-str" select="concat($refs-str, $m-name-padded)"/>
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="node-index" select="$node-index+1"/>
        <xsl:with-param name="last" select="$last"/>          
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>

  <!-- Declare the yacc semantic action for grammar rule match, just
       before reduction takes place. 
       parameters:
       -> prod The owning production.
       -> choice If this is a choice construct that is being 
          flattened, should be the choice elem. 
       -> prod-name The name of the owning production.
       -> If the called has inserted a rule, this is needed to offset 
          the variable numbers (i.e. $n).
       -> True if the action is for an empty rule.
       -> qualify-root-creation True if the ASTNode subroot should 
          be created only if it doesn't already exist.
       -> refset The actual refset to which the ASTNodes should be built on.
       -->
  <xsl:template name="action-production">
    <xsl:param name="prod" select=".."/>
    <xsl:param name="choice" select="dummy"/>
    <xsl:param name="prod-name" select="dummy"/>
    <xsl:param name="pseudo-variable-number-offset" select="0"/>
    <xsl:param name="empty-action" select="false()"/>
    <xsl:param name="qualify-root-creation" 
      select="$prod/self::g:zeroOrMore
              |$prod/self::g:oneOrMore"/>
    <xsl:param name="refset" 
      select="$prod/*"/>

    <xsl:variable name="break-and-indent">
      <xsl:text>&#10;                             </xsl:text>
    </xsl:variable>

    <xsl:text> { </xsl:text>
    <xsl:value-of select="$break-and-indent"/>

    <xsl:choose>
      <xsl:when test="$empty-action">
        <!-- xsl:text>if(NT</xsl:text>
        <xsl:value-of select="$prod-name"/>
        <xsl:text> != ASTNodeGetID($$))</xsl:text>
        <xsl:value-of select="$break-and-indent"/>
        <xsl:text>  </xsl:text -->
        yyval = new ParserVal(0);
        <xsl:text>$$ = ASTNodeCreate(NT</xsl:text>
        <xsl:value-of select="$prod-name"/>
        <xsl:text>);</xsl:text>
      </xsl:when>
      <xsl:when test="$prod/self::g:binary">
        <xsl:choose>
        	<xsl:when test="false()">
        	    
        	</xsl:when>
        	<xsl:otherwise>
        	    yyval = new ParserVal(0);
                <xsl:text>$$ = ASTNodeCreate($2);</xsl:text>
        	</xsl:otherwise>
        </xsl:choose>
        
        <xsl:value-of select="$break-and-indent"/>
        <!-- TODO: Figure out if anything needs to be done with setCurrentASTNode -->
        <!--<xsl:text>setCurrentASTNode(parm, $$);</xsl:text>
        <xsl:value-of select="$break-and-indent"/>-->
        <xsl:text>ASTNodeAddChild( $$, $1 );</xsl:text>
        <xsl:value-of select="$break-and-indent"/>
        <xsl:text>ASTNodeAddChild( $$, $3 ); </xsl:text>
      </xsl:when>
      <xsl:when test="$prod/self::g:primary
                      |$prod/self::g:production
                      |$prod/self::g:choice
                      |$prod/self::g:oneOrMore
                      |$prod/self::g:zeroOrMore
                      |$prod/self::g:optional
                      |$prod/self::g:sequence
                      |$prod/self::g:prefix">
         <xsl:if test="$qualify-root-creation">
          <xsl:text>if(NT</xsl:text>
          <xsl:value-of select="$prod-name"/>
          <xsl:text> != ASTNodeGetID($$))</xsl:text>
          <xsl:value-of select="$break-and-indent"/>
          <xsl:text>  </xsl:text>
        </xsl:if>
        yyval = new ParserVal(0);
        <xsl:text>$$ = ASTNodeCreate(NT</xsl:text>
        <xsl:value-of select="$prod-name"/>
        <xsl:text>);</xsl:text>
        <!-- TODO: Figure out if anything needs to be done with setCurrentASTNode -->
        <!--<xsl:value-of select="$break-and-indent"/>
        <xsl:text>setCurrentASTNode(parm, $$);</xsl:text>-->
        <xsl:choose>
          <xsl:when test="$choice">
            <xsl:call-template name="process-action-add-children">
              <xsl:with-param name="refset" select="$choice"/>
              <xsl:with-param name="break" select="$break-and-indent"/>
              <xsl:with-param name="prefix" select="$prod/self::g:prefix"/>
              <xsl:with-param name="pseudo-variable-number-offset" 
                select="$pseudo-variable-number-offset"/>
            </xsl:call-template>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process-action-add-children">
              <xsl:with-param name="refset" select="$refset"/>
              <xsl:with-param name="break" select="$break-and-indent"/>
              <xsl:with-param name="prefix" select="$prod/self::g:prefix"/>
              <xsl:with-param name="pseudo-variable-number-offset" 
                select="$pseudo-variable-number-offset"/>
            </xsl:call-template>            
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>fprintf(stdout, "</xsl:text>
        <xsl:value-of select="$prod-name"/>
        <xsl:text>\n"); </xsl:text>        
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text> } </xsl:text>
  </xsl:template>

  <xsl:template name="process-action-add-children">
    <xsl:param name="refset"/>
    <xsl:param name="count" select="1"/>
    <xsl:param name="break" select="' '"/>
    <xsl:param name="prefix" select="false()"/>
    <xsl:param name="pseudo-variable-number-offset" select="0"/>

    <xsl:choose>
      <xsl:when test="$refset[$count]/self::g:ref">
        <xsl:variable name="token" select="key('ref',$refset[$count]/@name)/self::g:token"/>
        <xsl:choose>
          <xsl:when test="$token/@value-type">
            <xsl:choose>
              <xsl:when test="count($refset[key('ref',@name)/self::g:token/@value-type]) = 1">
                <xsl:value-of select="$break"/>
                <xsl:choose>
                  <xsl:when test="normalize-space($token/@value-type)='string'">
                    <xsl:text>ASTNodeSetValueToString($$, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                  </xsl:when>
                  <xsl:when test="normalize-space($token/@value-type)='number'">
                    <xsl:text>ASTNodeSetValueToNumber($$, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                  </xsl:when>
                  <xsl:when test="normalize-space($token/@value-type)='id'">
                    <xsl:text>ASTNodeSetValueToID($$, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$break"/>
                <xsl:text>{ SimpleNode astn</xsl:text>
                <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                <xsl:text> = ASTNodeCreate(</xsl:text>
                <xsl:value-of select="$token/@name"/>
                <xsl:text>);</xsl:text>
                <xsl:value-of select="$break"/>
                
                <xsl:choose>
                  <xsl:when test="normalize-space($token/@value-type)='string'">
                    <xsl:text>ASTNodeSetValueToString(astn</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                  </xsl:when>
                  <xsl:when test="normalize-space($token/@value-type)='number'">
                    <xsl:text>ASTNodeSetValueToNumber(astn</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                   </xsl:when>
                  <xsl:when test="normalize-space($token/@value-type)='id'">
                    <xsl:text>ASTNodeSetValueToID(astn</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>, $</xsl:text>
                    <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                    <xsl:text>);</xsl:text>
                  </xsl:when>
                </xsl:choose>
                <xsl:value-of select="$break"/>
                <xsl:text>ASTNodeAddChild( $$, astn</xsl:text>
                <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
                <xsl:text>); }</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="not($token)">
            <xsl:value-of select="$break"/>
            <xsl:text>ASTNodeAddChild( $$, $</xsl:text>
            <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
            <xsl:text> ); </xsl:text>            
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- xsl:when test="(self::g:zeroOrMore|self::g:oneOrMore|self::g:optional|self::g:choice|self::g:choice)
                      [child::*]">
        
      </xsl:when -->
      <xsl:otherwise>
        <xsl:value-of select="$break"/>
        <xsl:if test="not($refset[$count]/@name)">
            <xsl:message>
                <xsl:text>ASTNodeAddChild otherwise: </xsl:text>
                <xsl:value-of select="name($refset[$count])"/>
            </xsl:message>
            <xsl:text>!!!!</xsl:text>
        </xsl:if>
        <xsl:text>ASTNodeAddChild( $$, $</xsl:text>
        <xsl:value-of select="$count+$pseudo-variable-number-offset"/>
        <xsl:text> ); </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="$refset[$count+1]">
        <xsl:call-template name="process-action-add-children">
          <xsl:with-param name="refset" select="$refset"/>
          <xsl:with-param name="count" select="$count+1"/>
          <xsl:with-param name="break" select="$break"/>
          <xsl:with-param name="prefix" select="$prefix"/>
          <xsl:with-param name="pseudo-variable-number-offset" 
            select="$pseudo-variable-number-offset"/>
        </xsl:call-template>        
      </xsl:when>
      <!-- For the implied ref after the prefix -->
      <xsl:when test="$prefix">
        <xsl:value-of select="$break"/>
        <xsl:text>ASTNodeAddChild( $$, $</xsl:text>
        <xsl:value-of select="$count+1+$pseudo-variable-number-offset"/>
        <xsl:text> ); </xsl:text>  
      </xsl:when>      
    </xsl:choose>

  </xsl:template>
  
  <xsl:template name="additional-user-code">
     <xsl:text>
        <![CDATA[/* ===== USER CODE BEGIN ====== */
SimpleNode ASTNodeCreate(int id)
{
	return new SimpleNode(this, id);
}

// this one is a (probably temporary) hack
SimpleNode ASTNodeCreate(Object node)
{
	return (SimpleNode)node;
}

void ASTNodeAddChild( SimpleNode parent, SimpleNode child )
{
	parent.jjtAddChild(child, parent.jjtGetNumChildren());
}

void ASTNodeAddChild( Object parent, Object child )
{
	ASTNodeAddChild( (SimpleNode) parent, (SimpleNode) child );
}

void ASTNodeSetValueToString( Object astn, String val )
{
  ((SimpleNode)astn).m_value = val;
}

void ASTNodeSetValueToNumber( Object astn, String val )
{
  ((SimpleNode)astn).m_value = val;
}

void ASTNodeSetValueToID( Object astn, int val )
{
	// TODO: Confirm ASTNodeSetValueToID is correct.
	((SimpleNode)astn).m_value = new Integer(val);
}

int ASTNodeGetID( Object astn )
{
  return ((SimpleNode)astn).id;
}


/* ===== USER CODE END ====== */
        ]]> 
     </xsl:text>
  </xsl:template>

  <!-- Default command line function -->
  <xsl:template name="command-line-main"><!--
    <xsl:text><![CDATA[extern FILE *yyin;
      
int main(int c, char **v)
{
  int maxsz = 1028*4;
  char* buf = (char*)malloc(maxsz+1);
  int bufPos = 0;
  char ch;
  void* xpathLexer;
  SimpleNode tree;

  fprintf(stdout, "]]></xsl:text><xsl:value-of select="$spec"/>
  <xsl:text><![CDATA[ parser!");

  yydebug = 0;

  while(1) {
    fprintf(stdout, "\nEnter expression:\n");

  while(((ch = fgetc(stdin)) != '\n') && (bufPos < maxsz))
    {
      buf[bufPos++] = ch;
    }
    buf[bufPos] = '\0';

    if(0 == bufPos)
      break;

    xpathLexer = newXPathLexerFromCharBuf(buf, bufPos, 0);
    if(c > 1)
    {
      int i;
      for(i = 1; i < c; i++)
      {
        if(strcmp(v[i], "-debug") == 0)
        {
          yydebug = 1;
          fprintf(stdout, "\nSetting yydebug to 1!\n");
        }
        else if(strcmp(v[i], "-debuglex") == 0)
        {
          setDebug(xpathLexer, 1);
          fprintf(stdout, "\nSetting yy_flex_debug to 1!\n");
        }
      }
    }
    yyparse(xpathLexer);
    tree = getCurrentASTNode(xpathLexer);
    if(0 != tree)
    {
      ASTNodeDump(tree, stdout, "| ");
      ASTNodeDelete(tree);
    }
    freeXPathLexer(xpathLexer);
    bufPos = 0;
  }
  free(buf);
  buf = 0;

  return 0;
}
]]></xsl:text>    
  --></xsl:template>



</xsl:stylesheet>
