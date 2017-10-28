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
  version="2.0"
  xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
  exclude-result-prefixes="g">

  <xsl:import href="../../../style/assemble-spec.xsl"/>
  
  <xsl:param name="is-xslt30" select="true()"/>
  
  <xsl:template match="g:xref">
    <xnt spec="XP30" ref="prod-xpath30-{@name}"><xsl:value-of select="@name"/></xnt>
  </xsl:template>
  
  <xsl:template match="g:ref[//g:production[@name=current()/@name][contains(@if, 'xpath30') or not(contains(@if, 'xslt30-patterns'))]]">
    <!--<xsl:message>** XNT <xsl:value-of select="@name"/></xsl:message>-->
    <xnt spec="XP30" ref="prod-xpath30-{@name}"><xsl:value-of select="@name"/></xnt>
  </xsl:template>
  
  <!-- Handle references from the pattern grammar to tokens specially (life is too short to work out why) -->
  <xsl:template match="g:ref[@name='URIQualifiedName']">
    <xnt spec="XP30" ref="prod-xpath30-{@name}"><xsl:value-of select="@name"/></xnt>
  </xsl:template>
  
  <xsl:template match="g:ref[@name=('NCNameTok')]">
    <xnt spec="XP30" ref="prod-xpath30-NCName">NCName</xnt>
  </xsl:template>
  
  <xsl:template match="g:ref[@name=('LocalPart')]">
    <xnt spec="XP30" ref="prod-xpath30-NCName">NCName</xnt>
  </xsl:template>
  
  <xsl:template match="g:ref">
    <!--<xsl:message>** NT <xsl:value-of select="@name"/></xsl:message>-->
    <xsl:next-match/>
  </xsl:template>
  
<!--  <xsl:template match="nt[@def]">
    <xsl:variable name="fn"><xsl:call-template name="get-gfn"/></xsl:variable>
    <xsl:variable name="grammar" select="document($fn,.)"/>
    <xsl:variable name="orig">
      <xsl:call-template name="get-gnotation"/>
    </xsl:variable>
    
    <nt>
      <xsl:attribute name="def">
        <xsl:variable name="def" select="@def"/>
        <!-\- Override "hack" in base template so we always link to doc- -\->
        <xsl:text>doc-</xsl:text>
        <xsl:if test="true()">
          <xsl:value-of select="$grammar/g:grammar/g:language/@id"/>
          <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:value-of select="@def"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </nt>
  </xsl:template>-->
  
</xsl:stylesheet>

