<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
File dotml2dot.xsl 
Copyright 2002 - 2006 Martin Loetzsch
Translates dotml documents into the native dot syntax.
-->

<!-- 
This file is taken from DotML 1.3, found at http://www.martin-loetzsch.de/DOTML/
The licensing conditions (available at that site) allow free use and modifications
--> 


<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:dotml="http://www.martin-loetzsch.de/DOTML">
	<xsl:output method="text"/>
	<xsl:variable xml:space="preserve" name="graph-attributes">bgcolor fontcolor fontname fontsize label margin nodesep rankdir ranksep ratio size</xsl:variable>
	<xsl:variable xml:space="preserve" name="cluster-attributes">bgcolor color fillcolor fontcolor fontname fontsize label labeljust labelloc style</xsl:variable>
  <xsl:variable xml:space="preserve" name="node-attributes">color fillcolor fixedsize fontcolor fontname fontsize height shape style URL width</xsl:variable>
  <xsl:variable xml:space="preserve" name="record-attributes">color fillcolor fontcolor fontname fontsize height style URL width</xsl:variable>
  <xsl:variable xml:space="preserve" name="edge-attributes">arrowhead arrowsize arrowtail constraint color decorate dir fontcolor fontname fontsize headlabel headport label labeldistance labelfloat labelfontcolor labelfontname labelfontsize minlen samehead sametail style taillabel tailport URL</xsl:variable>
	<xsl:key name="nodes" match="//dotml:node" use="concat(@id,ancestor::dotml:graph/@file-name)"/>
	<!--<xsl:template match="*" priority="-1000">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="text()"/>-->
	<xsl:template match="dotml:graph">digraph g {compound="true";<xsl:call-template name="copy-attributes">
			<xsl:with-param name="separator" select="';'"/>
			<xsl:with-param name="attributes" select="$graph-attributes"/>
		</xsl:call-template>
		<xsl:apply-templates/>}
<!--&lt;dot-filename&gt;<xsl:value-of select="@file-name"/>&lt;/dot-filename&gt;--> <!-- deleted by MHK -->
</xsl:template>
	<xsl:template match="dotml:sub-graph">subgraph sub_graph_<xsl:value-of select="count(preceding::dotml:sub-graph)"/>{rank="<xsl:value-of select="@rank"/>";<xsl:apply-templates/>}</xsl:template>
	<xsl:template match="dotml:cluster">subgraph cluster_<xsl:value-of select="@id"/>{<xsl:call-template name="copy-attributes">
			<xsl:with-param name="separator" select="';'"/>
			<xsl:with-param name="attributes" select="$cluster-attributes"/>
		</xsl:call-template>
		<xsl:apply-templates/>}</xsl:template>
	<xsl:template match="dotml:node">node[label="<xsl:choose>
			<xsl:when test="@label">
				<xsl:value-of select="@label"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@id"/>
			</xsl:otherwise>
		</xsl:choose>", <xsl:call-template name="copy-attributes">
			<xsl:with-param name="separator" select="','"/>
			<xsl:with-param name="attributes" select="$node-attributes"/>
		</xsl:call-template>] {<xsl:value-of select="@id"/>};</xsl:template>
	<xsl:template match="dotml:edge">edge[<xsl:call-template name="copy-attributes">
			<xsl:with-param name="separator" select="','"/>
			<xsl:with-param name="attributes" select="$edge-attributes"/>
		</xsl:call-template>lhead="<xsl:if test="@lhead">cluster_<xsl:value-of select="@lhead"/>
		</xsl:if>",ltail="<xsl:if test="@ltail">cluster_<xsl:value-of select="@ltail"/>
		</xsl:if>"] <xsl:if test="key('nodes',concat(@from,ancestor::dotml:graph/@file-name))/ancestor::dotml:record">struct<xsl:value-of select="count(key('nodes',concat(@from,ancestor::dotml:graph/@file-name))/preceding::dotml:record[local-name(..)!='record'])"/>:</xsl:if>
		<xsl:value-of select="@from"/> -> <xsl:if test="key('nodes',concat(@to,ancestor::dotml:graph/@file-name))/ancestor::dotml:record">struct<xsl:value-of select="count(key('nodes',concat(@to,ancestor::dotml:graph/@file-name))/preceding::dotml:record[local-name(..)!='record'])"/>:</xsl:if>
		<xsl:value-of select="@to"/>;</xsl:template>
	<xsl:template match="dotml:record">node[shape="record",label="<xsl:apply-templates select="dotml:*" mode="record-label"/>",<xsl:call-template name="copy-attributes">
			<xsl:with-param name="separator" select="','"/>
			<xsl:with-param name="attributes" select="$record-attributes"/>
		</xsl:call-template>]{struct<xsl:value-of select="count(preceding::dotml:record[local-name(..)!='record'])"/>};</xsl:template>
	<xsl:template match="dotml:record" mode="record-label">{<xsl:apply-templates select="dotml:*" mode="record-label"/>}<xsl:if test="position()!=last()"> | </xsl:if>
	</xsl:template>
	<xsl:template match="dotml:node" mode="record-label">&lt;<xsl:value-of select="@id"/>> <xsl:choose>
			<xsl:when test="@label">
				<xsl:value-of select="@label"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@id"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="position()!=last()"> | </xsl:if>
	</xsl:template>
	<xsl:template name="copy-attributes">
		<xsl:param name="attributes"/>
		<xsl:param name="separator"/>
		<xsl:choose>
			<xsl:when test="string-length(substring-after($attributes,' '))=0">
				<xsl:value-of select="$attributes"/>="<xsl:value-of select="@*[local-name()=$attributes]"/>"<xsl:value-of select="$separator"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($attributes,' ')"/>="<xsl:value-of select="@*[local-name()=substring-before($attributes,' ')]"/>"<xsl:value-of select="$separator"/>
				<xsl:call-template name="copy-attributes">
					<xsl:with-param name="attributes" select="substring-after($attributes,' ')"/>
					<xsl:with-param name="separator" select="$separator"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
