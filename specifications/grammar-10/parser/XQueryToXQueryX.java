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

import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Stack;

/**
 * Transforms an XQuery AST into a XQueryX XML stream.
 */
public class XQueryToXQueryX implements XPathTreeConstants {
    Stack _openElemStack = new Stack();

    Stack _openXMLElemStack = new Stack();

    Stack _outputStack = new Stack();

    Stack _stackChecks = new Stack();

    PrintWriter _xqout1;

    PrintWriter _xqout2;

    static final int BSP_STRIP = 0;

    static final int BSP_PRESERVE = 1;

    int _boundarySpacePolicy = BSP_STRIP;

    boolean _isAttribute = false;

    public XQueryToXQueryX() throws UnsupportedEncodingException {

        try {
            _xqout1 = new PrintWriter(new OutputStreamWriter(System.out,
                    "utf-8"));
        } catch (UnsupportedEncodingException e) {
            try {
                _xqout1 = new PrintWriter(new OutputStreamWriter(System.out,
                        "UTF8"));
            } catch (UnsupportedEncodingException e1) {
                _xqout1 = new PrintWriter(new OutputStreamWriter(System.out,
                        System.getProperty("file.encoding")));
            }
        }
    }

    public XQueryToXQueryX(PrintWriter xqout)
            throws UnsupportedEncodingException {
        _xqout1 = xqout;
    }

    public XQueryToXQueryX(PrintStream xqout)
            throws UnsupportedEncodingException {
        _xqout1 = (xqout != null) ? new PrintWriter(new OutputStreamWriter(
                xqout, "utf-8")) : null;
    }

    public XQueryToXQueryX(PrintStream xqout, PrintStream xqout2)
            throws UnsupportedEncodingException {
        _xqout1 = (xqout != null) ? new PrintWriter(new OutputStreamWriter(
                xqout, "utf-8")) : null;
        _xqout2 = (xqout2 != null) ? new PrintWriter(new OutputStreamWriter(
                xqout2, "utf-8")) : null;
    }

    private void xqprintln() {
        if (null != _xqout1)
            _xqout1.println();
        if (null != _xqout2)
            _xqout2.println();
    }

    private void xqprintln(String s) {
        if (null != _xqout1)
            _xqout1.println(s);
        if (null != _xqout2)
            _xqout2.println(s);
    }

    private void xqprint(String s) {
        if (null != _xqout1)
            _xqout1.print(s);
        if (null != _xqout2)
            _xqout2.print(s);
    }

    private void xqprint(char s) {
        if (null != _xqout1)
            _xqout1.print(s);
        if (null != _xqout2)
            _xqout2.print(s);
    }

    private static int MAXCHAR = 0xFFFF;

    private static void writeUTF16Surrogate(PrintWriter ps, char c, char ch[],
            int i, int end) {

        int surrogateValue = getURF16SurrogateValue(c, ch, i, end);

        ps.print('&');
        ps.print('#');

        ps.print(Integer.toString(surrogateValue));
        ps.print(';');
    }

    private static int getURF16SurrogateValue(char c, char ch[], int i, int end) {
        int next;

        if (i + 1 >= end) {
            throw new RuntimeException("Invalid UTF-16 surrogate detected: "
                    + Integer.toHexString((int) c));
        } else {
            next = ch[++i];

            if (!(0xdc00 <= next && next < 0xe000))
                throw new RuntimeException(
                        "Invalid UTF-16 surrogate detected: "
                                + Integer.toHexString((int) c));

            next = ((c - 0xd800) << 10) + next - 0xdc00 + 0x00010000;
        }

        return next;
    }

    static final private boolean isUTF16Surrogate(char c) {
        return (c & 0xFC00) == 0xD800;
    }

    /**
     * Tell if this character can be written without escaping. Needs more work.
     */
    private static boolean canConvert(char ch) {
        boolean isLegal = ch == 0x9 || ch == 0xA || ch == 0xD
                || (ch >= 0x20 && ch <= 0xD7FF)
                || (ch >= 0xE000 && ch <= 0xFFFD)
                || (ch >= 0x10000 && ch <= 0x10FFFF);
        if (!isLegal)
            throw new RuntimeException(
                    "Characters MUST match the production for Char.");

        return (ch <= MAXCHAR); // noop
    }

    private void xqprintEscaped(String s, char enclosingChar) {
        xqprintEscaped(s, enclosingChar, false);
    }

    private void xqprintEscaped(String s, char enclosingChar, boolean escapeAmp) {

        int strLen = s.length();
        for (int i = 0; i < strLen; i++) {
            char c = s.charAt(i);
            if (c == '&') {
                if(!escapeAmp){
                    // Assume the parser's done it's work.
                    xqprint(c);
                }
                else
                    xqprint("&amp;");
            } else if (c == '<')
                xqprint("&lt;");
            else if (c == '>')
                xqprint("&gt;");
            else if (c == '\'' && (i + 1) < s.length() && s.charAt(i + 1) == '\'' && enclosingChar == '\'') {
                xqprint("\'");
                i++;
            }
            else if (c == '\"' && (i + 1) < s.length()
                    && s.charAt(i + 1) == '\"' && enclosingChar == '\"') {
                xqprint("\"");
                i++;
            }
/*
            else if (isUTF16Surrogate(c)) {
                char[] chars = s.toCharArray();
                int n = s.length();
                if (null != _xqout1)
                    writeUTF16Surrogate(_xqout1, c, chars, i, n - 1);
                if (null != _xqout2)
                    writeUTF16Surrogate(_xqout2, c, chars, i, n - 1);
            } else if (!canConvert(c)) {
                xqprint("&#");
                xqprint(Integer.toString((int) c));
                xqprint(";");
            }
*/
            else if (isUTF16Surrogate(c)) {
                char[] chars = s.toCharArray();
                int n = s.length();
                xqprint("&#");
                xqprint(Integer.toString(getURF16SurrogateValue(c, chars, i++, n)));
                xqprint(";");
            }

            else if (c > '\u007F') {
                xqprint("&#");
                xqprint(Integer.toString((int) c));
                xqprint(";");
            }
            else if(c == 0x0D) {
                if (!((i + 1) < s.length() && s.charAt(i + 1) == 0x0A)) {
                   xqprint("\n");
                }
            }
            else if(_isAttribute && (c == 0x09 || c == 0x0A)){
                if (null != _xqout1)
                    _xqout1.print(' ');
                if (null != _xqout2)
                    _xqout2.print(' ');
            }
            else if (c == 0x0D || c == 0x85 || c == 0x2028) {
                xqprint("&#");
                xqprint(Integer.toString((int) c));
                xqprint(";");
            }
            else {
                if (null != _xqout1)
                    _xqout1.print(c);
                if (null != _xqout2)
                    _xqout2.print(c);
            }
        }

    }

    private void indent() {
        int indentAmount = _openElemStack.size();
        for (int i = 0; i < indentAmount; i++) {
            xqprint(" ");

        }
    }

    private void pd(String s, int i) {
        indent();
        for (int j = 0; j < i; j++) {
            xqprint(" ");
        }
        xqprint("<!-- ");
        xqprint(s);
        xqprintln(" -->");
    }

    private void pd(String s) {
        pd(s, 0);
    }

//    private void pd(int id) {
//        pd(jjtNodeName[id], 0);
//    }

    private void pushElem(int id, SimpleNode node) {
        indent();
        _outputStack.push("<");
        String nodeName = jjtNodeName[id];
        String s = "xqx:" + nodeName.substring(0, 1).toLowerCase()
                + nodeName.substring(1);
        _outputStack.push(s);
        _openElemStack.push(s);
        _openElemStack.push(node);
    }

    private void pushElem(String s, SimpleNode node) {
        indent();
        _outputStack.push("<");
        _outputStack.push(s);
        _openElemStack.push(s);
        _openElemStack.push(node);
    }

    private void pushAttr(String name, String val) {
        _outputStack.push(" ");
        _outputStack.push(name);
        _outputStack.push("=\"");
        _outputStack.push(val);
        _outputStack.push("\"");
    }

    private void flushOpen(SimpleNode node, boolean doLF) {
        if (_outputStack.size() > 0) {
            if (node != _openElemStack.peek())
                return;
            for (int i = 0; i < _outputStack.size(); i++) {
                String s = (String) _outputStack.elementAt(i);
                xqprint(s);
            }
            xqprint(">");
            if (doLF)
                xqprintln();
            _outputStack.removeAllElements();
        }
    }

    private void flushOpen(SimpleNode node) {
        flushOpen(node, true);
    }

    private void flushEmpty(SimpleNode node) {
        if (_outputStack.size() > 0) {
            if (node != _openElemStack.peek())
                return;
            _openElemStack.pop();
            _openElemStack.pop();
            // indent();
            for (int i = 0; i < _outputStack.size(); i++) {
                String s = (String) _outputStack.elementAt(i);
                xqprint(s);
            }
            xqprintln("/>");
            _outputStack.removeAllElements();
        }
    }

    private void flushClose(SimpleNode node, boolean doIndent) {
        if (_openElemStack.size() == 0)
            return;
        if (node != _openElemStack.peek())
            return;
        _openElemStack.pop();
        String elemName = (String) _openElemStack.pop();
        if (doIndent)
            indent();
        xqprint("</");
        xqprint(elemName);
        xqprintln(">");
    }

    private void flushClose(SimpleNode node) {
        flushClose(node, true);
    }

    private boolean isJustWhitespace(SimpleNode node) {
        if (node.id == JJTDIRELEMCONTENT || node.id == JJTDIRATTRIBUTEVALUE) {
            for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                SimpleNode child = (SimpleNode) node.jjtGetChild(i);
                if (!isJustWhitespace(child))
                    return false;
            }
            return true;
        } else if (node.id == JJTCDATASECTION)
            return false;
        else if (node.id == JJTELEMENTCONTENTCHAR
                || node.id == JJTQUOTATTRCONTENTCHAR
                || node.id == JJTAPOSATTRCONTENTCHAR) {
            if (node.m_value.trim().length() == 0)
                return true;
            else
                return false;
        } else {
            return false;
        }
    }

    private boolean isPreviousSiblingBoundaryWhitespaceChar(SimpleNode node) {
        node = getPreviousSibling(sn(node.jjtGetParent()));
        if (node == null)
            return true;
        if (node.jjtGetNumChildren() > 0)
            node = sn(node.jjtGetChild(0));
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
                node = sn(node.jjtGetChild(0));
                if (node.id == JJTLCURLYBRACEESCAPE || node.id == JJTCHARREF
                        || node.id == JJTPREDEFINEDENTITYREF)
                    return false;
            }
            return true;
        }
        return false;
    }

    private boolean isNextSiblingBoundaryWhitespaceChar(SimpleNode node) {
        node = getNextSibling(sn(node.jjtGetParent()));
        if (node == null)
            return true;
        if (node.jjtGetNumChildren() > 0)
            node = sn(node.jjtGetChild(0));
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
                node = sn(node.jjtGetChild(0));
                if (node.id == JJTLCURLYBRACEESCAPE || node.id == JJTCHARREF
                        || node.id == JJTPREDEFINEDENTITYREF)
                    return false;
            }
            return true;
        }
        return false;
    }

    private boolean isBoundaryWhitespaceChar(SimpleNode node) {
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

    private boolean shouldStripChar(SimpleNode node) {
        if ((_boundarySpacePolicy == BSP_STRIP)
                && isBoundaryWhitespaceChar(node))
            return true;
        else
            return false;
    }

    private boolean shouldVoidPathExpr(SimpleNode node) {
        if (getNumExprChildren(node) > 1)
            return false;
        for (int i = 0; i < node.jjtGetNumChildren(); i++) {
            SimpleNode child = (SimpleNode) node.jjtGetChild(i);
            if (child.id == JJTSTEPEXPR)
                return false;
            if (child.id == JJTSLASH || child.id == JJTSLASHSLASH)
                return false;
        }
        return true;
    }

    private void markCheck() {
        _stackChecks.push(new Integer(_openElemStack.size()));
    }

    private boolean check(SimpleNode node) {
        int markSize = ((Integer) _stackChecks.pop()).intValue();
        int currentSize = _openElemStack.size();
        if (markSize != currentSize)
            System.err.println("Stack not flushed properly!!! "
                    + jjtNodeName[node.id]);
        return (markSize == currentSize);
    }

    private void xqflush() {
        if (null != _xqout1)
            _xqout1.flush();
        if (null != _xqout2)
            _xqout2.flush();
    }

    public boolean transform(SimpleNode node, PrintStream ps1)
            throws UnsupportedEncodingException {
        _xqout1 = (ps1 != null) ? new PrintWriter(new OutputStreamWriter(ps1,
                "utf-8")) : null;
        boolean ret = transform(node);
        xqflush();
        return ret;
    }

    public boolean transform(SimpleNode node, PrintStream ps1, PrintStream ps2)
            throws UnsupportedEncodingException {
        _xqout1 = (ps1 != null) ? new PrintWriter(new OutputStreamWriter(ps1,
                "utf-8")) : null;
        _xqout2 = (ps2 != null) ? new PrintWriter(new OutputStreamWriter(ps2,
                "utf-8")) : null;
        boolean ret = transform(node);
        xqflush();
        return ret;
    }

    public boolean transformNoEncodingException(SimpleNode node,
            PrintStream ps1, PrintStream ps2) {
        try {
            _xqout1 = (ps1 != null) ? new PrintWriter(new OutputStreamWriter(
                    ps1, "utf-8")) : null;
            _xqout2 = (ps2 != null) ? new PrintWriter(new OutputStreamWriter(
                    ps2, "utf-8")) : null;
        } catch (UnsupportedEncodingException e) {
            _xqout1 = (ps1 != null) ? new PrintWriter(ps1) : null;
            _xqout2 = (ps2 != null) ? new PrintWriter(ps2) : null;
        }
        boolean ret = transform(node);
        xqflush();
        return ret;
    }

    public boolean transform(SimpleNode node) {
        markCheck();
        int id = node.id;

        switch (id) {
        case JJTXPATH2: {
            xqprintln("<?xml version=\"1.0\"?>");
            // pd(JJTXPATH2);
        }
            break;
        case JJTQUERYLIST: {
            // No action
            // pd(JJTQUERYLIST);
        }
            break;
        case JJTMODULE: {
            pushElem("xqx:module", node);
            pushAttr("xmlns:xqx", "http://www.w3.org/2005/XQueryX");
            _outputStack.push("\n           ");
            pushAttr("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
            _outputStack.push("\n           ");
            // pushAttr("xsi:noNamespaceSchemaLocation", "xqueryx.xsd");
            // pushAttr("xsi:noNamespaceSchemaLocation",
            // "file:///c:/proj/xqed2/grammar/parser/xqueryx.xsd");
            pushAttr(
                    "xsi:schemaLocation",
                    "http://www.w3.org/2005/XQueryX"
                            + "\n                                http://www.w3.org/2005/XQueryX/xqueryx.xsd");
            // pd(JJTMODULE);
        }
            break;
        case JJTVERSIONDECL: {
            // pd(JJTVERSIONDECL);
            pushElem(id, node);
            flushOpen(node);

            for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                SimpleNode child = (SimpleNode) node.jjtGetChild(i);
                if (i == 0) {
                    pushElem("xqx:version", child);
                    flushOpen(child, false);
                    xqprint(child.m_value.substring(1,
                            child.m_value.length() - 1));
                    flushClose(child, false);
                } else if (i == 1) {
                    pd("encoding: " + child.m_value);
                }
            }
            flushClose(node);
        }
            return check(node);
        case JJTINTEGERLITERAL:
        case JJTDECIMALLITERAL:
        case JJTDOUBLELITERAL:
        case JJTSTRINGLITERAL: {
            boolean doValue = true;
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
                if (getParentID(node) == JJTOPTIONDECL) {
                    elemName = "xqx:optionContents";
                    doValue = false;
                } else
                    elemName = "xqx:stringConstantExpr";
                break;
            default:
                elemName = "UNKNOWN!";
                break;
            }
            pushElem(elemName, node);
            flushOpen(node, doValue);

            if (doValue) {
                pushElem("xqx:value", node);
                flushOpen(node, false);
            }
            String val = node.m_value;
            if (id == JJTSTRINGLITERAL) {
                char enclosing = val.charAt(0);
                val = val.substring(1, val.length() - 1);
                xqprintEscaped(val, enclosing);
            }
            else
               xqprintEscaped(val, 'x');            
            if (doValue) {
                flushClose(node, false);
            }

            flushClose(node, doValue);
        }
            return check(node);

        case JJTBASEURIDECL:
            // handled in JJTBASEURIDECL
            break;

        case JJTURILITERAL: {
            if (getParentID(node) == JJTBASEURIDECL)
                pushElem("xqx:baseUriDecl", node);
            else if (getParentID(node) == JJTORDERMODIFIER)
                pushElem("xqx:collation", node);
            else if (getParentID(node) == JJTDEFAULTCOLLATIONDECL)
                pushElem("xqx:defaultCollationDecl", node);
            else if (getParentID(node) == JJTMODULEIMPORT) {
                SimpleNode firstChild = (SimpleNode)node.jjtGetParent().jjtGetChild(0);
                if ((firstChild == node)
                        || (firstChild.id == JJTNCNAME && (((SimpleNode) node
                                .jjtGetParent().jjtGetChild(1)) == node)))
                    pushElem("xqx:targetNamespace", node);
                else
                    pushElem("xqx:targetLocation", node);
            } else
                pushElem("xqx:uri", node);
            flushOpen(node, false);
            SimpleNode child = sn(node.jjtGetChild(0));
            String val = child.m_value;
            char enclosing = val.charAt(0);
            val = val.substring(1, val.length() - 1);
            xqprintEscaped(val, enclosing);
            flushClose(node, false);
        }
            return check(node);

        case JJTPROLOG: {
            if (node.jjtGetNumChildren() > 0) {
                // pd(JJTPROLOG);
                pushElem("xqx:prolog", node);
            }
        }
            reorderProlog(node);
            break;

        case JJTNCNAMECOLONSTAR:
        case JJTSTARCOLONNCNAME: {
            String qname = node.m_value;

            int i = qname.indexOf(':');
            if (i > 0) {
                String prefix = qname.substring(0, i);
                qname = qname.substring(i + 1);
                if (prefix.equals("*")) {
                    pushElem("xqx:star", node);
                    flushEmpty(node);
                } else {
                    pushElem("xqx:NCName", node);
                    flushOpen(node, false);
                    xqprint(prefix);
                    flushClose(node, false);
                }
            }
            if (qname.equals("*")) {
                pushElem("xqx:star", node);
                flushEmpty(node);
            } else {
                pushElem("xqx:NCName", node);
                flushOpen(node, false);
                xqprint(qname);
                flushClose(node, false);
            }
        }
            return check(node);

        case JJTSINGLETYPE: {
            boolean optionality = (node.m_value != null);
            pushElem(id, node);
            flushOpen(node);
            transformChildren(node);
            if (optionality) {
                pushElem("xqx:optional", node);
                flushEmpty(node);
            }
            flushClose(node);
        }
            return check(node);

        case JJTPRAGMAOPEN:
        case JJTPRAGMACLOSE:
            // No Action
            break;

        case JJTATOMICTYPE:
            // handled in JJTQNAME
            break;

        case JJTATTRIBNAMEORWILDCARD:
        case JJTELEMENTNAMEORWILDCARD:
            if (node.m_value != null && node.m_value.equals("*")) {
                pushElem(id == JJTATTRIBNAMEORWILDCARD ? JJTATTRIBUTENAME
                        : JJTELEMENTNAME, node);
                flushOpen(node);
                pushElem("xqx:star", node);
                flushEmpty(node);
                flushClose(node);
                return check(node);
            }
            break;

        case JJTATTRIBUTENAME:
        case JJTELEMENTNAME:
            pushElem(id, node);
            break;

        // case JJTTYPENAME:
        case JJTQNAMEFORPRAGMA:
        case JJTNCNAME:
        case JJTQNAME: {
            int pid = getParentID(node);
            if (pid == JJTCOMPELEMCONSTRUCTOR || pid == JJTCOMPATTRCONSTRUCTOR)
                pushElem("xqx:tagName", node);
            else if (pid == JJTTYPENAME)
                pushElem("xqx:typeName", node);
            else if (pid == JJTCOMPPICONSTRUCTOR)
                pushElem("xqx:piTarget", node);
            else if (pid == JJTATOMICTYPE)
                pushElem(JJTATOMICTYPE, node);
            else if (pid == JJTNAMESPACEDECL)
                pushElem("xqx:prefix", node);
            else if (pid == JJTVARDECL || pid == JJTPARAM)
                pushElem("xqx:varName", node);
            else if (pid == JJTFUNCTIONDECL)
                pushElem("xqx:functionName", node);
            else if (pid == JJTOPTIONDECL)
                pushElem("xqx:optionName", node);
            else if (pid == JJTOPTIONDECL)
                pushElem("xqx:optionName", node);
            else if (pid == JJTMODULEIMPORT)
                pushElem("xqx:namespacePrefix", node);
            else if (pid == JJTPRAGMA)
                pushElem("xqx:pragmaName", node);
             else
                pushElem("xqx:QName", node);
            String qname = processPrefix(node.m_value);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);
        }
            return check(node);

        case JJTENDTAGQNAME:
            SimpleNode openTag = (SimpleNode)_openXMLElemStack.peek();
            if(!openTag.getValue().equals(node.getValue()))
                throw new PostParseException("Error: In a direct element constructor, the name used in the end tag must exactly match the name used in the corresponding start tag, including its prefix or absence of a prefix.");
            return check(node);

        case JJTTAGQNAME: {
            if (getParentID(node) == JJTDIRATTRIBUTELIST
                    && isNamespaceDecl(node)) {
                if(!node.m_value.equals("xmlns")){
                    pushElem("xqx:prefix", node);
                    flushOpen(node, false);
                    int i = node.m_value.indexOf(':');
                    String prefix = node.m_value.substring(i + 1);
                    xqprint(prefix);
                    flushClose(node, false);
                }
                return check(node);
            }

            else if (getParentID(node) == JJTDIRATTRIBUTELIST) {
                if (node.getValue().startsWith("xmlns:")) {
                    pushElem("xqx:prefix", node);
                } else if (node.getValue().equals("xmlns")) {
                    // don't do anything
                } else
                    pushElem("xqx:attributeName", node);
            } else {
                pushElem("xqx:tagName", node);
            }

            String qname = null;
            qname = processPrefix(node.m_value);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);


        }
            return check(node);

        case JJTFUNCTIONQNAME: {
            pushElem("xqx:functionName", node);
            String qname = processPrefix(node.m_value);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);
        }
            return check(node);

        case JJTWILDCARD:
            pushElem("xqx:Wildcard", node);
            break;

        case JJTNAMETEST:
            if (getChildID(node, 0) == JJTWILDCARD)
                break;
        // Fall through on purpose

        case JJTVARNAME: {
            SimpleNode parent = (SimpleNode)node.jjtGetParent();
            int pid = parent.id;
            if (/* pid == JJTCASECLAUSE || */
                pid == JJTTYPESWITCHEXPR && getNextSibling(node) != null) {
                pushElem("xqx:variableBinding", node);
            } else if (id == JJTVARNAME) {
                pushElem("xqx:varRef", node);
                flushOpen(node, true);
                pushElem("xqx:name", node);
            } else
                pushElem(id, node);
            String qname = ((SimpleNode) node.jjtGetChild(0)).m_value;
            if (null != qname)
                qname = processPrefix(qname);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);

            SimpleNode nextSibling = getNextSibling(node);
            if (null != nextSibling && nextSibling.id == JJTTYPEDECLARATION) {
                transform(nextSibling);
            }

            if (id == JJTVARNAME) {
                flushClose(node, true);
            }

        }
            return check(node);

        case JJTPOSITIONALVAR: {
            pushElem("xqx:positionalVariableBinding", node);
            String val = sn(sn(node.jjtGetChild(0)).jjtGetChild(0)).m_value;
            String qname = processPrefix(val);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);
        }
            return check(node);

        case JJTITEMTYPE:
            if (node.m_value != null && node.m_value.equals("item")) {
                pushElem("xqx:anyItemType", node);
                flushEmpty(node);
                return check(node);
            }
            break;

        case JJTSEQUENCETYPE: {
            int pid = getParentID(node);
            boolean shouldBeSeqType = pid == JJTCASECLAUSE;
            if (shouldBeSeqType) {
                pushElem("xqx:sequenceType", node);
                flushOpen(node);
            }
            else if (pid == JJTFUNCTIONDECL) {
                pushElem("xqx:typeDeclaration", node);
                flushOpen(node);
            }
            if (node.m_value != null && node.m_value.equals("empty-sequence")) {
                pushElem("xqx:voidSequenceType", node);
                flushEmpty(node);
            } else {
                transformChildren(node);
            }
            if (shouldBeSeqType || pid == JJTFUNCTIONDECL) {
                flushClose(node);
            }
        }
            return check(node);

        case JJTEXPR:
            // sequenceExpr
            // (getParentID(node) == JJTPARENTHESIZEDEXPR || getParentID(node)
            // == JJTQUERYBODY)
            if (getNumExprChildren(node) > 1) {
                pushElem("xqx:sequenceExpr", node);
                flushOpen(node);
                transformChildren(node);
                flushClose(node);
                // return check(node);
            }
            else {
                transformChildren(node);
            }
            return check(node);

        case JJTPATHEXPR: {
            if (!shouldVoidPathExpr(node)) {
                pushElem(id, node);
                flushOpen(node, true);

                for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if(child.id == JJTSLASH){
                        pushElem("xqx:rootExpr", child);
                        flushEmpty(child);
                        flushClose(child);
                        continue;
                    }
                    else if(child.id == JJTSLASHSLASH){
                        transform(child);
                        continue;
                    }
                    boolean isFilter = isFilterExpr(child);
                    if (isFilter) {
                        pushElem("xqx:stepExpr", node);
                        flushOpen(node, true);
                        pushElem("xqx:filterExpr", node);
                        flushOpen(node, true);
                        if (child.id == JJTPARENTHESIZEDEXPR) {
                            pushElem("xqx:sequenceExpr", node);
                            flushOpen(node, true);
                            // if(getFirstChildOfFirstChildID(child) == JJTSTEPEXPR){
                            //    pushElem(id, node);
                            //    flushOpen(node, true);
                            // }
                        }
                    }

                    transform(child); // JJTPARENTHESIZEDEXPR will be void

                    if (isFilter) {
                        flushClose(node);
                        flushClose(node);
                        // if(getFirstChildOfFirstChildID(child) == JJTSTEPEXPR){
                        //    flushClose(node);
                        // }
                        if (child.id == JJTPARENTHESIZEDEXPR)
                            flushClose(node);
                    }

                    // flushClose(node);

                }
                flushClose(node);
                return check(node);
            }
        }
            break;

        case JJTPREDICATELIST:
            pushElem("xqx:predicates", node);
            break;

        case JJTFUNCTIONCALL: {
            pushElem("xqx:functionCallExpr", node);
            flushOpen(node, true);

            SimpleNode funcNameExpr = (SimpleNode) node.jjtGetChild(0);
            transform(funcNameExpr);

            pushElem("xqx:arguments", node);
            flushOpen(node, true);

            int start = 1;
            transformChildren(node, start);
            flushClose(node);
            flushClose(node);

        }
            return check(node);

        case JJTSTEPEXPR: {
            SimpleNode parent = ((SimpleNode)node.jjtGetParent());
            boolean isReducedPathExpr = (parent.id != JJTPATHEXPR);
            if(isReducedPathExpr){
                pushElem("xqx:pathExpr", node);
                flushOpen(node, true);
            }
            pushElem(id, node);
            flushOpen(node, true);
            int start = 0;
            int childID = getChildID(node, start);
            boolean isFilter = isFilterExpr((SimpleNode)node.jjtGetChild(0));
            if (isFilter) {
                // predicates outside
                pushElem("xqx:filterExpr", node);
                flushOpen(node, true);
                if (childID == JJTPARENTHESIZEDEXPR) {
                    pushElem("xqx:sequenceExpr", node);
                    flushOpen(node, true);
                    // pushElem("xqx:pathExpr", node);
                    // flushOpen(node, true);
                }

                SimpleNode predicateList = null;
                for (int i = start; i < node.jjtGetNumChildren(); i++) {
                    SimpleNode child = (SimpleNode) node.jjtGetChild(i);
                    if (child.id == JJTPREDICATELIST) {
                        predicateList = child;
                        continue;
                    }
                    transform(child);
                }

                flushClose(node, true);

                if (childID == JJTPARENTHESIZEDEXPR){
                    flushClose(node, true);
                    // flushClose(node, true);
                }
                if (null != predicateList) {
                    transform(predicateList);
                }
            } else {

                if (childID == JJTFORWARDAXIS || childID == JJTREVERSEAXIS) {
                    pushElem("xqx:xpathAxis", node);
                    flushOpen(node, false);
                    String axisStr = sn(node.jjtGetChild(0)).m_value;
                    xqprint(axisStr);
                    start++;
                    flushClose(node, false);
                } else if (childID == JJTABBREVREVERSESTEP) {
                    pushElem("xqx:xpathAxis", node);
                    flushOpen(node, false);
                    xqprint("parent");
                    flushClose(node, false);
                    pushElem("xqx:anyKindTest", node);
                    flushEmpty(node);
                    start++;
                } else if (childID == JJTABBREVFORWARDSTEP) {
                    String optionalAttribIndicator = sn(node.jjtGetChild(0)).m_value;
                    SimpleNode afs = sn(node.jjtGetChild(0));
                    SimpleNode possibleNodeTest = null;
                    SimpleNode possibleAttributeTest = null;
                    if (afs != null) {
                       possibleNodeTest = sn(afs.jjtGetChild(0));
                       if (possibleNodeTest != null) {
                          possibleAttributeTest = sn(possibleNodeTest.jjtGetChild(0));
                       }
                    }
                    if (optionalAttribIndicator != null
                            && optionalAttribIndicator.equals("@")) {
                        pushElem("xqx:xpathAxis", node);
                        flushOpen(node, false);
                        xqprint("attribute");
                        flushClose(node, false);
                    } else if (possibleNodeTest != null
                               && possibleNodeTest.id == JJTNODETEST
                               && possibleAttributeTest != null
                               && (possibleAttributeTest.id == JJTATTRIBUTETEST
                                   || possibleAttributeTest.id == JJTSCHEMAATTRIBUTETEST
                                  )
                              ) {
                        pushElem("xqx:xpathAxis", node);
                        flushOpen(node, false);
                        xqprint("attribute");
                        flushClose(node, false);
                    } else {
                        // SimpleNode prev = getPreviousSibling(node);
                        // if (prev != null && (prev.id == JJTSLASHSLASH || true))
                        {
                            pushElem("xqx:xpathAxis", node);
                            flushOpen(node, false);
                            xqprint("child");
                            flushClose(node, false);
                        }
                    }

                    transformChildren(sn(node.jjtGetChild(0)), start);
                    start++;
                } else {
                    // SimpleNode prev = getPreviousSibling(node);
                    if (!isFilterExpr((SimpleNode)node.jjtGetChild(0)))
                    {
                        pushElem("xqx:xpathAxis", node);
                        flushOpen(node, false);
                        xqprint("child");
                        flushClose(node, false);
                    }
                }
                transformChildren(node, start);


            }
            flushClose(node);
            if(isReducedPathExpr){
                flushClose(node);
            }
            return check(node);
        }
        // return check(node);

        case JJTQUANTIFIEDEXPR: {
            pushElem(id, node);
            flushOpen(node);
            pushElem("xqx:quantifier", node);
            flushOpen(node, false);
            xqprint(node.m_value);
            flushClose(node, false);

            int n = node.jjtGetNumChildren();
            for (int i = 0; i < n - 1;) {
                SimpleNode typedVariableBinding = sn(node.jjtGetChild(i));
                i++;

                pushElem("xqx:quantifiedExprInClause", node);
                flushOpen(node);

                pushElem("xqx:typedVariableBinding", node);
                flushOpen(node, true);

                pushElem(typedVariableBinding.id, typedVariableBinding);
                String qname = ((SimpleNode) typedVariableBinding.jjtGetChild(0)).m_value;
                if (null != qname)
                    qname = processPrefix(qname);
                flushOpen(typedVariableBinding, false);
                xqprint(qname);
                flushClose(typedVariableBinding, false);

                SimpleNode nextChild = (SimpleNode) node.jjtGetChild(i);
                i++;

                if (nextChild.id == JJTTYPEDECLARATION) {
                    // handle, ugh, in varname
                    transform(nextChild);
                    nextChild = (SimpleNode) node.jjtGetChild(i);
                    i++;
                }
                flushClose(node, true); // xqx:typedVariableBinding

                pushElem("xqx:sourceExpr", node);
                flushOpen(node);

                transform(nextChild);

                flushClose(node);
                flushClose(node);

            }
            pushElem("xqx:predicateExpr", node);
            flushOpen(node);
            transformChildren(node, n - 1, n - 1);
            flushClose(node);

            flushClose(node);
        }
            return check(node);

        case JJTIFEXPR:
            pushElem("xqx:ifThenElseExpr", node);
            flushOpen(node);

            pushElem("xqx:ifClause", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);

            pushElem("xqx:thenClause", node);
            flushOpen(node);
            transformChildren(node, 1, 1);
            flushClose(node);

            pushElem("xqx:elseClause", node);
            flushOpen(node);
            transformChildren(node, 2, 2);
            flushClose(node);

            flushClose(node);
            return check(node);

        case JJTFLWOREXPR: {
            pushElem("xqx:flworExpr", node);
            flushOpen(node);
            int n = node.jjtGetNumChildren();
            transformChildren(node, 0, n - 2);
            pushElem("xqx:returnClause", node);
            flushOpen(node);
            transformChildren(node, n - 1, n - 1);
            flushClose(node);
            flushClose(node);
        }
            return check(node);

        case JJTRANGEEXPR: {
            pushElem("xqx:rangeSequenceExpr", node);
            flushOpen(node);
            {
                pushElem("xqx:startExpr", node);
                flushOpen(node);
                transform(sn(node.jjtGetChild(0)));
                flushClose(node);
            }
            {
                pushElem("xqx:endExpr", node);
                flushOpen(node);
                transform(sn(node.jjtGetChild(1)));
                flushClose(node);
            }

            flushClose(node);
        }
            return check(node);

        case JJTUNARYEXPR: {
            int nUnarys = 0;
            for (int i = 0; i < node.jjtGetNumChildren(); i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                if (child.id == JJTPLUS) {
                    pushElem("xqx:unaryPlusOp", node);
                    flushOpen(node);
                    pushElem("xqx:operand", node);
                    flushOpen(node);
                    nUnarys++;
                } else if (child.id == JJTMINUS) {
                    pushElem("xqx:unaryMinusOp", node);
                    flushOpen(node);
                    pushElem("xqx:operand", node);
                    flushOpen(node);
                    nUnarys++;
                } else {
                    transform(child);
                    for (int j = 0; j < nUnarys; j++) {
                        flushClose(node);
                        flushClose(node);
                    }
                    break;
                }
            }
        }
            return check(node);

        // setOp??
        case JJTADDITIVEEXPR:
        case JJTMULTIPLICATIVEEXPR:
        case JJTUNIONEXPR:
        case JJTINTERSECTEXCEPTEXPR:
        case JJTCOMPARISONEXPR:
        case JJTANDEXPR:
        case JJTOREXPR: {
            switch (id) {
            case JJTADDITIVEEXPR: {
                String op = node.m_value;
                String elemName;
                if (op.equals("+"))
                    elemName = "xqx:addOp";
                else if (op.equals("-"))
                    elemName = "xqx:subtractOp";
                else
                    elemName = "JJTADDITIVEEXPR UNKNOWN EXPR!";
                pushElem(elemName, node);
            }
                break;
            case JJTMULTIPLICATIVEEXPR: {
                String op = node.m_value;
                String elemName;
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
                pushElem(elemName, node);
            }
                break;
            case JJTUNIONEXPR:
                pushElem("xqx:unionOp", node);
                break;
            case JJTINTERSECTEXCEPTEXPR: {
                String op = node.m_value;
                String elemName;
                if (op.equals("intersect"))
                    elemName = "xqx:intersectOp";
                else if (op.equals("except"))
                    elemName = "xqx:exceptOp";
                else
                    elemName = "JJTINTERSECTEXCEPTEXPR UNKNOWN EXPR: " + op;
                pushElem(elemName, node);
            }
                break;
            case JJTANDEXPR:
                pushElem("xqx:andOp", node);
                break;
            case JJTOREXPR:
                pushElem("xqx:orOp", node);
                break;
            case JJTCOMPARISONEXPR: {
                String op = node.m_value;
                String elemName;
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
                pushElem(elemName, node);
            }
                break;
            default:
                pushElem("???", node);
                break;
            }
            flushOpen(node);

            {
                pushElem("xqx:firstOperand", node);
                flushOpen(node);
                transform(sn(node.jjtGetChild(0)));
                flushClose(node);
            }
            {
                pushElem("xqx:secondOperand", node);
                flushOpen(node);
                transform(sn(node.jjtGetChild(1)));
                flushClose(node);
            }

            flushClose(node);
        }
            return check(node);

        case JJTSLASH:
            pushElem("xqx:pathExpr", node);
            flushOpen(node);
            pushElem("xqx:rootExpr", node);
            flushEmpty(node);
            flushClose(node);
            return check(node);

        case JJTSLASHSLASH:
            if (sn(node.jjtGetParent()).jjtGetChild(0) == node) {
                pushElem("xqx:rootExpr", node);
                flushEmpty(node);
                pushElem("xqx:stepExpr", node);
                flushOpen(node);
                pushElem("xqx:xpathAxis", node);
                flushOpen(node, false);
                xqprint("descendant-or-self");
                flushClose(node, false);
                pushElem("xqx:anyKindTest", node);
                flushEmpty(node);

                flushClose(node);
                flushClose(node);
            } else {
                pushElem("xqx:stepExpr", node);
                flushOpen(node);
                pushElem("xqx:xpathAxis", node);
                flushOpen(node, false);
                xqprint("descendant-or-self");
                flushClose(node, false);
                pushElem("xqx:anyKindTest", node);
                flushEmpty(node);
                flushClose(node);
            }
            return check(node);

        case JJTLETCLAUSE:
        case JJTFORCLAUSE: {
            pushElem(id, node);
            flushOpen(node);

            int n = node.jjtGetNumChildren();
            for (int i = 0; i < n; i++) {
                SimpleNode child = (SimpleNode) node.jjtGetChild(i);
                // Gets a little funky here, trying to break up into
                // forClauseItems
                if (child.id == JJTVARNAME) {
                    pushElem((id == JJTFORCLAUSE) ? "xqx:forClauseItem"
                            : "xqx:letClauseItem", node);
                    flushOpen(node, true);

                    pushElem("xqx:typedVariableBinding", node);
                    flushOpen(node, true);

                    pushElem(child.id, (SimpleNode)child);
                    String qname = ((SimpleNode) child.jjtGetChild(0)).m_value;
                    if (null != qname)
                        qname = processPrefix(qname);
                    flushOpen(child, false);
                    xqprint(qname);
                    flushClose(child, false);

                    i++;
                    SimpleNode nextChild = (SimpleNode) node.jjtGetChild(i);

                    if (nextChild.id == JJTTYPEDECLARATION) {
                        // handle, ugh, in varname
                        transform(nextChild);
                        i++;
                        nextChild = (SimpleNode) node.jjtGetChild(i);
                    }
                    flushClose(node, true); // xqx:typedVariableBinding

                    if (nextChild.id == JJTPOSITIONALVAR) {
                        transformChildren(node, i, i);
                        i++;
                        nextChild = (SimpleNode) node.jjtGetChild(i);
                    }

                    pushElem((id == JJTFORCLAUSE) ? "xqx:forExpr"
                            : "xqx:letExpr", node);
                    flushOpen(node, true);

                    transform(nextChild);

                    flushClose(node); // xqx:forExpr/xqx:letExpr
                    flushClose(node); // xqx:forClauseItem/xqx:letClauseItem
                }
            }

            flushClose(node);

        }
            return check(node);

        case JJTORDERSPECLIST: {
            int n = node.jjtGetNumChildren();
            for (int i = 0; i < n; i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                pushElem("xqx:orderBySpec", node);
                flushOpen(node);
                transform(child);

                if (child.id == JJTORDERSPEC) {
                    int n2 = child.jjtGetNumChildren();
                    for (int j = 0; j < n2; j++) {
                        SimpleNode child2 = sn(child.jjtGetChild(j));
                        if (child2.id == JJTORDERMODIFIER) {
                            if (child2.jjtGetNumChildren() > 0)
                                transform(child2);
                        }
                    }
                }
                flushClose(node);
            }

        }
            return check(node);

        case JJTORDERSPEC: {
            pushElem("xqx:orderByExpr", node);
            flushOpen(node);
            int n = node.jjtGetNumChildren();
            for (int i = 0; i < n; i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                if (child.id != JJTORDERMODIFIER)
                    transform(child);
            }
            flushClose(node);
        }
            return check(node);

        case JJTORDERMODIFIER:
            if (node.jjtGetNumChildren() == 0)
                return check(node);
            pushElem(id, node);
            break;

        case JJTPITEST: {
            pushElem("xqx:piTest", node);
            if (node.jjtGetNumChildren() > 0) {
                flushOpen(node);
                SimpleNode child = sn(node.jjtGetChild(0));
                markCheck();
                pushElem("xqx:piTarget", child);
                flushOpen(child, false);
                String ncName = child.m_value;
                if (child.id == JJTSTRINGLITERAL)
                    ncName = ncName.substring(1, ncName.length() - 1);
                xqprint(ncName);
                flushClose(child, false);
                check(child);

                flushClose(node);
            } else {
                flushEmpty(node);
            }
        }
            return check(node);

        case JJTSCHEMAIMPORT: {
            pushElem("xqx:schemaImport", node);
            flushOpen(node);

            SimpleNode child = sn(node.jjtGetChild(0));
            SimpleNode targetNamespace;
            int start = 0;
            if (child.id == JJTSCHEMAPREFIX && child.jjtGetNumChildren() > 0) {
                pushElem("xqx:namespacePrefix", node);
                flushOpen(node, false);
                xqprint(sn(child.jjtGetChild(0)).m_value);
                start++;
                flushClose(node, false);
                targetNamespace = sn(node.jjtGetChild(1));
                start++;
            } else if (child.id == JJTSCHEMAPREFIX) {
                pushElem("xqx:defaultElementNamespace", node);
                flushEmpty(node);
                start++;
                targetNamespace = sn(node.jjtGetChild(1));
                start++;
            } else {
                targetNamespace = child;
                start++;
            }
            pushElem("xqx:targetNamespace", targetNamespace);
            flushOpen(targetNamespace, false);
            String val = sn(targetNamespace.jjtGetChild(0)).m_value;
            val = val.substring(1, val.length() - 1);
            xqprint(val);
            flushClose(targetNamespace, false);

            for (int i = start; i < node.jjtGetNumChildren(); i++) {
                SimpleNode tl = sn(node.jjtGetChild(i));
                pushElem("xqx:targetLocation", tl);
                flushOpen(tl, false);
                val = sn(targetNamespace.jjtGetChild(0)).m_value;
                val = val.substring(1, val.length() - 1);
                xqprint(val);
                flushClose(tl, false);
            }
            flushClose(node);
        }
            return check(node);

        case JJTASCENDING:
        case JJTDESCENDING: {
            pushElem("xqx:orderingKind", node);
            flushOpen(node, false);
            if (id == JJTASCENDING)
                xqprint("ascending");
            else
                xqprint("descending");
            flushClose(node, false);
        }
            return check(node);

        case JJTGREATEST:
        case JJTLEAST: {
            if (getParentID(node) == JJTEMPTYORDERDECL)
                pushElem("xqx:emptyOrderingDecl", node);
            else
                pushElem("xqx:emptyOrderingMode", node);
            flushOpen(node, false);
            if (id == JJTGREATEST)
                xqprint("empty greatest");
            else
                xqprint("empty least");
            flushClose(node, false);
        }
            return check(node);

        case JJTPARENTHESIZEDEXPR:
            if (node.jjtGetNumChildren() == 0)
                pushElem("xqx:sequenceExpr", node);
            break;

        case JJTDEFAULTNAMESPACEDECL: {
            pushElem(id, node);
            flushOpen(node);
            pushElem("xqx:defaultNamespaceCategory", node);
            flushOpen(node, false);
            xqprint(node.m_value);
            flushClose(node, false);
            transformChildren(node);
            flushClose(node);
        }
            return check(node);

        case JJTBOUNDARYSPACEDECL:
            if (node.m_value.equals("preserve"))
                _boundarySpacePolicy = BSP_PRESERVE;
            else
                _boundarySpacePolicy = BSP_STRIP;
            return check(node);

        case JJTOCCURRENCEINDICATOR:
        case JJTORDERINGMODEDECL:
        case JJTPRESERVEMODE:
        case JJTINHERITMODE:
        case JJTCONSTRUCTIONDECL:
            pushElem(id, node);
            flushOpen(node, false);
            xqprint(node.m_value);
            flushClose(node, false);
            return check(node);

        case JJTINSTANCEOFEXPR:
        case JJTTREATEXPR:
        case JJTCASTABLEEXPR:
        case JJTCASTEXPR:
            if (id == JJTINSTANCEOFEXPR)
                pushElem("xqx:instanceOfExpr", node);
            else
                pushElem(id, node);
            flushOpen(node);
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);
            if (id != JJTCASTEXPR && id != JJTCASTABLEEXPR) {
                pushElem("xqx:sequenceType", node);
                flushOpen(node);
                transformChildren(node, 1, 1);
                flushClose(node);
            } else {
                transformChildren(node, 1, 1);
            }
            flushClose(node);
            return check(node);

        case JJTORDEREDEXPR:
        case JJTUNORDEREDEXPR: {
            pushElem(id, node);
            flushOpen(node);
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            flushClose(node);
        }
            return check(node);

        case JJTTYPESWITCHEXPR: {
            pushElem(id, node);
            flushOpen(node);
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            transformChildren(node, 0, 0);
            flushClose(node);

            int n = node.jjtGetNumChildren();
            int startOfDefault = n - 2;
            transformChildren(node, 1, startOfDefault - 1);

            if (getChildID(node, startOfDefault) != JJTVARNAME) {
                transformChildren(node, startOfDefault, startOfDefault);
                startOfDefault++;
            }
            pushElem("xqx:typeswitchExprDefaultClause", node);
            flushOpen(node);
            if (startOfDefault == n - 2) {
                transformChildren(node, startOfDefault, startOfDefault);
                startOfDefault++;
            }
            pushElem("xqx:resultExpr", node);
            flushOpen(node);
            transformChildren(node, startOfDefault, startOfDefault);
            flushClose(node);

            flushClose(node);

            flushClose(node);
        }
            return check(node);

        case JJTCASECLAUSE: {
            pushElem("xqx:typeswitchExprCaseClause", node);
            flushOpen(node);

            int nChildren = node.jjtGetNumChildren();
            int currentChild = 0;
            if (nChildren == 3) {
                currentChild++;
                pushElem("xqx:variableBinding", node);

                String qname = getFirstChildOfFirstChild(node).m_value;
                if (null != qname)
                    qname = processPrefix(qname);
                flushOpen(node, false);
                xqprint(qname);
                flushClose(node, false);
            }

            transformChildren(node, currentChild, currentChild);
            currentChild++;
            pushElem("xqx:resultExpr", node);
            flushOpen(node);
            transformChildren(node, currentChild);
            flushClose(node);
            flushClose(node);

        }
            return check(node);

        case JJTFUNCTIONDECL: {
            pushElem(id, node);
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
                pushElem("xqx:externalDefinition", node);
                flushEmpty(node);                
            } else {
                pushElem("xqx:functionBody", node);
                flushOpen(node);
                transformChildren(node, start, end);
                flushClose(node);
            }
            flushClose(node);

        }
            return check(node);

        case JJTVARDECL: {
            pushElem(id, node);
            flushOpen(node);
            int start = 0;
            int end = node.jjtGetNumChildren() - 1;
            transformChildren(node, start, end - 1);
            start = end;
            if (getChildID(node, end) == JJTEXTERNAL) {
                transformChildren(node, start, end);
            } else {
                pushElem("xqx:varValue", node);
                flushOpen(node);
                transformChildren(node, start, end);
                flushClose(node);
            }
            flushClose(node);

        }
            return check(node);

        case JJTOPTIONDECL:
        case JJTSCHEMAPREFIX:
        case JJTANYKINDTEST:
        case JJTDOCUMENTTEST:
        case JJTTEXTTEST:
        case JJTCOMMENTTEST:
        case JJTATTRIBUTETEST:
        case JJTEXTERNAL:
        case JJTMAINMODULE:
        case JJTLIBRARYMODULE:
        case JJTNAMESPACEDECL:
        case JJTCOPYNAMESPACESDECL:
        case JJTMODULEIMPORT:
        case JJTPARAMLIST:
        case JJTPARAM:
        case JJTQUERYBODY:
        case JJTVOID:
        case JJTWHERECLAUSE:
        case JJTORDERBYCLAUSE:
        case JJTPRAGMACONTENTS:
        case JJTFORWARDAXIS:
        case JJTABBREVFORWARDSTEP:
        case JJTREVERSEAXIS:
        case JJTABBREVREVERSESTEP:
        case JJTTYPEDECLARATION:
        case JJTATTRIBUTEDECLARATION:
        case JJTELEMENTTEST:
        case JJTELEMENTDECLARATION:
            pushElem(id, node);
            break;

        case JJTSCHEMAATTRIBUTETEST:
        {
           /* Parse tree is:
            * |                           SchemaAttributeTest
            * |                              AttributeDeclaration
            * |                                 AttributeName
            * |                                    QName foo
            */

            SimpleNode qn = sn(sn(sn(node.jjtGetChild(0)).jjtGetChild(0)).jjtGetChild(0));
            pushElem("xqx:schemaAttributeTest", node);
            String qname = processPrefix(qn.m_value);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);
            return check(node);
         }


        case JJTSCHEMAELEMENTTEST:
        {
           /* Parse tree is:
            * |                           SchemaElementTest
            * |                              ElementDeclaration
            * |                                 ElementName
            * |                                    QName notDeclared:ncname
            */

            SimpleNode qn = sn(sn(sn(node.jjtGetChild(0)).jjtGetChild(0)).jjtGetChild(0));
            pushElem("xqx:schemaElementTest", node);
            String qname = processPrefix(qn.m_value);
            flushOpen(node, false);
            xqprint(qname);
            flushClose(node, false);
            return check(node);
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

            pushElem(id, node);
            flushOpen(node, true);
            SimpleNode ncname = sn(node.jjtGetChild(0));
            pushElem("xqx:prefix", ncname);
            flushOpen(ncname, false);
            xqprint(ncname.m_value);
            flushClose(ncname, false);
            transformChildren(node, 1, 1);
            flushClose(node);
            return check(node);
        }


        case JJTPRAGMA:
            pushElem(id, node);
            flushOpen(node, true);
            transformChildren(node);
            if(!hasChildID(node, JJTPRAGMACONTENTS)){
                pushElem("xqx:pragmaContents", node);
                flushEmpty(node);
            }
            flushClose(node);
            return check(node);

        case JJTEXTENSIONCONTENTCHAR:
            transformChildren(node);
            return check(node);

        case JJTEXTENSIONEXPR:
        {
            pushElem(id, node);
            flushOpen(node, true);
            int n = node.jjtGetNumChildren();
            boolean foundArg = false;
            SimpleNode argNode = null;
            for (int i = 0; i < n; i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                if(foundArg == false && i == (n-2)) {
                    foundArg = true;
                    argNode = child;
                    if(argNode.jjtGetNumChildren() == 0)
                        continue;
                    pushElem("xqx:argExpr", argNode);
                    flushOpen(argNode, true);
                }
                transform(child);
                if(argNode != null && i == (n-2)) {
                    flushClose(argNode, true);
                }
            }
            flushClose(node, true);
        } return check(node);

        case JJTCONTEXTITEMEXPR:
            pushElem(id, node);
            break;

        case JJTVALIDATEEXPR: {
            pushElem(id, node);
            flushOpen(node, true);
            int n = node.jjtGetNumChildren();
            boolean foundArg = false;
            SimpleNode argNode = null;
            for (int i = 0; i < n; i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                if(foundArg == false && child.id != JJTVALIDATIONMODE) {
                    foundArg = true;
                    argNode = child;
                    pushElem("xqx:argExpr", argNode);
                    flushOpen(argNode, true);
                }
                transform(child);
            }
            flushClose(argNode, true);
            flushClose(node, true);
        } return check(node);

        case JJTVALIDATIONMODE:
            pushElem(id, node);
            flushOpen(node, false);
            xqprint(node.m_value);
            flushClose(node, false);
            return check(node);

        case JJTDEFAULTCOLLATIONDECL:
        case JJTEMPTYORDERDECL:
        case JJTTYPENAME:
        case JJTIMPORT:
        case JJTMINUS:
        case JJTPLUS:
        case JJTPREDICATE:
        case JJTOPENQUOT:
        case JJTCLOSEQUOT:
        case JJTOPENAPOS:
        case JJTCLOSEAPOS:
        case JJTQUOTATTRVALUECONTENT:
        case JJTAPOSATTRVALUECONTENT:
        case JJTVALUEINDICATOR:
        case JJTNODETEST:
        case JJTCOMMONCONTENT:
        case JJTENCLOSEDEXPR:
        case JJTLBRACE:
        case JJTLBRACEEXPRENCLOSURE:
        case JJTRBRACE:
        case JJTCONSTRUCTOR:
        case JJTDIRECTCONSTRUCTOR:
        case JJTSTARTTAGOPEN:
        case JJTEMPTYTAGCLOSE:
        case JJTSTARTTAGCLOSE:
        case JJTSEPARATOR:
        case JJTLESSTHANOPORTAGO:
        case JJTS:
        case JJTSFORPI:
            // Should be void probably!
            break;

        case JJTSETTER:
            checkDuplicateSetters(node);
            break;

        case JJTSFORPRAGMA:
            // Not so sure about this one.  So I'm
            // going to go ahead and print it for the time being.
            xqprint(node.m_value);
            break;

        case JJTPREDEFINEDENTITYREF:
            xqprint(node.m_value);
            break;

        case JJTCHARREF: {
            String ref = node.m_value;
            // What to do if this is invalid?
            xqprint(ref);
        }
            break;

        case JJTLCURLYBRACEESCAPE:
            // Bug fix for problem reported in Andrew Eisenberg mail to Scott
            // Boag 03/28/2006 02:36 PM
            // xqprint("{{");
            xqprint("{");
            break;

        case JJTRCURLYBRACEESCAPE:
            // Bug fix for problem reported in Andrew Eisenberg mail to Scott
            // Boag 03/28/2006 02:36 PM
            // xqprint("}}");
            xqprint("}");
            break;

        case JJTDIRCOMMENTCONSTRUCTOR:
            pushElem("xqx:computedCommentConstructor", node);
            break;

        case JJTDIRCOMMENTCONTENTS: {
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            pushElem("xqx:stringConstantExpr", node);
            flushOpen(node);
            pushElem("xqx:value", node);
            flushOpen(node, false);
            transformChildren(node);
            flushClose(node, false);
            flushClose(node);
            flushClose(node);
        }
            return check(node);

        case JJTCOMMENTCONTENTCHARDASH:
            xqprintEscaped(node.m_value, 'x', true);
            break;

        case JJTCOMMENTCONTENTCHAR:
        case JJTPICONTENTCHAR:
        case JJTCDATASECTIONCHAR:
            {
            String charStr = node.m_value;
            if (!charStr.equals("\r")) {
                if (node.id == JJTCDATASECTIONCHAR)
                   xqprint(charStr);
                else
                   xqprintEscaped(charStr, 'x', true);
            }
            else {
                SimpleNode sib = getNextSibling(node);
                if (sib == null
                    || sib.id != node.id
                    || !sib.m_value.equals("\n"))
                   xqprint("\n");
            }
            return check(node);
        }


        case JJTPROCESSINGINSTRUCTIONEND:
        case JJTPROCESSINGINSTRUCTIONSTARTFORELEMENTCONTENT:
        case JJTPROCESSINGINSTRUCTIONSTART:
        case JJTCDATASECTIONSTARTFORELEMENTCONTENT:
        case JJTCDATASECTIONCONTENTS:
        case JJTCDATASECTIONSTART:
        case JJTCDATASECTIONEND:
        case JJTXMLCOMMENTSTARTFORELEMENTCONTENT:
        case JJTXMLCOMMENTSTART:
        case JJTXMLCOMMENTEND:
            // Should probably be void!
            break;

        case JJTCDATASECTION: {
            pushElem("xqx:computedTextConstructor", node);
            flushOpen(node);
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            pushElem("xqx:stringConstantExpr", node);
            flushOpen(node);
            pushElem("xqx:value", node);
            flushOpen(node, false);
            xqprint("<![CDATA[");
            transformChildren(node);
            xqprint("]]>");
            flushClose(node, false);
            flushClose(node);
            flushClose(node);
            flushClose(node);
        }
            return check(node);

        case JJTDIRPICONTENTS:

            break;

        case JJTDIRPICONSTRUCTOR: {
            pushElem("xqx:computedPIConstructor", node);
            flushOpen(node);
            pushElem("xqx:piTarget", node);
            flushOpen(node, false);
            xqprint(sn(node.jjtGetChild(1)).m_value);
            flushClose(node, false);

            if (hasChildID(node, JJTDIRPICONTENTS)) {
                pushElem("xqx:piValueExpr", node);
                flushOpen(node);
                pushElem("xqx:stringConstantExpr", node);
                flushOpen(node);
                pushElem("xqx:value", node);
                flushOpen(node, false);
                transformChildren(node, 2);
                flushClose(node, false);
                flushClose(node);
                flushClose(node);
            }
            flushClose(node);
        }
            return check(node);

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
            pushElem(elemName, node);
            flushOpen(node);
            pushElem("xqx:argExpr", node);
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
            flushClose(node);
            return check(node);

        case JJTCOMPUTEDCONSTRUCTOR:
            // void
            break;

        case JJTCOMPPICONSTRUCTOR:
        case JJTCOMPATTRCONSTRUCTOR:
        case JJTCOMPELEMCONSTRUCTOR: {
            pushElem(
                    id == JJTCOMPATTRCONSTRUCTOR ? "xqx:computedAttributeConstructor"
                            : id == JJTCOMPPICONSTRUCTOR ? "xqx:computedPIConstructor"
                                    : "xqx:computedElementConstructor", node);
            flushOpen(node);
            int start = 0;
            if (getChildID(node, 0) == JJTLBRACEEXPRENCLOSURE) {
                if (id == JJTCOMPPICONSTRUCTOR)
                    pushElem("xqx:piTargetExpr", node);
                else
                    pushElem("xqx:tagNameExpr", node);
                flushOpen(node);
                transformChildren(node, 1, 1);
                flushClose(node);
                start += 3;
            } else {
                transformChildren(node, 0, 0);
                start++;
            }
            if (id == JJTCOMPATTRCONSTRUCTOR || id == JJTCOMPPICONSTRUCTOR) {
                pushElem(id == JJTCOMPATTRCONSTRUCTOR ? "xqx:valueExpr"
                        : "xqx:piValueExpr", node);
                flushOpen(node);
                if (getNumExprChildren(node, start) == 0) {
                    pushElem("xqx:sequenceExpr", node);
                    flushEmpty(node);
                } else
                    transformChildren(node, start);
                flushClose(node);

            } else
                transformChildren(node, start);

            flushClose(node);
        }
            return check(node);

        case JJTCONTENTEXPR:
            pushElem(id, node);
            break;

        case JJTDIRATTRIBUTELIST:
            if (getNumRealChildren(node) > 0) {
                pushElem("xqx:attributeList", node);
                flushOpen(node);

                int n = node.jjtGetNumChildren();
                for (int i = 0; i < n; i++) {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (child.id == JJTTAGQNAME) {
                        if (isNamespaceDecl(child))
                            pushElem("xqx:namespaceDeclaration", node);
                        else
                            pushElem("xqx:attributeConstructor", node);
                        flushOpen(node);
                    }
                    transform(child);
                    if (child.id == JJTDIRATTRIBUTEVALUE) {
                        flushClose(node);
                    }
                }
                flushClose(node);
            }
            return check(node);

        case JJTDIRELEMCONTENT:
            // if (isJustWhitespace(node))
            // return check(node);
            // pushElem("xqx:elementContent", node);
            if (getChildID(node, 0) == JJTELEMENTCONTENTCHAR) {
                String charStr = sn(node.jjtGetChild(0)).m_value;
                if (!charStr.equals("\r")) {
                   xqprintEscaped(charStr, 'x');
                }
                else {
                   SimpleNode sib = getNextSibling(node);
                   SimpleNode sibChild = null;
                   if (sib != null)
                      sibChild = sn(sib.jjtGetChild(0));
                   if (sib == null
                       || sib.id != JJTDIRELEMCONTENT
                       || sibChild == null
                       || sibChild.id != JJTELEMENTCONTENTCHAR
                       || !sibChild.m_value.equals("\n")) 
                      xqprint("\n");
                }
                return check(node);
            }
            break;

        case JJTDIRELEMCONSTRUCTOR: {
            pushElem("xqx:elementConstructor", node);
            flushOpen(node);
            int n = node.jjtGetNumChildren();
            boolean didFindDirElemContent = false;
            SimpleNode openChild = null;
            int nPush = 0;
            boolean didPushOpenXMLElem = false;
            try {
                for (int i = 0; i < n; i++) {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (child.id == JJTTAGQNAME){
                        _openXMLElemStack.push(child);
                        didPushOpenXMLElem = true;
                    }
                    else if (child.id == JJTDIRELEMCONTENT) {
                        // if (isJustWhitespace(child))
                        // continue;
                        if (didFindDirElemContent == false) {
                            pushElem("xqx:elementContent", node);
                            flushOpen(node);
                            didFindDirElemContent = true;
                        }
                        if (isEncloseExpr(child)) {
                            if (nPush == 2) {
                                flushClose(node, !isElemContentChar(openChild));
                                flushClose(node);
                            }
                            openChild = sn(sn(child.jjtGetChild(0)).jjtGetChild(0));
                            child = sn(sn(child.jjtGetChild(0)).jjtGetChild(0));
                            nPush = 0;

                        } else if (isElemContentChar(child)) {
                            if (child.id == JJTDIRELEMCONTENT
                                    && shouldStripChar(sn(child.jjtGetChild(0))))
                                continue;
                            if (!isElemContentChar(openChild)) {
                                pushElem("xqx:stringConstantExpr", node);
                                flushOpen(node);
                                pushElem("xqx:value", node);
                                flushOpen(node, false);
                                nPush = 2;
                            }
                            openChild = child;
                        } else {
                            if (nPush == 2) {
                                flushClose(node, !isElemContentChar(openChild));
                                flushClose(node);
                            }
                            openChild = child;
                            nPush = 0;
                        }

                    }
                    transform(child);

                }
            }
            finally {
                if(didPushOpenXMLElem)
                    _openXMLElemStack.pop();
            }

            if (nPush == 2) {
                flushClose(node, false);
                flushClose(node);
            }

            if (didFindDirElemContent){
                flushClose(node); // xqx:elementContent
            }

            flushClose(node); // xqx:elementConstructor
        }
            return check(node);

        case JJTDIRATTRIBUTEVALUE: {
            if (isJustWhitespace(node))
                return check(node);

            int n = node.jjtGetNumChildren();
            int isOpenMode = -1;
            boolean isAttributeValueExpr = false;
            for (int i = 0; i < n; i++) {
                SimpleNode child = sn(node.jjtGetChild(i));
                if (isEncloseExpr(child)) {
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
                    throw new RuntimeException(errMsg);
                } else
                    pushElem("xqx:attributeValueExpr", node);
                flushOpen(node);
                int nPush = 0;
                for (int i = 0; i < n; i++) {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (isEncloseExpr(child)) {
                        if (nPush == 2) {
                            flushClose(node, !isAttrContentChar(isOpenMode));
                            flushClose(node);
                        }
                        isOpenMode = sn(sn(child.jjtGetChild(0)).jjtGetChild(0)).id;
                        child = sn(sn(child.jjtGetChild(0)).jjtGetChild(0));
                        nPush = 0;

                    } else if (isAttrContentChar(child.id)) {
                        if (!isAttrContentChar(isOpenMode)) {
                            pushElem("xqx:stringConstantExpr", node);
                            flushOpen(node);
                            pushElem("xqx:value", node);
                            flushOpen(node, false);
                            nPush = 2;
                        }
                        isOpenMode = child.id;
                    } else if (child.id == JJTOPENQUOT
                            || child.id == JJTCLOSEQUOT
                            || child.id == JJTOPENAPOS
                            || child.id == JJTCLOSEAPOS) {
                        continue;
                    } else {
                        if (nPush == 2) {
                            flushClose(node, !isAttrContentChar(isOpenMode));
                            flushClose(node);
                        }
                        isOpenMode = child.id;
                        nPush = 0;
                    }
                    // xqprint(".");
                    boolean savedIsAttr = _isAttribute;
                    try{
                      _isAttribute = true;
                      transform(child);
                    }
                    finally{
                        _isAttribute = savedIsAttr;
                    }
                }
                if (nPush == 2) {
                    flushClose(node, false);
                    flushClose(node);
                }
                flushClose(node);
            } else {
                String val = getTagnameNodeFromAttributeValueNode(node).m_value;
                if (isNamespaceDecl(val))
                    pushElem("xqx:uri", node);
                else
                    pushElem("xqx:attributeValue", node);
                flushOpen(node, false);
                for (int i = 0; i < n; i++) {
                    SimpleNode child = sn(node.jjtGetChild(i));
                    if (child.id == JJTOPENQUOT || child.id == JJTCLOSEQUOT
                            || child.id == JJTOPENAPOS
                            || child.id == JJTCLOSEAPOS) {
                        continue;
                    }

                    // look for #0d #0a and normalize

                    SimpleNode grandChild = null;
                    if (child.jjtGetNumChildren() > 0) {
                       grandChild = sn(child.jjtGetChild(0));
                    }
                    SimpleNode sib = null;
                    SimpleNode sibChild = null;
                    if ((i + 1) < n) {
                       sib = sn(node.jjtGetChild(i + 1));
                    }
                    if (sib != null && sib.jjtGetNumChildren() > 0)
                       sibChild = sn(sib.jjtGetChild(0));

                    if (child.id == JJTQUOTATTRVALUECONTENT
                        && grandChild != null
                        && grandChild.id == JJTQUOTATTRCONTENTCHAR
                        && grandChild.m_value.equals("\r")
                        && sib != null
                        && sib.id == JJTQUOTATTRVALUECONTENT
                        && sibChild != null
                        && sibChild.id == JJTQUOTATTRCONTENTCHAR
                        && sibChild.m_value.equals("\n")) {
                       continue;
                    }

                    if (child.id == JJTAPOSATTRVALUECONTENT
                        && grandChild != null
                        && grandChild.id == JJTAPOSATTRCONTENTCHAR
                        && grandChild.m_value.equals("\r")
                        && sib != null
                        && sib.id == JJTAPOSATTRVALUECONTENT
                        && sibChild != null
                        && sibChild.id == JJTAPOSATTRCONTENTCHAR
                        && sibChild.m_value.equals("\n")) {
                       continue;
                    }

                    boolean savedIsAttr = _isAttribute;
                    try{
                      _isAttribute = true;
                      transform(child);
                    }
                    finally{
                      _isAttribute = savedIsAttr;
                    }
                }
                flushClose(node, false);
            }
        }
            return check(node);

        case JJTESCAPEQUOT:
            xqprint("\"");
            return check(node);

        case JJTESCAPEAPOS:
            xqprint("\'");
            return check(node);

        case JJTQUOTATTRCONTENTCHAR:
        case JJTAPOSATTRCONTENTCHAR:
            if (node.m_value != null) {
                boolean shouldSkip = false;
                SimpleNode charParent = (SimpleNode)node.jjtGetParent();
                SimpleNode nextSibling = getNextSibling(charParent);
                if(null != nextSibling && nextSibling.jjtGetNumChildren() == 1){
                    SimpleNode nextCharNode = (SimpleNode)nextSibling.jjtGetChild(0);
                    if(null != nextCharNode){
                        if(node.m_value.equals("\r")){
                            if(nextCharNode.equals("\n"))
                                shouldSkip = true;
                        }
                    }
                }
                if(node.m_value.equals("\r") && !shouldSkip)
                    node.m_value = "\n"; // normalization.
                if(!shouldSkip)
                    xqprintEscaped(node.m_value, 'x');
            }
            return check(node);

        case JJTELEMENTCONTENTCHAR:
            if (node.m_value != null) {
                xqprintEscaped(node.m_value, 'x');
            }
            return check(node);

        default:
            System.err.println("Unknown ID: "
                    + XPathTreeConstants.jjtNodeName[id]);
            break;
        }
        int n = node.jjtGetNumChildren();
        if (n == 0) {
            flushEmpty(node);
        } else {
            flushOpen(node);
            transformChildren(node);
            flushClose(node);
        }
        return check(node);
    }

    private void reorderProlog(SimpleNode prolog){
        int nChildren = prolog.jjtGetNumChildren();
        Node[] reorderedChildren = new Node[nChildren];
        int nChildrenAdded = 0;
        for (int i = 0; i < nChildren; i++) {
            SimpleNode child = sn(prolog.jjtGetChild(i));
            SimpleNode decl = (child.id == JJTSETTER) ?  sn(child.jjtGetChild(0)) : child;
            switch (decl.id) {
            case JJTDEFAULTCOLLATIONDECL:
            case JJTBASEURIDECL:
            case JJTCONSTRUCTIONDECL:
            case JJTORDERINGMODEDECL:
            case JJTEMPTYORDERDECL:
            case JJTCOPYNAMESPACESDECL:
            case JJTBOUNDARYSPACEDECL:
                reorderedChildren[nChildrenAdded] = child;
                nChildrenAdded++;
                reorderedChildren[nChildrenAdded] = sn(prolog.jjtGetChild(++i));  // JJTSEPARATOR
                nChildrenAdded++;
                break;
            }
        }
        for (int i = 0; i < nChildren; i++) {
            SimpleNode child = sn(prolog.jjtGetChild(i));
            SimpleNode decl = (child.id == JJTSETTER) ?  sn(child.jjtGetChild(0)) : child;
            switch (decl.id) {
            case JJTDEFAULTNAMESPACEDECL:
            case JJTNAMESPACEDECL:
            case JJTSCHEMAIMPORT:
            case JJTMODULEIMPORT:
            case JJTIMPORT:
                reorderedChildren[nChildrenAdded] = child;
                nChildrenAdded++;
                reorderedChildren[nChildrenAdded] = sn(prolog.jjtGetChild(++i));  // JJTSEPARATOR
                nChildrenAdded++;
                break;
            }
        }
        for (int i = 0; i < nChildren; i++) {
            SimpleNode child = sn(prolog.jjtGetChild(i));
            SimpleNode decl = (child.id == JJTSETTER) ?  sn(child.jjtGetChild(0)) : child;
            switch (decl.id) {
            case JJTVARDECL:
            case JJTFUNCTIONDECL:
            case JJTOPTIONDECL:
                reorderedChildren[nChildrenAdded] = child;
                nChildrenAdded++;
                reorderedChildren[nChildrenAdded] = sn(prolog.jjtGetChild(++i)); // JJTSEPARATOR
                nChildrenAdded++;
                break;
            }
        }
        if(nChildrenAdded != nChildren){
            throw new RuntimeException("Something failed in the prolog reorder!!!");
        }
        prolog.jjtSetChildren(reorderedChildren);
    }

    void checkDuplicateSetters(SimpleNode setter){
        SimpleNode setterChild = (SimpleNode)setter.jjtGetChild(0);
        int childID = setterChild.id;
        SimpleNode parent = (SimpleNode)setter.jjtGetParent();
        int numParentChildren = parent.jjtGetNumChildren();
        for (int j = 0; j < numParentChildren; j++) {
            SimpleNode setterCandidate = (SimpleNode)parent.jjtGetChild(j);
            if(setterCandidate != setter &&
                    setterCandidate.id == XPathTreeConstants.JJTSETTER &&
                    ((SimpleNode) setterCandidate.jjtGetChild(0)).id == childID){
                String errorCode;
                String errorMsg;
                if(childID == XPathTreeConstants.JJTBOUNDARYSPACEDECL) {
                    errorCode = "err:XQST0068";
                    errorMsg = "Prolog contains more than one boundary-space declaration.";
                }
                else if(childID == XPathTreeConstants.JJTDEFAULTCOLLATIONDECL) {
                    errorCode = "err:XQST0038";
                    errorMsg = "Prolog contains more than one default collation declaration, or the value specified by a default collation declaration is not present in statically known collations.";
                }
                else if(childID == XPathTreeConstants.JJTBASEURIDECL) {
                    errorCode = "err:XQST0032";
                    errorMsg = "Prolog contains more than one base URI declaration.";
                }
                else if(childID == XPathTreeConstants.JJTCONSTRUCTIONDECL) {
                    errorCode = "err:XQST0067";
                    errorMsg = "Prolog contains more than one construction declaration.";
                }
                else if(childID == XPathTreeConstants.JJTORDERINGMODEDECL) {
                    errorCode = "err:XQST0065";
                    errorMsg = "Prolog contains more than one ordering mode declaration.";
                }
                else if(childID == XPathTreeConstants.JJTEMPTYORDERDECL) {
                    errorCode = "err:XQST0069";
                    errorMsg = "Prolog contains more than one empty order declaration.";
                }
                else if(childID == XPathTreeConstants.JJTCOPYNAMESPACESDECL) {
                    errorCode = "err:XQST0055";
                    errorMsg = "Prolog contains more than one copy-namespaces declaration.";
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
    private SimpleNode getTagnameNodeFromAttributeValueNode(SimpleNode node) {
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
    private boolean isNamespaceDecl(SimpleNode child) {
        return child.m_value.startsWith("xmlns:")
                || child.m_value.equals("xmlns");
    }

    /**
     * @param child
     * @return
     */
    private boolean isNamespaceDecl(String val) {
        return val.startsWith("xmlns:")
                || val.equals("xmlns");
    }


    /**
     * @param node
     */
    private SimpleNode getNextSibling(SimpleNode node) {
        int nSiblingsOrSelf = node.jjtGetParent().jjtGetNumChildren();
        for (int i = 0; i < nSiblingsOrSelf; i++) {
            SimpleNode siblingOrSelf = sn(node.jjtGetParent().jjtGetChild(i));
            if (siblingOrSelf == node) {
                if ((i + 1) < nSiblingsOrSelf) {
                    return sn(node.jjtGetParent().jjtGetChild(i + 1));
                }
                break;
            }
        }
        return null;
    }

    /**
     * @param node
     */
    private SimpleNode getPreviousSibling(SimpleNode node) {
        int nSiblingsOrSelf = node.jjtGetParent().jjtGetNumChildren();
        for (int i = 0; i < nSiblingsOrSelf; i++) {
            SimpleNode siblingOrSelf = sn(node.jjtGetParent().jjtGetChild(i));
            if (siblingOrSelf == node) {
                if (i > 0)
                    return sn(node.jjtGetParent().jjtGetChild(i - 1));
                else
                    break;
            }
        }
        return null;
    }

    private boolean hasChildID(SimpleNode node, int id) {

        int n = node.jjtGetNumChildren();
        for (int i = 0; i < n; i++) {
            SimpleNode child = sn(node.jjtGetChild(i));
            if (child.id == id)
                return true;
        }
        return false;
    }

    private int getNumExprChildren(SimpleNode node) {
        return getNumExprChildren(node, 0);
    }

    private int getNumExprChildren(SimpleNode node, int start) {
        int count = 0;
        int n = node.jjtGetNumChildren();
        for (int i = start; i < n; i++) {
            SimpleNode child = sn(node.jjtGetChild(i));
            if (child.id != JJTS && child.id != JJTLBRACEEXPRENCLOSURE
                    && child.id != JJTRBRACE)
                count++;
        }
        return count;
    }

    private int getNumRealChildren(SimpleNode node) {
        int count = 0;
        int n = node.jjtGetNumChildren();
        for (int i = 0; i < n; i++) {
            SimpleNode child = sn(node.jjtGetChild(i));
            if (child.id != JJTS)
                count++;
        }
        return count;
    }

    /**
     * @param child
     * @return
     */
    private boolean isEncloseExpr(SimpleNode child) {
        return (child.id == JJTQUOTATTRVALUECONTENT
                || child.id == JJTAPOSATTRVALUECONTENT || child.id == JJTDIRELEMCONTENT)
                && sn(child.jjtGetChild(0)).id == JJTCOMMONCONTENT
                && sn(sn(child.jjtGetChild(0)).jjtGetChild(0)).id == JJTENCLOSEDEXPR;
    }

    /**
     * Tell if the node is it's parent last child.
     * @param n
     * @return
     */
    boolean isLastChild(Node n) {
        SimpleNode sm = (SimpleNode)n;
        SimpleNode parent = ((SimpleNode) sm.jjtGetParent());
        int count = parent.jjtGetNumChildren();
        Node lastChild = parent.jjtGetChild(count-1);
        return lastChild == sm;
    }

    /**
     * @param child
     * @return
     */
    private boolean isAttrContentChar(int id) {
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

    private boolean isFilterExpr(SimpleNode node) {
        int id = node.id;
        switch (id) {
        case JJTINTEGERLITERAL:
        case JJTDECIMALLITERAL:
        case JJTDOUBLELITERAL:
        case JJTSTRINGLITERAL:
        case JJTVARNAME:
        case JJTPARENTHESIZEDEXPR:
        case JJTCONTEXTITEMEXPR:
        case JJTFUNCTIONCALL:
        case JJTORDEREDEXPR:
        case JJTUNORDEREDEXPR:
        case JJTCONSTRUCTOR:
            return true;

        default:
            return false;
        }
    }

    private boolean isElemContentChar(SimpleNode node) {
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
     * @param qname
     * @return
     */
    private String processPrefix(String qname) {
        if (qname == null)
            return qname;
        int i = qname.indexOf(':');
        if (i > 0) {
            String prefix = qname.substring(0, i);
            qname = qname.substring(i + 1);
            pushAttr("xqx:prefix", prefix);
        }
        return qname;
    }

    private SimpleNode sn(Node node) {
        return (SimpleNode) node;
    }

    private void transformChildren(SimpleNode node, int start, int end) {
        // int n = node.jjtGetNumChildren();
        for (int i = start; i <= end; i++) {
            SimpleNode child = (SimpleNode) node.jjtGetChild(i);
            transform(child);
        }
    }

    private void transformChildren(SimpleNode node, int start) {
        transformChildren(node, start, node.jjtGetNumChildren() - 1);
    }

    private void transformChildren(SimpleNode node) {
        transformChildren(node, 0, node.jjtGetNumChildren() - 1);
    }

    /**
     * @param node
     * @return
     */
    private int getParentID(SimpleNode node) {
        return ((SimpleNode) node.jjtGetParent()).id;
    }

    /**
     * @param node
     * @return
     */
    private SimpleNode getFirstChildOfFirstChild(SimpleNode node) {
        if(((SimpleNode) node).jjtGetNumChildren() <= 0)
            return null;
        Node firstChild = node.jjtGetChild(0);
        if(((SimpleNode) firstChild).jjtGetNumChildren() <= 0)
            return null;
        return ((SimpleNode) firstChild.jjtGetChild(0));
    }


    /**
     * @param node
     * @return
     */
    private int getFirstChildOfFirstChildID(SimpleNode node) {
        if(((SimpleNode) node).jjtGetNumChildren() <= 0)
            return -1;
        Node firstChild = node.jjtGetChild(0);
        if(((SimpleNode) firstChild).jjtGetNumChildren() <= 0)
            return -1;
        return ((SimpleNode) firstChild.jjtGetChild(0)).id;
    }


    /**
     * @param node
     * @return
     */
    private int getChildID(SimpleNode node, int i) {
        if (i < ((SimpleNode) node).jjtGetNumChildren())
            return ((SimpleNode) node.jjtGetChild(i)).id;
        else
            return -1;
    }

//    /**
//     * @param node
//     * @return
//     */
//    private SimpleNode getFirstChildIgnoreS(SimpleNode node) {
//        for (int i = 0; i < node.jjtGetNumChildren(); i++) {
//            SimpleNode child = sn(node.jjtGetChild(i));
//            if (child.id != JJTS)
//                return sn(child);
//        }
//        return null;
//    }

}