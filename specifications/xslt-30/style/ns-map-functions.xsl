<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rddl="http://www.rddl.org/"
                version="2.0">

<xsl:import href="../../xpath-functions-30/style/xpath-functions.xsl"/>
<xsl:import href="../../../style/ns-blank.xsl"/>

<xsl:param name="specdoc" select="'MATHNS'"/>

<xsl:variable name="fando-base"
  select="(://loc[contains(.,'XSLT 3.0')][1]/@href:)   '../html/Overview.html'"/> 

<xsl:variable name="fando" select="document('../build/xslt-expanded1.xml')"/>
<xsl:variable name="protos" select="$fando//proto[not(@role)
				                  or @role != 'example']"/>

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

<!-- Instead of putting this stuff here, we'll use the templates from ns-blank.xsl, imported above
<xsl:template match="header">
  <div class="head">
    <p>
      <a href="http://www.w3.org/">
	<img src="http://www.w3.org/Icons/w3c_home" alt="W3C"
	     height="48" width="72"/>
      </a>
    </p>

    <h1>
      <a name="title" id="title"/>
      <xsl:value-of select="title"/>
    </h1>
  </div>
</xsl:template>

<xsl:template name="css">
  <style type="text/css">
    <xsl:value-of select="$additional.css"/>
  </style>
  <link rel="stylesheet" type="text/css">
    <xsl:attribute name="href">
      <xsl:text>http://www.w3.org/StyleSheets/TR/base.css</xsl:text>
    </xsl:attribute>
  </link>
</xsl:template>
-->

<xsl:template match="processing-instruction('map-function-summary')">
<xsl:message>template match=PI(fo-math)</xsl:message>
  <!-- fake the grouping -->
  <xsl:variable name="fnlist">
    <xsl:for-each select="$protos[(not(@isOp) or @isOp != 'yes') and @prefix='map']">
      <xsl:sort select="@name"/>
      <name>
        <xsl:value-of select="@name"/>
      </name>
    </xsl:for-each>
  </xsl:variable>	

  <xsl:apply-templates select="$fnlist/name" mode="group">
    <xsl:with-param name="protos" select="$protos"/>
    <xsl:with-param name="doc-base" select="$fando-base"/>
  </xsl:apply-templates>
</xsl:template>


<xsl:template match="name" mode="group">
  <xsl:param name="protos"/>
  <xsl:param name="doc-base"/>

  <xsl:if test="not(preceding-sibling::name)
                or string(preceding-sibling::name[1]) != string(.)">
    <xsl:variable name="name" select="string(.)"/>
    <xsl:variable name="gprotos" select="$protos[@name = $name]"/>

    <rddl:resource xlink:role="http://www.rddl.org/natures#term"
                   xlink:arcrole="http://www.rddl.org/purposes#definition"
                   xlink:title="Function named math:{.}"
                   xlink:href="{$doc-base}#func-{.}"
    >

      <h3>
        <a name="{.}" id="{.}"/>
        <xsl:value-of select="."/>
      </h3>

      <xsl:for-each select="$gprotos">
        <div class="exampleInner">
          <xsl:apply-templates select="."/>
        </div>
      </xsl:for-each>

      <!-- now can we find the para that says Summary: -->
      <xsl:variable name="summaryp"
		    select="$gprotos/ancestor-or-self::glist/gitem[starts-with(label,'Summary')]/def/p"/>

      <xsl:choose>
        <xsl:when test="$summaryp">
          <xsl:apply-templates select="$summaryp" mode="sumpara">
            <xsl:with-param name="proto" select="$gprotos[1]"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$gprotos/following::p[1]" mode="non-sumpara">
            <xsl:with-param name="proto" select="$gprotos[1]"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </rddl:resource>
  </xsl:if>
</xsl:template>

<xsl:template match="p" mode="sumpara">
  <xsl:param name="proto"/>

  <xsl:variable name="text" select="."/>

  <xsl:variable name="uri" select="$fando-base"/>
  <xsl:variable name="div" select="($proto/ancestor::div1|$proto/ancestor::div2|$proto/ancestor::div3|$proto/ancestor::div4|$proto/ancestor::div5)[last()]"/>

  <p>
    <a href="{$uri}#{$div/@id}">Summary:</a>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="$text"/>
  </p>
</xsl:template>

<xsl:template match="p" mode="non-sumpara">
  <xsl:param name="proto"/>

<xsl:message>I don't think this code should get executed</xsl:message>

<!--
  <xsl:variable name="uri" select="$xslt-base"/>
-->
  <xsl:variable name="uri" select="."/>
  <xsl:variable name="div" select="($proto/ancestor::div1|$proto/ancestor::div2|$proto/ancestor::div3|$proto/ancestor::div4|$proto/ancestor::div5)[last()]"/>

  <p>
    <a href="{$uri}#{$div/@id}">Summary:</a>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="node()"/>
  </p>
</xsl:template>

<!-- Hacks for XSLT -->

<xsl:template match="elcode">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>

<xsl:template match="xfunction">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>

<!-- /Hacks for XSLT -->

<xsl:template match="termref">
  <xsl:choose>
    <xsl:when test=". = ''">
      <xsl:value-of select="key('ids', @def)/@term"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="bibref">
  <xsl:text>[</xsl:text>
  <xsl:choose>
    <xsl:when test="key('ids', @ref)/@key">
      <xsl:value-of select="key('ids', @ref)/@key"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@ref"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="error" name="make-error-ref">
  <xsl:param name="uri" select="''"/>

  <xsl:variable name="spec">
    <xsl:choose>
      <xsl:when test="@spec"><xsl:value-of select="@spec"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$default.specdoc"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="@class"><xsl:value-of select="@class"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="code">
    <xsl:choose>
      <xsl:when test="@code"><xsl:value-of select="@code"/></xsl:when>
      <xsl:otherwise>??</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
      <xsl:otherwise>??</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="label"> <!-- CREATES LABEL IN XQUERY STYLE -->
    <xsl:text>err:</xsl:text>
    <xsl:value-of select="$spec"/>
    <xsl:value-of select="$class"/>
    <xsl:value-of select="$code"/>
  </xsl:variable>

  <xsl:text>[</xsl:text>
  <xsl:value-of select="$label"/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="code">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>

</xsl:stylesheet>
