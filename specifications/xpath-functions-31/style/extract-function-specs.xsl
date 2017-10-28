<?xml version='1.0'?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

<xsl:output indent="yes" method="xml" saxon:suppress-indentation="p" xmlns:saxon="http://saxon.sf.net/"/>

<xsl:template match="/">
  <fos:functions>
    <fos:global-variables>
	  <xsl:apply-templates select="//p[@role='global-variable-binding']"/>
	</fos:global-variables>
	<xsl:apply-templates select="//div1"/>
  </fos:functions>
</xsl:template>

<xsl:template match="*"/>

<xsl:template match="*[starts-with(local-name(),'div')][starts-with(@id, 'func-')][example/proto[not(@role='example')]]" priority="5">
  <fos:function name="{substring-after(@id, 'func-')}">
    <fos:signatures>
      <xsl:apply-templates select="example/proto"/>
    </fos:signatures>
	<xsl:variable name="summary" select="p[starts-with(., 'Summary')]"/>
	<xsl:variable name="semantics" select="p[starts-with(., 'Defines the semantics')]"/>
	<xsl:variable name="examples" select="*[starts-with(local-name(), 'div')][head='Examples']"/>
	<xsl:variable name="notes" select="note[not(following-sibling::p)]"/>
	<xsl:apply-templates select="$semantics" mode="semantics"/>
	<fos:summary>
	  <xsl:copy-of select="$summary" copy-namespaces="no"/>
    </fos:summary>
	<fos:rules>
	  <xsl:copy-of select="* except (head, example[proto], $summary, $semantics, $notes, $examples)" copy-namespaces="no"/>
	</fos:rules>
	<xsl:if test="$notes">
	  <fos:notes>
	    <xsl:copy-of select="$notes/child::node()" copy-namespaces="no"/>
	  </fos:notes>
	</xsl:if>
	<xsl:if test="$examples">
	  <fos:examples>
	  	<xsl:apply-templates select="$examples/(* except head)" mode="examples"/>
	  </fos:examples>
	</xsl:if>
  </fos:function>
</xsl:template>

<xsl:template match="div1|div2|div3|div4|div5">
  <xsl:apply-templates select="*[starts-with(local-name(), 'div')]"/>
</xsl:template>

<xsl:template match="proto">
  <fos:proto name="{@name}" 
       return-type="{@return-type}{'?'[current()/@returnEmptyOk='yes'][not(current()/@returnSeq='yes')]}{'*'[current()/@returnSeq='yes']}">
	<xsl:apply-templates select="arg"/>
  </fos:proto>
</xsl:template>

<xsl:template match="arg">
  <fos:arg name="{@name}" type="{@type}{'?'[current()/@emptyOk='yes'][not(current()/@seq='yes')]}{'*'[current()/@seq='yes']}"/>
</xsl:template>

<xsl:template match="p" mode="semantics">
  <xsl:variable name="operators" as="xs:string*">
    <xsl:analyze-string select="string(.)" regex='"([^"]+)"'>
	  <xsl:matching-substring>
	    <xsl:sequence select="normalize-space(regex-group(1))"/>
	  </xsl:matching-substring>
	  <xsl:non-matching-substring/>
	</xsl:analyze-string>
  </xsl:variable>
  <xsl:variable name="types" select="code[starts-with(., 'xs:')], 'numeric'[contains(., 'numeric')]"/>    
  <fos:semantics operator="{$operators[1]}" types="{$types}">
      <xsl:if test="count($operators) gt 1">
	    <xsl:attribute name="other-operators" select="subsequence($operators, 2)"/>
	  </xsl:if>
	  <xsl:copy-of select="node()" copy-namespaces="no"/>
  </fos:semantics>
</xsl:template>

<xsl:template match="ulist|olist" mode="examples">
  <xsl:for-each select="item">
    <fos:example>
	  <xsl:apply-templates mode="example"/>
	</fos:example>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="examples">
    <fos:example>
	  <xsl:apply-templates mode="example"/>
	</fos:example>
</xsl:template>

<xsl:template match="*" mode="example">
  <xsl:copy copy-namespaces="no">
    <xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="example"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="p[@role='global-variable-binding']">
  <xsl:call-template name="make-variable"/>
</xsl:template>

<xsl:template match="p[@role='variable-binding']" name="make-variable" mode="examples">
  <fos:variable name="{substring(code[1],2)}">
    <xsl:choose>
	    <xsl:when test="eg">
		  <xsl:attribute name="as">element()</xsl:attribute>
		  <xsl:value-of select="eg"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:attribute name="select" select="code[2]"/>
		</xsl:otherwise>
	</xsl:choose>
  </fos:variable>
</xsl:template>

<xsl:template match="p[count(code)=2 and text()[normalize-space()='returns']]" mode="example">
  <fos:test>
    <xsl:if test="code[1]/(preceding-sibling::* or preceding-sibling::text()[normalize-space()])">
	    <fos:preamble>
		  <xsl:copy-of select="code[1]/preceding-sibling::node()" copy-namespaces="no"/>
		</fos:preamble>
	</xsl:if>
    <fos:expression>
	  <xsl:copy-of select="code[1]/child::node()" copy-namespaces="no"/>
	</fos:expression>
	<fos:result>
	  <xsl:copy-of select="code[2]/child::node()" copy-namespaces="no"/>
	</fos:result>
	<xsl:if test="code[2]/(following-sibling::* or following-sibling::text()[not(normalize-space()=('', '.'))])">
		<fos:postamble>
		  <xsl:copy-of select="code[2]/following-sibling::node()" copy-namespaces="no"/>
		</fos:postamble>
	</xsl:if>
  </fos:test>
</xsl:template>

</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2007. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="extract-function-specs" userelativepaths="yes" externalpreview="no" url="..\src\xpath-functions.xml" htmlbaseurl="" outputurl="..\src\generated-function-catalog.xml" processortype="saxon8" useresolver="yes"
		          profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""
		          validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->