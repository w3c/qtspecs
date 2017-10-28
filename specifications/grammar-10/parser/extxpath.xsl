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

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="not-spec" select="'xquery'"/>
  <xsl:param name="spec" select="'xpath'"/>

  <xsl:template match="/">
    <tests>
      <xsl:for-each select="//*[@role='parse-test' and not(ancestor::*[normalize-space(@role)=normalize-space($not-spec)])]">
        <test>
          <xsl:attribute name="value">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </test>
      </xsl:for-each>
    </tests>
  </xsl:template>
  
</xsl:stylesheet>
