<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

  <!-- This stylesheet should be used instead of xsl-query.xsl when, and only when,
       the document in question contains BNF productions that are in both XQuery
       syntax and in XPath syntax. -->

  <!-- JimM, 2009-03-23: replaced show-chgs with show.diff.markup to correspond to other stylesheets that invoke this one -->

  <xsl:import href="xsl-query-2016.xsl"/>
  <!--
    ... which see for decls of 'show-markup', 'show.diff.markup', etc.
  -->

  <!--
  <xsl:import href="issues.xsl"/>
  <xsl:include href="issues-spec.xsl"/>
  <xsl:param name="issues-file" select="'issues.xml'"/>
  -->

  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:param name="additional.css.2">
<!--
    <xsl:comment> (xmlspec-override - $show.diff.markup = <xsl:value-of select="$show.diff.markup"/>)</xsl:comment>
-->
    <style type="text/css">
      table.small    { font-size: x-small; }
    </style>
  </xsl:param>

  <!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{xmlspec-override} </xsl:text>
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

  <!--========= Issues related templates ========== -->
  <!--
  <xsl:template match="p[@id='issues-list']">
    <xsl:apply-templates select="document($issues-file)"/>
  </xsl:template>
  -->

  <!-- mode: number -->
  <!-- xsl:template mode="number-simple" match="prod">
    <xsl:text>[</xsl:text>
    <xsl:choose>
      <xsl:when test="lhs/@number-id">
        <xsl:value-of select="lhs/@number-id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>XX</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
  </xsl:template -->

  <!-- ===================================================================== -->
  <!-- Templates that deal with EBNF -->

  <xsl:template match="lhs">
    <tr style="vertical-align:baseline;">
      <xsl:if test="@role">
        <xsl:attribute name="class">
          <xsl:value-of select="@role"/>
        </xsl:attribute>
      </xsl:if>
      <td>
        <xsl:call-template name="optional_diff_class_attr"/>
        <xsl:if test="../@id">
          <a name="{../@id}" id="{../@id}"/>
        </xsl:if>
        <xsl:apply-templates select="ancestor::prod" mode="number"/>
        <xsl:text>&#xa0;&#xa0;&#xa0;</xsl:text>
      </td>
      <td>
        <xsl:call-template name="optional_diff_class_attr"/>
        <code><xsl:apply-templates/></code>
      </td>
      <td>
        <xsl:call-template name="optional_diff_class_attr"/>
        <xsl:text>&#xa0;&#xa0;&#xa0;::=&#xa0;&#xa0;&#xa0;</xsl:text>
      </td>
      <xsl:apply-templates
        select="following-sibling::*[1][name()='rhs']"/>
    </tr>
  </xsl:template>

  <xsl:template match="lhs/text()" priority="20000">
    <xsl:call-template name="lhs-text"/>
  </xsl:template>

  <xsl:template name="lhs-text">
    <xsl:variable name="id">
      <xsl:choose>
        <!-- pull some nasty trick to handle multiply defined productions. -->
        <!-- Don wants this... -->
        <xsl:when test="starts-with(ancestor::prod/@id, 'noid_')">
          <xsl:value-of select="substring-after(ancestor::prod/@id, '.')"/>
          <!-- xsl:message>
            <xsl:value-of select="substring-after(ancestor::prod/@id, '.')"/>
          </xsl:message -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::prod/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="starts-with($id, 'doc-')">
        <xsl:variable name="ref-id" 
          select="concat('prod', substring($id, 4))"/>
        <xsl:call-template name="link-text-with-check">
          <xsl:with-param name="ref-id" select="$ref-id"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($id, 'prod-')">
        <xsl:variable name="ref-id" 
          select="concat('doc', substring($id, 5))"/>
        <xsl:call-template name="link-text-with-check">
          <xsl:with-param name="ref-id" select="$ref-id"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="link-text-with-check">
    <xsl:param name="ref-id"/>
    <xsl:variable name="role" 
      select="ancestor-or-self::*[@role='xpath' 
              or @role='xquery']/@role"/>
    <xsl:variable name="num-val" select="string(ancestor-or-self::prod/@num)"/>
    <xsl:variable name="idFound1" select="//*/@id[.=$ref-id]"/>
    <xsl:choose>
      <!-- The tests for "(XQuery)", etc. are a hack... this should be driven from 
           the prep stylesheets, but I'm not sure how at the moment. -->
      <xsl:when test="($idFound1) or contains($num-val, '(XQuery)') or contains($num-val, '(XPath)')">
        <a>
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="contains($num-val, '(XQuery)')">
                <xsl:text>http://www.w3.org/TR/xquery-30/</xsl:text>
                <xsl:text>#prod-xquery30-</xsl:text>
                <xsl:value-of select="substring-after(substring-after($ref-id, '-'), '-')"/>
              </xsl:when>
              <xsl:when test="contains($num-val, '(XPath)')">
                <xsl:text>http://www.w3.org/TR/xpath-30/</xsl:text>
                <xsl:text>#prod-xpath30-</xsl:text>
                <xsl:value-of select="substring-after(substring-after($ref-id, '-'), '-')"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- core, let it be relative -->
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$ref-id"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>

          <xsl:if test="$role">
            <xsl:attribute name="class">
              <xsl:value-of select="$role"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="."/>
        </a>
        <xsl:choose>
          <xsl:when test="contains($num-val, '(XQuery)')">
            <sup><small>XQ30</small></sup>
          </xsl:when>
          <xsl:when test="contains($num-val, '(XPath)')">
            <sup><small>XP30</small></sup>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$role">
            <span class="{$role}">
              <xsl:value-of select="."/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>

        <!--
          Our inability to create a link for $ref-id may be a sign of
          something wrong, so we'll print a message saying so, unless
          its one of the cases where it's expected...
        -->
        <xsl:variable name="doc_designation" select="ancestor::spec/header/w3c-designation"/>

        <!--
          Exception #1:
          In specs for language extensions (update, scripting, full text),
          the appendix provides EBNF for the whole language (base + extension),
          but the document body provides EBNF for (pretty much) only the extension.
          Thus, in the appendix, the LHS symbol in a base language production,
          which wants to point to the corresponding production in the doc body,
          doesn't have one to point to.
        -->
        <xsl:variable name="exception_for_extension_to_base" select="
            (
              contains($doc_designation, 'xquery-update-10')
              and
              starts-with($ref-id, 'doc-xquery-')
            )
            or
            (
              contains($doc_designation, 'xquery-update-30')
              and
              starts-with($ref-id, 'doc-xquery30-')
            )
            or
            (
              contains($doc_designation, 'xquery-sx-10')
              and
              starts-with($ref-id, 'doc-xquery-')
            )
            or
            (
              contains($doc_designation, 'xpath-full-text-10')
              and
              (
                starts-with($ref-id, 'doc-xquery10-')
                or
                starts-with($ref-id, 'doc-xpath20-')
              )
            )
            or
            (
              contains($doc_designation, 'xpath-full-text-30')
              and
              (
                starts-with($ref-id, 'doc-xquery30-')
                or
                starts-with($ref-id, 'doc-xpath30-')
              )
            )
          "/>

        <!--
          Also, the Update 1.0 doc has Core productions in the body,
          but they're not collected in an appendix. So we expect
          inability to link from the former to the latter.
        -->
        <xsl:variable name="exception_for_update10_core" select="
            contains($doc_designation, 'xquery-update-10')
            and
            starts-with($ref-id, 'prod-core-')
          "/>

        <xsl:if test="not($exception_for_extension_to_base) and not($exception_for_update10_core)">
          <xsl:message>Warning: link-text-with-check was unable to make a link for $ref-id="<xsl:value-of select="$ref-id"/>"</xsl:message>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- rhs: right-hand side of a formal production -->
  <!-- make a table cell; if it's not the first after an LHS, make a
       new row, too -->
  <xsl:template match="rhs|rhs-group">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='lhs']">
        <td>
          <xsl:call-template name="optional_diff_class_attr"/>
          <code><xsl:apply-templates/></code>
        </td>
        <xsl:apply-templates
          select="following-sibling::*[1][name()='com' or
                                          name()='constraint' or
                                          name()='vc' or
                                          name()='wfc']"/>
      </xsl:when>
      <xsl:otherwise>
        <tr style="vertical-align:baseline;">
          <td/><td/><td/>
          <td>
            <xsl:call-template name="optional_diff_class_attr"/>
            <code><xsl:apply-templates/></code>
          </td>
          <xsl:apply-templates
            select="following-sibling::*[1][name()='com' or
                                            name()='constraint' or
                                            name()='vc' or
                                            name()='wfc']"/>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template would be useful in xmlspec.xsl too. -->
  <xsl:template name="optional_diff_class_attr">
    <xsl:if test="ancestor-or-self::*/@diff and $show.diff.markup != 0">
      <xsl:attribute name="class">
        <xsl:text>diff-</xsl:text>
        <xsl:value-of select="ancestor-or-self::*/@diff"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->

  <xsl:template match="br" priority="400">
    <br/>
  </xsl:template>

  <xsl:template match="author[@role]">
    <dd class="{@role}">
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <xsl:template match="div1[@role]
                       |div2[@role]
                       |div3[@role]
                       |div4[@role]
                       |div5[@role]
                       |inform-div1[@role]">
    <div class="{@role}">
      <xsl:apply-imports/>
    </div>
  </xsl:template>

  <xsl:template match="ednote[@role]
                       |table[@role]
                       |eg[@role]
                       |head[@role]
                       |p[@role]
                       |olist[@role]">
    <div class="{@role}">
      <xsl:apply-imports/>
    </div>
  </xsl:template>

  <xsl:template match="gitem[@role]
                       |phrase[@role]
                       |sitem[@role]
                       |term[@role]
                       |loc[@role]
                       |nt[@role]">
    <span class="{@role}">
      <xsl:apply-imports/>
    </span>
  </xsl:template>

  <xsl:template match="item[@role]">
    <li class="{@role}">
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!--
  prod
  rhs-group
  -->

  <!-- Don't do anything for empty heads -->

  <xsl:template match="scrap/head">
    <xsl:if test="count(node()) != 0">
      <xsl:text>&#10;</xsl:text>
      <h5>
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select=".."/>
          <xsl:with-param name="conditional" select="0"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </h5>
    </xsl:if>
  </xsl:template>

  <!-- Added by Scott Boag, May 27, 2004 -->
  <!-- phrase: semantically meaningless markup hanger -->
  <!-- role attributes may be used to request different formatting,
       which isn't currently handled -->
  <xsl:template name="do-standard-phrase-attributes">
    <xsl:if test="@role">
      <xsl:attribute name="class">
        <xsl:value-of select="@role"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>

  </xsl:template>

  <xsl:template match="phrase[@diff='del']">
    <xsl:if test="$show.diff.markup=1">
      <span class="diff-{@diff}">
        <xsl:call-template name="do-standard-phrase-attributes"/>
        <xsl:apply-templates/>
      </span>
    </xsl:if>
  </xsl:template>


  <xsl:template match="phrase[@diff='add' or @diff='chg']" priority="200">
    <xsl:choose>
      <xsl:when test="$show.diff.markup=1">
        <span class="diff-{@diff}">
          <xsl:call-template name="do-standard-phrase-attributes"/>
          <xsl:apply-templates/>
        </span>
      </xsl:when>  
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- gitem: glossary list entry -->
  <!-- just pass children through for <dd>/<dt> formatting -->
  <xsl:template match="gitem/def//p/table">
    <xsl:apply-imports/>
    <br/>
  </xsl:template>


</xsl:stylesheet>
<!-- vim: sw=2 ts=2 expandtab
-->
