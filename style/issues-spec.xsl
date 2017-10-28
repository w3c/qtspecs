<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!-- xsl:import href="issues.xsl"/ -->
  <!-- xsl:import href="xmlspec.xsl"/ -->

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

  <xsl:template match="issue">
    <xsl:call-template name="lcissues-issue"/>
  </xsl:template>

  <xsl:template match="issues/header" mode="frontmatter">
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

    <p>
      <xsl:text>(parameters used:</xsl:text>
      <xsl:text> kwSort: </xsl:text><xsl:value-of select="$kwSort"/>
      <xsl:text>, kwFull: </xsl:text><xsl:value-of select="$kwFull"/>
      <xsl:text>, kwDate: </xsl:text><xsl:value-of select="$kwDate"/>
      <xsl:text>).</xsl:text>
    </p>
    <xsl:text>&#10;</xsl:text>
    <hr/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <xsl:template match="issues">
    <!-- xsl:variable name="issues" select="//issue[normalize-space($spec)=normalize-space(@locus)]"/ -->
    <xsl:variable name="issues" select="//issue"/>
    <xsl:choose>
      <xsl:when test="not($kwDate = '00000000')">
        <xsl:call-template name="do_issues">
          <xsl:with-param name="issues_to_process" select="$issues[@last-modified &gt; $kwDate]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$kwFull = 'brief'">
        <xsl:call-template name="do_issues">
          <xsl:with-param name="issues_to_process" select="$issues[not(contains('resolved postponed subsumed abandoned',@status))]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$kwFull = 'full'">
        <xsl:call-template name="do_issues">
          <xsl:with-param name="issues_to_process" select="$issues"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do_issues">
          <xsl:with-param name="issues_to_process" select="$issues[contains($kwFull,@status)]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match='input'>
    <p>
      <xsl:choose>
        <xsl:when test="@href and (contains(@href, '/Member/') or contains(@href, '/Group/'))">
          <xsl:text>[link to member only information</xsl:text>
          <xsl:if test="@name">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:if>
          <xsl:text>] </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:attribute name='href'>
              <xsl:value-of select='@href'/>
            </xsl:attribute>
            <xsl:text>Input from </xsl:text>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:value-of select='@author'/>
      <xsl:text>:</xsl:text>
    </p>
    <div style='margin-left: 2em; margin-right: 2em;'>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match='decision'>
    <p>
      <small>
        <xsl:text>Decision by: </xsl:text>
        <b><xsl:value-of select="@decider"/></b>
        <xsl:text> on </xsl:text>
        <xsl:value-of select="@date"/>
        <xsl:if test='@href'>
          <xsl:text> (</xsl:text>
          <xsl:choose>
            <xsl:when test="@href and (contains(@href, '/Member/') or contains(@href, '/Group/'))">
              <!-- xsl:text>[link to member only information</xsl:text>
                   <xsl:if test="@name">
                     <xsl:text>: </xsl:text>
                     <xsl:value-of select="@name"/>
                   </xsl:if>
                   <xsl:text>] </xsl:text -->
              <a href="{@href}"><xsl:value-of select="@href"/>
              <xsl:text> (W3C-members only)</xsl:text></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{@href}"><xsl:value-of select="@href"/></a>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </small>
      <xsl:apply-templates/>
    </p>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <xsl:template match='link'>
    <xsl:choose>
      <xsl:when test="@href and (contains(@href, '/Member/') or contains(@href, '/Group/'))">
        <!-- xsl:text>[link to member only information</xsl:text>
        <xsl:if test="@name">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="@name"/>
        </xsl:if>
        <xsl:text>] </xsl:text -->
        <a href="{@href}">
          <xsl:apply-templates/>
          <xsl:text> (W3C-members only)</xsl:text>
        </a>
      </xsl:when>
      <xsl:when test="@href and starts-with(@href, '#') and 
                      //issue[contains('resolved postponed subsumed abandoned', @status)]
                      [normalize-space(@keyword) = normalize-space(substring-after(current()/@href, '#'))]">
        <xsl:text>[link to </xsl:text>
        <xsl:value-of select="//issue[@keyword = substring-after(current()/@href, '#')]/@status"/>
        <xsl:text> issue</xsl:text>
        <xsl:if test="@href">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="@href"/>
        </xsl:if>
        <xsl:text>] </xsl:text>
      </xsl:when>
      <xsl:when test="@href and 
                      //issue[contains('resolved postponed subsumed abandoned', @status)]
                      [normalize-space(@keyword) = normalize-space(current()/@href)]">
        <xsl:text>[link to </xsl:text>
        <xsl:value-of select="//issue[@keyword = current()/@href]/@status"/>
        <xsl:text> issue</xsl:text>
        <xsl:if test="@href">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="@href"/>
        </xsl:if>
        <xsl:text>] </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<!--
  <xsl:template match='interaction'>
    <xsl:choose>
      <xsl:when test="//issue[contains('resolved postponed subsumed abandoned', @status)]
                      [normalize-space(@keyword) = normalize-space(current()/@issue)]">
        <p>
          <xsl:text>Cf. </xsl:text>
          <xsl:value-of select='id(@issue)/title'/>
        </p>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
-->

<xsl:template match='description'>
  <h3>
    <xsl:call-template name="add-name-anchor"/>
    <xsl:text>Description</xsl:text>
  </h3>
  <div>
   <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match='references'>
  <h3>
    <xsl:call-template name="add-name-anchor"/>
    <xsl:text>Interactions and Input</xsl:text>
  </h3>
  <div>
   <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match='proposal'>
  <h3>
    <xsl:call-template name="add-name-anchor"/>
    <xsl:text>Proposed Resolution</xsl:text>
  </h3>
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match='resolution'>
  <h3>
    <xsl:call-template name="add-name-anchor"/>
    <xsl:text>Actual Resolution</xsl:text>
  </h3>
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

<xsl:template match="action[@status='active']">
  <h3>
    <xsl:call-template name="add-name-anchor"/>
    <xsl:text>Action</xsl:text>
  </h3>
  <p><small>Responsible: <b><xsl:value-of select="@responsible"/></b><br/>
  Target date for Completion: <b><xsl:value-of select="@target-date"/></b></small></p>
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="interaction">
  <!-- empty for now -->
</xsl:template>

<xsl:template match="issue//link[not(*)]">
  <xsl:variable name="issue" select="id(substring-after(@href,'#'))"/>
  <xsl:choose>
    <xsl:when test="$issue/@status = 'resolved'">
      <xsl:message>Cannot point to resolved issue: <xsl:value-of select="@href"/></xsl:message>
      <xsl:text>[resolved issue </xsl:text>
      <xsl:value-of select="@href"/>
      <xsl:text>]</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <a href="{@href}"><xsl:value-of select="@href"/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

  <xsl:template name="add-name-anchor">
    <xsl:param name="val" select="''"/>
    <a>
      <xsl:call-template name="add-name-attribute">
        <xsl:with-param name="val" select="$val"/>
      </xsl:call-template>
    </a>
  </xsl:template>

  <xsl:template name="add-name-attribute">
    <xsl:param name="val" select="''"/>
    <xsl:attribute name="name">
      <xsl:choose>
        <xsl:when test="$val">
          <xsl:value-of select="$val"/>
        </xsl:when>
        <xsl:when test="@id">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:when test="../@id">
          <xsl:value-of select="../@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('id-', name(..), '-', generate-id())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>


</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->