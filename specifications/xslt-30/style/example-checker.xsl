<?xml version="1.0" encoding="utf-8"?>

<!-- 
    This stylesheet can be used to perform syntax checking of the examples in the XSLT specification.
    It relies on examples appearing in <eg> elements with a @role attribute indicating the language
    to be checked:
    
    xml - XML document
    xslt-document - complete XSLT stylesheet module
    xslt-declaration - an xslt top-level declaration
    xslt-declarations - a sequence of xslt top-level declarations
    xslt-instruction - an XSLT instruction
    xpath - an XPath expression
    json - a JSON document
    
    Some of these are validated by adding an xsl:stylesheet wrapper, and there is also provision to add namespace declarations
    to this wrapper.
    
    The stylesheet should be run against build/xslt-expanded1.xml (it can also be run against src/xslt.xml, but this will not
    catch example pulled in from the function catalog).
    
    The stylesheet is not run as part of the standard build process. The results need manual checking: there are spurious
    errors caused by references to resources (packages, stylesheets, and source documents) that cannot be resolved.
    
    The stylesheet uses XSLT 3.0 and uses Saxon extensions (so it needs a commercial version of Saxon).
-->


<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="#all" 
  expand-text="yes"
  xmlns:f="internal">
  
   <xsl:template match="/">
     <xsl:variable name="result" as="element()*">
      <xsl:apply-templates select="//eg"/>
     </xsl:variable>
     <errors>
       <xsl:copy-of select="$result[self::error]"/>
     </errors>
   </xsl:template>

   <xsl:template match="eg[@role='xml']">
     <xsl:call-template name="log"/>
     <xsl:try>
       <ok><xsl:sequence select="parse-xml(.)"/></ok>
       <xsl:catch>
         <error code="$err:code"><xsl:copy-of select="."/></error>
       </xsl:catch>
     </xsl:try>
   </xsl:template>
  
  <xsl:template match="eg[@role='xpath']">
    <xsl:call-template name="log"/>
    <xsl:try>
      <ok><xsl:evaluate xpath="."/></ok>
      <xsl:catch>
        <error><xsl:copy-of select="."/></error>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  <xsl:template match="eg[@role='xslt-document']">
    <xsl:call-template name="log"/>
    <xsl:try>
      <ok><xsl:sequence select="f:compile-stylesheet(.)"/></ok>
      <xsl:catch>
        <error><xsl:copy-of select="."/></error>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  <xsl:template match="eg[starts-with(@role,'xslt-declaration')]">
    <xsl:call-template name="log"/>
    <xsl:variable name="wrapped">
      <xsl:text><![CDATA[<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" ]]></xsl:text>
      <xsl:value-of select="substring-after(@role, ' ')"/>
      <xsl:text>></xsl:text>
      <xsl:value-of select="."/>
      <xsl:text><![CDATA[</xsl:stylesheet>]]></xsl:text>
    </xsl:variable>
    <xsl:try>
      <ok><xsl:sequence select="f:compile-stylesheet(.)"/></ok>
      <xsl:catch>
        <error><xsl:copy-of select="f:compile-stylesheet(.)"/></error>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  <xsl:template match="eg[starts-with(@role,'xslt-instruction')]">
    <xsl:call-template name="log"/>
    <xsl:variable name="wrapped">
      <xsl:text><![CDATA[<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" ]]></xsl:text>
      <xsl:value-of select="substring-after(@role, ' ')"/>
      <xsl:text><![CDATA[><xsl:variable name="v">]]></xsl:text>
      <xsl:value-of select="."/>
      <xsl:text><![CDATA[</xsl:variable></xsl:stylesheet>]]></xsl:text>
    </xsl:variable>
    <xsl:try>
      <ok><xsl:sequence select="f:compile-stylesheet(.)"/></ok>
      <xsl:catch>
        <error><xsl:copy-of select="f:compile-stylesheet(.)"/></error>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  <xsl:template match="eg[@role='jsp']"/>
  
  <xsl:template match="eg[@role='json']">
    <xsl:call-template name="log"/>
    <xsl:try>
      <ok><xsl:sequence select="json-to-xml(.)"/></ok>
      <xsl:catch>
        <error><xsl:copy-of select="."/></error>
      </xsl:catch>
    </xsl:try>
    
  </xsl:template>
  
  <xsl:template match="eg">
    <xsl:call-template name="log"/>
    <error><xsl:copy-of select="."/></error>
  </xsl:template>
  
  <xsl:function name="f:compile-stylesheet">
    <xsl:param name="input"/>
    <xsl:try>
      <xsl:variable name='c' select="saxon:compile-stylesheet(parse-xml($input))"/>
      <xsl:sequence select="string($c) eq 'improbable'"/>
      <xsl:catch>
        <error><xsl:value-of select="$input"/></error>
      </xsl:catch>
    </xsl:try>
  </xsl:function>
  
  <xsl:template name="log">
    <xsl:message>Processing {path(.)}</xsl:message>
  </xsl:template>

</xsl:stylesheet>
