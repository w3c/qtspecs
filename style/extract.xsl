<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:import href="xsl-query.xsl"/>

<xsl:output method="xml" indent="yes"/>

<xsl:param name="uri" select="''"/>

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
  <document-summary>
    <xsl:if test="$uri != ''">
      <xsl:attribute name="uri">
	      <xsl:value-of select="$uri"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="spec"/>
  </document-summary>
</xsl:template>

<xsl:template match="spec">
  <xsl:apply-templates select="header/title"/>
  <xsl:apply-templates select="body/div1|back/div1|back/inform-div1"/>
  <xsl:apply-templates select="//termdef"/>
  <xsl:apply-templates select="//nt"/>
  <xsl:apply-templates select="//error"/>
</xsl:template>

<xsl:template match="title">
  <title>
    <xsl:apply-imports/>
  </title>
</xsl:template>

<xsl:template match="head">
  <head>
    <xsl:apply-imports/>
<!--
    <xsl:apply-templates/>
-->
  </head>
</xsl:template>

<xsl:template match="body">
  <xsl:apply-templates select="div1"/>
</xsl:template>

<xsl:template match="back">
  <xsl:apply-templates select="div1|inform-div1"/>
</xsl:template>

<xsl:template match="div1">
  <div1 id="{@id}">
    <xsl:apply-templates select="head"/>
    <xsl:apply-templates select="div2"/>
  </div1>
</xsl:template>

<xsl:template match="div2">
  <div2 id="{@id}">
    <xsl:apply-templates select="head"/>
    <xsl:apply-templates select="div3"/>
  </div2>
</xsl:template>

<xsl:template match="div3">
  <div3 id="{@id}">
    <xsl:apply-templates select="head"/>
    <xsl:apply-templates select="div4"/>
  </div3>
</xsl:template>

<xsl:template match="div4">
  <div4 id="{@id}">
    <xsl:apply-templates select="head"/>
    <xsl:apply-templates select="div5"/>
  </div4>
</xsl:template>

<xsl:template match="div5">
  <div5 id="{@id}">
    <xsl:apply-templates select="head"/>
  </div5>
</xsl:template>

<xsl:template match="inform-div1">
  <inform-div1 id="{@id}">
    <xsl:apply-templates select="head"/>
  </inform-div1>
</xsl:template>

<xsl:template match="termdef">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="error">
  <xsl:copy>
    <xsl:attribute name="spec">
      <xsl:value-of select="$specdoc"/>
    </xsl:attribute>
    <xsl:copy-of select="@*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="nt">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="."/>
  </xsl:copy>
</xsl:template>

<xsl:template match="elcode | xfunction">
  <!-- nop; MK added elcode to XSLT? -->
</xsl:template>

</xsl:stylesheet>
