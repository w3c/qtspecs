<?xml version="1.0"?>

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

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="xpath-functions-base.xsl"/>

<xsl:param name="strikeout.missing.functions" select="0"/>

<xsl:param name="additional.css"><xsl:text>
div.schemaComp  { border: 4px double gray;
                  margin: 0em 1em;
                  padding: 0em;
                }
div.compHeader  { margin: 4px;
                  font-weight: bold;
                }
span.schemaComp { color: #A52A2A;
                }
div.compBody    { border-top-width: 4px;
                  border-top-style: double;
                  border-top-color: #d3d3d3;
                  padding: 4px;
                  margin: 0em;
                }

div.exampleInner { background-color: #d5dee3;
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
code.arg         {
                 }
code.strikeout   { text-decoration: line-through;
                 }

</xsl:text>
</xsl:param>

<xsl:param name="toc.level" select="3"/>

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

<xsl:template match="specref">
  <xsl:variable name="target" select="id(@ref)[1]"/>

  <xsl:choose>
    <xsl:when test="local-name($target)='issue'">
      <xsl:if test="$target/@status != 'closed'">
        <xsl:apply-imports/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="body">
  <div class="body">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="header">
  <div class="head">
    <xsl:if test="not(/spec/@role='editors-copy')">
      <p>
        <a href="http://www.w3.org/">
          <img src="http://www.w3.org/Icons/w3c_home"
               alt="W3C" height="48" width="72"/>
        </a>
      </p>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <h1>
      <xsl:apply-templates select="title"/>
      <xsl:if test="version">
        <xsl:text>: Issues List </xsl:text>
        <xsl:apply-templates select="version"/>
      </xsl:if>
    </h1>
    <xsl:if test="subtitle">
      <xsl:text>&#10;</xsl:text>
      <h2>
        <xsl:apply-templates select="subtitle"/>
      </h2>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <h2>
      <xsl:apply-templates select="w3c-doctype"/>
      <xsl:text> </xsl:text>
      <xsl:if test="pubdate/day">
        <xsl:apply-templates select="pubdate/day"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="pubdate/month"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="pubdate/year"/>
    </h2>
    <dl>
<!--
      <xsl:apply-templates select="publoc"/>
      <xsl:apply-templates select="latestloc"/>
      <xsl:apply-templates select="prevlocs"/>
-->
      <xsl:apply-templates select="authlist"/>
    </dl>

    <xsl:choose>
      <xsl:when test="copyright">
        <xsl:apply-templates select="copyright"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="copyright">
          <a href="http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Copyright">
            <xsl:text>Copyright</xsl:text>
          </a>
          <xsl:text>&#xa0;&#xa9;&#xa0;</xsl:text>
          <xsl:apply-templates select="pubdate/year"/>
          <xsl:text>&#xa0;</xsl:text>
          <a href="http://www.w3.org/">
            <abbr title="World Wide Web Consortium">W3C</abbr>
          </a>
          <sup>&#xae;</sup>
          <xsl:text> (</xsl:text>
          <a href="http://www.lcs.mit.edu/">
            <abbr title="Massachusetts Institute of Technology">MIT</abbr>
          </a>
          <xsl:text>, </xsl:text>
          <a href="http://www.inria.fr/">
            <abbr lang="fr"
                  title="Institut National de Recherche en Informatique et Automatique">INRIA</abbr>
          </a>
          <xsl:text>, </xsl:text>
          <a href="http://www.keio.ac.jp/">Keio</a>
          <xsl:text>), All Rights Reserved. W3C </xsl:text>
          <a href="http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Legal_Disclaimer">liability</a>
          <xsl:text>, </xsl:text>
          <a href="http://www.w3.org/Consortium/Legal/ipr-notice-20000612#W3C_Trademarks">trademark</a>
          <xsl:text>, </xsl:text>
          <a href="http://www.w3.org/Consortium/Legal/copyright-documents-19990405">document use</a>
          <xsl:text>, and </xsl:text>
          <a href="http://www.w3.org/Consortium/Legal/copyright-software-19980720">software licensing</a>
          <xsl:text> rules apply.</xsl:text>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </div>
  <hr/>
</xsl:template>

<xsl:template match="div1"/>

<!-- The following template numbers and formats issues in the issues list -->

<xsl:template match="inform-div1">
 <xsl:apply-templates select="issue"> 
      <xsl:sort select="@status" order='descending'/>
	  <xsl:sort select="@priority" />
 </xsl:apply-templates> 
</xsl:template>

<xsl:template match='issue'>
  <div class="issue">
    <h3>
  	  <xsl:call-template name="anchor"/>
      <xsl:text>Issue </xsl:text>
      <xsl:apply-templates select="." mode="number"/>
      <xsl:if test="@status = 'closed'">
        <xsl:text> [Closed] </xsl:text>
      </xsl:if>
 	  <xsl:if test="@status != 'closed'">
        <xsl:text>, priority = </xsl:text>
        <xsl:value-of select='@priority'/> 
      </xsl:if>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="head"/>
      (<xsl:value-of select="@id"/>)
    </h3>

    <div class="issueBody">
      <xsl:if test="@status != 'closed'">

      <xsl:apply-templates select="*[local-name(.) != 'head']"/>

   <!--   <xsl:if test="not(resolution)">
        <p class="prefix">
          <b>
            <xsl:text>Resolution:</xsl:text>
          </b>
        </p>
        <p>None recorded.</p>
      </xsl:if> -->

      <xsl:if test="@status != 'closed'">
        <xsl:choose>
          <xsl:when test="key('specrefs', @id)">
            <p>
              <xsl:text>This issue occurs in </xsl:text>
              <xsl:for-each select="key('specrefs', @id)">
                <xsl:variable name="div" select="(ancestor::div5
                                                 |ancestor::div4
                                                 |ancestor::div3
                                                 |ancestor::div2
                                                 |ancestor::div1)[last()]"/>
                <xsl:if test="position() &gt; 1">, </xsl:if>
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="target" select="$div"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:apply-templates select="$div" mode="divnum"/>
                  <xsl:apply-templates select="$div/head" mode="text"/>
                </a>
              </xsl:for-each>
            </p>
          </xsl:when>
          <xsl:otherwise>
            <p>This issue is not referenced!</p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      </xsl:if>
    </div>
  </div>
 </xsl:template>

<xsl:template match="inform-div1//issue/table[1]">
  <xsl:variable name="id">
    <xsl:choose>
      <xsl:when test="ancestor::issue/@id">
        <xsl:value-of select="ancestor::issue/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id(ancestor::issue)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <table summary="Issue Summary">
    <xsl:apply-templates/>
  </table>
  <h4>
    <a name="{$id}-desc"/>
    <xsl:text>Description:</xsl:text>
  </h4>
</xsl:template>

<xsl:template match="p/loc" priority="1">
  <xsl:choose>
    <xsl:when test="@role='internal'">
      <a href="{@href}">
        <xsl:apply-templates/>
        <xsl:text> (W3C-members only)</xsl:text>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="{@href}"><xsl:apply-templates/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="edtext/loc" priority="1">
  <xsl:choose>
    <xsl:when test="@role='internal'">
      <a href="{@href}">
        <xsl:apply-templates/>
        <xsl:text> (W3C-members only)</xsl:text>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="{@href}"><xsl:apply-templates/></a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="code">
  <xsl:variable name="name">
    <xsl:choose>
      <xsl:when test="starts-with(., 'xf:')">
        <xsl:choose>
          <xsl:when test="contains(.,'(')">
            <xsl:value-of select="substring-before(substring-after(.,':'),'(')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-after(.,':')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="defined">
    <xsl:choose>
      <xsl:when test="$name = '' or @role = 'del'">1</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="target" select="id(concat('func-', $name))"/>
        <xsl:choose>
          <xsl:when test="count($target) = 0">0</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$defined = 0">
    <xsl:message>
      <xsl:text>Warning: no definition function/operator: </xsl:text>
      <xsl:value-of select="$name"/>
<!--
      <xsl:text>, </xsl:text>
      <xsl:value-of select="."/>
-->
    </xsl:message>
  </xsl:if>

  <code>
    <xsl:if test="$defined=0 and $strikeout.missing.functions != 0">
      <xsl:attribute name="class">strikeout</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </code>
</xsl:template>

<!-- ============================================================ -->

  <xsl:template match="table">
    <table summary="A table [this is bad style]">
      <xsl:for-each select="@*">
        <!-- Wait: some of these aren't HTML attributes after all... -->
        <xsl:if test="local-name(.) != 'diff'">
          <xsl:copy>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates/>

      <xsl:if test=".//footnote">
        <tbody>
          <tr>
            <td>
              <xsl:apply-templates select=".//footnote" mode="table.notes"/>
            </td>
          </tr>
        </tbody>
      </xsl:if>
    </table>
  </xsl:template>


</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->