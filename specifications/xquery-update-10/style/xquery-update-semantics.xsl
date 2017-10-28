<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:import href="../../xpath-semantics-10/style/xquery-semantics.xsl"/>

   <xsl:param name="xquery-semantics-doc" select="'http://www.w3.org/TR/xquery-semantics/'"/>


<!-- This template overrides the template of the same name in xquery-semantics.xsl in order
   to make the href value "point to" the XQuery 1.0 Formal Semantics spec, which is where
   the symbol processing_context is actually defined. -->
   <xsl:template match="smcontext">
      <p><b><a href="{$xquery-semantics-doc}#processing_context" class="processing">Static Context Processing</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

<!-- This template overrides the template of the same name in xquery-semantics.xsl in order
   to make the href value "point to" the XQuery 1.0 Formal Semantics spec, which is where
   the symbol processing_normalization is actually defined. -->
   <xsl:template match="smnorm">
      <p><b><a href="{$xquery-semantics-doc}#processing_normalization" class="processing">Normalization</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

<!-- This template overrides the template of the same name in xquery-semantics.xsl in order
   to make the href value "point to" the XQuery 1.0 Formal Semantics spec, which is where
   the symbol processing_static is actually defined. -->
   <xsl:template match="smtype">
      <p><b><a href="{$xquery-semantics-doc}#processing_static" class="processing">Static Type Analysis</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

</xsl:stylesheet>