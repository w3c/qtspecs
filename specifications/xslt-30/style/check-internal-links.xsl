<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:key name="termdef" match="termdef" use="@id"/>
    <xsl:key name="specdef" match="div1|div2|div3|div4|div5|inform-div1" use="@id"/>
    <xsl:key name="bibldef" match="bibl" use="@id"/>
    
    <xsl:template match="/">
        <xsl:message>Checking internal links...</xsl:message>
        <xsl:for-each select="//termref[empty(key('termdef', @def))]">
            <xsl:message select="'**** Dangling reference to termdef ', string(@def)"/>
        </xsl:for-each>
        <xsl:for-each select="//specref[empty(key('specdef', @ref))]">
            <xsl:message select="'**** Dangling reference to section ', string(@ref)"/>
        </xsl:for-each>
        <xsl:for-each select="//bibref[empty(key('bibldef', @ref))]">
            <xsl:message select="'**** Dangling reference to bibl ', string(@ref)"/>
        </xsl:for-each>
        <!-- no output -->
    </xsl:template>
    
</xsl:stylesheet>