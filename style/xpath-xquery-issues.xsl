<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:import href="issues.xsl"/>

<xsl:output method="html"
            indent="no"/>

<xsl:param name="kwFull">full</xsl:param>
<xsl:param name="kwSort">numeric</xsl:param>

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
  <html>
    <head>
      <title>XPath 2.0 and XQuery 1.0 Issues List</title>
      <style type='text/css'>
         body {  margin: 2em 1em 2em 70px;
                 font-family: New Times Roman, serif;
                 color: black;
                 background-color: white;}
         p {     margin-top: 0.6em;}
         pre {   font-family: monospace;
                 margin-left: 2em;}
         div.issue {
                 margin-top: 1em;
                 }
         a:hover { background: #CCF;}
      </style>
    </head>
    <body>
      <h1><xsl:value-of select="/issues/header/p[1]"/></h1>
      <p>This document contains the XPath 2.0 and XQuery 1.0 Issues List that
records pre-Last Call issues.</p>
      <div id="htmlbody">
	<xsl:apply-templates/>
      </div>
    </body>
  </html>
</xsl:template>

<xsl:template match="issues">
  <!-- All of them, in numeric order -->
  <xsl:call-template name="do_issues">
    <xsl:with-param name="issues_to_process" select="//issue"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="quote">
  <xsl:text>“</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>”</xsl:text>
</xsl:template>

</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->