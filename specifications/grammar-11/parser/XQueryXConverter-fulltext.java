package org.w3c.xqparser;

import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

public class XQueryXConverter extends XQueryXConverterBase {

    public XQueryXConverter() throws UnsupportedEncodingException {
    }

    public XQueryXConverter(PrintWriter xqout)
            throws UnsupportedEncodingException {
        super(xqout);
    }

    public XQueryXConverter(PrintStream xqout)
            throws UnsupportedEncodingException {
        super(xqout);
    }

    public XQueryXConverter(PrintStream xqout, PrintStream xqout2)
            throws UnsupportedEncodingException {
        super(xqout, xqout2);
    }

    /* @Override */
    public boolean transform(SimpleNode node) {
        return super.transform(node);
    }

    /**
     * Process a node in the AST.  This function may process the children, in
     * which case it should return the node that was passed in.
     * Otherwise, it should return null.
     * @param node  The node to be processed.
     * @param id The ID of the node to be processed.
     * @return null if node should normally be processed for children, otherwise
     * the node on which the stack check should be made.
     */
    protected SimpleNode transformNode(SimpleNode node, int id) {
        switch (id) {

        // Override the base conversion for some non-FT-specific symbols

        case JJTMODULE: {
            pushElem("xqx:module", node);
            pushAttr("xmlns:xqx", "http://www.w3.org/2005/XQueryX");
            _outputStack.push("\n           ");
            pushAttr("xmlns:xqxft", "http://www.w3.org/2007/xpath-full-text");
            _outputStack.push("\n           ");
            pushAttr("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
            _outputStack.push("\n           ");

            pushAttr(
                    "xsi:schemaLocation",
                    "http://www.w3.org/2005/XQueryX"
                            + "\n                                http://www.w3.org/2005/XQueryX/xqueryx.xsd"
                            + "\n                                http://www.w3.org/2007/xpath-full-text"
                            + "\n                                http://www.w3.org/2007/xpath-full-text/xpath-full-text-10-xqueryx.xsd");
        }
            break;

        // Need to override these to handle FTScoreVar
        case JJTLETCLAUSE:
        case JJTFORCLAUSE: {
            boolean is_for = (id == JJTFORCLAUSE);

            pushElem(id, node);
            flushOpen(node);

            // This class is used for both xquery10-fulltext and xquery11-fulltext.
            // But xquery10 has unfactored ForClause & LetClause,
            // whereas xquery11 has factored ForClause & LetClause
            // (i.e., with ForBinding and LetBinding.)
            // In order to process the clause correctly, we need to know which it is.
            // (And note that we can't refer to JJTFORBINDING or JJTLETBINDING,
            // because that won't compile for xquery10-fulltext.)
            // (Conceivably, we could have two versions of this class,
            // one that works with xquery10, and one for xquery11.
            // But that would complicate the build process.)
            SimpleNode firstChild = (SimpleNode)node.jjtGetChild(0);
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
                    SimpleNode binding = sn(node.jjtGetChild(b));
                    int i = transform_ClauseItem(binding, is_for, 0);
                    assert i == binding.jjtGetNumChildren();
                }
            }

            flushClose(node); // forClause/letClause

            return node;
        }

        // Override this one for xqxft:ftExtensionSelection,
        // which wants pragmas to be in xqxft namespace.
        case JJTPRAGMA:
            if (getParentID(node) == JJTFTEXTENSIONSELECTION)
            {
                pushElem("xqxft:pragma", node);
            }
            else
            {
                pushElem("xqx:pragma", node);
            }
            break;

        // ---------------------------------------------------------------------

        // Define conversion for FT-specific symbols

        case JJTFTOPTIONDECL:
            pushElem("xqxft:ftOptionDecl", node);
            break;

        case JJTFTSCOREVAR:
            assert node.jjtGetNumChildren() == 1;
            SimpleNode varname_node = sn(node.jjtGetChild(0));
            assert varname_node.id == JJTVARNAME;

            assert varname_node.jjtGetNumChildren() == 1;
            SimpleNode qname_node = sn(varname_node.jjtGetChild(0));

            transform_QName( qname_node, "xqxft:ftScoreVariableBinding" );

            return node;

        // FTContainsExpr ::= RangeExpr ( "ftcontains" FTSelection FTIgnoreOption? )?
        case JJTFTCONTAINSEXPR:
            pushElem("xqxft:ftContainsExpr", node);
            flushOpen(node);

                pushElem("xqxft:ftRangeExpr", node);
                flushOpen(node);
                transformChildren(node, 0, 0);
                flushClose(node);

                pushElem("xqxft:ftSelectionExpr", node);
                flushOpen(node);
                transformChildren(node, 1, 1);
                flushClose(node);

                if ( node.jjtGetNumChildren() == 3 )
                {
                    transformChildren(node, 2, 2);
                }

            flushClose(node);

            return node;

        case JJTFTIGNOREOPTION:
            pushElem("xqxft:ftIgnoreOption", node);
            break;

        // FTSelection ::= FTOr FTPosFilter*
        case JJTFTSELECTION:
            pushElem("xqxft:ftSelection", node);
            flushOpen(node);

                pushElem("xqxft:ftSelectionSource", node);
                flushOpen(node);
                transformChildren(node, 0, 0);
                flushClose(node);

                pushElem("xqxft:ftPosFilter", node);
                flushOpen(node);
                transformChildren(node, 1);
                flushClose(node);

            flushClose(node);

            return node;

        case JJTFTOR:
            return transform_binary( "xqxft:ftOr", node );

        case JJTFTAND:
            return transform_binary( "xqxft:ftAnd", node );

        case JJTFTMILDNOT:
            return transform_binary( "xqxft:ftMildNot", node );

        case JJTFTUNARYNOT:
            pushElem("xqxft:ftUnaryNot", node);
            flushOpen(node);

                assert node.jjtGetNumChildren() == 1;
                pushElem("xqx:operand", node);
                flushOpen(node);
                transformChildren(node);
                flushClose(node);

            flushClose(node);
            return node;

        case JJTFTPRIMARYWITHOPTIONS:
            pushElem("xqxft:ftPrimaryWithOptions", node);
            break;

        // FTPrimary ::=
        //     (FTWords FTTimes?)
        //     | ("(" FTSelection ")")
        //     | FTExtensionSelection
        case JJTFTPRIMARY:
            pushElem("xqxft:ftPrimary", node);
            flushOpen(node);

            if (getChildID(node, 0) == JJTFTSELECTION)
            {
                pushElem("xqxft:parenthesized", node);
                flushOpen(node);
                transformChildren(node);
                flushClose(node);
            }
            else
            {
                transformChildren(node);
            }

            flushClose(node);
            return node;

        case JJTFTWORDS:
            pushElem("xqxft:ftWords", node);
            break;

        // FTWordsValue ::= Literal | ("{" Expr "}")
        case JJTFTWORDSVALUE:
            pushElem("xqxft:ftWordsValue", node);
            flushOpen(node);

            // assert node.jjtGetNumChildren() == 1;
            // SimpleNode child = sn(node.jjtGetChild(0));
            // child.id == JJTSTRINGLITERAL

                pushElem("xqxft:ftWordsExpression", node);
                flushOpen(node);
                transformChildren(node);
                flushClose(node);

            flushClose(node);
            return node;

        case JJTFTANYALLOPTION:
            pushElem("xqxft:ftAnyAllOption", node);
            flushOpen(node, false);

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
            xqprint(anyalloption);

            flushClose(node, false);
            return node;

        case JJTFTTIMES:
            pushElem("xqxft:ftTimes", node);
            break;

        case JJTFTEXTENSIONSELECTION:
            pushElem("xqxft:ftExtensionSelection", node);
            break;

        case JJTFTWEIGHT:
            pushElem("xqxft:weight", node);
            break;

        // ------------------------

        case JJTFTMATCHOPTIONS:
            int pid = getParentID(node);
            if (pid == JJTFTPRIMARYWITHOPTIONS)
            {
                pushElem("xqxft:ftMatchOptions", node);
            }
            else if (pid == JJTFTOPTIONDECL)
            {
                // skip
            }
            else
            {
                assert false;
            }
            break;

        case JJTFTMATCHOPTION:
            break;

        case JJTFTCASEOPTION:
            pushElem("xqxft:case", node);
            flushOpen(node);

                pushElem("xqxft:value", node);
                flushOpen(node,false);
                if (node.m_value == "lowercase" || node.m_value == "uppercase" )
                {
                    xqprint(node.m_value);
                }
                else if ( node.m_value == "sensitive" || node.m_value == "insensitive" )
                {
                    xqprint("case " + node.m_value);
                }
                else
                {
                    assert false;
                }
                flushClose(node, false);

            flushClose(node);
            return node;

        case JJTFTDIACRITICSOPTION:
            pushElem("xqxft:diacritics", node);
            flushOpen(node);

                pushElem("xqxft:value", node);
                flushOpen(node,false);
                xqprint("diacritics " + node.m_value);
                flushClose(node, false);

            flushClose(node);
            return node;

        case JJTFTEXTENSIONOPTION:
            pushElem("xqxft:ftExtensionOption", node);
            flushOpen(node);

                assert node.jjtGetNumChildren() == 2;
                transform_QName( sn(node.jjtGetChild(0)), "xqxft:ftExtensionName" );
                transform_StringLiteral( sn(node.jjtGetChild(1)), "xqxft:ftExtensionValue" );

            flushClose(node);
            return node;

        case JJTFTLANGUAGEOPTION:
            pushElem("xqxft:language", node);
            flushOpen(node);

                assert node.jjtGetNumChildren() == 1;
                transform_StringLiteral( sn(node.jjtGetChild(0)), "xqxft:value" );

            flushClose(node);
            return node;

        case JJTFTSTEMOPTION:
            pushElem("xqxft:stem", node);
            flushOpen(node);

                pushElem("xqxft:value", node);
                flushOpen(node, false);
                if (node.m_value == null)
                {
                    xqprint("stemming");
                }
                else if (node.m_value == "no")
                {
                    xqprint("no stemming");
                }
                else
                {
                    assert false;
                }
                flushClose(node, false);

            flushClose(node);
            return node;

        case JJTFTSTOPWORDOPTION:
            pushElem("xqxft:stopword", node);
            flushOpen(node);

                if (node.m_value == "no")
                {
                    pushElem("xqxft:noStopwords", node);
                    flushEmpty(node);
                }
                else
                {
                    pushElem("xqxft:stopwords", node);
                    flushOpen(node);

                    if (node.m_value == "default")
                    {
                        pushElem("xqxft:default", node);
                        flushEmpty(node);
                    }
                    else if (node.m_value == null)
                    {
                        // skip
                    }
                    else
                    {
                        assert false;
                    }

                    transformChildren(node);
                    flushClose(node);
                }

            flushClose(node);
            return node;

        case JJTFTSTOPWORDS:
            pushElem("xqxft:ftStopWords", node);
            flushOpen(node);
            transform_FTStopWords_content(node);
            flushClose(node);
            return node;

        case JJTFTSTOPWORDSINCLEXCL:
            pushElem("xqxft:ftStopWordsInclExcl", node);
            flushOpen(node);

                assert node.m_value == "union" || node.m_value == "except";
                pushElem("xqxft:" + node.m_value, node);
                flushOpen(node);
                assert node.jjtGetNumChildren() == 1;
                transform_FTStopWords_content( sn(node.jjtGetChild(0)) );
                flushClose(node);

            flushClose(node);
            return node;

        case JJTFTTHESAURUSOPTION:
            pushElem("xqxft:thesaurus", node);
            flushOpen(node);

                if (node.m_value == "no")
                {
                    pushElem("xqxft:noThesauri", node);
                    flushEmpty(node);
                }
                else
                {
                    pushElem("xqxft:thesauri", node);
                    flushOpen(node);
                    
                    if (node.m_value == "default")
                    {
                        pushElem("xqxft:default", node);
                        flushEmpty(node);
                    }
                    transformChildren(node);
                    
                    flushClose(node);
                }

            flushClose(node);
            return node;

        case JJTFTTHESAURUSID:
            pushElem("xqxft:thesaurusID", node);
            flushOpen(node);

            {
                int n_children = node.jjtGetNumChildren();
                assert n_children >= 1;
                assert n_children <= 3;

                transform_URILiteral(sn(node.jjtGetChild(0)), "xqxft:at");

                int i = 1;

                if (i < n_children)
                {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (child.id == JJTSTRINGLITERAL)
                    {
                        transform_StringLiteral(child, "xqxft:relationship");
                        i++;
                    }
                }

                if (i < n_children)
                {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (child.id == JJTFTRANGE)
                    {
                        pushElem("xqxft:levels", child);
                        flushOpen(child);
                        transform_ftRange_content(child);
                        flushClose(child);
                        i++;
                    }
                }

                assert i == n_children;
            }

            flushClose(node);
            return node;

        case JJTFTWILDCARDOPTION:
            pushElem("xqxft:wildcard", node);
            flushOpen(node);

                pushElem("xqxft:value", node);
                flushOpen(node,false);
                if (node.m_value == null)
                {
                    xqprint("wildcards");
                }
                else if (node.m_value == "no")
                {
                    xqprint("no wildcards");
                }
                else
                {
                    assert false;
                }
                flushClose(node, false);

            flushClose(node);
            return node;

        // ------------------------

        case JJTFTPOSFILTER:
            break;

        case JJTFTCONTENT:
            pushElem("xqxft:ftContent", node);
            flushOpen(node);

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
                pushElem("xqxft:location", node);
                flushOpen(node, false);
                xqprint(content);
                flushClose(node, false);

            flushClose(node);
            return node;

        case JJTFTDISTANCE:
            pushElem("xqxft:ftDistance", node);
            break;

        case JJTFTORDER:
            pushElem("xqxft:ftOrdered", node);
            break;

        case JJTFTSCOPE:
            pushElem("xqxft:ftScope", node);
            flushOpen(node);

                pushElem("xqxft:type", node);
                flushOpen(node, false);
                xqprint(node.m_value);
                flushClose(node, false);

                transformChildren(node);

            flushClose(node);
            return node;

        case JJTFTWINDOW:
            pushElem("xqxft:ftWindow", node);
            flushOpen(node);
            
                assert node.jjtGetNumChildren() == 2;

                pushElem("xqxft:value", node );
                flushOpen(node);
                transformChildren(node, 0, 0);
                flushClose(node);

                transformChildren(node, 1, 1);

            flushClose(node);
            return node;

        // ----

        case JJTFTRANGE:
            pushElem("xqxft:ftRange", node);
            flushOpen(node);
            transform_ftRange_content(node);
            flushClose(node);
            return node;

        case JJTFTUNIT:
        case JJTFTBIGUNIT:
            pushElem("xqxft:unit", node);
            flushOpen(node, false);

            String u = node.m_value;
            if (id == JJTFTUNIT)
            {
                assert u.charAt( u.length()-1 ) == 's';
                u = u.substring( 0, u.length()-1 );
            }
            xqprint(u);

            flushClose(node, false);
            return node;

        default:
            return super.transformNode(node, id);
        }
        return null;
    }

    // =========================================================================

    protected int transform_ClauseItem(SimpleNode parent, boolean is_for, int i)
    {
        pushElem(is_for ? "xqx:forClauseItem" : "xqx:letClauseItem", parent);
        flushOpen(parent, true);

            SimpleNode nextChild = (SimpleNode) parent.jjtGetChild(i);

            if ( nextChild.id == JJTFTSCOREVAR )
            {
                assert !is_for;

                transformChildren(parent, i, i);

                i++;
                nextChild = (SimpleNode) parent.jjtGetChild(i);
            }
            else
            {
                assert nextChild.id == JJTVARNAME;

                pushElem("xqx:typedVariableBinding", parent);
                flushOpen(parent, true);

                transform_QName( sn(nextChild.jjtGetChild(0)), "xqx:varName" );

                i++;
                nextChild = (SimpleNode) parent.jjtGetChild(i);

                if (nextChild.id == JJTTYPEDECLARATION)
                {
                    // handle, ugh, in varname
                    transform(nextChild);
                    i++;
                    nextChild = (SimpleNode) parent.jjtGetChild(i);
                }

                flushClose(parent, true); // xqx:typedVariableBinding

                if (nextChild.id == JJTPOSITIONALVAR)
                {
                    assert is_for;
                    transformChildren(parent, i, i);
                    i++;
                    nextChild = (SimpleNode) parent.jjtGetChild(i);
                }

                if (nextChild.id == JJTFTSCOREVAR)
                {
                    assert is_for;
                    transformChildren(parent, i, i);
                    i++;
                    nextChild = (SimpleNode) parent.jjtGetChild(i);
                }
            }

            {
                pushElem(is_for ? "xqx:forExpr" : "xqx:letExpr", parent);
                flushOpen(parent, true);
                transform(nextChild);
                flushClose(parent); // xqx:forExpr/xqx:letExpr
                i++;
            }

        flushClose(parent); // xqx:forClauseItem/xqx:letClauseItem

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
        pushElem("xqxft:" + localName, node);
        flushOpen(node);

        if (localName == "fromToRange")
        {
            assert node.jjtGetNumChildren() == 2;

            pushElem("xqxft:lower", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);

            pushElem("xqxft:upper", node);
            flushOpen(node);
            transformChildren(node, 1, 1);
            flushClose(node);
        }
        else
        {
            assert node.jjtGetNumChildren() == 1;

            pushElem("xqxft:value", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);
        }

        flushClose(node);
    }

    protected void transform_FTStopWords_content( SimpleNode node )
    {
        assert node.id == JJTFTSTOPWORDS;

        if (node.m_value == "at")
        {
            assert node.jjtGetNumChildren() == 1;
            transform_URILiteral( sn(node.jjtGetChild(0)), "xqxft:ref" );
        }
        else
        {
            pushElem("xqxft:list", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
        }
    }

    // The following methods aren't fulltext-specific.
    // It would make sense to move them into the base class
    // and then use them more widely.

    protected SimpleNode transform_binary( String nodeName, SimpleNode node )
    {
        pushElem(nodeName, node);
        flushOpen(node);

        assert node.jjtGetNumChildren() == 2;

            pushElem("xqx:firstOperand", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);

            pushElem("xqx:secondOperand", node);
            flushOpen(node);
            transformChildren(node, 1, 1);
            flushClose(node);

        flushClose(node);

        return node;
    }

    protected void transform_URILiteral( SimpleNode uriliteral_node, String nodeName )
    {
        assert uriliteral_node.id == JJTURILITERAL;
        assert uriliteral_node.jjtGetNumChildren() == 1;
        transform_StringLiteral( sn(uriliteral_node.jjtGetChild(0)), nodeName );
    }

    protected void transform_StringLiteral( SimpleNode stringLiteral, String nodeName )
    {
        assert stringLiteral.id == JJTSTRINGLITERAL;

        pushElem(nodeName, stringLiteral);
        flushOpen(stringLiteral, false);

        String lit = stringLiteral.m_value;
        char delimiter = lit.charAt(0);
        assert lit.charAt( lit.length()-1 ) == delimiter;
        String body = lit.substring(1, lit.length()-1); // get rid of delimiters
        xqprintEscaped(body, delimiter);

        flushClose(stringLiteral, false);
    }

    protected void transform_QName( SimpleNode qname_node, String nodeName )
    {
        assert qname_node.id == JJTQNAME;

        pushElem(nodeName, qname_node);

        String qname = qname_node.m_value;
        qname = processPrefix(qname);

        flushOpen(qname_node, false);
        xqprint(qname);
        flushClose(qname_node, false);
    }

}
// vim: sw=4 ts=4 expandtab
