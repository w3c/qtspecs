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

  <xsl:output method="text"/>
  <xsl:param name="not-spec" select="'xpath'"/>
  <xsl:param name="spec" select="'xquery'"/>

  <xsl:template match="/">
    <xsl:text>(: parse tests :)&#10;</xsl:text>
    <xsl:for-each select="//*[(@role='parse-test' or @role='frag-prolog-parse-test')
                          and not(ancestor::*
                          [normalize-space(@role)=normalize-space($not-spec)])]">
      <xsl:if test=".">
        <xsl:choose>
          <xsl:when test="@role='frag-prolog-parse-test' and not(starts-with(normalize-space(.), 'module')) and not(starts-with(normalize-space(.), 'xquery version'))">
            <xsl:text>module namespace myfns = "http://www.example.com/function-library";&#10;</xsl:text>
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:when test="@role='frag-prolog-parse-test' and starts-with(normalize-space(.), 'module')">
            <xsl:value-of select="."/>
            <xsl:text>&#10;declare base-uri "http://example.org";</xsl:text>
          </xsl:when>
          <xsl:when test="@role='frag-prolog-parse-test' and starts-with(normalize-space(.), 'xquery version')">
            <xsl:value-of select="."/>
            <xsl:text>&#10;foo</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:text>&#10;%%%</xsl:text>
      </xsl:if>
    </xsl:for-each>
    
  </xsl:template>

</xsl:stylesheet>
