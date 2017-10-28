<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="saxon"
                version="1.0">

  <xsl:key name="ids" match="*[@id]" use="@id"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <!-- N.B. Don't use xsl:copy because I don't want bogus namespaces -->

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

  <xsl:template match="spec">
    <xsl:element name="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="header|body"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="body">
    <xsl:element name="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="head"/>
      <xsl:apply-templates select="div1"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div1|div2|div3|div4|div5">
    <xsl:variable name="examples"
		  select=".//example[@role='signature'][proto[(not(@role) or @role!='example') and @isOp='no']]"/>

    <xsl:if test="$examples">
      <xsl:element name="{local-name(.)}">
	<xsl:copy-of select="@*"/>
	<xsl:attribute name="divnum">
	  <xsl:apply-templates select="." mode="divnum"/>
	</xsl:attribute>
	<xsl:apply-templates select="head"/>
	<xsl:apply-templates select="div1|div2|div3|div4|div5|
				     ./example[@role='signature'][proto[(not(@role) or @role!='example') and @isOp='no']]"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="example">
    <xsl:element name="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="proto"/>
    </xsl:element>    
    <xsl:if test="starts-with(following-sibling::p[1], 'Summary:')">
      <xsl:apply-templates select="following-sibling::p[1]"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="termref">
    <span class="arrow">&#xB7;</span>
    <xsl:choose>
      <xsl:when test=". = ''">
	<xsl:value-of select="key('ids', @def)/@term"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <span class="arrow">&#xB7;</span>
  </xsl:template>

  <xsl:template match="*">
    <xsl:element name="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::node()) and parent::p
	              and starts-with(.,'Summary: ')">
	<xsl:value-of select="substring-after(., 'Summary: ')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <!-- ============================================================ -->
  <!-- mode: divnum -->

  <xsl:template mode="divnum" match="div1">
    <xsl:number format="1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back/div1 | inform-div1">
    <xsl:number count="div1 | inform-div1" format="A "/>
  </xsl:template>

  <xsl:template mode="divnum"
    match="front/div1 | front//div2 | front//div3 | front//div4 | front//div5"/>

  <xsl:template mode="divnum" match="div2">
    <xsl:number level="multiple" count="div1 | div2" format="1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div2">
    <xsl:number level="multiple" count="div1 | div2 | inform-div1"
      format="A.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div3">
    <xsl:number level="multiple" count="div1 | div2 | div3"
      format="1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div3">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | inform-div1" format="A.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div4">
    <xsl:number level="multiple" count="div1 | div2 | div3 | div4"
      format="1.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div4">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | inform-div1"
      format="A.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div5">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | div5" format="1.1.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div5">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | div5 | inform-div1"
      format="A.1.1.1.1 "/>
  </xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->