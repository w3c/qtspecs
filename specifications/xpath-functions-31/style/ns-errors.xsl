<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rddl="http://www.rddl.org/"
                exclude-result-prefixes="exsl"
                version="1.0">

<xsl:import href="xpath-functions.xsl"/>
<xsl:import href="ns-xpath-functions.xsl"/>

<xsl:param name="specdoc" select="'ERRNS'"/>

<xsl:variable name="fando" select="document('xpath-functions.xml',.)"/>
<xsl:variable name="xslt" select="document('../../xslt-30/src/xslt.xml',.)"/>
<xsl:variable name="lang" select="document('../../xquery-31/src/errors.xml',.)"/>
<xsl:variable name="ser" select="document('../../xslt-xquery-serialization-31/src/errors.xml',.)"/>

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

<xsl:template match="code">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>
-->


<xsl:template match="processing-instruction('error-summary')">
  <div2 id="fo">
    <h2>2.1 Functions and Operators</h2>
    <dl>
    <xsl:apply-templates select="$fando//error" mode="error-list">
      <xsl:with-param name="spec" select="'FO'"/>
      <xsl:sort select="concat(@class, @code)"/>
    </xsl:apply-templates>
  </dl></div2>
  <div2 id="xt"><h2>2.2 XSLT</h2>
  <dl>
    <xsl:apply-templates select="$xslt//error[not(ancestor-or-self::*[@diff='del'])]" mode="error-list">
      <xsl:with-param name="spec" select="'XT'"/>
      <xsl:sort select="concat(@class, @code)"/>
    </xsl:apply-templates>
  </dl></div2>
  <div2 id="xqxp"><h2>2.3 XQuery and XPath</h2>
  <dl>
    <xsl:for-each select="$lang//error">
      <xsl:sort select="concat(@class, @code)"/>
      <xsl:variable name="role"
		    select="ancestor-or-self::*[(@role='xpath')
			                        or (@role='xquery')]"/>
      <xsl:choose>
        <xsl:when test="$role/@role = 'xquery'">
          <xsl:apply-templates select="." mode="error-list">
            <xsl:with-param name="spec" select="'XQ'"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="error-list">
            <xsl:with-param name="spec" select="'XP'"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </dl></div2>
  <div2 id="ser"><h2>2.4 Serialization</h2><dl>
    
    <xsl:apply-templates select="$ser//error" mode="error-list">
      <xsl:with-param name="spec" select="'SE'"/>
    </xsl:apply-templates>

  </dl></div2>
</xsl:template>

<xsl:template match="error" mode="error-list">
  <xsl:param name="spec"/>

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

  <xsl:variable name="label">
    <xsl:choose>
      <xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="string(.)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <dt class="resource">
    <rddl:resource xlink:role="http://www.rddl.org/natures#term"
                   xlink:arcrole="http://www.rddl.org/purposes#definition"
    >
      <xsl:attribute name="xlink:title">
        <xsl:text>Error with code err:</xsl:text>
        <xsl:value-of select="$spec"/>
        <xsl:value-of select="$class"/>
        <xsl:value-of select="$code"/>
      </xsl:attribute>
      <xsl:attribute name="xlink:href">
        <xsl:choose>
          <xsl:when test="$spec = 'FO'">
            <xsl:text>http://www.w3.org/TR/xpath-functions-30/#ERR</xsl:text>
          </xsl:when>
          <xsl:when test="$spec = 'XT'">
            <xsl:text>http://www.w3.org/TR/xslt-30/#err-</xsl:text>
          </xsl:when>
          <xsl:when test="$spec = 'SE'">
            <xsl:text>http://www.w3.org/TR/xslt-xquery-serialization-30/#ERR</xsl:text>
          </xsl:when>
          <xsl:when test="$spec = 'XQ'">
            <xsl:text>http://www.w3.org/TR/xquery-30/#ERR</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>http://www.w3.org/TR/xpath-30/#ERR</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$spec"/>
        <xsl:value-of select="$class"/>
        <xsl:value-of select="$code"/>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="$spec = 'FO'">
              <xsl:text>http://www.w3.org/TR/xpath-functions-30/#ERR</xsl:text>
            </xsl:when>
            <xsl:when test="$spec = 'XT'">
              <xsl:text>http://www.w3.org/TR/xslt-30/#err-</xsl:text>
            </xsl:when>
            <xsl:when test="$spec = 'SE'">
              <xsl:text>http://www.w3.org/TR/xslt-xquery-serialization-30/#ERR</xsl:text>
            </xsl:when>
            <xsl:when test="$spec = 'XQ'">
              <xsl:text>http://www.w3.org/TR/xquery-30/#ERR</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>http://www.w3.org/TR/xpath-30/#ERR</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="$spec"/>
          <xsl:value-of select="$class"/>
          <xsl:value-of select="$code"/>
        </xsl:attribute>
        <xsl:text>err:</xsl:text>
        <xsl:value-of select="concat($spec, $class, $code)"/>
      </a>
    </rddl:resource>
  </dt>
  <dd><xsl:value-of select="$label"/></dd>
</xsl:template>

</xsl:stylesheet>
