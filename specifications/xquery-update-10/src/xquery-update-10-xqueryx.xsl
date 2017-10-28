<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xqxuf="http://www.w3.org/2007/xquery-update-10"
                xmlns:xqx="http://www.w3.org/2005/XQueryX">

<!-- Initial creation                  2006-08-17: Jim Melton -->
<!-- Added revalidationDecl            2006-08-21: Jim Melton -->
<!-- Bring up to date with spec        2007-08-07: Jim Melton -->
<!-- Surround updating exprs w/parens  2007-09-13: Jim Melton -->


<xsl:import href="http://www.w3.org/2005/XQueryX/xqueryx.xsl"/>


<!-- revalidationDecl                                         -->
<xsl:template match="xqxuf:revalidationDecl">
  <xsl:text>declare revalidation </xsl:text>
  <xsl:apply-templates/>
</xsl:template>


<!-- insertExpr                                               -->
<xsl:template match="xqxuf:insertExpr">
  <xsl:value-of select="$LPAREN"/>
  <xsl:text>insert nodes </xsl:text>
  <xsl:value-of select="$NEWLINE"/>
  <xsl:apply-templates select="xqxuf:sourceExpr"/>
  <xsl:value-of select="$NEWLINE"/>
  <xsl:apply-templates select="xqxuf:insertInto |
                               xqxuf:insertBefore |
                               xqxuf:insertAfter"/>
  <xsl:value-of select="$NEWLINE"/>
  <xsl:apply-templates select="xqxuf:targetExpr"/>
  <xsl:value-of select="$RPAREN"/>
</xsl:template>


<!-- sourceExpr                                               -->
<xsl:template match="xqxuf:sourceExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- insertInto                                               -->
<xsl:template match="xqxuf:insertInto">
  <xsl:if test="child::node()">
    <xsl:text>as </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:text>into </xsl:text>
</xsl:template>


<!-- insertAsFirst                                            -->
<xsl:template match="xqxuf:insertAsFirst">
  <xsl:text>first </xsl:text>
</xsl:template>


<!-- insertAsLast                                             -->
<xsl:template match="xqxuf:insertAsLast">
  <xsl:text>last </xsl:text>
</xsl:template>


<!-- insertAfter                                              -->
<xsl:template match="xqxuf:insertAfter">
  <xsl:text>after </xsl:text>
</xsl:template>


<!-- insertBefore                                             -->
<xsl:template match="xqxuf:insertBefore">
  <xsl:text>before </xsl:text>
</xsl:template>


<!-- targetExpr                                               -->
<xsl:template match="xqxuf:targetExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- deleteExpr                                               -->
<xsl:template match="xqxuf:deleteExpr">
  <xsl:value-of select="$LPAREN"/>
  <xsl:text>delete nodes </xsl:text>
  <xsl:apply-templates/>
  <xsl:value-of select="$RPAREN"/>
</xsl:template>


<!-- replaceExpr                                              -->
<xsl:template match="xqxuf:replaceExpr">
  <xsl:value-of select="$LPAREN"/>
  <xsl:text>replace </xsl:text>
  <xsl:if test="xqxuf:replaceValue">
    <xsl:text>value of </xsl:text>
  </xsl:if>
  <xsl:text>node </xsl:text>
  <xsl:apply-templates select="xqxuf:targetExpr"/>
  <xsl:text> with </xsl:text>
  <xsl:apply-templates select="xqxuf:replacementExpr"/>
  <xsl:value-of select="$RPAREN"/>
</xsl:template>


<!-- replacementExpr                                          -->
<xsl:template match="xqxuf:replacementExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- renameExpr                                               -->
<xsl:template match="xqxuf:renameExpr">
  <xsl:value-of select="$LPAREN"/>
  <xsl:text>rename node </xsl:text>
  <xsl:apply-templates select="xqxuf:targetExpr"/>
  <xsl:text> as </xsl:text>
  <xsl:apply-templates select="xqxuf:newNameExpr"/>
  <xsl:value-of select="$RPAREN"/>
</xsl:template>


<!-- newNameExpr                                              -->
<xsl:template match="xqxuf:newNameExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- transformExpr                                            -->
<xsl:template match="xqxuf:transformExpr">
  <xsl:value-of select="$LPAREN"/>
  <xsl:text>copy </xsl:text>
  <xsl:apply-templates select="xqxuf:transformCopies"/>
  <xsl:value-of select="$NEWLINE"/>
  <xsl:text>  modify </xsl:text>
  <xsl:apply-templates select="xqxuf:modifyExpr"/>
  <xsl:value-of select="$NEWLINE"/>
  <xsl:text>  return </xsl:text>
  <xsl:apply-templates select="xqxuf:returnExpr"/>
  <xsl:value-of select="$RPAREN"/>
</xsl:template>


<!-- Part of transformExpr                                    -->
<xsl:template match="xqxuf:transformCopies">
  <xsl:call-template name="commaSeparatedList"/>
</xsl:template>


<!-- Part of transformExpr                                    -->
<xsl:template match="xqxuf:transformCopy">
  <xsl:apply-templates select="xqx:varRef"/>
  <xsl:text> := </xsl:text>
  <xsl:apply-templates select="xqxuf:copySource"/>
</xsl:template>

<!-- Part of transformExpr                                    -->
<xsl:template match="xqxuf:copySource">
  <xsl:apply-templates/>
</xsl:template>

<!-- Part of transformExpr                                    -->
<xsl:template match="xqxuf:modifyExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- Part of transformExpr                                    -->
<xsl:template match="xqxuf:returnExpr">
  <xsl:apply-templates/>
</xsl:template>


<!-- Over-ride the template for functionDecl in XQueryX.xsd   -->
  <xsl:template match="xqx:functionDecl" priority="100">
    <xsl:text>declare </xsl:text>
    <xsl:if test="@xqx:updatingFunction and
                  @xqx:updatingFunction = 'true'">
      <xsl:text>updating </xsl:text>
    </xsl:if>
    <xsl:text>function </xsl:text>
    <xsl:apply-templates select="xqx:functionName"/>
    <xsl:apply-templates select="xqx:paramList"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
    <xsl:apply-templates select="xqx:functionBody"/>
    <xsl:if test="xqx:externalDefinition">
      <xsl:text> external </xsl:text>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>