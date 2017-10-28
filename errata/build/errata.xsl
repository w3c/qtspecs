<?xml version='1.0'?><xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:er="http://www.w3.org/2007/04/qt-errata"
   xmlns:saxon="http://saxon.sf.net/"
   exclude-result-prefixes="xs er saxon">

<xsl:import href="basedoc.xsl"/>

<xsl:import-schema namespace="http://www.w3.org/2007/04/qt-errata" 
                   schema-location="errata.xsd"/>

<xsl:output method="html" version="5" indent="no"/>

<xsl:param name="publication-date" as="xs:date" select="current-date()"/>
<!--<xsl:param name="publication-date" as="xs:date" select="current-date()"/>-->

<xsl:param name="status" as="xs:string" select="'draft'"/>

<xsl:variable name="specref"
              as="xs:string" 
              select="/er:errata/er:base-documents/er:document[@name='main-xml']/@href"/>

<xsl:variable name="spec"
              as="document-node()" 
              select="doc($specref)"/>

<xsl:variable name="specdoc" 
              select="/er:errata/@spec" 
			  as="xs:string"/>

<xsl:variable name="spectitle"
              select="if ($specdoc = 'XP') then 'XML Path Language (XPath) 2.0'
			          else if ($specdoc = 'XQ') then 'XQuery 1.0: An XML Query Language'
					  else $spec/spec/header/concat(title, ' ', version)"
              as="xs:string"/>

<xsl:variable name="specdate"
              select="string-join($spec/spec/header/pubdate/(day,month,year), '&#xa0;')"
			  as="xs:string"/>

<xsl:variable name="etc-doc"
              select="doc(concat('../../etc/', $specdoc, '.xml'))"
			  as="document-node()"/>

<xsl:variable name="htmlref"
              as="xs:string" 
              select="/er:errata/er:base-documents/er:document[@name='main-html']/@href"/>

<xsl:variable name="datedhtmlref"
              as="xs:string"
			  select="(/er:errata/er:base-documents/er:document[@name='dated-html']/@href, $htmlref)[1]"/>

<xsl:variable name="shortName"
              as="xs:string"
		      select="translate(substring-after($htmlref, 'http://www.w3.org/TR/'), '/', '')"/>

<xsl:variable name="defaultErrataRef"
              as="xs:string"
			  select="concat('http://www.w3.org/XML/2007/qt-errata/', $shortName, '-errata.html')"/>

<xsl:variable name="explicitErrataRef"
              as="xs:string?" 
              select="/er:errata/er:base-documents/er:document[@name='errata-html']/@href"/>

<xsl:variable name="errataRef"
              as="xs:string"
			  select="($explicitErrataRef, $defaultErrataRef)[1]"/>
			  
<xsl:variable name="produceIndexByAffectedSection"
              as="xs:boolean"
              select="exists(//schema-element(er:old-text)/@ref) or 
                      exists(//schema-element(er:manual-change)/@affects)"/>
					  
<xsl:variable name="wg-responsibility">
  <spec code="DM31" wg="QT"/>
  <spec code="FO31" wg="QT"/>
  <spec code="FS31" wg="QT"/>
  <spec code="SE31" wg="QT"/>
  <spec code="XP31" wg="QT"/>
  <spec code="XQ31" wg="Q"/>
  <spec code="XQX31" wg="Q"/>
  <spec code="XT30" wg="T"/>
</xsl:variable>
              					  			  

<!-- Select sections in the base document by key() to avoid dependency on DTD IDs -->

<xsl:key name="id" match="*[@id]" use="@id"/>

<!-- Match the document root and check that the input is of the right type.
     Note that it must have been validated against the schema -->

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$status = ('draft', 'public-draft', 'normative')"/>
	<xsl:otherwise>
	  <xsl:message terminate="yes">Unknown status: must be draft, public-draft, or normative</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="schema-element(er:errata)">
      <xsl:apply-templates/>
    </xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes">Input document must be a schema-validated errata document</xsl:message>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Process the outermost er:errata element.
     Produce the HTML outline and boilerplate of the HTML errata document -->

<xsl:template match="schema-element(er:errata)">   
    <html>
	  <xsl:comment>Created using <xsl:value-of select="system-property('xsl:product-name'), system-property('xsl:product-version')"/></xsl:comment>
      <head>
        <title>
		      <xsl:value-of select="'Draft'[$status='draft'], 'Errata for', $spectitle"/>
        </title>
        <xsl:call-template name="css"/>
		<xsl:call-template name="additional-head"/>
      </head>
      <body>
	    <xsl:call-template name="check-for-conflicts"/>
		<div>
	      <h1>
            <xsl:value-of select="'Draft'[$status='draft'], 'Errata for', $spectitle"/>
		  </h1>
		  <xsl:call-template name="front-matter"/>
		</div>
		<xsl:call-template name="abstract-and-status"/>
		<xsl:call-template name="table-of-contents"/>
        <xsl:apply-templates select="reverse(er:erratum)"/>
		<xsl:call-template name="errata-index"/>
      </body>
    </html>
</xsl:template>

<!-- Named template to generate the front matter -->

<xsl:template name="front-matter">
  <h2><a name="w3c-doctype" id="w3c-doctype"/>
    <xsl:value-of select="format-date($publication-date, '[D] [MNn] [Y]')"/>
  </h2>
  <dl>
    <dt>Latest version:</dt>
    <dd>
      <a href="{$errataRef}"><xsl:value-of select="$errataRef"/></a>
    </dd>
	<xsl:apply-templates select="er:authlist"/>
  </dl>
  <p class="copyright"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> © <xsl:value-of select="year-from-date($publication-date)"/>
  	<xsl:text> </xsl:text>
  	<a href="http://www.w3.org/"><acronym title="World Wide Web Consortium">W3C</acronym></a><sup>®</sup> (<a href="http://www.csail.mit.edu/"><acronym title="Massachusetts Institute of Technology">MIT</acronym></a>, <a href="http://www.ercim.eu/"><acronym title="European Research Consortium for Informatics and Mathematics">ERCIM</acronym></a>, <a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved. W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
</xsl:template>

<xsl:template match="schema-element(er:authlist)[count(*) eq 1]">
	<dt>Editor:</dt>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="schema-element(er:authlist)[count(*) gt 1]">
	<dt>Editors:</dt>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="schema-element(er:author)">
	<dd>
	  <xsl:value-of select="er:author-name"/>
	  <xsl:text>, </xsl:text>
	  <xsl:value-of select="er:author-affiliation"/>
	  <xsl:text> </xsl:text>
	  <a href="{er:author-uri}"><xsl:value-of select="er:author-uri"/></a>
	</dd>
</xsl:template>

<!-- Named template to generate the abstract and status sections -->

<xsl:template name="abstract-and-status">
  <hr/>
  <div>
    <h2><a name="abstract" id="abstract"/>Abstract</h2>
	  <p>This document addresses errors in the
         <a href="{$datedhtmlref}"><xsl:value-of select="$spectitle"/></a>
         Recommendation published on <xsl:value-of select="$specdate"/>. 
         It records all errors that, at the time of this document's publication,
         have solutions that have been approved by the
		 <xsl:call-template name="appropriate-working-group"/>. 
         For updates see the <a href="{$htmlref}">latest version</a> of that document. </p>
    <p>The errata are numbered,
         and are listed in reverse chronological order of their date of origin.
		 Each erratum is classified as
         Substantive, Editorial, or Markup. These categories are defined as follows:</p>
		 <ul>
		 <li><p><b>Substantive: </b> a change to the specification that may require
		 implementations to change and that may change the outcome of a stylesheet or query.</p></li>
         <li><p><b>Editorial: </b> a clarification, correction of a textual error, or removal of an
		 inconsistency, where the Working Group does not believe that the intent of the specification
		 has changed. The erratum may affect implementations or user-written queries and stylesheets
		 if the previous lack of clarity in the specification resulted in a misreading.</p></li>
		 <li><p><b>Markup: </b> correction of formatting; the effect is cosmetic only.</p></li>
		 </ul>
		  
         <p>Each entry contains the following information: </p>
    <ul>
	  <li><p>A description of the error. </p></li>
	  <li><p>A reference to the Bugzilla entry recording the original problem
	  report, subsequent discussion, and resolution by the Working Group.</p></li>
	  <li><p>Key dates in the process of resolving the error. </p></li>
	  <li><p>Where appropriate, one or more textual changes to be applied
	  to the published Recommendation. </p></li>
	</ul>
	<p>Colored boxes and shading are used to help distinguish new text from old,
	however these visual clues are not essential to an understanding of the change.
	The styling of old and new text is an approximation to its appearance in the
	published Recommendation, but is not normative. Hyperlinks are shown underlined
	in the erratum text, but the links are not live.</p>

	<p>A number of indexes appear at the end of the document.</p>
		 	  
    <p>Substantive corrections are proposed by the
	     <xsl:call-template name="appropriate-working-group"/>
         (part of the <a href="http://www.w3.org/XML/Activity">XML Activity</a>),
         where there is consensus that they are appropriate;
         they are not to be considered normative until approved by a
         <a href="http://www.w3.org/2004/02/Process-20040205/tr.html#cfr-corrections">Call
         for Review of Proposed Corrections</a> or a
         <a href="http://www.w3.org/2004/02/Process-20040205/tr.html#cfr-edited">Call
         for Review of an Edited Recommendation</a>. </p>
		 
		 
		 <p>Please report errors in this document using W3C's 
		 <a href="http://www.w3.org/Bugs/Public/">public Bugzilla system</a> 
		 (instructions can be found at 
		 <a href="http://www.w3.org/XML/2005/04/qt-bugzilla">http://www.w3.org/XML/2005/04/qt-bugzilla</a>).
		 If access to that system is not feasible, you may send your comments to the
         W3C XSLT/XPath/XQuery public comments mailing list,
         <a href="mailto:public-qt-comments@w3.org">public-qt-comments@w3.org</a>. 
         It will be very helpful if you include the string
         [<xsl:value-of select="$specdoc"/>errata]
         in the subject line of your report, whether made in Bugzilla or in email.
		 Each Bugzilla entry and email message should contain only one error report. 
         Archives of the comments and responses are available at
         <a href="http://lists.w3.org/Archives/Public/public-qt-comments/">
         http://lists.w3.org/Archives/Public/public-qt-comments/</a>. 
	</p>
	</div>
	<div>
      <h2><a name="status" id="status"/>Status of this Document</h2>
	  <xsl:choose>
	    <xsl:when test="$status='normative'">

		</xsl:when>
		<xsl:otherwise>
	      <p><xsl:choose>
		    <xsl:when test="$status='draft'">
	          <em>This is an editor's draft. </em>
	        </xsl:when>
			<xsl:when test="$status='public-draft'">
	          <em>This is a public draft.</em>
	        </xsl:when>
	      </xsl:choose>
		  None of the errata reported in this document have been approved
		  by a <a href="http://www.w3.org/2004/02/Process-20040205/tr.html#cfr-corrections">Call for Review of Proposed Corrections</a> or a
		  <a href="http://www.w3.org/2004/02/Process-20040205/tr.html#cfr-edited">Call for Review of an Edited Recommendation</a>. 
		  As a consequence, they must not be considered to be normative.
		  </p>
		  <p>The Working Group does not intend to progress these errata to normative status; instead, it
		  intends to publish a second edition of the Recommendation incorporating these errata, and to progress
		  the second edition to normative status.</p>
        </xsl:otherwise>
	   </xsl:choose>	  
	  
	  <!--
	  <p>This document records all errors in the
	  <a href="{$htmlref}">
		   <xsl:value-of select="$spectitle"/></a> specification
         that were known at the time of publication of this document. 
      </p>-->
	</div>
</xsl:template>

<xsl:template name="appropriate-working-group">
  <xsl:variable name="wg"
                as="xs:string"
                select="$wg-responsibility/spec[@code=$specdoc]/@wg"/>
  <xsl:choose>
    <xsl:when test="$wg='QT'">
        <a href="http://www.w3.org/Style/XSL/">XSL Working Group</a>
		     and the <a href="http://www.w3.org/XML/Query">XML Query Working Group</a>
	</xsl:when>
    <xsl:when test="$wg='Q'">
        <a href="http://www.w3.org/XML/Query">XML Query Working Group</a>
	</xsl:when>
    <xsl:when test="$wg='T'">
        <a href="http://www.w3.org/Style/XSL/">XSL Working Group</a>
	</xsl:when>
	<xsl:otherwise>
		<span style="color: red">[[[ Unspecified Working Group ]]]</span>
  	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="table-of-contents">
  <div>
    <h2><a name="contents" id="contents"/>Table of Contents</h2>
	<p>&#xa0;&#xa0;<b>Errata</b></p>
	
	<xsl:for-each select="reverse(er:erratum[not(@apply='silent')])">
	  <p>&#xa0;&#xa0;&#xa0;&#xa0;
	    <a href="#{@id}">
		  <xsl:value-of select="concat($specdoc, '.', @id)"/>
        </a>&#xa0;&#xa0;
		<xsl:variable name="desc" select="normalize-space(string(er:description))"/>
		<xsl:value-of select="if (contains($desc, '. '))
		                      then concat(substring-before($desc, '. '), '.')
							  else $desc"/>
	  </p>
     </xsl:for-each>
      <p>&#xa0;&#xa0;<b>Indexes</b></p>
      <xsl:if test="$produceIndexByAffectedSection">
	     <p>&#xa0;&#xa0;&#xa0;&#xa0;<a href="#index-by-section">Index by affected section</a></p>
	  </xsl:if>
	  <p>&#xa0;&#xa0;&#xa0;&#xa0;<a href="#index-by-bugzilla">Index by Bugzilla entry</a></p>
	  <xsl:for-each-group select="//schema-element(er:affects)" group-by="@object">
        <p>&#xa0;&#xa0;&#xa0;&#xa0;<a href="#index-by-{current-grouping-key()}">Index by
	        <xsl:value-of select="current-grouping-key()"/></a></p>
	  </xsl:for-each-group>

	</div>
    <hr/>
</xsl:template>


<!-- Process one erratum -->

<xsl:template match="schema-element(er:erratum)">
  <h2>
    <a id="{@id}" name="{@id}">
	  <xsl:value-of select="concat($specdoc, '.', @id, ' - ', @category)"/>
    </a>
  </h2>

  <xsl:if test="@superseded">
    <!-- next two lines tweaked by mdyck -->
    <p><b>Superseded by Erratum <a href="#{@superseded}">
	  <xsl:value-of select="concat($specdoc, '.', @superseded)"/>
	  </a></b></p>
  </xsl:if>

  <xsl:for-each select="er:bugzilla">
    <p><i>See <a href="http://www.w3.org/Bugs/Public/show_bug.cgi?id={@bug}">Bug <xsl:value-of select="@bug"/></a></i></p>
  </xsl:for-each>

  <h3>Description</h3>

  <xsl:apply-templates select="er:description/child::node()"/>

  <xsl:if test="er:history/er:event">
    <h3>History</h3>
	<xsl:apply-templates select="er:history/er:event"/>
  </xsl:if>

  <xsl:variable name="changes" 
                select="schema-element(er:abstract-change)[not(@apply='silent')]"
                as="schema-element(er:abstract-change)*"/>
  <xsl:choose>
    <xsl:when test="count($changes) = 0"/>
    <xsl:when test="count($changes) = 1">
	  <h3>Change</h3>
	  <xsl:apply-templates select="$changes"/>
	</xsl:when>
	<xsl:otherwise>
	  <h3>Changes</h3>
  	  <ol>
	    <xsl:for-each select="$changes">
		  <li>
    		<xsl:apply-templates select="."/>
          </li>
        </xsl:for-each>
      </ol>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Ignore a silent erratum -->

<xsl:template match="schema-element(er:erratum)[@apply='silent']"/>

<!-- Output an event in the life of the erratum -->

<xsl:template match="schema-element(er:event)">
  <p>
    <b>
      <xsl:value-of select="format-date(@date, '[D1] [MNn,3-3] [Y0001]')"/>
	  <xsl:text>: </xsl:text>
    </b>
	<xsl:value-of select="upper-case(substring(@status, 1, 1))"/>
	<xsl:value-of select="substring(@status, 2)"/>
  </p>
</xsl:template>

<!-- Process a manual change: one that appears in the errata document but is not automatically
     applied to the base document -->

<xsl:template match="schema-element(er:manual-change)">
  <xsl:copy-of select="child::node()" copy-namespaces="no"/>
</xsl:template>

<!-- A "silent" change is ignored -->

<xsl:template match="schema-element(er:change)[@apply='silent']"/>

<!-- Processs a "normal" change, one given structurally -->

<xsl:template match="schema-element(er:change)">
    <xsl:variable name="id" select="er:old-text/@ref"/>
    <xsl:variable name="section" select="$spec/key('id', $id)" as="element()?"/>
	<xsl:variable name="exp" select="er:old-text/@select"/>
	<xsl:variable name="subsections" select="$section/saxon:evaluate($exp)"/>
	<xsl:choose>
	  <xsl:when test="empty($section)">
	    <p style="color:red">Processing <xsl:copy-of select="."/></p>
		<p style="color:red">No section with id="<xsl:value-of select="$id"/>" found in base document</p>
      </xsl:when>
	  <xsl:when test="empty($subsections)">
	    <p style="color:red">Expression <xsl:value-of select="$exp"/> selects nothing</p>
	  </xsl:when>
	  <xsl:when test="count($subsections) eq 1 and $section is $subsections">
	    <p><i>
			<xsl:choose>
			  <xsl:when test="er:old-text/@action = 'insert-as-last'">
				<xsl:text>Insert at the end of section </xsl:text>
			  </xsl:when>
			  <xsl:when test="er:old-text/@action = 'insert-after'">
				<xsl:text>Insert after section </xsl:text>
			  </xsl:when>
		      <xsl:when test="er:old-text/@action = 'insert-before'">
			    <xsl:text>Insert before section </xsl:text>
			  </xsl:when>
			  <xsl:when test="er:old-text/@action = 'insert-as-first'">
			    <xsl:text>Insert at the start of section </xsl:text>
			  </xsl:when>
			  <xsl:when test="er:old-text/@action = 'delete'">
		        <xsl:text>Delete section </xsl:text>
		      </xsl:when>
			  <xsl:otherwise>
			    <xsl:text>Replace section </xsl:text>
		      </xsl:otherwise>
			</xsl:choose>
			<b><xsl:value-of select="er:section-title($id)"/></b>
		</i></p>	
		<xsl:call-template name="new-text"/>	
	  </xsl:when>
	  <xsl:otherwise>
		<xsl:variable name="section-title" select="er:section-title($id)"/>       
	    <p>In <xsl:value-of select="$section-title"/>
		  <xsl:text> (</xsl:text>
		  <xsl:value-of select="if (count($subsections) gt 1) then 'starting at ' else ''"/>
		  <xsl:variable name="path" select="string-join(er:location($section, $subsections[1])[normalize-space()], ', ')"/>
		  <xsl:value-of select="replace($path, '^[ ,]+', '')"/>
	      <xsl:text>):</xsl:text>
		</p>
	    <xsl:choose>
		  <xsl:when test="er:old-text/@action = ('insert-as-last', 'insert-after')">
			<p><i>Insert after the text:</i></p>
		  </xsl:when>
		  <xsl:when test="er:old-text/@action = ('insert-as-first', 'insert-before')">
		    <p><i>Insert before the text:</i></p>
		  </xsl:when>
		  <xsl:when test="er:old-text/@action = 'delete'">
	        <p><i>Delete the text:</i></p>
	      </xsl:when>
		  <xsl:otherwise>
		    <p><i>Replace the text:</i></p>
	      </xsl:otherwise>
		</xsl:choose>
		<div style="border: medium double rgb{
		            if (starts-with(er:old-text/@action, 'insert-')) then '(255,255,0)' else '(255,0,0)'}">
		  <xsl:apply-templates select="$subsections" mode="base-text"/>
		</div>
        <xsl:call-template name="new-text"/>
      </xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="er:old-generated-text"/>
</xsl:template>

<xsl:template name="new-text">
		<xsl:if test="er:new-text">
		  <xsl:choose>
		    <xsl:when test="starts-with(er:old-text/@action, 'insert-')">
		      <p><i>The following:</i></p>
		    </xsl:when>
		    <xsl:otherwise>
		      <p><i>With:</i></p>
	        </xsl:otherwise>
		  </xsl:choose>    
		  <div style="border: medium double rgb(0,255,0)">
	        <xsl:apply-templates select="er:new-text/*" mode="base-text">
			  <xsl:with-param name="er:in-new-text" tunnel="yes" select="true()"/>
			</xsl:apply-templates>
		  </div>
		</xsl:if>
</xsl:template>

<xsl:template match="er:old-generated-text">
  <p><i>Also:</i> Make the corresponding change to the automatically-generated text
   in <xsl:value-of select="@section"/>.</p>
</xsl:template>


<!-- Match a phrase within er:new-text and highlight it -->
<!-- match="//er:new-text//phrase" doesn't work, because some underlying template
     apparently copies the text (losing its ancestry) before applying templates to it.
	 So we use a tunnel parameter -->

<xsl:template match="phrase"><!--schema-element(er:new-text)//phrase[@diff]-->
  <xsl:param name="er:in-new-text" tunnel="yes" as="xs:boolean" select="false()"/>
  <xsl:choose>
  	<xsl:when test="$er:in-new-text and @diff='del'">
  		<span style="background-color:#ff3333; text-decoration:line-through">
  			<xsl:apply-templates/>
  		</span>
  	</xsl:when>
    <xsl:when test="$er:in-new-text">
      <span style="background-color:#99ff99">
        <xsl:apply-templates/>
      </span>
    </xsl:when>
	<xsl:otherwise>
	  <xsl:next-match/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Get the title of a section in the base document, identified by the id attribute
     of the section. (Actually returns the concatenated section number and title) -->

<xsl:function name="er:section-title" as="xs:string">
   <xsl:param name="id" as="xs:NCName"/>
   <xsl:variable name="etc-section" select="$etc-doc/key('id',$id)[1]" as="element()?"/>
   <!-- the index in the /etc directory appears to omit some id values, notably those
        within a non-normative appendix (inform-div). So we have to be prepared to
		go to the base document if necessary -->
   <xsl:variable name="spec-section" select="$spec/key('id',$id)"/>
   <xsl:choose>
     <xsl:when test="exists($etc-section) and matches($etc-section/head, '[A-Za-z]')">
	   <xsl:sequence select="normalize-space($etc-section/head)"/>
     </xsl:when>
	 <xsl:when test="exists($spec-section)">
	   <xsl:value-of>
	     <xsl:number select="$spec-section" level="multiple" 
			          count="div1[er:is-included(.)]|inform-div1[er:is-included(.)]|div2|div3|div4"
				      format="{if ($spec-section/ancestor-or-self::back) then 'A.1.1.1' else '1.1.1.1'}"/>
         <xsl:text> </xsl:text>
	     <xsl:sequence select="$spec-section/head"/>
       </xsl:value-of>
	 </xsl:when>
	 <xsl:otherwise>
       <xsl:message terminate="yes">No section with id="<xsl:value-of 
	 	  select="$id"/>" found in <xsl:value-of select="document-uri($etc-doc)"/>
       </xsl:message>
       <xsl:sequence select="'dummy result'"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Function to test whether a given section is included in the document or not.
     This returns false for an XPath section in the XQuery document, or for an XQuery section
	 in the XPath document -->
	 
<xsl:function name="er:is-included" as="xs:boolean">
  <xsl:param name="section" as="element()"/>
  <xsl:sequence select="not(($specdoc eq 'XP' and $section/ancestor-or-self::*/@role = 'xquery')
                         or ($specdoc eq 'XQ' and $section/ancestor-or-self::*/@role = 'xpath'))"/>
</xsl:function>  


<xsl:function name="er:location" as="xs:string">
   <xsl:param name="section" as="element()"/>
   <xsl:param name="subsection" as="element()?"/>
   <xsl:choose>
     <xsl:when test="empty($subsection) or ($subsection is $section)">
	   <xsl:sequence select="''"/>
     </xsl:when>
     <xsl:when test="count($subsection/../*) = 1">
       <xsl:sequence select="er:location($section, $subsection/..)"/>
	 </xsl:when>
     <xsl:when test="$subsection/.. is $section">
     	<xsl:variable name="loc">
     		<xsl:apply-templates select="$subsection" mode="user-element-name"/>
     	</xsl:variable>
     	<xsl:variable name="seqloc">
     		<xsl:if test="not(starts-with($loc, '#'))">
     			<xsl:number select="$subsection" count="*[node-name(.) eq node-name($subsection)][er:is-included(.)]" 
     				format="w" ordinal="yes"/>
     		</xsl:if>
     		<xsl:text> </xsl:text>
     		<xsl:value-of select="replace($loc, '#', '')"/>
     	</xsl:variable>
     	<xsl:value-of select="$seqloc"/>
	 </xsl:when>
	 <xsl:otherwise>
	 	<xsl:variable name="loc">
	 		<xsl:apply-templates select="$subsection" mode="user-element-name"/>
	 	</xsl:variable>
	 	<xsl:variable name="seqloc">
	 		<xsl:if test="not(starts-with($loc, '#'))">
	 			<xsl:number select="$subsection" count="*[node-name(.) eq node-name($subsection)][er:is-included(.)]" 
	 				format="w" ordinal="yes"/>
	 		</xsl:if>
	 		<xsl:text> </xsl:text>
	 		<xsl:value-of select="replace($loc, '#', '')"/>
	 	</xsl:variable>
	   <xsl:value-of>
	     <xsl:variable name="upper" select="er:location($section, $subsection/..)"/>
	   	 <xsl:value-of select="$upper"/>
	   	 <xsl:if test="normalize-space($seqloc)">
		 	<xsl:if test="not(ends-with(normalize-space($upper), ','))">, </xsl:if>
	   	 	<xsl:value-of select="$seqloc"/>
	   	 </xsl:if>
	   </xsl:value-of>
	 </xsl:otherwise>
   </xsl:choose>
</xsl:function>

<!-- Produce the indexes to the errata -->

<xsl:template name="errata-index">
  <hr/>
  <xsl:if test="$produceIndexByAffectedSection">
      <h2><a id="index-by-section" name="index-by-section">Index by affected section</a></h2>
      	<xsl:for-each-group select="//schema-element(er:old-text)|//schema-element(er:manual-change)" 
    	                    group-by="@ref|@affects">
    	  <xsl:sort select="substring-before(er:section-title(current-grouping-key()), ' ')"
    	            collation="http://saxon.sf.net/collation?alphanumeric=yes"/>
    	  <p><xsl:value-of select="er:section-title(current-grouping-key())"/></p>
    	  <blockquote>
    		<xsl:for-each select="current-group()/ancestor::er:erratum" >
    		  <xsl:variable name="erratum" select="."/>
    		  <a href="#{$erratum/@id}"><xsl:value-of select="$erratum/concat($specdoc, '.', @id)"/></a>
    		  <xsl:text> </xsl:text>
    		</xsl:for-each>
    	  </blockquote>
        </xsl:for-each-group>
  </xsl:if>
  <h2><a id="index-by-bugzilla" name="index-by-bugzilla">Index by Bugzilla entry</a></h2>
    <xsl:for-each-group select="//er:erratum" group-by="er:bugzilla/@bug">
	  <xsl:sort select="current-grouping-key()"/>
	  <p>Bug #<xsl:value-of select="current-grouping-key()"/>
	    <xsl:text>: </xsl:text>
		<xsl:for-each select="current-group()" >
		  <xsl:variable name="erratum" select="."/>
		  <a href="#{@id}"><xsl:value-of select="concat($specdoc, '.', @id)"/></a>
		  <xsl:text> </xsl:text>
		</xsl:for-each>
	  </p>
	</xsl:for-each-group>
  <xsl:for-each-group select="//schema-element(er:affects)" group-by="@object">
    <h2><a name="index-by-{current-grouping-key()}">Index by
	        <xsl:value-of select="current-grouping-key()"/></a></h2>
	<xsl:for-each-group select="current-group()" group-by="@name">
	  <xsl:sort select="translate(current-grouping-key(), ' ', '!')" 
	            collation="http://saxon.sf.net/collation?alphanumeric=yes"/>
	  <p>
	    <xsl:value-of select="current-grouping-key()"/>
		<xsl:text>: </xsl:text>
		<xsl:for-each select="current-group()">
		  <xsl:variable name="erratum" select="ancestor::er:erratum"/>
		  <a href="#{$erratum/@id}"><xsl:value-of select="$erratum/concat($specdoc, '.', @id)"/></a>
		  <xsl:text> </xsl:text>
		</xsl:for-each>
	  </p>
    </xsl:for-each-group>
  </xsl:for-each-group>


</xsl:template>

<!-- The following templates in mode user-element-name return a human-readable name for
     an element in the xmlspec markup -->

<xsl:template match="*" mode="user-element-name">
  <xsl:value-of select="name(.)"/>
</xsl:template>

<xsl:template match="p" mode="user-element-name">paragraph</xsl:template>
<xsl:template match="ulist" mode="user-element-name">bulleted list</xsl:template>
<xsl:template match="olist" mode="user-element-name">numbered list</xsl:template>
<xsl:template match="eg" mode="user-element-name">code section</xsl:template>
<xsl:template match="constraintnote" mode="user-element-name">constraint</xsl:template>
<xsl:template match="example" mode="user-element-name">example box</xsl:template>
<xsl:template match="example[@role='signature']" mode="user-element-name">function signature</xsl:template>
<xsl:template match="tbody" mode="user-element-name">#</xsl:template>
<xsl:template match="tr" mode="user-element-name">row</xsl:template>
<xsl:template match="td" mode="user-element-name">column</xsl:template>
<xsl:template match="proto" mode="user-element-name">function prototype</xsl:template>
<xsl:template match="glist" mode="user-element-name">#</xsl:template>
<xsl:template match="gitem" mode="user-element-name">#<xsl:value-of select="label"/> section</xsl:template>
<xsl:template match="gitem/def" mode="user-element-name">#</xsl:template>
<xsl:template match="bibl" mode="user-element-name">bibliographic reference</xsl:template>
<xsl:template match="blist" mode="user-element-name">bibliography</xsl:template>
<xsl:template match="code" mode="user-element-name">code snippet</xsl:template>

<!-- The following template checks that there is no element in the source document
     that is replaced or deleted by more than one erratum -->

<xsl:template name="check-for-conflicts">
  <xsl:variable name="directly-affected-elements" 
      select="er:eval-all(/er:errata/er:erratum[not(@superseded)]//er:old-text[not(starts-with(@action, 'insert-'))])"/>
  <xsl:variable name="all-affected-elements"
      select="for $e in $directly-affected-elements return $e/descendant-or-self::*"/>
  <xsl:if test="count($all-affected-elements) != count($all-affected-elements/.)">
     <!-- we now know there are duplicates, we just need to identify them... -->
	 <xsl:for-each-group select="$all-affected-elements" group-by="generate-id()">
	   <xsl:if test="count(current-group()) gt 1">
	     <xsl:variable name="id" select="(ancestor::*/@id)[last()]"/>
         <xsl:variable name="section" select="$spec/key('id',$id)"/>
	     <xsl:variable name="section-number">
	       <xsl:number select="$section" level="multiple" count="div1|div2|div3|div4"/>
         </xsl:variable>
	     <xsl:variable name="loc" select="er:location($section, .)"/>
		 <p style="color:red">
		   <xsl:text>WARNING: In </xsl:text>
		   <xsl:value-of select="$section-number, $section/head"/>
		   <xsl:text> (</xsl:text>
		   <xsl:value-of select="$loc"/>
		   <xsl:text>) Element is affected by more than one change</xsl:text>
		 </p>
	   </xsl:if>
	 </xsl:for-each-group>
   </xsl:if>	   	   
</xsl:template>

<!-- Support function for the check-for-conflicts template.
     This function builds a list (retaining duplicates) of all elements
	 in the source document directly affected by a replacement or deletion.
	 "Directly affected" means that the element is explicitly selected for replacement
	 or deletion; the descendants of this element are indirectly affected. -->	     

<xsl:function name="er:eval-all" as="element()*">
  <xsl:param name="in" as="element(er:old-text)*"/>
  <xsl:for-each select="$in">
	<xsl:variable name="id" select="@ref"/>
    <xsl:variable name="section" select="$spec/key('id',$id)"/>
	<xsl:variable name="exp" select="@select"/>
	<xsl:variable name="nodes" select="$section/saxon:evaluate($exp)"/>
	<xsl:sequence select="$nodes"/>
  </xsl:for-each>
</xsl:function>

</xsl:stylesheet>
