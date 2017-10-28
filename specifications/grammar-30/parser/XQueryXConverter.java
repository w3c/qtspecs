package org.w3c.xqparser;

public class XQueryXConverter implements XParserTreeConstants
{
    protected ConversionController cc;
    protected XMLWriter xw;

    public XQueryXConverter(ConversionController cc, XMLWriter xw) {
        this.cc = cc;
        this.xw = xw;
    }

    protected boolean transformNode(SimpleNode node)
    {
        throw new RuntimeException(
            "subclasses of XQueryXConverter must override transformNode!");
    }

    // -------------------------------------------------------------------------

    protected void transform_name(SimpleNode name_node, int node_id)
    {
        transform_name(name_node, mapNodeIdToXqxElementName(node_id));
    }

    protected void transform_name(SimpleNode name_node, String xqx_element_name)
    {
        if (   name_node.id != JJTNCNAME
            && name_node.id != JJTQNAME
            && name_node.id != JJTFUNCTIONQNAME
            && name_node.id != JJTTAGQNAME
        ) {
            xw.putComment("transform_name got unexpected " + name_node.toString() + " for name_node.");
            // But proceed anyway.
        }

        String qname = name_node.m_value;
        assert qname != null;

        String[][] attributes;
        String local_name;
        int i = qname.indexOf(':');
        if (i > 0) {
            String prefix = qname.substring(0, i);
            local_name = qname.substring(i + 1);
            attributes = new String[][] {{"xqx:prefix", prefix}};
        } else {
            local_name = qname;
            attributes = new String[][] {};
        }
        xw.putStartTag(name_node, xqx_element_name, attributes, false);
        xw.putTextEscaped(local_name);
        xw.putEndTag(name_node, false);
    }

    protected String mapNodeIdToXqxElementName(int id)
    // Note that this is inappropriate for some values of 'id'.
    // The caller is responsible for knowing if it's appropriate.
    {
        String node_name = jjtNodeName[id];
        String xqx_element_name = "xqx:"
            + node_name.substring(0, 1).toLowerCase()
            + node_name.substring(1);
        return xqx_element_name;
    }

    // -------------------------------------------------------------------------

    protected String undelimitStringLiteral(SimpleNode stringLiteral_node)
    {
        assert stringLiteral_node.id == JJTSTRINGLITERAL;
        return undelimitStringLiteral(stringLiteral_node.m_value);
    }

    protected String undelimitStringLiteral(String lit)
    {
        char delimiter = lit.charAt(0);
        assert lit.charAt( lit.length()-1 ) == delimiter;
        String body = lit.substring(1, lit.length()-1);

        StringBuilder body_sans_escapes = new StringBuilder();
        int body_len = body.length();
        for (int i = 0; i < body_len; i++)
        {
            char c = body.charAt(i);
            if (c == delimiter)
            {
                // The grammar guarantees that within the body of the StringLiteral,
                // the delimiter character only appears in pairs.
                assert (i + 1) < body_len;
                assert body.charAt(i + 1) == delimiter;

                // For this pair, we want only one character in body_sans_escapes.
                // The easiest way to do this is increment i, thus skipping over
                // the second character of the pair.
                i++;
            }
            body_sans_escapes.append(c);
        }

        return body_sans_escapes.toString();
    }

    // -------------------------------------------------------------------------

    /**
     * @param node
     * @return
     */
    protected int getParentID(SimpleNode node) {
        return node.getParent().id;
    }

    /**
     * @param node
     * @return
     */
    protected int getChildID(SimpleNode node, int i) {
        if (i < node.jjtGetNumChildren())
            return node.getChild(i).id;
        else
            return -1;
    }
}
// vim: sw=4 ts=4 expandtab
