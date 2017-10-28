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

  <!-- Tokenize a list of strings, delimited by single spaces, 
       and output the unique ones,
       prefixed by $before-output and followed by $after-output. -->
  <xsl:template name="tokenize-and-output">
    <xsl:param name="string" select="''"/>
    <xsl:param name="before-output" select="''"/>
    <xsl:param name="after-output" select="''"/>
    <xsl:param name="delimit-output" select="' '"/>

    <xsl:param name="used-states" select="' '"/> <!-- Private -->
    
    <xsl:if test="$string">
      <xsl:variable name="token" select="substring-before($string,' ')"/>
      <xsl:choose>
        <xsl:when test="$token">
          
          
          <xsl:if test="not(contains($used-states, concat(' ', $token, ' ')))">
            <xsl:choose>
              <xsl:when test="$used-states = ' '">
                <xsl:value-of select="$before-output"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$delimit-output"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$token"/>
          </xsl:if>
          
          <xsl:call-template name="tokenize-and-output">
            <xsl:with-param name="string" 
              select="substring($string, string-length($token)+2)"/>
            <xsl:with-param name="used-states" 
              select="concat($used-states, $token, ' ')"/>
            <xsl:with-param name="before-output" select="$before-output"/>
            <xsl:with-param name="after-output" select="$after-output"/>
            <xsl:with-param name="delimit-output" select="$delimit-output"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$after-output"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Do xsl:apply-templates to the children of the current node,
       adding a delimiter between each child. -->
  <xsl:template name="apply-delimited-children">
    <xsl:param name="delimeter" select="', '"/>
    <xsl:for-each select="*">
      <xsl:if test="position()!=1 and position != last()">
        <xsl:copy-of select="$delimeter"/>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>

  <!-- Output characters of a string, replacing the character
       specified by the "from" parameter with the characters specified
       by the "to" parameter. -->
  <xsl:template name="replace-char">
    <xsl:param name="from" select="''"/>
    <xsl:param name="to" select="''"/>
    <xsl:param name="string" select="''"/>
    <xsl:if test="$string">
      <xsl:choose>
        <xsl:when test="substring($string,1,1)=$from">
          <!-- Added this to avoid empty commas in sequences of
               spaces. It should be removed, I think. -sb -->
          <xsl:if test="substring($string,2,1)!=$from">
            <xsl:value-of select="$to"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($string,1,1)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="replace-char">
        <xsl:with-param name="string" select="substring($string, 2)"/>
        <xsl:with-param name="to" select="$to"/>
        <xsl:with-param name="from" select="$from"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
    <xsl:template name="doSpecType">
        <xsl:choose>
        	<xsl:when test="$spec='xquery'">XQuery</xsl:when>
        	<xsl:when test="$spec='xpath'">XPath</xsl:when>
        	<xsl:otherwise><xsl:value-of select="$spec"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

  
</xsl:stylesheet>
