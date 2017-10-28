<?xml version="1.0"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="1.0">

  <xsl:import href="../../../style/xsl-query-2016.xsl"/>

<!--  <xsl:param name="spec" select="'FO'"/> -->

<!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">

    <xsl:comment>
      <xsl:text>* This is xpath-functions-base, match="/" -- show.diff.markup = </xsl:text>
      <xsl:value-of select="$show.diff.markup"/>
    </xsl:comment>

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
    <xsl:apply-imports/>
  </xsl:template> 

  <xsl:template match="span">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
