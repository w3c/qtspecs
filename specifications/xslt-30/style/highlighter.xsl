<?xml version="1.0" encoding="utf-8"?>

<!-- Adapted variant of highlight-inline.xsl from the xmlspectrum distribution 
     Michael Kay, Saxonica, November 2016
-->

<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT, XQuery and XSD 1.1 file formats

Description:

Transforms the source XHTML file by converting <pre> elements text contents
to span child elements containing class attributes for color styles. Also
inserts a link to a generated CSS file output as a xsl:result-document. 

Note that this interface stylesheet is a simple wrapper for xmlspectrum.xsl.

Dependencies:

1. xmlspectrum.xsl

Usage:

initial-template: (not used)
source-xml: (not used)
xsl parameters:
    sourcepath:  (path or URI for source file)
    color-theme: (name of color theme: default is 'solarized-dark')
    css-path:    (path for output CSS)

Sample transform using Saxon-HE/Java on command-line (unbroken line):

java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/blog-sample.html -o:output/blog-sample.html

The pre element must have a 'lang' attribute to indicate the code language, for xml-hosted languages, 3
further attributes can be used:

 data-prefix: the prefix assigned to the namespace used by the language
 data-indent: number of space chars applied for each xml nesting level
              (-1 prevents any changes to existing indentation on attributes)
 data-trim: (yes|no) whether to trim leading whitespace from xml elements
            - normally required when data-indent is used


-->

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:loc="com.qutoric.sketchpath.functions"
  xmlns:css="css-defs.com" exclude-result-prefixes="loc f xs css qf xh"
  xmlns:qf="urn:xq.internal-function" xmlns:f="internal">

  <xsl:import href="../../../lib/xmlspectrum/xsl/xmlspectrum.xsl"/>

  <xsl:output method="xml" indent="no"/>

  <xsl:param name="color-theme" select="'light'" as="xs:string"/>
  <xsl:param name="indent" select="'-1'" as="xs:string"/>
  <xsl:param name="auto-trim" select="'no'" as="xs:string"/>
  <xsl:param name="font-name" select="'std'"/>

  <xsl:variable name="indent-size" select="xs:integer($indent)" as="xs:integer"/>
  <xsl:variable name="do-trim" select="$auto-trim eq 'yes'"/>

  

  <xsl:template match="style[@type='text/css']">
    <xsl:copy>
      <xsl:copy-of select="@*, node()"/>
      <!-- Use xmlspectrum color scheme "pg-light", with slight adjustments:
           - delete background-color (picks this up from the standard xmlspec scheme)
           - make the grey used for attribute values and comments a little darker
             (to stand out on a light-grey background)
      -->
      <xsl:text>
        
       /*======================================================
        From highlighter.xsl - xmlspectrum syntax highlighting
        ======================================================*/     
       
/*body {
    margin:0;
}*/
span.atn[data-change=add] {
    background-color: #dbffdb;
}
span.atn[data-change=delete] {
    background-color: #ffdbdb;
}
span.atn[data-change=change] {
    background-color: #dbdbff;
}
p.spectrum, pre.spectrum {

    margin:0px;
    font-family:Monaco, Consolas, 'Andale Mono', 'DejaVu Sans Mono', monospace;
    
    white-space: pre-wrap;
    display: block;
    border: none thin;
    border-color: #405075;
    /*background-color:#FFFFFF;*/
    padding: 2px 2px 2px 5px;
    margin-bottom:5px;

}

div.spectrum-toc {

    font-family:Monaco, Consolas, 'Andale Mono', 'DejaVu Sans Mono', monospace;
    
    display: block;
    border: none thin;
    border-color: #405075;
    /*background-color:#FFFFFF;*/
    padding: 2px;

}

ul.base1, ul.spectrum-toc {
color:#1049a9;
  }

  ul.spectrum-toc > li {
  border-width:1px;
  border-top-style: solid;
  padding-bottom: 8px;
  }
  ul.spectrum-toc li {
  list-style: none;
  }
  ul.spectrum-toc span.blue {
  display:block;
  margin: 8px 0px 8px 0px;
  }
  ul.t-and-f {

  border-color: blue;
  float: left;
  }
  ul.v-and-p {

  border-color: red;
  float: left;
  }

  .spectrum span {
  white-space: pre-wrap;
  }

  span.ww
 {/*background-color: #FFFFFF; */}
 span.base01, span.eq-equ, span.z, span.sc, span.scx, span.ec, span.es, span.ez, span.atneq
 {color: #006C51; }
 span.base03, span.ww:not(:hover), span.txt:not(:hover), span.cm:not(:hover), span.pi:not(:hover)
 {/*background-color: #FFFFFF; */}
 span.base0, span.txt, span.cd
 {color: #00685A; }
 span.base1, span.literal
 {color: #1049a9; }
 span.yellow, span.op, span.type-op, span.if, span.higher, span.step, span.whitespace, span.quantifier, span.parenthesis
 {color: #534ed9; }
 span.orange
 {color: #EC0033; }
 span.function
 {color: #80001c; }
 span.red, span.tcall
 {color: #a66b00; }
 span.magenta, span.vname, span.pname, span.fname, span.tname, span.variable, span.external
 {color: #7608aa; }
 span.violet, span.qname, span.type-name, span.unclosed, span.en, span.cl, span.href
 {color: #4c036e; }
 span.blue, span.enxsl, span.clxsl, span.enx, span.filter, span.node, span.node-type
 {color: #052c6e; }
 span.cyan, span.atn, span.numeric, span.pi, span.dt, span.axis, span.context, span.bracedq, span.property
 {color: #0a57db; }
 span.av, span.type
 {color: #920031; }
 span.green, span.cm, span.comment
 {color: #264d00; }


a.solar {
    text-decoration:none;
}

      </xsl:text> 
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="pre[exists(@lang) and not(@lang = ('xpath', 'xquery'))]">
    <xsl:variable name="is-xsl" select="f:is-xslt(.)" as="xs:boolean"/>
    <xsl:variable name="prefix" select="(@data-prefix, '')[1]" as="xs:string"/>
    <xsl:variable name="context-indent"
      select="
        if (exists(@data-indent))
        then
          xs:integer(@data-indent)
        else
          $indent-size"/>

    <xsl:copy>
      <xsl:attribute name="class" select="'spectrum'"/>
      <xsl:apply-templates select="@* except @class"/>
      <xsl:variable name="real-trim" as="xs:boolean"
        select="
          if (exists(@data-trim))
          then
            @data-trim = 'yes'
          else
            $do-trim"/>
      <xsl:choose>
        <xsl:when test="$real-trim or $context-indent gt 0">
          <xsl:variable name="renderedXML" select="f:render(., @lang, $prefix)" as="element()*"/>
          <xsl:sequence select="f:indent($renderedXML, $context-indent, $real-trim)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="f:render(., @lang, $prefix)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="div[@class eq 'exampleInner']/pre[starts-with(normalize-space(), '&lt;')]" priority="2">
    <xsl:variable name="is-xsl" select="f:is-xslt(.)" as="xs:boolean"/>
    <xsl:variable name="prefix" select="'xsl'" as="xs:string"/>
    <xsl:variable name="context-indent"
      select="
        if (exists(@data-indent))
        then
          xs:integer(@data-indent)
        else
          $indent-size"/>

    <xsl:copy>
      <xsl:attribute name="class" select="'spectrum'"/>
      <xsl:apply-templates select="@* except @class"/>
      <xsl:variable name="real-trim" as="xs:boolean"
        select="
          if (exists(@data-trim))
          then
            @data-trim = 'yes'
          else
            $do-trim"/>
      <xsl:choose>
        <xsl:when test="$real-trim or $context-indent gt 0">
          <xsl:variable name="renderedXML" select="f:no-namespace(f:render(., 'xslt', $prefix))" as="element()*"/>
          <xsl:sequence select="f:indent($renderedXML, $context-indent, $real-trim)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="f:no-namespace(f:render(., 'xslt', $prefix))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- XPath, XQuery, and JSP snippets -->
  <xsl:template match="pre[@lang = ('xpath', 'xquery') or contains(., '&lt;jsp:')]" priority="3">
    <xsl:copy>
      <xsl:attribute name="class" select="'spectrum'"/>
      <xsl:apply-templates select="@* except @class"/>
      <xsl:sequence select="qf:show-xquery(.)"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- BNF snippets: don't attempt highlighting -->
  <xsl:template match="pre[contains(., '::=')]" priority="4">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template name="create-css">

    <xsl:result-document href="theme.css" method="text" indent="no">
      <xsl:sequence select="f:get-css()"/>
    </xsl:result-document>

  </xsl:template>
  
  <xsl:function name="f:is-xslt" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:sequence select="$element/@lang = 'xslt' or contains($element, '&lt;xsl:')"/>
  </xsl:function>
  
  <!-- xmlspectrum puts generated code in the XHTML namespace, we want it in no namespace -->
  
  <xsl:function name="f:no-namespace" as="node()*">
    <xsl:param name="in" as="node()*"/>
    <xsl:apply-templates select="$in" mode="no-namespace"/>
  </xsl:function>
  
  <xsl:template match="node()" mode="no-namespace">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="no-namespace"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xh:*" mode="no-namespace">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="no-namespace"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
