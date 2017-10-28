<?xml version="1.0" encoding="UTF-8"?>

<!--
 * Copyright (c) 2010 W3C(r) (http://www.w3.org/) (MIT (http://www.lcs.mit.edu/),
 * INRIA (http://www.inria.fr/), Keio (http://www.keio.ac.jp/)),
 * All Rights Reserved.
 * See http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Copyright.
 * W3C liability
 * (http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Legal_Disclaimer),
 * trademark
 * (http://www.w3.org/Consortium/Legal/ipr-notice-20000612#W3C_Trademarks),
 * document use
 * (http://www.w3.org/Consortium/Legal/copyright-documents-19990405),
 * and software licensing rules
 * (http://www.w3.org/Consortium/Legal/copyright-software-19980720)
 * apply.
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<xsl:param name="spec1"/>
<xsl:param name="spec2"/>
<xsl:param name="spec3"/>

<xsl:output method="text" encoding="iso-8859-1"/>

<xsl:template match="/">

package org.w3c.xqparser;

import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.Stack;

public class ConversionController
{
    protected XMLWriter xw;
    public String[] component_id_;
    protected XQueryXConverter[] xqxc_;

    public ConversionController() throws UnsupportedEncodingException
    {
        xw = new XMLWriter();
        xw.setOutputs(System.out, null);

        component_id_ = new String[] {
            "<xsl:value-of select="$spec1"/>",
            "<xsl:value-of select="$spec2"/>",
            "<xsl:value-of select="$spec3"/>",
        };

        xqxc_ = new XQueryXConverter[] {
            new XQueryXConverter_<xsl:value-of select="$spec1"/>(this, xw),
            new XQueryXConverter_<xsl:value-of select="$spec2"/>(this, xw),
            new XQueryXConverter_<xsl:value-of select="$spec3"/>(this, xw),
        };
    }

    // -------------------------------------------------------------------------

    public void transform(SimpleNode node, PrintStream ps1)
        throws UnsupportedEncodingException
    {
        xw.setOutputs(ps1, null);
        transform(node);
        xw.flush();
    }

    public void transform(SimpleNode node, PrintStream ps1, PrintStream ps2)
        throws UnsupportedEncodingException
    {
        xw.setOutputs(ps1, ps2);
        transform(node);
        xw.flush();
    }

    public void transformNoEncodingException(
        SimpleNode node, PrintStream ps1, PrintStream ps2)
    {
        xw.setOutputs_NoEncodingException(ps1, ps2);
        transform(node);
        xw.flush();
    }

    // -------------------------------------------------------------------------

    public void transform(SimpleNode node)
    {
        int markSize = xw.getDepthOfOpenElementStack();

        boolean node_has_been_handled = false;
        int n = xqxc_.length;
        for (int i = n-1; i &gt;= 0; i--)
        {
            boolean result = xqxc_[i].transformNode(node);
            if (result)
            {
                node_has_been_handled = true;
                break;
            }
        }
        if (!node_has_been_handled)
        {
            throw new RuntimeException(
                "Converter did not know how to handle " + node.toString()
            );
        }

        int currentSize = xw.getDepthOfOpenElementStack();
        if (markSize != currentSize)
            throw new RuntimeException(
                "Unbalanced tags! transformNode(" + node.toString() + ") opened "
                + Integer.toString(currentSize - markSize)
                + " more elements than it closed."
            );
    }

    // -------------------------------------------------------------------------

    public void transformChildren(SimpleNode node)
    {
        transformChildren(node, 0, node.jjtGetNumChildren() - 1);
    }

    public void transformChildren(SimpleNode node, int start)
    {
        transformChildren(node, start, node.jjtGetNumChildren() - 1);
    }

    public void transformChildren(SimpleNode node, int start, int end)
    {
        // int n = node.jjtGetNumChildren();
        for (int i = start; i &lt;= end; i++)
        {
            SimpleNode child = node.getChild(i);
            transform(child);
        }
    }

}
</xsl:template>
</xsl:stylesheet>
<!-- vim: sw=4 ts=4 expandtab
-->
