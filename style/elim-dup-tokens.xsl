<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>

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

    <xsl:template match="token-list">
       <token-list>
        <xsl:call-template name="dup-remove">
            <xsl:with-param name="t-list" select="*"/>
        </xsl:call-template>
       </token-list>
    </xsl:template>

    <xsl:template name="dup-remove">
        <xsl:param name="p-list" select="''"/>
        <xsl:param name="t-list"/>
        <xsl:param name="pos" select="1"/>
        <xsl:variable name="count" select="count($t-list)"/>
        <xsl:variable name="t" select="$t-list[$pos]"/>

    	<xsl:variable name="terminalID">
    		<xsl:choose>
    			<xsl:when test="string-length($t) > 0">
    				<xsl:text>"</xsl:text>
    				<xsl:value-of select="$t"/>
    				<xsl:text>"</xsl:text>
    			</xsl:when>
    			<xsl:when test="$t/@expo-name">
    				<xsl:value-of select="$t/@expo-name"/>
    			</xsl:when>
    			<xsl:otherwise>
    				<xsl:value-of select="terminal"/>
    				<xsl:value-of select="$pos"/>
    			</xsl:otherwise>
    		</xsl:choose>
    	</xsl:variable>

        <xsl:if test="not(contains($p-list, concat('~', $terminalID, '~')))">
            <xsl:copy-of select="$t"/>
        </xsl:if>
        <xsl:if test="$pos &lt;= $count">
        	    <xsl:call-template name="dup-remove">
    				<xsl:with-param name="p-list" select="concat($p-list, '~', $terminalID, '~')"/>
    				<xsl:with-param name="t-list" select="$t-list"/>
    				<xsl:with-param name="pos" select="$pos + 1"/>
    				<!-- xsl:with-param name="type" select="$type"/ -->
    				<!-- xsl:with-param name="has-output" select="$has-output"/ -->
    			</xsl:call-template>
		</xsl:if>

    </xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->