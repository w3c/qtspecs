<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="2.0">


<xsl:import href="xslt.xsl"/>
<!--<xsl:import href="../../../style/drawtree.xsl"/>-->
<xsl:output indent="no"/>  
<xsl:include href="diff.xsl"/>

<xsl:template match="t:tree" xmlns:t="http://www.w3.org/2008/XSL/Spec/TreeDiagram"
                             xmlns:svg="http://www.w3.org/2000/svg"
                             exclude-result-prefixes="t svg">
  <xsl:variable name="number">
    <xsl:number level="any"/>
  </xsl:variable>
  <xsl:variable name="svg">
    <xsl:apply-imports/>
  </xsl:variable>
  <xsl:result-document href="tree{$number}.svg">
    <xsl:copy-of select="$svg"/>
  </xsl:result-document>
  <xsl:variable name="max-x" select="max($svg//svg:rect/(@x + @width))"/>
  <xsl:variable name="max-y" select="max($svg//svg:rect/(@y + @height))"/>
  <embed src="tree{$number}.svg" width="{$max-x + 20}" height="{$max-y + 20}" type="image/svg+xml"/>
</xsl:template>
  
  <xsl:template match="div1/head/text() | div2/head/text() | div3/head/text() | div4/head/text()">
    <!-- insert a link to self, to make the ID value visible for the benefit of spec editors -->
    <a href="#{../../@id}" style="text-decoration: none">
      <xsl:apply-imports/>
    </a>
  </xsl:template>
  
  <xsl:template match="e:element-syntax[@diff and $show.diff.markup='1' and (string(@at) gt $baseline or not(@at))]" mode="get-diff-class"
    xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax">
    <xsl:text>element-syntax-chg</xsl:text>
  </xsl:template>

</xsl:stylesheet>
