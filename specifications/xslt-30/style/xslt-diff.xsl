<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
		version="2.0">


<xsl:import href="xslt.xsl"/>
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
  
  <!-- Override rendition of altlocs in xmlspec.xsl -->
  
  <xsl:template match="altlocs">
    <p>The following associated resources are available:</p>
    <ul>
      <xsl:for-each select="loc">
        <li>
          <xsl:apply-templates select="."/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <xsl:template match="div1/head/text() | div2/head/text() | div3/head/text() | div4/head/text()">
    <!-- insert a link to self, to make the ID value visible for the benefit of spec editors -->
    <a href="#{../../@id}" style="text-decoration: none">
      <xsl:apply-imports/>
    </a>
  </xsl:template>
 
  <xsl:template match="e:element-syntax[@diff and $show.diff.markup=1 and (string(@at) gt $baseline or not(@at))]" mode="get-diff-class"
    xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax">
    <xsl:text>element-syntax-chg</xsl:text>
  </xsl:template>
  
  <!--<xsl:template match="*[@mark='yes']" priority="100">
    <mark>
      <xsl:next-match/>
    </mark>
    </xsl:template>-->
  
  <!-- following template can be activated to insert paragraph numbers after every para -->
  <xsl:template match="p[$show.diff.markup=1]" use-when="false()">   
    <xsl:next-match/> 
    <span style="font-size:10; background-color:DarkRed; color:white; float:right">&#xa0;&#xa0;P<xsl:number select="(ancestor::div1|ancestor::informdiv1|/)[last()]" level="any"/>.<xsl:number level="any" from="div1|informdiv1"/></span>
  </xsl:template>
  
  <xsl:template match="p[$show.diff.markup=1][loc[1][matches(@href, '^bug[0-9]+$')]]">   
    <xsl:next-match/>
    <xsl:variable name="href" select="string(loc[1]/@href)"/>
    <xsl:variable name="refs" select="//*[ends-with(@at, $href) and string(@at) gt $baseline]"/>
    <xsl:choose>
      <xsl:when test="empty($refs)">
        <p>(No highlighted changes.)</p>
      </xsl:when>
      <xsl:otherwise>
        <p><xsl:text>(See </xsl:text>
          <xsl:for-each select="$refs">
            <xsl:variable name="n" as="xs:string">
              <xsl:number value="position()" format="a"/>
            </xsl:variable>
            <a href="#{$href}{$n}"><xsl:value-of select="$n"/></a>
            <xsl:value-of select="if (position() = last()) then '' else ' '"/>  
          </xsl:for-each> 
          <xsl:text>)</xsl:text>      
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="prodrecap">
    <xsl:variable name="capture">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:message>===============================</xsl:message>
    <xsl:message select="$capture"/>
    <xsl:message>===============================</xsl:message>
    <xsl:sequence select="$capture"/>   
  </xsl:template>
  
  <xsl:template match="def[@role='example']">
    <dd>
      <div class="example">
        <xsl:apply-templates/>
      </div>
    </dd>
  </xsl:template>
  

</xsl:stylesheet>
