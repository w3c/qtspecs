<?xml version="1.0" encoding="UTF-8"?>


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs j"
    version="2.0">
    
    <!-- 
        * This is a stylesheet for converting XML to JSON (indented for readability). 
        * It expects the XML to be in the format produced by the XSLT 3.0 function
        * fn:json-to-xml(), but is designed to be highly customizable.
        *
        * The stylesheet is made available under the terms of the W3C software notice and license
        * at http://www.w3.org/Consortium/Legal/copyright-software-19980720
        *
    -->    
    
    <xsl:import href="xml-to-json.xsl"/>
    
    <xsl:param name="indent-spaces" as="xs:integer" select="3"/>
    
    <xsl:param name="j:colon" as="xs:string"> : </xsl:param>
    
    <xsl:template name="j:start-array">
        <xsl:text> [&#xa;</xsl:text>
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:for-each select="1 to ($depth + 1) * $indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:end-array">
        <xsl:text> ] </xsl:text>
    </xsl:template>
    
    <xsl:template name="j:start-map">
        <xsl:text> {&#xa;</xsl:text>
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:for-each select="1 to ($depth + 1) * $indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:end-map">
        <xsl:text> } </xsl:text>
    </xsl:template>
   
    <xsl:template name="j:map-separator">
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:text>,&#xa;</xsl:text>
        <xsl:for-each select="1 to $depth * $indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:array-separator">
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:text>,&#xa;</xsl:text>
        <xsl:for-each select="1 to $depth * $indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>