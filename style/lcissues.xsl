<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
      Stylesheet for Issues for XQuery, XPath, XSLT and related.

      Based on:

      lcissues.xsl,v 2.1 2000/10/03 03:26:09 cmsmcq

      and

      comments.xsl used for the XSL 1.0 Recommendation
-->
<!--
      Global variables (that can be overridden on the XT command line:

      kwFull = brief | full | <status>
               brief suppresses resolved issues
               <status> keeps only those with this status

      kwSort = keyword | class | cluster | status | locus | title
               specifies a field to sort the issues on for the
               'toc' of issues (the issues themselves are left in
               their numeric order)

      kwDate = <date> includes only issues with a last-modified date
               that is later than the specified date

      kwLocus = all (default) | name(s) of the locus to be included
                (issues for all other will be removed)
-->

<!--     parameter settings - overridable on the XT command line     -->

<xsl:param name="kwSort">locus</xsl:param>
<xsl:param name="kwFull">brief</xsl:param>
<xsl:param name="kwDate">00000000</xsl:param>
<xsl:param name="kwLocus">all</xsl:param>
<xsl:param name="check-for-docChanges" select="false()"/>

<xsl:variable name="xquery-requirements-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xpath-requirements-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xslt-requirements-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="use-cases-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="algebra-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xquery-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xpath-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xpath-fulltext-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xslt-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="datamodel-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="xfo-spec">http://www.w3.org/........html</xsl:variable>
<xsl:variable name="formal-semantics-spec">http://www.w3.org/........html</xsl:variable>

<!--     end of parameters                                           -->

<xsl:include href="strings.xsl"/>

<xsl:output method="html"
            indent="no"
            doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"/>

<xsl:strip-space
 elements="issues
           header
           issue
           description
           references
           input
           interaction
           proposal
           resolution
           ulist
           olist"/>
<xsl:preserve-space elements="xsl:text"/>

<!--
         Root and Top Level Element
-->

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
  <title>XPath 2.0 and XQuery 1.0 Issues List</title>
  <style type='text/css'><xsl:text>
</xsl:text>
         body {  margin: 2em 1em 2em 70px;
                 font-family: New Times Roman, serif;
                 color: black;
                 background-color: white;}
         p {     margin-top: 0.6em;}
         pre {   font-family: monospace;
                 margin-left: 2em;}
         div.issue {
                 margin-top: 1em;
                 }
         a:hover { background: #CCF;}
  </style>
 </head>
 <xsl:text>

</xsl:text>
 <body>
  <div id="htmlbody">
   <xsl:apply-templates/>
  </div>
 </body>
</html>
</xsl:template>

<xsl:template match="issues">
   <xsl:choose>
     <xsl:when test="not($kwDate = '00000000') and $kwLocus = 'all'">
       <xsl:call-template name="do_issues">
         <xsl:with-param name="issues_to_process" select="//issue[@last-modified > $kwDate]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:when test="not($kwDate = '00000000')">
       <xsl:call-template name="do_issues">
         <xsl:with-param name="issues_to_process" select="//issue[@last-modified > $kwDate and contains($kwLocus,@locus)]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:when test="$kwFull = 'brief' and $kwLocus = 'all'">
       <xsl:call-template name="do_issues">
             <xsl:with-param name="issues_to_process" select="//issue[not(contains('resolved postponed subsumed abandoned',@status))]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:when test="$kwFull = 'brief'">
       <xsl:call-template name="do_issues">
             <xsl:with-param name="issues_to_process" select="//issue[not(contains('resolved postponed subsumed abandoned',@status)) and contains($kwLocus,@locus)]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:when test="$kwFull = 'full' and $kwLocus = 'all'">
       <xsl:call-template name="do_issues">
             <xsl:with-param name="issues_to_process" select="//issue"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:when test="$kwFull = 'full'">
       <xsl:call-template name="do_issues">
             <xsl:with-param name="issues_to_process" select="//issue[contains($kwLocus,@locus)]"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:choose>
         <xsl:when test="$kwLocus = 'all'">
           <xsl:call-template name="do_issues">
                 <xsl:with-param name="issues_to_process" select="//issue[contains($kwFull,@status)]"/>
           </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
           <xsl:call-template name="do_issues">
                 <xsl:with-param name="issues_to_process" select="//issue[contains($kwFull,@status) and contains($kwLocus,@locus)]"/>
           </xsl:call-template>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="do_issues">
 <xsl:param name="issues_to_process"/>
  <xsl:apply-templates select="header|title" mode="frontmatter"/>
  <table>
   <tr>
     <th style="text-align:left; width:5%">Num</th>
     <th style="text-align:left">Cl</th>
     <th style="text-align:left">Pr</th>
     <th style="text-align:left">Cluster</th>
     <th style="text-align:left">Status</th>
     <th style="text-align:left">Locus</th>
     <th style="text-align:left">Description</th>
     <th style="text-align:left">Responsible</th>
     <!--
     <th style="text-align:left">Originator</th>
     -->
   </tr>
   <xsl:choose>
   <xsl:when test="$kwSort = 'keyword'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@keyword"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'class'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@batch"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'cluster'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@cluster"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'status'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'locus'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@locus"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'title'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="title"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:when test="$kwSort = 'batch'">
     <xsl:apply-templates select="$issues_to_process" mode="toc">
       <xsl:sort select="@batch"/>
       <xsl:sort select="@priority"/>
       <xsl:sort select="@status"/>
     </xsl:apply-templates>
   </xsl:when>
   <xsl:otherwise>
     <xsl:apply-templates select="$issues_to_process" mode="toc">
     </xsl:apply-templates>
   </xsl:otherwise>
   </xsl:choose>
  </table>
  <hr/><xsl:text>

</xsl:text>
  <xsl:apply-templates select="$issues_to_process" />
</xsl:template>

<xsl:template match="issues/title" mode="frontmatter">
  <h1><xsl:apply-templates/></h1>
  <h3>Version <xsl:value-of select='/issues/@version'/></h3>
</xsl:template>

<xsl:template match="issues/header" mode="frontmatter"><xsl:text>
</xsl:text>
  <hr/><xsl:text>
</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>
</xsl:text>
<p>Values for <b>Status</b> has the following meaning:</p>
<p><b>resolved</b>: a decision has been finalized and the document
updated to reflect the decision.</p>
<p><b>decided</b>: recommendations and decision(s) has been made by
one or more of the following:
a task-force, XPath WG, or XQuery WG.</p>
<p><b>draft</b>: a proposal has been developed for possible future
inclusion in a published document.</p>
<p><b>active</b>: issue is actively being discussed.</p>
<p><b>unassigned</b>: discussion of issue deferred.</p>
<p><b>subsumed</b>: issue has been subsumed by another issue.</p>

<p><b>Cl</b> has the values:</p>
<p><b>D</b> for Document and Collections</p>
<p><b>T</b> for basic type issues</p>
<p><b>TF</b> for types in the context of functions</p>

<p>Priorities prefixed by "o-" are old, unreviewed, priority assignments.</p>
<p>Priority 1 is the highest, 4 is the lowest.</p>

<p><xsl:text>(stylesheet parameters used:</xsl:text>
<xsl:text> kwSort: </xsl:text><xsl:value-of select="$kwSort"/>
<xsl:text>, kwFull: </xsl:text><xsl:value-of select="$kwFull"/>
<xsl:text>, kwDate: </xsl:text><xsl:value-of select="$kwDate"/>
<xsl:text>, kwLocus: </xsl:text><xsl:value-of select="$kwLocus"/>
<xsl:text>).</xsl:text>
</p><xsl:text>
</xsl:text>
<hr/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="issues/title"/>

<xsl:template match="issues/header"/>

<!--
         'issue' and its Subelements for 'toc'
-->

<xsl:template match="issue" mode="toc">
 <xsl:choose>
 <xsl:when test="./title = 'Dummy'">
 <tr><xsl:if test="((position() mod 3) = 0)">
    <xsl:attribute name="style">background-color:#FFA</xsl:attribute>
   </xsl:if>
   <td
     ><a
       ><xsl:attribute name="href"
         >#<xsl:value-of select='@keyword'
       /></xsl:attribute
       ><xsl:value-of select="/issues/@prefix"
       /><xsl:number count="issue" level="any" format="1"
     /></a
   ></td>
   <td>-<!--* batch *--></td>
   <td>-<!--* cluster *--></td>
   <td>-<!--* status *--></td>
   <td>-<!--* locus, clause *--></td>
   <td>-<!--* originator *--></td>
   <!--*
   <td>-responsible </td>
   *-->		
   <td>[Dummy]</td>
 </tr>
 </xsl:when>
 <xsl:otherwise>
 <tr><xsl:if test="((position() mod 3) = 0)">
    <xsl:attribute name="style">background-color:#FFA</xsl:attribute>
   </xsl:if>
   <td
     ><a
       ><xsl:attribute name="href"
         >#<xsl:value-of select='@keyword'
       /></xsl:attribute
       ><xsl:value-of select="/issues/@prefix"
       /><xsl:number count="issue" level="any" format="1"
     /></a
   ></td>
   <td><xsl:value-of select="@batch"/></td>
   <td><xsl:value-of select="@priority"/></td>
   <td><xsl:value-of select="@cluster"/></td>
   <td><xsl:value-of select="@status"/></td>
   <td><xsl:value-of select="@locus"/>
       <xsl:text> </xsl:text>
       <xsl:value-of select="@clause"/></td>
   <td><xsl:value-of select="title"/></td>
<!--
   <td>
      <xsl:choose>
      <xsl:when test="@responsible">
        <xsl:value-of select="@responsible"/>
      </xsl:when>
      <xsl:when test="@batch='C'">
        editor
      </xsl:when>
      <xsl:when test="@batch='B'">
        chairs
      </xsl:when>
      </xsl:choose>
   </td>
-->
   <td><xsl:value-of select="@responsible"/></td>
<!--
   <td><xsl:value-of select="@originator"/></td>
-->
 </tr>
 </xsl:otherwise>
 </xsl:choose>
 <xsl:text>

</xsl:text>
</xsl:template>

<!--
         'issue' and its Subelements for body
-->

<xsl:template match="issue" name="lcissues-issue"><xsl:text>

</xsl:text>
 <div class='issue'>
  <xsl:choose>
    <xsl:when test="@status='unassigned'">
      <xsl:attribute name='style'>color: #A00000; background-color: white</xsl:attribute>
    </xsl:when>
    <xsl:when test="@status='active'">
      <xsl:attribute name='style'>color: red; background-color: white</xsl:attribute>
    </xsl:when>
    <xsl:when test="@status='draft'">
      <xsl:attribute name='style'>color: #002080; background-color: white</xsl:attribute>
      <!--* 000044 *-->
    </xsl:when>
    <xsl:when test="@status='resolved'">
      <xsl:attribute name='style'>color: #008000; background-color: white</xsl:attribute>
      <!--* 004400 *-->
    </xsl:when>
    <xsl:when test="@status='postponed'">
      <xsl:attribute name='style'>color: #808080; background-color: white</xsl:attribute>
      <!--* 003644 *--><!--* toc IS A0A0A0, but text needs to be darker *-->
    </xsl:when>
    <xsl:when test="(@status='abandoned' or title='Dummy')">
      <xsl:attribute name='style'>color: #808000; background-color: white</xsl:attribute>
      <!--* 443600 *-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name='style'>color: green; background-color: white</xsl:attribute>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
  <xsl:when test="./title = 'Dummy'">
  <h2><xsl:value-of select="/issues/@prefix"
    /><xsl:number count="issue" level="any" format="1. "/>
    <a><xsl:attribute name='name'>
         <xsl:choose>
              <xsl:when test='@keyword'><xsl:value-of select='@keyword'/></xsl:when>
           <xsl:otherwise><xsl:text>AEN</xsl:text><xsl:value-of select="generate-id(this)"/></xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
    </a>
   This issue number has been retired.</h2>
  </xsl:when>
  <xsl:otherwise>
  <h2><xsl:value-of select="/issues/@prefix"
    /><xsl:number count="issue" level="any" format="1. "/>
    <a><xsl:attribute name='name'>
         <xsl:choose>
              <xsl:when test='@keyword'><xsl:value-of select='@keyword'/></xsl:when>
           <xsl:otherwise><xsl:text>AEN</xsl:text><xsl:value-of select="generate-id(this)"/></xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
       <u><xsl:value-of select='@keyword'/></u>:
       <xsl:apply-templates select='title' mode='title'/>
<!--*  (<xsl:value-of select='@status'/>) *-->
    </a>
  </h2>
  <div>
    <xsl:if test="@priority='editorial'">
      <xsl:attribute name='style'>font-style: italic</xsl:attribute>
      <b>Editorial.</b>
    </xsl:if>
    <small>
      <xsl:if test="@batch">
        Issue Class: <b><xsl:value-of select="@batch"/></b>
      </xsl:if>
      Locus: <b><xsl:value-of select="@locus"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@clause"/>
      </b>
      <xsl:choose>
        <xsl:when test="@cluster">
          Cluster: <b><xsl:value-of select="@cluster"/></b>
        </xsl:when>
        <xsl:otherwise>
          (No cluster assigned yet)
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@priority">
        Priority: <b><xsl:value-of select="@priority"/></b>
      </xsl:if>
      Status: <b><xsl:value-of select='@status'/></b>
      <br/>
      <xsl:choose>
      <xsl:when test="@responsible">
        Assigned to: <b><xsl:value-of select="@responsible"/></b>
      </xsl:when>
      <xsl:when test="@batch='C'">
        Assigned to: <b>editor</b>
      </xsl:when>
      <xsl:when test="@batch='B'">
        Assigned to: <b>chairs</b>
      </xsl:when>
      </xsl:choose>
      Originator: <b><xsl:value-of select='@originator'/></b>
      <xsl:if test='@source'>
        Source: <a><xsl:attribute name='href'
           ><xsl:value-of select='@source'/></xsl:attribute>
           <xsl:value-of select='@source'/></a>
      </xsl:if>
    </small>
    <xsl:apply-templates/>
  </div>
  </xsl:otherwise>
  </xsl:choose>
 </div>
</xsl:template>

<xsl:template match="issue/title" mode="title">
 <xsl:apply-templates/>
</xsl:template>

<xsl:template match="issue/title"/>

<xsl:template match='description'>
  <h3>Description</h3>
  <div>
   <xsl:apply-templates/>
  </div>
</xsl:template>
<xsl:template match='references'>
  <h3>Interactions and Input</h3>
  <div>
   <xsl:apply-templates/>
  </div>
</xsl:template>
<xsl:template match='interaction'>
  <p>Cf. <a><xsl:attribute name='href'>#<xsl:value-of select='@issue'
     /></xsl:attribute><xsl:value-of select='id(@issue)/title'/></a></p>
  <xsl:apply-templates/>
</xsl:template>
<xsl:template match='input'>
  <p><a><xsl:attribute name='href'><xsl:value-of select='@href'
    /></xsl:attribute>Input from </a>
  <xsl:value-of select='@author'/>:</p>
  <div style='margin-left: 2em; margin-right: 2em;'><xsl:apply-templates/></div>
</xsl:template>
<xsl:template match='proposal'>
  <h3>Proposed Resolution</h3>
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match='resolution'>
  <h3>Actual Resolution</h3>
  <xsl:if test="ancestor::pubcomment">
  <p><b>Disposition: </b>
  <xsl:call-template name="disposition-text">
  <xsl:with-param name="disposition-code" select="@type"/>
  <xsl:with-param name="document-change" select="..//spotref"/>
  </xsl:call-template>
  </p>
  </xsl:if>
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match='decision'>
  <p>
    <small>
    Decision by: <b><xsl:value-of select="@decider"/></b>
    on <xsl:value-of select="@date"/>
    <xsl:if test='@href'>
      <xsl:text> (</xsl:text>
      <a href="{@href}"><xsl:value-of select="@href"/></a>
      <xsl:text>)</xsl:text>
    </xsl:if>
    </small>
    <xsl:apply-templates/>
  </p><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="action[@status='active']">
  <h3>Action</h3>
  <p><small>Responsible: <b><xsl:value-of select="@responsible"/></b><br/>
  Target date for Completion: <b><xsl:value-of select="@target-date"/></b></small></p>
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="docChanges">
<xsl:if test="spotref">
<p><b>Links</b> to the changed text:</p>
</xsl:if>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="spotref">
<xsl:choose>
<xsl:when test="ancestor::issue/@locus='xquery-requirements'">
<p>See <a href="{$xquery-requirements-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xpath-requirements'">
<p>See <a href="{$xpath-requirements-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xslt-requirements'">
<p>See <a href="{$xslt-requirements-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='use-cases'">
<p>See <a href="{$use-cases-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='algebra'">
<p>See <a href="{$algebra-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xquery'">
<p>See <a href="{$xquery-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xpath'">
<p>See <a href="{$xpath-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xpath-fulltext'">
<p>See <a href="{$xpath-fulltext-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xslt'">
<p>See <a href="{$xslt-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='datamodel'">
<p>See <a href="{$datamodel-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='xfo'">
<p>See <a href="{$xfo-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:when test="ancestor::issue/@locus='formal-semantics'">
<p>See <a href="{$formal-semantics-spec}#{@ref}">link to changed text</a>.</p>
</xsl:when>
<xsl:otherwise>
<p>***ERROR*** <xsl:value-of select="ancestor::issue/@locus"/></p>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="text">
<pre>
<xsl:apply-templates/>
</pre>
</xsl:template>

<xsl:template match="accept">
<xsl:choose>
<xsl:when test="@type='acc'">
<p><b>Submitter's acceptance of disposition:</b></p>
</xsl:when>
<xsl:when test="@type='rej'">
<p><b>Submitter's rejection of disposition:</b></p>
</xsl:when>
<xsl:otherwise>
<p>***ERROR***</p>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates/>
</xsl:template>

<!--
         General Document Elements and Miscellaneous templates
-->

<xsl:template match="p"><p><xsl:apply-templates/></p></xsl:template>

<xsl:template match='olist'>
<ol>
 <xsl:for-each select='item'>
   <li><xsl:apply-templates/></li>
 </xsl:for-each>
</ol>
</xsl:template>

<xsl:template match='ulist'>
<ul>
 <xsl:for-each select='item'>
  <li><xsl:apply-templates/></li>
 </xsl:for-each>
</ul>
</xsl:template>

<xsl:template match='eg'>
<div class='eg'>
 <table cellpadding='5' border='1' bgcolor='#bbffff' width='100%'>
  <tr>
   <td>
    <xsl:choose>
     <xsl:when test="@role='error'">
      <pre style='color: red; background-color: white'><xsl:apply-templates/></pre>
     </xsl:when>
     <xsl:otherwise>
      <pre><xsl:apply-templates/></pre>
     </xsl:otherwise>
    </xsl:choose>
   </td>
  </tr>
 </table>
</div>
</xsl:template>

<xsl:template match="ednote">
  <blockquote>
  <p><b>Ed. Note: </b><xsl:apply-templates/></p>
  </blockquote>
</xsl:template>

<xsl:template match="edtext">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="code"><code><xsl:apply-templates/></code></xsl:template>

<xsl:template match="emph"><em><xsl:apply-templates/></em></xsl:template>

<xsl:template match="b"><b><xsl:apply-templates/></b></xsl:template>

<xsl:template match="quote"><quote><xsl:apply-templates/></quote></xsl:template>

<xsl:template match='link'>
  <a><xsl:if test='@href'>
    <xsl:attribute name='href'><xsl:value-of select='@href'/></xsl:attribute>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@name">
    <xsl:value-of  select='@name'/>
    </xsl:when>
    <xsl:otherwise>
    <xsl:value-of select='@href'/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test='@name'>
<!--     <xsl:attribute name='name'><xsl:value-of  select='@name'/></xsl:attribute> -->
  </xsl:if>
  <xsl:apply-templates/></a>
</xsl:template>

<xsl:template match='*'>
  <xsl:element name="SPAN">
    <xsl:attribute name="STYLE">color:red; background-color: white</xsl:attribute>
    <xsl:attribute name='TITLE'><xsl:value-of select="name()"/></xsl:attribute>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:element>
</xsl:template>

<xsl:template match="text()"><xsl:value-of select="."/></xsl:template>

<xsl:template match='processing-instruction()'/>

<xsl:template match='comment()'/>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->