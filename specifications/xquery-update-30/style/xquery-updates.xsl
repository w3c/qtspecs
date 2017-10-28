<?xml version="1.0"?>

<!--
 * Copyright (c) 2002 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:rddl="http://www.rddl.org/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="exsl rddl xlink"
                version="1.0">

<xsl:import href="../../../style/xmlspec-override.xsl"/>

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

<!-- Override proto and arg to print XQuery F/O-style prototypes -->

<xsl:template match="proto">
  <xsl:variable name="prefix">
    <xsl:choose>
      <xsl:when test="@isOp='yes'">op:</xsl:when>
      <xsl:when test="@isSchema='yes'">xs:</xsl:when>
      <xsl:when test="@isDatatype='yes'">xdt:</xsl:when>
      <xsl:when test="@isSpecial='yes'"></xsl:when>
      <xsl:otherwise>fn:</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="stringvalue">
    <xsl:apply-templates select="." mode="stringify"/>
  </xsl:variable>

  <!-- If the prototype is going to be "too long", use a tabular presentation -->

  <div class="proto">
    <xsl:choose>
      <xsl:when test="string-length($stringvalue) &gt; 70">
	<table border="0" cellpadding="0" cellspacing="0"
	       summary="Function/operator prototype">
	  <tr>
            <td valign="baseline">
              <xsl:if test="count(arg) &gt; 1">
                <xsl:attribute name="rowspan">
                  <xsl:value-of select="count(arg)"/>
                </xsl:attribute>
              </xsl:if>

              <code class="function">
                <xsl:value-of select="$prefix"/>
                <xsl:value-of select="@name"/>
              </code>
              <xsl:text>(</xsl:text>
            </td>

            <xsl:choose>
              <xsl:when test="arg">
                <xsl:apply-templates select="arg[1]" mode="tabular"/>
              </xsl:when>
              <xsl:otherwise>
                <td valign="baseline">
                  <xsl:text>)</xsl:text>
                  <xsl:if test="@return-type != 'nil'">
                    <code class="as">&#160;as&#160;</code>
                    <xsl:choose>
                      <xsl:when test="@returnVaries = 'yes'">
                        <code class="return-varies">
                          <xsl:value-of select="@return-type"/>
                          <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                        </code>
                      </xsl:when>
                      <xsl:otherwise>
                        <code class="return-type">
                          <xsl:value-of select="@return-type"/>
                          <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                        </code>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </td>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
          <xsl:for-each select="arg[position() &gt; 1]">
            <tr>
              <xsl:apply-templates select="." mode="tabular"/>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:when>

      <xsl:otherwise>
        <code class="function">
          <xsl:value-of select="$prefix"/>
          <xsl:value-of select="@name"/>
        </code>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
        <xsl:if test="@return-type != 'nil'">
          <code class="as">&#160;as&#160;</code>
          <xsl:choose>
            <xsl:when test="@returnVaries = 'yes'">
              <code class="return-varies">
                <xsl:value-of select="@return-type"/>
                <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
              </code>
            </xsl:when>
            <xsl:otherwise>
              <code class="return-type">
                <xsl:value-of select="@return-type"/>
                <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
              </code>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="arg">
  <xsl:if test="preceding-sibling::arg">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@name = '...'">
      <span class="varargs">...</span>
    </xsl:when>
    <xsl:otherwise>
      <code class="arg">$<xsl:value-of select="@name"/></code>
      <code class="as">&#160;as&#160;</code>
      <code class="type">
        <xsl:value-of select="@type"/>
        <xsl:if test="@emptyOk='yes'">?</xsl:if>
      </code>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="arg" mode="tabular">
  <td valign="baseline">
    <xsl:choose>
      <xsl:when test="@name = '...'">
        <span class="varargs">...</span>
      </xsl:when>
      <xsl:otherwise>
        <code class="arg">$<xsl:value-of select="@name"/></code>
      </xsl:otherwise>
    </xsl:choose>
  </td>

  <td valign="baseline">
    <xsl:if test="@name != '...'">
      <code class="as">&#160;as&#160;</code>
      <code class="type">
        <xsl:value-of select="@type"/>
        <xsl:if test="@emptyOk='yes'">?</xsl:if>
      </code>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="following-sibling::arg">
        <xsl:text>,</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>)</xsl:text>
	<code class="as">&#160;as&#160;</code>
	<xsl:choose>
	  <xsl:when test="parent::proto/@returnVaries = 'yes'">
	    <code class="return-varies">
	      <xsl:value-of select="parent::proto/@return-type"/>
	      <xsl:if test="parent::proto/@returnEmptyOk='yes'">?</xsl:if>
	    </code>
	  </xsl:when>
	  <xsl:otherwise>
	    <code class="return-type">
	      <xsl:value-of select="parent::proto/@return-type"/>
	      <xsl:if test="parent::proto/@returnEmptyOk='yes'">?</xsl:if>
	    </code>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </td>
</xsl:template>

<xsl:template match="proto" mode="stringify">
  <xsl:value-of select="@name"/>
  <xsl:text>(</xsl:text>
  <xsl:apply-templates mode="stringify"/>
  <xsl:text>)</xsl:text>
  <code class="as">&#160;as&#160;</code>
  <xsl:value-of select="@return-type"/>
</xsl:template>

<xsl:template match="arg" mode="stringify">
  <xsl:if test="preceding-sibling::arg">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:value-of select="@type"/>
  <xsl:text> $</xsl:text>
  <xsl:value-of select="@name"/>
</xsl:template>

</xsl:stylesheet>


<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->