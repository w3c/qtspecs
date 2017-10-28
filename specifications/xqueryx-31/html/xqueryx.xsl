<?xml version="1.0"?>
<!--  ================================================================================  -->
<!--  Changes from Recommendation (XQueryX 3.0):                                        -->
<!--  ================================================================================  -->
<!--  Errata applied:                                                                   -->
<!--  ================================================================================  -->
<!--  Modifications:                                                                    -->
<!--    JM/2014-07-11 : Added support for anyMapText and typedMapTest                   -->
<!--    JM/2014-07-11 : Added support for anyArrayText and typedArrayTest               -->
<!--    JM/2014-07-13 : Added support for new alternatives in stepExpr                  -->
<!--    JM/2014-07-13 : Added support for lookup (formerly mapLookup)                   -->
<!--    JM/2014-07-13 : Added support for unaryLookup (formerly unaryMapLookup)         -->
<!--    JM/2014-07-13 : Added support for new alternatives in filterExpr                -->
<!--    JM/2014-07-13 : Added support for mapConstructor and arrayConstructor           -->
<!--    JM/2014-08-28 : Fixed [unary]Lookup replacing stringLiteral w/integerLiteral    -->
<!--    JM/2015-02-11 : Replaced arrowPostfix with arrowExpr per bug 27537              -->
<!--    JS/2015-11-05 : Added support for stringConstructor                             -->
<!--    JS/2016-01-20 : Added support for unaryLookup per bug 29364                     -->
<!--    JS/2016-01-20 : Added xqx:EQName to renderEQName per bug 29365                  -->
<!--    JS/2016-09-23 : Bug 29823 - remove duplicate integerLiteral and variableRef     -->
<!--    JS/2016-11-01 : Bug 29868 - does not always convert arrowExpr to XQuery         -->
<!--  ================================================================================  -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xqx="http://www.w3.org/2005/XQueryX">

<!-- Note that this stylesheet frequently invokes templates for
     specified elements, even when there are no templates in the
     stylesheet whose match="" attribute identifies those elements.
     In such case, the default template's element matching template
     is invoked, which merely invokes xsl:apply-templates -->

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="xqx:value xqx:attributeValue xqx:pragmaContents
                                xqx:optionContents xqx:xquery xqx:stringConstructorChars"/>

  <xsl:variable name="DOT" select="'.'"/>
  <xsl:variable name="SPACE" select="' '"/>
  <xsl:variable name="SLASH" select="'/'"/>
  <xsl:variable name="SLASH_SLASH" select="'//'"/>
  <xsl:variable name="LESSTHAN" select="'&lt;'"/>
  <xsl:variable name="GREATERTHAN" select="'&gt;'"/>
  <xsl:variable name="LPAREN" select="'('"/>
  <xsl:variable name="RPAREN" select="')'"/>
  <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
  <xsl:variable name="COMMA" select="','"/>
  <xsl:variable name="COMMA_SPACE" select="', '"/>
  <xsl:variable name="COMMA_NEWLINE"><xsl:text>,
</xsl:text></xsl:variable>
  <xsl:variable name="QUOTE"><xsl:text>'</xsl:text></xsl:variable>
  <xsl:variable name="DOUBLEQUOTE"><xsl:text>"</xsl:text></xsl:variable>
  <xsl:variable name="TO" select="' to '"/>
  <xsl:variable name="LBRACE" select="'{'"/>
  <xsl:variable name="RBRACE" select="'}'"/>
  <xsl:variable name="LBRACKET" select="'['"/>
  <xsl:variable name="RBRACKET" select="']'"/>
  <xsl:variable name="DOLLAR" select="'$'"/>
  <xsl:variable name="MINUS" select="'-'"/>
  <xsl:variable name="PLUS" select="'+'"/>
  <xsl:variable name="EQUAL" select="'='"/>
  <xsl:variable name="COLON" select="':'"/>
  <xsl:variable name="DOUBLE_COLON" select="'::'"/>
  <xsl:variable name="SEMICOLON" select="';'"/>
  <xsl:variable name="AT" select="'@'"/>
  <xsl:variable name="STAR" select="'*'"/>
  <xsl:variable name="QUESTIONMARK" select="'?'"/>
  <xsl:variable name="EXCLAMATIONMARK" select="'!'"/>
  <xsl:variable name="PERCENT" select="'%'"/>
  <xsl:variable name="ASSIGN" select="':='"/>
  <xsl:variable name="SEPARATOR" select="';'"/>
  <xsl:variable name="PRAGMA_BEGIN" select="'(# '"/>
  <xsl:variable name="PRAGMA_END" select="' #)'"/>
  <xsl:variable name="CONCATENATE" select="'||'"/>


  <xsl:template name="delimitedList">
    <xsl:param name="delimiter" />
    <xsl:param name="leftEncloser"/>
    <xsl:param name="rightEncloser" />
    <xsl:param name="selector"/>

    <xsl:value-of select="$leftEncloser"/>
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:if test="not (position()=last())">        
        <xsl:value-of select="$delimiter"/>
      </xsl:if>       
    </xsl:for-each>
    <xsl:value-of select="$rightEncloser"/>
  </xsl:template>   


  <xsl:template name="parenthesizedList">
    <xsl:param name="delimiter" select="$COMMA_SPACE"/>
    <xsl:call-template name="delimitedList">
      <xsl:with-param name="delimiter" select="$delimiter" />
      <xsl:with-param name="leftEncloser" select="$LPAREN"/>
      <xsl:with-param name="rightEncloser" select="$RPAREN"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="commaSeparatedList">
    <xsl:call-template name="delimitedList">
      <xsl:with-param name="delimiter">
        <xsl:value-of select="$COMMA_SPACE"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="quote">
    <xsl:param name="item"/>
    <xsl:value-of select="$DOUBLEQUOTE"/>
    <xsl:call-template name="globalReplace">
      <xsl:with-param name="stringToBeFixed">
        <xsl:call-template name="globalReplace">
          <xsl:with-param name="stringToBeFixed">
            <xsl:call-template name="globalReplace">
              <xsl:with-param name="stringToBeFixed">
                <xsl:call-template name="globalReplace">
                  <xsl:with-param name="stringToBeFixed">
                    <xsl:call-template name="globalReplace">
                      <xsl:with-param name="stringToBeFixed">
                        <xsl:call-template name="globalReplace">
                          <xsl:with-param name="stringToBeFixed">
                            <xsl:value-of select="$item"/>
                          </xsl:with-param>
                          <xsl:with-param name="toBeReplaced">&amp;</xsl:with-param>
                          <xsl:with-param name="replacement">&amp;amp;</xsl:with-param>
                        </xsl:call-template>
                                      </xsl:with-param>
                      <xsl:with-param name="toBeReplaced">&lt;</xsl:with-param>
                      <xsl:with-param name="replacement">&amp;lt;</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="toBeReplaced" select="'&#x85;'"/>
                  <xsl:with-param name="replacement">&amp;#x85;</xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="toBeReplaced" select="'&#xD;'"/>
              <xsl:with-param name="replacement">&amp;#xD;</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="toBeReplaced" select="'&#x2028;'"/>
          <xsl:with-param name="replacement">&amp;#x2028;</xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="toBeReplaced"><xsl:text>"</xsl:text></xsl:with-param>
      <xsl:with-param name="replacement"><xsl:text>""</xsl:text></xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="$DOUBLEQUOTE"/>
  </xsl:template>


  <xsl:template name="globalReplace">
    <xsl:param name="stringToBeFixed"/>
    <xsl:param name="toBeReplaced"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($stringToBeFixed, $toBeReplaced)">
        <xsl:value-of select="concat(substring-before($stringToBeFixed, $toBeReplaced), $replacement)"/>
        <xsl:call-template name="globalReplace">
          <xsl:with-param name="stringToBeFixed" select="substring-after($stringToBeFixed, $toBeReplaced)"/>
          <xsl:with-param name="toBeReplaced" select="$toBeReplaced"/>
          <xsl:with-param name="replacement" select="$replacement"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$stringToBeFixed"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="renderQName">
    <xsl:if test="@xqx:prefix">
      <xsl:value-of select="@xqx:prefix"/>
      <xsl:value-of select="$COLON"/>
    </xsl:if>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template name="renderEQName"
                match="xqx:QName | xqx:EQName | xqx:pragmaName | xqx:typeName | xqx:varName |
                       xqx:functionName | xqx:optionName | xqx:annotationName |
                       xqx:atomicType | xqx:tagName | xqx:name | xqx:decimalFormatName">
    <xsl:choose>
      <xsl:when test="xqx:tagName/parent::xqx:elementConstructor">
        <xsl:call-template name="renderQName"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@xqx:prefix and @xqx:URI">
            <xsl:message terminate="yes">Incorrect XQueryX: Elements of type xqx:EQName must not have both 'prefix' and 'URI' attributes</xsl:message>
          </xsl:when>
          <xsl:when test="@xqx:prefix">
            <xsl:value-of select="@xqx:prefix"/>
            <xsl:value-of select="$COLON"/>
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:when test="@xqx:URI">
            <xsl:text>Q</xsl:text>
            <xsl:value-of select="$LBRACE"/>
            <xsl:value-of select="@xqx:URI"/>
            <xsl:value-of select="$RBRACE"/>
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:attributeName">
    <xsl:choose>
      <xsl:when test="@xqx:prefix='xmlns'">
        <xsl:message terminate="yes">Incorrect XQueryX: Attribute names are not permitted to have prefix 'xmlns'; use xqx:namespaceDeclaration to declare namespaces</xsl:message>
      </xsl:when>
      <xsl:when test=". = 'xmlns'">
        <xsl:message terminate="yes">Incorrect XQueryX: Attribute names are not permitted to be 'xmlns'; use xqx:namespaceDeclaration to declare namespaces</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="renderQName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:NCName">
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:rootExpr">
    <xsl:value-of select="$SLASH"/>
  </xsl:template>


  <xsl:template match="xqx:argumentPlaceholder">
    <xsl:value-of select="$QUESTIONMARK"/>
  </xsl:template>


  <xsl:template match="xqx:pathExpr/xqx:rootExpr">
    <xsl:if test="not(following-sibling::xqx:stepExpr)">
      <xsl:value-of select="$LPAREN"/>
    </xsl:if>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$SLASH"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:if test="not(following-sibling::xqx:stepExpr)">
      <xsl:value-of select="$RPAREN"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:contextItemExpr">
    <xsl:value-of select="$DOT"/>
  </xsl:template>


  <xsl:template match="xqx:stringConstantExpr">
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:value"/>
    </xsl:call-template>
  </xsl:template>

<!-- 2016-09-23/JS Bug 29823 - Removed integerLiteral.                         -->
<!-- 2014-08-28/JM Added integerLiteral for use in lookup (formerly mapLookup) -->
  <xsl:template match="xqx:integerConstantExpr |
                       xqx:decimalConstantExpr |
                       xqx:doubleConstantExpr">
    <xsl:value-of select="xqx:value"/>
  </xsl:template>

<!-- 2016-09-23/JS Bug 29823 - Removed variableRef         -->
<!-- 2014-07-13/JM Added variableRef for use in arrowExpr -->
  <xsl:template match="xqx:varRef">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:apply-templates select="xqx:name"/>
  </xsl:template>


  <xsl:template match="xqx:pragma">
    <xsl:value-of select="$PRAGMA_BEGIN"/>
    <xsl:apply-templates select="xqx:pragmaName"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="xqx:pragmaContents"/>
    <xsl:value-of select="$PRAGMA_END"/>
  </xsl:template>


  <xsl:template match="xqx:extensionExpr">
    <xsl:apply-templates select="xqx:pragma"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>

  <xsl:template match="xqx:simpleMapExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:pathExpr[1]"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RPAREN"/>
    <xsl:for-each select="xqx:pathExpr[position() != 1]">
      <xsl:value-of select="$NEWLINE"/>
      <xsl:value-of select="$EXCLAMATIONMARK"/>
      <xsl:value-of select="$SPACE"/>
      <xsl:value-of select="$LPAREN"/>
      <xsl:value-of select="$SPACE"/>
      <xsl:apply-templates select="."/>
      <xsl:value-of select="$SPACE"/>
      <xsl:value-of select="$RPAREN"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:functionCallExpr">
    <xsl:if test="(xqx:functionName = 'node' or
                   xqx:functionName = 'document-node' or
                   xqx:functionName = 'element' or
                   xqx:functionName = 'attribute' or
                   xqx:functionName = 'schema-element' or
                   xqx:functionName = 'schema-attribute' or
                   xqx:functionName = 'processing-instruction' or
                   xqx:functionName = 'comment' or
                   xqx:functionName = 'text' or
                   xqx:functionName = 'function' or
                   xqx:functionName = 'namespace-node' or
                   xqx:functionName = 'item' or
                   xqx:functionName = 'if' or
                   xqx:functionName = 'switch' or
                   xqx:functionName = 'typeswitch' or
                   xqx:functionName = 'empty-sequence') and
                   ((not(xqx:functionName/@xqx:prefix) and not(xqx:functionName/@xqx:URI)) or
                    xqx:functionName/@xqx:prefix = '' or
                    xqx:functionName/@xqx:URI = '')">
      <xsl:variable name="message"><xsl:text>Incorrect XQueryX: function calls must not use unqualified "reserved" name "</xsl:text><xsl:value-of select="xqx:functionName"/><xsl:text>"</xsl:text></xsl:variable>
      <xsl:message terminate="yes"><xsl:value-of select="$message"/></xsl:message>
    </xsl:if>
    <xsl:apply-templates select="xqx:functionName"/>
    <xsl:choose>
      <xsl:when test="xqx:arguments">
        <xsl:for-each select="xqx:arguments">
          <xsl:call-template name="parenthesizedList"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$LPAREN"/>
        <xsl:value-of select="$RPAREN"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:constructorFunctionExpr">
    <xsl:apply-templates select="xqx:typeName"/>
    <xsl:for-each select="xqx:argExpr">
      <xsl:call-template name="parenthesizedList"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:unaryMinusOp | xqx:unaryPlusOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:choose>
       <xsl:when test="self::xqx:unaryPlusOp"><xsl:value-of select="$PLUS"/></xsl:when>
       <xsl:when test="self::xqx:unaryMinusOp"><xsl:value-of select="$MINUS"/></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:operand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:addOp | xqx:subtractOp | xqx:multiplyOp
                     | xqx:divOp | xqx:idivOp | xqx:modOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:addOp"><xsl:value-of select="$PLUS"/></xsl:when>
       <xsl:when test="self::xqx:subtractOp"><xsl:text> </xsl:text><xsl:value-of select="$MINUS"/><xsl:text> </xsl:text></xsl:when>
       <xsl:when test="self::xqx:multiplyOp"><xsl:value-of select="$STAR"/></xsl:when>
       <xsl:when test="self::xqx:divOp"><xsl:text> div </xsl:text></xsl:when>
       <xsl:when test="self::xqx:idivOp"><xsl:text> idiv </xsl:text></xsl:when>
       <xsl:when test="self::xqx:modOp"><xsl:text> mod </xsl:text></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:stringConcatenateOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:value-of select="$CONCATENATE"/>
     <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:eqOp | xqx:neOp | xqx:ltOp
                     | xqx:gtOp | xqx:leOp | xqx:geOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:eqOp"><xsl:text> eq </xsl:text></xsl:when>
       <xsl:when test="self::xqx:neOp"><xsl:text> ne </xsl:text></xsl:when>
       <xsl:when test="self::xqx:ltOp"><xsl:text> lt </xsl:text></xsl:when>
       <xsl:when test="self::xqx:gtOp"><xsl:text> gt </xsl:text></xsl:when>
       <xsl:when test="self::xqx:leOp"><xsl:text> le </xsl:text></xsl:when>
       <xsl:when test="self::xqx:geOp"><xsl:text> ge </xsl:text></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:equalOp | xqx:notEqualOp | xqx:lessThanOp
                     | xqx:greaterThanOp | xqx:lessThanOrEqualOp | xqx:greaterThanOrEqualOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:equalOp">
         <xsl:text> </xsl:text><xsl:value-of select="$EQUAL"/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:when test="self::xqx:notEqualOp">
         <xsl:text> !</xsl:text><xsl:value-of select="$EQUAL"/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:when test="self::xqx:lessThanOp">
         <xsl:text> </xsl:text><xsl:value-of select="$LESSTHAN"/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:when test="self::xqx:greaterThanOp">
         <xsl:text> </xsl:text><xsl:value-of select="$GREATERTHAN"/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:when test="self::xqx:lessThanOrEqualOp">
         <xsl:text> </xsl:text><xsl:value-of select="$LESSTHAN"/>
         <xsl:value-of select="$EQUAL"/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:when test="self::xqx:greaterThanOrEqualOp">
         <xsl:text> </xsl:text><xsl:value-of select="$GREATERTHAN"/>
         <xsl:value-of select="$EQUAL"/><xsl:text> </xsl:text>
       </xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:isOp | xqx:nodeBeforeOp | xqx:nodeAfterOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:isOp"><xsl:text> is </xsl:text></xsl:when>
       <xsl:when test="self::xqx:nodeBeforeOp"><xsl:text> </xsl:text>
         <xsl:value-of select="$LESSTHAN"/><xsl:value-of select="$LESSTHAN"/>
         <xsl:text> </xsl:text></xsl:when>
       <xsl:when test="self::xqx:nodeAfterOp"><xsl:text> </xsl:text>
         <xsl:value-of select="$GREATERTHAN"/><xsl:value-of select="$GREATERTHAN"/>
         <xsl:text> </xsl:text></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:andOp | xqx:orOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:andOp"><xsl:text> and </xsl:text></xsl:when>
       <xsl:when test="self::xqx:orOp"><xsl:text> or </xsl:text></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:unionOp | xqx:intersectOp | xqx:exceptOp">
    <xsl:value-of select="$LPAREN"/>
     <xsl:apply-templates select="xqx:firstOperand"/>
     <xsl:choose>
       <xsl:when test="self::xqx:unionOp"><xsl:text> union </xsl:text></xsl:when>
       <xsl:when test="self::xqx:intersectOp"><xsl:text> intersect </xsl:text></xsl:when>
       <xsl:when test="self::xqx:exceptOp"><xsl:text> except </xsl:text></xsl:when>
     </xsl:choose>
    <xsl:apply-templates select="xqx:secondOperand"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:sequenceExpr">
    <xsl:for-each select=".">
      <xsl:call-template name="parenthesizedList">
        <xsl:with-param name="delimiter" select="$COMMA_NEWLINE"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:rangeSequenceExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:startExpr"/>
    <xsl:value-of select="$TO"/>
    <xsl:apply-templates select="xqx:endExpr"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:forClause">
    <xsl:text> for </xsl:text>
    <xsl:call-template name="commaSeparatedList"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>

  <xsl:template match="xqx:forClauseItem">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xqx:allowingEmpty">
    <xsl:text> allowing empty </xsl:text>
  </xsl:template>

  <xsl:template match="xqx:forExpr">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>    in </xsl:text>
        <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="xqx:letClause">
    <xsl:text> let </xsl:text>
    <xsl:call-template name="commaSeparatedList"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>

  <xsl:template match="xqx:letClauseItem">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xqx:letExpr">
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$ASSIGN"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="xqx:windowClause">
    <xsl:text> for </xsl:text>
    <xsl:apply-templates/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>

  <xsl:template match="xqx:tumblingWindowClause">
    <xsl:text>   tumbling window </xsl:text>
    <xsl:apply-templates select="xqx:typedVariableBinding"/>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="xqx:bindingSequence"/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>      </xsl:text>
    <xsl:apply-templates select="xqx:windowStartCondition"/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>      </xsl:text>
    <xsl:apply-templates select="xqx:windowEndCondition"/>
  </xsl:template>

  <xsl:template match="xqx:slidingWindowClause">
    <xsl:text>   sliding window </xsl:text>
    <xsl:apply-templates select="xqx:typedVariableBinding"/>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="xqx:bindingSequence"/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>      </xsl:text>
    <xsl:apply-templates select="xqx:windowStartCondition"/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>      </xsl:text>
    <xsl:apply-templates select="xqx:windowEndCondition"/>
  </xsl:template>

  <xsl:template match="xqx:bindingSequence">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xqx:windowStartCondition">
    <xsl:text>start </xsl:text>
    <xsl:apply-templates select="xqx:windowVars"/>
    <xsl:text> when </xsl:text>
    <xsl:apply-templates select="xqx:winStartExpr"/>
  </xsl:template>

  <xsl:template match="xqx:windowEndCondition">
    <xsl:if test="@xqx:onlyEnd='true'">
      <xsl:text>only </xsl:text>
    </xsl:if>
    <xsl:text>end </xsl:text>
    <xsl:apply-templates select="xqx:windowVars"/>
    <xsl:text> when </xsl:text>
    <xsl:apply-templates select="xqx:winEndExpr"/>
  </xsl:template>

  <xsl:template match="xqx:windowVars">
    <xsl:apply-templates select="xqx:currentItem"/>
    <xsl:apply-templates select="xqx:positionalVariableBinding"/>
    <xsl:apply-templates select="xqx:previousItem"/>
    <xsl:apply-templates select="xqx:nextItem"/>
  </xsl:template>

  <xsl:template match="xqx:currentItem">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:call-template name="renderEQName"/>
  </xsl:template>

  <xsl:template match="xqx:previousItem">
    <xsl:text> previous </xsl:text>
    <xsl:value-of select="$DOLLAR"/>
    <xsl:call-template name="renderEQName"/>
  </xsl:template>

  <xsl:template match="xqx:nextItem">
    <xsl:text> next </xsl:text>
    <xsl:value-of select="$DOLLAR"/>
    <xsl:call-template name="renderEQName"/>
  </xsl:template>


  <xsl:template match="xqx:countClause">
    <xsl:text> count </xsl:text>
    <xsl:apply-templates/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:whereClause">
    <xsl:text> where </xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:groupByClause">
    <xsl:text>  group by </xsl:text>
    <xsl:call-template name="commaSeparatedList"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:groupingSpec">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="xqx:groupVarInitialize">
    <xsl:if test="xqx:typeDeclaration">
      <xsl:apply-templates select="xqx:typeDeclaration"/>
    </xsl:if>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$ASSIGN"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:varValue"/>
  </xsl:template>


  <xsl:template match="xqx:collation">
    <xsl:text> collation </xsl:text>
    <xsl:call-template name="quote">
      <xsl:with-param name="item">
        <xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:emptyOrderingMode">
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:orderingKind">
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:orderModifier">
    <xsl:apply-templates select="*"/>
  </xsl:template>


  <xsl:template match="xqx:orderBySpec">
    <xsl:apply-templates select="xqx:orderByExpr"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:orderModifier"/>
  </xsl:template>


  <xsl:template match="xqx:orderByClause">
    <xsl:if test="xqx:stable">
      <xsl:text> stable</xsl:text>
    </xsl:if>
    <xsl:text> order by </xsl:text>
    <xsl:apply-templates select="xqx:orderBySpec[1]"/>
    <xsl:for-each select="xqx:orderBySpec[position() > 1]">
      <xsl:value-of select="$COMMA_SPACE"/>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:returnClause">
    <xsl:text> return </xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


<!-- Surrounding FLWOR expressions with parentheses completes the set -->
  <xsl:template match="xqx:flworExpr">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:ifThenElseExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:text> if </xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:ifClause"/>
    <xsl:value-of select="$RPAREN"/>
    <xsl:text> then </xsl:text>
    <xsl:apply-templates select="xqx:thenClause"/>
    <xsl:text> else </xsl:text>
    <xsl:apply-templates select="xqx:elseClause"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:positionalVariableBinding">
    <xsl:text> at </xsl:text>
    <xsl:value-of select="$DOLLAR"/>
    <xsl:call-template name="renderEQName"/>
  </xsl:template>


  <xsl:template match="xqx:variableBinding">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:call-template name="renderEQName"/>
    <xsl:if test="parent::xqx:typeswitchExprCaseClause">
      <xsl:text> as </xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:typedVariableBinding" name="typedVariableBinding">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:apply-templates select="xqx:varName"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
  </xsl:template>


  <xsl:template match="xqx:quantifiedExprInClause">
    <xsl:apply-templates select="xqx:typedVariableBinding"/>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="xqx:sourceExpr"/>
  </xsl:template>


  <xsl:template match="xqx:quantifiedExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="xqx:quantifier"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:quantifiedExprInClause[1]"/>
    <xsl:for-each select="xqx:quantifiedExprInClause[position() > 1]">
      <xsl:value-of select="$COMMA_SPACE"/>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:text> satisfies </xsl:text>
    <xsl:apply-templates select="xqx:predicateExpr"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:instanceOfExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:text> instance of </xsl:text>
    <xsl:apply-templates select="xqx:sequenceType"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:castExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:text> cast as </xsl:text>
    <xsl:apply-templates select="xqx:singleType"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


<!-- 2015-02-11/JM For new expr arrowExpr -->
<!--/2016-11-01/JS Bug 29868 -->
  <xsl:template match="xqx:arrowExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:for-each select="*[not(self::xqx:argExpr) and not(self::xqx:arguments)]">
      <xsl:text> =&gt; </xsl:text>
      <xsl:choose>
        <xsl:when test="self::xqx:EQName or self::xqx:variableRef">
          <xsl:apply-templates select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$LPAREN"/>
          <xsl:apply-templates select="."/>
          <xsl:value-of select="$RPAREN"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="following-sibling::*[1][self::xqx:arguments]">
          <xsl:for-each select="following-sibling::*[1][self::xqx:arguments]">
            <xsl:call-template name="parenthesizedList"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$LPAREN"/>
          <xsl:value-of select="$RPAREN"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:castableExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:text> castable as </xsl:text>
    <xsl:apply-templates select="xqx:singleType"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:treatExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:text> treat as </xsl:text>
    <xsl:apply-templates select="xqx:sequenceType"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:switchExprCaseClause">
    <xsl:for-each select="xqx:switchCaseExpr">
      <xsl:value-of select="$NEWLINE"/>
      <xsl:text>   case (</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>) </xsl:text>
    </xsl:for-each>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>     return </xsl:text>
    <xsl:apply-templates select="xqx:resultExpr"/>
  </xsl:template>

  <xsl:template match="xqx:switchExprDefaultClause">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>   default return </xsl:text>
    <xsl:apply-templates select="xqx:resultExpr"/>
  </xsl:template>


  <xsl:template match="xqx:switchExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:text>switch</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:value-of select="$RPAREN"/>
    <xsl:apply-templates select="xqx:switchExprCaseClause"/>
    <xsl:apply-templates select="xqx:switchExprDefaultClause"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:typeswitchExprCaseClause">
    <xsl:text> case </xsl:text>
    <xsl:apply-templates select="xqx:variableBinding"/>
    <xsl:apply-templates select="xqx:sequenceType | xqx:sequenceTypeUnion"/>
    <xsl:text> return </xsl:text>
    <xsl:apply-templates select="xqx:resultExpr"/>
  </xsl:template>


  <xsl:template match="xqx:typeswitchExprDefaultClause">
    <xsl:text> default </xsl:text>
    <xsl:apply-templates select="xqx:variableBinding"/>
    <xsl:text> return </xsl:text>
    <xsl:apply-templates select="xqx:resultExpr"/>
  </xsl:template>


  <xsl:template match="xqx:typeswitchExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:text>typeswitch</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:value-of select="$RPAREN"/>
    <xsl:apply-templates select="xqx:typeswitchExprCaseClause"/>
    <xsl:apply-templates select="xqx:typeswitchExprDefaultClause"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:tryCatchExpr">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:value-of select="$LPAREN"/>
    <xsl:text>try </xsl:text>
    <xsl:apply-templates select="xqx:tryClause"/>
    <xsl:apply-templates select="xqx:catchClause"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:tryClause">
    <xsl:value-of select="$LBRACE"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:catchClause">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:text>  catch </xsl:text>
    <xsl:apply-templates select="xqx:catchErrorList"/>
    <xsl:apply-templates select="xqx:catchExpr"/>
  </xsl:template>


  <xsl:template match="xqx:catchErrorList">
    <xsl:for-each select="xqx:nameTest | xqx:Wildcard">
      <xsl:if test="(position() mod 5) = 0">
        <xsl:value-of select="$NEWLINE"/>
        <xsl:text>      </xsl:text>
      </xsl:if>
      <xsl:if test="position() > 1">
        <xsl:text>| </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
      <xsl:value-of select="$SPACE"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:catchExpr">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:validateExpr">
    <xsl:value-of select="$LPAREN"/>
    <xsl:text> validate </xsl:text>
    <xsl:if test="xqx:validationMode">
      <xsl:value-of select="xqx:validationMode"/>
      <xsl:value-of select="$SPACE"/>
    </xsl:if>
    <xsl:if test="xqx:typeName">
      <xsl:text>type </xsl:text>
      <xsl:apply-templates select="xqx:typeName"/>
      <xsl:value-of select="$SPACE"/>
    </xsl:if>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="xqx:argExpr"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:xpathAxis">
    <xsl:value-of select="."/>
    <xsl:value-of select="$DOUBLE_COLON"/>
  </xsl:template>


  <xsl:template match="xqx:predicates">
    <xsl:for-each select="*">
      <xsl:value-of select="$LBRACKET"/>
      <xsl:apply-templates select="."/>
      <xsl:value-of select="$RBRACKET"/>
    </xsl:for-each>
  </xsl:template>


<!-- 2014-07-13/JM Used in revised stepExpr to support new alternative lookup (formerly mapLookup) -->
  <xsl:template match="xqx:predicate">
    <xsl:value-of select="$LBRACKET"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$RBRACKET"/>
  </xsl:template>


  <!-- part of higher-order functions -->
  <xsl:template match="xqx:dynamicFunctionInvocationExpr">
    <xsl:apply-templates select="xqx:functionItem"/>
    <xsl:apply-templates select="xqx:predicates"/>
    <xsl:choose>
      <xsl:when test="xqx:arguments">
        <xsl:for-each select="xqx:arguments">
          <xsl:call-template name="parenthesizedList"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$LPAREN"/>
        <xsl:value-of select="$RPAREN"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- part of higher-order functions -->
  <xsl:template match="xqx:functionItem">
    <xsl:apply-templates/>
  </xsl:template>


<!-- 2014-07-13/JM Added mapConstructor                                                 -->
  <xsl:template match="xqx:mapConstructor">
     <xsl:text>map { </xsl:text>
     <xsl:apply-templates select="xqx:mapConstructorEntry[1]"/>
     <xsl:if test="xqx:mapConstructorEntry[2]">
       <xsl:for-each select="xqx:mapConstructorEntry[position() > 1]">
         <xsl:text> , </xsl:text>
         <xsl:apply-templates select="."/>
       </xsl:for-each>
     </xsl:if>
     <xsl:text> } </xsl:text>
  </xsl:template>

<!-- 2014-07-13/JM Added mapConstructorEntry                                            -->
  <xsl:template match="xqx:mapConstructorEntry">
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> : </xsl:text>
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>


<!-- 2014-07-13/JM Added arrayConstructor                                               -->
  <xsl:template match="xqx:arrayConstructor">
   <xsl:apply-templates/>
  </xsl:template>


<!-- 2014-07-13/JM Added squareArray                                                    -->
  <xsl:template match="xqx:squareArray">
    <xsl:text> [ </xsl:text>
    <xsl:apply-templates select="xqx:arrayElem[1]"/>
    <xsl:if test="xqx:arrayElem[2]">
      <xsl:for-each select="xqx:arrayElem[position() > 1]">
        <xsl:text> , </xsl:text>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:if>
    <xsl:text> ] </xsl:text>
  </xsl:template>


<!-- 2014-07-13/JM Added curlyArray                                                    -->
  <xsl:template match="xqx:curlyArray">
    <xsl:text> array { </xsl:text>
    <xsl:apply-templates/>
    <xsl:text> } </xsl:text>
  </xsl:template>

<!-- 2015-11-05/JS Added stringConstructor                                             -->
  <xsl:template match="xqx:stringConstructor">
    <xsl:text>``[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]``</xsl:text>
  </xsl:template>

<!-- 2015-11-05/JS Added stringConstructorInterpolation                                -->
  <xsl:template match="xqx:stringConstructorInterpolation">
    <xsl:text>`{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}`</xsl:text>
  </xsl:template>

<!-- 2015-11-05/JS Added stringConstructorChars                                        -->
  <xsl:template match="xqx:stringConstructorChars">
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:star">
    <xsl:value-of select="$STAR"/>
  </xsl:template>


  <xsl:template match="xqx:Wildcard[*]">
    <xsl:choose>
      <xsl:when test="local-name(./child::*[1])='star'">
        <xsl:apply-templates select="xqx:star"/>
        <xsl:value-of select="$COLON"/>
        <xsl:apply-templates select="xqx:NCName"/>
      </xsl:when>
      <xsl:when test="local-name(./child::*[1])='NCName'">
        <xsl:apply-templates select="xqx:NCName"/>
        <xsl:value-of select="$COLON"/>
        <xsl:apply-templates select="xqx:star"/>
      </xsl:when>
      <xsl:when test="local-name(./child::*[1])='uri'">
        <xsl:text>Q</xsl:text>
        <xsl:value-of select="$LBRACE"/>
        <xsl:value-of select="./xqx:uri"/>
        <xsl:value-of select="$RBRACE"/>
        <xsl:apply-templates select="xqx:star"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:Wildcard[not(*)]">
    <xsl:value-of select="$STAR"/>
  </xsl:template>


  <xsl:template name="simpleWildcard" match="xqx:simpleWildcard">
    <xsl:apply-templates select="xqx:star"/>
    <xsl:apply-templates select="xqx:QName"/>
  </xsl:template>


  <xsl:template match="xqx:textTest">
    <xsl:text>text()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:commentTest">
    <xsl:text>comment()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:namespaceTest">
    <xsl:text>namespace-node()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:anyKindTest">
    <xsl:text>node()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:piTest">
    <xsl:text>processing-instruction</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="*"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:documentTest">
    <xsl:text>document-node</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>

  <xsl:template match="xqx:nameTest">
    <xsl:call-template name="renderEQName"/>
  </xsl:template>


  <xsl:template match="xqx:attributeTest">
    <xsl:text>attribute</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:for-each select="xqx:attributeName">
      <xsl:call-template name="simpleWildcard"/>
    </xsl:for-each>
    <xsl:if test="xqx:typeName">
      <xsl:value-of select="$COMMA"/>
      <xsl:apply-templates select="xqx:typeName"/>
    </xsl:if>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:elementTest">
    <xsl:text>element</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:for-each select="xqx:elementName">
      <xsl:call-template name="simpleWildcard"/>
    </xsl:for-each>
    <xsl:if test="xqx:typeName">
      <xsl:value-of select="$COMMA"/>
      <xsl:apply-templates select="xqx:typeName"/>
    </xsl:if>
    <xsl:if test="xqx:nillable">
      <xsl:value-of select="$QUESTIONMARK"/>
    </xsl:if>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:schemaElementTest">
    <xsl:text>schema-element</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:call-template name="renderEQName"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <xsl:template match="xqx:schemaAttributeTest">
    <xsl:text>schema-attribute</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:call-template name="renderEQName"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <!-- anyFunctionTest, part of higher-order functions -->
  <xsl:template match="xqx:anyFunctionTest">
    <xsl:apply-templates select="xqx:annotation"/>
    <xsl:text> function</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="$STAR"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


  <!-- typedFunctionTest, part of higher-order functions -->
  <xsl:template match="xqx:typedFunctionTest">
    <xsl:apply-templates select="xqx:annotation"/>
    <xsl:text> function</xsl:text>
    <xsl:apply-templates select="xqx:paramTypeList"/>
    <xsl:text> as </xsl:text>
    <xsl:apply-templates select="xqx:sequenceType"/>
  </xsl:template>


  <xsl:template match="xqx:paramTypeList">
    <xsl:call-template name="parenthesizedList"/>
  </xsl:template>


<!-- 2014-07-11/JM For new MapTest -->
  <xsl:template match="xqx:anyMapTest">
    <xsl:text> map</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="$STAR"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


<!-- 2014-07-11/JM For new MapTest -->
  <xsl:template match="xqx:typedMapTest">
    <xsl:text> map(</xsl:text>
    <xsl:apply-templates select="xqx:atomicType"/>
    <xsl:text>, </xsl:text>
    <xsl:apply-templates select="xqx:sequenceType"/>
    <xsl:text>) </xsl:text>
  </xsl:template>


<!-- 2014-07-13/JM For new stepExpr alternative lookup (formerly mapLookup) -->
<!-- 2016-01-20/JS Add support for unaryLookup (bug 29364) -->
<!-- 2016-09-23/JS Bug 29823 - Renamed integerLiteral to integerConstantExpr  -->
  <xsl:template match="xqx:lookup | xqx:unaryLookup">
    <xsl:text> ?</xsl:text>
    <xsl:choose>
      <xsl:when test="xqx:star | xqx:NCName | xqx:integerConstantExpr">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$LPAREN"/>
        <xsl:apply-templates/>
	<xsl:value-of select="$RPAREN"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- 2014-07-11/JM For new ArrayTest -->
  <xsl:template match="xqx:anyArrayTest">
    <xsl:text> array</xsl:text>
    <xsl:value-of select="$LPAREN"/>
    <xsl:value-of select="$STAR"/>
    <xsl:value-of select="$RPAREN"/>
  </xsl:template>


<!-- 2014-07-11/JM For new ArrayTest -->
  <xsl:template match="xqx:typedArrayTest">
    <xsl:text> array(</xsl:text>
    <xsl:apply-templates select="xqx:sequenceType"/>
    <xsl:text>) </xsl:text>
  </xsl:template>


  <!-- parenthesizedItemType, part of higher-order functions -->
  <xsl:template match="xqx:parenthesizedItemType">
    <xsl:text> ( </xsl:text>
    <xsl:apply-templates/>
    <xsl:text> ) </xsl:text>
  </xsl:template>


  <xsl:template match="xqx:stepExpr">
    <xsl:if test="preceding-sibling::xqx:stepExpr">
      <xsl:value-of select="$SLASH"/>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>


  <xsl:template match="xqx:filterExpr">
    <xsl:apply-templates/>
  </xsl:template>


  <!-- part of higher-order functions -->
  <xsl:template match="xqx:namedFunctionRef">
    <xsl:if test="(xqx:functionName = 'node' or
                   xqx:functionName = 'document-node' or
                   xqx:functionName = 'element' or
                   xqx:functionName = 'attribute' or
                   xqx:functionName = 'schema-element' or
                   xqx:functionName = 'schema-attribute' or
                   xqx:functionName = 'processing-instruction' or
                   xqx:functionName = 'comment' or
                   xqx:functionName = 'text' or
                   xqx:functionName = 'function' or
                   xqx:functionName = 'namespace-node' or
                   xqx:functionName = 'item' or
                   xqx:functionName = 'if' or
                   xqx:functionName = 'switch' or
                   xqx:functionName = 'typeswitch' or
                   xqx:functionName = 'empty-sequence') and
                   ((not(@xqx:prefix) and not(@xqx:URI)) or
                    (@xqx:prefix and @xqx:prefix = '') or
                    (@xqx:URI and @xqx:URI = ''))">
      <xsl:variable name="message"><xsl:text>Incorrect XQueryX: function calls must not use unqualified "reserved" name "</xsl:text><xsl:value-of select="xqx:functionName"/><xsl:text>"</xsl:text></xsl:variable>
      <xsl:message terminate="yes"><xsl:value-of select="$message"/></xsl:message>
    </xsl:if>
    <xsl:apply-templates select="xqx:functionName"/>
    <xsl:text>#</xsl:text>
    <xsl:apply-templates select="xqx:integerConstantExpr"/>
  </xsl:template>

  <!-- part of higher-order functions -->
  <xsl:template match="xqx:inlineFunctionExpr">
    <xsl:apply-templates select="xqx:annotation"/>
    <xsl:text> function </xsl:text>
    <xsl:apply-templates select="xqx:paramList"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
    <xsl:apply-templates select="xqx:functionBody"/>
  </xsl:template>

  <xsl:template match="xqx:pathExpr">
    <xsl:apply-templates select="xqx:rootExpr | xqx:stepExpr"/>
  </xsl:template>


  <xsl:template match="xqx:attributeConstructor">
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:attributeName"/>
    <xsl:value-of select="$EQUAL"/>
    <xsl:choose>
      <xsl:when test="xqx:attributeValue">
        <xsl:call-template name="globalReplace">
          <xsl:with-param name="stringToBeFixed">
            <xsl:call-template name="globalReplace">
              <xsl:with-param name="stringToBeFixed">
                <xsl:call-template name="quote">
                  <xsl:with-param name="item">
                    <xsl:call-template name="globalReplace">
                      <xsl:with-param name="stringToBeFixed">
                        <xsl:call-template name="globalReplace">
                          <xsl:with-param name="stringToBeFixed">
                            <xsl:value-of select="xqx:attributeValue"/>
                          </xsl:with-param>
                          <xsl:with-param name="toBeReplaced"><xsl:text>{</xsl:text></xsl:with-param>
                          <xsl:with-param name="replacement"><xsl:text>{{</xsl:text></xsl:with-param>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="toBeReplaced"><xsl:text>}</xsl:text></xsl:with-param>
                      <xsl:with-param name="replacement"><xsl:text>}}</xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="toBeReplaced" select="'&#xA;'"/>
              <xsl:with-param name="replacement">&amp;#xA;</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="toBeReplaced" select="'&#x9;'"/>
          <xsl:with-param name="replacement">&amp;#x9;</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$DOUBLEQUOTE"/>
        <xsl:for-each select="./xqx:attributeValueExpr/xqx:*">
          <xsl:value-of select="$LBRACE"/>
            <xsl:apply-templates select="."/>
          <xsl:value-of select="$RBRACE"/>
        </xsl:for-each>
        <xsl:value-of select="$DOUBLEQUOTE"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:namespaceDeclaration">
    <xsl:text> xmlns</xsl:text>
    <xsl:if test="xqx:prefix">
      <xsl:text>:</xsl:text>
      <xsl:value-of select="xqx:prefix"/>
    </xsl:if>
    <xsl:value-of select="$EQUAL"/>
    <xsl:call-template name="quote">
       <xsl:with-param name="item">
         <xsl:call-template name="globalReplace">
           <xsl:with-param name="stringToBeFixed">
             <xsl:call-template name="globalReplace">
               <xsl:with-param name="stringToBeFixed">
                 <xsl:value-of select="xqx:uri"/>
               </xsl:with-param>
               <xsl:with-param name="toBeReplaced">
                 <xsl:text>{</xsl:text>
               </xsl:with-param>
               <xsl:with-param name="replacement">
                 <xsl:text>{{</xsl:text>
               </xsl:with-param>
             </xsl:call-template>
           </xsl:with-param>
           <xsl:with-param name="toBeReplaced">
             <xsl:text>}</xsl:text>
           </xsl:with-param>
           <xsl:with-param name="replacement">
             <xsl:text>}}</xsl:text>
           </xsl:with-param>
         </xsl:call-template>
       </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:attributeList">
    <xsl:apply-templates select="*"/>
  </xsl:template>


  <xsl:template match="xqx:elementContent">
    <xsl:for-each select="*">
      <xsl:if test="not(self::xqx:elementConstructor)">
        <xsl:value-of select="$SPACE"/>
        <xsl:value-of select="$LBRACE"/>
      </xsl:if>
      <xsl:apply-templates select="."/>
      <xsl:if test="not(self::xqx:elementConstructor)">
        <xsl:value-of select="$SPACE"/>
        <xsl:value-of select="$RBRACE"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:elementConstructor">
    <xsl:value-of select="$LESSTHAN"/>
    <xsl:apply-templates select="xqx:tagName"/>
    <xsl:apply-templates select="xqx:attributeList"/>
    <xsl:value-of select="$GREATERTHAN"/>
    <xsl:apply-templates select="xqx:elementContent"/>
    <xsl:value-of select="$LESSTHAN"/>
    <xsl:value-of select="$SLASH"/>
    <xsl:apply-templates select="xqx:tagName"/>
    <xsl:value-of select="$GREATERTHAN"/>
  </xsl:template>


  <xsl:template match="xqx:tagNameExpr">
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:computedElementConstructor">
    <xsl:text> element </xsl:text>
    <xsl:apply-templates select="xqx:tagName"/>
    <xsl:apply-templates select="xqx:tagNameExpr"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:apply-templates select="xqx:contentExpr"/>     
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:contentExpr">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xqx:computedAttributeConstructor">
    <xsl:text> attribute </xsl:text>
    <xsl:apply-templates select="xqx:tagName"/>
    <xsl:apply-templates select="xqx:tagNameExpr"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="xqx:valueExpr"/>     
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:computedDocumentConstructor">
    <xsl:text> document {</xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text> }</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:computedTextConstructor">
    <xsl:text> text</xsl:text>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:computedCommentConstructor">
    <xsl:text> comment</xsl:text>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:computedNamespaceConstructor">
    <xsl:text> namespace </xsl:text>
    <xsl:choose>
      <xsl:when test="xqx:prefix">
        <xsl:value-of select="xqx:prefix"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$LBRACE"/>
        <xsl:apply-templates select="xqx:prefixExpr"/>
        <xsl:value-of select="$RBRACE"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="xqx:URIExpr"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:piTargetExpr">
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:piValueExpr">
    <xsl:apply-templates select="*"/>
  </xsl:template>


  <xsl:template match="xqx:computedPIConstructor">
    <xsl:text> processing-instruction </xsl:text>
    <xsl:value-of select="xqx:piTarget"/>
    <xsl:apply-templates select="xqx:piTargetExpr"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:apply-templates select="xqx:piValueExpr"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:unorderedExpr">
    <xsl:text> unordered</xsl:text>
        <xsl:value-of select="$LBRACE"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:orderedExpr">
    <xsl:text> ordered</xsl:text>
        <xsl:value-of select="$LBRACE"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:versionDecl">
    <xsl:text>xquery </xsl:text>
    <xsl:if test="xqx:version">
      <xsl:text>version </xsl:text>
      <xsl:call-template name="quote">
        <xsl:with-param name="item" select="xqx:version"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="xqx:encoding and xqx:version">
      <xsl:value-of select="$SPACE"/>
    </xsl:if>
    <xsl:if test="xqx:encoding">
      <xsl:text>encoding </xsl:text>
      <xsl:call-template name="quote">
        <xsl:with-param name="item" select="xqx:encoding"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="$SEPARATOR"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:namespaceDecl">
    <xsl:text>declare namespace </xsl:text>
    <xsl:value-of select="xqx:prefix"/>
    <xsl:value-of select="$EQUAL"/>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:uri"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:defaultNamespaceDecl">
    <xsl:text>declare default </xsl:text>
    <xsl:value-of select="xqx:defaultNamespaceCategory"/>
    <xsl:text> namespace </xsl:text>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:uri"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:boundarySpaceDecl">
    <xsl:text>declare boundary-space </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:defaultCollationDecl">
    <xsl:text>declare default collation </xsl:text>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="."/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:baseUriDecl">
    <xsl:text>declare base-uri </xsl:text>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xqx:constructionDecl">
    <xsl:text>declare construction </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:orderingModeDecl">
    <xsl:text>declare ordering </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:emptyOrderingDecl">
    <xsl:text>declare default order </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:copyNamespacesDecl">
    <xsl:text>declare copy-namespaces </xsl:text>
    <xsl:value-of select="xqx:preserveMode"/>
    <xsl:value-of select="$COMMA"/>
    <xsl:value-of select="xqx:inheritMode"/>
  </xsl:template>


  <xsl:template match="xqx:optionDecl">
    <xsl:text>declare option </xsl:text>
    <xsl:apply-templates select="xqx:optionName"/>
    <xsl:value-of select="$SPACE"/>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:optionContents"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:decimalFormatDecl">
    <xsl:text>declare </xsl:text>
    <xsl:if test="not(xqx:decimalFormatName)">
      <xsl:text>default </xsl:text>
    </xsl:if>
    <xsl:text>decimal-format </xsl:text>
    <xsl:if test="xqx:decimalFormatName">
      <xsl:apply-templates select="xqx:decimalFormatName"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="xqx:decimalFormatParam"/>
  </xsl:template>


  <xsl:template match="xqx:decimalFormatParam">
    <xsl:value-of select="xqx:decimalFormatParamName"/>
    <xsl:text> = </xsl:text>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:decimalFormatParamValue"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
  </xsl:template>


  <xsl:template match="xqx:voidSequenceType">
    <xsl:text>empty-sequence()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:occurrenceIndicator">
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="xqx:anyItemType">
    <xsl:text>item()</xsl:text>
  </xsl:template>


  <xsl:template match="xqx:sequenceType">
    <xsl:apply-templates select="*"/>
  </xsl:template>


  <xsl:template match="xqx:sequenceTypeUnion">
    <xsl:apply-templates select="xqx:sequenceType[1]"/>
    <xsl:if test="count(xqx:sequenceType) > 1">
      <xsl:for-each select="xqx:sequenceType[position() > 1]">
        <xsl:text> | </xsl:text>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:singleType">
    <xsl:apply-templates select="xqx:atomicType"/>
    <xsl:if test="xqx:optional">
      <xsl:text>?</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:typeDeclaration">
    <xsl:text> as </xsl:text>
    <xsl:apply-templates select="*"/>
  </xsl:template>


<!-- contextItemDecl shouldn't have sequenceType, but itemType                         -->
  <xsl:template match="xqx:contextItemType">
    <xsl:text> as </xsl:text>
    <xsl:apply-templates select="*"/>
  </xsl:template>


<!-- contextItemDecl shouldn't have sequenceType, but itemType                         -->
  <xsl:template match="xqx:contextItemDecl">
    <xsl:text>declare context item </xsl:text>
    <xsl:apply-templates select="xqx:contextItemType"/>
    <xsl:if test="xqx:varValue">
      <xsl:value-of select="$SPACE"/>
      <xsl:value-of select="$ASSIGN"/>
      <xsl:value-of select="$SPACE"/>
      <xsl:apply-templates select="xqx:varValue"/>
    </xsl:if>
    <xsl:if test="xqx:external">
      <xsl:text> external </xsl:text>
      <xsl:if test="xqx:external/xqx:varValue">
        <xsl:text>:= </xsl:text>
        <xsl:apply-templates select="xqx:external/xqx:varValue"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:annotation">
    <xsl:value-of select="$SPACE"/>
    <xsl:value-of select="$PERCENT"/>
    <xsl:apply-templates select="xqx:annotationName"/>
    <xsl:if test="xqx:arguments">
      <xsl:for-each select="xqx:arguments">
         <xsl:call-template name="parenthesizedList"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:varDecl">
    <xsl:text>declare</xsl:text>
    <xsl:apply-templates select="xqx:annotation"/>
    <xsl:text> variable </xsl:text>
    <xsl:value-of select="$DOLLAR"/>
    <xsl:apply-templates select="xqx:varName"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
    <xsl:if test="xqx:varValue">
      <xsl:value-of select="$ASSIGN"/>
      <xsl:apply-templates select="xqx:varValue"/>
    </xsl:if>
    <xsl:if test="xqx:external">
      <xsl:text> external </xsl:text>
      <xsl:if test="xqx:external/xqx:varValue">
        <xsl:text>:= </xsl:text>
        <xsl:apply-templates select="xqx:external/xqx:varValue"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xqx:targetLocation">
    <xsl:choose>
      <xsl:when test="position()=1"> at </xsl:when>
      <xsl:otherwise>,&#xD;  </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="."/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="xqx:schemaImport">
    <xsl:text> import schema </xsl:text>
    <xsl:if test="xqx:defaultElementNamespace">
      <xsl:text> default element namespace </xsl:text>
    </xsl:if>
    <xsl:if test="xqx:namespacePrefix">
      <xsl:text> namespace </xsl:text>
      <xsl:value-of select="xqx:namespacePrefix"/>
      <xsl:value-of select="$EQUAL"/>
    </xsl:if>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:targetNamespace"/>
    </xsl:call-template>
    <xsl:apply-templates select="xqx:targetLocation"/>
  </xsl:template>


  <xsl:template match="xqx:moduleImport">
    <xsl:text> import module </xsl:text>
    <xsl:if test="xqx:namespacePrefix">
      <xsl:text> namespace </xsl:text>
      <xsl:value-of select="xqx:namespacePrefix"/>
      <xsl:value-of select="$EQUAL"/>
    </xsl:if>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:targetNamespace"/>
    </xsl:call-template>
    <xsl:apply-templates select="xqx:targetLocation"/>
  </xsl:template>


  <xsl:template match="xqx:param">
    <xsl:value-of select="$DOLLAR"/>
    <xsl:apply-templates select="xqx:varName"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
  </xsl:template>


  <xsl:template match="xqx:paramList">
    <xsl:call-template name="parenthesizedList"/>
  </xsl:template>


  <xsl:template match="xqx:functionBody">
    <xsl:value-of select="$NEWLINE"/>
    <xsl:value-of select="$LBRACE"/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$NEWLINE"/>
    <xsl:value-of select="$RBRACE"/>
  </xsl:template>


  <xsl:template match="xqx:functionDecl">
    <xsl:text>declare</xsl:text>
    <xsl:apply-templates select="xqx:annotation"/>
    <xsl:text> function </xsl:text>
    <xsl:apply-templates select="xqx:functionName"/>
    <xsl:apply-templates select="xqx:paramList"/>
    <xsl:apply-templates select="xqx:typeDeclaration"/>
    <xsl:choose>
      <xsl:when test="xqx:externalDefinition">
        <xsl:text> external </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="xqx:functionBody"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="xqx:queryBody">
    <xsl:apply-templates select="*"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>

  <xsl:template match="xqx:moduleDecl">
    <xsl:text> module namespace </xsl:text>
    <xsl:value-of select="xqx:prefix"/>
    <xsl:value-of select="$EQUAL"/>
    <xsl:call-template name="quote">
      <xsl:with-param name="item" select="xqx:uri" />
    </xsl:call-template>
    <xsl:value-of select="$SEPARATOR"/>
    <xsl:value-of select="$NEWLINE"/>
  </xsl:template>


  <xsl:template match="xqx:prolog">
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:value-of select="$SEPARATOR"/>
      <xsl:value-of select="$NEWLINE"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="xqx:libraryModule">
    <xsl:apply-templates select="xqx:moduleDecl"/>
    <xsl:apply-templates select="xqx:prolog"/>
  </xsl:template>


  <xsl:template match="xqx:mainModule">
    <xsl:apply-templates select="xqx:prolog"/>
    <xsl:apply-templates select="xqx:queryBody"/>
  </xsl:template>


<!-- Enhanced to properly support encoding parameter -->
  <xsl:template match="xqx:module" priority="2">
    <xsl:choose>
      <xsl:when test="xqx:versionDecl/xqx:encoding">
        <xsl:variable name="enc">
          <xsl:value-of select='xqx:versionDecl/xqx:encoding'/>
        </xsl:variable>
        <xsl:result-document encoding="{$enc}">
          <xsl:apply-templates select="*"/>
          <xsl:fallback>
            <xsl:apply-templates select="*"/>
          </xsl:fallback>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="/xqx:*">
   <xsl:message terminate="yes">Incorrect XQueryX: The only top-level element permitted is xqx:module</xsl:message>
  </xsl:template>


</xsl:stylesheet>
