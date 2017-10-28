<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">

<!-- preprocessing stylesheet used to force consistent style for tables -->
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="comment()|processing-instruction()|text()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="table[not(@border='0')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="border" select="'1'"/>
            <xsl:attribute name="cellpadding" select="'5'"/>
            <xsl:attribute name="width" select="'100%'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="th|td">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="align" select="'left'"/>
            <xsl:attribute name="valign" select="'top'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    



</xsl:stylesheet>
