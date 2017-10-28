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
public class XQueryXConverter_xquery10 extends XQueryXConverter {

    Stack _openXMLElemStack = new Stack();

    static final int BSP_STRIP = 0;

    static final int BSP_PRESERVE = 1;

    int _boundarySpacePolicy = BSP_STRIP;

    public XQueryXConverter_xquery10(ConversionController cc, XMLWriter xw)
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

                for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                    SimpleNode child = node.getChild(i);
                    if (i == 0) {
                        xw.putSimpleElement(child, "xqx:version", undelimitStringLiteral(child));
                    } else if (i == 1) {
                        xw.putComment("encoding: " + child.m_value);
                    }
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

            case JJTATOMICTYPE:
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
            case JJTNCNAME:
            case JJTQNAME: {
                int pid = getParentID(node);
                String xqx_element_name;
                if (pid == JJTCOMPELEMCONSTRUCTOR || pid == JJTCOMPATTRCONSTRUCTOR)
                    xqx_element_name = "xqx:tagName";
                else if (pid == JJTTYPENAME)
                    xqx_element_name = "xqx:typeName";
                else if (pid == JJTCOMPPICONSTRUCTOR)
                    xqx_element_name = "xqx:piTarget";
                else if (pid == JJTATOMICTYPE)
                    xqx_element_name = "xqx:atomicType";
                else if (pid == JJTNAMESPACEDECL)
                    xqx_element_name = "xqx:prefix";
                else if (pid == JJTVARDECL || pid == JJTPARAM)
                    xqx_element_name = "xqx:varName";
                else if (pid == JJTFUNCTIONDECL)
                    xqx_element_name = "xqx:functionName";
                else if (pid == JJTOPTIONDECL)
                    xqx_element_name = "xqx:optionName";
                else if (pid == JJTOPTIONDECL)
                    xqx_element_name = "xqx:optionName";
                else if (pid == JJTMODULEIMPORT)
                    xqx_element_name = "xqx:namespacePrefix";
                else if (pid == JJTPRAGMA)
                    xqx_element_name = "xqx:pragmaName";
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
                boolean shouldBeSeqType = pid == JJTCASECLAUSE;
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

            case JJTPATHEXPR: {
                    // First, check whether we can translate this node
                    // without an xqx:pathExpr element.
                    if (node.jjtGetNumChildren() == 1) {
                        SimpleNode only_child = node.getChild(0);
                        if (only_child.id == JJTFILTEREXPR && only_child.jjtGetNumChildren() == 1)
                        {
                            SimpleNode only_grandchild = only_child.getChild(0);
                            // only_grandchild is some kind of PrimaryExpr node,
                            // so it doesn't need to be in a pathExpr.
                            cc.transform(only_grandchild);
                            return true;
                        }
                    }

                    xw.putStartTag(node, xqx_element_name_g);

                    for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                        SimpleNode child = node.getChild(i);
                        if(child.id == JJTSLASH){
                            if (i==0) xw.putEmptyElement(child, "xqx:rootExpr");
                        }
                        else if(child.id == JJTSLASHSLASH){
                            if (i==0) xw.putEmptyElement(child, "xqx:rootExpr");
                            xw.putStartTag(child, "xqx:stepExpr");
                            xw.putSimpleElement(child, "xqx:xpathAxis", "descendant-or-self");
                            xw.putEmptyElement(child, "xqx:anyKindTest");
                            xw.putEndTag(child);
                        }
                        else {
                            assert child.id == JJTAXISSTEP || child.id == JJTFILTEREXPR;
                            xw.putStartTag(child, "xqx:stepExpr");
                            cc.transform(child);
                            xw.putEndTag(child);
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

                SimpleNode funcNameExpr = node.getChild(0);
                cc.transform(funcNameExpr);

                xw.putStartTag(node, "xqx:arguments");

                int start = 1;
                cc.transformChildren(node, start);
                xw.putEndTag(node);
                xw.putEndTag(node);

                return true;
            }

            case JJTFILTEREXPR: {
                    SimpleNode child_0 = node.getChild(0);

                    // predicates outside
                    xw.putStartTag(node, "xqx:filterExpr");
                    if (child_0.id == JJTPARENTHESIZEDEXPR) {
                        xw.putStartTag(node, "xqx:sequenceExpr");
                        // xw.putStartTag(node, "xqx:pathExpr");
                    }

                    SimpleNode predicateList = null;
                    for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                        SimpleNode child = node.getChild(i);
                        if (child.id == JJTPREDICATELIST) {
                            predicateList = child;
                            continue;
                        }
                        cc.transform(child);
                    }

                    xw.putEndTag(node);

                    if (child_0.id == JJTPARENTHESIZEDEXPR){
                        xw.putEndTag(node);
                        // xw.putEndTag(node);
                    }
                    if (null != predicateList) {
                        cc.transform(predicateList);
                    }
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

            case JJTFLWOREXPR10: {
                xw.putStartTag(node, "xqx:flworExpr");
                int n = node.jjtGetNumChildren();
                cc.transformChildren(node, 0, n - 2);
                xw.putStartTag(node, "xqx:returnClause");
                cc.transformChildren(node, n - 1, n - 1);
                xw.putEndTag(node);
                xw.putEndTag(node);
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
            case JJTADDITIVEEXPR:
            case JJTMULTIPLICATIVEEXPR:
            case JJTUNIONEXPR:
            case JJTINTERSECTEXCEPTEXPR:
            case JJTCOMPARISONEXPR:
            case JJTANDEXPR:
            case JJTOREXPR: {
                String elemName;
                switch (id) {
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
                boolean is_for = (id == JJTFORCLAUSE);

                xw.putStartTag(node, xqx_element_name_g);

                int n = node.jjtGetNumChildren();
                int i = 0;
                while (i < n) {
                    i = transform_ClauseItem(node, is_for, i);
                }

                xw.putEndTag(node);

                return true;
            }

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

            case JJTFUNCTIONDECL: {
                xw.putStartTag(node, xqx_element_name_g);
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
                xw.putEndTag(node);
                return true;
            }

            case JJTVARDECL: {
                xw.putStartTag(node, xqx_element_name_g);
                int start = 0;
                int end = node.jjtGetNumChildren() - 1;
                cc.transformChildren(node, start, end - 1);
                start = end;
                if (getChildID(node, end) == JJTEXTERNAL) {
                    cc.transformChildren(node, start, end);
                } else {
                    xw.putStartTag(node, "xqx:varValue");
                    cc.transformChildren(node, start, end);
                    xw.putEndTag(node);
                }
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
            case JJTTYPEDECLARATION:
            case JJTATTRIBUTEDECLARATION: // unreached
            case JJTELEMENTDECLARATION:   // unreached
                // node always has children
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTSCHEMAPREFIX: // unreached?
            case JJTDOCUMENTTEST:
            case JJTATTRIBUTETEST:
            case JJTELEMENTTEST:
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
                    if(i == (n-2)) {
                        if(child.jjtGetNumChildren() == 0)
                            continue;
                        xw.putStartTag(child, "xqx:argExpr");
                        cc.transform(child);
                        xw.putEndTag(child);
                    } else {
                        cc.transform(child);
                    }
                }
                xw.putEndTag(node);
                return true;
            }

            case JJTVALIDATEEXPR: {
                xw.putStartTag(node, xqx_element_name_g);
                int n = node.jjtGetNumChildren();
                boolean foundArg = false;
                SimpleNode argNode = null;
                for (int i = 0; i < n; i++) {
                    SimpleNode child = node.getChild(i);
                    if(foundArg == false && child.id != JJTVALIDATIONMODE) {
                        foundArg = true;
                        argNode = child;
                        xw.putStartTag(argNode, "xqx:argExpr");
                    }
                    cc.transform(child);
                }
                xw.putEndTag(argNode);
                xw.putEndTag(node);
                return true;
            }

            case JJTVALIDATIONMODE:
                xw.putSimpleElement(node, xqx_element_name_g, node.m_value);
                return true;

            case JJTDEFAULTCOLLATIONDECL:
            case JJTEMPTYORDERDECL:
            case JJTTYPENAME:
            case JJTIMPORT:
            case JJTPREDICATE:
            case JJTQUOTATTRVALUECONTENT:
            case JJTAPOSATTRVALUECONTENT:
            case JJTNODETEST:
            case JJTCOMMONCONTENT:
            case JJTENCLOSEDEXPR:
            case JJTCONSTRUCTOR:
            case JJTDIRECTCONSTRUCTOR:
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

            case JJTCONTENTEXPR:
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

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


}
// vim: sw=4 ts=4 expandtab
