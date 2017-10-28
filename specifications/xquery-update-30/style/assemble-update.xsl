<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="g xlink">

  <xsl:import href="../../../style/assemble-spec.xsl"/>

  <xsl:output method="xml" indent="no"
              doctype-system="../../../schema/xsl-query.dtd" />

  <xsl:param name="show.diff.markup" select="0"/>

<!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{assemble-update} </xsl:text>
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
<!--
    <xsl:comment>$show.diff.markup = <xsl:value-of select="$show.diff.markup"/></xsl:comment>
    <xsl:message>$show.diff.markup = <xsl:value-of select="$show.diff.markup"/></xsl:message>
-->
    <xsl:apply-templates/>
  </xsl:template> 

<xsl:template match="*[@diff]">
    <xsl:choose>
        <xsl:when test="$show.diff.markup = 0">
            <!--
                "Execute" the diff markup
                (carry out the edits that it indicates)
                so that no evidence of it exists in the result document.
            -->
            <xsl:choose>

                <xsl:when test="@diff='del'">
                    <!--
                        Ignore the current node.
                        (i.e., it has no effect on the result doc)
                    -->
                </xsl:when>

                <xsl:when test="self::phrase[empty(@*[name(.) != 'diff' and name(.) != 'at'])]">
                    <!--
                        (A <phrase> with no attributes other than 'diff' or 'at'.)
                        The current node was created solely as a hanger for diff attributes.
                        Transform its children, without a container element.
                    -->
                    <xsl:apply-templates select='node()'/>
                </xsl:when>

                <xsl:otherwise>
                    <!--
                        The current node has some semantics other than being a hanger for diff attrs.
                        Transform it according to the imported rules.
                        But those rules might copy over the diff attrs,
                        which we don't want, so make a copy of that without the diff attrs.
                        (Would make more sense to remove the diff attrs from the thing that
                        the imported rules operate on, but I'm not sure that's possible.)
                    -->
                    <xsl:variable name='x' as='node()*'>
                        <xsl:apply-imports/>
                    </xsl:variable>
                    <xsl:for-each select="$x">
                        <xsl:copy>
                            <xsl:copy-of select="@*[name(.) != 'diff' and name(.) != 'at'] | node()"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
            <!--
                $show.diff.markup != 0:

                A later stage will put markup in the result document
                so that the nature of the diffs is made visible.
                (I.e., highlight the edits via styling).
                (See xquery-semantics-diff.xsl.)

                At this stage (assemble), we don't do anything special with @diff or @at.
            -->
            <xsl:apply-imports/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

  <xsl:template name="construct-gn-link">
    <xsl:param name="string"/>
    <xsl:param name="spec" select="/g:grammar/g:language/@id"/>
    <xsl:param name="label" select="'gn: '"/>
    <xsl:param name="link-prefix" select="'parse-note-'"/>
    <com>
      <phrase><xspecref ref="{$link-prefix}{$string}">
        <xsl:attribute name="spec">
          <xsl:choose>
            <xsl:when test="$spec='xpath'">
              <xsl:text>XP</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>XQ</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="$label"/>
        <xsl:value-of select="$string"/>
      </xspecref></phrase>
    </com>
    
  </xsl:template>

  <xsl:template name="do-whitespace-comment">
    <xsl:call-template name="construct-gn-link">
      <xsl:with-param name="string" select="@whitespace-spec"/>
      <xsl:with-param name="label" select="'ws: '"/>
      <xsl:with-param name="link-prefix" select="'ws-'"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Try and apply a space delimited list of references to tokens. -->
  <xsl:template name="apply-gns">
    <xsl:param name="string" select="''"/>
    <xsl:param name="delimiter" select="' '"/>
    <xsl:param name="count" select="0"/>
    <xsl:param name="is-xgc" select="false()"/>

    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:variable name="token" select="substring-before($string, $delimiter)"/>
        <xsl:call-template name="construct-gn-link">
          <xsl:with-param name="string" select="$token"/>
        </xsl:call-template>
        <xsl:call-template name="apply-gns">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="construct-gn-link">
          <xsl:with-param name="string" select="$string"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
