<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="saxon"
                version="1.0">

  <xsl:key name="name" match="a" use="@name"/>

  <xsl:output method="xml" encoding="utf-8" indent="no"/>

  <xsl:preserve-space elements="*"/>

  <xsl:template match="a" priority="2">
    <xsl:choose>
      <xsl:when test="(@name or @id)
		and count(key('name', @name)) &gt; 1
		and ancestor-or-self::*[@class='diff-del']">
	<xsl:choose>
	  <xsl:when test="@href">
	    <xsl:copy>
	      <xsl:copy-of select="@href"/>
	      <xsl:apply-templates/>
	    </xsl:copy>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>Removed ID in deleted section (</xsl:text>
	      <xsl:value-of select="@name"/>
	      <xsl:text>)</xsl:text>
	    </xsl:message>
	    <xsl:apply-templates/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|processing-instruction()|text()">
    <xsl:copy/>
  </xsl:template>
</xsl:stylesheet>
