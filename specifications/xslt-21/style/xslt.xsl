<?xml version="1.0" encoding="ISO-8859-1" ?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax"
        xmlns:g="http://www.martin-loetzsch.de/DOTML"
        exclude-result-prefixes="e xs g"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
>

<xsl:import href="../../../style/xsl-query.xsl"/>
<xsl:import href="../../../style/funcproto.xsl"/>
<xsl:import href="dotml2dot.xsl"/>

<xsl:output method="xml" indent="no" encoding="utf-8"/>
<xsl:output name="xml" method="xml" indent="no" encoding="utf-8"/>

<xsl:strip-space elements="e:*"/>


<!-- following two variables can be set to "yes" or "no" -->
<!--<xsl:param name="hide-deletions" select="'no'"/>-->
<!--<xsl:param name="color-changes" select="'yes'"/>-->

<!-- publication date in yyyy-mm-dd format -->
<xsl:param name="date" select="'2010-05-11'"/>

<!-- cutoff date for closed issues -->
<xsl:param name="cutoff-date" select="'2005-04-04'"/>

<!-- document life-cycle stage -->
<xsl:param name="stage" select="'WD'"/>

<xsl:variable name="yyyy" select="substring($date, 1, 4)"/>
<xsl:variable name="mm" select="substring($date, 6, 2)"/>
<xsl:variable name="dd" select="substring($date, 9, 2)"/>
<xsl:variable name="day" select="number($dd)"/>
<xsl:variable name="month" select="
('January', 'February', 'March', 'April', 'May', 'June', 'July', 
'August', 'September', 'October', 'November', 'December')[number($mm)]"/>

<xsl:template match="day">
  <xsl:value-of select="$day"/>
</xsl:template>

<xsl:template match="month">
  <xsl:value-of select="$month"/>
</xsl:template>

<xsl:template match="year">
  <xsl:value-of select="$yyyy"/>
</xsl:template>

<xsl:param name="additional.css">
<!-- not used when creating diff version. The additional CSS declarations are in diffspec.xsl -->
dd.indent { margin-left: 2em; }
p.element-syntax { border: solid thin; background-color: #ffccff }
div.proto { border: solid thin; background-color: #ffccff }
div.example { border: solid thin; background-color: #40e0d0; padding: 1em }
span.verb { font: small-caps 100% sans-serif } 
span.error { font: small-caps 100% sans-serif } 
span.definition { font: small-caps 100% sans-serif } 
span.grayed { color: gray }
</xsl:param>




<xsl:template match="edtext">
  <xsl:apply-templates/>
</xsl:template>

  <!-- termdef: sentence or phrase defining a term -->
  <xsl:template match="termdef">
    <span class="definition">[Definition:&#xa0;</span>
    <a name="{@id}" id="{@id}" title="{@term}"/>
    <xsl:apply-templates/>
    <span class="definition">]</span>
  </xsl:template>

  <!-- specref: reference to another part of the current specification -->
  <xsl:variable name="root" select="/"/>
  <xsl:template match="specref">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="target" select="$root/key('ids', $ref)[1]"/>

    <xsl:choose>
      <xsl:when test="local-name($target)='issue'">
        <xsl:text>[</xsl:text>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
          </xsl:attribute>
          <b>
            <xsl:text>Issue </xsl:text>
            <xsl:apply-templates select="$target" mode="number"/>
            <xsl:text>: </xsl:text>
            <xsl:for-each select="$target/head">
              <xsl:apply-templates/>
            </xsl:for-each>
          </b>
        </a>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(local-name($target), 'div')">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
          </xsl:attribute>
          <i>
            <xsl:apply-templates select="$target" mode="divnum"/>
            <xsl:apply-templates select="$target/head" mode="text"/>
          </i>
        </a>
      </xsl:when>
      <xsl:when test="starts-with(local-name($target), 'inform-div')">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
          </xsl:attribute>
          <i>
            <xsl:apply-templates select="$target" mode="divnum"/>
            <xsl:apply-templates select="$target/head" mode="text"/>
          </i>
        </a>
      </xsl:when>
      <xsl:when test="local-name($target) = 'vcnote'">
        <b>
          <xsl:text>[VC: </xsl:text>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="target" select="$target"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="$target/head" mode="text"/>
          </a>
          <xsl:text>]</xsl:text>
        </b>
      </xsl:when>
      <xsl:when test="local-name($target) = 'prod'">
        <b>
          <xsl:text>[PROD: </xsl:text>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="target" select="$target"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="$target" mode="number-simple"/>
          </a>
          <xsl:text>]</xsl:text>
        </b>
      </xsl:when>
      <xsl:when test="local-name($target) = 'label'">
        <b>
          <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="target" select="$target"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="$target"/>
          </a>
          <xsl:text>]</xsl:text>
        </b>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unsupported specref to </xsl:text>
          <xsl:value-of select="local-name($target)"/>
          <xsl:text> [</xsl:text>
          <xsl:value-of select="@ref"/>
          <xsl:text>] </xsl:text>
          <xsl:text> (Contact stylesheet maintainer).</xsl:text>
        </xsl:message>
        <b>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="target" select="$target"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text>???</xsl:text>
          </a>
        </b>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="change">
    <xsl:apply-templates/>
</xsl:template>

    <xsl:variable name="latest" 
        select="concat('http://www.w3.org/TR/', $yyyy, '/', 
                $stage, '-xslt-21-', $yyyy, $mm, $dd, '/')"/>

<xsl:template match="publoc">
	<dt>This version:</dt>
        <dd><a href="{$latest}"><xsl:value-of select="$latest"/></a></dd>
</xsl:template>				

<xsl:template match="elcode">
   <!--xsl:call-template name="diff"/-->
   <a href="#element-{substring-after(.,'xsl:')}"><code><xsl:value-of select="."/></code></a>
</xsl:template> 



<xsl:template match="processing-instruction('element-syntax-summary')">

<p>The syntax of each XSLT element is summarized below, together with the
context in the stylesheet where the element may appear. Some elements (specifically,
instructions) are allowed as a child of any element that is allowed to contain a sequence
constructor. These elements are:</p>

    <ul>
    <xsl:for-each select="//e:element-syntax[.//e:model[@name='content-constructor']]">
      <xsl:sort select="@name"/>
      <li><code>xsl:<xsl:value-of select="@name"/></code></li>
    </xsl:for-each>
    <li>Literal result elements</li>
    <li>Extension instructions, if so defined</li>
    </ul>
    
  <xsl:for-each select="//e:element-syntax[not(@name='example-element') and not(ancestor::*[@diff='del'])]">
    <xsl:sort select="@name"/>
    <p><b><a href="#element-{@name}">
        <xsl:text>xsl:</xsl:text><xsl:value-of select="@name"/>
      </a></b></p>
    <table width="100%"><tr><td width="10%">&#xa0;</td><td>
    <xsl:if test="e:in-category">
    <p><i>Category: </i><xsl:value-of select="e:in-category/@name"/></p>
    </xsl:if>
    <p><i>Model:</i></p>
    <p class="element-syntax-summary">
      <!--xsl:call-template name="diff"/-->
      <code>
      <xsl:text>&lt;</xsl:text>
      <xsl:text>xsl:</xsl:text><xsl:value-of select="@name"/>
      <xsl:apply-templates mode="top"/>
      </code>
    </p>
      <xsl:apply-templates select="e:allowed-parents"/>
    </td></tr></table>
  </xsl:for-each>
</xsl:template>

<xsl:template match="e:element-syntax">
  <p>
    <xsl:attribute name="class">
      <xsl:apply-templates select="." mode="get-diff-class"/>
    </xsl:attribute>
    <!--xsl:call-template name="diff"/-->
    <a name="element-{@name}"/><code>
    <xsl:apply-templates select="e:in-category"/>
    <xsl:text>&lt;xsl:</xsl:text><xsl:value-of select="@name"/>
    <xsl:apply-templates mode="top"/>
    </code>
  </p>
</xsl:template>
  
<xsl:template match="e:element-syntax" mode="get-diff-class">
  <xsl:text>element-syntax</xsl:text>
</xsl:template>

<xsl:template match="e:in-category">
<xsl:text>&lt;!-- Category: </xsl:text>
<xsl:value-of select="@name"/>
<xsl:text> --&gt;</xsl:text>
<br/>
</xsl:template>

<xsl:template match="e:sequence|e:choice|e:model|e:element|e:text" mode="top">
  <!-- close the start tag -->
  <xsl:if test="../e:attribute">&#xa0;</xsl:if>
  <xsl:text>&gt;</xsl:text>
  <br/>
  
  <!-- show the content model -->
  <xsl:text>&nbsp;&nbsp;&lt;!-- Content: </xsl:text>
  <xsl:apply-templates select="."/>
  <xsl:text> --&gt;</xsl:text>
  <br/>
  
  <!-- create an end tag -->
  <xsl:text>&lt;/xsl:</xsl:text>
  <xsl:value-of select="../@name"/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="e:sequence|e:choice">
  <xsl:call-template name="group"/><!--added mhk-->
  <xsl:text>(</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>)</xsl:text>
  <xsl:call-template name="repeat"/>
</xsl:template>

<xsl:template match="e:model">
<xsl:call-template name="group"/>
<var><xsl:value-of select="@name"/></var>
<xsl:call-template name="repeat"/>
</xsl:template>

<xsl:template match="e:text">#PCDATA</xsl:template>

<xsl:template match="e:element">
  <xsl:call-template name="group"/>
  <xsl:choose>
    <xsl:when test="contains(@name, ':')">
      <xsl:value-of select="@name"/>
    </xsl:when>
    <xsl:otherwise>
      <a href="#element-{@name}">
        <xsl:text>xsl:</xsl:text>
        <xsl:value-of select="@name"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="repeat"/>
</xsl:template>

<xsl:template name="group">
  <xsl:if test="position()>1">
  <xsl:choose>
    <xsl:when test="parent :: e:sequence">, </xsl:when>
    <xsl:when test="parent :: e:choice"> | </xsl:when>
  </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="repeat">
  <xsl:choose>
   <xsl:when test="@repeat='one-or-more'">
    <xsl:text>+</xsl:text>
   </xsl:when>
   <xsl:when test="@repeat='zero-or-more'">
    <xsl:text>*</xsl:text>
   </xsl:when>
   <xsl:when test="@repeat='zero-or-one'">
    <xsl:text>?</xsl:text>
   </xsl:when>
  </xsl:choose>
</xsl:template>


<xsl:template match="e:empty" mode="top">
<xsl:text>&nbsp;/&gt;</xsl:text>
</xsl:template>

<xsl:template match="e:attribute" mode="top">
  <br/>  
  <xsl:text>&nbsp;&nbsp;</xsl:text>
  <xsl:choose>
    <xsl:when test="@deprecated='yes'">
      <span class="grayed">[<xsl:value-of select="@name"/>]?</span>
    </xsl:when>
    <xsl:when test="@required='yes'">
      <b><xsl:value-of select="@name"/></b>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@name"/><xsl:text>?</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text> = </xsl:text> 
  <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="e:data-type">
<xsl:if test="position()>1"> | </xsl:if>
<var><xsl:value-of select="@name"/></var>
</xsl:template>

<xsl:template match="e:constant">
<xsl:if test="position()>1"> | </xsl:if>
<xsl:text>"</xsl:text>
<xsl:value-of select="@value"/>
<xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="e:attribute-value-template">
<xsl:text>{ </xsl:text>
<xsl:apply-templates/>
<xsl:text> }</xsl:text>
</xsl:template>

<xsl:template match="e:allowed-parents" mode="top"/>

<xsl:template match="e:allowed-parents">
<p><i>Permitted parent elements:</i></p>
<ul>
 <xsl:apply-templates/>
 <xsl:if test="not(*)"><li>None</li></xsl:if>
</ul>
</xsl:template>

<xsl:template match="e:parent">
  <li><a href="#element-{@name}">
    <xsl:text>xsl:</xsl:text>
    <xsl:value-of select="@name"/>
  </a></li>
</xsl:template>

<xsl:template match="e:parent-category[@name='sequence-constructor']">
<li>any XSLT element whose content model is <i>sequence constructor</i></li>
<li>any literal result element</li>
</xsl:template>

<xsl:template match="var">
<var><xsl:apply-templates/></var>
</xsl:template>

<xsl:template match="requirements">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="req">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="req-text">
<p><b><i>Requirement <xsl:number count="req"/></i></b></p>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="req-response">
<p><i>Response</i></p>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="processing-instruction('schema-for-xslt')">
<pre>
<xsl:variable name="schema" select="unparsed-text('../src/schema-for-xslt21.xsd', 'iso-8859-1')"/>
<xsl:value-of select="translate($schema, '&#xD;', '')"/>
</pre>
</xsl:template>

<xsl:template match="processing-instruction('glossary')">
    <dl>
    <xsl:for-each select="//termdef[not(ancestor-or-self::*[@diff][1][@diff='del'])]">
      <xsl:sort select="lower-case(@term)"/>
      <dt>
        <a href="#{@id}"><xsl:value-of select="@term"/></a>
      </dt>
      <dd>
        <p>
          <xsl:apply-templates/>
        </p>
      </dd>
    </xsl:for-each>
    </dl>
<!--
  <table width="100%" cellspacing="10">
      <xsl:for-each select="//termdef[not(ancestor-or-self::*[@diff][1][@diff='del'])]">
      <xsl:sort select="@term"/>
      <tr>
      <td width="20%" valign="top"><a href="#{@id}"><xsl:value-of select="@term"/></a></td>
      <td valign="top"><p><xsl:apply-templates/></p></td>
      </tr>
    </xsl:for-each>
  </table>
-->
</xsl:template>
  
  
  <xsl:template match="processing-instruction('xslt-defined-functions')">
      <xsl:variable name="content">
      <glist>
        <xsl:for-each-group select="//proto[not(ancestor-or-self::*[@diff][1][@diff='del'])]" group-by="@name">
          <xsl:sort select="current-grouping-key()"/>
          <gitem>
            <label>
              <function><xsl:value-of select="current-grouping-key()"/></function>
            </label>
            <def>See <specref ref="{(ancestor::*/@id)[last()]}"/></def>
          </gitem>
        </xsl:for-each-group>
      </glist>
      </xsl:variable>
      <xsl:apply-templates select="$content"/>
    </xsl:template>

    <xsl:variable name="issue-doc" select="document('../issue-list2.xml')"/>


	<xsl:template match="issue" use-when="false()">
	<xsl:variable name="detail" select="$issue-doc/issues/issue[@id=current()/@id]"/>
	<xsl:if test="$detail/@status != 'closed'">
	<div>
	        <!--xsl:call-template name="diff"/-->
		
		<blockquote>
			<p>
			<b><a href="#{@id}">Issue <xsl:value-of select="$detail/@number"/> (<xsl:value-of select="substring-after(@id,'-')"/>)</a>: </b>
			<xsl:apply-templates select="$issue-doc/issues/issue[@id=current()/@id]/description"/>
			</p>
		</blockquote>
    </div>
    </xsl:if>
	</xsl:template>
  
  <xsl:template match="issue">
    <xsl:param name="summary" select="false()"/>
      <blockquote>
        <p>
          <b>
            <xsl:choose>
              <xsl:when test="$summary">
                <a href="#{@id}">Issue <xsl:number level="any"/> (<xsl:value-of select="substring-after(@id,'-')"/>)</a>:
              </xsl:when>
              <xsl:otherwise>
                <a name="{@id}">Issue <xsl:number level="any"/> (<xsl:value-of select="substring-after(@id,'-')"/>)</a>:
              </xsl:otherwise>
            </xsl:choose>  
          </b>
        </p>
        <xsl:apply-templates/>
      </blockquote>
  </xsl:template>
	
	<xsl:template match="issue/description">
	<xsl:apply-templates/>
	</xsl:template>

<xsl:template match="processing-instruction('summary-of-open-issues')">
  <xsl:apply-templates select="//issue">
     <xsl:with-param name="summary" select="true()"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="processing-instruction('issues-list-open') |
                     processing-instruction('issues-list-closed') |
                     processing-instruction('issues-list-decided') ">
  <xsl:variable name="status" select="substring-after(name(),'issues-list-')"/>
  <xsl:variable name="list" select="$issue-doc/issues/issue[@status=$status]"/>
  <xsl:if test="not($list)">
    <p><i>There are no issues in this category.</i></p>
  </xsl:if>
  <xsl:for-each select="$list">
    <xsl:if test="not(@status='closed' and xs:date(@last-changed) lt xs:date($cutoff-date))">
        <p><b><a name="{@id}">Issue <xsl:value-of select="@number"/></a>: <xsl:value-of select="substring-after(@id, 'issue-')"/></b></p>
        <p><i>Description: </i><xsl:apply-templates select="description"/></p>
        <xsl:if test="source">
        <p><i>Origin: </i><xsl:apply-templates select="source"/></p>
        </xsl:if>
        <xsl:if test="proposal">
        <p><i>Suggested resolution: </i><xsl:apply-templates select="proposal"/></p>
        </xsl:if>
        <xsl:if test="resolution">
        <p><i>Resolution: </i><xsl:apply-templates select="resolution"/></p>
        </xsl:if>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="description | source | resolution | proposal">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="processing-instruction('error-summary')">
<p><b>Static errors</b></p>
<dl>
<xsl:apply-templates select="//error[@type='static'][not(ancestor::*[@diff='del'])]" mode="summary"/>
</dl>
<p><b>Type errors</b></p>
<dl>
<xsl:apply-templates select="//error[@type='type'][not(ancestor::*[@diff='del'])]" mode="summary"/>
</dl>
<p><b>Dynamic errors</b></p>
<dl>
<xsl:apply-templates select="//error[@type='dynamic'][not(ancestor::*[@diff='del'])]" mode="summary"/>
</dl>

<xsl:if test="//error[@type='serialization'][not(ancestor::*[@diff='del'])]">
<p><b>Serialization errors</b></p>
<dl>
<xsl:apply-templates select="//error[@type='serialization'][not(ancestor::*[@diff='del'])]" mode="summary"/>
</dl>
</xsl:if>

<xsl:if test="//error[not(@type)]">
  <p><b>Unclassified errors</b></p>
  <dl>
  <xsl:apply-templates select="//error[not(@type)]" mode="summary"/>
  </dl>
</xsl:if>
</xsl:template>

<xsl:template match="error">
  <!-- uri is specified only for xerrorref; make no ID -->
  <xsl:param name="uri" select="''"/>
  <xsl:variable name="label" select="concat(@spec, @class, @code)"/>

  <xsl:choose>
    <xsl:when test="$uri = ''">
      <a name="err-{$label}">
	<span class="error">[ERR <xsl:value-of select="$label"/>] </span>
      </a>
      <xsl:apply-templates select="p/child::node()"/>
    </xsl:when>
    <xsl:otherwise>
      <a href="{$uri}#ERR{@spec}{@class}{@code}" title="{$label}">
	<span class="error">[ERR <xsl:value-of select="$label"/>] </span>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="error.action">
<xsl:param name="omode" select="'body'"/>
<xsl:if test="$omode='body'">
<xsl:apply-templates/>
</xsl:if>
</xsl:template>

<xsl:template match="error" mode="summary">
  <xsl:variable name="label" select="concat(@spec, @class, @code)"/>
<dt><a href="#err-{$label}"><span class="error">ERR <xsl:value-of select="$label"/></span></a></dt>
<dd><p><xsl:apply-templates select="p/node()">
    <xsl:with-param name="omode" select="'summary'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="p/error.action" mode="action"/></p></dd>
</xsl:template>

<xsl:template match="error.action" mode="action">
<br/><i>&#xa0;&#xa0;&#xa0;&#xa0;Action: </i><xsl:apply-templates/>
</xsl:template>

<xsl:template match="error.extra">
<xsl:param name="omode" select="'body'"/>
<xsl:if test="$omode='summary'">
<xsl:text/> [<xsl:apply-templates/>] <xsl:text/>
</xsl:if>
</xsl:template>

<xsl:template match="errorref[not(@spec) or @spec='XT']">
  <span class="error">
      <xsl:text>[see </xsl:text>
      <a href="#err-XT{@class}{@code}">ERR XT<xsl:value-of select="concat(@class, @code)"/></a>
      <xsl:text>]</xsl:text>
  </span>
</xsl:template>

<xsl:template match="xnt[@spec='XML']">
  <a href="http://www.w3.org/TR/2000/REC-xml-20001006#NT-{@ref}">
     <xsl:apply-templates/>
  </a>
  <sup><small>XML</small></sup>
</xsl:template>

<xsl:template match="xnt[@spec='NS']">
  <a href="http://www.w3.org/TR/REC-xml-names/#NT-{@ref}">
     <xsl:apply-templates/>
  </a>
  <sup><small>XML</small></sup>
</xsl:template>

<xsl:template match="xnt[@spec='XP']">
  <a href="http://www.w3.org/TR/xpath20/#doc-xpath-{@ref}">
     <xsl:apply-templates/>
  </a>
  <sup><small>XP</small></sup>
</xsl:template>

<xsl:template match="xnt" mode="superseded">
    <xsl:choose>
    <xsl:when test="@spec='XP'">
      <a href="http://www.w3.org/TR/xpath20/#doc-xpath-{.}" target="XP">
         <xsl:apply-templates/>
         <!--<xsl:text>&#9658;</xsl:text>-->
         <sup><small>XP</small></sup>
      </a>
    </xsl:when>
    <xsl:when test="@spec='XML'">
      <a href="http://www.w3.org/TR/2000/REC-xml-20001006#NT-{.}" target="XML">
         <xsl:apply-templates/>
         <sup><small>XML</small></sup>
      </a>
    </xsl:when>  
    <xsl:when test="@spec='NS'">
      <a href="http://www.w3.org/TR/REC-xml-names/#NT-{.}" target="NS">
         <xsl:apply-templates/>
         <sup><small>NS</small></sup>
      </a>
    </xsl:when>        
    <xsl:otherwise>	
      <u><xsl:apply-templates/></u>
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="function">
<a href="#function-{.}"><code><xsl:apply-templates/></code></a>
</xsl:template>

<xsl:template match="xfunction">
<!--<u><xsl:value-of select="."/></u>-->
<xsl:variable name="fname" select="string(.)"/>
<xsl:variable name="link" select="(: if ($fname='id' or $fname='idref' or $fname='name') 
                                  then concat('xpath-', $fname)
                                  else :) $fname"/>
<a href="http://www.w3.org/TR/xpath-functions-11/#func-{$link}">
    <code><xsl:value-of select="."/></code>
</a><sup><small>FO</small></sup>
</xsl:template>
  
  <xsl:template match="termref">
    <a title="{key('ids', @def)/@term}" class="termref">
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="target" select="key('ids', @def)"/>
        </xsl:call-template>
      </xsl:attribute>
      <!--<span class="arrow">&#xB7;</span>-->
      <xsl:choose>
        <xsl:when test=". = ''">
          <xsl:value-of select="key('ids', @def)/@term"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <!--<span class="arrow">&#xB7;</span>-->
    </a>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Cross-spec references -->

<xsl:template match="xspecref" mode="superseded">
  <!-- temporary code -->
  <u><xsl:value-of select="@ref"/><sup><xsl:value-of select="@spec"/></sup></u>
  <xsl:text>[link to be supplied]</xsl:text>
</xsl:template>

<xsl:template match="xtermref" mode="superseded">
  <!-- temporary code -->
  <u><xsl:apply-templates/></u>
  <xsl:text> [link to be supplied]</xsl:text>
</xsl:template>


	<xsl:template match="loc[.='' or not(@href)]">
	    <xsl:variable name="href" select="concat(@href, .)"/>
		<a href="{$href}"><xsl:value-of select="$href"/></a>
		<xsl:if test="contains($href, 'Member/w3c-xsl-wg')"><b> (members only) </b></xsl:if>
	</xsl:template>

	<xsl:template match="publoc/loc | latestloc/loc | prevlocs/loc | errata/loc" priority="2">
			<a href="{@href}">
			<xsl:choose>
			<xsl:when test=".!=''"><xsl:apply-templates/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
			</xsl:choose>
			</a>
			<br/>
	</xsl:template>

  <xsl:template match="altlocs">
    <p>
      <xsl:text>This document is also available </xsl:text>
      <xsl:text>in these non-normative formats: </xsl:text>
      <xsl:for-each select="loc">
        <xsl:if test="position() &gt; 1">
          <xsl:if test="last() &gt; 2">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="last() = 2">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="position() = last() and position() &gt; 1">and&#160;</xsl:if>
        <!-- next line changed by MHK -->
        <xsl:apply-templates select="."/>
      </xsl:for-each>
      <xsl:text>.</xsl:text>
    </p>
  </xsl:template>
	
	<xsl:template match="altlocs/loc">
	        <a href="{$latest}{@href}"><xsl:value-of select="."/></a>
	</xsl:template>

<xsl:template match="imp-def-feature"/>

<xsl:template match="processing-instruction('implementation-defined-features')">
<ol>
    <xsl:for-each select="//imp-def-feature[not(ancestor::*[@diff='del'])]">
      <xsl:variable name="ref">
        <specref ref="{(ancestor::*[@id])[last()]/@id}"/>
      </xsl:variable>
      <li><p>
          <xsl:apply-templates/>
          <xsl:text> (See </xsl:text>
            <xsl:apply-templates select="$ref/specref"/> <!-- uses XSLT 2.0 feature! -->
          <xsl:text>)</xsl:text>
      </p></li>
    </xsl:for-each>
</ol>
</xsl:template>

<xsl:param name="show.diff.markup">0</xsl:param>

<xsl:template match="example[@diff and ($show.diff.markup='1')]" priority="-1000">
  <table width="100%"><tr>
  <td width="10%">
    <!--xsl:call-template name="diff"/-->
    <xsl:text>&#xa0;</xsl:text>
  </td>
  <td>
    <div class="example">
    <xsl:apply-templates/>
    </div>
  </td>
  <td width="10%">
    <!--xsl:call-template name="diff"/-->
    <xsl:text>&#xa0;</xsl:text>
  </td>
  </tr></table>
</xsl:template>

<xsl:template match="example">
<xsl:if test="preceding-sibling::*[1][self::example]">
  <p>&#xa0;</p>
</xsl:if>
  <div class="{if (@diff and ($show.diff.markup='1')) then 'example-chg' else 'example'}">
    <xsl:apply-templates/>
</div>
</xsl:template>

  <!-- note: a note about the spec -->
  
  <!-- rfc 2119 keywords (must, may, should, ...) -->
  
  <xsl:template match="rfc2119">
    <!-- now available in xmlspec19.xsl, which uses <strong> rendition -->
    <span class="verb"><xsl:apply-templates/></span>
  </xsl:template>


<xsl:template match="proto">
    <!-- MHK addition -->
    <xsl:if test="not(preceding-sibling::*[1][self::proto][@name=current()/@name])">
    <a name="function-{@name}" id="function-{@name}"/>
    </xsl:if>
    <xsl:if test="preceding-sibling::*[1][self::proto]"><p/></xsl:if>
    <!-- end MHK addition -->
  <xsl:variable name="prefix">
    <xsl:choose>
      <xsl:when test="@class = 'op'">op:</xsl:when>
      <xsl:when test="@class = 'schema'">xs:</xsl:when>
      <xsl:when test="@class = 'func'">fn:</xsl:when>
      <xsl:when test="@class = 'dm'">dm:</xsl:when>
      <xsl:otherwise><!-- no prefix: changed by MHK --></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="stringvalue">
    <xsl:apply-templates select="." mode="stringify"/>
  </xsl:variable>

  <!-- If the prototype is going to be "too long", use a tabular presentation -->

  <div class="proto">
    <xsl:choose>
      <xsl:when test="string-length($stringvalue) &gt; 70">
        <table border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td valign="baseline">
              <xsl:if test="count(arg) &gt; 1">
                <xsl:attribute name="rowspan">
                  <xsl:value-of select="count(arg)"/>
                </xsl:attribute>
              </xsl:if>

              <code class="function">
                <xsl:value-of select="$prefix"/>
                <xsl:value-of select="@name"/>
              </code>
              <xsl:text>(</xsl:text>
            </td>

            <xsl:choose>
              <xsl:when test="arg">
                <xsl:apply-templates select="arg[1]" mode="tabular"/>
              </xsl:when>
              <xsl:otherwise>
                <td valign="baseline">
                  <xsl:text>)</xsl:text>

                  <xsl:if test="@return-type != 'none'">
                    <code class="as">&#160;as&#160;</code>
                    <code class="return-type">
                      <xsl:choose>
                        <xsl:when test="id(@return-type)">
                          <a>
                            <xsl:attribute name="href">
                              <xsl:call-template name="href.target">
                                <xsl:with-param name="target"
                                                select="id(@return-type)"/>
                              </xsl:call-template>
                            </xsl:attribute>
                            <xsl:value-of select="@return-type"/>
                          </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="@return-type"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                      <xsl:if test="@returnSeq='yes'">*</xsl:if>
                    </code>
                  </xsl:if>
                </td>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
          <xsl:for-each select="arg[position() &gt; 1]">
            <tr>
              <xsl:apply-templates select="." mode="tabular"/>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <code class="function">
          <xsl:value-of select="$prefix"/>
          <xsl:value-of select="@name"/>
        </code>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
        <xsl:if test="@return-type != 'none'">
          <code class="as">&#160;as&#160;</code>
          <code class="return-type">
            <xsl:choose>
              <xsl:when test="id(@return-type)">
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="target"
                                      select="id(@return-type)"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:value-of select="@return-type"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@return-type"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
            <xsl:if test="@returnSeq='yes'">*</xsl:if>
          </code>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>
  
<!-- Handle DotML graphs -->
  
<xsl:template match="*/g:graph">
  <!-- The */g:graph ensures we only match a g:graph in the original source document, and not one created by this rule itself -->
  <xsl:variable name="preprocessed-graph">
    <xsl:apply-templates select="." mode="preprocess-dotml"/>
  </xsl:variable>
  <!--<xsl:message select="$preprocessed-graph"/>-->
  <xsl:variable name="n" select="count(preceding::g:graph) + 1"/>
  
  <xsl:result-document href="img/fig{$n}.dot" method="text">
    <!-- invoke template in imported DotML stylesheet -->
    <xsl:apply-templates select="$preprocessed-graph/g:graph"/>
  </xsl:result-document>
  
  <xsl:variable name="svgfile" select="concat('img/fig', $n, '.svg')"/>
  <object type="image/svg+xml" codetype="image/svg+xml" data="{$svgfile}">
      <xsl:copy-of select="@width, @height"/>
      <span style="background-color:#FFFF20;padding-top:1pt;padding-bottom:1pt;">This browser can't
        display the SVG file <xsl:value-of select="$svgfile"/>. 
        Please upgrade your browser or install the Adobe SVG Viewer.
      </span>
  </object>
</xsl:template>
  
<xsl:template match="g:*" mode="preprocess-dotml">
   <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="preprocess-dotml"/>
   </xsl:copy>
</xsl:template>
  
  <xsl:template match="g:node" mode="preprocess-dotml">
    <xsl:copy>
      <xsl:copy-of select="@* except @edge-color"/>
      <xsl:if test="empty(@id)">
        <xsl:attribute name="id" select="generate-id(.)"/>
      </xsl:if>
    </xsl:copy>
    <xsl:apply-templates mode="preprocess-dotml"/>
    <xsl:for-each select="g:node">
       <g:edge from="{g:node-id(..)}" to="{g:node-id(.)}" >
         <xsl:if test="@edge-color">
           <xsl:attribute name="color" select="@edge-color"/>
         </xsl:if>
       </g:edge>
    </xsl:for-each>    
  </xsl:template>
  
  <xsl:function name="g:node-id" as="xs:string">
    <xsl:param name="node" as="element(g:node)"/>
    <xsl:sequence select="($node/@id, generate-id($node))[1]"/>
  </xsl:function>
  
  <xsl:template match="eg">
    <xsl:variable name="max-length"
      select="max(for $line in tokenize(., '\n') return string-length($line))"/>
    <xsl:if test="$max-length gt 75">
      <!-- ideally, get this down to 60 -->
      <xsl:message>*** WARNING: code example has max line length <xsl:value-of select="$max-length"/> 
        at <xsl:value-of select="(ancestor::*/@id)[last()]"/> 
        (example <xsl:value-of select="ancestor::example/head"/>)</xsl:message>
    </xsl:if>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>
