<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rddl="http://www.rddl.org/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="exsl"
                version="1.0">

<xsl:import href="../../../style/ns-blank.xsl"/>

<xsl:param name="specdoc" select="'SERNS'"/>

<xsl:variable name="ser" select="document('schema-for-serialization-parameters.xsd',.)"/>

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

<xsl:template match="processing-instruction('ser-parameter-summary')">
  <!-- collate them better -->
  <dl>
    <xsl:apply-templates select="$ser//xs:element[@substitutionGroup='output:serialization-parameter-element']" mode="serparam-list"/>
  </dl>
</xsl:template>

<xsl:template match="xs:element" mode="serparam-list">

  <dt class="resource">
    <rddl:resource xlink:role="http://www.rddl.org/natures#term"
                   xlink:arcrole="http://www.rddl.org/purposes#definition"
    >
      <xsl:attribute name="xlink:title">
        <xsl:text>Serialization parameter output:</xsl:text>
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:attribute name="xlink:href">
        <xsl:text>http://www.w3.org/2010/xslt-xquery-serialization/schema-for-parameters-for-xslt-xquery-serialization.xsd#</xsl:text><xsl:value-of select="@id"/>
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:text>http://www.w3.org/2010/xslt-xquery-serialization/schema-for-parameters-for-xslt-xquery-serialization.xsd#</xsl:text><xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:text>output:</xsl:text>
        <xsl:value-of select="@name"/>
      </a>
    </rddl:resource>
  </dt>
</xsl:template>

</xsl:stylesheet>
