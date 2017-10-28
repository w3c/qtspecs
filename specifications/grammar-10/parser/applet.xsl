<?xml version="1.0" encoding="utf-8"?>

<!--
 * Copyright (c) 2002 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:param name="spec" select="'xquery'"/>
  <xsl:param name="spec-date" select="'20061121'"/>
  <xsl:output method="html"/>

  <xsl:template match="@*|node()">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="frag//ref[@type='spec']">
    <!-- xsl:param name="spec-uri-part"/ -->
    <xsl:variable name="spec-uri-part">
      <xsl:choose>
        <xsl:when test="$spec='xquery-fulltext'">
          <xsl:text>xquery-full-text</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery-update'">
          <xsl:text>xquery-update</xsl:text>
        </xsl:when>
         <xsl:when test="$spec='xquery-core'">
          <xsl:text>xquery-core</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
          <xsl:text>xquery</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xpath'">
          <xsl:text>xpath20</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>##ERROR##</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="$spec='xquery-fulltext'">
           <xsl:text>http://www.w3.org/TR/2007/WD-xpath-full-text-10-20070518</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery-update'">
           <xsl:text>http://www.w3.org/TR/2007/WD-xquery-update-10-20070828</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
           <xsl:text>http://www.w3.org/TR/xquery</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xpath'">
           <xsl:text>http://www.w3.org/TR/xpath20</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>##ERROR##</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="{$uri}/">
      <xsl:call-template name="which-spec"/>
    </a>
    <xsl:text> (</xsl:text>
      <xsl:value-of select="$uri"/>
    <xsl:text>/)</xsl:text>
  </xsl:template>

  <xsl:template match="frag//ref[@type='grammar-xml']">
    <a>
      <xsl:attribute name="href">
        <xsl:text>xpath-grammar.xml</xsl:text>
      </xsl:attribute>
      <xsl:text>XML representation of the grammar</xsl:text>
    </a>
  </xsl:template>

  <xsl:template match="frag//ref[@type='build-zip']">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="$spec"/>
        <xsl:text>.zip</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="$spec"/>
      <xsl:text>.zip</xsl:text>
      </a>
  </xsl:template>

  <xsl:template match="frag//ref[@type='jjfiles']">
	<xsl:variable name="jjfile">
		<x>
			<xsl:value-of select="$spec"/>
			<xsl:text>-grammar.jj</xsl:text>
		</x>
	</xsl:variable>
	<xsl:variable name="jjtfile">
		<xsl:value-of select="$jjfile"/>
        <xsl:text>t</xsl:text></xsl:variable>
    <a>
      <xsl:attribute name="href">
		<xsl:value-of select="$jjfile"/>
      </xsl:attribute>
      <xsl:value-of select="$jjfile"/>
    </a>
	<xsl:text> and </xsl:text>
    <a>
      <xsl:attribute name="href">
		<xsl:value-of select="$jjtfile"/>
      </xsl:attribute>
      <xsl:value-of select="$jjtfile"/>
    </a>
  </xsl:template>

  <xsl:template match="frag//*" priority='-400'>
    <xsl:param name="spec-uri-part"/>
    <xsl:element name="{name()}">
      <xsl:apply-templates>
        <xsl:with-param name="spec-uri-part" select="$spec-uri-part"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template name="which-spec">
    <xsl:choose>
      <xsl:when test="$spec='xquery'">
        <xsl:text>XQuery 1.0</xsl:text>
      </xsl:when>
      <xsl:when test="$spec='xpath'">
        <xsl:text>XPath 2.0</xsl:text>
      </xsl:when>
      <xsl:when test="$spec='xquery-fulltext'">
        <xsl:text>XQuery 1.0 and XPath 2.0 Full-Text</xsl:text>
      </xsl:when>
      <xsl:when test="$spec='xquery-update'">
        <xsl:text>XQuery Update Facility</xsl:text>
      </xsl:when>
      <xsl:when test="$spec='xquery-core'">
        <xsl:text>XQuery 1.0 and XPath 2.0 Formal Semantics</xsl:text>
      </xsl:when>
      <xsl:when test="$spec='pathx1'">
        <xsl:text>XPath 1.0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Unknown Spec: </xsl:text>
        <xsl:value-of select="$spec"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="body">
    <xsl:variable name="spec-uri-part">
      <xsl:choose>
        <xsl:when test="$spec='xquery-fulltext'">
          <xsl:text>xquery-full-text</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery-update'">
          <xsl:text>xquery-update</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery-core'">
          <xsl:text>xquery-core</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
          <xsl:text>xquery</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xpath'">
          <xsl:text>xpath20</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>##ERROR##</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="$spec='xquery-fulltext'">
           <xsl:text>http://www.w3.org/TR/2007/WD-xpath-full-text-10-20070518</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery-update'">
           <xsl:text>http://www.w3.org/TR/2007/WD-xquery-update-10-20070828</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xquery'">
           <xsl:text>http://www.w3.org/TR/xquery</xsl:text>
        </xsl:when>
        <xsl:when test="$spec='xpath'">
           <xsl:text>http://www.w3.org/TR/xpath20</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>##ERROR##</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:copy>
      <h1>
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$uri"/>
            <xsl:choose>
              <xsl:when test="$spec='xquery'">
                <xsl:text>#nt-bnf</xsl:text>
              </xsl:when>
              <xsl:when test="$spec='xpath'">
                <xsl:text>#nt-bnf</xsl:text>
              </xsl:when>
              <xsl:when test="$spec='xquery-fulltext'">
                <xsl:text>#id-grammar</xsl:text>
              </xsl:when>
              <xsl:when test="$spec='xquery-update'">
                <xsl:text>#id-grammar</xsl:text>
              </xsl:when>
              <xsl:when test="$spec='pathx1'">
                <xsl:text>#location-paths</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>

          <xsl:call-template name="which-spec"/>
        </a>
        <xsl:text> Grammar Test Page</xsl:text>
      </h1>
      <xsl:variable name="spec-uri-part">
        <xsl:choose>
          <xsl:when test="$spec='xquery'">
            <xsl:text>xquery</xsl:text>
          </xsl:when>
          <xsl:when test="$spec='xpath'">
            <xsl:text>xpath20</xsl:text>
          </xsl:when>
          <xsl:when test="$spec='xquery-fulltext'">
            <xsl:text>xquery-full-text</xsl:text>
          </xsl:when>
		  <xsl:when test="$spec='xquery-update'">
            <xsl:text>xquery-update</xsl:text>
          </xsl:when>
          <xsl:when test="$spec='xquery-core'">
            <xsl:text>xquery-semantics</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>##ERROR##</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:apply-templates select="document('applettext.xml')/frag/*">
        <xsl:with-param name="spec-uri-part" select="$spec-uri-part"/>
      </xsl:apply-templates>

      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="applet[@name='TestApplet']">
    <xsl:copy>
      <xsl:attribute name="archive">
        <xsl:value-of select="$spec"/>
        <xsl:text>.zip</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="spec">
    <xsl:call-template name="which-spec"/>
  </xsl:template>

  <xsl:template match="title">
    <xsl:copy>
      <xsl:call-template name="which-spec"/>
      <xsl:text> Grammar Test Page</xsl:text>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
