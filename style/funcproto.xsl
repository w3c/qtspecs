<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
                
<xsl:template name="get-prefix">
    <!-- overridden in F+O specification -->
    <xsl:choose>
      <xsl:when test="@class = 'op'">op:</xsl:when>
      <xsl:when test="@class = 'schema'">xs:</xsl:when>
      <xsl:when test="@class = 'func'">fn:</xsl:when>
      <xsl:when test="@class = 'dm'"><span class="prefix">dm:</span></xsl:when>
      <xsl:otherwise>??:</xsl:otherwise>
    </xsl:choose>
</xsl:template>                

<!-- Override proto and arg to print XQuery F/O-style prototypes -->

<xsl:template match="proto">
  <xsl:variable name="prefix">
    <xsl:call-template name="get-prefix"/>
  </xsl:variable>

  <xsl:variable name="stringvalue">
    <xsl:apply-templates select="." mode="stringify"/>
  </xsl:variable>

  <!-- If the prototype is going to be "too long", use a tabular presentation -->

  <div class="proto">
    <xsl:choose>
      <xsl:when test="string-length($stringvalue) &gt; 70">
        <table>
          <tr>
            <td>
              <xsl:if test="count(arg) &gt; 1">
                <xsl:attribute name="rowspan">
                  <xsl:value-of select="count(arg)"/>
                </xsl:attribute>
              </xsl:if>

              <code class="function">
                <xsl:copy-of select="$prefix"/>
                <xsl:value-of select="@name"/>
              </code>
              <xsl:text>(</xsl:text>
            </td>

            <xsl:choose>
              <xsl:when test="arg">
                <xsl:apply-templates select="arg[1]" mode="tabular"/>
              </xsl:when>
              <xsl:otherwise>
                <td>
                  <xsl:text>)</xsl:text>

                  <xsl:if test="@return-type != 'none'">
                    <code class="as">&#160;as&#160;</code>
                    <code class="return-type">
                      <xsl:choose>
                        <xsl:when test="id(@return-type)">
                          <a>
                            <xsl:attribute name="href">
                              <xsl:call-template name="href.target">
                                <xsl:with-param name="target"
                                                select="id(@return-type)"/>
                              </xsl:call-template>
                            </xsl:attribute>
                            <xsl:value-of select="@return-type"/>
                          </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="@return-type"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                      <xsl:if test="@returnSeq='yes'">*</xsl:if>
                    </code>
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
          <xsl:copy-of select="$prefix"/>
          <xsl:value-of select="@name"/>
        </code>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
        <xsl:if test="@return-type != 'none'">
          <code class="as">&#160;as&#160;</code>
          <code class="return-type">
            <xsl:choose>
              <xsl:when test="id(@return-type)">
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="target"
                                      select="id(@return-type)"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:value-of select="@return-type"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@return-type"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
            <xsl:if test="@returnSeq='yes'">*</xsl:if>
          </code>
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
        <xsl:choose>
          <xsl:when test="id(@type)">
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="target"
                                  select="id(@type)"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:value-of select="@type"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@seq = 'yes'">
            <xsl:choose>
              <xsl:when test="@emptyOk='yes'">*</xsl:when>
              <xsl:otherwise>+</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="@emptyOk='yes'">?</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </code>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="arg" mode="tabular">
  <td >
    <xsl:choose>
      <xsl:when test="@name = '...'">
        <span class="varargs">...</span>
      </xsl:when>
      <xsl:otherwise>
        <code class="arg">$<xsl:value-of select="@name"/></code>
      </xsl:otherwise>
    </xsl:choose>
  </td>

  <td>
    <xsl:if test="@name != '...'">
      <code class="as">&#160;as&#160;</code>
      <code class="type">
        <xsl:choose>
          <xsl:when test="id(@type)">
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="target"
                                  select="id(@type)"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:value-of select="@type"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@seq = 'yes'">
            <xsl:choose>
              <xsl:when test="@emptyOk='yes'">*</xsl:when>
              <xsl:otherwise>+</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="@emptyOk='yes'">?</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </code>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="following-sibling::arg">
        <xsl:text>,</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>)</xsl:text>
        <xsl:if test="parent::proto/@return-type != 'none'">
          <code class="as">&#160;as&#160;</code>
          <code class="return-type">
            <xsl:choose>
              <xsl:when test="id(parent::proto/@return-type)">
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="target"
                                      select="id(parent::proto/@return-type)"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:value-of select="parent::proto/@return-type"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="parent::proto/@return-type"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="parent::proto/@returnEmptyOk='yes'">?</xsl:if>
            <xsl:if test="parent::proto/@returnSeq='yes'">*</xsl:if>
          </code>
        </xsl:if>
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
  <xsl:choose>
    <xsl:when test="id(@type)">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="target"
                            select="id(@type)"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:value-of select="@type"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@type"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text> $</xsl:text>
  <xsl:value-of select="@name"/>
</xsl:template>

<!-- Pretty print function signatures -->
<xsl:template match="example[@role='signature']">
  <div class="exampleInner">
    <xsl:apply-templates/>
  </div>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->
