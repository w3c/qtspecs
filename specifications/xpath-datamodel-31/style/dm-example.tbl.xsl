<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
  <table>
    <tbody>
      <xsl:apply-templates select="node()"/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="text()"/>

<xsl:template match="document">
  <tr role="document" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Document node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="document">
    <td>dm:base-uri(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="//base-uri[1]"/></td>
  </tr>
  <tr role="document">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"document"</td>
  </tr>
  <tr role="document">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="document">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td>xs:untypedAtomic(<xsl:call-template name="value"/>)</td>
  </tr>
  <tr role="document">
    <td>dm:children(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="*[self::element or self::text or self::processing-instruction or self::comment]">
        <xsl:if test="position() &gt; 1">, </xsl:if>
        <xsl:text>[</xsl:text>
        <loc href="#ex-{@label}">
          <xsl:value-of select="@label"/>
        </loc>
        <xsl:text>]</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="element">
  <tr role="element" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Element node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="element">
    <td>dm:base-uri(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="//base-uri[1]"/></td>
  </tr>
  <tr role="element">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"element"</td>
  </tr>
  <tr role="element">
    <td>dm:node-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
        <xsl:when test="not(contains(@name, ':'))">
          <xsl:text>xs:QName("http://www.example.com/catalog", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'html'">
          <xsl:text>xs:QName("http://www.w3.org/1999/xhtml", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xlink'">
          <xsl:text>xs:QName("http://www.w3.org/1999/xlink", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xsi'">
          <xsl:text>xs:QName("http://www.w3.org/2001/XMLSchema-instance", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xml'">
          <xsl:text>xs:QName("http://www.w3.org/XML/1998/namespace", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Unexpected prefix: <xsl:value-of select="@name"/>!!!</xsl:message>
          <xsl:text>???</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
  <tr role="element">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>

  <xsl:if test="typed-value/@comment">
    <tr role="element">
      <td colspan="3">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="typed-value/@comment"/>
      </td>
    </tr>
  </xsl:if>
  <tr role="element">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>

    <td>    
      <xsl:choose>
	<xsl:when test="typed-value = 'xs:untypedAtomic(dm:string-value())'">
	  <xsl:text>xs:untypedAtomic(</xsl:text>
	  <xsl:call-template name="value"/>
	  <xsl:text>)</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="typed-value"/>
	</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>

  <xsl:if test="type/@comment">
    <tr role="element">
      <td colspan="3">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="type/@comment"/>
      </td>
    </tr>
  </xsl:if>

  <tr role="element">
    <td>dm:type-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="type"/></td>
  </tr>

  <tr role="element">
    <td>dm:is-id(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
	<xsl:when test="is-id"><xsl:value-of select="is-id"/></xsl:when>
	<xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>

  <tr role="element">
    <td>dm:is-idrefs(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
	<xsl:when test="is-idrefs"><xsl:value-of select="is-idrefs"/></xsl:when>
	<xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>

  <tr role="element">
    <td>dm:parent(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>([</xsl:text>
      <loc href="#ex-{parent::*/@label}">
        <xsl:value-of select="parent::*/@label"/>
      </loc>
      <xsl:text>])</xsl:text>
    </td>
  </tr>
  <tr role="element">
    <td>dm:children(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="*[self::element or self::text or self::processing-instruction or self::comment]">
        <xsl:if test="position() &gt; 1">, </xsl:if>
        <xsl:text>[</xsl:text>
        <loc href="#ex-{@label}">
          <xsl:value-of select="@label"/>
        </loc>
        <xsl:text>]</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </td>
  </tr>
  <tr role="element">
    <td>dm:attributes(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="attribute">
        <xsl:if test="position() &gt; 1">, </xsl:if>
        <xsl:text>[</xsl:text>
        <loc href="#ex-{@label}">
          <xsl:value-of select="@label"/>
        </loc>
        <xsl:text>]</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </td>
  </tr>
  <tr role="element">
    <td>dm:namespace-nodes(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="/document/namespace">
        <xsl:if test="position() &gt; 1">, </xsl:if>
        <xsl:text>[</xsl:text>
        <loc href="#ex-{@label}">
          <xsl:value-of select="@label"/>
        </loc>
        <xsl:text>]</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </td>
  </tr>
  <tr role="element">
    <td>dm:namespace-bindings(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="/document/namespace">
        <xsl:if test="position() &gt; 1">, </xsl:if>
        <xsl:text>"</xsl:text>
	<xsl:value-of select="@name"/>
        <xsl:text>",&#160;"</xsl:text>
	<xsl:value-of select="./value"/>
        <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="attribute">
  <tr role="attribute" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Attribute node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="attribute">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"attribute"</td>
  </tr>
  <tr role="attribute">
    <td>dm:node-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
        <xsl:when test="not(contains(@name, ':'))">
          <xsl:text>xs:QName("", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'html'">
          <xsl:text>xs:QName("http://www.w3.org/1999/xhtml", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xlink'">
          <xsl:text>xs:QName("http://www.w3.org/1999/xlink", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xsi'">
          <xsl:text>xs:QName("http://www.w3.org/2001/XMLSchema-instance", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:when test="substring-before(@name, ':') = 'xml'">
          <xsl:text>xs:QName("http://www.w3.org/XML/1998/namespace", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Unexpected prefix: <xsl:value-of select="@name"/>!!!</xsl:message>
          <xsl:text>???</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
  <tr role="attribute">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="attribute">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="typed-value"/></td>
  </tr>
  <tr role="attribute">
    <td>dm:type-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="type"/></td>
  </tr>

  <tr role="attribute">
    <td>dm:is-id(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
	<xsl:when test="is-id"><xsl:value-of select="is-id"/></xsl:when>
	<xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>

  <tr role="attribute">
    <td>dm:is-idrefs(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
	<xsl:when test="is-idrefs"><xsl:value-of select="is-idrefs"/></xsl:when>
	<xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>

  <tr role="attribute">
    <td>dm:parent(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>([</xsl:text>
      <loc href="#ex-{parent::*/@label}">
        <xsl:value-of select="parent::*/@label"/>
      </loc>
      <xsl:text>])</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
</xsl:template>

<xsl:template match="namespace">
  <tr role="namespace" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Namespace node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="namespace">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"namespace"</td>
  </tr>
  <tr role="namespace">
    <td>dm:node-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:choose>
        <xsl:when test="@name != ''">
          <xsl:text>xs:QName("", "</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>")</xsl:text>
        </xsl:when>
        <xsl:otherwise>()</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
  <tr role="namespace">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="namespace">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
</xsl:template>

<xsl:template match="text">
  <tr role="text" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Text node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="text">
    <td>dm:base-uri(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="//base-uri[1]"/></td>
  </tr>
  <tr role="text">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"text"</td>
  </tr>
  <tr role="text">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="text">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>xs:untypedAtomic(<xsl:call-template name="value"/>)</td>
  </tr>
  <tr role="text">
    <td>dm:type-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>xs:untypedAtomic</td>
  </tr>
  <tr role="text">
    <td>dm:parent(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>([</xsl:text>
      <loc href="#ex-{parent::*/@label}">
        <xsl:value-of select="parent::*/@label"/>
      </loc>
      <xsl:text>])</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
</xsl:template>

<!-- BIZARRE syntax error for "processing-instruction" w/o the predicate -->
<xsl:template match="processing-instruction[true()]">
  <tr id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Processing Instruction node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:base-uri(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="//base-uri[1]"/></td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"processing-instruction"</td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:node-name(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>xs:QName("", "</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>")</xsl:text>
    </td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="processing-instruction">
    <td>dm:parent(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>([</xsl:text>
      <loc href="#ex-{parent::*/@label}">
        <xsl:value-of select="parent::*/@label"/>
      </loc>
      <xsl:text>])</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
</xsl:template>

<xsl:template match="comment">
  <tr role="comment" id="ex-{@label}">
    <td colspan="3">
      <xsl:text>// Comment node </xsl:text>
      <xsl:value-of select="@label"/>
    </td>
  </tr>
  <tr role="comment">
    <td>dm:base-uri(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:value-of select="//base-uri[1]"/></td>
  </tr>
  <tr role="comment">
    <td>dm:node-kind(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>"comment"</td>
  </tr>
  <tr role="comment">
    <td>dm:string-value(<xsl:value-of select="@label"/>)</td>
    <td>=</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="comment">
    <td>dm:typed-value(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td><xsl:call-template name="value"/></td>
  </tr>
  <tr role="comment">
    <td>dm:parent(<xsl:value-of select="@label"/>)</td>
    <td> =&#160;</td>
    <td>
      <xsl:text>([</xsl:text>
      <loc href="#ex-{parent::*/@label}">
        <xsl:value-of select="parent::*/@label"/>
      </loc>
      <xsl:text>])</xsl:text>
    </td>
  </tr>
  <tr>
    <td colspan="3">&#160;</td>
  </tr>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="value">
  <xsl:text>"</xsl:text>
  <xsl:call-template name="string.subst">
    <xsl:with-param name="string" select="value"/>
    <xsl:with-param name="target" select="' '"/>
    <xsl:with-param name="replacement" select="'&#160; '"/>
  </xsl:call-template>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template name="string.subst">
  <xsl:param name="string"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>

  <xsl:choose>
    <xsl:when test="contains($string, $target)">
      <xsl:variable name="rest">
        <xsl:call-template name="string.subst">
          <xsl:with-param name="string" select="substring-after($string, $target)"/>
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="replacement" select="$replacement"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="concat(substring-before($string, $target),                                    $replacement,                                    $rest)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
