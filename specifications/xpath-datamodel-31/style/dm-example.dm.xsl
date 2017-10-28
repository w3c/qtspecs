<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ann="http://nwalsh.com/xnlns/annotations"
                exclude-result-prefixes="ann"
                version="1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:strip-space elements="*"/>

<xsl:variable name="annot" select="document('')//ann:annotate"/>

<ann:annotate>
  <D1>
    <base-uri>xs:anyURI("http://www.example.com/catalog.xml")</base-uri>
  </D1>
  <E1>
    <type>anon:TYP000001</type>
    <typed-value>fn:error()</typed-value>
  </E1>
  <A1>
    <typed-value>(xs:anyURI("http://www.example.com/catalog"), xs:anyURI("catalog.xsd"))</typed-value>
    <type>anon:TYP000002</type>
  </A1>
  <A2>
    <typed-value>"en"</typed-value>
    <type>xs:NMTOKEN</type>
  </A2>
  <A3>
    <typed-value>"0.1"</typed-value>
    <type>xs:string</type>
  </A3>
  <C1>
    <typed-value>xs:string(dm:string-value())</typed-value>
  </C1>
  <E2>
    <typed-value>fn:error()</typed-value>
    <type>cat:tshirtType</type>
  </E2>
  <A4 normalize="yes">
    <typed-value>xs:ID("T1534017")</typed-value>
    <type>xs:ID</type>
    <is-id>true</is-id>
  </A4>
  <A5 normalize="yes">
    <typed-value>xs:token("Staind : Been Awhile")</typed-value>
    <type>xs:token</type>
  </A5>
  <A6>
    <typed-value>xs:anyURI("http://example.com/0,,1655091,00.html")</typed-value>
    <type>xs:anyURI</type>
  </A6>
  <A7>
    <typed-value>(xs:token("M"), xs:token("L"), xs:token("XL"))</typed-value>
    <type>cat:sizeList</type>
  </A7>
  <E3 normalize="yes">
    <typed-value>xs:token("Staind: Been Awhile Tee Black (1-sided)")</typed-value>
    <type>xs:token</type>
  </E3>
  <T1 normalize="yes"/>
  <E4>
    <typed-value>xs:untypedAtomic(dm:string-value())</typed-value>
    <type>cat:description</type>
  </E4>
  <E5>
    <typed-value>xs:untypedAtomic(dm:string-value())</typed-value>
    <type>xs:anyType</type>
  </E5>
  <E6 normalize="yes">
    <typed-value comment="The typed-value is based on the content type of the complex type for the element">cat:monetaryAmount(25.0)</typed-value>
    <type>cat:price</type>
  </E6>
  <T3 normalize="yes"/>
  <E7>
    <typed-value>fn:error()</typed-value>
    <type>cat:albumType</type>
  </E7>
  <A8 normalize="yes">
    <typed-value>xs:ID("A1481344")</typed-value>
    <type>xs:ID</type>
    <is-id>true</is-id>
  </A8>
  <A9 normalize="yes">
    <typed-value>xs:token("Staind : Its Been A While")</typed-value>
    <type>xs:token</type>
  </A9>
  <A10 normalize="yes">
    <typed-value>cat:formatType("CD")</typed-value>
    <type>cat:formatType</type>
  </A10>
  <E8 normalize="yes">
    <typed-value>xs:token("It's Been A While")</typed-value>
    <type>xs:token</type>
  </E8>
  <T4 normalize="yes"/>
  <E9>
    <typed-value comment="xsi:nil is true so the typed value is the empty sequence">()</typed-value>
    <type>cat:description</type>
  </E9>
  <A11 normalize="yes">
    <typed-value>xs:boolean("true")</typed-value>
    <type>xs:boolean</type>
  </A11>
  <E10 normalize="yes">
    <typed-value>cat:monetaryAmount(10.99)</typed-value>
    <type>cat:price</type>
  </E10>
  <T5 normalize="yes"/>
  <A12 normalize="yes">
    <typed-value>cat:currencyType("USD")</typed-value>
    <type>cat:currencyType</type>
  </A12>
  <E11>
    <typed-value>" Staind "</typed-value>
    <type>xs:string</type>
  </E11>
</ann:annotate>

<xsl:template match="/">
  <document label="D1">
    <xsl:copy-of select="$annot//*[name(.) = 'D1']/*"/>
    <value>
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string" select="."/>
        <xsl:with-param name="target" select="'&#10;'"/>
        <xsl:with-param name="replacement" select="'\n'"/>
      </xsl:call-template>
    </value>

    <xsl:for-each select="/*[1]/namespace::*">
      <xsl:variable name="label">
        <xsl:text>N</xsl:text>
        <xsl:value-of select="position()"/>
      </xsl:variable>

      <namespace label="{$label}">
        <xsl:attribute name="name">
          <xsl:value-of select="local-name(.)"/>
        </xsl:attribute>
        <xsl:copy-of select="$annot//*[name(.) = $label]/*"/>
        <value>
          <xsl:value-of select="."/>
        </value>
      </namespace>
    </xsl:for-each>

    <xsl:apply-templates select="node()"/>
  </document>
</xsl:template>

<xsl:template match="*">
  <xsl:variable name="elem" select="."/>
  <xsl:variable name="label">
    <xsl:text>E</xsl:text>
    <xsl:value-of select="count(preceding::*//descendant-or-self::*) + count(ancestor::*) + 1"/>
  </xsl:variable>

  <element label="{$label}">
    <xsl:attribute name="name">
      <xsl:value-of select="name(.)"/>
    </xsl:attribute>

    <xsl:copy-of select="$annot//*[name(.) = $label]/*"/>

    <value>
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string">
          <xsl:choose>
            <xsl:when test="$annot//*[name(.) = $label]/@normalize = 'yes'">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="target" select="'&#10;'"/>
        <xsl:with-param name="replacement" select="'\n'"/>
      </xsl:call-template>
    </value>

    <xsl:for-each select="@*">
      <xsl:variable name="alabel">
        <xsl:text>A</xsl:text>
        <xsl:value-of select="count($elem/preceding::*/@*) + count($elem/ancestor::*/@*) + position()"/>
      </xsl:variable>

      <attribute label="{$alabel}">
        <xsl:attribute name="name">
          <xsl:value-of select="name(.)"/>
        </xsl:attribute>

        <xsl:copy-of select="$annot//*[name(.) = $alabel]/*"/>

        <value>
          <xsl:call-template name="string.subst">
            <xsl:with-param name="string">
              <xsl:choose>
                <xsl:when test="$annot//*[name(.) = $alabel]/@normalize = 'yes'">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="target" select="'&#10;'"/>
            <xsl:with-param name="replacement" select="'\n'"/>
          </xsl:call-template>
        </value>
      </attribute>
    </xsl:for-each>

    <xsl:apply-templates select="node()"/>
  </element>
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
      <xsl:with-param name="replacement" select="'\n'"/>
    </xsl:call-template>
  </xsl:variable>

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

  <xsl:variable name="label">
    <xsl:text>T</xsl:text>
    <xsl:value-of select="count(preceding::text()) + count(preceding-sibling::text()) + 1"/>
  </xsl:variable>

  <text>
    <xsl:attribute name="label">
      <xsl:value-of select="$label"/>
    </xsl:attribute>
    <xsl:attribute name="name">
      <xsl:value-of select="$labelvalue"/>
    </xsl:attribute>
    <value>
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string">
          <xsl:choose>
            <xsl:when test="$annot//*[name(.) = $label]/@normalize = 'yes'">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="target" select="'&#10;'"/>
        <xsl:with-param name="replacement" select="'\n'"/>
      </xsl:call-template>
    </value>
  </text>
</xsl:template>

<xsl:template match="processing-instruction()">
  <processing-instruction>
    <xsl:attribute name="label">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="count(preceding::processing-instruction()) + 1"/>
    </xsl:attribute>
    <xsl:attribute name="name">
      <xsl:value-of select="local-name(.)"/>
    </xsl:attribute>
    <value>
      <xsl:value-of select="."/>
    </value>
  </processing-instruction>
</xsl:template>

<xsl:template match="comment()">
  <comment>
    <xsl:attribute name="label">
      <xsl:text>C</xsl:text>
      <xsl:value-of select="count(preceding::comment()) + 1"/>
    </xsl:attribute>
    <value>
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string" select="."/>
        <xsl:with-param name="target" select="'&#10;'"/>
        <xsl:with-param name="replacement" select="'\n'"/>
      </xsl:call-template>
    </value>
  </comment>
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
