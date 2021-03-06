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

  <xsl:template match="@*|node()">
    <xsl:if test="self::node()[not(@if) or contains(@if,'core')]">
      <xsl:copy>
        <xsl:apply-templates select="@*[not(name(.) = 'if')]|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
