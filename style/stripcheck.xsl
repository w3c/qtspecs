<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text"/>

  <xsl:preserve-space elements="*"/>

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

  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="not(@role)"/>
      <xsl:when test="@role='xquery'">
        <xsl:message><xsl:value-of select="local-name(.)"/></xsl:message>
        <xsl:if test="ancestor::*[@role='xpath']">WARNING: XPath in XQuery</xsl:if>
      </xsl:when>
      <xsl:when test="@role='xpath'">
        <xsl:message><xsl:value-of select="local-name(.)"/></xsl:message>
        <xsl:if test="ancestor::*[@role='xquery']">WARNING: XQuery in XPath</xsl:if>
      </xsl:when>
      <xsl:when test="@role='lexical-state-tables'
                      or @role='spec-conditional'
                      or @role='small'
                      or @role='non-terminal-structure-expand'
                      or @role='frag-prolog-parse-test'
                      or @role='parse-test'
                      or @role='wont-parse-test'
                      or @role='bug-parse-test'">
        <!-- nop -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unexpected role: <xsl:value-of select="@role"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()|text()"/>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->
