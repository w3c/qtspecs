<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    <xsl:param name="Parameter1" select="true()" as="xs:boolean"/>
    <xsl:param name="Parameter2" required="yes" as="xs:string"/>
    <xsl:param name="Parameter3" required="yes" as="xs:integer"/>
    <xsl:output method="xhtml" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Test of Passing Three Parameters (boolean, string, integer)</title>
            </head>
            <body>
                <h1>Test of Passing Three Parameters (boolean, string, integer)</h1>
                <p>The following parameters have been set by the Apache Ant build file.</p>
                <ul>
                    <li><b>Parameter1: </b><xsl:value-of select="$Parameter1"/>
                    </li>
                    <li><b>Parameter2: </b><xsl:value-of select="$Parameter2"/>
                    </li>
                    <li><b>Parameter3: </b><xsl:value-of select="$Parameter3"/>
                    </li>
                </ul>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
