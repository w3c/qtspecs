<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <!-- This stylesheet tidies up the SVG output produced by GraphViz by adding
         the suffix "pt" to the coordinates in the viewBox attribute. This
         improves rendition on Safari and Chrome -->
    
    <xsl:output method="xml"
                indent="yes"
                doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
                doctype-public="-//W3C//DTD SVG 1.1//EN"/>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="*:svg/@viewBox">
        <xsl:attribute name="viewBox"
            select="for $t in tokenize(., ' ') return concat($t, 'pt')"/>
    </xsl:template>-->
</xsl:stylesheet>