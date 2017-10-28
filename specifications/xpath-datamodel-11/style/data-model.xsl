<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:import href="../../../style/xsl-query.xsl"/>
  <xsl:include href="../../../style/funcproto.xsl"/>

  <xsl:output indent="no"/>

  <xsl:param name="show.revisions" select="0"/>
  <xsl:param name="show.issues" select="1"/>
  <xsl:param name="show.recent.issues" select="'2002-11-15'"/>

  <xsl:param name="additional.css">
    <style type="text/css">
      .termdef     { color: rgb(133,0,033);
                   }
      .aside       { border-left: 4px solid green;
                     background-color: #EEFFEE;
                     padding-left: 1em;
                     font-size: small;
                   }

      .node-summary table       { margin-left: 1em;
                                }
      .node-summary thead td    { font-weight: bold;
                                }
      .node-summary td          { padding-left: 1em;
                                  padding-right: 1em;
                                  border-bottom: 1px solid gray;
                                }

      .infoset-mapping table    { margin-left: 1em;
                                }
      .infoset-mapping thead td { font-weight: bold;
                                }
      .infoset-mapping td       { padding-left: 1em;
                                  padding-right: 1em;
                                }

      .issue-closed             { color: green;
                                }

      .issue-resolved           { color: red;
                                }

      .issue-open               { color: red;
                                }

div.schemaComp  { border: 4px double gray;
                  margin: 0em 1em;
                  padding: 0em;
                }
div.compHeader  { margin: 4px;
                  font-weight: bold;
                }
span.schemaComp { background-color: white;
                  color: #A52A2A;
                }
div.compBody    { border-top-width: 4px;
                  border-top-style: double;
                  border-top-color: #d3d3d3;
                  padding: 4px;
                  margin: 0em;
                }

div.exampleInner { background-color: #d5dee3;
                   color: black;
                   border-top-width: 4px;
                   border-top-style: double;
                   border-top-color: #d3d3d3;
                   border-bottom-width: 4px;
                   border-bottom-style: double;
                   border-bottom-color: #d3d3d3;
                   padding: 4px;
                   margin: 0em;
                 }

div.issueBody    { margin-left: 0.25in;
                 }

code.function    { font-weight: bold;
                 }
code.return-type { font-style: italic;
                 }
code.type        { font-style: italic;
                 }
code.as          { font-style: normal;
                 }
code.arg         {
                 }
code.strikeout   { text-decoration: line-through;
                 }
p.table.footnote { font-size: 8pt;
                 }

span.function    { font-family: monospace;
                 }

span.prefix      { font-style: italic;
                 }

table.hierarchy  { font-size: x-small;
                 }

td.castOther     { background-color: yellow;
                   color: black;
                 }

tr.document               { background-color: #FFD4EA; }
tr.element                { background-color: #96E3D1; }
tr.attribute              { background-color: #E7E6FF; }
tr.text                   { background-color: #FFFFC2; }
tr.processing-instruction { background-color: #E5FDFE; }
tr.comment                { background-color: #E1E1E1; }
tr.namespace              { background-color: #E7E6FF; }

    </style>
  </xsl:param>

  <!-- ====================================================================== -->
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

  <xsl:template name="additional-head">
    <xsl:apply-templates select="//div1" mode="links"/>
    <xsl:apply-templates select="//inform-div1" mode="links"/>

    <xsl:variable name="number-of-appendices"
		  select="count(/spec/back/div1 | /spec/back/inform-div1)"/>

    <link rel="TableOfContents" href="#accessors-list">
      <xsl:attribute name="title">
	<xsl:number value="$number-of-appendices + 1" format="A "/>
	<xsl:text> Accessor Summary</xsl:text>
      </xsl:attribute>
    </link>

    <link rel="TableOfContents" href="#infoset-construction-summary">
      <xsl:attribute name="title">
	<xsl:number value="$number-of-appendices + 2" format="A "/>
	<xsl:text> Infoset Construction Summary</xsl:text>
      </xsl:attribute>
    </link>

    <link rel="TableOfContents" href="#psvi-construction-summary">
      <xsl:attribute name="title">
	<xsl:number value="$number-of-appendices + 3" format="A "/>
	<xsl:text> PSVI Construction Summary</xsl:text>
      </xsl:attribute>
    </link>

    <link rel="TableOfContents" href="#infoset-mapping-summary">
      <xsl:attribute name="title">
	<xsl:number value="$number-of-appendices + 4" format="A "/>
	<xsl:text> Infoset Mapping Summary</xsl:text>
      </xsl:attribute>
    </link>
  </xsl:template>

  <xsl:template match="div1|inform-div1" mode="links">
    <link rel="TableOfContents">
      <xsl:attribute name="title">
	<xsl:apply-templates select="." mode="divnum"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="head"/>
      </xsl:attribute>
      <xsl:attribute name="href">
	<xsl:call-template name="href.target"/>
      </xsl:attribute>
    </link>
    <xsl:apply-templates select="div2" mode="links"/>
  </xsl:template>

  <xsl:template match="div2" mode="links">
    <link rel="TableOfContents">
      <xsl:attribute name="title">
	<xsl:apply-templates select="." mode="divnum"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="head"/>
      </xsl:attribute>
      <xsl:attribute name="href">
	<xsl:call-template name="href.target"/>
      </xsl:attribute>
    </link>
  </xsl:template>

  <!-- ====================================================================== -->

  <xsl:template match="revisiondesc">
    <xsl:if test="$show.revisions != 0">
      <div>
        <h2>
          <a name="revisions">Revision History</a>
        </h2>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="issue" mode="specref">
    <xsl:variable name="issueref">
      <xsl:text>[</xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target"/>
        </xsl:attribute>
        <xsl:value-of select="@id"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="head" mode="text"/>
      </a>
      <xsl:text>]</xsl:text>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@status = 'closed'">
        <xsl:copy-of select="$issueref"/>
        <xsl:text> (closed)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <b>
          <xsl:copy-of select="$issueref"/>
        </b>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="emph[@role='dm-node-property']">
    <b class="dm-node-prop"><xsl:apply-templates /></b>
  </xsl:template>

  <xsl:template match="emph[@role='info-item']">
    <b class="info-item"><xsl:apply-templates /></b>
  </xsl:template>

  <xsl:template match="emph[@role='infoset-property']">
    <b class="infoset-property">[<xsl:apply-templates />]</b>
  </xsl:template>

  <xsl:template match="emph[@role='psvi-property']">
    <span class="psvi-property">{<xsl:apply-templates />}</span>
  </xsl:template>

  <xsl:template match="p[@role='definition']">
    <div class="aside">
      <xsl:copy-of select="@id"/>
      <pre>
        <xsl:apply-templates/>
      </pre>
    </div>
  </xsl:template>

  <!-- note: a note about the spec -->
  <xsl:template match="note">
    <blockquote>
    <table width="90%" summary="Note"><tr>
      <!--<td width="10%">&#xa0;</td>-->
      <td width="10%" align="left" valign="top"><b>Note:</b></td>
      <td align="left" valign="top"><xsl:apply-templates/></td>
    </tr></table>
    </blockquote>
  </xsl:template>

  <!-- ednote: editors' note -->
  <xsl:template match="ednote">
    <xsl:if test="$show.ednotes != 0">
    <blockquote>
    <table width="100%" summary="Editorial note"><tr>
      <!--<td width="10%">&#xa0;</td>-->
      <td width="10%" align="left" valign="top"><b>Ed. Note:</b></td>
      <td align="left" valign="top"><xsl:apply-templates select="edtext"/></td>
    </tr></table>
    </blockquote>
    </xsl:if>
  </xsl:template>

  <!-- hack loc -->
  <xsl:template match="loc">
    <a href="{@href}">
      <xsl:choose>
        <xsl:when test="count(child::node())=0">
          <xsl:value-of select="@href"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

<xsl:template match="processing-instruction('glossary')">
  <table width="100%" summary="Glossary">
    <xsl:for-each select="//termdef[not(ancestor-or-self::*[@diff][1][@diff='del'])]">
      <xsl:sort select="@term"/>
      <tr>
        <td width="20%" valign="top">
          <a href="#{@id}"><xsl:value-of select="@term"/></a>
        </td>
        <td valign="top">
          <p><xsl:apply-templates/></p>
        </td>
      </tr>
    </xsl:for-each>
  </table>
</xsl:template>

  <!-- changed templates to auto generate an appendix with a list
       of links to open issues. -->
  <xsl:template name="autogenerated-appendices-toc">
    <xsl:variable name="number-of-appendices"
                  select="count(../back/div1 | ../back/inform-div1)"/>

<!--
    <xsl:if test="$show.issues != 0 and //issue[@status='closed']">
      <xsl:number value="$number-of-appendices + 1" format="A "/>
      <a href="#recently-closed-issues">Recently Closed Issues</a>
      <xsl:text> (Non-normative)</xsl:text>
      <br/>
    </xsl:if>
-->

    <xsl:number value="$number-of-appendices + 1" format="A "/>
    <a href="#accessors-list">Accessor Summary</a>
    <xsl:text> (Non-normative)</xsl:text>
    <br/>

    <xsl:number value="$number-of-appendices + 2" format="A "/>
    <a href="#infoset-construction-summary">Infoset Construction Summary</a>
    <xsl:text> (Non-normative)</xsl:text>
    <br/>

    <xsl:number value="$number-of-appendices + 3" format="A "/>
    <a href="#psvi-construction-summary">PSVI Construction Summary</a>
    <xsl:text> (Non-normative)</xsl:text>
    <br/>

    <xsl:number value="$number-of-appendices + 4" format="A "/>
    <a href="#infoset-mapping-summary">Infoset Mapping Summary</a>
    <xsl:text> (Non-normative)</xsl:text>
    <br/>
  </xsl:template>

  <xsl:template name="autogenerated-appendices">
<!--
    <xsl:if test="$show.issues != 0">
      <xsl:if test="$show.recent.issues != '' and //issue[@status='closed']">
        <xsl:variable name="issues"
                      select="//issue[@status = 'closed'
                              and ((substring(resolution/@date,1,4) &gt;
                                    substring($show.recent.issues,1,4))
                                   or ((substring(resolution/@date,1,4) =
                                        substring($show.recent.issues,1,4))
                                       and (substring(resolution/@date,6,2) &gt;
                                            substring($show.recent.issues,6,2)))
                                   or ((substring(resolution/@date,1,4) =
                                        substring($show.recent.issues,1,4))
                                       and (substring(resolution/@date,6,2) =
                                            substring($show.recent.issues,6,2))
                                       and (substring(resolution/@date,9,2) &gt;=
                                            substring($show.recent.issues,9,2))))]"/>

        <div class="div1">
          <xsl:text>&#10;</xsl:text>
          <h2>
            <a name="recently-closed-issues"/>
            <xsl:number value="count(../back/div1 | ../back/inform-div1) + 1" format="A "/>
            <xsl:text>Recently Closed Issues (Non-Normative)</xsl:text>
          </h2>
          <p>
            <xsl:text>There are </xsl:text>
            <xsl:value-of select="count($issues)"/>
            <xsl:text> recently closed issues. </xsl:text>
            <xsl:text>These issues have been resolved </xsl:text>
            <xsl:text>since the last publication.</xsl:text>
          </p>
          <xsl:apply-templates select="$issues">
            <xsl:with-param name="force" select="1"/>
            <xsl:sort select="@id"/>
          </xsl:apply-templates>
        </div>
      </xsl:if>
    </xsl:if>
-->

    <div class="div1">
      <xsl:variable name="app-num">
        <xsl:number value="count(../back/div1 | ../back/inform-div1) + 1" format="A"/>
      </xsl:variable>

      <h2>
        <a name="accessors-list"/>
        <xsl:value-of select="$app-num"/>
        <xsl:text> Accessor Summary (Non-Normative)</xsl:text>
      </h2>

      <p>This section summarizes the return values of each accessor by
      node type.</p>

      <xsl:variable name="summary-lists" select="//glist[@role='accessors']"/>
      <xsl:variable name="items" select="$summary-lists[1]/gitem"/>

      <xsl:for-each select="$items">
        <xsl:variable name="the-item" select="."/>

	<div>
	  <h3 id="acc-summ-{label}">
	    <xsl:value-of select="$app-num"/>
	    <xsl:text>.</xsl:text>
	    <xsl:value-of select="position()"/>
	    <xsl:text> </xsl:text>
	    <a href="#dm-{label}">
	      <em>dm:</em>
	      <xsl:value-of select="label"/>
	    </a>
	    <xsl:text> Accessor</xsl:text>
	  </h3>

	  <dl>
	    <xsl:for-each select="$summary-lists">
	      <xsl:variable name="pick-item"
			    select="gitem[string(label) = string($the-item/label)]"/>
	      <dt>
		<a href="#{ancestor::div2/@id}">
		  <xsl:value-of select="ancestor::div2/head"/>
		</a>
	      </dt>
	      <dd>
		<xsl:apply-templates select="$pick-item/def/*"/>
	      </dd>
	    </xsl:for-each>
	  </dl>
	</div>
      </xsl:for-each>
    </div>

    <div class="div1">
      <xsl:variable name="app-num">
        <xsl:number value="count(../back/div1 | ../back/inform-div1) + 2" format="A"/>
      </xsl:variable>

      <h2>
        <a name="infoset-construction-summary"/>
        <xsl:value-of select="$app-num"/>
        <xsl:text> Infoset Construction Summary (Non-Normative)</xsl:text>
      </h2>

      <p>This section summarizes data model construction from an Infoset for each
kind of information item.
General notes <a href="#const-infoset">occur elsewhere</a>.</p>

      <xsl:for-each select="//div3[head = 'Construction from an Infoset']">
	<div>
	  <h3>
	    <a name="auto-{@id}"/>
	    <xsl:value-of select="$app-num"/>
	    <xsl:text>.</xsl:text>
	    <xsl:value-of select="position()"/>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="../head"/>
	    <xsl:text> Information Items</xsl:text>
	  </h3>

	  <xsl:apply-templates select="*[not(self::head)]"/>
	</div>
      </xsl:for-each>
    </div>

    <div class="div1">
      <xsl:variable name="app-num">
        <xsl:number value="count(../back/div1 | ../back/inform-div1) + 3" format="A"/>
      </xsl:variable>

      <h2>
        <a name="psvi-construction-summary"/>
        <xsl:value-of select="$app-num"/>
        <xsl:text> PSVI Construction Summary (Non-Normative)</xsl:text>
      </h2>

      <p>This section summarizes data model construction from a PSVI
      for each kind of information item. General notes
      <a href="#const-psvi">occur elsewhere</a>.</p>

      <xsl:for-each select="//div3[head = 'Construction from a PSVI']">
	<div>
	  <h3>
	    <a name="auto-{@id}"/>
	    <xsl:value-of select="$app-num"/>
	    <xsl:text>.</xsl:text>
	    <xsl:value-of select="position()"/>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="../head"/>
	    <xsl:text> Information Items</xsl:text>
	  </h3>

	  <xsl:apply-templates select="*[not(self::head)]"/>
	</div>
      </xsl:for-each>
    </div>

    <div class="div1">
      <xsl:variable name="app-num">
        <xsl:number value="count(../back/div1 | ../back/inform-div1) + 4" format="A"/>
      </xsl:variable>

      <h2>
        <a name="infoset-mapping-summary"/>
        <xsl:value-of select="$app-num"/>
        <xsl:text> Infoset Mapping Summary (Non-Normative)</xsl:text>
      </h2>

      <p>This section summarizes the infoset mapping for each kind of
      node. General notes <a href="#infoset-mapping">occur
      elsewhere</a>.</p>

      <xsl:for-each select="//div3[head = 'Infoset Mapping']">
	<div>
	  <h3>
	    <a name="auto-{@id}"/>
	    <xsl:value-of select="$app-num"/>
	    <xsl:text>.</xsl:text>
	    <xsl:value-of select="position()"/>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="../head"/>
	    <xsl:text> Information Items</xsl:text>
	  </h3>

	  <xsl:apply-templates select="*[not(self::head)]"/>
	</div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="issue" mode="issues-list">
    <li>
      <a href="#{@id}"><xsl:value-of select="@id"/>:
      <xsl:value-of select="head"/></a>
    </li>
  </xsl:template>

  <xsl:template match="issue">
    <xsl:param name="force" select="0"/>

    <xsl:variable name="id" select="@id"/>

    <xsl:if test="$force != 0 or @status != 'closed'">
      <div class="issue">
        <p>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="@status='closed'">issue-closed</xsl:when>
              <xsl:when test="resolution">issue-resolved</xsl:when>
              <xsl:otherwise>issue-open</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <a name="{@id}"/>
          <xsl:apply-templates select="head" mode="issue-head"/>
        </p>

        <div style="margin-left:3em; margin-right:3em">
          <p>
            <b>Date:</b>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@date"/>
          </p>

          <p>
            <b>Raised by:</b>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@raisedby"/>
          </p>

          <xsl:if test="not(resolution) and //specref[@ref=$id]">
            <p>
              <b>Effects:</b>
            </p>
            <ul>
              <xsl:for-each select="//specref[@ref=current()/@id]">
                <xsl:for-each select="ancestor::*[head][1]">
                  <li>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:call-template name="href.target">
                          <xsl:with-param name="target" select="."/>
                        </xsl:call-template>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="self::issue">
                          <b>
                            <xsl:value-of select="@id"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="head"/>
                          </b>
                        </xsl:when>
                        <xsl:otherwise>
                          <b>
                            <xsl:apply-templates select="." mode="divnum"/>
                            <xsl:apply-templates select="head" mode="text"/>
                          </b>
                        </xsl:otherwise>
                      </xsl:choose>
                    </a>
                  </li>
                </xsl:for-each>
              </xsl:for-each>
            </ul>
          </xsl:if>

          <xsl:apply-templates/>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="issue/head" mode="issue-head">
    <b>Issue-<xsl:value-of select="substring-after(../@id,'-')"/>: </b>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="issue/head">
    <!-- nop -->
  </xsl:template>

  <xsl:template match="issue/p[1]">
    <p>
      <b>Description: </b>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="resolution">
    <div class="resolution">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="resolution/p[1]">
    <p>
      <b>Resolution: </b>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

<xsl:template match="function">
  <xsl:variable name="fname">
    <xsl:choose>
      <xsl:when test="contains(., '(')">
        <xsl:value-of select="substring-before(., '(')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <span class="function">
    <xsl:choose>
      <xsl:when test="contains($fname, ':')">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="id(concat('dm-', $fname))">
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="target" select="id(concat('dm-', $fname))"/>
                </xsl:call-template>
              </xsl:attribute>
              <span class="prefix">dm:</span>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <span class="prefix">dm:</span>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="inform-div1">
  <xsl:choose>
    <xsl:when test="$show.issues != 0">
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="contains(head,'Issues')">
      <xsl:message>Suppressing issue division!</xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="td|tr">
  <xsl:element name="{local-name(.)}">
    <xsl:for-each select="@*">
      <!-- Wait: some of these aren't HTML attributes after all... -->
      <xsl:if test="local-name(.) != 'diff'
		    and local-name(.) != 'role'">
	<xsl:attribute name="{name(.)}">
	  <xsl:value-of select="."/>
	</xsl:attribute>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="@role">
      <xsl:attribute name="class">
        <xsl:value-of select="@role"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- ====================================================================== -->

<!-- Special support for the hierarchy tables -->

<xsl:template match="table[@role='hierarchy']">
  <table class="hierarchy" summary="Type Hierarchy">
    <xsl:for-each select="@*">
      <!-- Wait: some of these aren't HTML attributes after all... -->
      <xsl:if test="local-name(.) != 'diff'
                    and local-name(.) != 'role'">
        <xsl:copy/>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
  </table>
</xsl:template>

<xsl:template match="td[ancestor::table/@role='hierarchy']">

  <td class="castOther" align="left" valign="middle">
    <xsl:apply-templates/>
  </td>
</xsl:template>

</xsl:stylesheet>
