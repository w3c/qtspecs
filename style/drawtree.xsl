<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:t="http://www.w3.org/2008/XSL/Spec/TreeDiagram"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="t xs">
  
  <!-- This stylesheet takes as input a simple XML description of a tree, and outputs an SVG
       diagram depicting the tree. It was developed for use in the XSLT 2.1 specification
       but is NO LONGER USED AS OF FEB 2010 -->
       
  <!-- This is an XSLT 2.0 stylesheet, with a dependency on the EXSLT mathematical functions -->      
       
  <!-- Here is an example of an input tree:
  
        <tree xmlns="http://www.w3.org/2008/XSL/Spec/TreeDiagram"
          x-step="30" y-step="30" box-width="140" box-height="30" style="horizontal">
          <node label="root">
            <node label="child::account">
              <node label="child::transaction">
                <node label="child::branch">
                  <node label="descendant::node()"/>
                </node>
                <node label="self::node">
                  <node label="child::amount">
                    <node label="descendant::node()"/>
                  </node>
                  <node label="descendant::node()"/>
                </node>
              </node>
            </node>
          </node>
        </tree>  
  -->
  
<xsl:output method="xml" indent="yes"/>
<xsl:strip-space elements="*"/>  
        

<xsl:template match="t:tree">
  <svg:svg 
    baseProfile="full" zoomAndPan="magnify" contentStyleType="text/css" 
    preserveAspectRatio="xMidYMid meet" version="1.0">
      <svg:g transform="translate(10,10)">
        <xsl:apply-templates/>
      </svg:g>
  </svg:svg>
</xsl:template>

<xsl:template match="t:node">
  <xsl:variable name="xy" select="t:topLeftCorner(.)" as="xs:integer*"/>
  <xsl:variable name="x" select="$xy[1]"/>
  <xsl:variable name="y" select="$xy[2]"/>
  <xsl:variable name="X_STEP" select="(ancestor::t:tree/xs:integer(@x-step), 50)[1]" as="xs:integer"/>  
  <xsl:variable name="Y_STEP" select="(ancestor::t:tree/xs:integer(@y-step), 70)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_WIDTH" select="(ancestor::t:tree/xs:integer(@box-width), 200)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_HEIGHT" select="(ancestor::t:tree/xs:integer(@box-height), 40)[1]" as="xs:integer"/>
  <svg:rect fill="{(@color, 'none')[1]}" x="{$x}" y="{$y}" width="{$BOX_WIDTH}" height="{$BOX_HEIGHT}"
            stroke="#000000"/>
  <svg:text x="{$x+10}" y="{$y+($BOX_HEIGHT idiv 2)}">
     <svg:tspan>
        <xsl:value-of select="@label"/>
     </svg:tspan>
  </svg:text>          
  <xsl:if test="parent::t:node">
    <xsl:call-template name="t:connectToParent"/>         
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- Compute the position of the top-left-hand-corner of the box representing a given
     node, as a sequence of two integers (the x and y coordinates respectively) -->

<xsl:function name="t:topLeftCorner" as="xs:integer*">
  <xsl:param name="node" as="element(t:node)"/>
  <xsl:variable name="style" select="($node/ancestor::t:tree/@style, 'drop')[1]" as="xs:string"/>
  <xsl:variable name="X_STEP" select="($node/ancestor::t:tree/xs:integer(@x-step), 50)[1]" as="xs:integer"/>  
  <xsl:variable name="Y_STEP" select="($node/ancestor::t:tree/xs:integer(@y-step), 70)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_WIDTH" select="($node/ancestor::t:tree/xs:integer(@box-width), 200)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_HEIGHT" select="($node/ancestor::t:tree/xs:integer(@box-height), 40)[1]" as="xs:integer"/>
  <xsl:choose>
    <xsl:when test="$style='drop'">
       <xsl:sequence select="count($node/ancestor::t:node) * $X_STEP"/>
       <xsl:sequence select="(count($node/preceding::t:node) + count($node/ancestor::t:node)) * $Y_STEP"/>
    </xsl:when>
    <xsl:when test="$style='vertical'">
       <xsl:variable name="depth" select="count($node/ancestor::t:node)" as="xs:integer"/>
       <xsl:choose>
         <xsl:when test="$node/parent::t:node">
           <xsl:sequence select="t:topLeftCorner($node/..)[1] + 
                          sum($node/preceding-sibling::t:node/t:subtreeWidth(.)) * ($BOX_WIDTH +$X_STEP)"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:sequence select="0"/>
         </xsl:otherwise>
       </xsl:choose>
       <xsl:sequence select="$depth * ($BOX_HEIGHT + $Y_STEP)"/>
    </xsl:when>
    <xsl:when test="$style='horizontal'">
       <xsl:variable name="depth" select="count($node/ancestor::t:node)" as="xs:integer"/>
       <xsl:sequence select="$depth * ($BOX_WIDTH + $X_STEP)"/>
       <xsl:choose>
         <xsl:when test="$node/parent::t:node">
           <xsl:sequence select="t:topLeftCorner($node/..)[2] + 
                          sum($node/preceding-sibling::t:node/t:subtreeWidth(.)) * ($BOX_HEIGHT +$Y_STEP)"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:sequence select="0"/>
         </xsl:otherwise>
       </xsl:choose>
    </xsl:when>    
    <xsl:otherwise>
      <xsl:message terminate="yes">Unknown tree style <xsl:value-of select="$style"/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template name="t:connectToParent">
  <xsl:variable name="this" select="t:topLeftCorner(.)" as="xs:integer*"/>    
  <xsl:variable name="parent" select="t:topLeftCorner(..)" as="xs:integer*"/>
  <xsl:variable name="style" select="(ancestor::t:tree/@style, 'drop')[1]" as="xs:string"/>
  <xsl:variable name="X_STEP" select="(ancestor::t:tree/xs:integer(@x-step), 50)[1]" as="xs:integer"/>  
  <xsl:variable name="Y_STEP" select="(ancestor::t:tree/xs:integer(@y-step), 70)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_WIDTH" select="(ancestor::t:tree/xs:integer(@box-width), 200)[1]" as="xs:integer"/>
  <xsl:variable name="BOX_HEIGHT" select="(ancestor::t:tree/xs:integer(@box-height), 40)[1]" as="xs:integer"/> 
  <xsl:choose>
    <xsl:when test="$style='drop'">
      <svg:line x1="{$this[1] - $X_STEP + 10}" x2="{$this[1]}" y1="{$this[2]+($BOX_HEIGHT idiv 2)}" 
                y2="{$this[2]+($BOX_HEIGHT idiv 2)}" stroke="#000000"/>
      <svg:line x1="{$this[1] - $X_STEP + 10}" x2="{$this[1] - $X_STEP + 10}" y1="{$parent[2] + $BOX_HEIGHT}" 
                y2="{$this[2]+($BOX_HEIGHT idiv 2)}" stroke="#000000"/>                
    </xsl:when>
    <xsl:when test="$style='vertical'">
      <xsl:sequence select="t:arrow($parent[1] + ($BOX_WIDTH idiv 2),
                                    $parent[2] + $BOX_HEIGHT,
                                    $this[1] + ($BOX_WIDTH idiv 2),
                                    $this[2])"/>
                                    
      
    </xsl:when>    
    <xsl:when test="$style='horizontal'">
      <xsl:sequence select="t:arrow($parent[1] + $BOX_WIDTH,
                                    $parent[2] + ($BOX_HEIGHT idiv 2),
                                    $this[1],
                                    if ($this[2] eq $parent[2]) 
                                       then $this[2] + ($BOX_HEIGHT idiv 2) 
                                       else $this[2])"/>
                                    
      
    </xsl:when>        
    <xsl:otherwise>
      <xsl:message terminate="yes">Unknown tree style <xsl:value-of select="$style"/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>

<!-- Calculate the depth of a node within the tree -->

<xsl:function name="t:depth" as="xs:integer">
  <xsl:param name="node" as="element(t:node)"/>
  <xsl:sequence select="count($node/ancestor::node())"/>
</xsl:function>

<!-- Calculate the width of the subtree rooted at a particular node, that is, the sum of the widths
     of its subtrees if it has any, or 1 otherwise -->

<xsl:function name="t:subtreeWidth" as="xs:integer">
  <xsl:param name="node" as="element(t:node)"/>
  <xsl:choose>
    <xsl:when test="$node/child::t:node">
      <xsl:sequence select="sum(for $n in $node/child::t:node return t:subtreeWidth($n))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Construct a line with an arrowhead -->

<xsl:function name="t:arrow" as="element(svg:g)">
  <xsl:param name="x1" as="xs:integer"/>
  <xsl:param name="y1" as="xs:integer"/>
  <xsl:param name="x2" as="xs:integer"/>
  <xsl:param name="y2" as="xs:integer"/>
  <xsl:variable name="angle" select="math:atan2($y2 - $y1, $x2 - $x1) div 3.14159 * 180"
      xmlns:math="http://exslt.org/math"/>
  <svg:g>
    <svg:line x1="{$x1}" x2="{$x2}" y1="{$y1}" y2="{$y2}" stroke="#000000"/>
    <svg:g transform="rotate({$angle}, {$x2}, {$y2})">
      <svg:polygon points="{$x2},{$y2} {$x2 - 10},{$y2 - 5} {$x2 - 10},{$y2 + 5}"
                   fill="#000000"/>
    </svg:g>             
  </svg:g>
</xsl:function>
     
</xsl:transform>           