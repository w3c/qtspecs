<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:import href="../../../style/xmlspec-override.xsl"/>
   
   <xsl:output method="xml" encoding="utf-8"/>

   <xsl:param name="show-markup" select="'0'"/>
   <xsl:variable name="show.diff.markup" select="$show-markup cast as xs:integer"/>

   <xsl:param name="xpath-doc" select="'http://www.w3.org/TR/xpath20/'"/>
   <xsl:param name="xquery-doc" select="'http://www.w3.org/TR/xquery/'"/>

   <xsl:param name="spec" select="'FS'"/>
   <xsl:param name="core-doc" select="''"/>
   <xsl:param name="formal-doc" select="''"/>

   <xsl:param name="position-xpath" select="'&#160;(XPath)'"/>
   <xsl:param name="position-xquery" select="'&#160;(XQuery)'"/>
   <xsl:param name="position-core" select="'&#160;(Core)'"/>
   <xsl:param name="position-formal" select="'&#160;(Formal)'"/>

   <xsl:key name="ids" match="*[@id]" use="@id"/>

  <xsl:param name="additional.css">
    <style type="text/css">
table.small    { font-size: x-small; }

a.judgment:visited, a.judgment:link { font-family: sans-serif;
                              	      color: black; 
                              	      text-decoration: none }
a.processing:visited, a.processing:link { color: black; 
                              		  text-decoration: none }
a.env:visited, a.env:link { color: black; 
                            text-decoration: none }
    </style>
  </xsl:param>

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

<!-- This template is used to remove all elements that are marked for deletion -->
  <xsl:template match="*[@diff]">
    <xsl:choose>
      <xsl:when test="@diff='del'">
        <xsl:if test="$show.diff.markup != 0">
          <xsl:apply-imports/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--
+++++++++++++++++++++++++

Inclusions

+++++++++++++++++++++++++
-->

   <!-- Denise's role attribute handling removed -->

   <!-- Avoid empty align-attributes to the degree necessary for netscape -->
<!-- ndw thinks this is unnecessary and broken!
   <xsl:template match="table">
      <table summary="{@summary}">
          <xsl:if test="@cellspacing">
             <xsl:attribute name="cellspacing">
                <xsl:value-of select="@cellspacing"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@cellpadding">
             <xsl:attribute name="cellpadding">
                <xsl:value-of select="@cellpadding"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@align">
             <xsl:attribute name="align">
  	        <xsl:value-of select="@align"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@border">
             <xsl:attribute name="border">
  	        <xsl:value-of select="@border"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
      </table>
   </xsl:template>

   <xsl:template match="td">
      <td>
          <xsl:if test="@align">
             <xsl:attribute name="align">
  	        <xsl:value-of select="@align"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@valign">
             <xsl:attribute name="valign">
  	        <xsl:value-of select="@valign"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@nowrap">
             <xsl:attribute name="nowrap">
  	        <xsl:value-of select="@nowrap"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@colspan">
             <xsl:attribute name="colspan">
  	        <xsl:value-of select="@colspan"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@id">
	      <a name="{@id}"/>
          </xsl:if>
         <xsl:apply-templates/>
      </td>
   </xsl:template>
   
   <xsl:template match="tr">
      <tr>
          <xsl:if test="@align">
             <xsl:attribute name="align">
  	        <xsl:value-of select="@align"/>
             </xsl:attribute>
          </xsl:if>
          <xsl:if test="@valign">
             <xsl:attribute name="valign">
  	        <xsl:value-of select="@valign"/>
             </xsl:attribute>
          </xsl:if>
         <xsl:apply-templates/>
      </tr>
   </xsl:template>
-->
   
   <xsl:template match="br">
     <br/>
   </xsl:template>

   <!-- additions to xmlspec -->
   <xsl:template match="specref">
      <xsl:variable name="target" select="key('ids',@ref)[1]"/>
      <a href="#{@ref}">
         <xsl:choose>
            <xsl:when test="key('ids',@ref)[name()='queryissue']">
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:value-of select="@ref"/>:&#160;
                  <xsl:apply-templates select="key('ids',@ref)/head" mode="text"/>
<!-- DD: I changed this implementation because my XSL processor
     (Saxon) couldn't handle it; the above is simpler anyway.
                  <xsl:for-each select="key('ids',@ref)/head">
                     <xsl:apply-templates select=".." mode="number"/>
                     <xsl:apply-templates/>
                  </xsl:for-each>
-->
               </b>
               <xsl:apply-templates/>
               <xsl:text>]</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(local-name($target), 'div') or starts-with(local-name($target), 'inform-div')">
	       <b>[<xsl:apply-templates select="key('ids',@ref)" mode="divnum"/>
                   <xsl:apply-templates select="key('ids',@ref)/head" mode="text"/>]</b>
	    </xsl:when>
<!-- DD: I changed this implementation because my XSL processor
     (Saxon) couldn't handle it; the above is simpler anyway.
            <xsl:when test="key('ids',@ref)/head">
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:for-each select="key('ids',@ref)/head">
                     <xsl:apply-templates select=".." mode="number"/>
                     <xsl:apply-templates/>
                  </xsl:for-each>
               </b>
               <xsl:apply-templates/>
               <xsl:text>]</xsl:text>
            </xsl:when>
-->
<!-- Added Figure explicitely and a Missing Reference case - Jerome -->
            <xsl:when test="key('ids',@ref)/caption">
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:text>Figure&#160;</xsl:text>
                  <xsl:for-each select="key('ids',@ref)/caption">
                     <xsl:apply-templates select=".." mode="fignumber"/>
                  </xsl:for-each>
               </b>
               <xsl:apply-templates/>
               <xsl:text>]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:text>Missing Reference :</xsl:text>&#160;
                  <xsl:value-of select="@ref"/>
               </b>
               <xsl:apply-templates/>
               <xsl:text>]</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </a>
   </xsl:template>

<!--
   <xsl:template match="table[@variant='figure']">
      <xsl:choose>
         <xsl:when test="caption">
            <blockquote>
               <hr size="2"/>
               <div align="center">
                  <a name="{@id}"/>
                  <xsl:choose>
                     <xsl:when test="@align">
                        <table summary="{@summary}">
                    	   <xsl:if test="@cellspacing">
                    	      <xsl:attribute name="cellspacing">
                    		 <xsl:value-of select="@cellspacing"/>
                    	      </xsl:attribute>
                    	   </xsl:if>
                    	   <xsl:if test="@cellpadding">
                    	      <xsl:attribute name="cellpadding">
                    		 <xsl:value-of select="@cellpadding"/>
                    	      </xsl:attribute>
                    	   </xsl:if>
                           <xsl:apply-templates/>
                        </table>
                     </xsl:when>
                     <xsl:otherwise>
                        <table summary="{@summary}">
                    	   <xsl:if test="@cellspacing">
                    	      <xsl:attribute name="cellspacing">
                    		 <xsl:value-of select="@cellspacing"/>
                    	      </xsl:attribute>
                    	   </xsl:if>
                    	   <xsl:if test="@cellpadding">
                    	      <xsl:attribute name="cellpadding">
                    		 <xsl:value-of select="@cellpadding"/>
                    	      </xsl:attribute>
                    	   </xsl:if>
                           <xsl:apply-templates/>
                        </table>
                     </xsl:otherwise>
                  </xsl:choose>
               </div>
               <div align="center">
                  <br/>
                  <hr size="2"/>
                  <xsl:text>Figure&#160;</xsl:text>
                  <xsl:apply-templates select="." mode="fignumber"/>
                  <xsl:text>:&#160;</xsl:text>
                  <xsl:value-of select="caption"/>
                  <br/>
                  <hr size="2"/>
               </div>
            </blockquote>
         </xsl:when>
         <xsl:otherwise>
            <div align="center">
                <table summary="{@summary}">
                    <xsl:if test="@cellspacing">
                       <xsl:attribute name="cellspacing">
                          <xsl:value-of select="@cellspacing"/>
                       </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@cellpadding">
                       <xsl:attribute name="cellpadding">
                          <xsl:value-of select="@cellpadding"/>
                       </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@align">
                       <xsl:attribute name="align">
                          <xsl:value-of select="@align"/>
                       </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@border">
                       <xsl:attribute name="border">
                          <xsl:value-of select="@border"/>
                       </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                 </table>
            </div>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
-->

   <xsl:template mode="fignumber" match="*">
      <xsl:number value="count(preceding::table[caption] | preceding::infergr[caption])+1"/>
   </xsl:template>

<!-- Why is it there ???  JErome
   <xsl:template match="caption"/>
-->

   <xsl:template match="tbody">
      <tbody>
         <xsl:apply-templates/>
      </tbody>
   </xsl:template>


  <!-- adapt the original code for "prod" for "prodlite": -->
  <!-- by a weird bit of fortuitous interaction, the production number goes away
       just by changing the name from prod to prodlite.  (Okay, here's
       why: the relevant line is in the template for "lhs" in xmlspec.xsl:
             
	   <xsl:apply-templates select="ancestor::prod" mode="number"/>

       since the ancestor isn't "prod" nothing gets executed.
   -->

  <xsl:template match="prodlite">
    <tbody>
      <xsl:apply-templates
        select="lhs |
                rhs[preceding-sibling::*[1][name()!='lhs']] |
                com[preceding-sibling::*[1][name()!='rhs']] |
                constraint[preceding-sibling::*[1][name()!='rhs']] |
                vc[preceding-sibling::*[1][name()!='rhs']] |
                wfc[preceding-sibling::*[1][name()!='rhs']]"/>
    </tbody>
  </xsl:template>

  <!-- modify "scrap" so it will call it -->


  <!-- scrap: series of formal grammar productions -->
  <!-- set up a <table> and handle children -->
<!--  <xsl:template match="scrap">
    <xsl:apply-templates select="head"/>
    <table summary="" class="scrap" summary="Scrap">
      <xsl:apply-templates select="bnf | prod | prodgroup | prodlite"/>
    </table>
  </xsl:template>
-->

   <!-- Some font switches -->
   <xsl:template match="subscript">
      <sub>
         <font size="2">
            <xsl:value-of select="."/>
         </font>
      </sub>
   </xsl:template>
   <xsl:template match="symbol">
      <font face="symbol">
         <xsl:value-of select="."/>
      </font>
   </xsl:template>
   <xsl:template match="big">
      <font size="5">
         <xsl:value-of select="."/>
      </font>
   </xsl:template>

   <!-- Mapping Rules -->

   <xsl:template match="mapping">
      <div align="center">  
        <table summary="" cellspacing="0" cellpadding="0">
          <xsl:apply-templates/>
        </table>
      </div>
   </xsl:template>
   <xsl:template match="xquery">
     <tr><td>&#160;</td></tr>
     <tr><td align="center" style="margin-right:1cm;">
<!-- <eg> - Does not exist in HTML - Jerome -->
        <xsl:apply-templates/>
<!-- </eg> -->
      </td></tr>
   </xsl:template>

   <xsl:template match="core">
      <tr>
        <td align="center">
<!--           <hr style="color:black" size="1" noshade="noshade"/>     -->
        <b>==</b>
        </td>
      </tr>
      <tr><td align="center" style="margin-right:1cm;">
        <xsl:apply-templates/>
      </td></tr>
   </xsl:template>

   <xsl:template match="map">
     <font size="6">[</font>
     <xsl:apply-templates/> 
     <font size="6">]</font>
   </xsl:template>


   <!-- Type Inference Rules -->
   <xsl:template match="infergr">
      <div align="center">
         <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template match="display">
      <div align="center">
         <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template match="infer">
      <table summary="" cellspacing="0" cellpadding="0">
         <xsl:apply-templates/>
      </table>
      <br/>
   </xsl:template>

   <xsl:template match="prejudge">
      <tr align="center" valign="middle">
         <td>
            <xsl:choose>
               <xsl:when test="multiclause">
                  <table summary="" cellspacing="0" cellpadding="0">
                     <tr align="center" valign="middle">
                        <td>
                           <table summary="" cellspacing="0" cellpadding="0">
                              <xsl:apply-templates/>
                           </table>
                        </td>
                     </tr>
                  </table>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
         </td>
      </tr>
   </xsl:template>

   <xsl:template match="postjudge">
      <tr>
          <td>
             <hr style="color:black" size="1" noshade="noshade"/>
          </td>
      </tr>
      <tr align="center" valign="middle">
         <td>
            <xsl:choose>
               <xsl:when test="multiclause">
                  <table summary="" cellspacing="0" cellpadding="0">
                     <tr align="center" valign="middle">
                        <td>
                           <table summary="" cellspacing="0" cellpadding="0">
                              <xsl:apply-templates/>
                           </table>
                        </td>
                     </tr>
                  </table>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
         </td>
      </tr>
   </xsl:template>

   <xsl:template match="multiclause">
      <tr align="center" valign="middle">
         <td>
            <xsl:apply-templates/>
         </td>
      </tr>
   </xsl:template>

   <xsl:template match="clause">
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::clause">
         <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="environment">
      <xsl:apply-templates/> <b>&#160;|-&#160;</b>
   </xsl:template>

   <xsl:template match="update">
     <xsl:apply-templates select="environment/node()"/>
     <xsl:text>(</xsl:text>
     <xsl:apply-templates select="expression"/>
     <xsl:text>) </xsl:text>
   </xsl:template>

   <xsl:template match="update/environment/text()">
     <xsl:value-of select="substring-before(string(), '.')"/>
     <xsl:text> + </xsl:text>
     <xsl:value-of select="substring-after(string(), '.')"/>
   </xsl:template>

<!-- Not used anymore - Jerome
   <xsl:template match="fullupdate">
     <xsl:apply-templates select="environment/node()"/>
     <xsl:text> = (</xsl:text>
     <xsl:apply-templates select="expression"/>
     <xsl:text>) ]</xsl:text>
   </xsl:template>
-->

   <xsl:template match="fullupdate/environment/text()">
     <xsl:value-of select="substring-before(string(), '.')"/>
     <xsl:text> [ </xsl:text>
     <xsl:value-of select="substring-after(string(), '.')"/>
   </xsl:template>

   <xsl:template match="expression">
      <xsl:apply-templates/>
   </xsl:template>

   <!-- Query Issues -->
   <xsl:template name="insertID">
   	<xsl:choose>
            <xsl:when test="@id">
   		<a name="{@id}"/>
   	    </xsl:when>
   	    <xsl:otherwise>
   		<a name="section-{translate(head,' ','-')}"/>
   	    </xsl:otherwise>
        </xsl:choose>
   </xsl:template>
	
   <xsl:template match="queryissue">
   <!-- this complex control structure is for compatibility with xt -->
      <xsl:call-template name="insertID"/>
      <xsl:choose>
         <xsl:when test="resolution">
           <p style="color:green">
            <b>Issue-<xsl:value-of select="substring-after(@id,'-')"/>:</b>&#160;
            <xsl:value-of select="head"/>
           </p>
           <p style="margin-left:1cm;margin-right:1cm;color:green">
            <b>Date:</b>&#160;<xsl:value-of select="@date"/>
            <br/>
            <b>Raised by:</b>&#160;<xsl:value-of select="@raisedby"/>
           </p>
         </xsl:when>
         <xsl:otherwise>
           <p>
            <b>Issue-<xsl:value-of select="substring-after(@id,'-')"/>:</b>&#160;
            <xsl:value-of select="head"/>
           </p>
           <p style="margin-left:1cm;margin-right:1cm">
            <b>Date:</b>&#160;<xsl:value-of select="@date"/>
            <br/>
            <b>Raised by:</b>&#160;<xsl:value-of select="@raisedby"/>
           </p>         
         </xsl:otherwise>
     </xsl:choose>
     <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="description | suggestion | resolution">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="description/p[1]" priority="1">
      <xsl:choose>
      <xsl:when test="../../resolution">
      <p style="margin-left:1cm;margin-right:1cm;color:green">
      <b>Description:</b>&#160;
      <xsl:apply-templates/>
      </p>
      </xsl:when>
      <xsl:otherwise>
      <p style="margin-left:1cm;margin-right:1cm">
      <b>Description:</b>&#160;
      <xsl:apply-templates/>
      </p>
      </xsl:otherwise>
      </xsl:choose>
     </xsl:template>

   <xsl:template match="suggestion/p[1]" priority="1">
      <xsl:choose>
      <xsl:when test="../../resolution">
      <p style="margin-left:1cm;margin-right:1cm;color:green">
      <b>Suggested Resolution:</b>&#160;
      <xsl:apply-templates/>
      </p>
      </xsl:when>
      <xsl:otherwise>
      <p style="margin-left:1cm;margin-right:1cm">
      <b>Suggested Resolution:</b>&#160;<xsl:apply-templates/>
      <xsl:apply-templates/>
      </p>
      </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="resolution/p[1]" priority="1">
      <xsl:choose>
      <xsl:when test="../../resolution">
      <p style="margin-left:1cm;margin-right:1cm;color:green">
      <b>Resolution:</b>&#160;
      <xsl:apply-templates/>
      </p>
      </xsl:when>
      <xsl:otherwise>
      <p style="margin-left:1cm;margin-right:1cm">
      <b>Resolution:</b>&#160;<xsl:apply-templates/>
      <xsl:apply-templates/>
      </p>
      </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="description/p | resolution/p | suggestion/p">
   <xsl:choose>
      <xsl:when test="../../resolution">
      <p style="margin-left:1cm;margin-right:1cm;color:green">
            <xsl:apply-templates/>
      </p>
      </xsl:when>
      <xsl:otherwise>
      <p style="margin-left:1cm;margin-right:1cm">
      <xsl:apply-templates/>
      </p>    
    </xsl:otherwise>
   </xsl:choose>
   </xsl:template>
   
   <xsl:template match="description/*/item | resolution/*/item | suggestion/*/item">
      <xsl:choose>
      <xsl:when test="../../../resolution">
    <li style="margin-left:1cm;margin-right:1cm;color:green">
           <xsl:apply-templates/>
    </li>
    </xsl:when>
    <xsl:otherwise>
    <li style="margin-left:1cm;margin-right:1cm">
       <xsl:apply-templates/>
    </li>
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="description/eg | resolution/eg | suggestion/eg">
      <xsl:choose>
      <xsl:when test="../../resolution">
      <pre style="margin-left:1cm;margin-right:1cm;color:green">
         <xsl:apply-templates/>
      </pre>
      </xsl:when>
            <xsl:otherwise>
       <pre style="margin-left:1cm;margin-right:1cm">
         <xsl:if test="@variant='error'">
           <xsl:attribute name="style">color: black</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
      </pre>
       </xsl:otherwise>
    </xsl:choose>
   </xsl:template>

<xsl:template match="queryissue/head"/>

<xsl:template mode="number" match="queryissue"/>

<xsl:template match="div3[@id='appendix_open_issues']">
<!-- <h4><xsl:value-of select="head"/></h4> -->
   <xsl:apply-templates/>
      <b>Number: <xsl:value-of select="count(//queryissue[not(resolution)])"/>
      </b>
      <p>
         <xsl:for-each select="//queryissue[not(resolution)]">
            <xsl:sort select="head" order="ascending"/>
            <a href="#{@id}">
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:value-of select="@id"/>:&#160;
                       <xsl:value-of select="head"/>
               </b>
               <xsl:text>]</xsl:text>
            </a>
            <br/>
         </xsl:for-each>
      </p>
   </xsl:template>

   <xsl:template match="div3[@id='appendix_closed_issues']">
<!-- <h4><xsl:value-of select="head"/></h4> -->
      <xsl:apply-templates/>
      <b>Number:  <xsl:value-of select="count(//queryissue[resolution])"/>
      </b>
      <p>
         <xsl:for-each select="//queryissue[resolution]">
            <xsl:sort select="head" order="ascending"/>
            <a href="#{@id}">
               <xsl:text>[</xsl:text>
               <b>
                  <xsl:value-of select="@id"/>:&#160;
                       <xsl:value-of select="head"/>
               </b>
               <xsl:text>]</xsl:text>
            </a>
            <br/>
         </xsl:for-each>
      </p>
   </xsl:template>
   
   <xsl:template match="p/loc" priority="1">
   	<xsl:choose>
   	<xsl:when test="@variant='internal'">
   	<a href="{@href}"><xsl:apply-templates/>
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
      	<xsl:when test="@variant='internal'">
      	<a href="{@href}"><xsl:apply-templates/>
      	<xsl:text> (W3C-members only)</xsl:text>
      	</a>
      	</xsl:when>
      	<xsl:otherwise>
      	<a href="{@href}"><xsl:apply-templates/></a>
      	</xsl:otherwise>
      	</xsl:choose>
   </xsl:template>


   <!-- Schema mapping rules -->

   <xsl:template match="schemaRepresentationEg">
      <div class="exampleInner">
        <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template match="schemaRepresentation">
	<table summary="">
	  <tbody>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#60;</xsl:text>
                <xsl:value-of select="name"/>
              </td>
	    </tr>
            <xsl:for-each select="schemaAttribute[position()!=last()]">
      	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:choose>
                  <xsl:when test="@role='ignored'">
                    <b><xsl:text> [ ignored ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                  </xsl:when>
                  <xsl:when test="@role='nothandled'">
                    <b><xsl:text> [ not handled ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
	    </tr>
            </xsl:for-each>
            <xsl:for-each select="schemaAttribute[position()=last()]">
      	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:choose>
                  <xsl:when test="@role='ignored'">
                    <b><xsl:text> [ ignored ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                    <xsl:text>&#62;</xsl:text>
                  </xsl:when>
                  <xsl:when test="@role='nothandled'">
                    <b><xsl:text> [ not handled ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                    <xsl:text>&#62;</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                    <xsl:text>&#62;</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
	    </tr>
            </xsl:for-each>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:for-each select="content">
                  <xsl:apply-templates/>
                </xsl:for-each>
              </td>
	    </tr>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#60;/</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>&#62;</xsl:text>
              </td>
	    </tr>
	  </tbody>
	</table>
   </xsl:template>

   <xsl:template match="schemaRepresentationNoContent">
	<table summary="">
	  <tbody>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#60;</xsl:text>
                <xsl:value-of select="name"/>
              </td>
	    </tr>
            <xsl:for-each select="schemaAttribute[position()!=last()]">
      	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:choose>
                  <xsl:when test="@role='ignored'">
                    <b><xsl:text> [ ignored ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                  </xsl:when>
                  <xsl:when test="@role='nothandled'">
                    <b><xsl:text> [ not handled ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
	    </tr>
            </xsl:for-each>
            <xsl:for-each select="schemaAttribute[position()=last()]">
      	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:choose>
                  <xsl:when test="@role='ignored'">
                    <b><xsl:text> [ ignored ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                    <xsl:text>&#62;</xsl:text>
                  </xsl:when>
                  <xsl:when test="@role='nothandled'">
                    <b><xsl:text> [ not handled ]&#160;&#160;</xsl:text></b>
                    <xsl:apply-templates/>
                    <xsl:text>&#62;</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                    <xsl:text>&#160;/&#62;</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
	    </tr>
            </xsl:for-each>
	  </tbody>
	</table>
   </xsl:template>

   <xsl:template match="schemaRepresentationNoAttribute">
	<table summary="">
	  <tbody>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#60;</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>&#62;</xsl:text>
              </td>
	    </tr>
	    <tr>
	      <td>
                <xsl:for-each select="content">
                  <xsl:apply-templates/>
                </xsl:for-each>
              </td>
	    </tr>
	    <tr>
	      <td>
                <xsl:text>&#160;&#160;&#60;/</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>&#62;</xsl:text>
              </td>
	    </tr>
	  </tbody>
	</table>
   </xsl:template>

   <!-- Semantics Section rules -->
   <!-- fancy this up later, make them look like (unnumbered) headers -->

   <xsl:template match="smintro">
      <p><b>Introduction</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="b">
      <b><xsl:apply-templates/></b>
   </xsl:template>

   <xsl:template match="smnotation">
      <p><b>Notation</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smcore">
      <p><b>Core Grammar</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smcontext">
      <p><b><a href="#processing_context" class="processing">Static Context Processing</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smdyncontext">
      <p><b><a href="#dyn_processing_context" class="processing">Dynamic Context Processing</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smnorm">
      <p><b><a href="#processing_normalization" class="processing">Normalization</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smtype">
      <p><b><a href="#processing_static" class="processing">Static Type Analysis</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smeval">
      <p><b><a href="#processing_dynamic" class="processing">Dynamic Evaluation</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smerror">
      <p><b><a href="#sec_errors" class="processing">Dynamic Errors</a></b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smexample">
      <p><b>Example</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smexamples">
      <p><b>Examples</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smnote">
      <p><b>Note</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smrules">
      <p><b>Semantics</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smschema">
      <p><b>Schema component</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="smschemanorm">
      <p><b>Schema mapping</b></p>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="small">
    <small>
      <xsl:apply-templates/>
    </small>
   </xsl:template>

  <xsl:template mode="number-simple" match="prod">
    <!-- Using @num and auto-numbered productions is forbidden. -->
    <small>
    <xsl:choose>
      <xsl:when test="@num">
        <xsl:value-of select="@num"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number level="any" count="prod[not(@diff='add')]"/>
      </xsl:otherwise>
    </xsl:choose>
    </small>
  </xsl:template>

  <xsl:template match="rhs-group">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="prod/com" priority="2000">
    <!-- xsl:apply-templates/ --> <!-- swallow it for now -->
  </xsl:template>

  <!-- nt: production non-terminal -->
  <!-- make a link to the non-terminal's definition -->
  <xsl:template match="rhs//nt">
    
    <xsl:variable name="target" select="key('ids', @def)"/>
    <xsl:choose>
      <xsl:when test="$target">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="target" select="key('ids', @def)"/>
            </xsl:call-template> 
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor::prod[contains(@num, '(Formal)') or contains(@num, '(Core)')] 
                          and (starts-with(@def, 'prod-') or starts-with(@def, 'doc-'))">
            <!-- then try a fix-up to the core production -->
            <xsl:variable name="def2">
              <xsl:choose>
                <xsl:when test="starts-with(@def, 'prod-fs-')">
                  <xsl:value-of select="concat('prod-core-', substring(@def, 9))"/>
                </xsl:when>
                <xsl:when test="starts-with(@def, 'doc-fs-')">
                  <xsl:value-of select="concat('doc-core-', substring(@def, 8))"/>
                </xsl:when>
                <xsl:when test="starts-with(@def, 'prod-core-')">
                  <xsl:value-of select="concat('doc-core-', substring(@def, 11))"/>
                </xsl:when>
                <xsl:when test="starts-with(@def, 'doc-core-')">
                  <xsl:value-of select="concat('prod-core-', substring(@def, 10))"/>
                </xsl:when>
                <xsl:when test="starts-with(@def, 'doc-')">
                  <xsl:value-of select="concat('doc-core-', substring(@def, 5))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('prod-core-', substring(@def, 6))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="target1" select="key('ids', $def2)"/>
            <xsl:choose>
              <xsl:when test="$target1">
                <a href="#{$def2}">
                  <xsl:apply-templates/>
                </a> 
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="def3">
                  <xsl:choose>
                    <xsl:when test="starts-with(@def, 'prod-fs-')">
                      <xsl:value-of select="concat('doc-core-', substring(@def, 9))"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@def, 'doc-fs-')">
                      <xsl:value-of select="concat('prod-core-', substring(@def, 8))"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@def, 'prod-core-')">
                      <xsl:value-of select="concat('doc-core-', substring(@def, 11))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat('doc-core-', substring(@def, 6))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="target2" select="key('ids', $def3)"/>
                <xsl:choose>
                  <xsl:when test="$target2">
                    <a href="#{$def3}">
                      <xsl:apply-templates/>
                    </a> 
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message>
                      <xsl:text>nt target not found (after looking for core def)! def: </xsl:text>
                      <xsl:value-of select="$def3"/>
                    </xsl:message> 
                    <xsl:apply-templates/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::prod[contains(@num, '(XPath)')] 
                          or ancestor::prod[contains(@num, '(XQuery)')]">
            <!-- well, kind of don't worry about it for the moment... -->
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>nt target not found! def: </xsl:text>
              <xsl:value-of select="@def"/>
            </xsl:message>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- Mary: Added these rules to mimic function prototypes in F&O
document -->
<xsl:template match="example[@role='signature']">
  <div class="exampleInner">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="proto">
  <xsl:variable name="prefix">
    <xsl:choose>
      <xsl:when test="@isOp='yes'">op:</xsl:when>
      <xsl:when test="@isSchema='yes'">xs:</xsl:when>
      <xsl:when test="@isDatatype='yes'">xdt:</xsl:when>
      <xsl:when test="@isStd='yes'">fn:</xsl:when>
      <xsl:when test="@isSpecial='yes'"></xsl:when>
      <xsl:otherwise>fs:</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="stringvalue">
    <xsl:apply-templates select="." mode="stringify"/>
  </xsl:variable>

  <!-- If the prototype is going to be "too long", use a tabular presentation -->

  <div class="proto">
    <xsl:choose>
      <xsl:when test="string-length($stringvalue) &gt; 70">
        <table border="0" cellpadding="0" cellspacing="0" summary="Function/operator prototype">
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
                  <xsl:if test="@return-type != 'nil'">
                    <code class="as">&#160;as&#160;</code>
                    <xsl:choose>
                      <xsl:when test="@returnVaries = 'yes'">
                        <code class="return-varies">
                          <xsl:value-of select="@return-type"/>
                          <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                        </code>
                      </xsl:when>
                      <xsl:otherwise>
                        <code class="return-type">
                          <xsl:value-of select="@return-type"/>
                          <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
                        </code>
                      </xsl:otherwise>
                    </xsl:choose>
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
        <xsl:if test="@return-type != 'nil'">
          <code class="as">&#160;as&#160;</code>
          <xsl:choose>
            <xsl:when test="@returnVaries = 'yes'">
              <code class="return-varies">
                <xsl:value-of select="@return-type"/>
                <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
              </code>
            </xsl:when>
            <xsl:otherwise>
              <code class="return-type">
                <xsl:value-of select="@return-type"/>
                <xsl:if test="@returnEmptyOk='yes'">?</xsl:if>
              </code>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="arg">
  <xsl:if test="preceding-sibling::arg">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@name = '...'">
      <span class="varargs">...</span>
    </xsl:when>
    <xsl:otherwise>
      <code class="arg">$<xsl:value-of select="@name"/></code>
      <code class="as">&#160;as&#160;</code>
      <code class="type">
        <xsl:value-of select="@type"/>
        <xsl:if test="@emptyOk='yes'">?</xsl:if>
      </code>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- HTML a's aren't really supposed to be allowed! -->
<xsl:template match="a" priority="10">
  <xsl:if test="starts-with(@href,'#') and not(key('ids', substring-after(@href,'#')))">
    <xsl:message>
      <xsl:text>ERROR: Broken cross reference: </xsl:text>
      <xsl:value-of select="@href"/>
    </xsl:message>
  </xsl:if>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
