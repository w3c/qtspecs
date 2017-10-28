<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="urn:oasis:names:tc:entity:xmlns:xml:catalog">

<!-- stylesheet to create the Saxon StandardEntityResolver data from the catalog.xml file -->
<!-- the output needs to be massaged by hand -->

<xsl:output method="text"/>

<xsl:template match="/">
  <xsl:apply-templates select="//public"/>
</xsl:template>

<xsl:template match="public">
  <xsl:variable name="this" select="."/>
  <xsl:variable name="systemId">
    <xsl:variable name="content" select="unparsed-text(resolve-uri(@uri, base-uri(.)))"/>
    <xsl:for-each select="tokenize($content, '\n')[contains(., 'http:') and contains(., $this/@uri)]">        
      <xsl:sequence select="replace(., '^.*&quot;(http://www.w3.org\S+?)&quot;.*$', '$1')"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:text>        register("</xsl:text>
  <xsl:value-of select="@publicId"/>
  <xsl:text>",&#xa;</xsl:text>
  <xsl:text>                 "</xsl:text>
  <xsl:value-of select="$systemId"/>
  <xsl:text>",&#xa;</xsl:text>
  <xsl:text>                 "</xsl:text>
  <xsl:value-of select="concat(../@xml:base, @uri)"/>
  <xsl:text>");&#xa;</xsl:text>
</xsl:template>

</xsl:transform>