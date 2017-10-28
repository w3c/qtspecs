<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">

  <xsl:import href="xpath-functions.xsl"/>
  <xsl:param name="show.diff.markup" select="1"/>
  <xsl:param name="called.by.diffspec" select="1"/>

  <xsl:template match="/">
    <xsl:comment>
      <xsl:text>* This is fo-diff, match="/" - - show.diff.markup = </xsl:text>
      <xsl:value-of select="$show.diff.markup"/>
    </xsl:comment>
    <xsl:apply-imports/>
  </xsl:template>

</xsl:stylesheet>
