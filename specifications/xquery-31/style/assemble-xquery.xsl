<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="g xlink">

  <xsl:import href="../../../style/assemble-spec.xsl"/>

  <xsl:output method="xml" indent="yes"
              doctype-system="../../../schema/xsl-query.dtd" />

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

  <xsl:template name="construct-gn-link">
    <xsl:param name="string"/>
    <xsl:param name="spec" select="/g:grammar/g:language/@id"/>
    <xsl:param name="label" select="'gn: '"/>
    <xsl:param name="link-prefix" select="'parse-note-'"/>
    <com>
      <loc href="#{$link-prefix}{$string}">
        <xsl:value-of select="$label"/>
        <xsl:value-of select="$string"/>
      </loc>
<!-- This is incorrect; seems to be caused by my carelessly copying
     assemble-update.xsl and renaming it assemble-xquery.xsl without
     understanding this template. 
      <phrase><xspecref ref="{$link-prefix}{$string}">
        <xsl:attribute name="spec">
          <xsl:choose>
            <xsl:when test="contains($spec, 'xpath')">
              <xsl:text>XP30</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>XQ30</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="$label"/>
        <xsl:value-of select="$string"/>
      </xspecref></phrase>
-->
    </com>
    
  </xsl:template>

  <xsl:template name="do-whitespace-comment">
    <xsl:call-template name="construct-gn-link">
      <xsl:with-param name="string" select="@whitespace-spec"/>
      <xsl:with-param name="label" select="'ws: '"/>
      <xsl:with-param name="link-prefix" select="'ws-'"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Try and apply a space delimited list of references to tokens. -->

  <xsl:template name="apply-gns">
    <xsl:param name="string" select="''"/>
    <xsl:param name="delimiter" select="' '"/>
    <xsl:param name="count" select="0"/>
    <xsl:param name="is-xgc" select="false()"/>

    <!-- Handle the gn: vs xgc: case explicitly ... -->
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="$is-xgc">xgc: </xsl:when>
        <xsl:otherwise>gn: </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:variable name="token" select="substring-before($string, $delimiter)"/>
        <xsl:call-template name="construct-gn-link">
          <xsl:with-param name="string" select="$token"/>
          <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
        <xsl:call-template name="apply-gns">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="construct-gn-link">
          <xsl:with-param name="string" select="$string"/>
          <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

