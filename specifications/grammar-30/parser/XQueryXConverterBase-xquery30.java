/*
 Copyright (c) 2005 W3C(r) (http://www.w3.org/) (MIT (http://www.lcs.mit.edu/),
 INRIA (http://www.inria.fr/), Keio (http://www.keio.ac.jp/)),
 All Rights Reserved.
 See http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Copyright.
 W3C liability
 (http://www.w3.org/Consortium/Legal/ipr-notice-20000612#Legal_Disclaimer),
 trademark
 (http://www.w3.org/Consortium/Legal/ipr-notice-20000612#W3C_Trademarks),
 document use
 (http://www.w3.org/Consortium/Legal/copyright-documents-19990405),
 and software licensing rules
 (http://www.w3.org/Consortium/Legal/copyright-software-19980720)
 apply.
 */
package org.w3c.xqparser;

import java.util.Stack;

/**
 * Transforms an XQuery AST into a XQueryX XML stream.
 */
public class XQueryXConverter_xquery30 extends XQueryXConverter {

    Stack _openXMLElemStack = new Stack();

    static final int BSP_STRIP = 0;

    static final int BSP_PRESERVE = 1;

    int _boundarySpacePolicy = BSP_STRIP;

    public XQueryXConverter_xquery30(ConversionController cc, XMLWriter xw)
    {
        super(cc, xw);
    }

//    protected void pd(int id) {
//        xw.putComment(jjtNodeName[id]);
//    }

    protected boolean isPreviousSiblingBoundaryWhitespaceChar(SimpleNode node) {
        node = getPreviousSibling(node.getParent());
        if (node == null)
            return true;
        if (node.jjtGetNumChildren() > 0)
            node = node.getChild(0);
        if (node.id == JJTCDATASECTION)
            return false;
        else if (node.id == JJTELEMENTCONTENTCHAR
                || node.id == JJTQUOTATTRCONTENTCHAR
                || node.id == JJTAPOSATTRCONTENTCHAR) {
            if (node.m_value.trim().length() == 0) {
                return isPreviousSiblingBoundaryWhitespaceChar(node);
            }
        } else {
            if (node.id == JJTCOMMONCONTENT) {
                node = node.getChild(0);
                if (node.id == JJTLCURLYBRACEESCAPE
                        || node.id == JJTRCURLYBRACEESCAPE
                        || node.id == JJTCHARREF
                        || node.id == JJTPREDEFINEDENTITYREF)
                    return false;
            }
            return true;
        }
        return false;
    }

    protected boolean isNextSiblingBoundaryWhitespaceChar(SimpleNode node) {
        node = getNextSibling(node.getParent());
        if (node == null)
            return true;
        if (node.jjtGetNumChildren() > 0)
            node = node.getChild(0);
        if (node.id == JJTCDATASECTION)
            return false;
        else if (node.id == JJTELEMENTCONTENTCHAR
                || node.id == JJTQUOTATTRCONTENTCHAR
                || node.id == JJTAPOSATTRCONTENTCHAR) {
            if (node.m_value.trim().length() == 0) {
                return isNextSiblingBoundaryWhitespaceChar(node);
            }
        } else {
            if (node.id == JJTCOMMONCONTENT) {
                node = node.getChild(0);
                if (node.id == JJTLCURLYBRACEESCAPE
                        || node.id == JJTRCURLYBRACEESCAPE
                        || node.id == JJTCHARREF
                        || node.id == JJTPREDEFINEDENTITYREF)
                    return false;
            }
            return true;
        }
        return false;
    }

    protected boolean isBoundaryWhitespaceChar(SimpleNode node) {
        if (node.id == JJTCDATASECTION)
            return false;
        if (node.id == JJTELEMENTCONTENTCHAR
                || node.id == JJTQUOTATTRCONTENTCHAR
                || node.id == JJTAPOSATTRCONTENTCHAR) {
            if (node.m_value.trim().length() == 0) {
                if (isPreviousSiblingBoundaryWhitespaceChar(node)
                        && isNextSiblingBoundaryWhitespaceChar(node)) {
                    return true;
                }
            }
        }
        return false;
    }

    protected boolean shouldStripChar(SimpleNode node) {
        if ((_boundarySpacePolicy == BSP_STRIP)
                && isBoundaryWhitespaceChar(node))
            return true;
        else
            return false;
    }

    /**
     * Process a node in the AST and its descendants.
     * @param node  The node to be processed.
     * @return true
     */
    protected boolean transformNode(final SimpleNode node) {
        int id = node.id;
        String xqx_element_name_g = mapNodeIdToXqxElementName(id);
        // The "g" stands for both:
        // "generated" (in that the name is generated mechanically from the
        //     name of the non-terminal that this node is an instance of); and
        // "guess" (in that we don't know at this point whether the name will
        //     be useful/appropriate).

        // -----------------
        // Consistency would dictate that the following if-stmt be handled as
        // a case on JJTCONSTRUCTOR in the subsequent switch-stmt.
        // However, 'Constructor' was renamed to 'NodeConstructor' in XQuery 3.1.
        // You might not expect this to affect this xquery*30* converter,
        // but the xquery31 converter delegates to the xquery30 converter
        // for any constructs that are handled the same in 3.0 and 3.1.
        // So this class is compiled not only in an xquery30 context,
        // but also in an xquery31 context, and in the latter case,
        // JJTCONSTRUCTOR does not exist (though JJTNODECONSTRUCTOR does).
        // To obtain code that will compile in both contexts, we replace the
        // condition:
        //     id == JJTCONSTRUCTOR
        // (in effect) with
        //     jjtNodeName[id] == "Constructor"
        //
        // (Note that although the latter *compiles* in both contexts, it only
        // *works* in xquery30, which is fine. The xquery31 converter can handle
        // the 'NodeConstructor' case.)
        //
        if (jjtNodeName[id] == "Constructor") {
            cc.transformChildren(node);
            return true;
        }

        // -----------------
        // Similarly, in XQuery 3.1, we removed the nonterminals:
        //     TryTargetExpr, ContentExpr, PrefixExpr,  URIExpr
        // when we introduced:
        //     EnclosedTryTryTargetExpr, etc.

        if (jjtNodeName[id] == "TryTargetExpr") {
            cc.transformChildren(node);
            return true;
        }
        if (jjtNodeName[id] == "ContentExpr" || jjtNodeName[id] == "PrefixExpr") {
            xw.putStartTag(node, xqx_element_name_g);
            cc.transformChildren(node);
            xw.putEndTag(node);
            return true;
        }
        if (jjtNodeName[id] == "URIExpr") {
            xw.putStartTag(node, "xqx:URIExpr");
            cc.transformChildren(node);
            xw.putEndTag(node);
            return true;
        }

        // Also, there are a couple spots below marked "kludge for xquery31".
        // These are conditions that will never be true for input conforming
        // to the xquery30 grammar, but can be true for xquery31 input.
        // (I.e., when the xquery31 converter delegates to the xquery30 converter.)
        // Theoretically, the xquery31 converter should take care of these cases,
        // but it's far less bother to change the xquery30 converter.

        // -----------------

        switch (id) {
            case JJTSTART: {
                xw.putXMLDecl();
                // pd(JJTSTART);
                cc.transformChildren(node);
                return true;
            }

            case JJTQUERYLIST: {
                // No action
                // pd(JJTQUERYLIST);
                cc.transformChildren(node);
                return true;
            }

            case JJTMODULE: {
                String[][] attributes = {
                    {"xmlns:xqx", "http://www.w3.org/2005/XQueryX"},
                    {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
                    // {"xsi:noNamespaceSchemaLocation", "xqueryx.xsd"},
                    // {"xsi:noNamespaceSchemaLocation",
                    // "file:///c:/proj/xqed2/grammar/parser/xqueryx.xsd"},
                    {"xsi:schemaLocation",
                        "http://www.w3.org/2005/XQueryX"
                                + "\n                                http://www.w3.org/2005/XQueryX/xqueryx.xsd"}
                };

                xw.putStartTag(node, "xqx:module", attributes, true);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTVERSIONDECL: {
                // pd(JJTVERSIONDECL);
                xw.putStartTag(node, xqx_element_name_g);

                // The children of the VERSIONDECL node are:
                // one for each StringLiteral, and one for Separator.
                int n_children = node.jjtGetNumChildren();
                assert node.getChild(n_children-1).id == JJTSEPARATOR;

                if (node.m_value.equals("encoding"))
                {
                    // VersionDecl -> "xquery" "encoding" StringLiteral Separator
                    xw.putSimpleElement(node, "xqx:encoding", undelimitStringLiteral(node.getChild(0)));
                    assert node.jjtGetNumChildren() == 2;
                }
                else if (node.m_value.equals("version"))
                {
                    // VersionDecl -> "xquery" "version" StringLiteral ("encoding" StringLiteral)? Separator

                    xw.putSimpleElement(node, "xqx:version", undelimitStringLiteral(node.getChild(0)));

                    if (n_children == 2)
                    {
                        xw.putComment("encoding: " + "null");
                    }
                    else if (n_children == 3)
                    {
                        xw.putSimpleElement(node, "xqx:encoding", undelimitStringLiteral(node.getChild(1)));
                    }
                    else
                    {
                        assert false;
                    }
                }
                else
                {
                    assert false;
                }

                xw.putEndTag(node);
                return true;
            }

            case JJTINTEGERLITERAL:
            case JJTDECIMALLITERAL:
            case JJTDOUBLELITERAL:
            case JJTSTRINGLITERAL: {
                if (id == JJTSTRINGLITERAL && getParentID(node) == JJTOPTIONDECL) {
                    xw.putSimpleElement(node, "xqx:optionContents", undelimitStringLiteral(node));
                    return true;
                } else if (id == JJTSTRINGLITERAL && getParentID(node) == JJTDECIMALFORMATDECL) {
                    xw.putSimpleElement(node, "xqx:decimalFormatParamValue", undelimitStringLiteral(node));
                    return true;
                }

                String elemName;
                switch (id) {
                    case JJTINTEGERLITERAL:
                        elemName = "xqx:integerConstantExpr";
                        break;
                    case JJTDECIMALLITERAL:
                        elemName = "xqx:decimalConstantExpr";
                        break;
                    case JJTDOUBLELITERAL:
                        elemName = "xqx:doubleConstantExpr";
                        break;
                    case JJTSTRINGLITERAL:
                        elemName = "xqx:stringConstantExpr";
                        break;
                    default:
                        elemName = "UNKNOWN!";
                        break;
                }

                String content =
                    (id == JJTSTRINGLITERAL)
                    ? undelimitStringLiteral(node)
                    : node.m_value;

                xw.putStartTag(node, elemName);

                xw.putSimpleElement(node, "xqx:value", content);

                xw.putEndTag(node);
                return true;
            }

            case JJTBASEURIDECL:
                // handled in JJTBASEURIDECL
                cc.transformChildren(node);
                return true;

            case JJTURILITERAL: {
                String xqx_element_name;
                if (getParentID(node) == JJTBASEURIDECL)
                    xqx_element_name = "xqx:baseUriDecl";
                else if (getParentID(node) == JJTORDERMODIFIER)
                    xqx_element_name = "xqx:collation";
                else if (getParentID(node) == JJTGROUPINGSPEC)
                    xqx_element_name = "xqx:collation";
                else if (getParentID(node) == JJTDEFAULTCOLLATIONDECL)
                    xqx_element_name = "xqx:defaultCollationDecl";
                else if (getParentID(node) == JJTMODULEIMPORT) {
                    SimpleNode firstChild = node.getParent().getChild(0);
                    if ((firstChild == node)
                            || (firstChild.id == JJTNCNAME &&
                                ((node.getParent().getChild(1)) == node)))
                        xqx_element_name = "xqx:targetNamespace";
                    else
                        xqx_element_name = "xqx:targetLocation";
                } else
                    xqx_element_name = "xqx:uri";
                SimpleNode child = node.getChild(0);
                xw.putSimpleElement(node, xqx_element_name, undelimitStringLiteral(child));
                return true;
            }

            case JJTNAMEDFUNCTIONREF: {
                xw.putStartTag(node, "xqx:namedFunctionRef");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTPROLOG: {
                if (node.jjtGetNumChildren() > 0) {
                    // pd(JJTPROLOG);
                    xw.putStartTag(node, "xqx:prolog");
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                    return true;
                } else {
                    return true;
                }
            }

            case JJTURIQUALIFIEDSTAR: {
                String uri_qualified_star = node.m_value;
                int i = uri_qualified_star.lastIndexOf('}');
                String uri = uri_qualified_star.substring(2, i);
                String star = uri_qualified_star.substring(i + 1);
                assert star.equals("*");
                xw.putSimpleElement(node, "xqx:uri", uri);
                xw.putEmptyElement(node, "xqx:star");
                return true;
            }

            case JJTNCNAMECOLONSTAR: {
                String ncname_colon_star = node.m_value;
                int i = ncname_colon_star.indexOf(':');
                String ncname = ncname_colon_star.substring(0, i);
                String star = ncname_colon_star.substring(i + 1);
                assert star.equals("*");
                xw.putSimpleElement(node, "xqx:NCName", ncname);
                xw.putEmptyElement(node, "xqx:star");
                return true;
            }

            case JJTSTARCOLONNCNAME: {
                String star_colon_ncname = node.m_value;
                int i = star_colon_ncname.indexOf(':');
                String star = star_colon_ncname.substring(0, i);
                String ncname = star_colon_ncname.substring(i + 1);
                assert star.equals("*");
                xw.putEmptyElement(node, "xqx:star");
                xw.putSimpleElement(node, "xqx:NCName", ncname);
                return true;
            }

            case JJTSINGLETYPE: {
                boolean optionality = (node.m_value != null);
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                if (optionality) {
                    xw.putEmptyElement(node, "xqx:optional");
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTPRAGMAOPEN:
            case JJTPRAGMACLOSE:
                // No Action
                return true;

            case JJTATOMICORUNIONTYPE:
                // handled in JJTQNAME
                cc.transformChildren(node);
                return true;

            case JJTATTRIBNAMEORWILDCARD:
            case JJTELEMENTNAMEORWILDCARD:
                if (node.m_value != null && node.m_value.equals("*")) {
                    String xqx_element_name =
                        mapNodeIdToXqxElementName(
                            (id == JJTATTRIBNAMEORWILDCARD)
                            ? JJTATTRIBUTENAME
                            : JJTELEMENTNAME
                        );
                    xw.putStartTag(node, xqx_element_name);
                    xw.putEmptyElement(node, "xqx:star");
                    xw.putEndTag(node);
                    return true;
                } else {
                    cc.transformChildren(node);
                    return true;
                }

            case JJTATTRIBUTENAME:
            case JJTELEMENTNAME:
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // case JJTTYPENAME:
            case JJTURIQUALIFIEDNAME:
            case JJTNCNAME:
            case JJTQNAME: {
                int pid = getParentID(node);
                String xqx_element_name;
                if (pid == JJTCOMPELEMCONSTRUCTOR || pid == JJTCOMPATTRCONSTRUCTOR)
                    xqx_element_name = "xqx:tagName";
                else if (pid == JJTTYPENAME)
                {
                    // The TypeName's parent could be:
                    //  - a ValidateExpr, an AttributeTest, or an ElementTest,
                    //    for which xqx:typeName is the correct result,
                    //  or
                    //  - a SimpleTypeName (in a SingleType), and
                    //    backwards-compatibility for xqx:singleType means
                    //    that the correct result is xqx:atomicType.
                    if (node.getParent().getParent().id == JJTSIMPLETYPENAME)
                        xqx_element_name = "xqx:atomicType";
                    else
                        xqx_element_name = "xqx:typeName";
                }
                else if (pid == JJTCOMPPICONSTRUCTOR)
                    xqx_element_name = "xqx:piTarget";
                else if (pid == JJTATOMICORUNIONTYPE) // XXX
                    xqx_element_name = "xqx:atomicType";
                else if (pid == JJTNAMESPACEDECL)
                    xqx_element_name = "xqx:prefix";
                else if (pid == JJTVARDECL || pid == JJTPARAM)
                    xqx_element_name = "xqx:varName";
                else if (pid == JJTFUNCTIONDECL || pid == JJTFUNCTIONCALL || pid == JJTNAMEDFUNCTIONREF )
                    xqx_element_name = "xqx:functionName";
                else if (pid == JJTOPTIONDECL)
                    xqx_element_name = "xqx:optionName";
                else if (pid == JJTOPTIONDECL)
                    xqx_element_name = "xqx:optionName";
                else if (pid == JJTMODULEIMPORT)
                    xqx_element_name = "xqx:namespacePrefix";
                else if (pid == JJTPRAGMA)
                    xqx_element_name = "xqx:pragmaName";
                else if (pid == JJTCURRENTITEM)
                    xqx_element_name = "xqx:currentItem";
                else if (pid == JJTNEXTITEM)
                    xqx_element_name = "xqx:nextItem";
                else if (pid == JJTPREVIOUSITEM)
                    xqx_element_name = "xqx:previousItem";
                else if (pid == JJTDECIMALFORMATDECL)
                    xqx_element_name = "xqx:decimalFormatName";
                else if (pid == JJTANNOTATION)
                    xqx_element_name = "xqx:annotationName";
                else
                    xqx_element_name = "xqx:QName";
                transform_name(node, xqx_element_name);
                return true;
            }

            case JJTENDTAGQNAME:
                SimpleNode openTag = (SimpleNode)_openXMLElemStack.peek();
                if(!openTag.getValue().equals(node.getValue()))
                    throw new PostParseException("Error: In a direct element constructor, the name used in the end tag must exactly match the name used in the corresponding start tag, including its prefix or absence of a prefix.");
                return true;

            case JJTTAGQNAME: {
                if (getParentID(node) == JJTDIRATTRIBUTELIST
                        && isNamespaceDecl(node)) {
                    if(!node.m_value.equals("xmlns")){
                        int i = node.m_value.indexOf(':');
                        String prefix = node.m_value.substring(i + 1);
                        xw.putSimpleElement(node, "xqx:prefix", prefix);
                    }
                    return true;
                }

                String xqx_element_name;
                if (getParentID(node) == JJTDIRATTRIBUTELIST) {
                    xqx_element_name = "xqx:attributeName";
                } else {
                    xqx_element_name = "xqx:tagName";
                }
                transform_name(node, xqx_element_name);

                return true;
            }

            case JJTFUNCTIONQNAME: {
                transform_name(node, "xqx:functionName");
                return true;
            }

            case JJTWILDCARD:
                if (node.jjtGetNumChildren() == 0) {
                    xw.putEmptyElement(node, "xqx:Wildcard");
                } else {
                    xw.putStartTag(node, "xqx:Wildcard");
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                }
                return true;

            case JJTNAMETEST:
                if (getChildID(node, 0) == JJTWILDCARD) {
                    cc.transformChildren(node);
                    return true;
                } else {
                    transform_name(node.getChild(0), "xqx:nameTest");
                    return true;
                }

            case JJTVARNAME: {
                SimpleNode parent = node.getParent();
                int pid = parent.id;
                if (/* pid == JJTCASECLAUSE || */
                    pid == JJTTYPESWITCHEXPR && getNextSibling(node) != null) {
                    transform_name(node.getChild(0), "xqx:variableBinding");
                } else if (pid == JJTVARDECL || pid == JJTGROUPINGVARIABLE) {
                    transform_name(node.getChild(0), "xqx:varName");
                } else {
                    xw.putStartTag(node, "xqx:varRef");
                    transform_name(node.getChild(0), "xqx:name");
                    xw.putEndTag(node);
                }
                return true;
            }

            case JJTPOSITIONALVAR: {
                transform_name(node.getChild(0).getChild(0), "xqx:positionalVariableBinding");
                return true;
            }

            case JJTITEMTYPE:
                if (node.m_value != null && node.m_value.equals("item")) {
                    xw.putEmptyElement(node, "xqx:anyItemType");
                    return true;
                } else {
                    cc.transformChildren(node);
                    return true;
                }

            case JJTSEQUENCETYPE: {
                int pid = getParentID(node);
                boolean shouldBeSeqType = (pid == JJTSEQUENCETYPEUNION || pid == JJTTYPEDFUNCTIONTEST);
                if (shouldBeSeqType) {
                    xw.putStartTag(node, "xqx:sequenceType");
                }
                else if (pid == JJTFUNCTIONDECL) {
                    xw.putStartTag(node, "xqx:typeDeclaration");
                }
                if (node.m_value != null && node.m_value.equals("empty-sequence")) {
                    xw.putEmptyElement(node, "xqx:voidSequenceType");
                } else {
                    cc.transformChildren(node);
                }
                if (shouldBeSeqType || pid == JJTFUNCTIONDECL) {
                    xw.putEndTag(node);
                }
                return true;
            }

            case JJTEXPR:
                // sequenceExpr
                // (getParentID(node) == JJTPARENTHESIZEDEXPR || getParentID(node)
                // == JJTQUERYBODY)
                if (getNumExprChildren(node) > 1) {
                    xw.putStartTag(node, "xqx:sequenceExpr");
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                }
                else {
                    cc.transformChildren(node);
                }
                return true;

            case JJTSIMPLEMAPEXPR:
                transform_SimpleMapExpr(node, getNumExprChildren(node)-1);
                return true;

            case JJTPATHEXPR: {
                    // First, check whether we can translate this node
                    // without an xqx:pathExpr element.
                    // If the PathExpr's parent is a SimpleMapExpr,
                    // then we can't shortcut, because xqx:simpleMapExpr's children
                    // must be xqx:pathExprs.
                    if (getParentID(node) != JJTSIMPLEMAPEXPR && node.jjtGetNumChildren() == 1) {
                        SimpleNode only_child = node.getChild(0);
                        if (only_child.id == JJTPOSTFIXEXPR && only_child.jjtGetNumChildren() == 1)
                        {
                            SimpleNode only_grandchild = only_child.getChild(0);
                            // only_grandchild is some kind of PrimaryExpr node,
                            // so it doesn't need to be in a pathExpr.
                            cc.transform(only_grandchild);
                            return true;
                        }
                    }

                    xw.putStartTag(node, xqx_element_name_g);

                    String xqx_element_name_for_next_step = "xqx:stepExpr";
                    for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                        SimpleNode child = node.getChild(i);
                        if(child.id == JJTSLASH){
                            if (i==0) xw.putEmptyElement(child, "xqx:rootExpr");
                            xqx_element_name_for_next_step = "xqx:stepExpr";
                        }
                        else if(child.id == JJTSLASHSLASH){
                            if (i==0) xw.putEmptyElement(child, "xqx:rootExpr");
                            xw.putStartTag(child, "xqx:stepExpr");
                            xw.putSimpleElement(child, "xqx:xpathAxis", "descendant-or-self");
                            xw.putEmptyElement(child, "xqx:anyKindTest");
                            xw.putEndTag(child);
                            xqx_element_name_for_next_step = "xqx:stepExpr";
                        }
                        else {
                            assert child.id == JJTAXISSTEP || child.id == JJTPOSTFIXEXPR;
                            xw.putStartTag(child, xqx_element_name_for_next_step);
                            cc.transform(child);
                            xw.putEndTag(child);
                            xqx_element_name_for_next_step = null;
                        }
                    }
                    xw.putEndTag(node);
                    return true;
            }

            case JJTPREDICATELIST:
                xw.putStartTag(node, "xqx:predicates");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTFUNCTIONCALL: {
                xw.putStartTag(node, "xqx:functionCallExpr");

                cc.transformChildren(node);

                xw.putEndTag(node);

                return true;
            }

            case JJTARGUMENTLIST:
                xw.putStartTag(node, "xqx:arguments");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTARGUMENT:
                cc.transformChildren(node);
                return true;

            case JJTARGUMENTPLACEHOLDER:
                xw.putEmptyElement(node, "xqx:argumentPlaceholder");
                return true;

            case JJTPOSTFIXEXPR: {
                int end = node.jjtGetNumChildren() - 1;
                convert_pPostfixExpr_to_content_for_stepExpr(node, end);
                return true;
            }

            case JJTAXISSTEP:
                cc.transformChildren(node);
                return true;

            case JJTFORWARDAXIS:
            case JJTREVERSEAXIS: {
                String axisStr = node.m_value;
                xw.putSimpleElement(node, "xqx:xpathAxis", axisStr);
                return true;
            }

            case JJTABBREVREVERSESTEP:
                xw.putSimpleElement(node, "xqx:xpathAxis", "parent");
                xw.putEmptyElement(node, "xqx:anyKindTest");
                return true;

            case JJTABBREVFORWARDSTEP: {
                        //  AbbrevForwardStep ::= "@"? NodeTest
                        SimpleNode nodeTest = node.getChild(0);
                        String optionalAttribIndicator = node.m_value;
                        if (optionalAttribIndicator != null
                                && optionalAttribIndicator.equals("@")) {
                            // "The attribute axis attribute:: can be abbreviated by @."
                            xw.putSimpleElement(node, "xqx:xpathAxis", "attribute");
                        } else {
                            // "If the axis name is omitted from an axis step,
                            // the default axis is child, with two exceptions:
                            // if the axis step contains an AttributeTest or SchemaAttributeTest
                            // then the default axis is attribute;
                            // if the axis step contains namespace-node()
                            // then the default axis is namespace."
                            // [But XQuery does not support the namespace axis,
                            // so the second exception does not apply.]
                            SimpleNode nodeTest_child = nodeTest.getChild(0);
                            if (
                                   nodeTest_child.id == JJTATTRIBUTETEST
                                || nodeTest_child.id == JJTSCHEMAATTRIBUTETEST
                            ) {
                                xw.putSimpleElement(node, "xqx:xpathAxis", "attribute");
                            } else {
                                xw.putSimpleElement(node, "xqx:xpathAxis", "child");
                            }
                        }

                        // The NodeTest within the AbbrevForwardStep:
                        cc.transform(nodeTest);
                        return true;
                    }

            case JJTQUANTIFIEDEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                xw.putSimpleElement(node, "xqx:quantifier", node.m_value);

                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n - 1;) {
                    SimpleNode typedVariableBinding = node.getChild(i);
                    i++;

                    xw.putStartTag(node, "xqx:quantifiedExprInClause");

                    xw.putStartTag(node, "xqx:typedVariableBinding");

                    transform_name(typedVariableBinding.getChild(0), typedVariableBinding.id);

                    SimpleNode nextChild = node.getChild(i);
                    i++;

                    if (nextChild.id == JJTTYPEDECLARATION) {
                        cc.transform(nextChild);
                        nextChild = node.getChild(i);
                        i++;
                    }
                    xw.putEndTag(node); // xqx:typedVariableBinding

                    xw.putStartTag(node, "xqx:sourceExpr");

                    cc.transform(nextChild);

                    xw.putEndTag(node);
                    xw.putEndTag(node);

                }
                xw.putStartTag(node, "xqx:predicateExpr");
                cc.transformChildren(node, n - 1, n - 1);
                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;
            }


            case JJTCATCHCLAUSE: {
                xw.putStartTag(node, "xqx:catchClause");
                for (int n = 0; n < node.jjtGetNumChildren(); n++) {
                   SimpleNode child = node.getChild(n);
                   if (child.id == JJTEXPR
                       || child.id == JJTENCLOSEDEXPR /* kludge for xquery31 */) {
                      xw.putStartTag(child, "xqx:catchExpr");
                      cc.transform(child);
                      xw.putEndTag(child);
                   }
                   else {
                      cc.transform(child);
                   }
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTIFEXPR:
                xw.putStartTag(node, "xqx:ifThenElseExpr");

                xw.putStartTag(node, "xqx:ifClause");
                cc.transformChildren(node, 0, 0);
                xw.putEndTag(node);

                xw.putStartTag(node, "xqx:thenClause");
                cc.transformChildren(node, 1, 1);
                xw.putEndTag(node);

                xw.putStartTag(node, "xqx:elseClause");
                cc.transformChildren(node, 2, 2);
                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            case JJTFLWOREXPR11: {
                xw.putStartTag(node, "xqx:flworExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTINITIALCLAUSE:
            case JJTINTERMEDIATECLAUSE: {
                cc.transformChildren(node);
                return true;
            }

            case JJTRANGEEXPR: {
                xw.putStartTag(node, "xqx:rangeSequenceExpr");
                {
                    xw.putStartTag(node, "xqx:startExpr");
                    cc.transform(node.getChild(0));
                    xw.putEndTag(node);
                }
                {
                    xw.putStartTag(node, "xqx:endExpr");
                    cc.transform(node.getChild(1));
                    xw.putEndTag(node);
                }

                xw.putEndTag(node);
                return true;
            }

            case JJTUNARYEXPR: {
                int nUnarys = 0;
                for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                    SimpleNode child = node.getChild(i);
                    if (child.id == JJTPLUS) {
                        xw.putStartTag(node, "xqx:unaryPlusOp");
                        xw.putStartTag(node, "xqx:operand");
                        nUnarys++;
                    } else if (child.id == JJTMINUS) {
                        xw.putStartTag(node, "xqx:unaryMinusOp");
                        xw.putStartTag(node, "xqx:operand");
                        nUnarys++;
                    } else {
                        cc.transform(child);
                        for (int j = 0; j < nUnarys; j++) {
                            xw.putEndTag(node);
                            xw.putEndTag(node);
                        }
                        break;
                    }
                }
                return true;
            }

            // setOp??
            case JJTSTRINGCONCATEXPR:
            case JJTADDITIVEEXPR:
            case JJTMULTIPLICATIVEEXPR:
            case JJTUNIONEXPR:
            case JJTINTERSECTEXCEPTEXPR:
            case JJTCOMPARISONEXPR:
            case JJTANDEXPR:
            case JJTOREXPR: {
                String elemName;
                switch (id) {
                    case JJTSTRINGCONCATEXPR:
                        elemName = "xqx:stringConcatenateOp";
                        break;
                    case JJTADDITIVEEXPR: {
                        String op = node.m_value;
                        if (op.equals("+"))
                            elemName = "xqx:addOp";
                        else if (op.equals("-"))
                            elemName = "xqx:subtractOp";
                        else
                            elemName = "JJTADDITIVEEXPR UNKNOWN EXPR!";
                    }
                        break;
                    case JJTMULTIPLICATIVEEXPR: {
                        String op = node.m_value;
                        if (op.equals("*"))
                            elemName = "xqx:multiplyOp";
                        else if (op.equals("div"))
                            elemName = "xqx:divOp";
                        else if (op.equals("idiv"))
                            elemName = "xqx:idivOp";
                        else if (op.equals("mod"))
                            elemName = "xqx:modOp";
                        else
                            elemName = "JJTMULTIPLICATIVEEXPR UNKNOWN EXPR: " + op;
                    }
                        break;
                    case JJTUNIONEXPR:
                        elemName = "xqx:unionOp";
                        break;
                    case JJTINTERSECTEXCEPTEXPR: {
                        String op = node.m_value;
                        if (op.equals("intersect"))
                            elemName = "xqx:intersectOp";
                        else if (op.equals("except"))
                            elemName = "xqx:exceptOp";
                        else
                            elemName = "JJTINTERSECTEXCEPTEXPR UNKNOWN EXPR: " + op;
                    }
                        break;
                    case JJTANDEXPR:
                        elemName = "xqx:andOp";
                        break;
                    case JJTOREXPR:
                        elemName = "xqx:orOp";
                        break;
                    case JJTCOMPARISONEXPR: {
                        String op = node.m_value;
                        if (op.equals("eq"))
                            elemName = "xqx:eqOp";
                        else if (op.equals("ne"))
                            elemName = "xqx:neOp";
                        else if (op.equals("lt"))
                            elemName = "xqx:ltOp";
                        else if (op.equals("le"))
                            elemName = "xqx:leOp";
                        else if (op.equals("gt"))
                            elemName = "xqx:gtOp";
                        else if (op.equals("ge"))
                            elemName = "xqx:geOp";
                        else if (op.equals("="))
                            elemName = "xqx:equalOp";
                        else if (op.equals("!="))
                            elemName = "xqx:notEqualOp";
                        else if (op.equals("<"))
                            elemName = "xqx:lessThanOp";
                        else if (op.equals("<="))
                            elemName = "xqx:lessThanOrEqualOp";
                        else if (op.equals(">"))
                            elemName = "xqx:greaterThanOp";
                        else if (op.equals(">="))
                            elemName = "xqx:greaterThanOrEqualOp";
                        else if (op.equals("is"))
                            elemName = "xqx:isOp";
                        else if (op.equals("<<"))
                            elemName = "xqx:nodeBeforeOp";
                        else if (op.equals(">>"))
                            elemName = "xqx:nodeAfterOp";
                        else
                            elemName = "JJTCOMPARISONEXPR UNKNOWN: " + op;
                    }
                        break;
                    default:
                        elemName = "???";
                        break;
                }
                xw.putStartTag(node, elemName);

                {
                    xw.putStartTag(node, "xqx:firstOperand");
                    cc.transform(node.getChild(0));
                    xw.putEndTag(node);
                }
                {
                    xw.putStartTag(node, "xqx:secondOperand");
                    cc.transform(node.getChild(1));
                    xw.putEndTag(node);
                }

                xw.putEndTag(node);
                return true;
            }

            case JJTLETCLAUSE:
            case JJTFORCLAUSE: {
                xw.putStartTag(node, xqx_element_name_g);

                cc.transformChildren(node);

                xw.putEndTag(node);

                return true;
            }

            case JJTFORBINDING:
            case JJTLETBINDING: {
                boolean is_for = (id == JJTFORBINDING);

                int i = transform_ClauseItem(node, is_for, 0);
                assert i == node.jjtGetNumChildren();
                return true;
            }

            case JJTALLOWINGEMPTY: {
                 xw.putEmptyElement(node, "xqx:allowingEmpty");
                return true;
            }

            case JJTGROUPINGSPECLIST: {
                cc.transformChildren(node);
                return true;
            }

            case JJTGROUPINGSPEC: {
                xw.putStartTag(node, xqx_element_name_g);

                // GroupingSpec ::=
                //     GroupingVariable
                //     (TypeDeclaration? ":=" ExprSingle)?
                //     ("collation" URILiteral)?
                // Gaah, two optional chunks in the RHS.

                int n = node.jjtGetNumChildren();

                int i = 0;

                // chunk 1:  GroupingVariable
                cc.transformChildren(node, i, i); i++;

                if (i<n && node.getChild(i).id != JJTURILITERAL) {
                    // chunk 2 is present:  TypeDeclaration? ":=" ExprSingle
                    xw.putStartTag(node, "xqx:groupVarInitialize");

                        if (node.getChild(i).id == JJTTYPEDECLARATION) {
                            cc.transformChildren(node, i, i); i++;
                        }

                        xw.putStartTag(node, "xqx:varValue");
                        cc.transformChildren(node, i, i); i++;
                        xw.putEndTag(node);

                    xw.putEndTag(node);
                }

                if (i<n) {
                    // chunk 3 is present:  "collation" URILiteral
                    cc.transformChildren(node, i, i); i++;
                }

                assert i == n;

                xw.putEndTag(node);
                return true;
            }

            case JJTGROUPINGVARIABLE:
                cc.transformChildren(node);
                return true;

            case JJTORDERBYCLAUSE: {
                xw.putStartTag(node, xqx_element_name_g);
                if (node.m_value != null && node.m_value.equals("stable")) {
                    xw.putEmptyElement(node, "xqx:stable");
                }
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTORDERSPECLIST: {
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    xw.putStartTag(node, "xqx:orderBySpec");
                    cc.transform(child);

                    if (child.id == JJTORDERSPEC) {
                        int n2 = child.jjtGetNumChildren();
                        for (int j = 0; j < n2; j++) {
                            SimpleNode child2 = child.getChild(j);
                            if (child2.id == JJTORDERMODIFIER) {
                                if (child2.jjtGetNumChildren() > 0)
                                    cc.transform(child2);
                            }
                        }
                    }
                    xw.putEndTag(node);
                }
                return true;
            }

            case JJTORDERSPEC: {
                xw.putStartTag(node, "xqx:orderByExpr");
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    if (child.id != JJTORDERMODIFIER)
                        cc.transform(child);
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTORDERMODIFIER:
                if (node.jjtGetNumChildren() == 0)
                    return true;
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTPITEST: {
                if (node.jjtGetNumChildren() > 0) {
                    xw.putStartTag(node, "xqx:piTest");
                    SimpleNode child = node.getChild(0);
                    String content =
                        (child.id == JJTSTRINGLITERAL)
                        ? undelimitStringLiteral(child)
                        : child.m_value;
                    xw.putSimpleElement(child, "xqx:piTarget", content);

                    xw.putEndTag(node);
                } else {
                    xw.putEmptyElement(node, "xqx:piTest");
                }
                return true;
            }

            case JJTSCHEMAIMPORT: {
                xw.putStartTag(node, "xqx:schemaImport");

                SimpleNode child = node.getChild(0);
                SimpleNode targetNamespace;
                int start = 0;
                if (child.id == JJTSCHEMAPREFIX && child.jjtGetNumChildren() > 0) {
                    xw.putSimpleElement(node, "xqx:namespacePrefix", child.getChild(0).m_value);
                    start++;
                    targetNamespace = node.getChild(1);
                    start++;
                } else if (child.id == JJTSCHEMAPREFIX) {
                    xw.putEmptyElement(node, "xqx:defaultElementNamespace");
                    start++;
                    targetNamespace = node.getChild(1);
                    start++;
                } else {
                    targetNamespace = child;
                    start++;
                }
                xw.putSimpleElement(targetNamespace, "xqx:targetNamespace", undelimitStringLiteral(targetNamespace.getChild(0)));

                for (int i = start; i < node.jjtGetNumChildren(); i++) {
                    SimpleNode tl = node.getChild(i);
                    xw.putSimpleElement(tl, "xqx:targetLocation", undelimitStringLiteral(tl.getChild(0)));
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTASCENDING:
            case JJTDESCENDING: {
                String content =
                    (id == JJTASCENDING)
                    ? "ascending"
                    : "descending";
                xw.putSimpleElement(node, "xqx:orderingKind", content);
                return true;
            }

            case JJTGREATEST:
            case JJTLEAST: {
                String xqx_element_name =
                    (getParentID(node) == JJTEMPTYORDERDECL)
                    ? "xqx:emptyOrderingDecl"
                    : "xqx:emptyOrderingMode";
                String content =
                    (id == JJTGREATEST)
                    ? "empty greatest"
                    : "empty least";
                xw.putSimpleElement(node, xqx_element_name, content);
                return true;
            }

            case JJTPARENTHESIZEDEXPR:
                if (node.jjtGetNumChildren() == 0) {
                    xw.putEmptyElement(node, "xqx:sequenceExpr");
                    return true;
                } else {
                    cc.transformChildren(node);
                    return true;
                }

            case JJTDEFAULTNAMESPACEDECL: {
                xw.putStartTag(node, xqx_element_name_g);
                xw.putSimpleElement(node, "xqx:defaultNamespaceCategory", node.m_value);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTBOUNDARYSPACEDECL:
                if (node.m_value.equals("preserve"))
                    _boundarySpacePolicy = BSP_PRESERVE;
                else
                    _boundarySpacePolicy = BSP_STRIP;
                return true;

            case JJTOCCURRENCEINDICATOR:
            case JJTORDERINGMODEDECL:
            case JJTPRESERVEMODE:
            case JJTINHERITMODE:
            case JJTCONSTRUCTIONDECL:
                xw.putSimpleElement(node, xqx_element_name_g, node.m_value);
                return true;

            case JJTINSTANCEOFEXPR:
            case JJTTREATEXPR:
            case JJTCASTABLEEXPR:
            case JJTCASTEXPR: {
                String xqx_element_name =
                    (id == JJTINSTANCEOFEXPR)
                    ? "xqx:instanceOfExpr"
                    : xqx_element_name_g;
                xw.putStartTag(node, xqx_element_name);
                xw.putStartTag(node, "xqx:argExpr");
                cc.transformChildren(node, 0, 0);
                xw.putEndTag(node);
                if (id != JJTCASTEXPR && id != JJTCASTABLEEXPR) {
                    xw.putStartTag(node, "xqx:sequenceType");
                    cc.transformChildren(node, 1, 1);
                    xw.putEndTag(node);
                } else {
                    cc.transformChildren(node, 1, 1);
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTORDEREDEXPR:
            case JJTUNORDEREDEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                xw.putStartTag(node, "xqx:argExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTTYPESWITCHEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                xw.putStartTag(node, "xqx:argExpr");
                cc.transformChildren(node, 0, 0);
                xw.putEndTag(node);

                int n = node.jjtGetNumChildren();
                int startOfDefault = n - 2;
                cc.transformChildren(node, 1, startOfDefault - 1);

                if (getChildID(node, startOfDefault) != JJTVARNAME) {
                    cc.transformChildren(node, startOfDefault, startOfDefault);
                    startOfDefault++;
                }
                xw.putStartTag(node, "xqx:typeswitchExprDefaultClause");
                if (startOfDefault == n - 2) {
                    cc.transformChildren(node, startOfDefault, startOfDefault);
                    startOfDefault++;
                }
                xw.putStartTag(node, "xqx:resultExpr");
                cc.transformChildren(node, startOfDefault, startOfDefault);
                xw.putEndTag(node);

                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;
            }

            case JJTCASECLAUSE: {
                xw.putStartTag(node, "xqx:typeswitchExprCaseClause");

                int nChildren = node.jjtGetNumChildren();
                int currentChild = 0;
                if (nChildren == 3) {
                    currentChild++;
                    transform_name(getFirstChildOfFirstChild(node), "xqx:variableBinding");
                }

                cc.transformChildren(node, currentChild, currentChild);
                currentChild++;
                xw.putStartTag(node, "xqx:resultExpr");
                cc.transformChildren(node, currentChild);
                xw.putEndTag(node);
                xw.putEndTag(node);

                return true;
            }

            case JJTSEQUENCETYPEUNION:
                if (node.jjtGetNumChildren() == 1) {
                    cc.transformChildren(node);
                    // It would also be correct to treat this case the same as
                    // the general case. However, doing so would change the output
                    // for all (old) queries involving a TypeswitchExpr, which
                    // would be an annoyance for the XQTS.
                } else {
                    xw.putStartTag(node, xqx_element_name_g);
                    cc.transformChildren(node);
                    xw.putEndTag(node);
                }
                return true;

            case JJTSWITCHEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                xw.putStartTag(node, "xqx:argExpr");
                cc.transformChildren(node, 0, 0);
                xw.putEndTag(node);

                int n = node.jjtGetNumChildren();
                int startOfDefault = n - 1;
                cc.transformChildren(node, 1, startOfDefault - 1);

                xw.putStartTag(node, "xqx:switchExprDefaultClause");
                xw.putStartTag(node, "xqx:resultExpr");
                cc.transformChildren(node, startOfDefault, startOfDefault);
                xw.putEndTag(node);

                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;
            }

            case JJTSWITCHCASECLAUSE: {
                xw.putStartTag(node, "xqx:switchExprCaseClause");

                int nChildren = node.jjtGetNumChildren();

                for (int i = 0; i < nChildren - 1; i++) {
                   xw.putStartTag(node, "xqx:switchCaseExpr");
                   cc.transformChildren(node, i, i);
                   xw.putEndTag(node);
                }

                xw.putStartTag(node, "xqx:resultExpr");
                cc.transformChildren(node, nChildren - 1);
                xw.putEndTag(node);
                xw.putEndTag(node);

                return true;
            }

            case JJTANNOTATEDDECL: {

                int end = node.jjtGetNumChildren() - 1;
                String xqx_element_name = mapNodeIdToXqxElementName(getChildID(node, end));
                xw.putStartTag(node, xqx_element_name);

                cc.transformChildren(node);

                xw.putEndTag(node);
                return true;
            }

            case JJTANNOTATION: {
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node, 0, 0);
                int nc = node.jjtGetNumChildren();
                if ( nc > 1 ) {
                    xw.putStartTag(node, "xqx:arguments");
                    cc.transformChildren(node, 1);
                    xw.putEndTag(node);
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTFUNCTIONDECL: {

                int start = 0;
                cc.transformChildren(node, start, start);
                start++;

                if (getChildID(node, start) == JJTPARAMLIST) {
                    cc.transformChildren(node, start, start);
                    start++;
                } else {
                    xw.putEmptyElement(node, "xqx:paramList");
                }

                int end = node.jjtGetNumChildren() - 1;
                cc.transformChildren(node, start, end - 1);

                start = end;
                if (getChildID(node, end) == JJTEXTERNAL) {
                    xw.putEmptyElement(node, "xqx:externalDefinition");
                } else {
                    xw.putStartTag(node, "xqx:functionBody");
                    cc.transformChildren(node, start, end);
                    xw.putEndTag(node);
                }
                return true;
            }

            case JJTINLINEFUNCTIONEXPR: {
                xw.putStartTag(node, "xqx:inlineFunctionExpr");
                int start = 0;
                int end = node.jjtGetNumChildren() - 1;

                while (getChildID(node, start) == JJTANNOTATION) {
                    cc.transformChildren(node, start, start);
                    start++;
                }

                if (getChildID(node, start) == JJTPARAMLIST) {
                    cc.transformChildren(node, start, start);
                    start++;
                } else {
                    xw.putEmptyElement(node, "xqx:paramList");
                }

                if (getChildID(node, start) == JJTSEQUENCETYPE) {
                   xw.putStartTag(node, "xqx:typeDeclaration");
                   cc.transformChildren(node, start, start++);
                   xw.putEndTag(node);
                }

                xw.putStartTag(node, "xqx:functionBody");
                cc.transformChildren(node, start, end);
                xw.putEndTag(node);

                xw.putEndTag(node);

                return true;
            }

            case JJTVARDECL: {
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                     SimpleNode child = node.getChild(i);
                     if (child.id == JJTEXTERNAL) {
                        if (i != n - 1) {
                            xw.putStartTag(child, "xqx:external");
                           cc.transformChildren(node, n - 1, n - 1);
                           xw.putEndTag(child);
                           i++;
                        }
                        else {
                            xw.putEmptyElement(child, "xqx:external");
                        }
                     }
                     else cc.transform(child);
               }
                return true;
            }

            case JJTVARDEFAULTVALUE: {
                xw.putStartTag(node, "xqx:varValue");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTCONTEXTITEMDECL: {
                xw.putStartTag(node, xqx_element_name_g);
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                     SimpleNode child = node.getChild(i);
                     switch (child.id) {

                        case JJTITEMTYPE: {
                           xw.putStartTag(child, "xqx:contextItemType");
                           cc.transform(child);
                           xw.putEndTag(child);
                           break;
                        }

                        case JJTEXTERNAL: {
                           if (i != n - 1) {
                               xw.putStartTag(child, "xqx:external");
                              cc.transformChildren(node, n - 1, n - 1);
                              xw.putEndTag(child);
                              i++;
                           }
                           else {
                               xw.putEmptyElement(child, "xqx:external");
                           }
                           break;
                        }

                        default:
                           cc.transform(child);
                    }
                }
                xw.putEndTag(node);
                return true;
            }


            case JJTDECIMALFORMATDECL: {
                SimpleNode child = null;
                int i = 0;
                int n = node.jjtGetNumChildren();

                xw.putStartTag(node, xqx_element_name_g);

                child = node.getChild(i);
                if (child.id == JJTQNAME || child.id == JJTURIQUALIFIEDNAME) {
                   cc.transform(child);
                   i++;
                }
                else {
                   // no QName, so it must be a default declaration
                }

                for (; i < n; i++) {
                   SimpleNode paramName = node.getChild(i++);
                   SimpleNode paramValue = node.getChild(i);
                   xw.putStartTag(child, "xqx:decimalFormatParam");
                   cc.transform(paramName);
                   cc.transform(paramValue);
                   xw.putEndTag(child);

               }
               xw.putEndTag(node);
                return true;
            }



            case JJTDFPROPERTYNAME: {
                xw.putSimpleElement(node, "xqx:decimalFormatParamName", node.m_value);
                return true;
            }


            case JJTSLIDINGWINDOWCLAUSE:
            case JJTTUMBLINGWINDOWCLAUSE: {
                xw.putStartTag(node, xqx_element_name_g);

                int i = 0;
                SimpleNode child = null;
                int n = node.jjtGetNumChildren();

                // first child is VarName
                // second child may be TypeDeclaration

                child = node.getChild(0);
                xw.putStartTag(node, "xqx:typedVariableBinding");
                transform_name(child.getChild(0), child.id);
                i++;

                child = node.getChild(1);

                if (child.id == JJTTYPEDECLARATION) {
                   cc.transform(child);
                   i++;
                }
                xw.putEndTag(node);

                for (; i < n; i++) {
                    child = node.getChild(i);
                    if (child.id == JJTWINDOWSTARTCONDITION || child.id == JJTWINDOWENDCONDITION) {
                       cc.transform(child);
                    }
                    else {
                       xw.putStartTag(child, "xqx:bindingSequence");
                       cc.transform(child);
                       xw.putEndTag(child);
                    }
                }

                xw.putEndTag(node);

                return true;
            }


            case JJTWINDOWSTARTCONDITION: {
                xw.putStartTag(node, xqx_element_name_g);
                cc.transform(node.getChild(0));
                xw.putStartTag(node, "xqx:winStartExpr");
                cc.transform(node.getChild(1));
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }


            case JJTWINDOWENDCONDITION: {
                String[][] attributes;
                if (node.m_value != null && node.m_value.equals("only"))
                    attributes = new String[][] {{"xqx:onlyEnd", "true"}};
                else
                    attributes = new String[][] {};
                xw.putStartTag(node, xqx_element_name_g, attributes, true);
                cc.transform(node.getChild(0));
                xw.putStartTag(node, "xqx:winEndExpr");
                cc.transform(node.getChild(1));
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTANYKINDTEST:
            case JJTTEXTTEST:
            case JJTCOMMENTTEST:
            case JJTEXTERNAL:
            case JJTCONTEXTITEMEXPR:
                xw.putEmptyElement(node, xqx_element_name_g);
                return true;

            case JJTNAMESPACENODETEST:
                xw.putEmptyElement(node, "xqx:namespaceTest");
                return true;

            case JJTOPTIONDECL:
            case JJTMAINMODULE:
            case JJTLIBRARYMODULE:
            case JJTNAMESPACEDECL:
            case JJTCOPYNAMESPACESDECL:
            case JJTMODULEIMPORT:
            case JJTPARAMLIST:
            case JJTPARAM:
            case JJTQUERYBODY:
            case JJTWHERECLAUSE:
            case JJTGROUPBYCLAUSE:
            case JJTCOUNTCLAUSE:
            case JJTRETURNCLAUSE:
            case JJTTYPEDECLARATION:
            case JJTATTRIBUTEDECLARATION: // unreached
            case JJTELEMENTDECLARATION:   // unreached
            case JJTVARVALUE:
            case JJTWINDOWCLAUSE:
            case JJTTRYCATCHEXPR:
            case JJTTRYCLAUSE:
            case JJTCATCHERRORLIST:
            case JJTPARENTHESIZEDITEMTYPE:
                // node always has children
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTSCHEMAPREFIX: // unreached?
            case JJTDOCUMENTTEST:
            case JJTATTRIBUTETEST:
            case JJTELEMENTTEST:
            case JJTWINDOWVARS:
            case JJTVOID: // ??
                // node sometimes has children
                if (node.jjtGetNumChildren() == 0) {
                    xw.putEmptyElement(node, xqx_element_name_g);
                } else {
                    xw.putStartTag(node, xqx_element_name_g);
                    cc.transformChildren(node);

                    // Handle optionally nillable TypeName in ElementTest
                    if ( id == JJTELEMENTTEST
                        && node.m_value != null
                        && node.m_value.equals("?")
                    ) {
                        xw.putEmptyElement(node, "xqx:nillable");
                    }

                    xw.putEndTag(node);
                }
                return true;

            case JJTSCHEMAATTRIBUTETEST:
            {
               /* Parse tree is:
                * |                           SchemaAttributeTest
                * |                              AttributeDeclaration
                * |                                 AttributeName
                * |                                    QName foo
                */

                SimpleNode qn = node.getChild(0).getChild(0).getChild(0);
                transform_name(qn, "xqx:schemaAttributeTest");
                return true;
             }

            case JJTSCHEMAELEMENTTEST:
            {
               /* Parse tree is:
                * |                           SchemaElementTest
                * |                              ElementDeclaration
                * |                                 ElementName
                * |                                    QName notDeclared:ncname
                */

                SimpleNode qn = node.getChild(0).getChild(0).getChild(0);
                transform_name(qn, "xqx:schemaElementTest");
                return true;
             }

            case JJTFUNCTIONTEST:
            {
                int lastChildId = getChildID(node, node.jjtGetNumChildren()-1);
                String lastChild_xqx_element_name_g = mapNodeIdToXqxElementName(lastChildId);
                xw.putStartTag(node, lastChild_xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTANYFUNCTIONTEST:
            {
                return true;
            }

            case JJTTYPEDFUNCTIONTEST:
            {
                int nChildren = node.jjtGetNumChildren();

                xw.putStartTag(node, "xqx:paramTypeList");
                   cc.transformChildren(node, 0, nChildren - 2);
                xw.putEndTag(node);

                cc.transformChildren(node, nChildren - 1);

                return true;
            }

            case JJTMODULEDECL:
            {
               /* Parse tree is:
                * |            ModuleDecl
                * |               NCName prefix
                * |               URILiteral
                * |                  StringLiteral "http://example.com"
                * |               Separator
                */

                xw.putStartTag(node, xqx_element_name_g);
                SimpleNode ncname = node.getChild(0);
                xw.putSimpleElement(ncname, "xqx:prefix", ncname.m_value);
                cc.transformChildren(node, 1, 1);
                xw.putEndTag(node);
                return true;
            }

            case JJTPRAGMA:
            {
                xw.putStartTag(node, xqx_element_name_g);
                int n = node.jjtGetNumChildren();
                boolean foundPragmaContents = false;
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    cc.transform(child);
                    if (child.id == JJTPRAGMACONTENTS)
                       foundPragmaContents = true;
                }
                if (!foundPragmaContents) {
                   xw.putEmptyElement(node, "xqx:pragmaContents");
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTPRAGMACONTENTS:
                xw.putStartTag(node, "xqx:pragmaContents", false);
                cc.transformChildren(node);
                xw.putEndTag(node, false);
                return true;

            case JJTEXTENSIONEXPR:
            {
                xw.putStartTag(node, xqx_element_name_g);
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    switch (child.id) {
                        case JJTPRAGMA:
                            cc.transform(child);
                            break;

                        case JJTENCLOSEDEXPR: // <-- kludge for xquery31
                        case JJTEXPR:
                            xw.putStartTag(child, "xqx:argExpr");
                            cc.transform(child);
                            xw.putEndTag(child);
                            break;
                    }
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTVALIDATEEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);

                    switch (child.id) {
                       case JJTTYPENAME: {
                          cc.transform(child);
                          break;
                       }

                       case JJTVALIDATIONMODE: {
                          cc.transform(child);
                          break;
                       }

                       case JJTEXPR: {
                          xw.putStartTag(child, "xqx:argExpr");
                          cc.transform(child);
                          xw.putEndTag(child);
                       }

                    }
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTVALIDATIONMODE:
                xw.putSimpleElement(node, xqx_element_name_g, node.m_value);
                return true;

            case JJTFUNCTIONBODY:
            case JJTDEFAULTCOLLATIONDECL:
            case JJTEMPTYORDERDECL:
            case JJTSIMPLETYPENAME:
            case JJTTYPENAME:
            case JJTIMPORT:
            case JJTPREDICATE:
            case JJTQUOTATTRVALUECONTENT:
            case JJTAPOSATTRVALUECONTENT:
            case JJTNODETEST:
            case JJTCOMMONCONTENT:
            case JJTENCLOSEDEXPR:
            case JJTDIRECTCONSTRUCTOR:
            case JJTCURRENTITEM:
            case JJTPREVIOUSITEM:
            case JJTNEXTITEM:
            case JJTFUNCTIONITEMEXPR:
            case JJTSWITCHCASEOPERAND:
                cc.transformChildren(node);
                return true;

            case JJTMINUS:
            case JJTPLUS:
            case JJTOPENQUOT:
            case JJTCLOSEQUOT:
            case JJTOPENAPOS:
            case JJTCLOSEAPOS:
            case JJTVALUEINDICATOR:
            case JJTLBRACE:
            case JJTRBRACE:
            case JJTEMPTYTAGCLOSE:
            case JJTSTARTTAGCLOSE:
            case JJTSEPARATOR:
            case JJTLEFTANGLEBRACKET:
            case JJTS:
                return true;

            case JJTSETTER:
                checkDuplicateSetters(node);
                cc.transformChildren(node);
                return true;

            case JJTPREDEFINEDENTITYREF:
                xw.putText(node.m_value);
                return true;

            case JJTCHARREF: {
                String ref = node.m_value;
                // What to do if this is invalid?
                xw.putText(ref);
                return true;
            }

            case JJTLCURLYBRACEESCAPE:
                // Bug fix for problem reported in Andrew Eisenberg mail to Scott
                // Boag 03/28/2006 02:36 PM
                // xw.putText("{{");
                xw.putText("{");
                return true;

            case JJTRCURLYBRACEESCAPE:
                // Bug fix for problem reported in Andrew Eisenberg mail to Scott
                // Boag 03/28/2006 02:36 PM
                // xw.putText("}}");
                xw.putText("}");
                return true;

            case JJTDIRCOMMENTCONSTRUCTOR:
                xw.putStartTag(node, "xqx:computedCommentConstructor");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTDIRCOMMENTCONTENTS: {
                xw.putStartTag(node, "xqx:argExpr");
                xw.putStartTag(node, "xqx:stringConstantExpr");
                xw.putStartTag(node, "xqx:value", false);
                cc.transformChildren(node);
                xw.putEndTag(node, false);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTDIRCOMMENTCONTENTDASHCHAR:
                xw.putTextEscaped(node.m_value, true);
                return true;

            case JJTCHAR:
            case JJTDIRCOMMENTCONTENTCHAR:
                {
                String charStr = node.m_value;
                if (!charStr.equals("\r")) {
                    if (node.getParent().id == JJTCDATASECTIONCONTENTS)
                       xw.putText(charStr);
                    else
                       xw.putTextEscaped(charStr, true);
                }
                else {
                    SimpleNode sib = getNextSibling(node);
                    if (sib == null
                        || sib.id != node.id
                        || !sib.m_value.equals("\n"))
                       xw.putText("\n");
                }
                return true;
            }

            case JJTCDATASECTIONCONTENTS:
                cc.transformChildren(node);
                return true;

            case JJTPROCESSINGINSTRUCTIONEND:
            case JJTPROCESSINGINSTRUCTIONSTART:
            case JJTCDATASECTIONSTART:
            case JJTCDATASECTIONEND:
            case JJTDIRCOMMENTSTART:
            case JJTDIRCOMMENTEND:
                return true;

            case JJTCDATASECTION: {
                xw.putStartTag(node, "xqx:computedTextConstructor");
                xw.putStartTag(node, "xqx:argExpr");
                xw.putStartTag(node, "xqx:stringConstantExpr");
                xw.putStartTag(node, "xqx:value", false);
                xw.putText("<![CDATA[");
                cc.transformChildren(node);
                xw.putText("]]>");
                xw.putEndTag(node, false);
                xw.putEndTag(node);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTDIRPICONSTRUCTOR: {
                xw.putStartTag(node, "xqx:computedPIConstructor");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTPITARGET:
                xw.putSimpleElement(node, "xqx:piTarget", node.m_value);
                return true;

            case JJTDIRPICONTENTS:
                xw.putStartTag(node, "xqx:piValueExpr");
                xw.putStartTag(node, "xqx:stringConstantExpr");
                xw.putStartTag(node, "xqx:value", false);
                cc.transformChildren(node);
                xw.putEndTag(node, false);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;

            case JJTCOMPCOMMENTCONSTRUCTOR:
            case JJTCOMPDOCCONSTRUCTOR:
            case JJTCOMPTEXTCONSTRUCTOR:
                String elemName;
                switch (id) {
                    case JJTCOMPDOCCONSTRUCTOR:
                        elemName = "xqx:computedDocumentConstructor";
                        break;
                    case JJTCOMPTEXTCONSTRUCTOR:
                        elemName = "xqx:computedTextConstructor";
                        break;
                    case JJTCOMPCOMMENTCONSTRUCTOR:
                        elemName = "xqx:computedCommentConstructor";
                        break;
                    default:
                        elemName = "UNKNOWN-" + jjtNodeName[id];
                        break;
                }
                xw.putStartTag(node, elemName);
                xw.putStartTag(node, "xqx:argExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;

            case JJTCOMPUTEDCONSTRUCTOR:
                cc.transformChildren(node);
                return true;

            case JJTCOMPPICONSTRUCTOR:
            case JJTCOMPATTRCONSTRUCTOR:
            case JJTCOMPELEMCONSTRUCTOR: {
                String xqx_element_name =
                        id == JJTCOMPATTRCONSTRUCTOR ? "xqx:computedAttributeConstructor"
                                : id == JJTCOMPPICONSTRUCTOR ? "xqx:computedPIConstructor"
                                        : "xqx:computedElementConstructor";
                xw.putStartTag(node, xqx_element_name);
                int start = 0;
                if (getChildID(node, 0) == JJTLBRACE) {
                    String xqx_element_name2 =
                        (id == JJTCOMPPICONSTRUCTOR)
                        ? "xqx:piTargetExpr"
                        : "xqx:tagNameExpr";
                    xw.putStartTag(node, xqx_element_name2);
                    cc.transformChildren(node, 1, 1);
                    xw.putEndTag(node);
                    start += 3;
                } else {
                    cc.transformChildren(node, 0, 0);
                    start++;
                }
                if (id == JJTCOMPATTRCONSTRUCTOR || id == JJTCOMPPICONSTRUCTOR) {
                    xw.putStartTag(node, id == JJTCOMPATTRCONSTRUCTOR ? "xqx:valueExpr" : "xqx:piValueExpr");
                    if (getNumExprChildren(node, start) == 0) {
                        xw.putEmptyElement(node, "xqx:sequenceExpr");
                    } else
                        cc.transformChildren(node, start);
                    xw.putEndTag(node);

                } else
                    cc.transformChildren(node, start);

                xw.putEndTag(node);
                return true;
            }

            case JJTCOMPNAMESPACECONSTRUCTOR: {
                xw.putStartTag(node, "xqx:computedNamespaceConstructor");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTPREFIX: {
                SimpleNode child = node.getChild(0);
                xw.putSimpleElement(node, xqx_element_name_g, child.m_value);
                return true;
            }

            case JJTDIRATTRIBUTELIST:
                if (getNumRealChildren(node) > 0) {
                    xw.putStartTag(node, "xqx:attributeList");

                    int n = node.jjtGetNumChildren();
                    for (int i = 0; i < n; i++) {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTTAGQNAME) {
                            String xqx_element_name =
                                isNamespaceDecl(child)
                                ? "xqx:namespaceDeclaration"
                                : "xqx:attributeConstructor";
                            xw.putStartTag(node, xqx_element_name);
                        }
                        cc.transform(child);
                        if (child.id == JJTDIRATTRIBUTEVALUE) {
                            xw.putEndTag(node);
                        }
                    }
                    xw.putEndTag(node);
                }
                return true;

            case JJTDIRELEMCONTENT:
                // pushElem("xqx:elementContent", node);
                if (getChildID(node, 0) == JJTELEMENTCONTENTCHAR) {
                    String charStr = node.getChild(0).m_value;
                    if (!charStr.equals("\r")) {
                       xw.putTextEscaped(charStr);
                    }
                    else {
                       SimpleNode sib = getNextSibling(node);
                       if (sib == null
                           || sib.id != JJTDIRELEMCONTENT)
                          xw.putText("\n");
                       else {
                          SimpleNode sibChild = sib.getChild(0);
                          if (sibChild.id != JJTELEMENTCONTENTCHAR
                              || !sibChild.m_value.equals("\n"))
                             xw.putText("\n");
                       }

                    }
                    return true;
                } else {
                    cc.transformChildren(node);
                    return true;
                }

            case JJTDIRELEMCONSTRUCTOR: {
                xw.putStartTag(node, "xqx:elementConstructor");
                int n = node.jjtGetNumChildren();
                boolean didFindDirElemContent = false;
                SimpleNode openChild = null;
                int nPush = 0;
                boolean didPushOpenXMLElem = false;
                try {
                    for (int i = 0; i < n; i++) {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTTAGQNAME){
                            _openXMLElemStack.push(child);
                            didPushOpenXMLElem = true;
                            cc.transform(child);
                        }
                        else if (child.id == JJTDIRELEMCONTENT) {
                            if (didFindDirElemContent == false) {
                                xw.putStartTag(node, "xqx:elementContent");
                                didFindDirElemContent = true;
                            }
                            SimpleNode enc_expr = getEnclosedExpr(child);
                            if (enc_expr != null) {
                                if (nPush == 2) {
                                    xw.putEndTag(node, !isElemContentChar(openChild));
                                    xw.putEndTag(node);
                                }
                                openChild = enc_expr;
                                nPush = 0;

                                // add xqx:sequenceExpr if content is a direct element constructor
                                // or a direct element constructor surrounded by parenthesis
                                if ( getUnitDescendantOrSelf(enc_expr.getChild(1), JJTDIRELEMCONSTRUCTOR) != null )
                                {
                                    xw.putStartTag(node, "xqx:sequenceExpr");
                                    cc.transform(enc_expr);
                                    xw.putEndTag(node);
                                }
                                else
                                    cc.transform(enc_expr);

                            } else if (isElemContentChar(child)) {
                                if (child.id == JJTDIRELEMCONTENT
                                        && shouldStripChar(child.getChild(0)))
                                    continue;
                                if (!isElemContentChar(openChild)) {
                                    xw.putStartTag(node, "xqx:stringConstantExpr");
                                    xw.putStartTag(node, "xqx:value", false);
                                    nPush = 2;
                                }
                                openChild = child;
                                cc.transform(child);
                            } else {
                                if (nPush == 2) {
                                    xw.putEndTag(node, !isElemContentChar(openChild));
                                    xw.putEndTag(node);
                                }
                                openChild = child;
                                nPush = 0;
                                cc.transform(child);
                            }

                        }
                        else {
                            cc.transform(child);
                        }
                    }
                }
                finally {
                    if(didPushOpenXMLElem)
                        _openXMLElemStack.pop();
                }

                if (nPush == 2) {
                    xw.putEndTag(node, false);
                    xw.putEndTag(node);
                }

                if (didFindDirElemContent){
                    xw.putEndTag(node); // xqx:elementContent
                }

                xw.putEndTag(node); // xqx:elementConstructor
                return true;
            }

            case JJTDIRATTRIBUTEVALUE: {
                int n = node.jjtGetNumChildren();
                int isOpenMode = -1;
                boolean isAttributeValueExpr = false;
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    if (getEnclosedExpr(child) != null) {
                        isAttributeValueExpr = true;
                        break;
                    }
                }
                if (isAttributeValueExpr) {
                    String val = getTagnameNodeFromAttributeValueNode(node).m_value;
                    if (isNamespaceDecl(val)) {
                        // Not sure of a better way to handle this at the moment.
                        String errMsg = "<err id='XQST0022'>" +
                        "It is a static error if the value of a namespace declaration attribute is not a URILiteral."+
                        "</err>";
                        throw new PostParseException(errMsg);
                    }
                    xw.putStartTag(node, "xqx:attributeValueExpr");
                    int nPush = 0;
                    for (int i = 0; i < n; i++) {
                        SimpleNode child = node.getChild(i);
                        SimpleNode enc_expr = getEnclosedExpr(child);
                        if (enc_expr != null) {
                            if (nPush == 2) {
                                xw.putEndTag(node, !isAttrContentChar(isOpenMode));
                                xw.putEndTag(node);
                            }
                            isOpenMode = enc_expr.id;
                            nPush = 0;
                            cc.transform(enc_expr);

                        } else if (isAttrContentChar(child.id)) {
                            if (!isAttrContentChar(isOpenMode)) {
                                xw.putStartTag(node, "xqx:stringConstantExpr");
                                xw.putStartTag(node, "xqx:value", false);
                                nPush = 2;
                            }
                            isOpenMode = child.id;
                            cc.transform(child);
                        } else if (child.id == JJTOPENQUOT
                                || child.id == JJTCLOSEQUOT
                                || child.id == JJTOPENAPOS
                                || child.id == JJTCLOSEAPOS) {
                            continue;
                        } else {
                            if (nPush == 2) {
                                xw.putEndTag(node, !isAttrContentChar(isOpenMode));
                                xw.putEndTag(node);
                            }
                            isOpenMode = child.id;
                            nPush = 0;
                            cc.transform(child);
                        }
                    }
                    if (nPush == 2) {
                        xw.putEndTag(node, false);
                        xw.putEndTag(node);
                    }
                    xw.putEndTag(node);
                } else {
                    String val = getTagnameNodeFromAttributeValueNode(node).m_value;
                    String xqx_element_name =
                        (isNamespaceDecl(val))
                        ? "xqx:uri"
                        : "xqx:attributeValue";
                    xw.putStartTag(node, xqx_element_name, false);
                    for (int i = 0; i < n; i++) {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTOPENQUOT || child.id == JJTCLOSEQUOT
                                || child.id == JJTOPENAPOS
                                || child.id == JJTCLOSEAPOS) {
                            continue;
                        }

                        cc.transform(child);
                    }
                    xw.putEndTag(node, false);
                }
                return true;
            }

            case JJTESCAPEQUOT:
                xw.putText("\"");
                return true;

            case JJTESCAPEAPOS:
                xw.putText("\'");
                return true;

            case JJTQUOTATTRCONTENTCHAR:
            case JJTAPOSATTRCONTENTCHAR:
                if (node.m_value.equals("\r")) {
                    // A.2.3 "End-of-Line Handling" says the XQuery processor "must behave
                    // as if it normalized all line breaks on input, before parsing."
                    // The parser in this package doesn't, so we have to make up for that.
                    SimpleNode charParent = node.getParent();
                    SimpleNode nextSibling = getNextSibling(charParent);
                    if(null != nextSibling && nextSibling.jjtGetNumChildren() == 1){
                        SimpleNode nextCharNode = nextSibling.getChild(0);
                        if(null != nextCharNode){
                            if(nextCharNode.m_value.equals("\n"))
                                // This character is #xD and the next is #xA, so this
                                // two-character sequence must be translated to a single #xA.
                                // The easiest way to do that is to just skip over the #xD.
                                return true;
                        }
                    }
                    // This character is #xD and it is not immediately followed by #xA,
                    // so this must be translated to a single #xA.
                    node.m_value = "\n";
                }

                // 3.7.1.1 "Attributes" says that in a consecutive sequence of
                // literal characters in attribute content, whitespace must be
                // normalized according to the rules in section 3.3.3 of the XML
                // spec (1.0 or 1.1). This in turn says that #xD, #xA, and #x9 are
                // each normalized to a space character (#x20).
                //
                // Of course, #xD has already been eliminated by the A.2.3
                // normalization, so we only have to deal with #xA and #x9
                // (i.e., \n and \t respectively).
                //
                if (node.m_value.equals("\n") || node.m_value.equals("\t")) {
                    node.m_value = " ";
                }

                xw.putTextEscaped(node.m_value);
                return true;

            case JJTELEMENTCONTENTCHAR:
                if (node.m_value != null) {
                    xw.putTextEscaped(node.m_value);
                }
                return true;

            default: {
                String context = "";
                SimpleNode parent = node;
                System.err.println("Unknown ID: "
                        + XParserTreeConstants.jjtNodeName[id]);
                while ((parent = parent.getParent()) != null) {
                   context = parent.toString()
                             + ((context.length() == 0) ? "" : (", " + context));
                }
                System.err.println("Context is " + context);
                cc.transformChildren(node);
                return true;
            }
        }
        // unreachable
    }

    // =========================================================================

    protected void transform_SimpleMapExpr(SimpleNode sme_node, int hi)
    // Make an <xqx:simpleMapExpr> that covers some of the children of sme_node,
    // namely the ones at positions 0 thru hi inclusive.
    {
        // The grammar allows a SimpleMapExpr to have 2 or more PathExpr children,
        // but in the XQueryX schema, an xqx:simpleMapExpr has exactly 2 xqx:pathExpr children.
        // So we must "binarize" (unflatten) the children.
        //
        // (Note that an analogous situation exists for OrExpr, AndExpr, etc.
        // But the difference is that those are defined as g:binary in a g:exprProduction,
        // which means that the parser takes care of binarizing the parse tree.)

        int n_children = getNumExprChildren(sme_node);
        assert n_children >= 2; // because of condition="&gt; 1" in the grammar
        assert hi >= 1;
        assert hi < n_children;

        xw.putStartTag(sme_node, "xqx:simpleMapExpr");

        // SimpleMapExpr's associativity is left-to-right,
        // meaning that a!b!c == (a!b)!c.
        // So to cover positions 0 through hi,
        // the left operand covers positions 0 through hi-1,
        // and the right operand covers just hi.

        // Left operand:
        if (hi == 1) {
            // Just cover position 0, i.e. this is the innermost call.
            cc.transformChildren(sme_node, 0, 0);
        } else {
            // This operand needs to cover more than one position,
            // so make a recursive call.
            // However, that call always results in an <xqx:simpleMapExpr>,
            // which is not allowed as an operand of <xqx:simpleMapExpr>.
            // So we have to bury it.
            xw.putStartTag(sme_node, "xqx:pathExpr");
                xw.putStartTag(sme_node, "xqx:stepExpr");
                    xw.putStartTag(sme_node, "xqx:filterExpr");
                        xw.putStartTag(sme_node, "xqx:sequenceExpr");
                            transform_SimpleMapExpr(sme_node, hi-1);
                        xw.putEndTag(sme_node);
                    xw.putEndTag(sme_node);
                xw.putEndTag(sme_node);
            xw.putEndTag(sme_node);
        }

        // Right operand:
        cc.transformChildren(sme_node, hi, hi);

        xw.putEndTag(sme_node);
    }

    protected int transform_ClauseItem(SimpleNode parent, boolean is_for, int i)
    {
        xw.putStartTag(parent, is_for ? "xqx:forClauseItem" : "xqx:letClauseItem");

            SimpleNode nextChild = parent.getChild(i);
            assert nextChild.id == JJTVARNAME;

            xw.putStartTag(parent, "xqx:typedVariableBinding");

            {
                transform_name(nextChild.getChild(0), nextChild.id);

                i++;
                nextChild = parent.getChild(i);
            }

            if (nextChild.id == JJTTYPEDECLARATION)
            {
                cc.transform(nextChild);
                i++;
                nextChild = parent.getChild(i);
            }

            xw.putEndTag(parent); // xqx:typedVariableBinding

            if (nextChild.id == JJTALLOWINGEMPTY)
            {
                assert is_for;
                cc.transformChildren(parent, i, i);
                i++;
                nextChild = parent.getChild(i);
            }

            if (nextChild.id == JJTPOSITIONALVAR)
            {
                assert is_for;
                cc.transformChildren(parent, i, i);
                i++;
                nextChild = parent.getChild(i);
            }

            {
                xw.putStartTag(parent, is_for ? "xqx:forExpr" : "xqx:letExpr");
                cc.transform(nextChild);
                xw.putEndTag(parent); // xqx:forExpr/xqx:letExpr
                i++;
            }

        xw.putEndTag(parent); // xqx:forClauseItem/xqx:letClauseItem

        return i;
    }

    void checkDuplicateSetters(SimpleNode setter){
        SimpleNode setterChild = setter.getChild(0);
        int childID = setterChild.id;

        // Only check for duplicate boundary-space declarations

        if (childID != XParserTreeConstants.JJTBOUNDARYSPACEDECL)
           return;
        SimpleNode parent = setter.getParent();
        int numParentChildren = parent.jjtGetNumChildren();
        for (int j = 0; j < numParentChildren; j++) {
            SimpleNode setterCandidate = parent.getChild(j);
            if(setterCandidate != setter &&
                    setterCandidate.id == XParserTreeConstants.JJTSETTER &&
                    setterCandidate.getChild(0).id == childID){
                String errorCode;
                String errorMsg;
                if(childID == XParserTreeConstants.JJTBOUNDARYSPACEDECL) {
                    errorCode = "err:XQST0068";
                    errorMsg = "Prolog contains more than one boundary-space declaration.";
                }
                else {
                    errorCode = "err:???";
                    errorMsg = "Unknown setter found!";
                }
                throw new PostParseException(
                        errorCode+" Static Error: "+errorMsg);
            }
        }
    }

    /**
     * @param node
     * @return
     */
    protected SimpleNode getTagnameNodeFromAttributeValueNode(SimpleNode node) {
        SimpleNode prev = node;
        while ((prev = getPreviousSibling(prev)) != null) {
            if(prev.id != JJTVALUEINDICATOR && prev.id != JJTS)
                return prev;
        }
        return null;
    }

    /**
     * @param child
     * @return
     */
    protected boolean isNamespaceDecl(SimpleNode child) {
        return child.m_value.startsWith("xmlns:")
                || child.m_value.equals("xmlns");
    }

    /**
     * @param child
     * @return
     */
    protected boolean isNamespaceDecl(String val) {
        return val.startsWith("xmlns:")
                || val.equals("xmlns");
    }


    /**
     * @param node
     */
    protected SimpleNode getNextSibling(SimpleNode node) {
        int nSiblingsOrSelf = node.getParent().jjtGetNumChildren();
        for (int i = 0; i < nSiblingsOrSelf; i++) {
            SimpleNode siblingOrSelf = node.getParent().getChild(i);
            if (siblingOrSelf == node) {
                if ((i + 1) < nSiblingsOrSelf) {
                    return node.getParent().getChild(i + 1);
                }
                break;
            }
        }
        return null;
    }

    /**
     * @param node
     */
    protected SimpleNode getPreviousSibling(SimpleNode node) {
        int nSiblingsOrSelf = node.getParent().jjtGetNumChildren();
        for (int i = 0; i < nSiblingsOrSelf; i++) {
            SimpleNode siblingOrSelf = node.getParent().getChild(i);
            if (siblingOrSelf == node) {
                if (i > 0)
                    return node.getParent().getChild(i - 1);
                else
                    break;
            }
        }
        return null;
    }

    protected boolean hasChildID(SimpleNode node, int id) {

        int n = node.jjtGetNumChildren();
        for (int i = 0; i < n; i++) {
            SimpleNode child = node.getChild(i);
            if (child.id == id)
                return true;
        }
        return false;
    }

    protected int getNumExprChildren(SimpleNode node) {
        return getNumExprChildren(node, 0);
    }

    protected int getNumExprChildren(SimpleNode node, int start) {
        int count = 0;
        int n = node.jjtGetNumChildren();
        for (int i = start; i < n; i++) {
            SimpleNode child = node.getChild(i);
            if (child.id != JJTS && child.id != JJTLBRACE
                    && child.id != JJTRBRACE)
                count++;
        }
        return count;
    }

    protected int getNumRealChildren(SimpleNode node) {
        int count = 0;
        int n = node.jjtGetNumChildren();
        for (int i = 0; i < n; i++) {
            SimpleNode child = node.getChild(i);
            if (child.id != JJTS)
                count++;
        }
        return count;
    }

    /**
     * @param child
     * @return
     */
    protected SimpleNode getEnclosedExpr(SimpleNode child) {
        return getUnitDescendantOrSelf(child, JJTENCLOSEDEXPR);
    }

    protected SimpleNode getUnitDescendantOrSelf(SimpleNode base, int desired_id)
    // If there exists a node that:
    // -- has id = 'desired_id', and
    // -- is, at its level, the sole descendant-or-self of 'base',
    // then return that node.
    // Otherwise return null.
    {
        SimpleNode node = base;
        while (true) {
            if (node.id == desired_id) return node;
            if (node.jjtGetNumChildren() != 1) return null;
            node = node.getChild(0);
        }
    }

    /**
     * @param child
     * @return
     */
    protected boolean isAttrContentChar(int id) {
        switch (id) {
            case JJTQUOTATTRVALUECONTENT:
            case JJTAPOSATTRVALUECONTENT:
            case JJTESCAPEAPOS:
            case JJTESCAPEQUOT:
                return true;

            case JJTCOMMONCONTENT:
                return true;

            default:
                return false;
        }
    }

    protected boolean isElemContentChar(SimpleNode node) {
        if (node == null)
            return false;
        if (node.id == JJTDIRELEMCONTENT) {
            switch (getChildID(node, 0)) {
                case JJTELEMENTCONTENTCHAR:
                    return true;

                case JJTCOMMONCONTENT:
                    return true;

                default:
                    return false;
            }
        } else
            return false;

    }

    // -------------------------------------------------------------------------

    // Recall that a PostfixExpr is a PrimaryExpr followed by 0 to N postfixes.
    // A *partial PostfixExpr* is a quasi-subexpression of a PostfixExpr,
    // consisting of the PrimaryExpr plus some prefix of the postfixes (0 <= n <= N).
    // (i.e. the PrimaryExpr plus 0 to N of the postfixes, counting from the left)
    // (We have to invent this because PostfixExpr is defined via '*' rather than recursively.)
    // In method names, we abbreviate "partial PostfixExpr" as "pPostfixExpr".
    //
    // *Ending predicates* are predicates that occur as the last postfixes of a
    // partial PostfixExpr.
    //
    // A *filter* is an xqx element in the xsd:group "filterExpr".
    // (Note that this does *not* mean "an <xqx:filterExpr> element",
    // as the latter is not actually in the xsd:group "filterExpr".)

    protected void convert_pPostfixExpr_to_content_for_stepExpr(SimpleNode node, int end) {

        assert node.id == JJTPOSTFIXEXPR;

        int n_ending_predicates = get_n_ending_predicates_of_pPostfixExpr(node, end);

        xw.putStartTag(node, "xqx:filterExpr");
        convert_pPostfixExpr_to_a_filter(node, end - n_ending_predicates);
        xw.putEndTag(node);

        convert_ending_predicates_of_pPostfixExpr(node, end, n_ending_predicates);
    }

    protected void convert_pPostfixExpr_to_a_filter(SimpleNode node, int end) {

        if (end == 0) {
            // The partial PostfixExpr is simply a PrimaryExpr.
            convert_PrimaryExpr_to_a_filter(node);
        }
        else {
            // The partial PostfixExpr has at least one postfix.
            // Consider its last postfix...
            if ( getChildID(node, end) == JJTARGUMENTLIST) {
                convert_pPostfixExpr_ending_in_ArgumentList_to_dFIE(node, end);
            }
            else {
                // Logically, the only other alternative is that `node` is
                // a partial PostfixExpr that ends in a Predicate.
                // However, the methods that call convert_pPostfixExpr_to_a_filter()
                // always do something else with ending Predicates,
                // and so `node` never ends in a predicate.
                //
                assert false;
            }
        }
    }

    protected void convert_PrimaryExpr_to_a_filter(SimpleNode node) {
        //
        // `node` isn't a Node whose NodeName is "PrimaryExpr", because
        // the parser doesn't generate those. Rather, it's a node for
        // one of the many alternatives that PrimaryExpr derives.
        //
        // For all of these alternatives, the 'transform' is an element in
        // the xqx:filterExpr group (which is what this function wants),
        // except for ParenthesizedExpr, whose transform is either
        // an xqx:sequenceExpr, or the transform of its children.
        // The former is in xqx:filterExpr, the latter isn't, in general.
        //
        // So here, we single out the case of a ParenthesizedExpr,
        // and force it to always convert to an xqx:sequenceExpr.

        SimpleNode primaryExpr = node.getChild(0);
        if (primaryExpr.id == JJTPARENTHESIZEDEXPR) {
            xw.putStartTag(node, "xqx:sequenceExpr");
            cc.transformChildren(primaryExpr);
            xw.putEndTag(node);
        }
        else
            cc.transform(primaryExpr);
    }

    protected void convert_pPostfixExpr_ending_in_ArgumentList_to_dFIE(SimpleNode node, int end) {
        // "dFIE" = dynamicFunctionInvocationExpr

        SimpleNode argumentList = node.getChild(end);
        assert argumentList.id == JJTARGUMENTLIST;

        xw.putStartTag(node, "xqx:dynamicFunctionInvocationExpr");

        // Do we make use of the fact that a dFIE can contain predicates?
        int n_predicates_for_the_dFIE_to_capture;
        if (true) {
            // Yes, use that fact.
            n_predicates_for_the_dFIE_to_capture =
                get_n_ending_predicates_of_pPostfixExpr(node, end-1);
        }
        else {
            // No, ignore that fact.
            n_predicates_for_the_dFIE_to_capture = 0;
        }

        xw.putStartTag(node, "xqx:functionItem");
        convert_pPostfixExpr_to_a_filter(node, end - 1 - n_predicates_for_the_dFIE_to_capture);
        xw.putEndTag(node);

        convert_ending_predicates_of_pPostfixExpr(
            node, end-1, n_predicates_for_the_dFIE_to_capture);

        if (argumentList.jjtGetNumChildren() != 0) {
            xw.putStartTag(node, "xqx:arguments");
            cc.transformChildren(argumentList);
            xw.putEndTag(node);
        }

        xw.putEndTag(node);
    }

    protected int get_n_ending_predicates_of_pPostfixExpr(SimpleNode node, int end) {
        assert node.id == JJTPOSTFIXEXPR;

        int n_ending_predicates = 0;
        for (int j = end; getChildID(node, j) == JJTPREDICATE; j--)
            n_ending_predicates++;

        return n_ending_predicates;
    }

    protected void convert_ending_predicates_of_pPostfixExpr(SimpleNode node, int end, int n_ending_predicates) {
        assert node.id == JJTPOSTFIXEXPR;

        if (n_ending_predicates != 0) {
            xw.putStartTag(node, "xqx:predicates");
            cc.transformChildren(node, end - n_ending_predicates + 1, end);
            xw.putEndTag(node);
        }
    }

    // -------------------------------------------------------------------------

    /**
     * @param node
     * @return
     */
    protected SimpleNode getFirstChildOfFirstChild(SimpleNode node) {
        if(node.jjtGetNumChildren() <= 0)
            return null;
        SimpleNode firstChild = node.getChild(0);
        if(firstChild.jjtGetNumChildren() <= 0)
            return null;
        return firstChild.getChild(0);
    }


    /**
     * @param node
     * @return
     */
    protected int getFirstChildOfFirstChildID(SimpleNode node) {
        if(node.jjtGetNumChildren() <= 0)
            return -1;
        SimpleNode firstChild = node.getChild(0);
        if(firstChild.jjtGetNumChildren() <= 0)
            return -1;
        return firstChild.getChild(0).id;
    }

    // override XQueryXConverter.transform_name
    protected void transform_name(SimpleNode name_node, String xqx_element_name)
    {
        if (name_node.id == JJTURIQUALIFIEDNAME)
        {
            String uqn_string = name_node.m_value;
            int rbrace_index = uqn_string.lastIndexOf('}');
            String uri = uqn_string.substring(2, rbrace_index);
            String local_name = uqn_string.substring(rbrace_index+1);
            String[][] attributes = new String[][] {{"xqx:URI", uri}};
            xw.putStartTag(name_node, xqx_element_name, attributes, false);
            xw.putTextEscaped(local_name);
            xw.putEndTag(name_node, false);
        }
        else
        {
            super.transform_name(name_node, xqx_element_name);
        }
    }

}
// vim: sw=4 ts=4 expandtab
