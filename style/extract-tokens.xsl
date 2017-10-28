<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:g="http://www.w3.org/2001/03/XPath/grammar"
  xmlns:xalan="http://xml.apache.org/xslt"
  exclude-result-prefixes="g xalan">

  <xsl:param name="spec" select="'xpath'"/>
  <xsl:param name="grammar-file" select="'xpath-grammar.xml'"/>
  <xsl:variable name="sourceTree" select="/"/>

  <xsl:output method="xml" indent="yes"/>

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
    <token-list>
      <xsl:call-template name="show-dt"/>
    </token-list>
  </xsl:template>

  <xsl:variable name="nd-chars"  select= "'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'"/>
  <xsl:variable name="syms">[]{}!@#$%^&amp;*()_+=-/\.,&lt;&gt;?:;|</xsl:variable>

  <xsl:template name="show-dt">
    <xsl:param name="p-list" select="''"/>
    <xsl:param name="t-list" select="
            /g:grammar//*[
                not(ancestor-or-self::*[@show='no'])
                and (
                    self::g:string[
                        not(ancestor::g:token)
                        or
                        ancestor::g:token[
                            /g:grammar//g:ref/@name=@name
                            and (@inline='true')
                            and not(@token-kind='skip')
                        ]
                    ]
                    or
                    self::g:token[
                        /g:grammar//g:ref/@name=@name
                        and not(
                            @alias-for
                            or @delimiter-type='hide'
                            or @inline='true'
                            or @is-macro='yes'
                            or @token-kind='skip'
                            or (count(g:ref) = count(*) and count(g:ref) = 1 and not(@inline='false'))
                        )
                    ]
                )
            ]"/>

    <xsl:param name="has-output" select="false()"/>

    <xsl:for-each select="$t-list">
        <xsl:sort select="."/>
        <!--  <xsl:message>
            <xsl:text>-></xsl:text>
            <xsl:choose>
                <xsl:when test="self::node()[self::g:string]">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:message> -->

        <xsl:variable name="expo-name">
            <xsl:choose>
                <xsl:when test="@exposition-name">
                    <xsl:value-of select="@exposition-name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="isPattern" select="
                self::g:token[
                    g:ref[position()=1]
                    or g:optional
                    or g:choice
                    or g:sequence
                    or g:charClass
                    or g:oneOrMore
                    or g:zeroOrMore
                ]"/>

        <xsl:variable name="c" select="substring(normalize-space(self::node()), 1, 1)"/>
        <xsl:variable name="c-last" select="substring(normalize-space(self::node()), string-length(.), string-length(.))"/>
        <xsl:variable name="ref-prefix" select="'prod-'"/>

        <xsl:choose>
            <xsl:when test="self::g:token[@delimiter-type='nondelimiting']">
                <xsl:choose>
                    <xsl:when test="string($expo-name)">
                        <token  type="nondelimiting" inline="{@inline}" expo-name="{$expo-name}">
                            <xsl:if test="not($isPattern)">
                                <xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/>
                            </xsl:if>
                        </token>
                    </xsl:when>
                    <xsl:otherwise>
                        <token type="nondelimiting"><xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/></token>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@delimiter-type='delimiting' or
                    not(contains($nd-chars, $c) and contains($nd-chars, $c-last))">
                <xsl:choose>
                    <xsl:when test="string($expo-name)">
                        <token type="delimiting" inline="{@inline}" expo-name="{$expo-name}">
                            <xsl:if test="not($isPattern)">
                                <xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/>
                            </xsl:if>
                        </token>
                    </xsl:when>
                    <xsl:otherwise>
                        <token type="delimiting">
                            <xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/>
                        </token>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string($expo-name)">
                        <token  type="nondelimiting" inline="{@inline}" expo-name="{$expo-name}">
                            <xsl:if test="not($isPattern)">
                                <xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/>
                            </xsl:if>
                        </token>
                    </xsl:when>
                    <xsl:otherwise>
                        <token type="nondelimiting"><xsl:value-of select="descendant-or-self::g:string | descendant-or-self::g:char"/></token>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>

  </xsl:template>


</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->
<!-- vim: sw=4 ts=4 expandtab
-->
