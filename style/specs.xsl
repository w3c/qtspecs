<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:h="http://www.w3.org/1999/xhtml"
                version="2.0">

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
  <html>
    <head>
      <title>XSL/XML Query Specifications</title>
      <style type="text/css">
tr.odd      { }
tr.even     { background-color: #EAEAEA; }
tr.first td { border-top-style: solid;
              border-top-color: black;
	      border-top-width: 1px;
            }
td.rowsep { border-bottom-style: solid;
            border-bottom-color: black;
	    border-bottom-width: 1px;
	    border-left-style: solid;
	    border-left-color: black;
	    border-left-width: 1px;
	    border-right-style: solid;
	    border-right-color: black;
	    border-right-width: 1px;
	    padding-bottom: 10px;
	    padding-left: 3px;
          }
td.only   { border-left-style: solid;
	    border-left-color: black;
	    border-left-width: 1px;
	    border-right-style: solid;
	    border-right-color: black;
	    border-right-width: 1px;
	    padding-left: 3px;
          }
td.first  {
	    border-left-style: solid;
	    border-left-color: black;
	    border-left-width: 1px;
	    padding-left: 3px;
          }
td.last   {
	    border-right-style: solid;
	    border-right-color: black;
	    border-right-width: 1px;
          }
span.unavail {
            font-weight: bold;
	    color: red;
}
      </style>
    </head>
    <body>
      <xsl:apply-templates/>
    </body>
  </html>
</xsl:template>

<xsl:template match="speclists">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="speclist">
  <h1><a name="{@xml:id}"/><xsl:value-of select="title"/></h1>
  <table border="0" summary="Specifications list"
	 cellpadding="2" cellspacing="0">
    <tbody>
      <xsl:apply-templates select="spec"/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="spec">
  <xsl:variable name="doc"
		select="document(concat(../@local-base,@href), .)"/>
  <xsl:variable name="title"
		select="$doc/h:html/h:head/h:title"/>
  <xsl:variable name="draft"
		select="$doc/h:html/h:body/h:div[@class='head']/h:h2[1]"/>

  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 0">even</xsl:when>
      <xsl:otherwise>odd</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <tr>
    <xsl:attribute name="class">
      <xsl:choose>
	<xsl:when test="position() = 1">first</xsl:when>
	<xsl:otherwise><xsl:value-of select="$class"/></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <xsl:choose>
      <xsl:when test="not($doc/*)">
	<td class="only" colspan="7">
	  <span class="unavail">
	    <xsl:text>Unavailable: </xsl:text>
	    <xsl:value-of select="@href"/>
	  </span>
	</td>
      </xsl:when>
      <xsl:otherwise>
	<td class="first">
	  <a href="{ancestor::speclist[1]/@base}{@href}">
	    <xsl:value-of select="$title"/>
	  </a>
	  <xsl:text> (</xsl:text>
	  <a href="{../@local-base}{@href}">local</a>
	  <xsl:text>)</xsl:text>
	</td>
	<td>
	  <xsl:variable name="cgi"
			select="'http://validator.w3.org/check'"/>
	  <xsl:variable name="uri"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <xsl:variable name="auth"
			select="'proxy'"/>
	  <a href="{$cgi}?uri={$uri}&amp;auth={$auth}&amp;recursive=on">VAL</a>
	</td>
	<td>
	  <xsl:variable name="uri" 
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <xsl:variable name="enc1">
	    <xsl:call-template name="string.subst">
	      <xsl:with-param name="string" select="$uri"/>
	      <xsl:with-param name="target" select="':'"/>
	      <xsl:with-param name="replacement" select="'%3A'"/>
	    </xsl:call-template>
	  </xsl:variable>
	  <xsl:variable name="enc2">
	    <xsl:call-template name="string.subst">
	      <xsl:with-param name="string" select="$enc1"/>
	      <xsl:with-param name="target" select="'/'"/>
	      <xsl:with-param name="replacement" select="'%2F'"/>
	    </xsl:call-template>
	  </xsl:variable>
	  <xsl:variable name="enc-uri">
	    <xsl:call-template name="string.subst">
	      <xsl:with-param name="string" select="$enc2"/>
	      <xsl:with-param name="target" select="'%'"/>
	      <xsl:with-param name="replacement" select="'%25'"/>
	    </xsl:call-template>
	  </xsl:variable>

          <!--* Variables for invoking pubrules.  The pubrules
              * checker embeds a version of its own URI in the
              * call to XSL, so most parameters occur twice.
              * I've pulled out the ones that seem most likely
              * to change; the others are still literals.
              *-->

          <!--* year: year of publication (omissible?) *-->
          <xsl:variable name="year">2007</xsl:variable>

          <!--* uimode: 
              *   checker = 'auto checker'
              *   checker_full = 'manual checker'
              *   filter = 'View pubrules'
              *-->
          <xsl:variable name="uimode">checker_full</xsl:variable>

          <!--* display: what results to display and what to hide.
              *   all = show all results
              *   hidesuccessful = hide if OK, else show
              *   summary = show only errors and warnings
              *-->
          <xsl:variable name="display">all</xsl:variable>
          <!--* <xsl:variable name="display">hidesuccessful</xsl:variable> *-->

          <!--* docstatus: What is the document type / status?
              *      ord-wd-tr:  Ordinary Working Draft
              *     fpwd-wd-tr:  First Public Working Draft
              *       lc-wd-tr:  Last Call Working Draft
              *   fpwdlc-wd-tr:  First Public and Last Call WD
              *          cr-tr:  Candidate Rec
              *          pr-tr:  Proposed Rec
              *         per-tr:  Proposed Edited Rec
              *         rec-tr:  Recommendation
              *     wg-note-tr:  Working Group Note
              *   fpwg-note-tr:  First Public WG Note
              *     ig-note-tr:  Interest Group Note
              *   fpig-note-tr:  First Public IG Note
              *     cg-note-tr:  Coordination Group Note
              *       mem-subm:  Member Submission
              *      team-subm:  Team Submission
              *            xgr:  Incubator Group Report
              *     rescind-tr:  Rescinded Rec
              *-->
          <xsl:variable name="docstatus">rec-tr</xsl:variable>

          <!--* other parameters ... *-->
          <!--* uri: uri of document to check. Use $enc_uri *-->
          <!--* recursive: recursively check HTML and CSS validity for
              * multipart documents?
              * checked (or whatever is used to signify 'unchecked') *-->
          <!--* filterValues: form (use the values in the form,
              * don't run the value-guessing program)
              *-->
          <!--* patpol: which patent policy?  use 'w3c'
              *   w3c = 5 Feb 2004
              *   cpp = the old 'current patent policy'
              *   none = 
              *-->
          <!--* rectrack: checked *-->
          <!--* normative: includes normative material? yes | no *-->
          <!--* prevrec: 
              *   none = no previous Rec
              *   cppeditorial = Editorial revision of CPP Rec
              *   cppother = Other revision of CPP rec
              *   editorial = Editorial rev of Rec under W3C PP
              *   other = other rev of Rec under W3C PP
              *   precppother = other rev of pre-CPP Rec
              *-->

          <!--* Now construct the pubrules URI *-->
          <xsl:variable name="big_kahuna"
            select="concat(
              'http://www.w3.org/2005/08/online_xslt/xslt',
              '?xmlfile=',
                  'http%3A%2F%2Fcgi.w3.org%2Fcgi-bin%2Ftidy-if',
                  '%3FdocAddr%3D', $enc-uri,
                  '&amp;xslfile=',
                     'http%3A%2F%2Fwww.w3.org%2F2005%2F08%2Fonline_xslt%2Fxslt',
                        '%3Fxmlfile%3D',
                          'http%3A%2F%2Fwww.w3.org',
                          '%2F2005%2F07%2Fpubrules',
                            '%253Fuimode%253D', $uimode,
                            '%2526year%253D', $year,
                            '%2526docstatus%253D', $docstatus,
                            '%2526rectrack%253Dyes',
                            '%2526prevrec%253Dnone',
                            '%2526patpol%253Dw3c',
                            '%2526normative%253Dyes',
                            '%2526uri%253D', $enc-uri,
                            '%2526filterValues%253Dform',
                            '%2526display%253D', $display,
                            '%2526auth%253Dproxy',
                            '%2526recursive%253Don',
                        '%26xslfile',
                        '%3Dhttp%3A%2F%2Fwww.w3.org%2F2005%2F09%2Fchecker%2Fframe.xsl',
                        '%26display%3Dhidesuccessful',
                  '&amp;uimode=', $uimode,
                  '&amp;filterValues=form',
                  '&amp;year=',$year,
                  '&amp;docstatus=', $docstatus,
                  '&amp;rectrack=yes',
                  '&amp;prevrec=none',
                  '&amp;patpol=w3c',
                  '&amp;normative=yes',
                  '&amp;doc_uri=', $uri,
                  '&amp;auth=proxy',
                  '&amp;recursive=on',
                  '&amp;display=', $display,
              '#docreqs'
            )"/>

	  <a href="{$big_kahuna}">PUB</a>

	  <!--
	  <xsl:variable name="cgi"
			select="'http://www.w3.org/2000/06/webdata/xslt'"/>
	  <xsl:variable name="xslfile"
			select="'http://www.w3.org/2001/07/pubrules-checker'"/>
	  <xsl:variable name="doc_uri"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <xsl:variable name="auth"
			select="'proxy'"/>
	  <xsl:variable name="xmlfile"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <a href="{$cgi}?xslfile={$xslfile}&amp;doc_uri={$doc_uri}&amp;auth={$auth}&amp;recursive=1&amp;xmlfile={$xmlfile}">PUB</a>
	  -->
	</td>
	<td>
	  <xsl:variable name="cgi"
			select="'http://validator.w3.org/checklink'"/>
	  <xsl:variable name="uri"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <a href="{$cgi}?&amp;uri={$uri}&amp;recursive=on">LINK</a>
	</td>
	<td>
	  <xsl:variable name="cgi"
			select="'http://www.w3.org/2001/09/checkuris'"/>
	  <xsl:variable name="uri"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <a href="{$cgi}?&amp;uri={$uri}">W3C&#160;URI</a>
	</td>

	<td>
	  <xsl:variable name="cgi"
			select="'http://www.w3.org/2003/09/nschecker'"/>
	  <xsl:variable name="uri"
			select="concat(ancestor::speclist[1]/@base,@href)"/>
	  <a href="{$cgi}?&amp;uri={$uri}">NS</a>
	</td>

	<td class="last">
	  <xsl:choose>
	    <xsl:when test="@issues">
	      <xsl:text>&#160;&#160;[</xsl:text>
      
	      <xsl:choose>
		<xsl:when test="../@issues-base">
		  <a>
		    <xsl:attribute name="href">
		      <xsl:value-of select="../@issues-base"/>
		      <xsl:value-of select="@issues"/>
		    </xsl:attribute>
		    <xsl:text>Issues</xsl:text>
		  </a>
		</xsl:when>
		<xsl:otherwise>
		  <a href="http://www.w3.org/XML/Group/xsl-query-specs/last-call-comments/{@issues}/issues.html">Issues</a>
		</xsl:otherwise>
	      </xsl:choose>
	      <xsl:text>]</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>&#160;</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</td>
      </xsl:otherwise>
    </xsl:choose>
  </tr>
  <tr class="{$class}">
    <td class="only" colspan="7">
      <xsl:if test="not(also)">
	<xsl:attribute name="class">rowsep</xsl:attribute>
      </xsl:if>
      <xsl:text>        </xsl:text>
      <xsl:value-of select="$draft"/>
    </td>
  </tr>

  <xsl:apply-templates>
    <xsl:with-param name="class" select="$class"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="also">
  <xsl:param name="class"/>

  <tr class="{$class}">
    <td class="only" colspan="7">
      <xsl:if test="not(following-sibling::also)">
	<xsl:attribute name="class">rowsep</xsl:attribute>
      </xsl:if>
      <xsl:text>              Also: </xsl:text>
      <xsl:choose>
	<xsl:when test="@href">
	  <a href="{ancestor::speclist[1]/@base}{@href}">
	    <xsl:value-of select="."/>
	  </a>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	  <xsl:text>: </xsl:text>
	  <span class="unavail">
	    <xsl:text>Unavailable</xsl:text>
	  </span>
	</xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
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
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->