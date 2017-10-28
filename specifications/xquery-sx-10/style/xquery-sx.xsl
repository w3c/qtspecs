<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../xpath-semantics-10/style/xquery-semantics.xsl"/>

   <xsl:output indent="no"/>

  <xsl:template match="prod/com" priority="2000">
    <td>
      <xsl:if test="ancestor-or-self::*/@diff and $show.diff.markup != 0">
        <xsl:attribute name="class">
          <xsl:text>diff-</xsl:text>
          <xsl:value-of select="ancestor-or-self::*/@diff"/>
        </xsl:attribute>
      </xsl:if>
      <i>
        <xsl:text>/* </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> */</xsl:text>
      </i>
    </td>
  </xsl:template>

</xsl:stylesheet>