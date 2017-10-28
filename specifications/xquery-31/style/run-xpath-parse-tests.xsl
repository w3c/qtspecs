<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:err="http://www.w3.org/2005/xqt-errors" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
     expand-text="1" version="3.0">
    
    <!-- Stylesheet for testing XPath examples -->
    <!-- Designed to be run against ../src/xpath.xml -->
    <!-- The stylesheet attempts to evaluate all examples tagged with @role='parse-test'. Many of the examples will
         fail with errors (e.g. undeclared variables or namespace prefixes) but a scan of the output should reveal 
         any nasties like unmatched parentheses. -->

    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="e" as="element()">
        <e/>
    </xsl:variable>

    <xsl:template match="(eg | code)[@role = 'parse-test'][not(ancestor::*[@role='xquery'])]">
        <processing expression="{.}" xsl:exclude-result-prefixes="#all">
            <xsl:try>
                <xsl:variable name="result" as="item()*">
                    <xsl:evaluate xpath="." namespace-context="$e" context-item="."/>
                </xsl:variable>
                <xsl:attribute name="result-size" select="count($result)"/>
                <xsl:catch errors="*">
                    <error code="{$err:code}">{$err:description}</error>
                </xsl:catch>
            </xsl:try>
        </processing>
    </xsl:template>

</xsl:stylesheet>
