<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="g xlink">

  <xsl:import href="../../../style/assemble-spec.xsl"/>

  <xsl:output method="xml" indent="no" />

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

    <xsl:choose>
      <xsl:when test="starts-with($string, 'sx-')">
        <com>
          <loc href="#{$link-prefix}{$string}">
            <xsl:value-of select="$label"/>
            <xsl:value-of select="$string"/>
          </loc>
        </com>
      </xsl:when>
      <xsl:otherwise>
        <com>
          <phrase><xspecref ref="{$link-prefix}{$string}">
            <xsl:attribute name="spec">
              <xsl:choose>
                <xsl:when test="$spec='xpath'">
                  <xsl:text>XP</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>XQ</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$label"/>
            <xsl:value-of select="$string"/>
          </xspecref></phrase>
        </com>
      </xsl:otherwise>
    </xsl:choose>

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

    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:variable name="token" select="substring-before($string, $delimiter)"/>
        <xsl:call-template name="construct-gn-link">
          <xsl:with-param name="string" select="$token"/>
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
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->