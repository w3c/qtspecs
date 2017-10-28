package org.w3c.xqparser;

public class XQueryXConverter_fulltext extends XQueryXConverter {

    public XQueryXConverter_fulltext(ConversionController cc, XMLWriter xw) {
        super(cc, xw);
    }

    /**
     * Process a node in the AST and its descendants.
     * @param node  The node to be processed.
     * @return true
     */
    protected boolean transformNode(SimpleNode node) {
        int id = node.id;
        switch (id) {

            // Override the base conversion for some non-FT-specific symbols

            case JJTMODULE: {
                String[][] attributes = {
                    {"xmlns:xqx", "http://www.w3.org/2005/XQueryX"},
                    {"xmlns:xqxft", "http://www.w3.org/2007/xpath-full-text"},
                    {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
                    {"xsi:schemaLocation",
                        "http://www.w3.org/2005/XQueryX"
                                + "\n                                http://www.w3.org/2005/XQueryX/xqueryx.xsd"
                                + "\n                                http://www.w3.org/2007/xpath-full-text"
                                + "\n                                http://www.w3.org/2007/xpath-full-text/xpath-full-text-10-xqueryx.xsd"}
                };

                xw.putStartTag(node, "xqx:module", attributes, true);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            // Need to override these to handle FTScoreVar
            case JJTLETCLAUSE:
            case JJTFORCLAUSE: {
                boolean is_for = (id == JJTFORCLAUSE);

                String xqx_element_name = mapNodeIdToXqxElementName(id);
                xw.putStartTag(node, xqx_element_name);

                // This class is used for both xquery10-fulltext and xquery30-fulltext.
                // But xquery10 has unfactored ForClause & LetClause,
                // whereas xquery30 has factored ForClause & LetClause
                // (i.e., with ForBinding and LetBinding.)
                // In order to process the clause correctly, we need to know which it is.
                // (And note that we can't refer to JJTFORBINDING or JJTLETBINDING,
                // because that won't compile for xquery10-fulltext.)
                // (Conceivably, we could have two versions of this class,
                // one that works with xquery10, and one for xquery30.
                // But that would complicate the build process.)
                SimpleNode firstChild = node.getChild(0);
                String firstChildNodeName = jjtNodeName[firstChild.id];
                boolean children_are_bindings =
                    (firstChildNodeName == "ForBinding" || firstChildNodeName == "LetBinding");

                if ( !children_are_bindings )
                {
                    int n = node.jjtGetNumChildren();
                    int i = 0;
                    while (i < n) {
                        i = transform_ClauseItem(node, is_for, i);
                    }
                }
                else
                {
                    for (int b = 0; b < node.jjtGetNumChildren(); b++)
                    {
                        SimpleNode binding = node.getChild(b);
                        int i = transform_ClauseItem(binding, is_for, 0);
                        assert i == binding.jjtGetNumChildren();
                    }
                }

                xw.putEndTag(node); // forClause/letClause

                return true;
            }

            // Override this one for xqxft:ftExtensionSelection,
            // which wants pragmas to be in xqxft namespace.
            case JJTPRAGMA: {
                String xqx_element_name =
                    (getParentID(node) == JJTFTEXTENSIONSELECTION)
                    ? "xqxft:pragma"
                    : "xqx:pragma";
                xw.putStartTag(node, xqx_element_name);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            // ---------------------------------------------------------------------

            // Define conversion for FT-specific symbols

            case JJTFTOPTIONDECL:
                xw.putStartTag(node, "xqxft:ftOptionDecl");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTFTSCOREVAR:
                assert node.jjtGetNumChildren() == 1;
                SimpleNode varname_node = node.getChild(0);
                assert varname_node.id == JJTVARNAME;

                assert varname_node.jjtGetNumChildren() == 1;
                SimpleNode qname_node = varname_node.getChild(0);

                transform_name( qname_node, "xqxft:ftScoreVariableBinding" );

                return true;

            // FTContainsExpr ::= RangeExpr ( "ftcontains" FTSelection FTIgnoreOption? )?
            case JJTFTCONTAINSEXPR:
                xw.putStartTag(node, "xqxft:ftContainsExpr");

                    xw.putStartTag(node, "xqxft:ftRangeExpr");
                    cc.transformChildren(node, 0, 0);
                    xw.putEndTag(node);

                    xw.putStartTag(node, "xqxft:ftSelectionExpr");
                    cc.transformChildren(node, 1, 1);
                    xw.putEndTag(node);

                    if ( node.jjtGetNumChildren() == 3 )
                    {
                        cc.transformChildren(node, 2, 2);
                    }

                xw.putEndTag(node);

                return true;

            case JJTFTIGNOREOPTION:
                xw.putStartTag(node, "xqxft:ftIgnoreOption");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // FTSelection ::= FTOr FTPosFilter*
            case JJTFTSELECTION:
                xw.putStartTag(node, "xqxft:ftSelection");

                    xw.putStartTag(node, "xqxft:ftSelectionSource");
                    cc.transformChildren(node, 0, 0);
                    xw.putEndTag(node);

                    xw.putStartTag(node, "xqxft:ftPosFilter");
                    cc.transformChildren(node, 1);
                    xw.putEndTag(node);

                xw.putEndTag(node);

                return true;

            case JJTFTOR:
                transform_binary( "xqxft:ftOr", node );
                return true;

            case JJTFTAND:
                transform_binary( "xqxft:ftAnd", node );
                return true;

            case JJTFTMILDNOT:
                transform_binary( "xqxft:ftMildNot", node );
                return true;

            case JJTFTUNARYNOT:
                xw.putStartTag(node, "xqxft:ftUnaryNot");

                    assert node.jjtGetNumChildren() == 1;
                    xw.putStartTag(node, "xqx:operand");
                    cc.transformChildren(node);
                    xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            case JJTFTPRIMARYWITHOPTIONS:
                xw.putStartTag(node, "xqxft:ftPrimaryWithOptions");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // FTPrimary ::=
            //     (FTWords FTTimes?)
            //     | ("(" FTSelection ")")
            //     | FTExtensionSelection
            case JJTFTPRIMARY:
                xw.putStartTag(node, "xqxft:ftPrimary");

                if (getChildID(node, 0) == JJTFTSELECTION)
                {
                    xw.putStartTag(node, "xqxft:parenthesized");
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                }
                else
                {
                    cc.transformChildren(node);
                }

                xw.putEndTag(node);
                return true;

            case JJTFTWORDS:
                xw.putStartTag(node, "xqxft:ftWords");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // FTWordsValue ::= Literal | ("{" Expr "}")
            case JJTFTWORDSVALUE:
                xw.putStartTag(node, "xqxft:ftWordsValue");

                // assert node.jjtGetNumChildren() == 1;
                // SimpleNode child = node.getChild(0);
                // child.id == JJTSTRINGLITERAL

                    xw.putStartTag(node, "xqxft:ftWordsExpression");
                    cc.transformChildren(node);
                    xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            case JJTFTANYALLOPTION:
                String anyalloption = "";
                // This logic is pretty fragile,
                // and relies on an assumption re process-value
                // that I don't know is justified.
                if (node.m_value == "word")
                {
                    anyalloption = "any word";
                }
                else if (node.m_value == "words")
                {
                    anyalloption = "all words";
                }
                else
                {
                    anyalloption = node.m_value;
                }

                xw.putSimpleElement(node, "xqxft:ftAnyAllOption", anyalloption);
                return true;

            case JJTFTTIMES:
                xw.putStartTag(node, "xqxft:ftTimes");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTFTEXTENSIONSELECTION:
                xw.putStartTag(node, "xqxft:ftExtensionSelection");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTFTWEIGHT:
                xw.putStartTag(node, "xqxft:weight");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // ------------------------

            case JJTFTMATCHOPTIONS:
                int pid = getParentID(node);
                if (pid == JJTFTPRIMARYWITHOPTIONS)
                {
                    xw.putStartTag(node, "xqxft:ftMatchOptions");
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                    return true;
                }
                else if (pid == JJTFTOPTIONDECL)
                {
                    // skip
                    cc.transformChildren(node);
                    return true;
                }
                else
                {
                    assert false;
                    cc.transformChildren(node);
                    return true;
                }

            case JJTFTMATCHOPTION:
                cc.transformChildren(node);
                return true;

            case JJTFTCASEOPTION: {
                xw.putStartTag(node, "xqxft:case");

                    String content;
                    if (node.m_value == "lowercase" || node.m_value == "uppercase" )
                    {
                        content = node.m_value;
                    }
                    else if ( node.m_value == "sensitive" || node.m_value == "insensitive" )
                    {
                        content = "case " + node.m_value;
                    }
                    else
                    {
                        assert false;
                        content = "UNEXPECTED " + node.m_value;
                    }
                    xw.putSimpleElement(node, "xqxft:value", content);

                xw.putEndTag(node);
                return true;
            }

            case JJTFTDIACRITICSOPTION:
                xw.putStartTag(node, "xqxft:diacritics");

                    xw.putSimpleElement(node, "xqxft:value", "diacritics " + node.m_value);

                xw.putEndTag(node);
                return true;

            case JJTFTEXTENSIONOPTION:
                xw.putStartTag(node, "xqxft:ftExtensionOption");

                    assert node.jjtGetNumChildren() == 2;
                    transform_name( node.getChild(0), "xqxft:ftExtensionName" );
                    transform_StringLiteral( node.getChild(1), "xqxft:ftExtensionValue" );

                xw.putEndTag(node);
                return true;

            case JJTFTLANGUAGEOPTION:
                xw.putStartTag(node, "xqxft:language");

                    assert node.jjtGetNumChildren() == 1;
                    transform_StringLiteral( node.getChild(0), "xqxft:value" );

                xw.putEndTag(node);
                return true;

            case JJTFTSTEMOPTION: {
                xw.putStartTag(node, "xqxft:stem");

                    String content;
                    if (node.m_value == null)
                    {
                        content = "stemming";
                    }
                    else if (node.m_value == "no")
                    {
                        content = "no stemming";
                    }
                    else
                    {
                        assert false;
                        content = "UNEXPECTED " + node.m_value;
                    }
                    xw.putSimpleElement(node, "xqxft:value", content);

                xw.putEndTag(node);
                return true;
            }

            case JJTFTSTOPWORDOPTION:
                xw.putStartTag(node, "xqxft:stopword");

                    if (node.m_value == "no")
                    {
                        xw.putEmptyElement(node, "xqxft:noStopwords");
                    }
                    else
                    {
                        xw.putStartTag(node, "xqxft:stopwords");

                        if (node.m_value == "default")
                        {
                            xw.putEmptyElement(node, "xqxft:default");
                        }
                        else if (node.m_value == null)
                        {
                            // skip
                        }
                        else
                        {
                            assert false;
                        }

                        cc.transformChildren(node);
                        xw.putEndTag(node);
                    }

                xw.putEndTag(node);
                return true;

            case JJTFTSTOPWORDS:
                xw.putStartTag(node, "xqxft:ftStopWords");
                transform_FTStopWords_content(node);
                xw.putEndTag(node);
                return true;

            case JJTFTSTOPWORDSINCLEXCL:
                xw.putStartTag(node, "xqxft:ftStopWordsInclExcl");

                    assert node.m_value == "union" || node.m_value == "except";
                    xw.putStartTag(node, "xqxft:" + node.m_value);
                    assert node.jjtGetNumChildren() == 1;
                    transform_FTStopWords_content( node.getChild(0) );
                    xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            case JJTFTTHESAURUSOPTION:
                xw.putStartTag(node, "xqxft:thesaurus");

                    if (node.m_value == "no")
                    {
                        xw.putEmptyElement(node, "xqxft:noThesauri");
                    }
                    else
                    {
                        xw.putStartTag(node, "xqxft:thesauri");

                        if (node.m_value == "default")
                        {
                            xw.putEmptyElement(node, "xqxft:default");
                        }
                        cc.transformChildren(node);

                        xw.putEndTag(node);
                    }

                xw.putEndTag(node);
                return true;

            case JJTFTTHESAURUSID:
                xw.putStartTag(node, "xqxft:thesaurusID");

                {
                    int n_children = node.jjtGetNumChildren();
                    assert n_children >= 1;
                    assert n_children <= 3;

                    transform_URILiteral(node.getChild(0), "xqxft:at");

                    int i = 1;

                    if (i < n_children)
                    {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTSTRINGLITERAL)
                        {
                            transform_StringLiteral(child, "xqxft:relationship");
                            i++;
                        }
                    }

                    if (i < n_children)
                    {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTFTLITERALRANGE)
                        {
                            xw.putStartTag(child, "xqxft:levels");
                            transform_ftLiteralRange_content(child);
                            xw.putEndTag(child);
                            i++;
                        }
                    }

                    assert i == n_children;
                }

                xw.putEndTag(node);
                return true;

            case JJTFTWILDCARDOPTION: {
                xw.putStartTag(node, "xqxft:wildcard");

                    String content;
                    if (node.m_value == null)
                    {
                        content = "wildcards";
                    }
                    else if (node.m_value == "no")
                    {
                        content = "no wildcards";
                    }
                    else
                    {
                        assert false;
                        content = "UNEXPECTED " + node.m_value;
                    }
                    xw.putSimpleElement(node, "xqxft:value", content);

                xw.putEndTag(node);
                return true;
            }

            // ------------------------

            case JJTFTPOSFILTER:
                cc.transformChildren(node);
                return true;

            case JJTFTCONTENT: {
                xw.putStartTag(node, "xqxft:ftContent");

                    String content = "";
                    if (node.m_value == "start")
                    {
                        content = "at start";
                    }
                    else if (node.m_value == "end")
                    {
                        content = "at end";
                    }
                    else if (node.m_value == "entire")
                    {
                        content = "entire content";
                    }
                    else
                    {
                        assert false;
                    }
                    xw.putSimpleElement(node, "xqxft:location", content);

                xw.putEndTag(node);
                return true;
            }

            case JJTFTDISTANCE:
                xw.putStartTag(node, "xqxft:ftDistance");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTFTORDER:
                xw.putEmptyElement(node, "xqxft:ftOrdered");
                return true;

            case JJTFTSCOPE:
                xw.putStartTag(node, "xqxft:ftScope");

                    xw.putSimpleElement(node, "xqxft:type", node.m_value);

                    cc.transformChildren(node);

                xw.putEndTag(node);
                return true;

            case JJTFTWINDOW:
                xw.putStartTag(node, "xqxft:ftWindow");

                    assert node.jjtGetNumChildren() == 2;

                    xw.putStartTag(node, "xqxft:value");
                    cc.transformChildren(node, 0, 0);
                    xw.putEndTag(node);

                    cc.transformChildren(node, 1, 1);

                xw.putEndTag(node);
                return true;

            // ----

            case JJTFTRANGE:
                xw.putStartTag(node, "xqxft:ftRange");
                transform_ftRange_content(node);
                xw.putEndTag(node);
                return true;

            case JJTFTUNIT:
            case JJTFTBIGUNIT:
                String u = node.m_value;
                if (id == JJTFTUNIT)
                {
                    assert u.charAt( u.length()-1 ) == 's';
                    u = u.substring( 0, u.length()-1 );
                }
                xw.putSimpleElement(node, "xqxft:unit", u);
                return true;

            default:
                return false;
        }
        // unreachable
    }

    // =========================================================================

    protected int transform_ClauseItem(SimpleNode parent, boolean is_for, int i)
    {
        xw.putStartTag(parent, is_for ? "xqx:forClauseItem" : "xqx:letClauseItem", true);

            SimpleNode nextChild = parent.getChild(i);

            if ( nextChild.id == JJTFTSCOREVAR )
            {
                assert !is_for;

                cc.transformChildren(parent, i, i);

                i++;
                nextChild = parent.getChild(i);
            }
            else
            {
                assert nextChild.id == JJTVARNAME;

                xw.putStartTag(parent, "xqx:typedVariableBinding", true);

                transform_name( nextChild.getChild(0), "xqx:varName" );

                i++;
                nextChild = parent.getChild(i);

                if (nextChild.id == JJTTYPEDECLARATION)
                {
                    // handle, ugh, in varname
                    cc.transform(nextChild);
                    i++;
                    nextChild = parent.getChild(i);
                }

                xw.putEndTag(parent, true); // xqx:typedVariableBinding

                if (nextChild.id == JJTPOSITIONALVAR)
                {
                    assert is_for;
                    cc.transformChildren(parent, i, i);
                    i++;
                    nextChild = parent.getChild(i);
                }

                if (nextChild.id == JJTFTSCOREVAR)
                {
                    assert is_for;
                    cc.transformChildren(parent, i, i);
                    i++;
                    nextChild = parent.getChild(i);
                }
            }

            {
                xw.putStartTag(parent, is_for ? "xqx:forExpr" : "xqx:letExpr", true);
                cc.transform(nextChild);
                xw.putEndTag(parent); // xqx:forExpr/xqx:letExpr
                i++;
            }

        xw.putEndTag(parent); // xqx:forClauseItem/xqx:letClauseItem

        return i;
    }

    protected void transform_ftRange_content(SimpleNode node)
    {
        assert node.id == JJTFTRANGE;

        String localName = "";
        if (node.m_value == "exactly")
        {
            localName = "exactlyRange";
        }
        else if (node.m_value == null)
        {
            localName = "atLeastRange";
        }
        else if (node.m_value == "most")
        {
            localName = "atMostRange";
        }
        else if (node.m_value == "from")
        {
            localName = "fromToRange";
        }
        else
        {
            assert false;
        }
        xw.putStartTag(node, "xqxft:" + localName);

        if (localName == "fromToRange")
        {
            assert node.jjtGetNumChildren() == 2;

            xw.putStartTag(node, "xqxft:lower");
            cc.transformChildren(node, 0, 0);
            xw.putEndTag(node);

            xw.putStartTag(node, "xqxft:upper");
            cc.transformChildren(node, 1, 1);
            xw.putEndTag(node);
        }
        else
        {
            assert node.jjtGetNumChildren() == 1;

            xw.putStartTag(node, "xqxft:value");
            cc.transformChildren(node, 0, 0);
            xw.putEndTag(node);
        }

        xw.putEndTag(node);
    }

    protected void transform_ftLiteralRange_content(SimpleNode node)
    {
        assert node.id == JJTFTLITERALRANGE;

        String localName = "";
        if (node.m_value == "exactly")
        {
            localName = "exactlyLiteralRange";
        }
        else if (node.m_value == null)
        {
            localName = "atLeastLiteralRange";
        }
        else if (node.m_value == "most")
        {
            localName = "atMostLiteralRange";
        }
        else if (node.m_value == "from")
        {
            localName = "fromToLiteralRange";
        }
        else
        {
            assert false;
        }
        xw.putStartTag(node, "xqxft:" + localName);

        if (localName == "fromToLiteralRange")
        {
            assert node.jjtGetNumChildren() == 2;

            xw.putSimpleElement(node, "xqxft:lower", node.getChild(0).m_value);
            xw.putSimpleElement(node, "xqxft:upper", node.getChild(1).m_value);

        }
        else
        {
            assert node.jjtGetNumChildren() == 1;

            xw.putSimpleElement(node, "xqxft:value", node.getChild(0).m_value);
        }

        xw.putEndTag(node);
    }

    protected void transform_FTStopWords_content( SimpleNode node )
    {
        assert node.id == JJTFTSTOPWORDS;

        if (node.m_value == "at")
        {
            assert node.jjtGetNumChildren() == 1;
            transform_URILiteral( node.getChild(0), "xqxft:ref" );
        }
        else
        {
            xw.putStartTag(node, "xqxft:list");
            cc.transformChildren(node);
            xw.putEndTag(node);
        }
    }

    // The following methods aren't fulltext-specific.
    // It would make sense to move them into the base class
    // and then use them more widely.

    protected void transform_binary( String nodeName, SimpleNode node )
    {
        xw.putStartTag(node, nodeName);

        assert node.jjtGetNumChildren() == 2;

            xw.putStartTag(node, "xqx:firstOperand");
            cc.transformChildren(node, 0, 0);
            xw.putEndTag(node);

            xw.putStartTag(node, "xqx:secondOperand");
            cc.transformChildren(node, 1, 1);
            xw.putEndTag(node);

        xw.putEndTag(node);
    }

    protected void transform_URILiteral( SimpleNode uriliteral_node, String nodeName )
    {
        assert uriliteral_node.id == JJTURILITERAL;
        assert uriliteral_node.jjtGetNumChildren() == 1;
        transform_StringLiteral( uriliteral_node.getChild(0), nodeName );
    }

    protected void transform_StringLiteral( SimpleNode stringLiteral, String nodeName )
    {
        assert stringLiteral.id == JJTSTRINGLITERAL;

        xw.putSimpleElement(stringLiteral, nodeName, undelimitStringLiteral(stringLiteral));
    }

}
// vim: sw=4 ts=4 expandtab
