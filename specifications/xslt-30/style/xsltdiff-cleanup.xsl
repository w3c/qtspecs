<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

  <xsl:key name="name" match="a" use="@name"/>
  <xsl:key name="id" match="*[@id]" use="@id"/>

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
  
  <!-- The diff stylesheets seem to generate nested div or span elements with identical attributes, causing failures
     on duplicate attributes. Can't work out why, so we'll repair the damage here. MHK 26/9/2014 -->
  
  <xsl:template match="*[@id=current()/../@id and @class=current()/../@class and name()=name(current()/..)]" priority="4">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[@id][not(current() is key('id', @id)[1])]">
    <xsl:copy>
      <xsl:copy-of select="@* except @id"/>
      <xsl:apply-templates/>
    </xsl:copy>   
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
