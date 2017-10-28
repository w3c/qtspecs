<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:set="http://exslt.org/sets"
                exclude-result-prefixes="exsl set"
                version="2.0">
  
<!-- 2012-06-18 MHK: made this a 2.0 stylesheet, but should still run with 1.0+EXSLT if
     the 1.0 processor implements forwards compatible mode correctly -->  

<xsl:output method="xml" encoding="utf-8"/>

<xsl:param name="verbose" select="0"/>

<!-- 2009-11-25, Jim: Added param to receive the doc build datetime -->
<xsl:param name="currentDateTime" select="'(not provided)'"/>

<!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
<xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{xml-fix} </xsl:text>
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
<!-- 2009-11-25, Jim: Added comment to capture datetime when document was built -->
    <xsl:comment>This document was created at <xsl:value-of select="$currentDateTime"/></xsl:comment>

  <xsl:variable name="unwrapped">
    <xsl:apply-templates mode="unwrap.p"/>
  </xsl:variable>

  <xsl:variable name="noempty">
    <xsl:apply-templates select="exsl:node-set($unwrapped)/*" mode="remove.empty.div"/>
  </xsl:variable>

  <xsl:apply-templates select="exsl:node-set($noempty)/*" mode="make.xhtml"/>
</xsl:template>

<!-- This module contains templates that match against HTML nodes. It is used
     to post-process result tree fragments for some sorts of cleanup.
     These templates can only ever be fired by a processor that supports
     exslt:node-set(). -->

<!-- ==================================================================== -->

<!-- unwrap.p mode templates remove blocks from HTML p elements (and
     other places where blocks aren't allowed) -->

<xsl:template name="unwrap.p">
  <xsl:param name="p"/>
  <xsl:choose>
    <xsl:when test="function-available('exsl:node-set')
                    and function-available('set:leading')
                    and function-available('set:trailing')">
      <xsl:apply-templates select="exsl:node-set($p)" mode="unwrap.p"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$p"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template xmlns:html="http://www.w3.org/1999/xhtml"
              match="html:p|p" mode="unwrap.p">
  <!-- xmlns:html is necessary for the xhtml stylesheet case -->
  <xsl:variable name="blocks" xmlns:html="http://www.w3.org/1999/xhtml"
                select="address|blockquote|div|hr|h1|h2|h3|h4|h5|h6
                        |layer|p|pre|table|dl|menu|ol|ul|form
                        |html:address|html:blockquote|html:div|html:hr
                        |html:h1|html:h2|html:h3|html:h4|html:h5|html:h6
                        |html:layer|html:p|html:pre|html:table|html:dl
                        |html:menu|html:ol|html:ul|html:form"/>
  <xsl:choose>
    <xsl:when test="$blocks">
      <xsl:if test="$verbose != 0">
	<xsl:message>Unwrapping <xsl:value-of select="name($blocks[1])"/></xsl:message>
      </xsl:if>
      <xsl:call-template name="unwrap.p.nodes">
        <xsl:with-param name="wrap" select="."/>
        <xsl:with-param name="first" select="1"/>
        <xsl:with-param name="nodes" select="node()"/>
        <xsl:with-param name="blocks" select="$blocks"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="unwrap.p"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="unwrap.p">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="unwrap.p"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="text()|processing-instruction()|comment()" mode="unwrap.p">
  <xsl:copy/>
</xsl:template>

<xsl:template name="unwrap.p.nodes">
  <xsl:param name="wrap" select="."/>
  <xsl:param name="first" select="0"/>
  <xsl:param name="nodes"/>
  <xsl:param name="blocks"/>
  <xsl:variable name="block" select="$blocks[1]"/>

  <!-- This template should never get called if these functions aren't available -->
  <!-- but this test is still necessary so that processors don't choke on the -->
  <!-- function calls if they don't support the set: functions -->
  <xsl:if test="function-available('set:leading')
                and function-available('set:trailing')">
    <xsl:choose>
      <xsl:when test="$blocks">
        <xsl:variable name="leading" select="set:leading($nodes,$block)"/>
        <xsl:variable name="trailing" select="set:trailing($nodes,$block)"/>

        <xsl:if test="($wrap/@id and $first = 1) or $leading">
          <xsl:element name="{local-name($wrap)}" namespace="{namespace-uri($wrap)}">
            <xsl:for-each select="$wrap/@*">
              <xsl:if test="$first != 0 or local-name(.) != 'id'">
                <xsl:copy/>
              </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="$leading" mode="unwrap.p"/>
          </xsl:element>
        </xsl:if>

        <xsl:apply-templates select="$block" mode="unwrap.p"/>

        <xsl:if test="$trailing">
          <xsl:call-template name="unwrap.p.nodes">
            <xsl:with-param name="wrap" select="$wrap"/>
            <xsl:with-param name="nodes" select="$trailing"/>
            <xsl:with-param name="blocks" select="$blocks[position() &gt; 1]"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:if test="($wrap/@id and $first = 1) or $nodes">
          <xsl:element name="{local-name($wrap)}" namespace="{namespace-uri($wrap)}">
            <xsl:for-each select="$wrap/@*">
              <xsl:if test="$first != 0 or local-name(.) != 'id'">
                <xsl:copy/>
              </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="$nodes" mode="unwrap.p"/>
          </xsl:element>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<!-- remove.empty.div mode templates remove empty blocks -->

<xsl:template name="remove.empty.div">
  <xsl:param name="div"/>
  <xsl:choose>
    <xsl:when test="function-available('exsl:node-set')">
      <xsl:apply-templates select="exsl:node-set($div)" mode="remove.empty.div"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$div"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template xmlns:html="http://www.w3.org/1999/xhtml"
              match="html:p|p|html:div|div" mode="remove.empty.div">
  <xsl:choose>
    <xsl:when test="not(*) and normalize-space(.) = ''">
      <xsl:if test="$verbose != 0">
	<xsl:message>Removing empty <xsl:value-of select="name(.)"/></xsl:message>
      </xsl:if>
    </xsl:when>
    <xsl:when test="node()">
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="remove.empty.div"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$verbose != 0">
	<xsl:message>Removing empty <xsl:value-of select="name(.)"/></xsl:message>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="remove.empty.div">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="remove.empty.div"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="text()|processing-instruction()|comment()" mode="remove.empty.div">
  <xsl:copy/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="make.xhtml">
  <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="make.xhtml"/>
  </xsl:element>
</xsl:template>

<xsl:template match="text()|processing-instruction()|comment()" mode="make.xhtml">
  <xsl:copy/>
</xsl:template>
  
<!-- XSLT 2.0 implementation of set:leading and set:trailing (ignored by a 1.0 processor) -->

<xsl:function name="set:leading" as="node()*">
   <xsl:param name="ns1" as="node()*"/>
   <xsl:param name="ns2" as="node()*"/>
   <xsl:sequence select="if (empty($ns2)) 
                         then $ns1
                         else $ns1[. &lt;&lt; $ns2[1]]"/>
</xsl:function>
  
  <xsl:function name="set:trailing" as="node()*">
    <xsl:param name="ns1" as="node()*"/>
    <xsl:param name="ns2" as="node()*"/>
    <xsl:sequence select="if (empty($ns2)) 
                          then $ns1 
                          else $ns1[. >> $ns2[1]]"/>
  </xsl:function>
  
  <xsl:function name="exsl:node-set" as="node()*">
    <xsl:param name="ns1" as="node()*"/>
    <xsl:sequence select="$ns1"/>
    
  </xsl:function>

</xsl:stylesheet>
