<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   " ">
<!ENTITY bsp   " ">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
  xmlns:xalan="http://xml.apache.org/xslt"
  exclude-result-prefixes="g xalan">
  <!-- $Id: grammar2spec.xsl,v 1.108 2016/06/29 14:56:59 mdyck Exp $ -->

  <!-- * Copyright (c) 2002 World Wide Web Consortium,
       * (Massachusetts Institute of Technology, Institut National de
       * Recherche en Informatique et en Automatique, Keio University). All
       * Rights Reserved. This program is distributed under the W3C's Software
       * Intellectual Property License. This program is distributed in the
       * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
       * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
       * PURPOSE.
       * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
       * -->

  <!-- FileName: grammar2spec.xsl -->
  <!-- Creator: Scott Boag -->
  <!-- Purpose: Transforms documents that conform to grammar.dtd to
       a document that conforms to xmlspec.dtd, in particular
       the prod elements. -->

  <!-- 2008-09-23: In template add-nt-link, Jim and Jonathan added a predicate
       to ensure that $lang-id has only a single NCName as a value, not a
       sequence of NCNames (e.g., 'xquery' instead of 'xquery update'). -->
  <!-- 2008-09-23: Jim and Jonathan replaced:
         <xsl:variable name="left-name" select="(../following-sibling::g:level/*/@name)"/>
       with:
         <xsl:variable name="left-name" select="(../following-sibling::g:level/*/@name)[1]"/>
       as proposed by Michael Dyck in email to resolve a problem that causes IDREF values
       used in attributes to contain more than one NCName. -->
  <!-- 2008-09-25: Jim and Jonathan replaced version="2.0" with version="1.0" - -
       there is no reason for this stylesheet to be marked 2.0, plus the behavior of
       some expressions changed between 1.0 processors and 2.0 processors...which is
       the reason for the other two changes, adding predicate [1] in two places. -->

  <xsl:output method="xml" indent="no" xalan:indent-amount="2"
              doctype-system = "../../../schema/xsl-query.dtd" />

  <!-- Specifies the desired grammar subset for many targets. -->
  <!-- xsl:param name="spec" select="'xpath'"/ -->

  <!-- xsl:variable name="grammar" select="/"/ -->

  <xsl:param name="tokens-file" select="'tokens.xml'"/>
  
  <xsl:param name="is-xslt30" select="false()"/>

  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

  <!--
    For the purposes of this stylesheet, a "definition" is:
      - a g:production,
      - a child of g:level (g:binary, g:prefix, g:postfix, g:primary), or
      - a g:token.
    (Normally, one might refer to these all as "productions", but that might
    be misconstrued to only refer to g:production elements.)

    A definition is "visible" if:
      - it does not have @show='no', and
      - if it's a g:token,
        - it has @inline='false', and
        - it does not have @visible='false'.

    Visible definitions are the ones that can be referenced to pull EBNF into
    specifications.

    The following keys collect all (and only) the visible definitions of a given
    grammar (i.e., whichever grammar contains the context node when the key()
    function is called).
  -->

  <xsl:key name="visible_nonterminal_defns"
    match="g:*[
            self::g:production
            or parent::g:level
           ][not(@show='no')]"
    use="''"/>

  <xsl:key name="visible_nonterminal_defns_by_name"
    match="g:*[
            self::g:production
            or parent::g:level
           ][not(@show='no')]"
    use="@name"/>

  <xsl:key name="visible_terminal_defns"
    match="
      g:token[
        @inline='false'
        and not(@visible='false')
        and not(@show='no')
      ]"
    use="''"/>

  <xsl:key name="visible_terminal_defns_by_name"
    match="
      g:token[
        @inline='false'
        and not(@visible='false')
        and not(@show='no')
      ]"
    use="@name"/>

  <!--
    In the above 2 xsl:keys, "and not(@visible='false')" is there for
    when this stylesheet is used with grammar-10/xpath-grammar.xml,
    which still has 'visible' attributes.
    (In grammar-30, they've been phased out.)
  -->

  <xsl:key name="defns_by_name" match="g:token
                             |g:production
                             |g:exprProduction/g:level/*"
    use="@name"/>

  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

  <!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>XSLT Processor: </xsl:text>
      <xsl:value-of select="system-property('xsl:vendor')"/>
      <xsl:if test="system-property('xsl:version') = '2.0'">
        <xsl:text> </xsl:text>
        <xsl:value-of select="system-property('xsl:product-name')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:message><xsl:value-of select="$XSLTprocessor"/></xsl:message>
    <xsl:comment><xsl:value-of select="$XSLTprocessor"/></xsl:comment>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- When processing the g:grammar as input, this template wraps the
       productions in a minimal xmlspec document. -->
  <xsl:template match="g:grammar">
    <spec>
      <header>
        <title>XPath/XQuery Grammar</title>
        <w3c-designation>Scratch Document</w3c-designation>
        <w3c-doctype>Scratch Document</w3c-doctype>
        <pubdate>
          <month>March</month>
          <year>2003</year>
        </pubdate>
        <publoc>http://www.w3.org/Style/XSL/Group/xpath2-tf/xpath-grammar.xml</publoc>
        <authlist>
          <author>
            <name>Scott Boag</name>
          </author>
        </authlist>
        <status><p>scratch</p></status>
        <abstract><p>dummy</p></abstract>
        <langusage><language>english</language></langusage>
        <revisiondesc><p>1.0</p></revisiondesc>
      </header>
      <body>
        <div1>
          <head>BNF</head>
          <scrap>
            <head>NAMED TERMINALS</head>
            <xsl:call-template name="add-terminals"/>
          </scrap>
          <scrap>
            <head>NON-TERMINALS</head>
            <xsl:call-template name="add-non-terminals"/>
          </scrap>
        </div1>
      </body>
    </spec>
  </xsl:template>

  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
  <!--
    This section includes the templates that are invoked from outside this
    stylesheet (marked with "EXPORT"), plus some of their "helper" templates.
  -->

  <!-- EXPORT -->
  <xsl:template name="show-defined-tokens">
    <xsl:param name="type"/>
    <xsl:call-template name="show-dt">
      <xsl:with-param name="type" select="$type"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="show-dt">
    <xsl:param name="type"/>

    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>

    <!--
    <xsl:message>DEBUG: Starting template show-dt. </xsl:message>
    <xsl:message>DEBUG: template show-dt ~~ $type = <xsl:value-of select="$type"/>. </xsl:message>
    -->
    <xsl:for-each select="document($tokens-file,.)/token-list/token[@type = $type]">
      <xsl:choose>
        <xsl:when test="@expo-name and string-length(.) = 0">
          <xsl:variable name="expo-name" select="@expo-name"/>
          <xsl:for-each select="$grammar">
            <xsl:call-template name="add-nt-link">
              <xsl:with-param name="docprod_part" select="'prod-'"/>
              <xsl:with-param name="symbol_ename" select="$expo-name"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="c" select="substring(self::node(), 1, 1)"/>
          <xsl:choose>
            <xsl:when test="string-length(self::node()) = 1">
              <xsl:choose>
                <xsl:when test="$c = ','">(comma)</xsl:when>
                <xsl:when test="$c = '.'">(dot)</xsl:when>
                <xsl:when test="$c = ':'">(colon)</xsl:when>
                <xsl:when test="$c = ';'">(semi-colon)</xsl:when>
                <xsl:otherwise>
                  <xsl:text>"</xsl:text>
                  <xsl:value-of select="."/>
                  <xsl:text>"</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>"</xsl:text>
              <xsl:value-of select="."/>
              <xsl:text>"</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>

    <!--
    <xsl:message>DEBUG: Exiting template show-dt. </xsl:message>
    -->
  </xsl:template>

  <!-- ===================================================================== -->

  <!-- EXPORT -->
  <xsl:template name="show-tokens-transition-to-state">
    <glist>
      <xsl:variable name="whichLang" select="/g:grammar/g:language/@id"/>
      <xsl:for-each select="/g:grammar/g:state-list/g:state[not(@show='no')]">
        <xsl:variable name="rstate" select="@name"/>

        <xsl:variable name="header-id">
          <xsl:text>state-</xsl:text>
          <xsl:choose>
            <xsl:when test="starts-with($rstate, '#')">
              <xsl:value-of select="substring($rstate, 2)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$rstate"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="description" select="g:description/node()"/>
        <xsl:variable name="recognizeTestString" select="concat(' ', normalize-space($rstate), ' ')"/>

        <xsl:variable name="delimiters" select="' &#x9;&#10;'"/>
        <gitem id="{$rstate}_{$whichLang}">
          <xsl:call-template name="add-role-attribute">
            <xsl:with-param name="default-class" select="'note'"/>
          </xsl:call-template>
          <label>The <xsl:value-of select="$rstate"/> State</label>
          <def>
            <p>
              <xsl:apply-templates select="$description"/>
            </p>
            <p>
              <table border = "1" summary="Transition table">
                <thead>
                  <tr>
                    <th>Pattern</th>
                    <th>Transition To State</th>
                    <!-- th>Explanation</th -->
                  </tr>
                </thead>
                <tbody>
                  <xsl:for-each select="g:transition[g:tref[key('defns_by_name', @name)]]">
                    <tr>
                      <td>
                        <xsl:for-each select="g:tref[not(@show='no') and key('defns_by_name', @name)]">
                          <xsl:choose>
                            <xsl:when test="@name = 'NotOccurrenceIndicator'">
                              <xsl:text>[</xsl:text>
                              <xsl:value-of select="@name"/>
                              <xsl:text>]</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="apply-refs">
                                <xsl:with-param name="wrapper-name" select="'phrase'"/>
                                <xsl:with-param name="string" select="@name"/>
                              </xsl:call-template>
                              <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                              </xsl:if>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </td>
                      <td>
                        <table summary="Transition table">
                          <tbody>
                            <xsl:if test="@action">
                              <tr>
                                <td>
                                  <loc>
                                    <xsl:attribute name="href">
                                      <xsl:choose>
                                        <xsl:when test="@action='pushState' or @action='pushState()'">
                                          <xsl:text>#lexaction-pushstate</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@action, 'pushState(')">
                                          <xsl:text>#lexaction-pushstate-with-param</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@action, 'popState')">
                                          <xsl:text>#lexaction-popstate</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@action, 'input_stream.backup')">
                                          <xsl:text>#lexaction-backup</xsl:text>
                                        </xsl:when>
                                      </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="@action"/>
                                    <xsl:if test="not(contains(@action, '('))">
                                      <xsl:text>()</xsl:text>
                                    </xsl:if>
                                  </loc>
                                </td>
                              </tr>
                            </xsl:if>
                            <xsl:choose>
                              <xsl:when test="@next-state">
                                <tr>
                                  <td>
                                    <loc href="#{@next-state}_{$whichLang}">
                                      <xsl:value-of select="@next-state"/>
                                    </loc>
                                  </td>
                                </tr>
                              </xsl:when>
                              <xsl:when test="not(@action)">
                                <tr>
                                  <td>
                                    <loc href="#lexaction-maintain-state">
                                      <xsl:text>(maintain state)</xsl:text>
                                    </loc>
                                  </td>
                                </tr>
                              </xsl:when>
                            </xsl:choose>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </xsl:for-each>
                </tbody>
              </table>
            </p>
            <!-- p>&#160;</p -->
          </def>
        </gitem>
      </xsl:for-each>
    </glist>
  </xsl:template>

  <!-- Try to apply a space-delimited list of references to tokens. -->
  <xsl:template name="apply-refs">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="string" select="''"/>
    <xsl:param name="delimiters" select="' &#x9;&#10;'"/>
    <xsl:param name="count" select="0"/>

    <xsl:variable name="delimiter"
      select="substring($delimiters, 1, 1)"/>
    <!-- xsl:message>
      <xsl:value-of select="$string"/>
    </xsl:message -->
    <xsl:choose>
      <xsl:when test="not($delimiter)">
        <xsl:variable name="ref" select="(/g:grammar//g:ref[$string=@name]|/g:grammar//g:xref[$string=@name])[1]"/>
        <xsl:choose>
          <xsl:when test="$ref">
            <xsl:choose>
              <xsl:when test="$string=normalize-space('Prefix') or $string=normalize-space('LocalPart')">
                <!-- no action? -->
              </xsl:when>
              <xsl:when test="key('defns_by_name', $string)">
                <xsl:for-each select="$ref">
                  <xsl:call-template name="g:ref">
                    <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
                    <xsl:with-param name="docprod_part" select="'prod-'"/>
                    <xsl:with-param name="conn-cur" select="$conn-top"/>
                    <xsl:with-param name="conn-new" select="$conn-top"/>
                    <xsl:with-param name="show-no-shows" select="true()"/>
                  </xsl:call-template>
                </xsl:for-each>
                <!-- br/ -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>
                  <xsl:text>"</xsl:text>
                  <xsl:value-of select="$string"/>
                  <xsl:text>"</xsl:text>
                  <xsl:text> is not used in transition table!!!!</xsl:text>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <!-- Note that in particular is can occur in the case of ExprCommentStart etc.,
                 where there is no other reference to it.  I can also occur in the case of
                 tokens that are not referenced by mistake.  There may be a way of testing
                 for this case.  -->
            <xsl:value-of select="$string"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:if test="not(starts-with($string, $delimiter))">
          <xsl:call-template name="apply-refs">
            <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
            <xsl:with-param name="string" select="substring-before($string, $delimiter)"/>
            <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
            <xsl:with-param name="count" select="$count+1"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="apply-refs">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
          <xsl:with-param name="delimiters" select="$delimiters"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="apply-refs">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="string" select="$string"/>
          <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ===================================================================== -->

  <!-- EXPORT -->
  <xsl:template name="add-non-terminals">
    <xsl:param name="orig"/>

    <xsl:for-each select="key('visible_nonterminal_defns', '')">
      <xsl:call-template name="make-prod">
        <xsl:with-param name="orig" select="$orig"/>
        <xsl:with-param name="result_id_docprod_part" select="'prod-'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- EXPORT -->
  <xsl:template name="add-terminals">
    <xsl:param name="orig"/>
    <xsl:param name="xml-only" select="false()"/>
    <xsl:param name="do-local-terminals" select="false()"/>

    <xsl:for-each select="key('visible_terminal_defns', '')[(@is-local-to-terminal-symbol='yes')=$do-local-terminals]">
      <xsl:if test="not($xml-only) or @is-xml='yes'">
        <xsl:call-template name="make-prod">
          <xsl:with-param name="orig" select="$orig"/>
          <xsl:with-param name="result_id_docprod_part" select="'prod-'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- EXPORT -->
  <xsl:template name="show-prod">
    <xsl:param name="name"/>
    <xsl:param name="orig"/>
    <xsl:param name="result_id_noid_part"/>

    <xsl:variable name="production" select="key('defns_by_name', $name)
                            [not(@alias-for and not(@inline='false'))]"/>

    <xsl:if test="not($production)">
      <xsl:message>
        WARNING!! production with name="<xsl:value-of select="$name"/>" not found
      </xsl:message>
    </xsl:if>

    <xsl:for-each select="$production">
      <xsl:call-template name="make-prod">
        <xsl:with-param name="orig" select="$orig"/>
        <xsl:with-param name="result_id_noid_part" select="$result_id_noid_part"/>
        <xsl:with-param name="result_id_docprod_part" select="'doc-'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- -->

  <xsl:template name="make-prod">
    <xsl:param name="orig"/>
    <xsl:param name="result_id_noid_part" select="''"/>
    <xsl:param name="result_id_docprod_part"/> <!-- 'doc-' or 'prod-' -->

    <xsl:variable name="base_language_id" select="(/g:grammar/g:language/@id)[1]"/>
    <xsl:variable name="result_id_lang_part" select="concat($base_language_id, '-')"/>

    <!--
    <xsl:variable name="debugging" select="@name = 'ReplaceExpr' or @name = 'EscapeQuot'"/>
    <xsl:if test="$debugging">
      <xsl:message>Template *, name = <xsl:value-of select="@name"/>. orig = <xsl:value-of select="$orig"/>.
        result_id_noid_part    = '<xsl:value-of select="$result_id_noid_part"/>'
        result_id_docprod_part = '<xsl:value-of select="$result_id_docprod_part"/>'
      </xsl:message>
    </xsl:if>
    -->

    <xsl:text>&#xA;</xsl:text>
    <prod>
      <xsl:variable name="expo-name">
        <!--
        <xsl:if test="$debugging">
          <xsl:message>Checking <xsl:value-of select="@name"/></xsl:message>
        </xsl:if>
        -->
        <xsl:choose>
          <xsl:when test="@exposition-name">
            <!--
            <xsl:if test="$debugging">
              <xsl:message>Putting out lhs for <xsl:value-of select="@name"/> as <xsl:value-of select="@exposition-name"/></xsl:message>
            </xsl:if>
            -->
            <xsl:value-of select="@exposition-name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@name"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="num">
        <xsl:call-template name="make-absolute-nt-number">
          <xsl:with-param name="name" select="@name"/>
        </xsl:call-template>
        <xsl:value-of select="$orig"/>
      </xsl:attribute>

      <xsl:variable name="result_id_symbol_part" select="$expo-name"/>

      <xsl:attribute name="id">
        <xsl:variable name="computed-id">
          <xsl:value-of select="$result_id_noid_part"/>
          <xsl:value-of select="$result_id_docprod_part"/>
          <xsl:value-of select="$result_id_lang_part"/>
          <xsl:value-of select="$result_id_symbol_part"/>
        </xsl:variable>
        <!--
        <xsl:if test="$debugging">
          <xsl:message>^*^*^* The calculated id value is <xsl:value-of select="$computed-id"/>.</xsl:message>
        </xsl:if>
        -->
        <xsl:value-of select="$computed-id"/>
      </xsl:attribute>

      <xsl:call-template name="add-role-attribute"/>

      <lhs>
        <xsl:call-template name="add-role-attribute"/>
        <xsl:value-of select="$expo-name"/>
      </lhs>

      <rhs>
        <xsl:choose>
          <xsl:when test="@xhref">
            <xnt ref="{substring-after(@xhref, '#')}" spec="XML">
              <xsl:attribute name="spec">
                <xsl:choose>
                  <xsl:when test="contains(@xhref, 'REC-xml-names')">
                    <xsl:text>Names</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains(@xhref, 'REC-xml#')">
                    <xsl:text>XML</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message terminate="yes">
                      <xsl:text>Can't figure out spec for: </xsl:text>
                      <xsl:value-of select="@xhref"/>
                    </xsl:message>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:text>[</xsl:text>
              <xsl:value-of select="@xhref"/>
              <xsl:text>]</xsl:text>
            </xnt>
          </xsl:when>
          <xsl:when test="false()">
            <xnt href="{@xhref}" ref="{substring-after(@xhref, '#')}" spec="XML">[<xsl:value-of select="@xhref"/>]</xnt>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="wrap-with-rhs-group">
              <xsl:with-param name="wrapper-name" select="'rhs-group'"/>
              <xsl:with-param name="content">
                <xsl:apply-templates select=".">
                  <xsl:with-param name="docprod_part" select="$result_id_docprod_part"/>
                </xsl:apply-templates>
                <xsl:if test="@subtract-reg-expr">
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="@subtract-reg-expr"/>
                </xsl:if>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

      </rhs>

      <!--
        Production annotations.  Specifically:
          - extra-grammatical constraints (A.1.2),
          - grammar notes (A.1.3), and
          - whitespace annotations (A.2.4.2).

        In documents up to and including the 3.0 series,
        these annotations were omitted from the EBNF
        in the main body of the doc "to increase readability".

        But in the 3.1 series (and hypothetical future series),
        we show the annotations in the main body too.
        See Bug 29702.
      -->
      <xsl:if test="$result_id_docprod_part = 'prod-' or ends-with($base_language_id, '31')">
        <xsl:if test="@whitespace-spec">
          <xsl:call-template name="do-whitespace-comment"/>
        </xsl:if>
        <xsl:if test="@xgc-id">
          <!-- com -->
            <xsl:call-template name="apply-gns">
              <xsl:with-param name="string" select="@xgc-id"/>
              <xsl:with-param name="is-xgc" select="true()"/>
            </xsl:call-template>
          <!-- /com -->
        </xsl:if>
        <xsl:if test="@comment-id">
          <!-- com -->
            <xsl:call-template name="apply-gns">
              <xsl:with-param name="string" select="@comment-id"/>
            </xsl:call-template>
          <!-- /com -->
        </xsl:if>
      </xsl:if>
    </prod>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template name="make-absolute-nt-number">
    <!--
      Returns a number (positive integer or NaN).
    -->
    <xsl:param name="name" select="@ref"/>

    <xsl:choose>

      <xsl:when test="key('visible_terminal_defns_by_name', $name)">
        <xsl:for-each select="/g:grammar">
          <xsl:for-each select="key('visible_terminal_defns', '')">
            <xsl:if test="normalize-space(@name)=normalize-space($name)">
              <xsl:value-of select="position()+count(key('visible_nonterminal_defns', ''))"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>

      <xsl:when test="key('visible_nonterminal_defns_by_name', $name)">
        <xsl:for-each select="/g:grammar">
          <xsl:for-each select="key('visible_nonterminal_defns', '')">
            <xsl:if test="normalize-space(@name)=normalize-space($name)">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
        <xsl:message>
          template name="make-absolute-nt-number": No definition found for name '<xsl:value-of select="$name"/>'!
        </xsl:message>
        <xsl:value-of select="number('NaN')"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <xsl:template name="do-whitespace-comment">
    <com>
      <loc href="#ws-{@whitespace-spec}">
        <xsl:text>ws: </xsl:text>
        <xsl:value-of select="@whitespace-spec"/>
      </loc>
    </com>
  </xsl:template>

  <!-- Try and apply a space delimited list of references to tokens. -->
  <xsl:template name="apply-gns">
    <xsl:param name="string" select="''"/>
    <xsl:param name="delimiter" select="' '"/>
    <xsl:param name="count" select="0"/>
    <xsl:param name="is-xgc" select="false()"/>

    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:variable name="token" select="substring-before($string, $delimiter)"/>
        <com>
          <loc href="#parse-note-{$token}">
            <xsl:text>gn: </xsl:text>
            <xsl:value-of select="$token"/>
          </loc>
        </com>
        <xsl:call-template name="apply-gns">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$is-xgc">
        <!-- constraint def="parse-note-{$string}"/ -->
        <com>
          <loc href="#parse-note-{$string}">
            <xsl:text>xgs: </xsl:text>
            <xsl:value-of select="$string"/>
          </loc>
        </com>
      </xsl:when>
      <xsl:otherwise>
        <com>
          <loc href="#parse-note-{$string}">
            <xsl:text>gn: </xsl:text>
            <xsl:value-of select="$string"/>
          </loc>
        </com>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
  <!--
    This section includes "match" templates, arranged in a roughly top-down
    order.
  -->

  <xsl:template match="g:production">
    <xsl:param name="docprod_part"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="exp-prod"
      select="/g:grammar/g:exposition-production[@name=$name]"/>
    <xsl:choose>
      <xsl:when test="$exp-prod and $docprod_part = 'doc-'">
        <xsl:for-each select="$exp-prod">
          <xsl:call-template name="g:group">
            <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
            <xsl:with-param name="conn-cur" select="$conn-top"/>
            <xsl:with-param name="docprod_part" select="$docprod_part"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="g:group">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="conn-cur" select="$conn-top"/>
          <xsl:with-param name="docprod_part" select="$docprod_part"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->

  <xsl:template match="g:exprProduction">
    <xsl:param name="docprod_part"/>
    <xsl:for-each select="g:level[1]/*">
      <xsl:if test="position()!=1">
        <xsl:call-template name="linebreak"/>
        <xsl:text>|&nbsp;&nbsp;</xsl:text>
      </xsl:if>
      <xsl:call-template name="output-spec-based-next">
        <xsl:with-param name="docprod_part" select="$docprod_part"/>
        <xsl:with-param name="level-list" select=".. | ../following-sibling::g:level"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- 2008-09-23: Jim and Jonathan replaced:
         <xsl:variable name="left-name" select="(../following-sibling::g:level/*/@name)"/>
       with:
         <xsl:variable name="left-name" select="(../following-sibling::g:level/*/@name)[1]"/>
       as proposed by Michael Dyck in email to resolve a problem that causes IDREF values
       used in attributes to contain more than one NCName.
  -->
  <xsl:template match="g:postfix">
    <xsl:param name="docprod_part"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:variable name="left-name" select="(../following-sibling::g:level/*/@name)[1]"/>
    <xsl:call-template name="add-nt-link">
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="symbol_ename" select="$left-name"/>
    </xsl:call-template>
    <xsl:text>&nbsp;</xsl:text>
    <xsl:text>(&nbsp;</xsl:text>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="conn-cur" select="$conn-seq"/>
    </xsl:call-template>
    <xsl:text>&nbsp;)</xsl:text>

    <xsl:choose>
      <xsl:when test="@prefix-seq-type">
        <xsl:value-of select="@prefix-seq-type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="g:prefix" name="g:prefix">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>
    <xsl:variable name="next-name" select="following-sibling::*/@name"/>
    <xsl:variable name="right-name" select="../following-sibling::g:level/*/@name"/>
    <xsl:variable name="should-paren" select="g:sequence"/>
    <xsl:if test="$should-paren">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="conn-cur" select="$conn-seq"/>
    </xsl:call-template>
    <xsl:if test="$should-paren">
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@prefix-seq-type">
        <xsl:value-of select="@prefix-seq-type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&nbsp;</xsl:text>

    <xsl:call-template name="output-spec-based-next">
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="g:binary">
    <xsl:param name="docprod_part"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:call-template name="output-spec-based-next">
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
    <xsl:text>&nbsp;(&nbsp;</xsl:text>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="conn-cur" select="$conn-seq"/>
    </xsl:call-template>
    <xsl:text>&nbsp;&nbsp;</xsl:text>
    <xsl:call-template name="output-spec-based-next">
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
    <xsl:text>&nbsp;)</xsl:text>
    <xsl:choose>
      <xsl:when test="@prefix-seq-type">
        <xsl:value-of select="@prefix-seq-type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="g:primary">
    <xsl:param name="docprod_part"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:variable name="is-not-last" select="boolean(../following-sibling::g:level)"/>
    <xsl:if test="$is-not-last">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="conn-cur" select="$conn-top"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>

    <xsl:if test="$is-not-last">
      <xsl:text>) | </xsl:text>
      <xsl:call-template name="output-spec-based-next">
        <xsl:with-param name="docprod_part" select="$docprod_part"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:next">
    <xsl:param name="docprod_part"/>
    <!-- The assumption is this we're in a exprProduction,
         in a prefix, primary, etc., and want to call the next level. -->
    <!-- xsl:variable name="name" select="ancestor::g:exprProduction/@name"/ -->
    <xsl:variable name="name" select="ancestor::g:level/following-sibling::g:level/*/@name"/>

    <xsl:call-template name="add-nt-link">
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="symbol_ename" select="$name"/>
    </xsl:call-template>
  </xsl:template>

  <!-- -->

  <!--
  <xsl:template match="g:token">
    <xsl:param name="docprod_part"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>

    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="conn-cur" select="$conn-top"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
  </xsl:template>
  -->

  <xsl:template match="g:token">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>

    <xsl:choose>
      <xsl:when test="@alias-for">
        <xsl:choose>
          <xsl:when test="false()">
            <!-- for right now, never expand, but treat like a production. -->
            <xsl:apply-templates select="key('defns_by_name', @alias-for)">
              <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
              <xsl:with-param name="docprod_part" select="$docprod_part"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="g:ref">
              <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
              <xsl:with-param name="docprod_part" select="$docprod_part"/>
              <xsl:with-param name="tname" select="key('defns_by_name', @alias-for)/@name"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="g:group">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="conn-cur" select="$conn-top"/>
          <xsl:with-param name="docprod_part" select="$docprod_part"/>
        </xsl:call-template>
        <!-- xsl:if test="@subtract-reg-expr" -->
        <!-- xsl:text> - z</xsl:text -->
        <!-- xsl:value-of select="@subtract-reg-expr"/ -->
        <!-- /xsl:if -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->

  <xsl:template match="g:choice">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>
    <xsl:param name="conn-cur" select="$conn-none"/>
    <xsl:param name="conn-new" select="$conn-seq"/>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="conn-new" select="$conn-or"/>
      <xsl:with-param name="conn-cur" select="$conn-cur"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="g:sequence">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>
    <xsl:param name="conn-cur" select="$conn-none"/>
    <xsl:param name="conn-new" select="$conn-seq"/>

    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
      <xsl:with-param name="conn-new" select="$conn-seq"/>
      <xsl:with-param name="conn-cur" select="$conn-cur"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="g:optional">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>
    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
    <xsl:text>?</xsl:text>
  </xsl:template>

  <xsl:template match="g:zeroOrMore">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>

    <xsl:if test="@subtract-reg-expr">
      <xsl:text>(</xsl:text>
    </xsl:if>

    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
    <xsl:text>*</xsl:text>

    <xsl:if test="@subtract-reg-expr">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="@subtract-reg-expr"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:oneOrMore">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>

    <xsl:if test="@subtract-reg-expr">
      <xsl:text>(</xsl:text>
    </xsl:if>

    <xsl:call-template name="g:group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="docprod_part" select="$docprod_part"/>
    </xsl:call-template>
    <xsl:text>+</xsl:text>

    <xsl:if test="@subtract-reg-expr">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="@subtract-reg-expr"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- -->

  <xsl:template match="g:complement">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:text>[^</xsl:text>
    <xsl:apply-templates select="g:charClass/*">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
    </xsl:apply-templates>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="g:charClass">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:variable name="isSeq" select="count(g:*)&gt;1 and (parent::g:oneOrMore or parent::g:zeroOrMore) and count(parent::*/*) = 1"/>
    <xsl:if test="$isSeq">
      <xsl:text>[</xsl:text>
    </xsl:if>
    <xsl:for-each select="g:*">

      <xsl:apply-templates select=".">
        <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      </xsl:apply-templates>

      <!-- xsl:if test="last() != position()"><xsl:text> |&nbsp;</xsl:text></xsl:if -->
    </xsl:for-each>
    <xsl:if test="$isSeq">
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="g:charClass[g:charRange]">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:variable name="isSeq"
      select="count(g:*)>1 and (parent::g:oneOrMore or parent::g:zeroOrMore) and count(parent::*/*) = 1"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="g:*">

      <xsl:apply-templates select=".">
        <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      </xsl:apply-templates>

    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!--
  <xsl:template match="g:charClass[count(g:*) > 1]">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:text>(</xsl:text>
    <xsl:for-each select="g:*">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select=".">
        <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      </xsl:apply-templates>
      <xsl:text>]</xsl:text>
      <xsl:if test="last() != position()">
        <xsl:text> |&nbsp;</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>
  -->

  <xsl:template match="g:charClass[count(g:char) > 1]">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="g:*">
      <!-- xsl:text>"</xsl:text -->
      <xsl:apply-templates select=".">
        <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      </xsl:apply-templates>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="g:charCode">
    <xsl:text>#x</xsl:text>
    <xsl:value-of select="translate(@value, 'abcdef', 'ABCDEF')"/>
  </xsl:template>

  <xsl:template match="g:charCodeRange">
    <xsl:text>#x</xsl:text>
    <xsl:value-of select="translate(@minValue, 'abcdef', 'ABCDEF')"/>
    <xsl:text>-#x</xsl:text>
    <xsl:value-of select="translate(@maxValue, 'abcdef', 'ABCDEF')"/>
  </xsl:template>

  <xsl:template match="g:charRange">
    <xsl:value-of select="@minChar"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@maxChar"/>
  </xsl:template>

  <xsl:template match="g:sequence/g:char[not(@complement='yes')]">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:call-template name="wrap-with-rhs-group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="content">
        <xsl:call-template name="add-string"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="g:char">
    <xsl:if test="@complement='yes'">
      <xsl:text>~</xsl:text>
    </xsl:if>
    <!-- bit of a hack here... -->
    <xsl:if test="../@subtract-reg-expr">
      <xsl:text>(</xsl:text>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@force-quote='single'">
        <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:when test="@force-quote='double'">
        <xsl:text>"</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:value-of select="."/>

    <xsl:choose>
      <xsl:when test="@force-quote='single'">
        <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:when test="@force-quote='double'">
        <xsl:text>"</xsl:text>
      </xsl:when>
    </xsl:choose>


    <!-- bit of a hack here... -->
    <xsl:if test="../@subtract-reg-expr">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="../@subtract-reg-expr"/>
      <xsl:text>)</xsl:text>
    </xsl:if>

  </xsl:template>

  <xsl:template match="g:emph">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- -->

  <xsl:template match="g:string">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:call-template name="wrap-with-rhs-group">
      <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
      <xsl:with-param name="content">
        <xsl:call-template name="add-string"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="g:ref|g:xref" name="g:ref">
    <xsl:param name="docprod_part"/>
    <xsl:param name="conn-cur" select="$conn-none"/>
    <xsl:param name="conn-new" select="$conn-seq"/>
    <xsl:param name="show-no-shows" select="false()"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="tname" select="@name"/>

    <xsl:variable name="deref" select="key('defns_by_name', $tname)"/>

    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="$deref/@exposition-name">
          <xsl:value-of select="$deref/@exposition-name"/>
        </xsl:when>
        <xsl:when test="$deref/@alias-for">
          <xsl:variable name="de-aliased" select="key('defns_by_name',$deref/@alias-for)"/>
          <xsl:choose>
            <xsl:when test="$de-aliased/@exposition-name">
              <xsl:value-of select="$de-aliased/@exposition-name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$deref/@inline = 'false'">
                  <xsl:value-of select="$deref/@name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$de-aliased/@name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tname"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="needs-exposition-parens"
      select="@needs-exposition-parens='yes'"/>

    <xsl:if test="$show-no-shows or not(@show = 'no')">
      <xsl:if test="@subtract-reg-expr">
        <xsl:text>(</xsl:text>
      </xsl:if>

        <xsl:variable name="deref2" select="key('defns_by_name',$name)"/>
        <xsl:variable name="inlineable_token" select="$deref2[self::g:token and not(@inline='false')]"/>

        <xsl:choose>
          <xsl:when test="not($inlineable_token)">
            <xsl:call-template name="add-nt-link">
              <xsl:with-param name="docprod_part" select="$docprod_part"/>
              <xsl:with-param name="symbol_ename" select="$name"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="wrap-with-rhs-group">
              <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
              <xsl:with-param name="content">
                <xsl:choose>
                  <xsl:when test="$needs-exposition-parens">
                    <xsl:text>(</xsl:text>
                  </xsl:when>
                </xsl:choose>
                <xsl:for-each select="$inlineable_token">
                  <xsl:call-template name="g:group">
                    <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
                    <xsl:with-param name="docprod_part" select="$docprod_part"/>
                    <!-- xsl:with-param name="conn-new" select="$conn-seq"/ -->
                    <xsl:with-param name="conn-new" select="$conn-seq"/>
                    <!-- xsl:with-param name="conn-cur" select="$conn-cur"/ -->
                    <xsl:with-param name="conn-cur" select="$conn-seq"/>
                  </xsl:call-template>
                </xsl:for-each>
                <xsl:choose>
                  <xsl:when test="$needs-exposition-parens">
                    <xsl:text>)</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

      <!-- xsl:when test="$deref/@alias-for and $deref/@subtract-reg-expr">
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$deref/@subtract-reg-expr"/>
      </xsl:when -->

      <!-- bit of a hack here... -->
      <xsl:if test="@subtract-reg-expr">
        <xsl:text> - </xsl:text>
        <xsl:value-of select="@subtract-reg-expr"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
  <!--
    This section includes various low-level named templates.
  -->

  <xsl:variable name="conn-none" select="0"/>
  <xsl:variable name="conn-or" select="1"/>
  <xsl:variable name="conn-seq" select="2"/>
  <xsl:variable name="conn-top" select="3"/>

  <xsl:template name="g:group">
    <xsl:param name="wrapper-name" select="'rhs-group'"/>
    <xsl:param name="docprod_part"/>
    <xsl:param name="conn-cur" select="$conn-none"/>
    <xsl:param name="conn-new" select="$conn-seq"/>
    <xsl:variable name="isExpo" select="$docprod_part = 'doc-'"/>

    <xsl:variable name="group" select="*[not(@show='no')]"/>
    <xsl:choose>
      <xsl:when test="count($group)>1
          and $conn-new != $conn-cur
          and $conn-cur != $conn-top">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="g:group">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="docprod_part" select="$docprod_part"/>
          <xsl:with-param name="conn-new" select="$conn-new"/>
          <xsl:with-param name="conn-cur" select="$conn-new"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="count($group)>1">
        <xsl:for-each select="$group">
          <xsl:if test="position() != 1">
            <xsl:choose>
              <xsl:when test="$conn-new=$conn-seq"><xsl:text>&bsp;&bsp;</xsl:text></xsl:when>
              <xsl:when test="../@break[.='true']"><xsl:call-template name="linebreak"/>|&nbsp;&nbsp;</xsl:when>
              <xsl:otherwise><xsl:text>&bsp;&bsp;|&nbsp;&nbsp;</xsl:text></xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:apply-templates select=".">
            <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
            <xsl:with-param name="docprod_part" select="$docprod_part"/>
            <xsl:with-param name="conn-new" select="$conn-new"/>
            <xsl:with-param name="conn-cur" select="$conn-new"/>
          </xsl:apply-templates>
          <xsl:if test="not($isExpo)">
            <xsl:call-template name="add-lookahead-notation"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$group">
          <xsl:with-param name="wrapper-name" select="$wrapper-name"/>
          <xsl:with-param name="docprod_part" select="$docprod_part"/>
          <xsl:with-param name="conn-new" select="$conn-new"/>
          <xsl:with-param name="conn-cur" select="$conn-cur"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-lookahead-notation">
    <xsl:param name="lh" select="@lookahead"/>
    <xsl:param name="option" select="."/>
    <xsl:param name="choice" select="parent::g:choice"/>
    <xsl:if test="false() and $lh">
      <xsl:if test="not($choice) or not(generate-id($choice/*[position()=last()]) = generate-id($option))">
        <xsl:choose>
          <xsl:when test="$lh = 1">
            <sup>
              <xsl:text>CC</xsl:text>
            </sup>
          </xsl:when>
          <xsl:otherwise>
            <sup>
              <xsl:text>L</xsl:text>
              <xsl:value-of select="$lh"/>
            </sup>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="output-spec-based-next">
    <xsl:param name="docprod_part"/>
    <xsl:param name="level-list" select="../following-sibling::g:level"/>
    <xsl:param name="left-name" select="($level-list/*)[1]/@name"/>
    <xsl:choose>
      <xsl:when test="$left-name[1]/../@if[not(contains(., 'xquery') and contains(., 'xpath'))]
                      and $spec='shared'">
        <xsl:for-each select="$left-name[position() &lt; 3]">

          <xsl:variable name="which-spec">
            <xsl:choose>
              <xsl:when test="contains(../@if, 'xquery') and contains(../@if, 'xpath')">
                <xsl:choose>
                  <xsl:when test="position()=1">
                    <xsl:text>xquery</xsl:text>
                  </xsl:when>
                  <xsl:when test="position()=2">
                    <xsl:text>xpath</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="contains(../@if, 'xquery')">
                <xsl:text>xquery</xsl:text>
              </xsl:when>
              <xsl:when test="contains(../@if, 'xpath')">
                <xsl:text>xpath</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="position()=1">
                    <xsl:text>xquery</xsl:text>
                  </xsl:when>
                  <xsl:when test="position()=2">
                    <xsl:text>xpath</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!--
            Note that there isn't any reference to the variable just defined.
            Many years ago (in xpath-query-src/grammar2spec.xsl), it was
            (in effect) passed to the following invocation of 'add-nt-link'.
            Maybe that should be reinstated.
          -->

          <xsl:call-template name="add-nt-link">
            <xsl:with-param name="docprod_part" select="$docprod_part"/>
            <xsl:with-param name="symbol_ename" select="."/>
          </xsl:call-template>

          <xsl:if test="not(position()=last())">
            <xsl:text>&nbsp;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="add-nt-link">
          <xsl:with-param name="docprod_part" select="$docprod_part"/>
          <xsl:with-param name="symbol_ename" select="$left-name"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-nt-link">
    <xsl:param name="docprod_part"/>
    <xsl:param name="symbol_ename"/>
    <xsl:param name="which-spec" select="ancestor-or-self::*[@if][1]/@if[contains(., $spec) or ($spec = 'shared')]"/>

    <xsl:if test="not($symbol_ename) or $symbol_ename=''">
      <xsl:message>In a call to add-nt-link, value passed to symbol_ename is empty!</xsl:message>
    </xsl:if>

    <!--
    <xsl:message>DEBUG: Starting template add-nt-link. </xsl:message>
    <xsl:message>DEBUG: ~~ $symbol_ename = <xsl:value-of select="$symbol_ename"/>. </xsl:message>
    <xsl:message>DEBUG: ~~ $spec = <xsl:value-of select="$spec"/>. </xsl:message>
    <xsl:message>DEBUG: ~~ $which-spec = <xsl:value-of select="local-name($which-spec)"/> and $which-spec/@if = <xsl:value-of select="$which-spec/@if"/>. </xsl:message>
    -->

    <nt>
      <!--
        Note that, for a specification that defines a language *extension*
        (e.g., Update or Full Text), /g:grammar/g:language will yield two
        (or more) element nodes, one for the base language and one for the
        extension. In such a case, /g:grammar/g:language/@id will also yield
        multiple nodes. Generally, it suffices to use the first, so we
        apply the predicate [1]. (With an XSLT 1.0 processor, the predicate
        wasn't necessary, since stringifying a node-set only stringifies
        the doc-order-first of its nodes.)
      -->
      <xsl:variable name="lang-id" select="(/g:grammar/g:language/@id)[1]"/>
      <!--
      <xsl:message>DEBUG: ~~ $lang-id = <xsl:value-of select="$lang-id"/>. </xsl:message>
      -->

      <xsl:variable name="idref_lang_part">
        <xsl:choose>
          <xsl:when test="@orig">
            <!--
                The only g:* elements that can have an @orig
                are g:ref ang g:xref.
                The only place they actually do is in xpath-semantics-30.
            -->
            <xsl:value-of select="@orig"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$lang-id"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>-</xsl:text>
      </xsl:variable>

      <xsl:variable name="docprod_part_adjusted">
        <xsl:choose>
          <xsl:when test="local-name(.) = 'xref' or $is-xslt30">
            <!--
              A reference to a symbol in another grammar.

              The assumptions seem to be that:
              (a) the other grammar does not appear in the appendix, so there
                  is no 'prod-' production for the referenced symbol, but
              (b) there is a 'doc-' production for it.
              So use 'doc-' instead of 'prod-' for the docprod_part.

              This is a hack for FS, whose formal-grammar.xml
              has the only uses of g:xref in qtspecs, and
              for which the above assumptions are partially true.
              
              Also use "doc-" for the XSLT 3.0 pattern grammar, which does
              not appear in an appendix.
            -->
            <xsl:text>doc-</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$docprod_part"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="idref_docprod_part">
        <xsl:choose>
          <xsl:when test="$docprod_part_adjusted = 'doc-'">
            <!-- Test to see if there is a prodrecap with this name.
                 If not, then link directly to the BNF in the
                 appendix.
                 -->
            <xsl:for-each select="$sourceTree">
              <xsl:choose>
                <xsl:when test="//prodrecap[@id=$symbol_ename] or $is-xslt30">
                  <xsl:text>doc-</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>prod-</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>

          <xsl:otherwise>
            <!-- assert: $docprod_part_adjusted = 'prod-' -->
            <xsl:text>prod-</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="def">
        <xsl:value-of select="$idref_docprod_part"/>
        <xsl:value-of select="$idref_lang_part"/>
        <xsl:value-of select="$symbol_ename"/>
      </xsl:attribute>

      <xsl:call-template name="add-role-attribute">
        <xsl:with-param name="which-spec" select="$which-spec"/>
      </xsl:call-template>

      <xsl:value-of select="$symbol_ename"/>
    </nt>
    <!--
    <xsl:message>DEBUG: Exiting template add-nt-link. </xsl:message>
    -->
  </xsl:template>

  <xsl:template name="wrap-with-rhs-group">
    <xsl:param name="content"/>
    <xsl:param name="wrapper-name" select="'rhs-group'"/>

    <xsl:choose>
      <xsl:when test="normalize-space($spec)!=normalize-space('shared')">
        <xsl:copy-of select="$content"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="which-spec"
          select="ancestor-or-self::*[@if][1]/@if[contains(., $spec)
                  or ($spec = 'shared')]"/>
        <xsl:choose>
          <xsl:when test="$which-spec and (contains($which-spec, 'xpath')
                          or contains($which-spec, 'xquery'))">
            <xsl:element name="{$wrapper-name}">
              <xsl:call-template name="add-role-attribute">
                <xsl:with-param name="which-spec" select="$which-spec"/>
              </xsl:call-template>
              <xsl:copy-of select="$content"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-role-attribute">
    <xsl:param name="which-spec" select="ancestor-or-self::*[@if][1]/@if[contains(., $spec) or ($spec = 'shared')]"/>
    <xsl:param name="default-class" select="''"/>

    <xsl:choose>
      <xsl:when test="$spec='shared'">
        <xsl:choose>
          <xsl:when test="$which-spec[ancestor::g:grammar]
                          and ((not(contains($which-spec, 'xpath')) and contains($which-spec, 'xquery'))
                          or  (not(contains($which-spec, 'xquery')) and contains($which-spec, 'xpath')))">
            <xsl:attribute name="role">
              <xsl:choose>
                <xsl:when test="contains($which-spec, 'xquery')">
                  <xsl:text>xquery</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>xpath</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <!-- xsl:attribute name="role">
              <xsl:text>shared</xsl:text>
            </xsl:attribute -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$default-class">
        <!-- xsl:attribute name="role">
          <xsl:value-of select="$default-class"/>
        </xsl:attribute -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-string">
    <xsl:choose>
      <xsl:when test="contains(.,'&quot;')">
        <xsl:text>'</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:when test='contains(.,"&apos;")'>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="linebreak">
    <br/>
  </xsl:template>

</xsl:stylesheet>
<!-- vim: sw=2 ts=2 expandtab
-->
