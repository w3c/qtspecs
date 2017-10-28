<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

<!--
     Definitions of various strings

     Assumes definition of the following parameters

     check-for-docChanges

-->

<xsl:template name="comment-source-text">
<xsl:choose>
<xsl:when test="@source='xe'">
<xsl:text> (public comment)</xsl:text>
</xsl:when>
<xsl:when test="@source='qe'">
<xsl:text> (public comment)</xsl:text>
</xsl:when>
<xsl:when test="@source='wg'">
<xsl:text> (</xsl:text><xsl:value-of select="@wg"/><xsl:text> comment)</xsl:text>
</xsl:when>
<xsl:when test="@source='xwg'">
<xsl:text> (XSL WG comment)</xsl:text>
</xsl:when>
<xsl:when test="@source='qwg'">
<xsl:text> (XQuery WG comment)</xsl:text>
</xsl:when>
<xsl:when test="@source='w3c-xed'">
<xsl:text> (W3C staff editorial review)</xsl:text>
</xsl:when>
<xsl:when test="@source='w3c-qed'">
<xsl:text> (W3C staff editorial review)</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>***ERROR****</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- example of call
<xsl:template match="disposition">
<p><b>Disposition: </b>
<xsl:call-template name="disposition-text">
<xsl:with-param name="disposition-code" select="@type"/>
<xsl:with-param name="document-change" select="..//spotref"/>
</xsl:call-template>
</p>
<xsl:apply-templates/>
</xsl:template>
-->

<xsl:template name="disposition-text">
<xsl:param name="disposition-code">todo</xsl:param>
<xsl:param name="document-change"/>
<xsl:choose>
<xsl:when test="$disposition-code='ae'">
<xsl:text>Accepted (editorial)</xsl:text>
<xsl:if test="$check-for-docChanges and not($document-change)">
<b> DOCUMENT TO BE UPDATED</b>
</xsl:if>
</xsl:when>
<xsl:when test="$disposition-code='an'">
<xsl:text>Accepted (editorial)</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='ac'">
<xsl:text>Accepted (clarification)</xsl:text>
<xsl:if test="$check-for-docChanges and not($document-change)">
<b> DOCUMENT TO BE UPDATED</b>
</xsl:if>
</xsl:when>
<xsl:when test="$disposition-code='ab'">
<xsl:text>Accepted (bug in spec)</xsl:text>
<xsl:if test="$check-for-docChanges and not($document-change)">
<b> DOCUMENT TO BE UPDATED</b>
</xsl:if>
</xsl:when>
<xsl:when test="$disposition-code='af'">
<xsl:text>Accepted (new functionality)</xsl:text>
<xsl:if test="$check-for-docChanges and not($document-change)">
<b> DOCUMENT TO BE UPDATED</b>
</xsl:if>
</xsl:when>
<xsl:when test="$disposition-code='rj'">
<xsl:text>Explanation of why no change will be made</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='ex'">
<xsl:text>Explanation of XSL spec</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='exc'">
<xsl:text>Explanation of interpretation of comment</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='exl'">
<xsl:text>Explanation</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='df'">
<xsl:text>Future XSL version</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='ow'">
<xsl:text>Out of scope; responsibility of other WG</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='oj'">
<xsl:text>Out of scope; requires joint work with other WG</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='rn'">
<xsl:text>Requires negotiation/discussion; XSL WG cannot close issue alone</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='uc'">
<xsl:text>Unclear comment</xsl:text>
</xsl:when>
<xsl:when test="$disposition-code='todo'">
<xsl:text>***TO BE DONE***</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>***ERROR***</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->