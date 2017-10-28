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

  <xsl:output method="text" encoding="WINDOWS-1250"/>
  <xsl:param name="not-spec" select="'xpath'"/>
  <xsl:param name="spec" select="'xquery'"/>
  <xsl:param name="targetrole" select="'xquery'"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$targetrole='semfunc-file-fts-xquery'">
          <xsl:text>(: FT semantic functions for syntax and type checking :)&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$targetrole='semfunc-file-ftssimple-xquery'">
        <xsl:text>(: FT semantic functions for syntax and type checking :)&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$targetrole='semfunc-file-allmatches-xsd'">
        <xsl:text>&#60;!-- AllMatches schemata for FT semantic functions -->&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$targetrole='semfunc-file-ftselection-xsd'">
        <xsl:text>&#60;!-- FTSelection schemata for FT semantic functions -->&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:for-each select="//eg[@role=$targetrole]">
      <xsl:choose>
        <xsl:when test="$targetrole='semfunc-file-fts-xquery'">
          <xsl:text>module namespace myfns = "http://www.example.com/function-library";&#10;</xsl:text>
        </xsl:when>
        <xsl:when test="$targetrole='semfunc-file-ftssimple-xquery'">
          <xsl:text>module namespace myfns = "http://www.example.com/function-library";&#10;</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="."/>
      <xsl:text>&#10;%%%&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

