<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="http://www.w3.org/qtspecs/build/functions"
  exclude-result-prefixes="my xs"
  version="2.0"
>

  <xsl:import href="xmlspec.xsl"/>

  <xsl:param name="show-markup" select="'0'"/>
  <xsl:variable name="show.diff.markup" as="xs:integer" select="$show-markup cast as xs:integer"/>
  <xsl:param name="called.by.diffspec" select="0" as="xs:integer"/>
  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <xsl:param name="diff.baseline" select="''" as="xs:string"/>
  <xsl:param name="diff.baseline.date" select="()" as="xs:string?"/>
  <xsl:param name="additional.css"/>
  <xsl:param name="additional.css.2"/>

  <xsl:param name="chg-color" select="'#ffff99'"/>
  <xsl:param name="add-color" select="'#99ff99'"/>
  <xsl:param name="del-color" select="'#ff9999'"/>
  <xsl:param name="off-color" select="'#ffffff'"/>

  <!-- 2010-12-23: Jim $additional.css to $additional.css.diff, which will be non-empty
                 only when diffs are being done; won't override doc stylesheet $additional.css -->
  <xsl:param name="additional.css.diff">
<!--
<xsl:comment>(xsl-query - $show.diff.markup = <xsl:value-of select="$show.diff.markup"/>)</xsl:comment>
<xsl:message>(xsl-query - $show.diff.markup = <xsl:value-of select="$show.diff.markup"/>)</xsl:message>
-->
    <xsl:if test="xs:integer($show.diff.markup) != 0">
/* from xsl-query.xsl (A) */      
.diff-add  { background-color: <xsl:value-of select="$add-color"/> }
.diff-del  { background-color: <xsl:value-of select="$del-color"/>; text-decoration: line-through }
.diff-chg  { background-color: <xsl:value-of select="$chg-color"/> }
.diff-off  { background-color: <xsl:value-of select="$off-color"/>; text-decoration: none; }
    </xsl:if>
/* from xsl-query.xsl (B) */    
table.small                             { font-size: x-small; }
a.judgment:visited, a.judgment:link     { font-family: sans-serif;
                              	          color: black; 
                              	          text-decoration: none }
a.processing:visited, a.processing:link { color: black; 
                              		        text-decoration: none }
a.env:visited, a.env:link               { color: black; 
                                          text-decoration: none }</xsl:param>

  <xsl:param name="additional.title">
    <xsl:if test="$show.diff.markup != 0">
      <xsl:text>Review Version</xsl:text>
    </xsl:if>
  </xsl:param>

  <xsl:output method="xml" indent="no" encoding="utf-8"/>

  <xsl:key name="error" match="error" use="concat(@class,@code)"/>
  <xsl:key name="bibrefs" match="bibref" use="@ref"/>


  <xsl:param name="specdoc" select="'XX'"/>

  <xsl:variable name="default.specdoc">
    <xsl:choose>
      <xsl:when test="$specdoc != 'XX'">
        <xsl:value-of select="$specdoc"/>
        <xsl:message>specdoc is <xsl:value-of select="$specdoc"/> (override)</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Data Model') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'DM'"/>
        <xsl:message>specdoc is DM</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'FO'"/>
        <xsl:message>specdoc is FO</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XPath') and
                      contains(/spec/header/title, '2.0')">
        <xsl:value-of select="'XP'"/>
        <xsl:message>specdoc is XP</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XML Query Language') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'XQ'"/>
        <xsl:message>specdoc is XQ</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Formal Semantics') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'FS'"/>
        <xsl:message>specdoc is FS</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQueryX') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'XQX'"/>
        <xsl:message>specdoc is XQX</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Serialization') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'SER'"/>
        <xsl:message>specdoc is SER</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XML Query') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'XQR'"/>
        <xsl:message>specdoc is XQR</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XML Query') and
                      contains(/spec/header/title, 'Use Cases')">
        <xsl:value-of select="'XQUC'"/>
        <xsl:message>specdoc is XQUC</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Data Model') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'DM11'"/>
        <xsl:message>specdoc is DM11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'FO11'"/>
        <xsl:message>specdoc is FO11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XPath') and
                      contains(/spec/header/title, '2.1')">
        <xsl:value-of select="'XP21'"/>
        <xsl:message>specdoc is XP21</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'XQ11'"/>
        <xsl:message>specdoc is XQ11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Formal Semantics') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'FS11'"/>
        <xsl:message>specdoc is FS11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQueryX') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'XQX11'"/>
        <xsl:message>specdoc is XQX11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Serialization') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'SER11'"/>
        <xsl:message>specdoc is SER11</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Data Model') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'DM30'"/>
        <xsl:message>specdoc is DM30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'FO30'"/>
        <xsl:message>specdoc is FO30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XPath') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XP30'"/>
        <xsl:message>specdoc is XP30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQ30'"/>
        <xsl:message>specdoc is XQ30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQueryX') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQX30'"/>
        <xsl:message>specdoc is XQX30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Serialization') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'SER30'"/>
        <xsl:message>specdoc is SER30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XML Query') and
                      contains(/spec/header/title, 'Requirements') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'XQR11'"/>
        <xsl:message>specdoc is XQR11</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, 'Use Cases') and
                      contains(/spec/header/title, '1.1')">
        <xsl:value-of select="'XQUC11'"/>
        <xsl:message>specdoc is XQUC11</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Full Text') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'FTR'"/>
        <xsl:message>specdoc is FTR</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Full Text') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Use Cases')">
        <xsl:value-of select="'FTUC'"/>
        <xsl:message>specdoc is FTUC</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Full Text') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'FT'"/>
        <xsl:message>specdoc is FT</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Update Facility') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'XQUR'"/>
        <xsl:message>specdoc is XQUR</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Update Facility') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Use Cases')">
        <xsl:value-of select="'XQUU'"/>
        <xsl:message>specdoc is XQUU</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Update Facility') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'XQU'"/>
        <xsl:message>specdoc is XQU</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Scripting Extension') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'SXR'"/>
        <xsl:message>specdoc is SXR</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Scripting Extension') and
                      contains(/spec/header/title, '1.0') and
                      contains(/spec/header/title, 'Use Cases')">
        <xsl:value-of select="'SXU'"/>
        <xsl:message>specdoc is SXU</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Scripting Extension') and
                      contains(/spec/header/title, '1.0')">
        <xsl:value-of select="'SX'"/>
        <xsl:message>specdoc is SX</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XSLT') and
                      contains(/spec/header/title, '2.0')">
        <xsl:value-of select="'XSLT'"/>
        <xsl:message>specdoc is XSLT</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Data Model') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'DM30'"/>
        <xsl:message>specdoc is DM30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'FO30'"/>
        <xsl:message>specdoc is FO30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XPath') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XP30'"/>
        <xsl:message>specdoc is XP30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQ30'"/>
        <xsl:message>specdoc is XQ30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Formal Semantics') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'FS30'"/>
        <xsl:message>specdoc is FS30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XQueryX') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQX30'"/>
        <xsl:message>specdoc is XQX30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Serialization') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'SER30'"/>
        <xsl:message>specdoc is SER30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XML Query') and
                      contains(/spec/header/title, 'Requirements') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQR30'"/>
        <xsl:message>specdoc is XQR30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, 'Use Cases') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQUC30'"/>
        <xsl:message>specdoc is XQUC30</xsl:message>
      </xsl:when>


      <xsl:when test="contains(/spec/header/title, 'Data Model') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'DM31'"/>
        <xsl:message>specdoc is DM31</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'FO31'"/>
        <xsl:message>specdoc is FO31</xsl:message>
      </xsl:when>
      
      <xsl:when test="contains(/spec/header/title, 'Functions and Operators') and
        contains(/spec/header/title, '4.0')">
        <xsl:value-of select="'FO40'"/>
        <xsl:message>specdoc is FO40</xsl:message>
      </xsl:when>
      
      <xsl:when test="contains(/spec/header/title, 'XPath') and
        contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'XP31'"/>
        <xsl:message>specdoc is XP31</xsl:message>
      </xsl:when>
      
      <xsl:when test="contains(/spec/header/title, 'XPath') and
        contains(/spec/header/title, '4.0')">
        <xsl:value-of select="'XP40'"/>
        <xsl:message>specdoc is XP40</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XQuery') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'XQ31'"/>
        <xsl:message>specdoc is XQ31</xsl:message>
      </xsl:when>
      
      <xsl:when test="contains(/spec/header/title, 'XQuery') and
        contains(/spec/header/title, '4.0')">
        <xsl:value-of select="'XQ40'"/>
        <xsl:message>specdoc is XQ40</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XQueryX') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'XQX31'"/>
        <xsl:message>specdoc is XQX31</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Serialization') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'SER31'"/>
        <xsl:message>specdoc is SER31</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'XML Query') and
                      contains(/spec/header/title, 'Requirements') and
                      contains(/spec/header/title, '3.1')">
        <xsl:value-of select="'XQRUC31'"/>
        <xsl:message>specdoc is XQRUC31</xsl:message>
      </xsl:when>


      <xsl:when test="contains(/spec/header/title, 'Full Text') and
                      contains(/spec/header/title, '3.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'FT30RU'"/>
        <xsl:message>specdoc is FT30RU</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Full Text') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'FT30'"/>
        <xsl:message>specdoc is FT30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Update Facility') and
                      contains(/spec/header/title, '3.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'XQU30RU'"/>
        <xsl:message>specdoc is XQU30RU</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Update Facility') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XQU30'"/>
        <xsl:message>specdoc is XQU30</xsl:message>
      </xsl:when>

      <xsl:when test="contains(/spec/header/title, 'Scripting Extension') and
                      contains(/spec/header/title, '3.0') and
                      contains(/spec/header/title, 'Requirements')">
        <xsl:value-of select="'SX30RU'"/>
        <xsl:message>specdoc is SX30RU</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'Scripting Extension') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'SX30'"/>
        <xsl:message>specdoc is SX30</xsl:message>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, 'XSLT') and
                      contains(/spec/header/title, '3.0')">
        <xsl:value-of select="'XSLT30'"/>
        <xsl:message>specdoc is XSLT30</xsl:message>
      </xsl:when>

        <xsl:otherwise>
        <xsl:message>Title: <xsl:value-of select="/spec/header/title"/></xsl:message>
        <xsl:message terminate="yes">
          <xsl:text>xsl-query.xsl says: Failed to determine which specdoc this is: use specdoc parameter!</xsl:text>
          <xsl:value-of select="'Title: ', /spec/header/title"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ====================================================================== -->

  <!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{xsl-query} </xsl:text>
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
    <xsl:comment>
      <xsl:value-of select="$XSLTprocessor"/>
    </xsl:comment>
<!--
<xsl:comment>$show.diff.markup = <xsl:value-of select="$show.diff.markup"/></xsl:comment>
<xsl:message>$show.diff.markup = <xsl:value-of select="$show.diff.markup"/></xsl:message>
-->
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template name="css">
    <style type="text/css">
      <xsl:text>
/* from xsl:query.xsl (C) */          
code           { font-family: monospace; }

div.constraint,
div.issue,
div.note,
div.notice     { margin-left: 2em; }

div.issue
p.title        { margin-left: -2em; }

ol.enumar      { list-style-type: decimal; }
ol.enumla      { list-style-type: lower-alpha; }
ol.enumlr      { list-style-type: lower-roman; }
ol.enumua      { list-style-type: upper-alpha; }
ol.enumur      { list-style-type: upper-roman; }

li p           { margin-top: 0.3em;
                 margin-bottom: 0.3em; }

sup small      { font-style: italic;
                 color: #8F8F8F;
               }
    </xsl:text>
      <xsl:if test="$tabular.examples = 0">
        <xsl:text>
/* from xsl:query.xsl (D) */          
div.exampleInner pre { margin-left: 1em;
                       margin-top: 0em; margin-bottom: 0em}
div.exampleOuter {border: 4px double gray;
                  margin: 0em; padding: 0em}
div.exampleInner { background-color: #d5dee3;
                   border-top-width: 4px;
                   border-top-style: double;
                   border-top-color: #d3d3d3;
                   border-bottom-width: 4px;
                   border-bottom-style: double;
                   border-bottom-color: #d3d3d3;
                   padding: 4px; margin: 0em }
div.exampleWrapper { margin: 4px }
div.exampleHeader { font-weight: bold;
                    margin: 4px}

div.issue { border-bottom-color: black;
            border-bottom-style: solid;
	    border-bottom-width: 1pt;
	    margin-bottom: 20pt;
}

th.issue-toc-head { border-bottom-color: black;
                    border-bottom-style: solid;
                    border-bottom-width: 1pt;
}

      </xsl:text>
      </xsl:if>
      <xsl:value-of select="$additional.css"/>
      <xsl:value-of select="$additional.css.2"/>
      <!-- 2010-12-23: Jim added the following inclusion of $additional.css.diff,
                 which will be non-empty only when diffs are being done -->
      <xsl:value-of select="$additional.css.diff"/>
    </style>
    <link rel="stylesheet" type="text/css">
      <xsl:attribute name="href">
<!-- 2014-01-31: Jim removed the scheme (http:) from the URI text so newer browsers -->
<!-- can access the CSS stylesheet whether the document itself is reached by http or https -->
        <xsl:text>//www.w3.org/StyleSheets/TR/</xsl:text>
        <xsl:choose>
          <xsl:when test="/spec/@role='editors-copy'">base</xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="/spec/@w3c-doctype='wd'">W3C-WD</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='cr'">W3C-CR</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='pr'">W3C-PR</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='per'">W3C-PER</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='rec'">W3C-REC</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='note'">W3C-NOTE</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='wgnote'">W3C-WG-NOTE</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='memsub'">W3C-Member-SUBM</xsl:when>
              <xsl:when test="/spec/@w3c-doctype='teamsub'">W3C-Team-SUBM</xsl:when>
              <xsl:otherwise>base</xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>.css</xsl:text>
      </xsl:attribute>
    </link>
  </xsl:template>

  <xsl:template match="br">
    <br/>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Automatic glossaries -->

  <xsl:template match="processing-instruction('glossary')">
    <dl>
      <xsl:apply-templates select="//termdef" mode="glossary-list">
        <xsl:sort select="@term" data-type="text" order="ascending"/>
      </xsl:apply-templates>
    </dl>
  </xsl:template>

  <xsl:template match="termdef" mode="glossary-list">
    <xsl:variable name="diff_governor" select="ancestor-or-self::*[@diff][1]"/>
    <xsl:variable name="diff_effect" select="my:diff-markup-effect($diff_governor)"/>
    <xsl:choose>
      <xsl:when test="$diff_effect eq 'delete'">
      </xsl:when>

      <xsl:when test="$diff_effect eq 'normal'">
        <dt>
          <a name="GL{@id}"/>
          <xsl:value-of select="@term"/>
        </dt>
        <dd>
          <p>
            <xsl:apply-templates/>
          </p>
          <xsl:if test="@open='true'">
            <xsl:variable name="close" select="../following-sibling::p[@role='closetermdef'][1]"/>
            <xsl:apply-templates select="../following-sibling::*[$close >> .]"/>
          </xsl:if>
        </dd>
      </xsl:when>

      <xsl:when test="$diff_effect eq 'highlight'">
        <dt class="diff-{$diff_governor/@diff}">
          <a name="GL{@id}"/>
          <xsl:value-of select="@term"/>
        </dt>
        <dd class="diff-{$diff_governor/@diff}">
          <p>
            <xsl:apply-templates/>
          </p>
          <xsl:apply-templates select="$diff_governor/@at">
            <xsl:with-param name="put-in-p" select="true()"/>
          </xsl:apply-templates>
        </dd>
      </xsl:when>

    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Automatic lists of impl def/dep features -->

  <xsl:template match="processing-instruction('imp-def-feature')">
    <ol>
      <xsl:apply-templates select="//imp-def-feature" mode="imp-def"/>
    </ol>
  </xsl:template>

  <xsl:template match="processing-instruction('imp-dep-feature')">
    <ol>
      <xsl:apply-templates select="//imp-dep-feature" mode="imp-def"/>
    </ol>
  </xsl:template>

  <xsl:template match="imp-def-feature|imp-dep-feature" mode="imp-def">
    <xsl:variable name="div" select="(ancestor::div1|ancestor::div2|ancestor::div3|ancestor::div4|ancestor::div5)[last()]"/>
    <li>
      <xsl:apply-templates/>
      <xsl:text> (See </xsl:text>
      <xsl:apply-templates select="$div" mode="specref"/>
      <xsl:text>)</xsl:text>
    </li>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Error Markup -->

  <xsl:template match="error" name="make-error-ref">
    <xsl:param name="uri" select="''"/>

    <xsl:variable name="spec">
      <xsl:choose>
        <xsl:when test="@spec">
          <xsl:value-of select="replace(@spec, '3[0|1]', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($default.specdoc,1,2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="@class">
          <xsl:value-of select="@class"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="code">
      <xsl:choose>
        <xsl:when test="@code">
          <xsl:value-of select="@code"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="label">
      <!-- CREATES LABEL IN XQUERY STYLE -->
      <xsl:text>err:</xsl:text>
      <xsl:value-of select="$spec"/>
      <xsl:value-of select="$class"/>
      <xsl:value-of select="$code"/>
    </xsl:variable>

    <xsl:text>[</xsl:text>

    <a href="{$uri}#ERR{$spec}{$class}{$code}" title="{$label}">
      <!-- ??? 
    <xsl:if test="@label and $spec != $default.specdoc">
      <xsl:text>Error: </xsl:text>
      <xsl:value-of select="$spec"/>
      <xsl:text>: </xsl:text>
    </xsl:if>
    -->
      <xsl:value-of select="$label"/>
    </a>

    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="errorref">
    <xsl:variable name="error" select="key('error', concat(@class,@code))"/>

    <xsl:choose>
      <xsl:when test="$error">
        <xsl:apply-templates select="$error[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Warning: Error <xsl:value-of select="@code"/> not found.</xsl:message>
        <xsl:text>[ERROR </xsl:text>
        <xsl:value-of select="@code"/>
        <xsl:text> NOT FOUND]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="error-list">
    <dl>
      <xsl:apply-templates mode="error-list"/>
    </dl>
  </xsl:template>

  <xsl:template match="processing-instruction('error-list')">
    <dl>
      <xsl:apply-templates select="//error" mode="error-list"/>
    </dl>
  </xsl:template>

  <xsl:template match="error" mode="error-list">
    <xsl:variable name="spec">
      <xsl:choose>
        <xsl:when test="@spec">
          <xsl:value-of select="@spec"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($default.specdoc,1,2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
 <!--
    <xsl:message><xsl:value-of select="'@spec:', @spec, '$spec:', $spec"/></xsl:message>
-->

    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="@class">
          <xsl:value-of select="@class"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="code">
      <xsl:choose>
        <xsl:when test="@code">
          <xsl:value-of select="@code"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="@label">
          <xsl:value-of select="@label"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$spec"/>
          <xsl:value-of select="$class"/>
          <xsl:value-of select="$code"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <dt>
      <a name="ERR{$spec}{$class}{$code}"/>
      <xsl:text>err:</xsl:text>
      <xsl:value-of select="concat($spec, $class, $code)"/>
      <xsl:if test="@label">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="@label"/>
      </xsl:if>
    </dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Imp def/dep markup -->

  <xsl:template match="imp-def-feature"/>
  <xsl:template match="imp-dep-feature"/>

  <!-- ====================================================================== -->
  <!-- Cross-spec references -->

  <xsl:template match="xspecref">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="doc" select="document(concat('../etc/', @spec, '.xml'))"/>
    <xsl:variable name="div" select="$doc//*[@id=$ref]"/>
    <xsl:variable name="nt" select="($doc//*[@def=$ref])[1]"/>
    <xsl:variable name="uri" select="$doc/document-summary/@uri"/>

    <xsl:choose>
      <xsl:when test="$div">
        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref}">
              <xsl:text>Section </xsl:text>
              <xsl:value-of select="$div/head"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Section </xsl:text>
            <xsl:value-of select="$div/head"/>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:when test="$nt">
        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref}">
              <xsl:value-of select="string($nt)"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="string($nt)"/>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:when test="node()">
        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref}">
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Warning: Cannot resolve </xsl:text>
          <xsl:copy-of select="."/>
          <xsl:text> at id=</xsl:text>
          <xsl:value-of select="(ancestor::*/@id)[last()]"/>
        </xsl:message>
        <xsl:text>[TITLE OF </xsl:text>
        <xsl:value-of select="@spec"/>
        <xsl:text> SPEC, TITLE OF </xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text> SECTION]</xsl:text>
        <xsl:apply-templates/>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xnt[not(@spec)]" priority="2">
    <!-- if there's no @spec, don't try to load a document ... -->
    <xsl:call-template name="process-xnt"/>
  </xsl:template>

  <xsl:template match="xnt">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="doc" select="document(concat('../etc/', @spec, '.xml'))"/>
    <xsl:variable name="nt" select="$doc//nt[@def=$ref]"/>
    <xsl:variable name="uri" select="$doc/document-summary/@uri"/>

    <xsl:choose>
      <xsl:when test="contains(@spec, 'XP') and not($nt)">
        <!-- XP and XQ are a special case -->
        <xsl:variable name="ref2" select="concat('doc-xpath-',@ref)"/>
        <xsl:variable name="nt2" select="$doc//nt[@def=$ref2]"/>
        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref2}">
              <xsl:call-template name="process-xnt">
                <xsl:with-param name="doc" select="$doc"/>
                <xsl:with-param name="nt" select="$nt2"/>
              </xsl:call-template>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process-xnt">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="nt" select="$nt2"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:when test="contains(@spec, 'XQ') and not($nt)">
        <!-- XP and XQ are a special case -->
        <xsl:variable name="ref2" select="concat('doc-xquery-',@ref)"/>
        <xsl:variable name="nt2" select="$doc//nt[@def=$ref2]"/>

        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref2}">
              <xsl:call-template name="process-xnt">
                <xsl:with-param name="doc" select="$doc"/>
                <xsl:with-param name="nt" select="$nt2"/>
              </xsl:call-template>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process-xnt">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="nt" select="$nt2"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$uri">
            <a href="{$uri}#{$ref}">
              <xsl:call-template name="process-xnt">
                <xsl:with-param name="doc" select="$doc"/>
                <xsl:with-param name="nt" select="$nt"/>
              </xsl:call-template>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process-xnt">
              <xsl:with-param name="doc" select="$doc"/>
              <xsl:with-param name="nt" select="$nt"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <sup>
          <small>
            <xsl:value-of select="@spec"/>
          </small>
        </sup>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process-xnt">
    <xsl:param name="doc"/>
    <xsl:param name="nt"/>

    <xsl:choose>
      <xsl:when test="@href">
        <a href="{@href}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="not($nt)">
        <xsl:message>
          <xsl:text>Warning: Cannot resolve </xsl:text>
          <xsl:copy-of select="."/>
          <xsl:text> at id=</xsl:text>
          <xsl:value-of select="(ancestor::*/@id)[last()]"/>
        </xsl:message>
        <xsl:text>[NT </xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text> IN </xsl:text>
        <xsl:value-of select="@spec"/>
        <xsl:text>]</xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="node()">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nt"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xtermref">
    <xsl:variable name="href" select="@href"/>
    <xsl:choose>
      <xsl:when test="$href">
        <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="doc" select="document(concat('../etc/', @spec, '.xml'))"/>
        <xsl:variable name="termdef" select="$doc//termdef[@id=$ref]"/>
        <xsl:variable name="uri" select="$doc/document-summary/@uri"/>

        <xsl:choose>
          <xsl:when test="not($termdef)">
            <xsl:message>
              <xsl:text>Warning: Cannot resolve </xsl:text>
              <xsl:copy-of select="."/>
              <xsl:text> at id=</xsl:text>
              <xsl:value-of select="(ancestor::*/@id)[last()]"/>
            </xsl:message>
            <xsl:text>[TERMDEF </xsl:text>
            <xsl:value-of select="@ref"/>
            <xsl:text> IN </xsl:text>
            <xsl:value-of select="@spec"/>
            <xsl:text>]</xsl:text>
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:when test="node()">
            <xsl:choose>
              <xsl:when test="$uri">
                <a href="{$uri}#{$ref}">
                  <xsl:apply-templates/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <sup>
              <small>
                <xsl:value-of select="@spec"/>
              </small>
            </sup>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$uri">
                <a href="{$uri}#{$ref}">
                  <xsl:value-of select="$termdef/@term"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$termdef/@term"/>
              </xsl:otherwise>
            </xsl:choose>
            <sup>
              <small>
                <xsl:value-of select="@spec"/>
              </small>
            </sup>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="implied_spec_version_for_xerrorref">
    <xsl:choose>
      <xsl:when test="contains(/spec/header/title, '3.1') or contains(/spec/header/version, '3.1')">
        <xsl:value-of select="'31'"/>
      </xsl:when>
      <xsl:when test="contains(/spec/header/title, '3.0') or contains(/spec/header/version, '3.0')">
        <xsl:value-of select="'30'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="xerrorref">
    <xsl:variable name="ref" select="@code"/>
    <xsl:variable name="class" select="@class"/>
    <xsl:variable name="spec" select="
      if (string-length(@spec) eq 2) then
        (: It would be better if we didn't have this special case,
           but unfortunately it's relied on rather widely now. :)
        concat(@spec, $implied_spec_version_for_xerrorref)
      else
        @spec
    "/>
    <xsl:variable name="doc" select="document(concat('../etc/', $spec, '.xml'))"/>
    <xsl:variable name="error" select="$doc//error[@code=$ref and @class=$class]"/>
    <xsl:variable name="uri" select="$doc/document-summary/@uri"/>

    <!--
  <xsl:message>
    <xsl:text>xerrorref: </xsl:text>
    <xsl:value-of select="$ref"/>
    <xsl:text>; </xsl:text>
    <xsl:value-of select="$class"/>
    <xsl:text>; </xsl:text>
    <xsl:value-of select="@spec"/>
    <xsl:text>; </xsl:text>
    <xsl:value-of select="$error"/>
  </xsl:message>
  -->

    <xsl:choose>
      <xsl:when test="not($error)">
        <xsl:message>
          <xsl:text>Warning: Cannot resolve </xsl:text>
          <xsl:copy-of select="."/>
          <xsl:text> at id=</xsl:text>
          <xsl:value-of select="(ancestor::*/@id)[last()]"/>
        </xsl:message>
        <xsl:text>[ERROR </xsl:text>
        <xsl:value-of select="concat(@class,@code)"/>
        <xsl:text> IN </xsl:text>
        <xsl:value-of select="$spec"/>
        <xsl:text>]</xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="node()">
        <xsl:apply-templates/>
        <sup>
          <small>
            <xsl:value-of select="$spec"/>
          </small>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$error">
          <xsl:with-param name="uri" select="$uri"/>
        </xsl:apply-templates>
        <sup>
          <small>
            <xsl:value-of select="$spec"/>
          </small>
        </sup>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- nt: production non-terminal -->
  <!-- make a link to the non-terminal's definition -->
  <xsl:template match="nt">
    <xsl:variable name="target" select="key('ids', @def)"/>
    <xsl:if test="not($target)">
      <xsl:message>broken reference: no @id matches nt/@def="<xsl:value-of select="@def"/>"</xsl:message>
    </xsl:if>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>


  <!-- ====================================================================== -->

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
        <xsl:if test="@role">
          <xsl:attribute name="class">
            <xsl:value-of select="@role"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="not(node()) and $xsl-query//bibl[@id=$id]">
            <xsl:apply-templates select="$xsl-query//bibl[@id=$id]/node()"/>
          </xsl:when>
          <xsl:when test="not(node()) and $tr//bibl[@id=$id]">
            <!--* <xsl:apply-templates select="$tr//bibl[@id=$id]/node()"/> *-->
            <!--* <xsl:apply-templates select="$tr//bibl[@id=$id][not(preceding-sibling::bibl[@id=$id])]/node()"/> *-->
            <xsl:apply-templates select="($tr//bibl[@id=$id])[1]/node()"/>
          </xsl:when>
          <xsl:when test="not(node()) and $rfc//bibl[@id=$id]">
            <xsl:apply-templates select="$rfc//bibl[@id=$id]/node()"/>
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

  <!-- ====================================================================== -->
  <!-- Extracted out of xmlspec.xsl so that it can go back to being the base
     stylesheet! -->

  <xsl:template match="loc">
    <xsl:if test="starts-with(@href, '#')">
      <xsl:if test="@role and @role != 'force'">
        <xsl:if test="not(key('ids', substring-after(@href, '#')))">
          <xsl:message terminate="yes">
            <xsl:text>Internal loc href to </xsl:text>
            <xsl:value-of select="@href"/>
            <xsl:text>, but that ID does not exist in this document.</xsl:text>
          </xsl:message>
        </xsl:if>
      </xsl:if>
    </xsl:if>
    <!-- ==================================================================== -->
    <!-- JM/2014-09-06 - Added support for optional id attribute              -->
    <xsl:choose>
      <xsl:when test="@id">
        <a id="{@id}" href="{@href}">
          <xsl:choose>
            <xsl:when test="count(child::node())=0">
              <xsl:value-of select="@href"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a href="{@href}">
          <xsl:choose>
            <xsl:when test="count(child::node())=0">
              <xsl:value-of select="@href"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->

  <xsl:template match="author/loc" priority="100">
    <xsl:text>, via </xsl:text>
    <a href="{@href}">
      <xsl:value-of select="@href"/>
    </a>
  </xsl:template>

  <!-- notes: a series of notes about the spec -->
  <!-- note is defined in xmlspec -->
  <xsl:template match="notes">
    <div class="note">
      <p class="prefix">
        <b>Notes:</b>
      </p>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ====================================================================== -->

  <xsl:template match="issue/head">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="issue">
    <div class="issue">
      <p class="title">
        <xsl:if test="@id">
          <a name="{@id}" id="{@id}"/>
        </xsl:if>
        <b>
          <xsl:text>Issue: </xsl:text>
          <xsl:value-of select="@id"/>
        </b>
        <xsl:text>, priority: </xsl:text>
        <xsl:value-of select="@priority"/>
        <xsl:text>, status: </xsl:text>
        <xsl:value-of select="@status"/>
      </p>

      <xsl:apply-templates/>

      <xsl:if test="not(resolution)">
        <p class="prefix">
          <b>
            <xsl:text>Resolution:</xsl:text>
          </b>
        </p>
        <p>None recorded.</p>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="processing-instruction('issues-toc')">
    <table summary="Issues TOC">
      <thead>
        <tr>
          <th class="issue-toc-head" align="left">Issue</th>
          <th class="issue-toc-head" align="left">Priority</th>
          <th class="issue-toc-head" align="left">Status</th>
          <th class="issue-toc-head" align="left">ID</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="following::issue[@status != 'closed']">
          <tr>
            <td>
              <xsl:value-of select="count(preceding::issue[@status != 'closed'])+1"/>
              <xsl:text>: </xsl:text>
              <xsl:value-of select="head"/>
              <xsl:text> (</xsl:text>
              <a href="#{@id}">
                <xsl:value-of select="@id"/>
              </a>
              <xsl:text>)</xsl:text>
            </td>
            <td>
              <xsl:value-of select="@priority"/>
            </td>
            <td>
              <xsl:value-of select="@status"/>
            </td>
            <td>
              <xsl:value-of select="@id"/>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- ====================================================================== -->

  <xsl:template match="div1|div2|div3|div4|div5|inform-div1">
    <xsl:if test="not(@id)">
      <xsl:message>
        <xsl:text>Warning: </xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text> has no id: </xsl:text>
        <xsl:value-of select="head"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-imports/>
  </xsl:template>

  <!-- ====================================================================== -->

  <!-- Stylesheet for @diff markup in XMLspec -->
  <!-- Author: Norman Walsh (Norman.Walsh@East.Sun.COM) -->
  <!-- Date Created: 2000.07.21 -->

  <!-- Modified by MHK to do differencing since a baseline. The @diff value
     is compared to the $baseline parameter using XPath rules (we use string
     comparison, available only in XPath 2.0) -->

  <!-- This stylesheet is copyright (c) 2000 by its authors.  Free
     distribution and modification is permitted, including adding to
     the list of authors and copyright holders, as long as this
     copyright notice is maintained. -->

  <!-- This stylesheet attempts to implement the XML Specification V2.1
     DTD.  Documents conforming to earlier DTDs may not be correctly
     transformed.

     This stylesheet supports the use of change-markup with the @diff
     attribute. If you use @diff, you should always use this stylesheet.
     If you want to turn off the highlighting of differences, use this
     stylesheet, but set show.diff.markup to 0.

     Using the original xmlspec stylesheet with @diff markup will cause
     @diff=del text to be presented.
-->

  <!-- ChangeLog:

     15 July 2008: Michael Kay
       - modified to handle the diff markup generated by the stylesheet that
         applies errata to create a 2nd edition spec from a 1st edition spec
       - applies highlighting to entries in the table of contents
       - some other enhancements such as handling of list items and table cells
       - no longer imports xslt.xsl. It is now generic across all the specs;
         it should be INCLUDED by a stylesheet that also IMPORTS the spec-specific
         stylesheet

     17 Sep 2002: Michael Kay
       - parameterized the colors
       - added extra CSS styles for XSLT
     16 Sep 2002: Michael Kay
       - modified to ignore diff markup if the @at attribute
         is before the baseline given as a parameter. Requires
		 XSLT 2.0 to do string comparison.
     25 Sep 2000: (Norman.Walsh@East.Sun.COM)
       - Use inline diff markup (as opposed to block) for name and
         affiliation
       - Handle @diff='del' correctly in bibl and other list-contexts.
     14 Aug 2000: (Norman.Walsh@East.Sun.COM)
       - Support additional.title param
     27 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Fix HTML markup problem with diff'd authors in authlist
     26 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Update pointer to latest xmlspec-stylesheet.
     21 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Initial version
-->

  <!-- ==================================================================== -->

  <!--
    The following template is a copy of the match="spec" template in
    xmlspec.xsl, with an extra chunk inserted.

    In a better design, xmlspec.xsl would have a "hook" in its template
    (at the point corresponding to where we insert the extra chunk).
    The hook would call a template (named, say, "top-of-body").
    In xmlspec.xsl, there would be a no-op template of that name,
    but this stylesheet would override that with a template
    consisting of just the inserted chunk.

    But we can't edit xmlspec.xsl.
  -->

  <!-- spec: the specification itself -->
  <xsl:template match="spec">
    <html>
      <xsl:if test="header/langusage/language">
        <xsl:attribute name="lang">
          <xsl:value-of select="header/langusage/language/@id"/>
        </xsl:attribute>
      </xsl:if>
      <head>
        <title>
          <xsl:apply-templates select="header/title"/>
          <xsl:if test="header/version">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="header/version"/>
          </xsl:if>
          <xsl:if test="$additional.title != ''">
            <xsl:text> -- </xsl:text>
            <xsl:value-of select="$additional.title"/>
          </xsl:if>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <xsl:if test="$show.diff.markup != 0">
          <div>
            <p>The presentation of this document has been augmented to
            identify changes from a previous version. Three kinds of changes
            are highlighted: <span class="diff-add">new, added text</span>,
              <span class="diff-chg">changed text</span>, and
              <span class="diff-del">deleted text</span>.</p>
            <xsl:if test="exists($diff.baseline.date)">
              <p>The baseline for changes is the publication dated
                <xsl:value-of select="format-date(xs:date($diff.baseline.date), '[D] [MNn] [Y]')"/>.</p>
            </xsl:if>
            <hr/>
          </div>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="//footnote[not(ancestor::table)]">
          <hr/>
          <div class="endnotes">
            <xsl:text>&#xA;</xsl:text>
            <h3>
              <xsl:call-template name="anchor">
                <xsl:with-param name="conditional" select="0"/>
                <xsl:with-param name="default.id" select="'endnotes'"/>
              </xsl:call-template>
              <xsl:text>End Notes</xsl:text>
            </h3>
            <dl>
              <xsl:apply-templates select="//footnote[not(ancestor::table)]" mode="notes"/>
            </dl>
          </div>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <!-- ==================================================================== -->

  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <xsl:template match="*[my:diff-markup-effect(.) eq 'delete']" priority="2"/>

  <xsl:template match="*[my:diff-markup-effect(.) eq 'delete']" mode="text" priority="2"/>

  <xsl:template match="*[my:diff-markup-effect(.) eq 'delete']" mode="toc" priority="2"/>

  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <xsl:template match="*[my:diff-markup-effect(.) eq 'highlight']" priority="3">
    <!--
    <xsl:message><xsl:value-of select="'diff=', @diff, 'at=', @at, '$diff.baseline=', $diff.baseline"/></xsl:message>
    -->
    <xsl:call-template name="diff-markup">
      <xsl:with-param name="diff" select="string(@diff)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="diff-markup">
    <xsl:param name="diff">off</xsl:param>
    <!-- Taken from F&O 3.0 and Serialization 3.0 -->
    <xsl:param name="in-errorref" select="false()" tunnel="yes"/>
    <xsl:choose>

      <!--
        In this <xsl:choose>, most of the alternatives involve
        wrapping a <span> or <div> element around <xsl:next-match/>.
        However, in some cases, that would (and did) produce invalid HTML
        (e.g., when next-match generates dd, li, td, or tr).
        This alternative addresses those cases.

        The approach here is to save the result of
        <xsl-next-match/> and make a tweaked copy of it,
        without introducing a <span> or <div>.
      -->
      <xsl:when test="
        self::publoc | self::latestloc | self::prevlocs |
        self::authlist | self::author |
        self::item |
        self::bibl |
        self::gitem | self::label | self::def |
        self::tr | self::th | self::td
      ">
        <xsl:variable name="diffclass" select="concat('diff-', $diff)"/>

        <xsl:variable name="original" select="."/>

        <xsl:variable name="trans" as="node()*">
          <xsl:next-match/>
        </xsl:variable>

        <xsl:for-each select="$trans">
          <xsl:choose>

            <xsl:when test="
                self::dt
                and
                local-name($original)=('publoc','latestloc','prevlocs','authlist')
            ">
              <!--
                This is just fixed text
                ("This version", "Latest version", "Previous versions", "Editors"),
                so it presumably hasn't changed, so don't highlight it.
              -->
              <xsl:copy-of select="."/>
            </xsl:when>

            <xsl:when test="self::dt | self::dd | self::li | self::th | self::td">
              <xsl:copy>
                <xsl:call-template name="ensure-class-name">
                  <xsl:with-param name="class-name" select="$diffclass"/>
                </xsl:call-template>
                <xsl:copy-of select="@*[name(.) != 'class'] | node()"/>
                <xsl:if test="not(self::dt)">
                  <xsl:apply-templates select="$original/@at"/>
                </xsl:if>
                <!-- (Putting the @at-thing in a <dt> doesn't look right.) -->
              </xsl:copy>
            </xsl:when>

            <xsl:when test="self::tr">
              <xsl:copy>
                <xsl:call-template name="ensure-class-name">
                  <xsl:with-param name="class-name" select="$diffclass"/>
                </xsl:call-template>
                <!-- Put the at-thing in the tr's last td -->
                <xsl:for-each select="@*[name(.) != 'class'] | node()">
                  <xsl:choose>
                    <xsl:when test=". is ../td[last()]">
                      <xsl:copy>
                        <xsl:copy-of select="@* | node()"/>
                        <xsl:apply-templates select="$original/@at"/>
                      </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:copy-of select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:copy>
            </xsl:when>

            <xsl:otherwise>
              <xsl:message>WARNING: diff-markup: don't know how to handle <xsl:value-of select="local-name(.)"/></xsl:message>
            </xsl:otherwise>

          </xsl:choose>
        </xsl:for-each>
      </xsl:when>

      <!-- simpler cases ... -->

      <!-- Taken from F&O 3.0 and Serialization 3.0 -->
      <xsl:when test="self::error and $in-errorref">
        <xsl:next-match/>
      </xsl:when>

      <xsl:when test="ancestor-or-self::phrase">
        <span class="diff-{$diff}">
          <xsl:next-match/>
          <xsl:apply-templates select="@at"/>
        </span>
      </xsl:when>

      <xsl:when test="ancestor::p and not(self::p)">
        <span class="diff-{$diff}">
          <xsl:next-match/>
          <xsl:apply-templates select="@at"/>
        </span>
      </xsl:when>

      <xsl:when test="ancestor-or-self::affiliation">
        <span class="diff-{$diff}">
          <xsl:next-match/>
        </span>
      </xsl:when>

      <xsl:when test="ancestor-or-self::name">
        <span class="diff-{$diff}">
          <xsl:next-match/>
        </span>
      </xsl:when>

      <xsl:when test="ancestor-or-self::header">
        <div class="diff-{$diff}">
          <xsl:next-match/>
          <xsl:apply-templates select="@at">
            <xsl:with-param name="put-in-p" select="true()"/>
          </xsl:apply-templates>
        </div>
      </xsl:when>

      <xsl:otherwise>
        <div class="diff-{$diff}">
          <xsl:next-match/>
          <xsl:apply-templates select="@at">
            <xsl:with-param name="put-in-p" select="true()"/>
          </xsl:apply-templates>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ensure-class-name">
    <xsl:param name="class-name" required="yes"/>
    <!--
      Create a 'class' attribute
      that copies the 'class' attribute (if any) of the current node,
      and adds $class-name if it's not already there.
    -->
    <xsl:attribute name='class'>
      <xsl:choose>

        <xsl:when test="not(@class)">
          <!-- Current node doesn't have a class attr. -->
          <xsl:value-of select="$class-name"/>
        </xsl:when>

        <xsl:otherwise>
          <!-- Node already has a class attr. -->
          <!-- Check whether its value already contains $class-name. -->
          <xsl:choose>
            <xsl:when test="tokenize(@class, '\s+') = $class-name">
              <!-- It does, so just copy the current value. -->
              <xsl:value-of select="@class"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- It doesn't, so add $class-name to the current value. -->
              <xsl:value-of select="concat($class-name, ' ', @class)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@at">
    <xsl:param name="put-in-p" select="false()"/>
    <xsl:variable name="atval" select="string(.)"/>
    <xsl:if test="matches($atval, 'E[0-9]+')">
      <xsl:variable name="content" select="concat(' [', $atval, ']')"/>
      <xsl:choose>
        <xsl:when test="$put-in-p">
          <p align="right">
            <xsl:value-of select="$content"/>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <!-- highlight leaf entries in the table of contents for sections containing a change -->
  <xsl:template match="
      *
        [$show.diff.markup != 0]
        [descendant-or-self::*
          [
            my:diff-markup-effect(.) eq 'highlight'
            and
            (
              ancestor-or-self::*
                [contains(name(), 'div')]
                [number(substring-after(name(), 'div')) le $toc.level]
                [1]
              is
              current()
            )
          ]
        ]"
      mode="toc">
    <!--<div class="diff-chg">-->
    <xsl:apply-imports>
      <xsl:with-param name="toc-change" select="true()" tunnel="yes"/>
    </xsl:apply-imports>
    <!--</div>-->
  </xsl:template>

  <xsl:template match="*" mode="toc">
    <xsl:apply-imports>
      <xsl:with-param name="toc-change" select="false()" tunnel="yes"/>
    </xsl:apply-imports>
  </xsl:template>

  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <!-- Highlight the headings of changed sections in the TOC -->
  <xsl:template match="head" mode="text">
    <xsl:param name="toc-change" tunnel="yes" select="false()"/>
    <xsl:choose>
      <xsl:when test="$toc-change">
        <span class="diff-chg">
          <xsl:apply-templates mode="toc"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
          <xsl:apply-templates mode="toc"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Taken from F&O 3.0 and Serialization 3.0 -->
  <!-- Avoid change-marking an error just because the errorref is diffed -->
  <xsl:template match="errorref" priority="10">
    <xsl:next-match>
      <xsl:with-param name="in-errorref" select="true()" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template>


<!-- 2014-01-31: Jim added these templates, including overrides of templates in xmlspec.xsl -->

  <!-- prevlocs: previous locations for this spec -->
  <!-- called in a <dl> context from header -->
  <xsl:template match="prevlocs">
    <dt>
      <xsl:text>Previous version</xsl:text>
      <xsl:if test="count(loc) &gt; 1"><xsl:text>s</xsl:text></xsl:if>
      <xsl:if test="@doc">
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@doc"/>
      </xsl:if>
      <xsl:text>:</xsl:text>
    </dt>
    <dd>
      <xsl:for-each select="loc">
        <xsl:apply-templates select="."/>
        <xsl:if test="position() &lt; last()">
          <br />
        </xsl:if>
      </xsl:for-each>
<!--
      <xsl:apply-templates/>
-->
    </dd>
  </xsl:template>

  <!-- latestloc: latest location for this spec -->
  <!-- called in a <dl> context from header -->
  <xsl:template match="latestloc">
    <dt>
      <xsl:text>Latest version</xsl:text>
      <xsl:if test="@doc">
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@doc"/>
      </xsl:if>
      <xsl:text>:</xsl:text>
    </dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>


  <!-- latestloc-major and -tech: latest location for this major version and this technology -->
  <!-- called in a <dl> context from header -->
  <xsl:template match="latestloc-major | latestloc-tech">
    <dt>
      <xsl:text>Most recent version</xsl:text>
      <xsl:if test="@doc">
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@doc"/>
      </xsl:if>
      <xsl:text>:</xsl:text>
    </dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>


  <!-- prevrec: previous Recommendation for this technology -->
  <!-- called in a <dl> context from header -->
  <xsl:template match="prevrec">
    <dt>
      <xsl:text>Most recent Recommendation of </xsl:text>
      <xsl:value-of select="@doc"/>
      <xsl:text>:</xsl:text>
    </dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>



  <!-- ================================================================= -->

  <xsl:function name="my:diff-markup-effect" as="xs:string">
    <xsl:param name="el" as="element()?"/>
    <!--
      Given element $el,
      looking at its 'diff' and 'at' attributes (if any),
      and knowing the globals $show.diff.markup and $diff.baseline,
      return a string that indicates what should be done with the element:
      'normal'        : transform as if diff markup didn't exist.
      'delete'        : transform to nothing.
      'diff-highlight': transform with modifications that will highlight changes.
    -->
    <xsl:choose>

      <xsl:when test="empty($el)">
        <!--
          The caller looked for an ancestor or descendant with @diff,
          and didn't find one.
        -->
        <xsl:sequence select="'normal'"/>
      </xsl:when>

      <xsl:when test="$show.diff.markup = 0">
        <!--
          'Execute' all diff markup (regardless of @at).
          (Suppress deleted content, and let everything else through.)
        -->
        <xsl:choose>
          <xsl:when test="$el/@diff = 'del'">
            <xsl:sequence select="'delete'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="'normal'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!--
          In the document being generated, highlight diffs.
          For diffs marked with @at,
          highlight those that occur "after" $diff.baseline,
          and execute the others.
        -->
        <xsl:choose>

          <xsl:when test="empty($el/@diff)">
            <!-- This node does not have diff markup. -->
            <xsl:sequence select="'normal'"/>
          </xsl:when>

          <xsl:when test="
              $el/@at
              and
              string($el/@at) le $diff.baseline
          ">
            <!--
              This node has diff markup,
              but that markup occurred "before" the baseline,
              so execute it.
            -->
            <xsl:choose>
              <xsl:when test="$el/@diff = 'del'">
                <xsl:sequence select="'delete'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="'normal'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <!--
              This node has diff markup
              that occurred "after" the baseline,
              so highlight it.
            -->
            <xsl:sequence select="'highlight'"/>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
 

</xsl:stylesheet>
