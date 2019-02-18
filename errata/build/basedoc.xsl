<?xml version='1.0'?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:er="http://www.w3.org/2007/04/qt-errata"
	exclude-result-prefixes="er">

<!-- This stylesheet module is imported by errata.xsl. It handles the formatting of
     xmlspec elements when they appear in the context of an errata document. This
	   differs from the normal processing largely in the way that links are rendered -->

<xsl:import href="../../style/xsl-query.xsl"/>
<xsl:import href="../../specifications/xpath-functions-31/style/xpath-functions.xsl"/>

<!-- Handle conditional code for XP/XQ shared baseline document -->

<xsl:template match="*" mode="base-text">
  <xsl:choose>
    <xsl:when test="$specdoc = ('XP', 'XQ')">
	  <xsl:variable name="preprocessed" as="element()">
	    <xsl:apply-templates select="." mode="preprocess"/>
      </xsl:variable>
	  <xsl:apply-templates select="$preprocessed"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="."/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="preprocess">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="preprocess"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*[@role='xquery' and $specdoc = 'XP']" mode="preprocess"/>

<xsl:template match="*[@role='xpath' and $specdoc = 'XQ']" mode="preprocess"/>

<!-- Override special handling of <code> in F+O -->

<xsl:template match="code">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>

<!-- Provide rendering of infoset properties in DM -->

<xsl:template match="emph[@role='infoset-property']">
  <b>[<xsl:value-of select="."/>]</b>
</xsl:template>

<xsl:template match="emph[@role='dm-node-property']">
  <b><xsl:value-of select="."/></b>
</xsl:template>

<!-- Override special handling of <function> in DM -->

<xsl:template match="function[$specdoc='DM']">
  <xsl:variable name="fname" select="replace(., '\(.*$', '')"/>
  <code style="text-decoration: underline">
    <xsl:choose>
      <xsl:when test="contains($fname, ':')">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <span class="prefix">dm:</span>
		<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </code>
</xsl:template>

<!-- Override special handling of <elcode> in XSLT-->

<xsl:template match="elcode">
  <code>
    <xsl:apply-templates/>
  </code>
</xsl:template>

<!-- Special case handling of an item that has no list parent -->

<xsl:template match="er:new-text/item[not(@number)]" mode="base-text">
  <ul>
    <li>
      <xsl:apply-templates/>
    </li>
  </ul>
</xsl:template>

<xsl:template match="er:new-text/item[@number]" mode="base-text">
  <table cellpadding="5">
    <tr>
	  <td valign="top"><p><xsl:value-of select="@number"/></p></td>
      <td valign="top"><xsl:apply-templates/></td>
    </tr>
  </table>
</xsl:template>

<!-- Following rules are designed to ensure that the generated HTML list items 
     or table entries are properly wrapped to make the errata document well-formed HTML -->

<xsl:template match="tr" mode="base-text">
  <table>
 	  <xsl:next-match/>
  </table>
</xsl:template>

<xsl:template match="td" mode="base-text">
  <table>
    <tr>
	  <xsl:next-match/>
    </tr>
  </table>
</xsl:template>

<xsl:template match="bibl" mode="base-text">
  <dl>
    <xsl:next-match/>
  </dl>
</xsl:template>

<xsl:template match="ulist/item" mode="base-text">
  <ul>
    <li>
      <xsl:apply-templates/>
    </li>
  </ul>
</xsl:template>

<xsl:template match="olist/item" mode="base-text">
  <table cellpadding="5">
    <tr>
	  <td valign="top">
	    <xsl:variable name="nr" select="count(preceding-sibling::item)+1"/>
		<xsl:variable name="depth" select="count(ancestor::olist)"/>
		<p>
		  <xsl:number value="$nr" format="{('1','a','i','A','I')[($depth - 1) mod 5 + 1]}"/>
        </p>
	  </td>
      <td valign="top"><xsl:apply-templates/></td>
    </tr>
  </table>
</xsl:template>

  <xsl:template name="list.numeration">
    <xsl:variable name="depth" select="count(ancestor::olist)
	    + (ancestor::item/@depth, 0)[1]"/>
    <xsl:choose>
      <xsl:when test="$depth mod 5 = 0">ar</xsl:when>
      <xsl:when test="$depth mod 5 = 1">la</xsl:when>
      <xsl:when test="$depth mod 5 = 2">lr</xsl:when>
      <xsl:when test="$depth mod 5 = 3">ua</xsl:when>
      <xsl:when test="$depth mod 5 = 4">ur</xsl:when>
    </xsl:choose>
  </xsl:template>

<!-- Allow new sections to have an explicit section number -->

  <xsl:template match="div1[@number]/head">
    <xsl:text>&#10;</xsl:text>
    <h2>
      <xsl:value-of select="../@number"/>
	  <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="div2[@number]/head">
    <xsl:text>&#10;</xsl:text>
    <h3>
      <xsl:value-of select="../@number"/>
	  <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="div3[@number]/head">
    <xsl:text>&#10;</xsl:text>
    <h4>
      <xsl:value-of select="../@number"/>
	  <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates/>
    </h4>
  </xsl:template>

  <xsl:template match="div4[@number]/head">
    <xsl:text>&#10;</xsl:text>
    <h5>
      <xsl:value-of select="../@number"/>
	  <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates/>
    </h5>
  </xsl:template>

  <xsl:template match="div5[@number]/head">
    <xsl:text>&#10;</xsl:text>
    <h6>
      <xsl:value-of select="../@number"/>
	  <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates/>
    </h6>
  </xsl:template>

<!-- Override templates for resolving links and references -->

<xsl:template match="termref[node()]">
  <span style="text-decoration: underline">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="termref[not(node())]">
  <span style="text-decoration: underline">
    <xsl:value-of select="($spec//termdef[@id=current()/@def]/@term, @def)[1]"/>
  </span>
</xsl:template>

<xsl:template match="specref">
  <span style="text-decoration: underline">
    <xsl:value-of select="er:section-title(@ref)"/>
  </span>
</xsl:template>

<xsl:template match="bibref">
  <span style="text-decoration: underline">
    [<xsl:value-of select="($spec//bibl[@id = current()/@ref]/@key, @ref)[1]"/>]
  </span>
</xsl:template>

<xsl:template name="href.target">
  <xsl:param name="target"/>
  <span style="text-decoration: underline">
    <xsl:value-of select="."/>
  </span>
</xsl:template>

<xsl:template match="errorref">
  <xsl:variable name="error" select="key('error', concat(@class,@code), $spec)"/>

  <xsl:choose>
    <xsl:when test="$error">
      <xsl:apply-templates select="$error[1]">
	    <xsl:with-param name="inner" select="true()" tunnel="yes"/>
	  </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Warning: Error <xsl:value-of select="@code"/> not found.</xsl:message>
      <xsl:text>[ERROR </xsl:text>
      <xsl:value-of select="@code"/>
      <xsl:text> NOT FOUND]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xerrorref">
  <xsl:next-match>
    <xsl:with-param name="inner" tunnel="yes" select="true()"/>
  </xsl:next-match>
</xsl:template>

<!-- used in XSLT specification -->
<xsl:template match="error.extra">
  <xsl:text> [</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
  <sup>for Appendix E </sup> 
</xsl:template>

<!-- used in XQuery errata, but could arise anywhere -->
<xsl:template match="error">
  <xsl:param name="inner" select="false()" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="$inner">
      <xsl:value-of select="concat('[err:', (@spec,$specdoc)[1], @class, @code, ']')"/>
	</xsl:when>
	<xsl:otherwise>
      <p>
        <b><xsl:value-of select="concat('err:', (@spec,$specdoc)[1], @class, @code)"/></b>
		<xsl:value-of select="if (@label) then concat(' ', @label) else ''"/>
      </p>
      <xsl:apply-templates/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="p[error[p]]">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="nt[@def]">
  <span style="text-decoration: underline">
    <xsl:value-of select="."/>
  </span>
</xsl:template>

<xsl:template name="check-bibrefs">
  <!-- override the checking that is done by the base stylesheet xsl-query.xsl -->
</xsl:template>

<xsl:template match="phrase[@role='spec-language'][not(child::node())]">  
  <xsl:value-of select="if ($specdoc = 'XP') then 'XPath' else 'XQuery'"/>
</xsl:template>
  
  <xsl:template match="var[matches(., '[A-Za-z][0-9]')]">
    <var><xsl:value-of select="substring(.,1,1)"/><sub><xsl:value-of select="substring(.,2,1)"/></sub></var>
  </xsl:template>
  
  <xsl:template match="phrase[@diff='del']">
    <span class="diff-del"><xsl:apply-templates/></span>
  </xsl:template>

</xsl:stylesheet>

