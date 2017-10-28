<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="../../xpath-functions-31/style/merge-function-specs.xsl"/>
    
    <xsl:template match="/">
        <xsl:message>Transforming <xsl:value-of select="document-uri(.)"/> with <xsl:value-of select="static-base-uri()"/></xsl:message>
        <xsl:apply-imports/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('built-in-function-streamability')">
        <xsl:copy-of select="doc('../build/built-in-streamability-expanded.xml')"/>
    </xsl:template>
    
</xsl:stylesheet>