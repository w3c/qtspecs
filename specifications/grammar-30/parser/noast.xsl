<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
	xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
	
	<xsl:import href="javacc.xsl"/>

	<xsl:template name="set-parser-package">
		<xsl:text>package </xsl:text>org.w3c.xqparser<xsl:text>;&#10;&#10;  </xsl:text>
  </xsl:template>
	
	<xsl:template name="action-production">
		System.out.println("action-production: <xsl:value-of select="@name"/>");
	</xsl:template>
	
	<xsl:template name="action-production-end">
		{ System.out.println("action-production-end: <xsl:value-of select="@name"/>"); }
	</xsl:template>
	
	<xsl:template name="action-exprProduction">
		System.out.println("action-exprProduction: <xsl:value-of select="@name"/>");
	</xsl:template>
	
	<xsl:template name="action-exprProduction-label">
	</xsl:template>
	
	<xsl:template name="action-exprProduction-end">
	</xsl:template>
	
	<xsl:template name="action-level">
	</xsl:template>
	
	<xsl:template name="action-level-jjtree-label"></xsl:template>
	<xsl:template name="binary-action-level-jjtree-label"></xsl:template>
	
	<xsl:template name="action-level-start">
	</xsl:template>
	
	<xsl:template name="action-level-end">
	</xsl:template>
	
	<xsl:template name="action-token-ref">
	</xsl:template>
	
	<!-- Begin LV -->
	<xsl:template name="user-action-ref-start">
		{ System.out.println("user-action-ref-start: <xsl:value-of select="@name"/>"); }
	</xsl:template>
	
	<xsl:template name="user-action-ref-end">
		{ System.out.println("user-action-ref-end: <xsl:value-of select="@name"/>"); }
	</xsl:template>
	<!-- End LV -->

</xsl:stylesheet>