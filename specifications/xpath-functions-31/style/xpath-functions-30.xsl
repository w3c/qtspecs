<?xml version="1.0"?>

<!--
 Created 17 Dec 2008 by MHK.
 No longer used 16 Feb 2009?
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">


<xsl:import href="../../../style/xmlspec-override.xsl"/>
<xsl:import href="../../../style/funcproto.xsl"/>

<!-- override rules for determining function prefix in base stylesheet -->

<xsl:template name="get-prefix">
    <xsl:choose>
      <xsl:when test="@isOp='yes'">op:</xsl:when>
      <xsl:when test="@isSchema='yes'">xs:</xsl:when>
      <xsl:when test="@isDatatype='yes'">xdt:</xsl:when>
      <xsl:when test="@isSpecial='yes'"></xsl:when>
      <xsl:otherwise>fn:</xsl:otherwise>
    </xsl:choose>
</xsl:template>
 



</xsl:stylesheet>

