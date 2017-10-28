<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tr="http://www.w3.org/2001/02pd/rec54#"
		xmlns:contact="http://www.w3.org/2000/10/swap/pim/contact#"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:doc="http://www.w3.org/2000/10/swap/pim/doc#"
		xmlns:log="http://www.w3.org/2000/10/swap/log#"
		xmlns:mat="http://www.w3.org/2002/05/matrix/vocab#"
		xmlns:org="http://www.w3.org/2001/04/roadmap/org#"
		xmlns:os="http://www.w3.org/2000/10/swap/os#"
		xmlns:rcs="http://www.w3.org/2001/03swell/rcs#"
		xmlns:rct="file:/home/dom/WWW/2002/01/tr-automation/recent.n3#"
		xmlns:rctg1="file:/home/vivien/WWW/2002/01/tr-automation/recent.n3#"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rec="http://www.w3.org/2001/02pd/rec54#"
		xmlns:s="http://www.w3.org/2000/01/rdf-schema#"
                version="1.0">

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
  <blist>
    <!--* N.B. sequence is:  most mature documents first.
        * Add a descending sort by date, to get latest version first.
	*-->
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* REC documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:REC">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* PR documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:PR">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* PER documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:PER">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* CR documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:CR">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* Last Call WD documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:LastCall">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* WD documents, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:WD">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:comment>* NOTEs, alpha by short-name, descending by date *</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="//tr:NOTE">
      <xsl:sort select="doc:versionOf/@rdf:resource"/>
      <xsl:sort select="dc:date" order="descending"/>
    </xsl:apply-templates>

  </blist>
</xsl:template>

<xsl:template match="tr:REC|tr:PER|tr:PR|tr:CR|tr:LastCall|tr:WD|tr:NOTE">
  <xsl:variable name="shortname">
    <xsl:call-template name="shortname">
      <xsl:with-param name="uri">
	<xsl:choose>
	  <xsl:when test="substring(doc:versionOf/@rdf:resource,
		                    string-length(doc:versionOf/@rdf:resource),
                                    1) = '/'">
	    <xsl:value-of select="substring(doc:versionOf/@rdf:resource,
			                    1,
					    string-length(doc:versionOf/@rdf:resource)-1)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="doc:versionOf/@rdf:resource"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <bibl id="{$shortname}" key="{dc:title}">
    <titleref href="{doc:versionOf/@rdf:resource}">
      <xsl:value-of select="dc:title"/>
    </titleref>
    <xsl:text>, </xsl:text>

    <xsl:choose>
      <xsl:when test="count(tr:editor) = 1">
	<xsl:value-of select="tr:editor/contact:fullName"/>
	<xsl:text>, Editor. </xsl:text>
      </xsl:when>
      <xsl:when test="count(tr:editor) = 2">
	<xsl:value-of select="tr:editor[1]/contact:fullName"/>
	<xsl:text> and </xsl:text>
	<xsl:value-of select="tr:editor[2]/contact:fullName"/>
	<xsl:text>, Editors. </xsl:text>
      </xsl:when>
      <xsl:when test="count(tr:editor) = 3">
	<xsl:value-of select="tr:editor[1]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="tr:editor[2]/contact:fullName"/>
	<xsl:text>, and </xsl:text>
	<xsl:value-of select="tr:editor[3]/contact:fullName"/>
	<xsl:text>, Editors. </xsl:text>
      </xsl:when>
      <xsl:when test="count(tr:editor) = 4">
	<xsl:value-of select="tr:editor[1]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="tr:editor[2]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="tr:editor[3]/contact:fullName"/>
	<xsl:text>, and </xsl:text>
	<xsl:value-of select="tr:editor[4]/contact:fullName"/>
	<xsl:text>, Editors. </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="tr:editor[1]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="tr:editor[2]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<xsl:value-of select="tr:editor[3]/contact:fullName"/>
	<xsl:text>, </xsl:text>
	<emph>et. al.</emph>
	<xsl:text>, Editors. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text>World Wide Web Consortium, </xsl:text>
    <xsl:value-of select="substring(dc:date, 9, 2)"/>
    <xsl:text>&#160;</xsl:text>
    <xsl:choose>
      <xsl:when test="substring(dc:date, 6, 2) = '01'">Jan</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '02'">Feb</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '03'">Mar</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '04'">Apr</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '05'">May</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '06'">Jun</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '07'">Jul</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '08'">Aug</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '09'">Sep</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '10'">Oct</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '11'">Nov</xsl:when>
      <xsl:when test="substring(dc:date, 6, 2) = '12'">Dec</xsl:when>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text>
    <xsl:value-of select="substring(dc:date, 1, 4)"/>
    <xsl:text>. </xsl:text>

    <xsl:text>This version is </xsl:text>
    <xsl:value-of select="@rdf:about"/>
    <xsl:text>. The </xsl:text>
    <a href="{doc:versionOf/@rdf:resource}">latest version</a>
    <xsl:text> is available at </xsl:text>
    <xsl:value-of select="doc:versionOf/@rdf:resource"/>
    <xsl:text>.</xsl:text>
  </bibl>
</xsl:template>

<!--
<bibl id="XFO" key="XQuery 1.0 and XPath 2.0 Functions and Operators">
<titleref href="http://www.w3.org/TR/xpath-functions/"
>XQuery 1.0 and XPath 2.0 Functions and Operators</titleref>,
Ashok Malhotra, Jim Melton, and Norman Walsh, Editors.
World Wide Web Consortium,
&spec.pub.date;.
</bibl>
-->

<xsl:template name="shortname">
  <xsl:param name="uri"/>
  <xsl:choose>
    <xsl:when test="contains($uri, '/')">
      <xsl:call-template name="shortname">
	<xsl:with-param name="uri" select="substring-after($uri,'/')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$uri"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->