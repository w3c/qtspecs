<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lc="http:///XML/Group/xsl-query-specs/lc-comments"
                exclude-result-prefixes="lc"
                version="1.0">

<xsl:output method="html"/>

<xsl:param name="suppress" select="''"/>

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

<xsl:template match="lc:lcComments">
  <xsl:variable name="comments"
		select="lc:comment[@class != $suppress]"/>

  <html>
    <head>
      <title>Data Model Last Call Comments</title>
    </head>
    <style type="text/css">
tr.head { background-color: black;
          color: white;
        }
tr.odd  {
        }
tr.even { background-color: #DFDFDF;
        }
div.comment
h3      { margin-bottom: 0px;
          padding-bottom: 0px;
        }

div.status { margin-left: 20px; }
div.class { margin-left: 20px; }

div.initmessage { margin-top: 10px;
                  margin-left: 20px; 
                }
div.message { margin-left: 20px; }

div.text { background-color: #DFDFDF; }

    </style>
    <body>
      <h1>Data Model Last Call <xsl:value-of select="@call"/> Comments</h1>

      <p>
        <xsl:value-of select="count($comments)"/>
        <xsl:text> comments</xsl:text>
      </p>

      <xsl:apply-templates select="lc:preamble"/>

      <table border="0" summary="Comment ToC" cellspacing="0" cellpadding="3">
        <tr class="head">
          <th>Comment</th>
          <th>Status</th>
          <th>Class</th>
          <th>Summary</th>
        </tr>
        <xsl:apply-templates select="$comments" mode="toc"/>
      </table>

      <xsl:apply-templates select="$comments"/>

    </body>
  </html>
</xsl:template>

<xsl:template match="lc:comment" mode="toc">
  <tr>
    <xsl:attribute name="class">
      <xsl:choose>
        <xsl:when test="position() mod 2 = 0">even</xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <td>
      <a href="#{@id}">
        <xsl:value-of select="@id"/>
      </a>
    </td>
    <td><xsl:value-of select="@status"></xsl:value-of></td>
    <td><xsl:value-of select="@class"></xsl:value-of></td>
    <td>
      <xsl:choose>
        <xsl:when test="lc:summary != ''">
          <xsl:value-of select="lc:summary"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="lc:msg[1]/lc:subject"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</xsl:template>

<xsl:template match="lc:comment">
  <hr/>
  <div class="comment">
    <a name="{@id}"/>
    <h3>
      <xsl:value-of select="@id"/>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="lc:summary != ''">
          <xsl:value-of select="lc:summary"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="lc:msg[1]/lc:subject"/>
        </xsl:otherwise>
      </xsl:choose>
    </h3>

    <div class="status">
      <xsl:text>Status: </xsl:text>
      <xsl:value-of select="@status"></xsl:value-of>
    </div>

    <div class="class">
      <xsl:text>Class: </xsl:text>
      <xsl:value-of select="@class"></xsl:value-of>
    </div>

    <div class="initmessage">
      <div class="uri">
	<a href="lc:msg[1]/@uri">
	  <xsl:value-of select="lc:msg[1]/@uri"/>
	</a>
      </div>

      <div class="author">
	<xsl:value-of select="lc:msg[1]/lc:author"/>
	<!--
	<xsl:text>: </xsl:text>
	<xsl:value-of select="lc:msg[1]/lc:subject"/>
	-->
      </div>

      <div class="text">
	<pre>
	  <xsl:value-of select="lc:msg[1]/lc:text"/>
	</pre>
      </div>
    </div>

    <xsl:for-each select="lc:msg[position() &gt; 1]">
      <div class="message">
	<div class="uri">
	  <a href="@uri">
	    <xsl:value-of select="@uri"/>
	  </a>
	</div>

	<div class="author">
	  <xsl:value-of select="lc:author"/>
	  <!--
	  <xsl:text>: </xsl:text>
	  <xsl:value-of select="lc:subject"/>
	  -->
	</div>

	<div class="text">
	  <pre>
	    <xsl:value-of select="lc:text"/>
	  </pre>
	</div>
      </div>
    </xsl:for-each>
  </div>
</xsl:template>

<xsl:template match="lc:preamble">
  <xsl:apply-templates mode="copy"/>
</xsl:template>

<xsl:template match="*" mode="copy">
  <xsl:element name="{local-name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="copy"/>
  </xsl:element>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="copy">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->