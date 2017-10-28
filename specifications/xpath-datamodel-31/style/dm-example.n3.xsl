<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:output method="text"/>

<xsl:strip-space elements="*"/>

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
<xsl:text><![CDATA[# XML Tree Model
#

@prefix : <xxx#> .
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix log: <http://www.w3.org/2000/10/swap/log#> .
@prefix gv: <http://www.w3.org/2001/02pd/gv#>.
@prefix ont: <http://www.daml.org/2001/03/daml+oil#> .

<> dc:description "Tree Model of an XML Instance" .

# Classes

:Node a rdfs:Class .
:Document a rdfs:Class .
:Element a rdfs:Class .
:Attribute a rdfs:Class .
:Namespace a rdfs:Class .
:Text a rdfs:Class .
:Comment a rdfs:Class .
:ProcessingInstruction a rdfs:Class .

]]></xsl:text>

  <xsl:text>:idD1 a :Document .&#10;</xsl:text>
  <xsl:text>:idD1 :label "D1" .&#10;</xsl:text>

  <xsl:for-each select="*|text()|comment()|processing-instruction()">
    <xsl:text>:idD1</xsl:text>
    <xsl:text> :child </xsl:text>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> .&#10;</xsl:text>
  </xsl:for-each>

  <xsl:text>&#10;</xsl:text>

  <xsl:for-each select="/*[1]/namespace::*">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> a :Namespace .&#10;</xsl:text>

    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> :label "N</xsl:text>
    <xsl:value-of select="position()"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:text>" .&#10;</xsl:text>

    <xsl:text>&#10;</xsl:text>
  </xsl:for-each>

  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="*">
  <xsl:variable name="elem" select="."/>
  <xsl:variable name="elemid" select="generate-id()"/>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="$elemid"/>
  <xsl:text> a :Element .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="$elemid"/>
  <xsl:text> :label "E</xsl:text>
  <xsl:value-of select="count(preceding::*//descendant-or-self::*) + count(ancestor::*) + 1"/>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>" .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="$elemid"/>
  <xsl:text> :name "</xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>" .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="$elemid"/>
  <xsl:text> :parent :</xsl:text>
  <xsl:choose>
    <xsl:when test="parent::*">
      <xsl:value-of select="generate-id(parent::*)"/>
    </xsl:when>
    <xsl:otherwise>idD1</xsl:otherwise>
  </xsl:choose>
  <xsl:text> .&#10;</xsl:text>

  <xsl:for-each select="@*">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$elemid"/>
    <xsl:text> :attribute </xsl:text>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> .&#10;</xsl:text>
  </xsl:for-each>

  <xsl:for-each select="*|text()|comment()|processing-instruction()">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$elemid"/>
    <xsl:text> :child </xsl:text>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> .&#10;</xsl:text>
  </xsl:for-each>

  <xsl:text>&#10;</xsl:text>

  <xsl:for-each select="@*">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> a :Attribute .&#10;</xsl:text>

    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> :parent :</xsl:text>
    <xsl:value-of select="$elemid"/>
    <xsl:text> .&#10;</xsl:text>

    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> :label "A</xsl:text>
    <xsl:value-of select="count($elem/preceding::*/@*) + count($elem/ancestor::*/@*) + position()"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text>" .&#10;</xsl:text>

    <xsl:text>:</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text> :name "</xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text>" .&#10;</xsl:text>

    <xsl:text>&#10;</xsl:text>
  </xsl:for-each>

  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()">
  <xsl:variable name="rawvalue">
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; 12">
        <xsl:value-of select="concat(substring(., 1, 9), '...')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="normalizedvalue">
    <xsl:choose>
      <xsl:when test="string-length(normalize-space(.)) &gt; 12">
        <xsl:value-of select="concat(substring(normalize-space(.), 1, 9), '...')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="value">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$rawvalue"/>
      <xsl:with-param name="target" select="'&#10;'"/>
      <xsl:with-param name="replacement" select="'\\\\n'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="intvalue" select="$value"/>
  <xsl:variable name="intnormalizedvalue" select="$value"/>
<!--
  <xsl:variable name="intvalue">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$value"/>
      <xsl:with-param name="target">'</xsl:with-param>
      <xsl:with-param name="replacement">\'</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="intnormalizedvalue">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$normalizedvalue"/>
      <xsl:with-param name="target">'</xsl:with-param>
      <xsl:with-param name="replacement">\'</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
-->

  <xsl:variable name="labelvalue">
    <xsl:choose>
      <xsl:when test="name(parent::*) = 'price'
                      or name(parent::*) = 'title'">
        <xsl:value-of select="$intnormalizedvalue"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- in fact all the text nodes should be normalized in the current example -->
        <xsl:value-of select="$intvalue"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> a :Text .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :parent :</xsl:text>
  <xsl:choose>
    <xsl:when test="parent::*">
      <xsl:value-of select="generate-id(parent::*)"/>
    </xsl:when>
    <xsl:otherwise>idD1</xsl:otherwise>
  </xsl:choose>
  <xsl:text> .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :label "T</xsl:text>
  <xsl:value-of select="count(preceding::text()) + count(preceding-sibling::text()) + 1"/>

  <xsl:text>: '</xsl:text>
  <xsl:value-of select="$labelvalue"/>
  <xsl:text>'" .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :value "</xsl:text>
  <xsl:call-template name="string.subst">
    <xsl:with-param name="string" select="."/>
    <xsl:with-param name="target" select="'&#10;'"/>
    <xsl:with-param name="replacement" select="'\\\\n'"/>
  </xsl:call-template>
  <xsl:text>" .&#10;</xsl:text>

  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="processing-instruction()">
  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> a :ProcessingInstruction .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :parent :</xsl:text>
  <xsl:choose>
    <xsl:when test="parent::*">
      <xsl:value-of select="generate-id(parent::*)"/>
    </xsl:when>
    <xsl:otherwise>idD1</xsl:otherwise>
  </xsl:choose>
  <xsl:text> .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :label "P</xsl:text>
  <xsl:value-of select="count(preceding::processing-instruction()) + count(preceding-sibling::processing-instruction()) + 1"/>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>" .&#10;</xsl:text>

  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="comment()">
  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> a :Comment .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :parent :</xsl:text>
  <xsl:choose>
    <xsl:when test="parent::*">
      <xsl:value-of select="generate-id(parent::*)"/>
    </xsl:when>
    <xsl:otherwise>idD1</xsl:otherwise>
  </xsl:choose>
  <xsl:text> .&#10;</xsl:text>

  <xsl:text>:</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text> :label "C</xsl:text>
  <xsl:value-of select="count(preceding::comment()) + count(preceding-sibling::comment()) + 1"/>
  <xsl:text>" .&#10;</xsl:text>

  <xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="string.subst">
  <xsl:param name="string"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>

  <xsl:choose>
    <xsl:when test="contains($string, $target)">
      <xsl:variable name="rest">
        <xsl:call-template name="string.subst">
          <xsl:with-param name="string" select="substring-after($string, $target)"/>
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="replacement" select="$replacement"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="concat(substring-before($string, $target),                                    $replacement,                                    $rest)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->