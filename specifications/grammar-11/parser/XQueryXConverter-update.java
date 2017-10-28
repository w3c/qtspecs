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

        // Consistency would prefer that this if-stmt be instead a case
        // (on JJTCOMPATIBILITYANNOTATION) in the subsequent switch-stmt.
        // However, that would only work when compiled with the xquery11
        // ConverterBase. You'd get a "cannot find symbol" error if you
        // tried to compile it with the xquery10 ConverterBase.
        // The if-stmt, on the other hand, will compile with both.
        if (jjtNodeName[id] == "CompatibilityAnnotation") {
            pushElem("xqx:annotation", node);
            flushOpen(node);

                pushElem("xqx:QName", node);
                flushOpen(node, false);
                xqprint("updating");
                flushClose(node, false);

            flushClose(node);
            return node;
        }

        switch (id) {

        case JJTMODULE: {
            pushElem("xqx:module", node);
            pushAttr("xmlns:xqx", "http://www.w3.org/2005/XQueryX");
            _outputStack.push("\n           ");
            pushAttr("xmlns:xqxuf", "http://www.w3.org/2007/xquery-update-10");
            _outputStack.push("\n           ");
            pushAttr("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
            _outputStack.push("\n           ");

            pushAttr(
                    "xsi:schemaLocation",
                    "http://www.w3.org/2007/xquery-update-10"
                            + "\n                                http://www.w3.org/2007/xquery-update-10/xquery-update-10-xqueryx.xsd");
            // pd(JJTMODULE);
        }
            break;

        case JJTFUNCTIONDECL: {
            if ( BASE_LANGUAGE_ID == "xquery11" ) {
                // Let the base converter handle it
                return super.transformNode(node, id);
            }

            /* copied and extended the xquery10 FunctionDecl-handler to recognize "updating" */

            pushElem(id, node);

            if (node.m_value != null) {
                pushAttr("xqx:updatingFunction", "true");
            }
            flushOpen(node);

            int start = 0;
            transformChildren(node, start, start);
            start++;
            if (getChildID(node, start) == JJTPARAMLIST) {
                transformChildren(node, start, start);
                start++;
            } else {
                pushElem("xqx:paramList", node);
                flushEmpty(node);
            }
            int end = node.jjtGetNumChildren() - 1;
            transformChildren(node, start, end - 1);
            start = end;
            if (getChildID(node, end) == JJTEXTERNAL) {
                transformChildren(node, start, end);
            } else {
                pushElem("xqx:functionBody", node);
                flushOpen(node);
                transformChildren(node, start, end);
                flushClose(node);
            }
            flushClose(node);

        }
            return node;

        case JJTREVALIDATIONDECL: {
            String choice = node.m_value;
            pushElem("xqxuf:revalidationDecl", node);
            flushOpen(node, false);
            xqprint(choice);
            flushClose(node, false);
            return node;
        }

        case JJTINSERTEXPRTARGETCHOICE: {
            String choice = node.m_value;
            if (choice == null) {
                pushElem("xqxuf:insertInto", node);
                flushEmpty(node);
            } else if (choice.equals("first")) {
                pushElem("xqxuf:insertInto", node);
                flushOpen(node);
                pushElem("xqxuf:insertAsFirst", node);
                flushEmpty(node);
                flushClose(node);
            } else if (choice.equals("last")) {
                pushElem("xqxuf:insertInto", node);
                flushOpen(node);
                pushElem("xqxuf:insertAsLast", node);
                flushEmpty(node);
                flushClose(node);
            } else if (choice.equals("before")) {
                pushElem("xqxuf:insertBefore", node);
                flushEmpty(node);
            } else if (choice.equals("after")) {
                pushElem("xqxuf:insertAfter", node);
                flushEmpty(node);
            }
            return node;
        }

        case JJTINSERTEXPR: {
            pushElem("xqxuf:insertExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTDELETEEXPR: {
            pushElem("xqxuf:deleteExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTREPLACEEXPR: {
            pushElem("xqxuf:replaceExpr", node);
            flushOpen(node);

            if (node.m_value != null) {
                pushElem("xqxuf:replaceValue", node);
                flushEmpty(node);
            }

            transformChildren(node, 0, 0);
            pushElem("xqxuf:replacementExpr", node);
            flushOpen(node);
            transformChildren(node, 1, 1);
            flushClose(node);
            flushClose(node);
            return node;
        }

        case JJTRENAMEEXPR: {
            pushElem("xqxuf:renameExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTSOURCEEXPR: {
            pushElem("xqxuf:sourceExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTTARGETEXPR: {
            pushElem("xqxuf:targetExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTNEWNAMEEXPR: {
            pushElem("xqxuf:newNameExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            return node;
        }

        case JJTTRANSFORMEXPR: {
            pushElem("xqxuf:transformExpr", node);
            flushOpen(node);

            pushElem("xqxuf:transformCopies", node);
            flushOpen(node);

            int n = node.jjtGetNumChildren();
            for (int i = 0; i < ((n - 2) / 2); i++) {
                pushElem("xqxuf:transformCopy", node);
                flushOpen(node);
                transform((SimpleNode) node.jjtGetChild(2 * i));
                pushElem("xqxuf:copySource", node);
                flushOpen(node);
                transform((SimpleNode) node.jjtGetChild(2 * i + 1));
                flushClose(node);
                flushClose(node);
            }
            flushClose(node);

            pushElem("xqxuf:modifyExpr", node);
            flushOpen(node);
            transform((SimpleNode) node.jjtGetChild(n - 2));
            flushClose(node);

            pushElem("xqxuf:returnExpr", node);
            flushOpen(node);
            transform((SimpleNode) node.jjtGetChild(n - 1));
            flushClose(node);

            flushClose(node);
            return node;
        }

        default:
            return super.transformNode(node, id);
        }
        return null;
    }

}
