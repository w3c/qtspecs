/*
 Copyright (c) 2014 W3C(r) (http://www.w3.org/) (MIT (http://www.lcs.mit.edu/),
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

public class XQueryXConverter_xquery31 extends XQueryXConverter {

    protected XQueryXConverter_xquery30 xquery30_converter;

    public XQueryXConverter_xquery31(ConversionController cc, XMLWriter xw) {
        super(cc, xw);
        xquery30_converter = new XQueryXConverter_xquery30(cc, xw);
    }

    /**
     * Process a node in the AST and its descendants.
     * @param node  The node to be processed.
     * @return true
     */
    protected boolean transformNode(SimpleNode node) {
        int id = node.id;
        String xqx_element_name_g = mapNodeIdToXqxElementName(id);

        switch (id) {

            // ---------------------------------------------------
            // ArrowExpr has been inserted into the Expr hierarchy

            case JJTARROWEXPR:
                xw.putStartTag(node, xqx_element_name_g);

                xw.putStartTag(node, "xqx:argExpr");
                cc.transform(node.getChild(0));
                xw.putEndTag(node);

                cc.transformChildren(node, 1);

                xw.putEndTag(node);
                return true;

            // -----------------------------------------------
            // PostfixExpr has been expanded to include Lookup

            case JJTPOSTFIXEXPR: {
                int end = node.jjtGetNumChildren() - 1;
                convert_pPostfixExpr_to_content_for_stepExpr(node, end);
                return true;
            }

            case JJTUNARYLOOKUP:
            case JJTLOOKUP:
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTKEYSPECIFIER:
                if (node.m_value != null && node.m_value.equals("*"))
                    xw.putEmptyElement(node, "xqx:star");
                else
                    cc.transformChildren(node);
                return true;

            case JJTNCNAME: {
                if ( getParentID(node) == JJTKEYSPECIFIER ) {
                    transform_name(node, "xqx:NCName");
                    return true;
                }
                else
                    return xquery30_converter.transformNode(node);
            }

            case JJTARROWFUNCTIONSPECIFIER:
                cc.transformChildren(node);
                return true;

            case JJTURIQUALIFIEDNAME:
            case JJTQNAME: {
                if ( getParentID(node) == JJTARROWFUNCTIONSPECIFIER ) {
                    xquery30_converter.transform_name(node, "xqx:EQName");
                    return true;
                }
                else
                    return xquery30_converter.transformNode(node);
            }

            // -----------------------------------------------------------------
            // 'NodeConstructor' is new name for 'Constructor'

            case JJTNODECONSTRUCTOR:
                cc.transformChildren(node);
                return true;

            // -----------------------------------------------------------------
            // 'Expr' is now optional in 'EnclosedExpr'

            case JJTENCLOSEDEXPR:
                if (xquery30_converter.getNumExprChildren(node) == 0) {
                    xw.putEmptyElement(node, "xqx:sequenceExpr");
                    return true;
                }
                else {
                    return xquery30_converter.transformNode(node);
                }

            // Various 'EnclosedFooExpr' have been introduced,
            // taking the place of the corresponding 'FooExpr'

            case JJTENCLOSEDTRYTARGETEXPR:
                cc.transformChildren(node);
                return true;

            case JJTENCLOSEDCONTENTEXPR: {
                assert node.jjtGetNumChildren() == 1;
                SimpleNode ee = node.getChild(0);
                assert ee.id == JJTENCLOSEDEXPR;
                if (ee.jjtGetNumChildren() == 2)
                    // i.e., just Lbrace and Rbrace
                    // i.e., the EnclosedExpr's Expr is omitted
                    // so we can omit the computedElementConstructor's contentExpr
                    return true;

                xw.putStartTag(node, "xqx:contentExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTENCLOSEDPREFIXEXPR:
                xw.putStartTag(node, "xqx:prefixExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTENCLOSEDURIEXPR:
                // In xqx:computedNamespaceConstructor,
                // 'URIExpr' has minOccurs="0",
                // but we don't make use of that possibility here.
                xw.putStartTag(node, "xqx:URIExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            // -----------------------------------------------------------------
            // StringConstructor

            case JJTSTRINGCONSTRUCTOR:
            case JJTSTRINGCONSTRUCTORINTERPOLATION:
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTSTRINGCONSTRUCTORSTART:
            case JJTSTRINGCONSTRUCTOREND:
            case JJTSTRINGCONSTRUCTORINTERPOLATIONSTART:
            case JJTSTRINGCONSTRUCTORINTERPOLATIONEND:
                return true;

            case JJTSTRINGCONSTRUCTORCONTENT:
                cc.transformChildren(node);
                return true;

            case JJTSTRINGCONSTRUCTORCHARS:
                xw.putStartTag(node, xqx_element_name_g, false);
                cc.transformChildren(node);
                xw.putEndTag(node, false);
                return true;

            // -----------------------------------------------------------------
            // MapConstructor and ArrayConstructor

            case JJTMAPCONSTRUCTOR:
            case JJTMAPCONSTRUCTORENTRY:
            case JJTMAPKEYEXPR:
            case JJTMAPVALUEEXPR:
            case JJTARRAYCONSTRUCTOR:
                xw.putStartTag(node, xqx_element_name_g);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;

            case JJTSQUAREARRAYCONSTRUCTOR:
            case JJTCURLYARRAYCONSTRUCTOR: {
                String xqx_element_name = xqx_element_name_g.replace("Constructor", "");
                xw.putStartTag(node, xqx_element_name);

                int n_children = node.jjtGetNumChildren();

                SimpleNode member_parent = null;
                int members_start = -1;
                int members_end = -1;

                if (id == JJTSQUAREARRAYCONSTRUCTOR) {
                    member_parent = node;
                    members_start = 0;
                    members_end = n_children-1;
                }
                else if (id == JJTCURLYARRAYCONSTRUCTOR) {
                    assert n_children == 1;
                    SimpleNode encl = node.getChild(0);
                    assert encl.id == JJTENCLOSEDEXPR;

                    int encl_n_children = encl.jjtGetNumChildren();
                    assert encl_n_children == 2 || encl_n_children == 3;

                    member_parent = encl;
                    assert getChildID(encl, 0) == JJTLBRACE;
                    members_start = 1;
                    members_end = encl_n_children-2;
                    assert getChildID(encl, encl_n_children-1) == JJTRBRACE;
                }

                for (int i = members_start; i <= members_end; i++ ) {
                    SimpleNode child = member_parent.getChild(i);
                    xw.putStartTag(child, "xqx:arrayElem");
                    cc.transform(child);
                    xw.putEndTag(child);
                }

                xw.putEndTag(node);
                return true;
            }

            // -----------------------------------------------------------------
            // MapTest and ArrayTest

            case JJTMAPTEST:
                cc.transformChildren(node);
                return true;

            case JJTANYMAPTEST:
                xw.putEmptyElement(node, xqx_element_name_g);
                return true;

            case JJTTYPEDMAPTEST:
                xw.putStartTag(node, xqx_element_name_g);
                assert node.jjtGetNumChildren() == 2;

                cc.transform(node.getChild(0));

                xw.putStartTag(node, "xqx:sequenceType");
                cc.transform(node.getChild(1));
                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            // -----

            case JJTARRAYTEST:
                cc.transformChildren(node);
                return true;

            case JJTANYARRAYTEST:
                xw.putEmptyElement(node, xqx_element_name_g);
                return true;

            case JJTTYPEDARRAYTEST:
                xw.putStartTag(node, xqx_element_name_g);

                assert node.jjtGetNumChildren() == 1;
                assert getChildID(node, 0) == JJTSEQUENCETYPE;
                xw.putStartTag(node, "xqx:sequenceType");
                cc.transform(node.getChild(0));
                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;

            // ------------------------------------------

            default:
                return xquery30_converter.transformNode(node);
        }

    }

    // -------------------------------------------------------------------------

    // Recall that a PostfixExpr is a PrimaryExpr followed by 0 to N postfixes.
    // A *partial PostfixExpr* is a quasi-subexpression of a PostfixExpr,
    // consisting of the PrimaryExpr plus some prefix of the postfixes (0 <= n <= N).
    // (i.e. the PrimaryExpr plus 0 to N of the postfixes, counting from the left)
    // (We have to invent this because PostfixExpr is defined via '*' rather than recursively.)
    // In method names, we abbreviate "partial PostfixExpr" as "pPostfixExpr".
    //
    // *Ending postfixes* are postfixes that occur at the end of a partial PostfixExpr.
    //
    // *easy postfixes* are ending postfixes whose XQX counterparts are allowed
    // as "top-level content" in a xqx:stepExpr.
    //
    // A *filter* is an xqx element in the xsd:group "filterExpr".
    // (Note that this does *not* mean "an <xqx:filterExpr> element",
    // as the latter is not actually in the xsd:group "filterExpr".)

    protected void convert_pPostfixExpr_to_content_for_stepExpr(SimpleNode node, int end) {

        assert node.id == JJTPOSTFIXEXPR;

        int n_easy_postfixes = get_n_easy_postfixes_of_pPostfixExpr(node, end);

        xw.putStartTag(node, "xqx:filterExpr");
        convert_pPostfixExpr_to_a_filter(node, end - n_easy_postfixes);
        xw.putEndTag(node);

        convert_any_easy_postfixes_of_pPostfixExpr(node, end, n_easy_postfixes);
    }

    protected int get_n_easy_postfixes_of_pPostfixExpr(SimpleNode node, int end) {
        assert node.id == JJTPOSTFIXEXPR;

        int n_easy_postfixes = 0;
        for (int j = end; is_a_postfix_allowed_by_stepExpr(node.getChild(j)); j--)
            n_easy_postfixes++;

        return n_easy_postfixes;
    }

    protected boolean is_a_postfix_allowed_by_stepExpr(SimpleNode node) {
        int id = node.id;
        if (id == JJTPREDICATE || id == JJTLOOKUP)
            return true;
        else if (id == JJTARGUMENTLIST)
            return false;
        else
            return false;
    }

    protected void convert_any_easy_postfixes_of_pPostfixExpr(SimpleNode node, int end, int n_easy_postfixes) {
        assert node.id == JJTPOSTFIXEXPR;

        if (n_easy_postfixes == 0) return;

        // If, given xquery30-valid input, we wish to duplicate
        // what the xquery30 converter would generate,
        // we can detect+handle the following special case.
        if (xquery30_converter.get_n_ending_predicates_of_pPostfixExpr(node, end) == n_easy_postfixes) {
            // All the easy postfixes are predicates,
            // so we can choose to generate an <xqx:predicates>,
            // which duplicates what the xquery30 converter would generate.
            xw.putStartTag(node, "xqx:predicates");
            cc.transformChildren(node, end - n_easy_postfixes + 1, end);
            xw.putEndTag(node);
        }
        else {
            // Here, we can't just do:
            // cc.transformChildren(node, end - n_easy_predicates + 1, end);
            // because then the predicate-exprs would not be embedded in <xqx:predicate> elements
            // (because xquery31 doesn't override xquery30's transform for JJTPREDICATE).

            for (int j = end - n_easy_postfixes + 1; j <= end; j++) {
                SimpleNode child = node.getChild(j);
                if (child.id == JJTPREDICATE) {
                    xw.putStartTag(child, "xqx:predicate");
                    cc.transformChildren(child);
                    xw.putEndTag(child);
                }
                else
                    cc.transform(child);
            }

        }
    }

    protected void convert_pPostfixExpr_to_a_filter(SimpleNode node, int end) {

        if (end == 0) {
            // The partial PostfixExpr is simply a PrimaryExpr.
            xquery30_converter.convert_PrimaryExpr_to_a_filter(node);
        }
        else {
            // The partial PostfixExpr has at least one postfix.
            // Consider its last postfix...
            SimpleNode ending_postfix = node.getChild(end);
            if ( ending_postfix.id == JJTARGUMENTLIST) {
                convert_pPostfixExpr_ending_in_ArgumentList_to_dFIE(node, end);
            }
            else {
                assert is_a_postfix_allowed_by_stepExpr(ending_postfix);

                // A direct conversion of the partial PostfixExpr
                // will result in a stepExpr, which is not a filter.
                // (I.e., xqx:stepExpr is not in the group xqx:filterExpr.)
                // So we must "wrap" the stepExpr in a pathExpr
                // and then wrap that in a sequenceExpr to make a filter.
                xw.putStartTag(node, "xqx:sequenceExpr");
                    xw.putStartTag(node, "xqx:pathExpr");
                        xw.putStartTag(node, "xqx:stepExpr");
                            convert_pPostfixExpr_to_content_for_stepExpr(node, end);
                        xw.putEndTag(node);
                    xw.putEndTag(node);
                xw.putEndTag(node);
            }
        }
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
                xquery30_converter.get_n_ending_predicates_of_pPostfixExpr(node, end-1);
        }
        else {
            // No, ignore that fact.
            n_predicates_for_the_dFIE_to_capture = 0;
        }

        xw.putStartTag(node, "xqx:functionItem");
        convert_pPostfixExpr_to_a_filter(node, end - 1 - n_predicates_for_the_dFIE_to_capture);
        xw.putEndTag(node);

        xquery30_converter.convert_ending_predicates_of_pPostfixExpr(
            node, end-1, n_predicates_for_the_dFIE_to_capture);

        if (argumentList.jjtGetNumChildren() != 0) {
            xw.putStartTag(node, "xqx:arguments");
            cc.transformChildren(argumentList);
            xw.putEndTag(node);
        }

        xw.putEndTag(node);
    }

    // -------------------------------------------------------------------------

}
// vim: sw=4 ts=4 expandtab
