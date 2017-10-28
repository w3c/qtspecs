<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rddl="http://www.rddl.org/"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
  version="2.0">

  <!-- Rewritten MHK Nov 2015 to use the function catalogs in the FO and XSLT specs as the basic source -->

  <xsl:import href="xpath-functions.xsl"/>
  <xsl:import href="../../../style/ns-blank-2017.xsl"/>

  <xsl:param name="specdoc" select="'FONS'"/>
  
  <xsl:param name="pubdate" select="xs:date('2017-03-21')"/>

  <xsl:variable name="fando-base" select="//loc[contains(.,'Functions and Operators')][1]/@href"/>

  <xsl:variable name="xslt-base" select="//loc[contains(.,'XSL Transformations')][1]/@href"/>

  <xsl:variable name="fando" select="document('xpath-functions-expanded.xml',.)"/>
  <xsl:variable name="fando-functions" select="document('function-catalog.xml',.)"/>
  <xsl:variable name="xslt" select="document('../../xslt-30/src/xslt.xml',.)"/>
  <xsl:variable name="xslt-functions" select="document('../../xslt-30/src/function-catalog.xml',.)"/>
  <xsl:variable name="protos"
    select="$fando//proto[not(@role)
				                  or @role != 'example']"/>
  <xsl:variable name="xprotos"
    select="$xslt//proto[not(@role)
				                  or @role != 'example']"/>

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
    <xsl:message>
      <xsl:value-of select="$XSLTprocessor"/>
    </xsl:message>
    <xsl:comment><xsl:value-of select="$XSLTprocessor"/></xsl:comment>
    <xsl:apply-templates/>
  </xsl:template>
 
  
  <xsl:template match="header/pubdate">
    <h2><xsl:value-of select="format-date(xs:date('2017-03-21'), '[D] [MNn] [Y]')"/></h2>
  </xsl:template>



  <xsl:template match="processing-instruction('fo-function-summary')">
    <xsl:apply-templates select="$fando-functions//fos:function[not(@prefix) or @prefix='fn']">
      <xsl:sort select="@name" lang="en"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="processing-instruction('xslt-function-summary')">
    <xsl:apply-templates select="$xslt-functions//fos:function[not(@prefix) or @prefix='fn']">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="processing-instruction('xquery-update-function-summary')">
    <xsl:apply-templates select="$fn-put//fos:function">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:variable name="fn-put">
    <fos:function name="put" prefix="fn" >
      <fos:signatures>
        <fos:proto name="put" return-type="empty-sequence()">
          <fos:arg name="node" type="node()" usage="absorbtion"/>
          <fos:arg name="uri" type="xs:string"/>
        </fos:proto>
      </fos:signatures>
      <fos:summary>
        <p>Stores a document or element to the location specified by <code>$uri</code>. This function is normally invoked to create a resource 
          on an external storage system such as a file system or a database.</p>
          
          <p>The external effects of <code>fn:put</code> are implementation-defined, since they occur outside the domain of XQuery. 
            The intent is that, if <code>fn:put</code> is invoked on a document node and no error is raised, a subsequent query can access 
            the stored document by invoking <code>fn:doc</code> with the same URI.</p>

      </fos:summary>
      <fos:rules>
        <p/>
      </fos:rules>

    </fos:function>
  </xsl:variable>


  <xsl:template match="fos:function">
    <xsl:param name="doc-base"/>
    <rddl:resource xlink:role="http://www.rddl.org/natures#term"
      xlink:arcrole="http://www.rddl.org/purposes#definition"
      xlink:title="Function named fn:{@name}" xlink:href="{$doc-base}#func-{@name}">
      <h3>
        <a name="{@name}" id="{@name}"/>
        <xsl:value-of select="@name"/>
      </h3>
      <xsl:apply-templates select="fos:signatures/fos:proto"/>
      <xsl:apply-templates select="fos:summary/node()"/>

    </rddl:resource>
  </xsl:template>

  <xsl:template match="fos:proto">
    <p>
      <strong>
        <xsl:value-of select="@name"/>
      </strong>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="fos:arg">
        <xsl:if test="position() != 1">, </xsl:if>
        <xsl:value-of select="@type"/>
      </xsl:for-each>
      <xsl:text>) as </xsl:text>
      <xsl:value-of select="@return-type"/>
    </p>
  </xsl:template>


  <!-- Everything below here is PROBABLY no longer needed. MHK Nov 2015 -->

  <!-- Hacks for XSLT -->

  <xsl:template match="elcode">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="xfunction">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- /Hacks for XSLT -->

  <xsl:template match="termref">
    <xsl:choose>
      <xsl:when test=". = ''">
        <xsl:value-of select="key('ids', @def)/@term"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="bibref">
    <xsl:text>[</xsl:text>
    <xsl:choose>
      <xsl:when test="key('ids', @ref)/@key">
        <xsl:value-of select="key('ids', @ref)/@key"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@ref"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="error" name="make-error-ref">
    <xsl:param name="uri" select="''"/>

    <xsl:variable name="spec">
      <xsl:choose>
        <xsl:when test="@spec">
          <xsl:value-of select="@spec"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default.specdoc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="@class">
          <xsl:value-of select="@class"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="code">
      <xsl:choose>
        <xsl:when test="@code">
          <xsl:value-of select="@code"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>??</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="label">
      <!-- CREATES LABEL IN XQUERY STYLE -->
      <xsl:text>err:</xsl:text>
      <xsl:value-of select="$spec"/>
      <xsl:value-of select="$class"/>
      <xsl:value-of select="$code"/>
    </xsl:variable>

    <xsl:text>[</xsl:text>
    <xsl:value-of select="$label"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="code">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>
  
  <xsl:function name="fos:spec-date" as="xs:date">
    <xsl:param name="spec-id"/>
    <xsl:variable name="bib-entry" select="doc('../../../etc/xsl-query-bibl.xml')//bibl[@id = substring-before($spec-id, '-ref')]"/>
    <xsl:variable name="date" select="replace(normalize-space($bib-entry), '^.*This version is https://www.w3.org/TR/.*?([0-9]{8,8})/.*$', '$1', 'm')"/>
    <xsl:message select="'**DATE: ', $date"/>
    <xsl:sequence select="xs:date(concat(substring($date,1,4), '-', substring($date,5,2), '-', substring($date, 7, 2)))"/>
  </xsl:function>
  
  <!--<xsl:template match="div1[@id='normrefs']/blist/bibl">
    <xsl:variable name="date" select="fos:spec-date(@id)"/>
    <xsl:variable name="date8" select="format-date($date, '[Y0001][M01][D01]')"/>
    <!-\-<xsl:variable name="href" select="doc('../../../etc/xsl-query-bibl.xml')//bibl[@id = substring-before(@id, '-ref')]//a[.='latest version']/@href"/>-\->
    <xsl:variable name="href" select="concat('https://www.w3.org/TR/', substring-before(@id, '-ref'), '/')"/>
      <dt class="label"><span><a name="{@id}" id="{@id}"></a><xsl:value-of select="@key"/></span></dt>
      <dd>
        <div class="resource">
          
          <rddl:resource xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rddl="http://www.rddl.org/" xlink:title="{@key}" xlink:role="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional" xlink:arcrole="http://www.rddl.org/purposes#normative-reference" xlink:href="{$href}" xlink:type="simple" xlink:embed="none" xlink:actuate="none">
            
            <p><a href="{$href}"><xsl:value-of select="@key"/></a>
              (<xsl:value-of select="format-date($date, '[D] [MNn] [Y]')"/> version)
            </p>
            
          </rddl:resource>
          
        </div>
      </dd>
    
  </xsl:template>-->
  
  <!--<bibl id="xpath-functions-31-ref" key="XPath and XQuery Functions and Operators 3.1" class="resource">
    <rddl:resource xlink:title="XPath and XQuery Functions and Operators 3.1"
      xlink:role="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional"
      xlink:arcrole="http://www.rddl.org/purposes#normative-reference"
      xlink:href="&fo.loc;">
      <p><loc href="&fo.loc.dated;">XPath and XQuery Functions and Operators 3.1</loc>
        (&fo.spec.date.day; &fo.spec.date.month; &fo.spec.date.year; version)</p>
    </rddl:resource>
  </bibl>
-->
</xsl:stylesheet>
