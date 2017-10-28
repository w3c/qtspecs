<?xml version="1.0"?>

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

<xsl:output method="xml"
            doctype-system="../../schema/xsl-query.dtd"/>

<xsl:key name="ids" match="*[@id]" use="@id"/>

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
    <xsl:message><xsl:value-of select="$XSLTprocessor"/></xsl:message>
    <xsl:comment><xsl:value-of select="$XSLTprocessor"/></xsl:comment>
    <xsl:apply-templates/>
  </xsl:template> 

<xsl:template match="*">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="back/inform-div1">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>

  <xsl:if test="not(following-sibling::inform-div1)">
    <xsl:if test="/spec/body/div1[position() &gt; 1]">
      <inform-div1 id="quickref">
        <head>Function and Operator Quick Reference</head>

        <div2>
          <head>Functions and Operators by Section</head>

          <glist>
            <xsl:apply-templates select="/spec/body/div1[position() &gt; 1]"
                                 mode="quickref"/>
          </glist>
        </div2>

        <div2>
          <head>Functions and Operators Alphabetically</head>

          <xsl:apply-templates select="//proto[not(@role) or @role != 'example']"
                               mode="quickref">
            <xsl:sort select="@name"/>
          </xsl:apply-templates>
        </div2>

      </inform-div1>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="div1" mode="quickref">
  <xsl:if test=".//example[@role='signature']">
    <gitem>
      <label>
        <xsl:value-of select="head"/>
      </label>
      <def>
        <glist>
          <xsl:apply-templates select="div2" mode="quickref"/>
        </glist>
      </def>
    </gitem>
  </xsl:if>
</xsl:template>

<xsl:template match="div2" mode="quickref">
  <xsl:if test=".//example[@role='signature']">
    <gitem>
      <label>
        <xsl:value-of select="head"/>
      </label>
      <def>
        <xsl:choose>
          <xsl:when test="div3">
            <xsl:apply-templates select="div3" mode="quickref"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select=".//proto" mode="quickref"/>
          </xsl:otherwise>
        </xsl:choose>
      </def>
    </gitem>
  </xsl:if>
</xsl:template>

<xsl:template match="div3" mode="quickref">
  <xsl:apply-templates select=".//proto" mode="quickref"/>
</xsl:template>

<xsl:template match="proto" mode="quickref">
  <xsl:variable name="def" select="key('ids', concat('func-', @name))"/>
  <xsl:variable name="prefix">
    <xsl:choose>
      <xsl:when test="@isOp='yes'">op:</xsl:when>
      <xsl:otherwise>xf:</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="protoref">
    <code class="function">
      <a href="#func-{@name}">
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="@name"/>
      </a>
    </code>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
    <code> =&gt; </code>
    <code class="return-type">
      <xsl:value-of select="@return-type"/>
      <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
    </code>
  </div>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->