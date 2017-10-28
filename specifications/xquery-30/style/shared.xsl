<?xml version="1.0" encoding="utf-8"?>
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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">
  
  <xsl:import href="../../../style/xmlspec-override.xsl"/> 

  <xsl:param name="spec" select="'xpath'"/>

  <xsl:param name="additional.css">
    <style type="text/css">
.wsspec      { font-family: monospace; font-size: small; font-style: italic }      
<xsl:if test="$spec='shared'">
  <xsl:text>
.xpath         { color: red; background-color: white }
.xquery      { color: green; background-color: white }

.xpath:link { color: red; background-color: white }
.xpath:visited { color: red; background-color: white }

.shared:link { color: black; background-color: white }
.shared:visited { color: black; background-color: white }

.xquery:link { color: green; background-color: white }
.xquery:visited { color: green; background-color: white }

  </xsl:text>
</xsl:if>

    </style>
  </xsl:param>

  <xsl:param name="additional.css.2"/>

  <xsl:output method="xml" encoding="utf-8"/>

  <!-- xsl:param name="spec" select="shared"/ -->

  
<!-- Generate a comment that identifies as much as we can about the XSLT processor being used -->
  <xsl:template match="/">
    <xsl:variable name="XSLTprocessor">
      <xsl:text>{shared.xsl} </xsl:text>
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
    <xsl:comment> ($show.diff.markup = <xsl:value-of select="$show.diff.markup"/>)</xsl:comment>
-->
    <xsl:apply-templates/>
  </xsl:template> 

  <!--========= Overridden Templates of XPath2.xsl ========== -->

  <xsl:template mode="toc" match="*">
    <xsl:choose>
      <xsl:when test="not($spec='shared') and @role and not(@role=$spec)">
        <!-- suppress -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--
  <xsl:template mode="toc" match="*[not($spec='shared') and @role and not(@role=$spec)]">
  </xsl:template>
-->

  <!--========= End Overridden Templates of XPath2.xsl ========== --> 

  <!-- blist: list of bibliographic entries -->
  <!-- set up the list and process children -->
  <xsl:template match="blist">
    <dl>
      <xsl:apply-templates select="*">
        <xsl:sort select="@key"/>
      </xsl:apply-templates>
    </dl>
  </xsl:template>

  <xsl:template match="rhs-group">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Added hack to avoid processing of specref by this template. -sb -->
  <xsl:template match="*[(@role='xpath' or @role='xquery') 
                       and not(local-name(.)='specref')]" priority="20">

    <xsl:variable name="role" select="@role"/>

    <!-- Transform the source node and bind the result to $r. -->
    <xsl:variable name="r" as="node()*">
      <xsl:apply-imports/>
    </xsl:variable>

    <!-- Ensure that the result is marked with class="$role". -->
    <xsl:choose>
      <xsl:when test="$r/self::text()[matches(., '\S')]">
        <!--
          One or more of the (top-level) nodes in $r
          is a non-empty non-whitespace text node.
          We could either create a <span> for each such text node,
          or create a <span> for the whole result-sequence.
          I think the latter is more often the better choice.
        -->
        <span class="{$role}">
          <xsl:copy-of select="$r"/>
        </span>
      </xsl:when>

      <xsl:otherwise>
        <!--
          Any (top-level) text nodes in $r are whitespace,
          so they probably don't need to be marked with class=$role.
          So we only have to worry about (top-level) element nodes.
          Ensure that each one has class=$role.
        -->
        <xsl:for-each select="$r">
          <xsl:copy>
            <xsl:attribute name='class'>
              <xsl:choose>

                <xsl:when test="not(@class)">
                  <!-- Node doesn't have a class attr. -->
                  <xsl:value-of select="$role"/>
                </xsl:when>

                <xsl:otherwise>
                  <!-- Node already has a class attr. -->
                  <!-- Check whether its value already contains $role. -->
                  <xsl:choose>
                    <xsl:when test="tokenize(@class, '\s+') = $role">
                      <!-- It does, so just copy the current value. -->
                      <xsl:value-of select="@class"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- It doesn't, so add $role to the current value. -->
                      <xsl:value-of select="concat($role, ' ', @class)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>

            <!--
              And then copy over all the other attributes,
              and all the child nodes.
            -->
            <xsl:copy-of select="@*[name(.) != 'class'] | node()"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- xnt: external non-terminal -->
  <!-- xspecref: external specification reference -->
  <!-- xtermref: external term reference -->
  <!-- just link to URI provided -->
  <!-- xsl:template match="xspecref">
    <a href="{@href}">
      <xsl:if test="@id">
        <xsl:attribute name="name">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </a>
  </xsl:template -->

  <!-- nt: production non-terminal -->
  <!-- make a link to the non-terminal's definition -->
  <xsl:template match="prod//nt" priority="40000">
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="target" select="key('ids', @def)"/>
        </xsl:call-template>
      </xsl:attribute> 
      <xsl:variable name="role" select="ancestor-or-self::*[@role='xpath' 
                                        or @role='xquery'][1]/@role"/>
      <xsl:if test="$role">
        <xsl:attribute name="class">
          <xsl:value-of select="$role"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </a>
  </xsl:template>


<xsl:template match="errorref">
  <xsl:variable name="error" select="key('error', concat(@class,@code))"/>

  <xsl:choose>
    <xsl:when test="$error">
      <!-- hack fix for apply-imports param problem -->
      <xsl:for-each select="$error[1]">
        <xsl:call-template name="make-error-ref"/>
      </xsl:for-each>
     </xsl:when>
    <xsl:otherwise>
      <xsl:message>Warning: Error <xsl:value-of select="@code"/> not found.</xsl:message>
      <xsl:text>[ERROR </xsl:text>
      <xsl:value-of select="@code"/>
      <xsl:text> NOT FOUND]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
