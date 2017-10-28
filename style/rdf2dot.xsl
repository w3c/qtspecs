<?xml version='1.0'?><!-- -*- mode: indented-text;-*- -->
<xsl:transform
    xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:web  ="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:util ="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:g    ="http://www.w3.org/2001/02pd/gv#"
    >

<xsl:variable name="RCSId"
  select='"$Id: rdf2dot.xsl,v 1.2 2008/09/26 00:57:39 jmelton Exp $"'/>
<xsl:param name="Debug" select='0'/>

<div xmlns="http://www.w3.org/1999/xhtml">

<pre>
This transformation groks a limited subset of RDF:
  -- just one level of nesting (no Description/typedNodes
     as values of properties)
  -- properties are sorted by subject, collected
     in a Description element for that subject
  -- rdf:ID is not used; only rdf:about
  -- only absolute URIs are used

Arbitrary RDF can be converted to this form using
	  cwm --rdf foo.rdf --bySubject --base=bogus: > foo-limited.rdf

see <a href="http://www.w3.org/2000/10/swap/">Semantic Web Area for Play</a>
for details about cwm.
</pre>

<address>Dan Connolly <br class=""/>
$Id: rdf2dot.xsl,v 1.2 2008/09/26 00:57:39 jmelton Exp $</address>
</div>

<xsl:output method="text"/>

<xsl:param name="GVns"
	   select='"http://www.w3.org/2001/02pd/gv#"'/>

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

<xsl:template match="/web:RDF">
  <xsl:text>/* transformed by by </xsl:text>
  <xsl:value-of select='substring($RCSId, 2, string-length($RCSId)-2)'/>
  <xsl:text> */
</xsl:text>

  <xsl:for-each select="*/g:digraph/@web:resource">

    <!-- I suspect there's a way to use xsl:key instead
         of this /web:RDF/*[@web:about="..."] idiom
      -->
    <xsl:variable name="it" select="/web:RDF/*[@web:about=current()]"/>

    <xsl:text>digraph </xsl:text>
    <xsl:call-template name="eachGraph">
      <xsl:with-param name="it" select='$it'/>
    </xsl:call-template>

  </xsl:for-each>
</xsl:template>

<xsl:template name="eachGraph">
  <xsl:param name="it"/>
  <xsl:param name="cluster"/>

  <xsl:value-of select='concat($cluster, generate-id($it))'/>
  <xsl:text> {
</xsl:text>

  <!-- graph attributes see Graphviz spec table 1 -->
  <xsl:for-each select='$it/*[namespace-uri() = $GVns and (
			      local-name() = "center"
		           or local-name() = "clusterrank"
		           or local-name() = "color"
		           or local-name() = "concentrate"
		           or local-name() = "fillcolor"
		           or local-name() = "fontcolor"
		           or local-name() = "fontname"
		           or local-name() = "fontsize"
		           or local-name() = "label"
		           or local-name() = "layerseq"
		           or local-name() = "margin"
		           or local-name() = "mclimit"
		           or local-name() = "nodesep"
		           or local-name() = "nslimit"
		           or local-name() = "ordering"
		           or local-name() = "orientation"
		           or local-name() = "page"
		           or local-name() = "rank"
		           or local-name() = "rankdir"
		           or local-name() = "ranksep"
		           or local-name() = "ratio"
		           or local-name() = "size"
			   )]'> <!--@@ ...others-->
    <xsl:value-of select='local-name()'/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select='.'/> <!-- @@quoting? -->
    <xsl:text>";
</xsl:text>
  </xsl:for-each>

  <!-- explicit nodes -->
  <xsl:for-each select="$it/g:hasNode/@web:resource">
    <xsl:variable name="nodeURI" select='current()'/>
    <xsl:variable name="nodeElt" select='/web:RDF/*[@web:about=$nodeURI]'/>
    <xsl:if test='$nodeElt'>
      <xsl:call-template name="eachNode">
        <xsl:with-param name="graphElt" select='$it'/>
        <xsl:with-param name="nodeElt" select='$nodeElt'/>
        <xsl:with-param name="nodeURI" select='$nodeURI'/>
      </xsl:call-template>
    </xsl:if>
  </xsl:for-each>

  <xsl:for-each select="$it/g:subgraph/@web:resource">
    <xsl:variable name="it2" select="/web:RDF/*[@web:about=current()]"/>

    <xsl:text>subgraph </xsl:text>
    <xsl:call-template name="eachGraph">
      <xsl:with-param name="it" select='$it2'/>
      <xsl:with-param name="cluster" select='"cluster"'/>
    </xsl:call-template>

  </xsl:for-each>

    <xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template name="eachNode">
  <xsl:param name="graphElt"/>
  <xsl:param name="nodeElt"/>
  <xsl:param name="nodeURI"/>

  <xsl:text>"</xsl:text>
  <xsl:value-of select='$nodeURI'/>
  <xsl:text>" [</xsl:text>

  <!-- node attributes -->
  <xsl:for-each select='$nodeElt/*[namespace-uri() = $GVns and (
                                   local-name() = "label"
			        or local-name() = "color"
				or local-name() = "fillcolor"
				or local-name() = "shape"
				or local-name() = "style"
				or local-name() = "fontcolor"
				or local-name() = "fontname"
				or local-name() = "fontsize"
				or local-name() = "height"
				or local-name() = "width"
				or local-name() = "layer"
				or local-name() = "URL"
				or local-name() = "sides"
				or local-name() = "shapefile")
				]'> <!-- "URL" not in the original file format docs, but seems to be supported; cf http://www.graphviz.org/webdot/tut2.html-->
    <xsl:value-of select='local-name()'/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select='.'/> <!-- @@quoting? -->
    <xsl:text>",
</xsl:text>
  </xsl:for-each>
  <xsl:text>];
</xsl:text>

  <!-- edges -->
  <xsl:for-each select="$nodeElt/*[@web:resource]"> <!-- iterate over all properties -->
    <!-- compute full name of property -->
    <xsl:variable name="obj" select='./@web:resource'/>
    <xsl:variable name="pred" select='concat(namespace-uri(),  local-name())'/>


    <xsl:if test='$Debug>4'>
    <xsl:message>propertyElt in nodeElt:
      subj: <xsl:value-of select='$nodeURI'/>
      pred: <xsl:value-of select='$pred'/>
    </xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test='$graphElt/g:hasEdgeProperty/@web:resource=$pred'>
        <xsl:call-template name="doEdge">
          <xsl:with-param name="nodeURI" select='$nodeURI'/>
          <xsl:with-param name="pred" select='$pred'/>
          <xsl:with-param name="obj" select='$obj'/>
          <xsl:with-param name="edgeElt" select='/web:RDF/*[@web:about=$pred]'/>
          </xsl:call-template>

      </xsl:when>


      <xsl:when test='/web:RDF/g:EdgeProperty[@web:about=$pred]'>

        <xsl:message>
	  <xsl:value-of select='$pred'/> is an EdgeProperty.
	  A given property might be used to make edges
	  in one graph and not in another; so
	  EdgeProperty(p) isn't well-defined those p's.
	  It seems that edge-ness is a function of the
	  graph and the property; i.e. a relation between
	  them.

	  So EdgeProperty is deprecated... use hasEdgeProperty.

	  @@oops... what about g:style, g:label, etc... should
	  those be a function of the property and the graph?
	  Or should we have edgeLabel and nodeLabel properties?
	  Hmm...
	</xsl:message>

        <xsl:call-template name="doEdge">
          <xsl:with-param name="nodeURI" select='$nodeURI'/>
          <xsl:with-param name="pred" select='$pred'/>
          <xsl:with-param name="obj" select='$obj'/>
          <xsl:with-param name="edgeElt" select='/web:RDF/*[@web:about=$pred]'/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test='/web:RDF/*[@web:about=$pred]/web:type
                       [@web:resource=concat($GVns, "EdgeProperty")]'>
        <xsl:message>
	  <xsl:value-of select='$pred'/> is an EdgeProperty.

	  A given property might be used to make edges
	  in one graph and not in another; so
	  EdgeProperty(p) isn't well-defined those p's.
	  It seems that edge-ness is a function of the
	  graph and the property; i.e. a relation between
	  them.

	  So EdgeProperty is deprecated... use hasEdgeProperty

	  @@oops... what about g:style, g:label, etc... should
	  those be a function of the property and the graph?
	  Or should we have edgeLabel and nodeLabel properties?
	  Hmm... maybe
		 my:graph g:nodeType my:Marbles;
		    g:edgeType my:GEdgeProp;
		    g:labelProp my:label;
		    g:styleProp my:styleProp;
	</xsl:message>

        <xsl:call-template name="doEdge">
          <xsl:with-param name="nodeURI" select='$nodeURI'/>
          <xsl:with-param name="pred" select='$pred'/>
          <xsl:with-param name="obj" select='$obj'/>
          <xsl:with-param name="edgeElt" select='/web:RDF/*[@web:about=$pred]'/>
          </xsl:call-template>

      </xsl:when>

      <xsl:otherwise>
        <!-- nothing -->
      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each>

</xsl:template>

<xsl:template name="doEdge">
        <xsl:param name="nodeURI"/>
        <xsl:param name="pred"/>
        <xsl:param name="obj"/>
        <xsl:param name="edgeElt"/>

          <xsl:if test='$Debug>4'>
            <xsl:message>EdgeProperty:
              pred: <xsl:value-of select='$pred'/>
              obj: <xsl:value-of select='$obj'/>
            </xsl:message>
          </xsl:if>

	     <xsl:text>"</xsl:text>
             <xsl:value-of select='$nodeURI'/>
	     <xsl:text>" -&gt; "</xsl:text>
	     <xsl:value-of select='$obj'/>
	     <xsl:text>"</xsl:text>


             <xsl:text> [ /* edge attributes */
</xsl:text>
             <!-- edge attributes all except id -->
             <xsl:for-each select='$edgeElt/*[local-name() = "label"
			          or local-name() = "color"
			          or local-name() = "decorate"
			          or local-name() = "dir"
			          or local-name() = "fillcolor"
			          or local-name() = "fontcolor"
			          or local-name() = "fontname"
			          or local-name() = "fontsize"
			          or local-name() = "layer"
			          or local-name() = "minlen"
			          or local-name() = "style"
			          or local-name() = "weight"
				  ]'> <!--@@ ...others-->
               <xsl:value-of select='local-name()'/>
               <xsl:text>="</xsl:text>
               <xsl:value-of select='.'/> <!-- @@quoting? -->
               <xsl:text>",
</xsl:text>
             </xsl:for-each>
             <xsl:text>];
</xsl:text>
</xsl:template>



<!-- don't pass text thru -->
<xsl:template match="text()|@*">
</xsl:template>


</xsl:transform>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->