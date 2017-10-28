<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html="http://www.w3.org/1999/xhtml">

<!--
  <xsl:output method="xhtml"
       encoding="UTF-8"
       doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
       doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
       indent="no"/>


       doctype-system="../schema/common/xhtml10/xhtml1-transitional.dtd"
-->
  <xsl:output method="xhtml"
       encoding="UTF-8"
       doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
       doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
       indent="no"/>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!--
  <xsl:template match="html:br">
    <br></br>
  </xsl:template>
-->

  <xsl:template match="html:a[@href='http://www.w3.org/2005/10/Process-20051014/']">
    <a href="http://www.w3.org/2005/10/Process-20051014/" id="w3c_process_revision" xmlns="http://www.w3.org/1999/xhtml">14 October 2005 W3C Process Document</a>
  </xsl:template>
  
  <!-- AJC: modified the following template to only match the tag that defines the process document, 
       rather than other references to the process document that happen to be the same href -->
  <xsl:template match="html:a[@href='http://www.w3.org/2015/Process-20150901/'][text()='1 September 2015 W3C Process Document']">
    <a href="http://www.w3.org/2015/Process-20150901/" id="w3c_process_revision" xmlns="http://www.w3.org/1999/xhtml">1 September 2015 W3C Process Document</a>
  </xsl:template>

</xsl:stylesheet>