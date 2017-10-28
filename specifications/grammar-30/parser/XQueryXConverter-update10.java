package org.w3c.xqparser;

public class XQueryXConverter_update10 extends XQueryXConverter {

    public XQueryXConverter_update10(ConversionController cc, XMLWriter xw) {
        super(cc, xw);
    }

    /**
     * Process a node in the AST and its descendants.
     * @param node  The node to be processed.
     * @return true
     */
    protected boolean transformNode(SimpleNode node) {
        int id = node.id;

        // Consistency would prefer that this if-stmt be instead a case
        // (on JJTCOMPATIBILITYANNOTATION) in the subsequent switch-stmt.
        // However, that would only work when compiled with the xquery30
        // ConverterBase. You'd get a "cannot find symbol" error if you
        // tried to compile it with the xquery10 ConverterBase.
        // The if-stmt, on the other hand, will compile with both.
        if (jjtNodeName[id] == "CompatibilityAnnotation") {
            xw.putStartTag(node, "xqx:annotation");

                xw.putSimpleElement(node, "xqx:QName", "updating");

            xw.putEndTag(node);
            return true;
        }

        // Similarly, JJTTRANSFORMEXPR exists for update10 but not update30,
        // because Update 3.0 renamed "TransformExpr" to "CopyModifyExpr".
        // (It's somewhat kludgey to handle the CopyModifyExpr case here,
        // but it's simpler than the alternatives.)
        //
        if (jjtNodeName[id] == "TransformExpr" || jjtNodeName[id] == "CopyModifyExpr") {
            xw.putStartTag(node, "xqxuf:transformExpr");

            xw.putStartTag(node, "xqxuf:transformCopies");

            int n = node.jjtGetNumChildren();
            for (int i = 0; i < ((n - 2) / 2); i++) {
                xw.putStartTag(node, "xqxuf:transformCopy");
                cc.transform(node.getChild(2 * i));
                xw.putStartTag(node, "xqxuf:copySource");
                cc.transform(node.getChild(2 * i + 1));
                xw.putEndTag(node);
                xw.putEndTag(node);
            }
            xw.putEndTag(node);

            xw.putStartTag(node, "xqxuf:modifyExpr");
            cc.transform(node.getChild(n - 2));
            xw.putEndTag(node);

            xw.putStartTag(node, "xqxuf:returnExpr");
            cc.transform(node.getChild(n - 1));
            xw.putEndTag(node);

            xw.putEndTag(node);
            return true;
        }

        switch (id) {

            case JJTMODULE: {
                String[][] attributes = {
                    {"xmlns:xqx", "http://www.w3.org/2005/XQueryX"},
                    {"xmlns:xqxuf", "http://www.w3.org/2007/xquery-update-10"},
                    {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
                    {"xsi:schemaLocation",
                        "http://www.w3.org/2007/xquery-update-10"
                                + "\n                                http://www.w3.org/2007/xquery-update-10/xquery-update-10-xqueryx.xsd"}
                };

                xw.putStartTag(node, "xqx:module", attributes, true);
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTFUNCTIONDECL: {
                if ( cc.component_id_[0].equals("xquery30") ) {
                    // Let the base converter handle it
                    return false;
                }

                /* copied and extended the xquery10 FunctionDecl-handler to recognize "updating" */


                String[][] attributes;
                if (node.m_value != null) {
                    attributes = new String[][] {{"xqx:updatingFunction", "true"}};
                } else {
                    attributes = new String[][] {};
                }
                xw.putStartTag(node, "xqx:functionDecl", attributes, true);

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
                    cc.transformChildren(node, start, end);
                } else {
                    xw.putStartTag(node, "xqx:functionBody");
                    cc.transformChildren(node, start, end);
                    xw.putEndTag(node);
                }
                xw.putEndTag(node);

                return true;
            }

            case JJTREVALIDATIONDECL: {
                String choice = node.m_value;
                xw.putSimpleElement(node, "xqxuf:revalidationDecl", choice);
                return true;
            }

            case JJTINSERTEXPRTARGETCHOICE: {
                String choice = node.m_value;
                if (choice == null) {
                    xw.putEmptyElement(node, "xqxuf:insertInto");
                } else if (choice.equals("first")) {
                    xw.putStartTag(node, "xqxuf:insertInto");
                    xw.putEmptyElement(node, "xqxuf:insertAsFirst");
                    xw.putEndTag(node);
                } else if (choice.equals("last")) {
                    xw.putStartTag(node, "xqxuf:insertInto");
                    xw.putEmptyElement(node, "xqxuf:insertAsLast");
                    xw.putEndTag(node);
                } else if (choice.equals("before")) {
                    xw.putEmptyElement(node, "xqxuf:insertBefore");
                } else if (choice.equals("after")) {
                    xw.putEmptyElement(node, "xqxuf:insertAfter");
                }
                return true;
            }

            case JJTINSERTEXPR: {
                xw.putStartTag(node, "xqxuf:insertExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTDELETEEXPR: {
                xw.putStartTag(node, "xqxuf:deleteExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTREPLACEEXPR: {
                xw.putStartTag(node, "xqxuf:replaceExpr");

                if (node.m_value != null) {
                    xw.putEmptyElement(node, "xqxuf:replaceValue");
                }

                cc.transformChildren(node, 0, 0);
                xw.putStartTag(node, "xqxuf:replacementExpr");
                cc.transformChildren(node, 1, 1);
                xw.putEndTag(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTRENAMEEXPR: {
                xw.putStartTag(node, "xqxuf:renameExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTSOURCEEXPR: {
                xw.putStartTag(node, "xqxuf:sourceExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTTARGETEXPR: {
                xw.putStartTag(node, "xqxuf:targetExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            case JJTNEWNAMEEXPR: {
                xw.putStartTag(node, "xqxuf:newNameExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            default:
                return false;
        }
    }

}
// vim: sw=4 ts=4 expandtab
