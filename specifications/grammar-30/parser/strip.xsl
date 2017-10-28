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
  version="1.0" xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
  <xsl:param name="spec1" select="'xpath'"/>
  <xsl:param name="spec2" select="'dummy'"/>
  <xsl:param name="spec3" select="'dummy'"/>

  <xsl:template match="@*|node()">
    <xsl:if test="self::node()[not(@if)
                  or contains(@if, $spec1)
                  or contains(@if, $spec2)
                  or contains(@if, $spec3)]">
      <xsl:if test="self::node()[not(contains(@not-if, $spec1)
                    or contains(@not-if, $spec2)
                    or contains(@not-if, $spec3))]">
        <xsl:choose>
          <!--
              Assuming it passes the if|not-if tests,
              a <g:ref> marked with unfold="yes" is replaced by
              the content of the production that it refers to.
          -->
          <xsl:when test="self::g:ref/@unfold = 'yes'">
            <xsl:variable name="n" select="./@name"/>
            <xsl:apply-templates select="//g:production[@name = $n]/*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="comment()" priority="16">
  </xsl:template>

</xsl:stylesheet>
