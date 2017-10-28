<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rddl="http://www.rddl.org/"
                xmlns:rddlx="http://www.rddl.org/natures#"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rddlp="http://www.rddl.org/purposes#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
 
 <xsl:output method="xml" indent="yes"/>

 <xsl:param name="doc">
  <!-- Make sure to give on command line if not using XSLT2 ! -->
  <xsl:choose>
   <xsl:when test="function-available('fn:base-uri')">
    <xsl:value-of select="fn:base-uri()"/>
    <xsl:message> fn:base-uri is available; its value is <xsl:value-of select="fn:base-uri()"/>. </xsl:message>
   </xsl:when>

   <xsl:otherwise>
    <xsl:message>No base URI known -- rerun with doc=... param or edit by hand
to fix the rdf:about="xyzzy" on line 3</xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:param>
 
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
  <rdf:RDF>
   <owl:Ontology rdf:about="">
    <owl:imports rdf:resource="link.rdf"/>
    <owl:imports rdf:resource="rddl.owl"/>
   </owl:Ontology>
   <owl:Ontology rdf:about="link.rdf"/>
   <owl:Ontology rdf:about="rddl.owl"/>
   <rdf:Description rdf:about="{$doc}">
    <rdf:type rdf:resource="http://www.w3.org/2007/ont/link#Document"/>
      <xsl:apply-templates select="//*[@class='resource']/rddl:resource"/>
   </rdf:Description>
   <xsl:apply-templates select="//*[@class='anchor']/rddl:resource"/>
  </rdf:RDF>
 </xsl:template>
 
 <xsl:template match="*[@class='anchor']/rddl:resource">
  <xsl:choose>
   <xsl:when test="contains(@xlink:role,'#dt-built-in')">
    <rdfs:Datatype rdf:ID="{../@id}">
      <xsl:attribute name="xml:base" select="$doc"/>
      <xsl:call-template name="rr"/>
    </rdfs:Datatype>
   </xsl:when>
   <xsl:otherwise>
    <rdf:Description rdf:ID="{../@id}">
      <xsl:attribute name="xml:base" select="$doc"/>
      <xsl:call-template name="rr"/>
    </rdf:Description>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template name="rr" match="*[@class='resource']/rddl:resource[@xlink:purpose]">
  <xsl:variable name="purpose" select="@xlink:arcrole"/>
  <xsl:variable name="nature" select="@xlink:role"/>
  <xsl:variable name="target" select="@xlink:href"/>
  <xsl:variable name="pfx" select="'rddlp:'"/>

  <xsl:variable name="pns">
   <xsl:choose>
    <xsl:when test="$purpose='http://www.w3.org/1999/XSL/Transform'">
     <xsl:value-of select="$purpose"/>
    </xsl:when>
    <xsl:when test="contains($purpose, 'http://www.rddl.org/purposes')">
     <xsl:value-of select="concat(substring-before($purpose,'#'),'#')"/>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pnm">
   <xsl:choose>
    <xsl:when test="$purpose='http://www.w3.org/1999/XSL/Transform'">
     <xsl:value-of select="'rddlp:xslt-transform'"/>
    </xsl:when>
    <xsl:when test="contains($purpose, 'http://www.rddl.org/purposes')">
     <xsl:value-of select="concat($pfx,substring-after($purpose,'#'))"/>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>
  <xsl:element name="{$pnm}" namespace="{$pns}">
   <rddlx:Object>
    <rddlx:natureKey>
     <rddlx:NatureKey rdf:about="{$nature}"/>
    </rddlx:natureKey>
    <rddlx:target rdf:resource="{$target}"/>
   </rddlx:Object>
  </xsl:element>
  <!-- Some anchored resources have nested descriptions -->

  <xsl:for-each select="rddl:resource">
   <xsl:call-template name="rr"/>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>