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

/*
 * Credit and thanks to David Carlisle 2005.
 */
package org.w3c.xqparser;

import java.io.*;

/**
 * Utility class to convert from JavaCC-generated parser output to a XML
 * serialization.
 */
public class Xq2xml {

    private static int MAXCHAR = 0xFFFF;

    /**
     * Convert a SimpleNode tree to an XML Serialization.
     *
     * @param prefix
     *            String used for indent.
     * @param outWriter
     *            output destination for XML.
     * @param tree
     *            input tree root.
     */
    public static void convert(String prefix, PrintWriter outWriter,
            SimpleNode tree) {
        outWriter.println();
        outWriter.print(prefix + "<" + XPathTreeConstants.jjtNodeName[tree.id]
                + ">");
        if (tree.m_value != null) {
            outWriter.print("<data>");
            printEscaped(outWriter, tree.m_value);
            outWriter.print("</data>");

        }
        if (tree.children != null) {
            for (int i = 0; i < tree.children.length; ++i) {
                SimpleNode n = (SimpleNode) tree.children[i];
                if (n != null) {
                    convert(prefix + " ", outWriter, n);
                }
            }
            outWriter.println();
            outWriter.print(prefix);
        }
        outWriter.print("</" + XPathTreeConstants.jjtNodeName[tree.id] + ">");
    }

    /**
     * Convert an XPath/XQuery string to an XML Serialization.
     *
     * @param expr
     *            input expression.
     * @return XML serialization in the form of a string.
     * @throws UnsupportedEncodingException
     */
    public static String convert(String expr)
            throws UnsupportedEncodingException {

        Reader ir = new StringReader(expr);
        StringWriter w = new StringWriter();
        convert(ir, w);
        w.flush();
        String s = w.getBuffer().toString();
        return (s);
    }

    /**
     * Convert an XPath/XQuery file to an XML Serialization.
     *
     * @param file
     *            input file that contains the XPath/XQuery expression, assumes
     *            utf-8.
     * @return XML serialization in the form of a string.
     * @throws IOException
     * @throws UnsupportedEncodingException
     */
    public static String convert(File file) throws IOException,
            UnsupportedEncodingException {

        InputStream is = new FileInputStream(file);
        Reader ir = new InputStreamReader(is, "utf-8");

        ByteArrayOutputStream baos = new ByteArrayOutputStream(62 * 1024);
        Writer w = new OutputStreamWriter(baos, "utf-8");

        convert(ir, w);
        try {
            w.flush();
        } catch (IOException e) {
            // should never happen!
            e.printStackTrace();
        }
        String s = new String(baos.toByteArray());
        return (s);
    }

    /**
     * Convert an XPath/XQuery stream to an XML Serialization.
     *
     * @param reader
     *            input reader, handles encoding issues.
     * @param writer
     *            output writer, handles encoding issues.
     */
    public static void convert(Reader reader, Writer writer) {
        try {
            XPath parser = new XPath(reader);
            SimpleNode tree = parser.XPath2();
            if (null == tree)
                printErrorString(writer, "no data");
            else {
                PrintWriter ps = new PrintWriter(writer);
                // PrintStream ps = new PrintStream(baos);
                convert("", ps, tree);
            }
        } catch (Exception e) {
            printErrorString(writer, e.getMessage());
        } catch (Error err) {
            printErrorString(writer, err.getMessage());
        }

    }

    /**
     * Convert an XPath/XQuery stream to an XML Serialization.
     *
     * @param is
     *            input stream, assumed to be utf-8.
     * @param os
     *            output stream, assumed to be utf-8.
     * @throws UnsupportedEncodingException
     */
    public static void convert(InputStream is, OutputStream os)
            throws UnsupportedEncodingException {
        InputStreamReader ir = new InputStreamReader(is, "utf-8");
        OutputStreamWriter ow = new OutputStreamWriter(os, "utf-8");
        convert(ir, ow);
    }

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

    private static void printEscaped(PrintWriter ps, String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '<')
                ps.print("&lt;");
            else if (c == '>')
                ps.print("&gt;");
            else if (c == '&')
                ps.print("&amp;");
            else if (isUTF16Surrogate(c)) {
                char[] chars = s.toCharArray();
                int n = s.length();
                writeUTF16Surrogate(ps, c, chars, i, n - 1);
            } else if (!canConvert(c)) {
                ps.print("&#");
                ps.print(Integer.toString((int) c));
                ps.print(";");
            } else {
                ps.print(c);
                ;
            }
        }
    }

    private static void printErrorString(PrintWriter ps, String msg) {
        ps.print("<error><data>");
        printEscaped(ps, msg);
        ps.print("</data></error>");
    }

    private static void printErrorString(Writer w, String msg) {
        PrintWriter ps = new PrintWriter(w);
        printErrorString(ps, msg);
        ps.flush();
    }

    private static String getErrorString(String msg) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream(62 * 1024);
        PrintWriter ps = new PrintWriter(baos);
        printErrorString(ps, msg);
        ps.flush();
        String s = new String(baos.toByteArray());
        return s;
    }

}