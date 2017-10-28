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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
  exclude-result-prefixes="g xlink"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:param name="spec" select="'xpath'"/>
  <xsl:param name="not-spec" select="''"/>
  <xsl:param name="grammar-file" select="'xpath-grammar.xml'"/>
  <xsl:param name="grammar-map-file-name">grammar-map.xml</xsl:param>

  <!-- xsl:variable name="grammar" select="document($grammar-file)"/ -->
  <xsl:variable name="sourceTree" select="/"/>
  <xsl:variable name="prodrecaps" select="//prodrecap"/>

  <!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{assemble-spec} </xsl:text>
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

  <xsl:template match="@*|node()[not(self::g:*)]" priority="-10000">
    <xsl:if test="self::node()[not(normalize-space($not-spec)=@role)]">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:include href="grammar2spec.xsl"/>

  <xsl:template name="get-gfn">
    <!-- Assumes predrecap context -->
    <xsl:variable name="k" select="@orig"/>
    <xsl:choose>
      <xsl:when test="$k">
        <xsl:variable name="gfn" select="document($grammar-map-file-name,.)//*[string(@name)=string($k)]"/>
        <xsl:value-of select="$gfn"/>
        <!--
        <xsl:message>
          <xsl:text>grammar file: </xsl:text><xsl:value-of select="$gfn"/>
          <xsl:text>, k: '</xsl:text><xsl:value-of select="$k"/><xsl:text>'</xsl:text>
        </xsl:message>
        -->
      </xsl:when>
      <xsl:when test="@at">
        <!--
        <xsl:message>
          <xsl:text>grammar file: </xsl:text><xsl:value-of select="@at"/>
          <xsl:text>, @at</xsl:text>
        </xsl:message>
        -->
        <xsl:value-of select="@at"/>
      </xsl:when>
      <xsl:otherwise>
        <!--
        <xsl:message>
          <xsl:text>grammar file: </xsl:text><xsl:value-of select="$grammar-file"/>
          <xsl:text>, global</xsl:text>
        </xsl:message>
        -->
        <xsl:value-of select="$grammar-file"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-gnotation">
    <!-- Assumes predrecap context -->
    <xsl:variable name="k" select="@orig"/>
    <xsl:choose>
      <xsl:when test="$k">
        <xsl:variable name="gfn" select="document($grammar-map-file-name,.)//*[string(@name)=string($k)]"/>
        <xsl:value-of select="$gfn/@notation"/>
        <!-- xsl:message>
          <xsl:text>grammar file: </xsl:text><xsl:value-of select="$gfn"/>
          <xsl:text>, k: '</xsl:text><xsl:value-of select="$k"/><xsl:text>'</xsl:text>
        </xsl:message -->
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="prodrecap[@id='DefinedLexemes' or @role='DefinedLexemes']">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>
    <xsl:for-each select="$grammar/g:grammar">
      <xsl:call-template name="add-terminals">
        <xsl:with-param name="orig" select="$orig"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="prodrecap[@id='LocalTerminalSymbols' or @role='LocalTerminalSymbols']">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>
    <xsl:for-each select="$grammar/g:grammar">
      <xsl:call-template name="add-terminals">
        <xsl:with-param name="orig" select="$orig"/>
        <xsl:with-param name="do-local-terminals" select="true()"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="prodrecap[@id='BNF-Grammar-prods' or @role='BNF-Grammar-prods']">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>

    <xsl:for-each select="$grammar/g:grammar">
      <xsl:call-template name="add-non-terminals">
        <xsl:with-param name="orig" select="$orig"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="prodrecap">

    <xsl:variable name="debugging" select="false()"/>
    <xsl:if test="$debugging">
      <xsl:comment>
        DEBUG: template match="prodrecap" starting
        $spec = '<xsl:value-of select="$spec"/>'
        @id   = '<xsl:value-of select="@id"/>'
        @ref  = '<xsl:value-of select="@ref"/>'
        @role = '<xsl:value-of select="@role"/>'
      </xsl:comment>
    </xsl:if>

    <xsl:variable name="name" select="@ref"/>

    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>

    <xsl:if test="$debugging">
      <xsl:comment>
        DEBUG: template match="prodrecap" ...
        $fn      = '<xsl:value-of select="$fn"/>'
        $grammar = [the document at $fn]
        $orig    = '<xsl:value-of select="$orig"/>'
      </xsl:comment>
    </xsl:if>

    <xsl:variable name="result_id_noid_part">
      <xsl:if test="not(@id)">
        <!-- pull some nasty trick to handle multiply defined productions. -->
        <!-- Don wants this... -->
        <!-- Don't change the 'noid_' text... "lhs-text" template depends on it. -->
        <xsl:value-of select="concat('noid_', generate-id(.), '.')"/>
      </xsl:if>
    </xsl:variable>

    <!--
        Note that in this template, we're only concerned with
        whether or not @id is present; we ignore any value it has.
    -->

    <xsl:if test="$debugging">
      <xsl:comment>
        DEBUG: template match="prodrecap" ...
        Calling template "show-prod"
        with parameters:
          name         = <xsl:value-of select="$name"/>
          orig         = <xsl:value-of select="$orig"/>
          result_id_noid_part   = <xsl:value-of select="$result_id_noid_part"/>
      </xsl:comment>
    </xsl:if>

    <xsl:for-each select="$grammar">
      <xsl:call-template name="show-prod">
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="orig" select="$orig"/>
        <xsl:with-param name="result_id_noid_part" select="$result_id_noid_part"/>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:if test="$debugging">
      <xsl:comment>
        DEBUG: template match="prodrecap" exiting
      </xsl:comment>
    </xsl:if>

  </xsl:template>

  <xsl:template match="p[@role='lexical-state-tables']">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:for-each select="$grammar">
      <xsl:call-template name="show-tokens-transition-to-state"/>
    </xsl:for-each>
  </xsl:template>

  <!-- This template "fills in" a paragraph in the EBNF section of document source files -->
  <xsl:template match="phrase[@role='defined-tokens-delimiting']">
    <!--
    <xsl:message>DEBUG: Starting template phrase[@role='defined-tokens-delimiting']. </xsl:message>
    -->
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <!--
    <xsl:message>DEBUG: template phrase[...delimiting] ~~ $fn = <xsl:value-of select="$fn"/>. </xsl:message>
    -->
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:for-each select="$grammar">
      <xsl:call-template name="show-defined-tokens">
        <xsl:with-param name="type" select="'delimiting'"/>
      </xsl:call-template>
    </xsl:for-each>
    <!--
    <xsl:message>DEBUG: Exiting template phrase[@role='defined-tokens-delimiting']. </xsl:message>
    -->
  </xsl:template>

  <!-- This template "fills in" a paragraph in the EBNF section of document source files -->
  <xsl:template match="phrase[@role='defined-tokens-nondelimiting']">
    <!--
    <xsl:message>DEBUG: Starting template phrase[@role='defined-tokens-nondelimiting']. </xsl:message>
    -->
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <!--
    <xsl:message>DEBUG: template phrase[...nondelimiting] ~~ $fn = <xsl:value-of select="$fn"/>. </xsl:message>
    -->
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:for-each select="$grammar">
      <xsl:call-template name="show-defined-tokens">
        <xsl:with-param name="type" select="'nondelimiting'"/>
      </xsl:call-template>
    </xsl:for-each>
    <!--
    <xsl:message>DEBUG: Exiting template phrase[@role='defined-tokens-nondelimiting']. </xsl:message>
    -->
  </xsl:template>

  <!--========= Language phrase substitution ========== -->

  <!--* MSM adds this to handle errataloc, 2007-01-16.  I hope it's
      * correct... *-->
  <xsl:template match="errataloc[@role='spec-conditional']/@href">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="$spec='xpath'">
          <xsl:text>http://www.w3.org/XML/2007/qt-errata/xpath20-errata.html</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
          <xsl:text>http://www.w3.org/XML/2007/qt-errata/xquery-errata.html</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!--* MSM adds this to handle translations, 2007-01-16.  I hope it's
      * correct... *-->
  <xsl:template match="translationloc[@role='spec-conditional']/@href">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="$spec='xpath'">
          <xsl:text>http://www.w3.org/2003/03/Translations/byTechnology?technology=xpath20</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
          <xsl:text>http://www.w3.org/2003/03/Translations/byTechnology?technology=xquery</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="termdef">
    <xsl:choose>
      <xsl:when test="starts-with(@id,'xpath-') or starts-with(@id,'xpath21-') or starts-with(@id,'xpath30-')">
        <xsl:message>Cleaning up termdef: <xsl:value-of select="@id"/></xsl:message>
        <termdef>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="id">
            <xsl:value-of select="substring(@id,7)"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </termdef>
      </xsl:when>
      <xsl:otherwise>
        <termdef>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </termdef>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  <xsl:template match="nt[@def]">
    <nt def="doc-{@def}">
      <xsl:apply-templates/>
    </nt>
  </xsl:template>
  -->

  <xsl:template match="nt[@def]">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>

    <nt>
      <xsl:attribute name="def">
        <xsl:variable name="def" select="@def"/>
        <xsl:choose>
          <!-- Bit of a hack here.  The problem is no doc def exists for some productions.  -->
          <!-- In any case, perhaps -->
          <!--   there should other criteria to decide if we link to the exposition or not! -->
          <xsl:when test="$grammar/g:grammar//g:token[@name=$def and @is-xml='yes']">
            <xsl:text>prod-</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>doc-</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="true()">
          <xsl:value-of select="$grammar/g:grammar/g:language/@id"/>
          <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:value-of select="@def"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </nt>
  </xsl:template>

  <xsl:template match="g:description/code">
    <code>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="g:description/nt">
    <nt>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </nt>
  </xsl:template>

</xsl:stylesheet>

