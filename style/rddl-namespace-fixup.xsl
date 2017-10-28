<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
>
<!--* A stylesheet that moves a non-namespaced 
    * document into the XHTML namespace.
    *-->

 <xsl:param name="foreign">keep</xsl:param>
 <!--* or lose *-->

 <xsl:variable name="xhtmlns">http://www.w3.org/1999/xhtml</xsl:variable>

 <xsl:template match='comment()'>
  <xsl:comment>
   <xsl:value-of select="."/>
  </xsl:comment>
 </xsl:template>
 
 <xsl:template match='processing-instruction()'>
  <xsl:variable name="pitarget" select="name()"/>
  <xsl:processing-instruction name="{$pitarget}">
   <xsl:value-of select="."/>
  </xsl:processing-instruction>
 </xsl:template>

 <xsl:template match="/">
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="@*">
  <xsl:copy/>
 </xsl:template>

 <xsl:template match="*">
  <xsl:choose>
   <xsl:when test="namespace-uri() = ''">
    <xsl:element name="{local-name()}" namespace="{$xhtmlns}" xmlns="http://www.w3.org/1999/xhtml">
     <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
   </xsl:when>
   <xsl:when test="namespace-uri() != '' and $foreign='keep'">
    <xsl:copy>
     <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
   </xsl:when>
   <xsl:when test="namespace-uri() != '' and $foreign='lose'">
    <!--* do nothing *-->
   </xsl:when>
   <xsl:otherwise>
    <xsl:message terminate="yes">Something is wrong - probably a bad value for $foreign (<xsl:value-of select="$foreign"/>).</xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
</xsl:stylesheet>
