<?xml version="1.0" encoding="UTF-8"?>

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

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
    <xsl:import href="javacc.xsl"/>

    <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="other-javacc-options">
        MULTI=false;
        VISITOR=true ;     // invokes the JJTree Visitor support
        NODE_SCOPE_HOOK=false;
        NODE_USES_PARSER=true;
        NODE_PACKAGE="org.w3c.xqparser";
        NODE_PREFIX="";
    </xsl:template>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="parser-decls">
        package org.w3c.xqparser;

        import org.w3c.xqparser.Node;
        import org.w3c.xqparser.SimpleNode;
        import java.util.Stack;

        public class XParser {

            Stack _elementStack = new Stack();

            Stack binaryTokenStack = new Stack();

            void processToken(SimpleNode n, Token t)
            {
                <!-- TODO: These need to be done declarativly from the grammar file!!! -->
                <xsl:if test="not(/g:grammar/g:language/@id = 'xcore')">
                    if(t.kind == XParserConstants.Slash &amp;&amp; n.id != XParserTreeConstants.JJTSLASH)
                        return;
                </xsl:if>
                <xsl:if test="substring(/g:grammar/g:language/@id, 1, 6) = 'xquery'">
                    if(t.kind == XParserConstants.TagQName &amp;&amp; n.id != XParserTreeConstants.JJTTAGQNAME)
                        return;
                    if(t.kind == XParserConstants.S &amp;&amp; n.id != XParserTreeConstants.JJTS)
                        return;
                </xsl:if>
                n.processToken(t);
            }

            <xsl:if test="substring(/g:grammar/g:language/@id, 1, 6) = 'xquery'">
                void checkCharRef(String ref) throws ParseException
                {
                    String numeral = ref.substring(2, ref.length() - 1);
                    int val;
                    try {
                        if (numeral.charAt(0) == 'x') {
                            val = Integer.parseInt(numeral.substring(1), 16);
                        } else
                            val = Integer.parseInt(numeral);
                    } catch (NumberFormatException nfe) {
                        // "The string does not contain a parsable integer."
                        // Given the constraints imposed by the grammar/parser,
                        // I believe the only way this can happen is if the
                        // numeral is too long to fit in an 'int',
                        // which means that it's also too big to identify
                        // a valid character.
                        throw new ParseException(
                            "err:XQST0090: character reference does not identify a valid character: " + ref);
                    }

                    boolean isLegal = val == 0x9 || val == 0xA || val == 0xD
                        || (val &gt;= 0x20 &amp;&amp; val &lt;= 0xD7FF)
                        || (val &gt;= 0xE000 &amp;&amp; val &lt;= 0xFFFD)
                        || (val &gt;= 0x10000 &amp;&amp; val &lt;= 0x10FFFF);
                    if (!isLegal)
                        throw new ParseException(
                            "err:XQST0090: character reference does not identify a valid character: " + ref);
                }
            </xsl:if>


        }
    </xsl:template>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="production-for-start-symbol">
        SimpleNode START() :
        {}
        {
            <xsl:value-of select="g:start/@name"/>()&lt;EOF&gt;
            { if(this.token_source.curLexState == XParserConstants.EXPR_COMMENT)
                throw new ParseException("Unterminated comment.");
            return jjtThis ; }
        }
    </xsl:template>

    <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template match="g:sequence[not(*)]" priority="10"/>

    <xsl:template match="g:production" mode="production-java-block">
        <!-- Begin LV -->
        <xsl:if test="@prod-user-action">
            <xsl:value-of select="@prod-user-action"/>
        </xsl:if>
        <!-- End LV -->
    </xsl:template>

    <!-- xsl:template name="action-production-end">
    </xsl:template -->

    <xsl:template name="action-exprProduction-label">
        <xsl:if test="@node-type='void'">
            <xsl:text> #void </xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template name="action-exprProduction">
    </xsl:template>

    <xsl:template name="action-exprProduction-end">
    </xsl:template>

    <xsl:template match="g:level" mode="action-level">
        <xsl:param name="thisProd"/>
        <xsl:param name="nextProd"/>

        <xsl:if test="@level-user-action">
            <xsl:value-of select="@level-user-action"/>
        </xsl:if>
        <!-- xsl:text>
            printIndent(); System.err.println("</xsl:text>
            <xsl:value-of select="$thisProd"/>
            <xsl:text>");
        </xsl:text -->
    </xsl:template>

    <xsl:template name="action-level-jjtree-label">
        <xsl:param name="label">
            <xsl:text>void</xsl:text>
        </xsl:param>
        <!-- Begin SMPG -->
        <xsl:param name="condition"></xsl:param>
        <!-- End SMPG -->

        <xsl:text> #</xsl:text>
        <xsl:value-of select="$label"/>

        <!-- Begin SMPG -->
        <xsl:if test="$condition != ''">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="$condition"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
        <!-- End SMPG -->
    </xsl:template>

    <xsl:template name="binary-action-level-jjtree-label">
        <xsl:param name="label"/>
        <xsl:param name="which" select="'unknown'"/>
        <!-- xsl:message>
            <xsl:text>In binary-action-level-jjtree-label: </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text>  (</xsl:text>
            <xsl:value-of select="$which"/>
            <xsl:text>)</xsl:text>
        </xsl:message -->
        <xsl:if test="ancestor-or-self::g:binary or self::g:level/g:binary">
            <xsl:text>
                {
                    try
                    {
                        processToken(jjtThis, (Token)binaryTokenStack.pop());
                    }
                    catch(java.util.EmptyStackException e)
                    {
                        token_source.printLinePos();
                        e.printStackTrace();
                        throw e;
                    }
                }
            </xsl:text>
            <xsl:text> #</xsl:text><xsl:value-of select="$label"/><xsl:text>(2)</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="action-level-start">
    </xsl:template>

    <xsl:template match="*" mode="action-level-end">
    </xsl:template>

    <xsl:template name="action-token-ref">
        <!-- xsl:if test="ancestor::g:binary">
        <xsl:text> #</xsl:text><xsl:value-of select="@name"/>
        </xsl:if -->
        <xsl:choose>
            <xsl:when test="self::g:string">
                <xsl:if test="@process-value='yes' or @token-user-action or ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
                    <xsl:text>{</xsl:text>
                    <xsl:if test="@token-user-action">
                        <xsl:value-of select="@token-user-action"/>
                    </xsl:if>
                    <xsl:if test="@process-value='yes'">
                        <xsl:choose>
                            <xsl:when test="ancestor-or-self::*/@node-type='void' or key('map_name_to_defn',@name)/self::g:token/@node-type='void'">
                                <xsl:text>jjtThis.processValue("</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>jjtThis.processValue("</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test=". = '&quot;'">\</xsl:if>
                        <xsl:value-of select="."/>
                        <xsl:text>");</xsl:text>
                    </xsl:if>
                    <xsl:if test="ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
                        binaryTokenStack.push(token);
                    </xsl:if>
                    <xsl:text>}</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="not(ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes')">

                <xsl:choose>
                    <xsl:when test="@node-type='void' or key('map_name_to_defn',@name)/self::g:token/@node-type='void'">
                        <!-- Don't produce a node.  #void doesn't seem to work here, for some reason. -->
                        <xsl:text>{</xsl:text>
                        <xsl:if test="@token-user-action">
                            <xsl:value-of select="@token-user-action"/>
                        </xsl:if>
                        <xsl:text>processToken(((SimpleNode)jjtree.peekNode()), token);}</xsl:text>
                    </xsl:when>
                    <xsl:when test="key('map_name_to_defn',@name)/self::g:token/@node-type">
                        <xsl:text>{</xsl:text>
                        <xsl:if test="@token-user-action">
                            <xsl:value-of select="@token-user-action"/>
                        </xsl:if>
                        <xsl:text>processToken(jjtThis, token);}</xsl:text>
                        <xsl:text> #</xsl:text>
                        <xsl:value-of select="key('map_name_to_defn',@name)/self::g:token/@node-type"/>
                        <!-- See JTree doc for why I do the following... -->
                        <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
                            <xsl:text>(true)</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@node-type">
                        <xsl:text>{</xsl:text>
                        <xsl:if test="@token-user-action">
                            <xsl:value-of select="@token-user-action"/>
                        </xsl:if>
                        <xsl:text>processToken(jjtThis, token);}</xsl:text>
                        <xsl:text> #</xsl:text>
                        <xsl:value-of select="@node-type"/>
                        <!-- See JTree doc for why I do the following... -->
                        <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
                            <xsl:text>(true)</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>{</xsl:text>
                        <xsl:if test="@token-user-action">
                            <xsl:value-of select="@token-user-action"/>
                        </xsl:if>
                        <xsl:text>processToken(jjtThis, token);}</xsl:text>
                        <xsl:text> #</xsl:text>
                        <xsl:value-of select="@name"/>
                        <!-- See JTree doc for why I do the following... -->
                        <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
                            <xsl:text>(true)</xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>


            </xsl:when>
            <xsl:otherwise>
                <!-- xsl:message>
                    <xsl:text>In binary-action-level-jjtree-label: </xsl:text>
                    <xsl:value-of select="name(.)"/>
                </xsl:message -->
                {binaryTokenStack.push(token);}
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Begin LV -->
    <xsl:template match="g:ref" mode="user-action-ref-start">
        <xsl:if test="@nt-user-action-start">{<xsl:value-of select="@nt-user-action-start"/>}</xsl:if>
    </xsl:template>

    <xsl:template match="g:ref" mode="user-action-ref-end">
        <xsl:param name="addEnclose" select="true()"/>
        <xsl:if test="@nt-user-action-end">
            <xsl:if test="$addEnclose">{</xsl:if>
            <xsl:value-of select="@nt-user-action-end"/>
            <xsl:if test="$addEnclose">}</xsl:if>
        </xsl:if>
    </xsl:template>
    <!-- End LV -->

</xsl:stylesheet>
<!-- vim: sw=4 ts=4 expandtab
-->
