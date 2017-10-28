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

import java.io.PrintWriter;
import java.io.PrintStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.util.Stack;

public class XMLWriter
{
    protected Stack _openElemStack = new Stack();

    protected PrintWriter _pw1;

    protected PrintWriter _pw2;

    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    public void setOutputs_NoEncodingException(PrintStream ps1, PrintStream ps2)
    {
        try
        {
            setOutputs(ps1, ps2);
        }
        catch (UnsupportedEncodingException e)
        {
            _pw1 = (ps1 == null) ? null : new PrintWriter(ps1);
            _pw2 = (ps2 == null) ? null : new PrintWriter(ps2);
        }
    }

    public void setOutputs(PrintStream ps1, PrintStream ps2)
        throws UnsupportedEncodingException
    {
        _pw1 = _ps_to_pw(ps1, "utf-8");
        _pw2 = _ps_to_pw(ps2, "utf-8");
    }

    protected PrintWriter _ps_to_pw(PrintStream ps, String charsetName)
        throws UnsupportedEncodingException
    {
        if (ps == null) return null;

        return new PrintWriter(new OutputStreamWriter(ps, charsetName));
    }

    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    public void putXMLDecl()
    {
        putText("<?xml version=\"1.0\"?>\n");
    }

    public void putComment(String s)
    {
        _indent();
        putText("<!-- " + s + " -->\n");
    }

    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    public void putEmptyElement(Object check_obj, String xqx_element_name)
    {
        _indent();
        putText("<" + xqx_element_name + "/>\n");
    }

    public void putSimpleElement(Object check_obj, String xqx_element_name, String content)
    {
        putStartTag(check_obj, xqx_element_name, false);
        putTextEscaped(content);
        putEndTag(check_obj, false);
    }

    // -------------------------------------------------------------------------

    protected String[][] NO_ATTRIBUTES = {};

    public void putStartTag(Object check_obj, String xqx_element_name)
    {
        putStartTag(check_obj, xqx_element_name, NO_ATTRIBUTES, true);
    }

    public void putStartTag(Object check_obj, String xqx_element_name, boolean doLF)
    {
        putStartTag(check_obj, xqx_element_name, NO_ATTRIBUTES, doLF);
    }

    public void putStartTag(
        Object     check_obj,
        String     xqx_element_name,
        String[][] attributes,
        boolean    doLF)
    {
        _indent();
        putText("<" + xqx_element_name);

        for ( int i = 0; i < attributes.length; i++ )
        {
            if (i>0) putText("\n           ");
            String[] attribute = attributes[i];
            assert attribute.length == 2;
            String name = attribute[0];
            String value = attribute[1];
            putText(" " + name + "=\"" + value + "\"");
        }

        putText(">");
        if (doLF) putText("\n");

        // ---------

        _openElemStack.push(xqx_element_name);
        _openElemStack.push(check_obj);
    }

    // -------------------------------------------------------------------------

    public void putEndTag(Object check_obj)
    {
        putEndTag(check_obj, true);
    }

    public void putEndTag(Object check_obj, boolean doIndent)
    {
        if (_openElemStack.empty())
        {
            throw new RuntimeException(
                "putEndTag() was called for " + check_obj.toString()
                + " but there's no matching call to putStartTag()");
        }

        Object earlier_check_obj = _openElemStack.pop();
        if (check_obj != earlier_check_obj)
        {
            throw new RuntimeException(
                "putEndTag() was called for " + check_obj.toString()
                + " but the matching putStartTag() was called for " + earlier_check_obj.toString() );
        }

        String elemName = (String) _openElemStack.pop();

        // ---------

        if (doIndent) _indent();
        putText("</" + elemName + ">\n");
    }

    // -------------------------------------------------------------------------

    protected void _indent()
    {
        int indentAmount = _openElemStack.size();
        for (int i = 0; i < indentAmount; i++)
        {
            putText(" ");
        }
    }

    public int getDepthOfOpenElementStack()
    {
        // Each call to putStartTag() makes 2 calls to _openElemStack.push()
        // (and each putEndTag() does 2 pops), so divide the stack size by 2
        // to get an externally-meaningful number.
        return _openElemStack.size() / 2;
    }

    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    public void putTextEscaped(String s)
    {
        putTextEscaped(s, false);
    }

    public void putTextEscaped(String s, boolean escapeAmp)
    {
        int strLen = s.length();
        for (int i = 0; i < strLen; i++)
        {
            char c = s.charAt(i);
            if (c == '&')
            {
                if(!escapeAmp)
                    // Assume the parser has done its work.
                    putText(c);
                else
                    putText("&amp;");
            }
            else if (c == '<')
                putText("&lt;");
            else if (c == '>')
                putText("&gt;");
/*
            else if (_isUTF16Surrogate(c))
            {
                char[] chars = s.toCharArray();
                int n = s.length();
                if (_pw1 != null) _writeUTF16Surrogate(_pw1, c, chars, i, n - 1);
                if (_pw2 != null) _writeUTF16Surrogate(_pw2, c, chars, i, n - 1);
            }
            else if (!_canConvert(c))
            {
                _putDecimalCharRef((int) c);
            }
*/

            else if (_isUTF16Surrogate(c))
            {
                char[] chars = s.toCharArray();
                int n = s.length();
                _putDecimalCharRef(_getURF16SurrogateValue(c, chars, i++, n));
            }

            else if (c > '\u007F')
            {
                _putDecimalCharRef((int) c);
            }
            else if(c == 0x0D)
            {
                if (!((i + 1) < s.length() && s.charAt(i + 1) == 0x0A))
                {
                   putText("\n");
                }
            }
            else if (c == 0x0D || c == 0x85 || c == 0x2028)
            {
                _putDecimalCharRef((int) c);
            }
            else
            {
                putText(c);
            }
        }
    }

    protected void _putDecimalCharRef(int i)
    {
        putText("&#" + Integer.toString(i) + ";");
    }

    static final protected boolean _isUTF16Surrogate(char c)
    {
        return (c & 0xFC00) == 0xD800;
    }

    protected static void _writeUTF16Surrogate(
            PrintWriter pw,
            char c,
            char ch[],
            int  i,
            int  end)
    {
        int surrogateValue = _getURF16SurrogateValue(c, ch, i, end);

        pw.print('&');
        pw.print('#');

        pw.print(Integer.toString(surrogateValue));
        pw.print(';');
    }

    protected static int _getURF16SurrogateValue(char c, char ch[], int i, int end)
    {
        int next;

        if (i + 1 >= end)
        {
            throw new RuntimeException(
                "Invalid UTF-16 surrogate detected: "
                + Integer.toHexString((int) c));
        }
        else
        {
            next = ch[++i];

            if (!(0xdc00 <= next && next < 0xe000))
                throw new RuntimeException(
                    "Invalid UTF-16 surrogate detected: "
                    + Integer.toHexString((int) c));

            next = ((c - 0xd800) << 10) + next - 0xdc00 + 0x00010000;
        }

        return next;
    }

    /**
     * Tell if this character can be written without escaping. Needs more work.
     */
    protected static boolean _canConvert(char ch)
    {
        boolean isLegal =
                ch == 0x9 || ch == 0xA || ch == 0xD
                || (ch >= 0x20 && ch <= 0xD7FF)
                || (ch >= 0xE000 && ch <= 0xFFFD)
                || (ch >= 0x10000 && ch <= 0x10FFFF);
        if (!isLegal)
            throw new RuntimeException(
                "Characters MUST match the production for Char.");

        return (ch <= _MAXCHAR); // noop
    }

    protected static int _MAXCHAR = 0xFFFF;

    // -------------------------------------------------------------------------

    public void putText(String s)
    {
        if (_pw1 != null) _pw1.print(s);
        if (_pw2 != null) _pw2.print(s);
    }

    public void putText(char s)
    {
        if (_pw1 != null) _pw1.print(s);
        if (_pw2 != null) _pw2.print(s);
    }

    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    public void flush()
    {
        if (_pw1 != null) _pw1.flush();
        if (_pw2 != null) _pw2.flush();
    }

}
// vim: sw=4 ts=4 expandtab
