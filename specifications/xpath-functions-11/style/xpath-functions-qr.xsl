<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<!-- This is for the F&O Quick Reference -->

<xsl:import href="xpath-functions.xsl"/>

<xsl:template match="/">
<!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
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

<xsl:template match="header">
  <div class="head">
    <xsl:if test="not(/spec/@role='editors-copy')">
      <p>
	<a href="http://www.w3.org/">
	  <img src="http://www.w3.org/Icons/w3c_home"
	       alt="W3C" height="48" width="72"/>
	</a>
	<xsl:choose>
	  <xsl:when test="/spec/@w3c-doctype='memsub'">
	    <a href='http://www.w3.org/Submission/'>
	      <img alt='Member Submission'
		   src='http://www.w3.org/Icons/member_subm'/>
	    </a>
	  </xsl:when>
	  <xsl:when test="/spec/@w3c-doctype='teamsub'">
	    <a href='http://www.w3.org/2003/06/TeamSubmission'>
	      <img alt='Team Submission'
		   src='http://www.w3.org/Icons/team_subm'/>
	    </a>
	  </xsl:when>
	</xsl:choose>
      </p>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <h1>
      <xsl:call-template name="anchor">
	<xsl:with-param name="node" select="title[1]"/>
	<xsl:with-param name="conditional" select="0"/>
	<xsl:with-param name="default.id" select="'title'"/>
      </xsl:call-template>
      
      <xsl:apply-templates select="title"/>
      <xsl:if test="version">
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="version"/>
      </xsl:if>
    </h1>
    <xsl:if test="subtitle">
      <xsl:text>&#10;</xsl:text>
      <h2>
	<xsl:call-template name="anchor">
	  <xsl:with-param name="node" select="subtitle[1]"/>
	  <xsl:with-param name="conditional" select="0"/>
	  <xsl:with-param name="default.id" select="'subtitle'"/>
	</xsl:call-template>
	<xsl:apply-templates select="subtitle"/>
      </h2>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <h2>
      <xsl:call-template name="anchor">
	<xsl:with-param name="node" select="w3c-doctype[1]"/>
	<xsl:with-param name="conditional" select="0"/>
	<xsl:with-param name="default.id" select="'w3c-doctype'"/>
      </xsl:call-template>

      <xsl:apply-templates select="w3c-doctype"/>
      <xsl:text> </xsl:text>
      <xsl:if test="pubdate/day">
	<xsl:apply-templates select="pubdate/day"/>
	<xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="pubdate/month"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="pubdate/year"/>
    </h2>

    <h2>Quick Reference</h2>
  </div>
</xsl:template>

<!-- ============================================================ -->
<!-- mode: toc -->

<xsl:template mode="toc" match="div1">
  <xsl:value-of select="@divnum"/>
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
	<xsl:with-param name="target" select="."/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="head" mode="text"/>
  </a>
  <br/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="$toc.level &gt; 1">
    <xsl:apply-templates select="div2" mode="toc"/>
  </xsl:if>
</xsl:template>

<xsl:template mode="toc" match="div2">
  <xsl:text>&#xa0;&#xa0;&#xa0;&#xa0;</xsl:text>
  <xsl:value-of select="@divnum"/>
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
	<xsl:with-param name="target" select="."/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="head" mode="text"/>
  </a>
  <br/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="$toc.level &gt; 2">
    <xsl:apply-templates select="div3" mode="toc"/>
  </xsl:if>
</xsl:template>

<xsl:template mode="toc" match="div3">
  <xsl:text>&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;</xsl:text>
  <xsl:value-of select="@divnum"/>
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
	<xsl:with-param name="target" select="."/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="head" mode="text"/>
  </a>
  <br/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="$toc.level &gt; 3">
    <xsl:apply-templates select="div4" mode="toc"/>
  </xsl:if>
</xsl:template>

<xsl:template mode="toc" match="div4">
  <xsl:text>&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;</xsl:text>
  <xsl:value-of select="@divnum"/>
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
	<xsl:with-param name="target" select="."/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="head" mode="text"/>
  </a>
  <br/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="$toc.level &gt; 4">
    <xsl:apply-templates select="div5" mode="toc"/>
  </xsl:if>
</xsl:template>

<xsl:template mode="toc" match="div5">
  <xsl:text>&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;</xsl:text>
  <xsl:value-of select="@divnum"/>
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
	<xsl:with-param name="target" select="."/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="head" mode="text"/>
  </a>
  <br/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="div1/head">
  <xsl:text>&#10;</xsl:text>
  <h2>
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
    <xsl:value-of select="../@divnum"/>
    <xsl:apply-templates/>
  </h2>
</xsl:template>

<xsl:template match="div2/head">
  <xsl:text>&#10;</xsl:text>
  <h3>
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
    <xsl:value-of select="../@divnum"/>
    <xsl:apply-templates/>
  </h3>
</xsl:template>

<xsl:template match="div3/head">
  <xsl:text>&#10;</xsl:text>
  <h4>
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
    <xsl:value-of select="../@divnum"/>
    <xsl:apply-templates/>
  </h4>
</xsl:template>

<xsl:template match="div4/head">
  <xsl:text>&#10;</xsl:text>
  <h5>
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
    <xsl:value-of select="../@divnum"/>
    <xsl:apply-templates/>
  </h5>
</xsl:template>

<xsl:template match="div5/head">
  <xsl:text>&#10;</xsl:text>
  <h6>
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
    <xsl:value-of select="../@divnum"/>
    <xsl:apply-templates/>
  </h6>
</xsl:template>

<xsl:template match="errorref">
  <xsl:value-of select="@class"/>
  <xsl:value-of select="@code"/>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->