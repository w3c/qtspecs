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

  <xsl:param name="spec"/>
  <xsl:param name="spec2" select="'dummy'"/>
  <xsl:param name="spec3" select="'dummy'"/>
  <xsl:param name="status"/>

  <xsl:output method="html"/>

  <!-- ===================================================================== -->

  <xsl:variable name="spec_info"
    select="document('specs.xml')/specs/spec[@id=$spec]"/>

  <xsl:variable name="spec2_info"
    select="document('specs.xml')/specs/spec[@id=$spec2]"/>

  <xsl:variable name="spec3_info"
    select="document('specs.xml')/specs/spec[@id=$spec3]"/>

  <!-- -->

  <xsl:variable name="lang-brief-name">
    <xsl:value-of select="$spec_info/@brief-name"/>
    <xsl:if test="$spec2 != 'dummy'">
      <xsl:text> with </xsl:text>
      <xsl:value-of select="$spec2_info/@brief-name"/>
    </xsl:if>
    <xsl:if test="$spec3 != 'dummy'">
      <xsl:text> and </xsl:text>
      <xsl:value-of select="$spec3_info/@brief-name"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="page-title">
    <xsl:text>Grammar Test Page for </xsl:text>
    <xsl:value-of select="$lang-brief-name"/>
  </xsl:variable>

  <!-- ===================================================================== -->

  <xsl:template match="/">
    <xsl:if test="not($spec_info)">
      <xsl:message terminate="yes">
        <xsl:text>Unknown value for 'spec' parameter: '</xsl:text>
        <xsl:value-of select="$spec"/>
        <xsl:text>'</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|node()">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>

  <!-- =========== -->

  <xsl:template match="e-head-title">
    <title>
      <xsl:value-of select="$page-title"/>
    </title>
  </xsl:template>

  <xsl:template match="e-body-title">
    <h1>
      <xsl:value-of select="$page-title"/>
    </h1>
  </xsl:template>

  <xsl:template match="e-lang-with-links">
    <xsl:copy-of select="$spec_info/node()"/>
    <xsl:if test="$spec2 != 'dummy'">
      <xsl:text> with </xsl:text>
      <xsl:copy-of select="$spec2_info/node()"/>
    </xsl:if>
    <xsl:if test="$spec3 != 'dummy'">
      <xsl:text> and </xsl:text>
      <xsl:copy-of select="$spec3_info/node()"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="e-optional-status-note">
    <xsl:if test="$status = 'experimental-combo'">
      (Note that this combination is neither
      normative nor currently on-track to become normative.
      This applet is provided for experimental purposes only.)
    </xsl:if>
  </xsl:template>

  <xsl:template match="e-lang-no-links">
    <xsl:value-of select="$lang-brief-name"/>
  </xsl:template>

</xsl:stylesheet>
