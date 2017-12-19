<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common"
  xmlns:f="http://local-functions/"
  xmlns:rddl="http://www.rddl.org/" exclude-result-prefixes="#all" version="2.0">

  <xsl:import href="xsl-query-2016.xsl"/>

  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:param name="specdoc" select="'SomeNS'"/>
  <xsl:param name="pubdate" as="xs:string" select="string(current-date())"/>
  <xsl:variable name="pubdate-as-date" as="xs:date" select="xs:date($pubdate)"/>

  <!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>XSLT Processor: </xsl:text>
      <xsl:value-of select="system-property('xsl:vendor')"/>
      <xsl:if test="system-property('xsl:version') = '2.0'">
        <xsl:text> </xsl:text>
        <xsl:value-of select="system-property('xsl:product-name')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:message>
      <xsl:value-of select="$XSLTprocessor"/>
    </xsl:message>
    <xsl:comment><xsl:value-of select="$XSLTprocessor"/></xsl:comment>
    <xsl:apply-templates/>
  </xsl:template>
 

  <xsl:template match="header">
    <div class="head">
      <p>
        <a href="http://www.w3.org/">
          <img src="http://www.w3.org/Icons/w3c_home" alt="W3C" height="48" width="72"/>
        </a>
      </p>

      <h1>
        <a name="title" id="title"/>
        <xsl:value-of select="title"/>
      </h1>
      <h2><xsl:value-of select="format-date(xs:date('2017-03-21'), '[D1] [MNn] [Y0001]')"/></h2>
    </div>
  </xsl:template>

  <xsl:template name="css">
    <style type="text/css">
    <xsl:value-of select="$additional.css"/>
    <xsl:text> </xsl:text>
  </style>
    <link rel="stylesheet" type="text/css">
      <xsl:attribute name="href">
        <xsl:text>http://www.w3.org/StyleSheets/TR/base.css</xsl:text>
      </xsl:attribute>
    </link>
  </xsl:template>

  <xsl:template match="code">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="div1">
    <xsl:choose>
      <xsl:when test="@class">
        <xsl:variable name="class" select="@class"/>
        <div class="{$class}">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="f:get-bibl" as="element(bibl)?">
    <xsl:param name="id" as="xs:string"/>
    <xsl:variable name="xsl-query" select="document('../etc/xsl-query-bibl.xml')"/>
    <xsl:variable name="tr" select="document('../etc/tr.xml')"/>
    <xsl:variable name="rfc" select="document('../etc/rfc.xml')"/>
    <xsl:sequence select="$xsl-query//bibl[@id = $id]"/>
  </xsl:function>


  <xsl:template match="bibl" name="bibl">
    <xsl:variable name="xsl-query" select="document('../etc/xsl-query-bibl.xml')"/>
    <xsl:variable name="tr" select="document('../etc/tr.xml')"/>
    <xsl:variable name="rfc" select="document('../etc/rfc.xml')"/>
    <xsl:variable name="id" select="@id"/>

    <xsl:if test="count(key('bibrefs', @id)) = 0">
      <xsl:message>
        <xsl:text>Warning: no bibref to bibl "</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>"</xsl:text>
      </xsl:message>
    </xsl:if>

    <dt class="label">
      <span>
        <xsl:if test="@role">
          <xsl:attribute name="class">
            <xsl:value-of select="@role"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@id">
          <a name="{@id}" id="{@id}"/>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@key">
            <xsl:value-of select="@key"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@id"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </dt>
    <dd>
      <div>
        <xsl:choose>
          <xsl:when test="@role and not(@class)">
            <xsl:attribute name="class">
              <xsl:value-of select="@role"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="@class and not(@role)">
            <xsl:attribute name="class">
              <xsl:value-of select="@class"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">
              <xsl:value-of select="@class"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@role"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="not(node()) and $xsl-query//bibl[@id = $id]">
            <xsl:apply-templates select="$xsl-query//bibl[@id = $id]/node()"/>
          </xsl:when>
          <xsl:when test="not(node()) and $tr//bibl[@id = $id]">
            <xsl:apply-templates select="$tr//bibl[@id = $id]/node()"/>
          </xsl:when>
          <xsl:when test="not(node()) and $rfc//bibl[@id = $id]">
            <xsl:apply-templates select="$rfc//bibl[@id = $id]/node()"/>
          </xsl:when>
          <xsl:when test="not(node())">
            <xsl:message>Error: no <xsl:value-of select="$id"/> known!</xsl:message>
            <xsl:text>ERROR: NO </xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text> KNOWN!</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </dd>
  </xsl:template>


  <xsl:template match="bibl/rddl:resource[not(*)]" priority="5" xmlns:rddl="http://www.rddl.org/"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:variable name="etc-bibl" select="f:get-bibl(../@id)"/>
    <xsl:variable name="raw-date" select="replace(string($etc-bibl), '^.*(20[0-9]{6,6}).*$', '$1', 's')"/>
    <xsl:variable name="cooked-date" as="xs:date">
      <xsl:variable name="punctuate" select="replace($raw-date, '(....)(..)(..)', '$1-$2-$3')"/>
      <xsl:sequence select="if ($punctuate castable as xs:date) then xs:date($punctuate) else current-date()"/>     
    </xsl:variable>
    <xsl:variable name="dated-loc" as="xs:string">      
      <xsl:variable name="t1" select="replace($etc-bibl/@key, 'https://www\.w3\.org/TR/', concat('https://www.w3.org/TR/', substring($raw-date, 1, 4)))"/>
      <xsl:sequence select="replace($t1, '/$', concat('-', $raw-date, '/'))"/> 
    </xsl:variable>
    
    <xsl:message>$etc-bibl/@key - <xsl:value-of select="$etc-bibl/@key"/></xsl:message>
    <xsl:message>$dated-loc - <xsl:value-of select="$dated-loc"/></xsl:message>

    <rddl:resource xmlns:rddl="http://www.rddl.org/"
      xlink:title="{$etc-bibl/@key}"
      xlink:role="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional"
      xlink:arcrole="http://www.rddl.org/purposes#normative-reference"
      xlink:href="{$etc-bibl/titleref/@href}">
      <p>
        <a href="{$etc-bibl/titleref/@href}">
          <xsl:value-of select="$etc-bibl/@key"/> 
        </a>
        (<xsl:value-of select="format-date($cooked-date, '[D1] [MNn] [Y0001]')"/> version)
      </p>
    </rddl:resource> 
      
  </xsl:template>
  
  <xsl:template match="bibl/rddl:resource[*]" priority="6" xmlns:rddl="http://www.rddl.org/"
    xmlns:xlink="http://www.w3.org/1999/xlink">

    
    <xsl:copy>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
    
  </xsl:template>

</xsl:stylesheet>
