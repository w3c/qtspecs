<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rddl="http://www.rddl.org/"
                exclude-result-prefixes="exsl"
                version="1.0">

<xsl:import href="../../xpath-functions-30/style/xpath-functions.xsl"/>
<xsl:import href="../../../style/ns-blank.xsl"/>
  
  <!-- TODO: this stylesheet is hacked together by modifying ns-errors.xsl. It  needs tidying up -->

<xsl:param name="specdoc" select="'ERRNS'"/>

<xsl:variable name="fando" select="document('xpath-functions.xml',.)"/>
<xsl:variable name="xslt" select="document('../../xslt-30/src/xslt.xml',.)"/>
<xsl:variable name="lang" select="document('../../xquery-30/src/xquery.xml',.)"/>
<xsl:variable name="ser" select="document('../../xslt-xquery-serialization-30/xslt-xquery-serialization.xml',.)"/>

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

  <xsl:template match="processing-instruction('doc')">
    <pre>
      <xsl:variable name="doc" select="unparsed-text(resolve-uri(concat('../src/', string(.)), base-uri(/)), 'iso-8859-1')"/>
      <xsl:value-of select="translate($doc, '&#xD;', '')"/>
    </pre>
  </xsl:template>


</xsl:stylesheet>
