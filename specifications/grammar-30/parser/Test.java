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
// ONLY EDIT THIS FILE IN THE GRAMMAR ROOT DIRECTORY!
// THE ONE IN THE ${spec}-src DIRECTORY IS A COPY!!!
package org.w3c.xqparser;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Vector;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.traversal.DocumentTraversal;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.NodeIterator;
import org.xml.sax.SAXException;

/**
 * Title: Description: Copyright: Copyright (c) 2001 Company:
 *
 * @author
 * @version 1.0
 */

public class Test {
    static final String language = "@language@";

    static final int DUMP_NONE = 1;

    static final int DUMP_AST = 2;

    static final int DUMP_XQUERYX = 3;

    static final int DUMP_AST_XML = 4;

    int dumpFormat;

    String XQueryXOutputFilename = null;
    String XQueryXOutputHierarchyRoot = null;
    boolean validateXQueryX = false;
    int maxInvalidXQueryX = -1;

    private static final String UTF_16_BE = "UTF-16BE"; //$NON-NLS-1$
    private static final String UTF_16_LE = "UTF-16LE"; //$NON-NLS-1$
    private static final String UTF_8 = "UTF-8"; //$NON-NLS-1$

    public static String parseEncoding(String filePath)
    {
       if (filePath == null || filePath.equals(""))
       {
           return null;
       }
       FileInputStream fileInstream = null;
       BufferedReader br = null;
       FileReader reader = null;
       try
       {
           // Check the BOM for UTF-16 encoding
           fileInstream = new FileInputStream(filePath);
           int byteOne = fileInstream.read();
           int byteTwo = fileInstream.read();
           if (byteOne == 0xFE && byteTwo == 0xFF)
           {
               // Big endian utf-16
               return UTF_16_BE;
           }
           if (byteOne == 0xFF && byteTwo == 0xFE)
           {
               // Little endian utf-16
               return UTF_16_LE;
           }
           int byteThree = fileInstream.read();
           if (byteOne == 0xEF && byteTwo == 0xBB && byteThree == 0xBF)
           {
               // UTF-8
               return UTF_8;
           }

           reader = new FileReader(filePath);
           br = new BufferedReader(reader);
           String text = br.readLine();
           int index = text.indexOf("encoding") + 8; //$NON-NLS-1$
           if (index > 7)
           {
               StringBuffer sub = new StringBuffer(text.substring(index).trim());
               if (sub.charAt(0) == '=')
               {
                   sub.deleteCharAt(0); //remove = from working string
                   String st =sub.toString().trim(); // remove whitespaces
                   if (st.charAt(0) == '"')
                   {
                       int qouteIndex = st.indexOf('"', 1);
                       if (qouteIndex > -1)
                       {
                           return st.substring(1, qouteIndex);
                       }
                   }
               }
           }
           return UTF_8;
       }
       catch(FileNotFoundException fne)
       {
           return null;
       }
       catch (IOException ioe)
       {
           return null;
       }
       finally
       {
           try
           {
               if (br != null)
               {
                   br.close();
               }
               if (reader != null)
               {
                   reader.close();
               }
               if (fileInstream != null)
               {
                   fileInstream.close();
               }
           }
           catch (IOException ex)
           {
               //ignore
           }
       }
    }


    public Test() {
    }

    public static void main(String[] args) {
        Test test = new Test();
        test.process(args);
    }

    public void process(String[] args) {
            boolean haveXQueryXConverter = thisPackageHasAnXQueryXConverter();
            int argsStart = 0;
            dumpFormat = DUMP_NONE;
            while (argsStart < args.length) {
                try {
                    String arg = args[argsStart];
                    argsStart++;

                    if (arg.equals("-dumptree")) {
                        dumpFormat = DUMP_AST;
                    } else if (arg.equals("-dumpxml")) {
                        dumpFormat = DUMP_AST_XML;
                    } else if (arg.equals("-xqueryx")) {
                        if (haveXQueryXConverter)
                            dumpFormat = DUMP_XQUERYX;
                        else
                            System.out.println("Ignoring arg '-xqueryx': this package does not have an XQueryX converter.");
                    }
                    else if ("-xqueryxfile".equalsIgnoreCase(arg)) {
                        if (haveXQueryXConverter)
                        {
                            XQueryXOutputFilename = args[argsStart];
                            XQueryXOutputHierarchyRoot = null;
                            dumpFormat = DUMP_XQUERYX;
                        }
                        else
                        {
                            System.out.println("Ignoring arg '-xqueryxfile': this package does not have an XQueryX converter.");
                        }
                        argsStart++;
                    } else if (arg.equalsIgnoreCase("-XQueryXOutputHierarchyRoot")) {
                        if (haveXQueryXConverter)
                        {
                            XQueryXOutputHierarchyRoot = args[argsStart];
                            XQueryXOutputFilename = null;
                            dumpFormat = DUMP_XQUERYX;
                        }
                        else
                        {
                            System.out.println("Ignoring arg '-XQueryXOutputHierarchyRoot': this package does not have an XQueryX converter.");
                        }
                        argsStart++;
                    } else if (arg.equalsIgnoreCase("-validateXQueryX")) {
                        if (haveXQueryXConverter)
                            validateXQueryX = true;
                        else
                            System.out.println("Ignoring arg '-validateXQueryX': this package does not have an XQueryX converter.");
                    } else if (arg.equalsIgnoreCase("-maxInvalidXQueryX")) {
                        if (haveXQueryXConverter)
                            maxInvalidXQueryX = Integer.parseInt(args[argsStart]);
                        else
                            // ignore args[argsStart]
                            System.out.println("Ignoring arg '-maxInvalidXQueryX': this package does not have an XQueryX converter.");
                        argsStart++;

                    } else if ("-file".equalsIgnoreCase(arg)) {
                        String filename = args[argsStart];
                        argsStart++;
                        processFile(filename);
                    } else if (arg.endsWith(".xquery")) {
                        processFile(arg);
                    } else if ("-expr".equalsIgnoreCase(arg)) {
                        String expression = args[argsStart];
                        argsStart++;
                        processString(expression);

                    } else if ("-catalog1".equalsIgnoreCase(arg)) {
                        String catalogFileName = args[argsStart];
                        argsStart++;
                        processW3CTestCatalogV1(catalogFileName);
                    } else if ("-catalog3".equalsIgnoreCase(arg)) {
                        String catalogFileName = args[argsStart];
                        argsStart++;
                        processW3CTestCatalogV3(catalogFileName);
                    } else {
                        processExprsInXmlFile(arg);
                    }
                } catch(TokenMgrError tme) {
                    System.out.println("    "+tme.getMessage());
                } catch(ParseException pe) {
                    System.out.println("    "+pe.getMessage());
                } catch(PostParseException ppe) {
                    System.out.println("    "+ppe.getMessage());
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
    }

    void processExprsInXmlFile(String filename)
        throws ParserConfigurationException, IOException, SAXException
    {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(filename);
        Element tests = doc.getDocumentElement();
        NodeList testElems = tests.getChildNodes();
        int nChildren = testElems.getLength();
        int testid = 0;
        for (int i = 0; i < nChildren; i++)
        {
            org.w3c.dom.Node node = testElems.item(i);
            if (org.w3c.dom.Node.ELEMENT_NODE == node.getNodeType())
            {
                testid++;
                String xpathString = ((Element) node).getAttribute("value");
                if (dumpFormat != DUMP_NONE)
                    System.out.println("  Test[" + testid + "]: " + xpathString);
                else
                {
                    System.out.print("[" + testid + "]");
                    System.out.flush();
                    // hmm... there must be a cool mathmatical way
                    // to calculate!
                    if (testid < 20) {
                        if ((testid % 18) == 0)
                            System.out.println();
                    } else if (testid < 114) {
                        if ((testid % 14) == 0)
                            System.out.println();
                    } else if (testid < 1000) {
                        if ((testid % 12) == 0)
                            System.out.println();
                    } else if ((testid % 10) == 0)
                        System.out.println();
                }

                try
                {
                    dump(parseString(xpathString));
                }
                catch (TokenMgrError e)
                {
                    System.out.println(e.getMessage());
                }
                catch (ParseException e)
                {
                    System.out.println( "parse error (" + getFirstLine(e.getMessage()) + ")" );
                }
            }
        }
        System.out.println();
        if (dumpFormat != DUMP_XQUERYX)
            System.out.println("End of file.");
        System.out.flush();
    }

    String getFirstLine(String s)
    {
        String eol = System.getProperty("line.separator", "\n");
        int indexOfFirstEOL = s.indexOf(eol);
        return
            (indexOfFirstEOL == -1)
            ? s
            : s.substring(0, indexOfFirstEOL);
    }

    /**
     * @param catalogFileName
     * @throws ParserConfigurationException
     * @throws SAXException
     * @throws IOException
     */
    private void processW3CTestCatalogV1(String catalogFileName)
            throws ParserConfigurationException, SAXException, IOException {
        System.out.println("Running catalog for: " + catalogFileName);

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(catalogFileName);

        File catFile = new File(catalogFileName);
        String catDir = catFile.getParent();
        String xqFilePathCommonPrefix =
            catDir + File.separator
            + "Queries" + File.separator
            + "XQuery" + File.separator;

        SuiteFilesHandler sfh = new SuiteFilesHandler(xqFilePathCommonPrefix);

        try {
            NodeIterator testGroups = getDescendantsNamed(doc, doc, "test-group");
            org.w3c.dom.Element testGroup;
            while ((testGroup = (org.w3c.dom.Element) testGroups.nextNode()) != null)
            {
                String groupName = testGroup.getAttribute("name");
                sfh.groupStart(groupName);

                // We only want the test-cases that are within 'testGroup'
                // and not within another test-group within 'testGroup'.
                // (so we can't use getDescendantsNamed(..., "test-case"))
                // These are schema-guaranteed to be children of 'testGroup'.
                org.w3c.dom.Node tgChild;
                for (tgChild = testGroup.getFirstChild(); tgChild != null; tgChild = tgChild.getNextSibling())
                {
                    if (!tgChild.getNodeName().equals("test-case")) continue;

                    Element testCase = (Element)tgChild;

                    if (language.startsWith("xpath"))
                    {
                        // At first glance, you might think that the test-case attribute
                        //     is-XPath2="true"
                        // means that the test-case's query (minus the customization
                        // section) is a valid XPath2 expression, and
                        //     is-XPath2="false"
                        // means it isn't. However, it's not that simple. Instead,
                        //     is-XPath2="true"
                        // appears to mean that the test-case (minus etc) has the same
                        // expected behaviour for an XPath 2.0 processor as it does for
                        // an XQuery 1.0 processor. (Or perhaps that the expected
                        // outcomes for XPath 2.0 are a subset of those for XQuery 1.0.)
                        // And
                        //     is-XPath2="false"
                        // means (usually) that it doesn't have the same behaviour.
                        // Unfortunately, the latter doesn't really give us enough
                        // information to deduce what its expected behavior *is*.
                        //
                        // So, until the catalog gets better XPath-related info, we
                        // skip test-cases marked is-XPath2="false".

                        String isXPath2 = testCase.getAttribute("is-XPath2");
                        if (isXPath2.equals("false") || isXPath2.equals(""))
                            continue;
                    }

                    String tcName = testCase.getAttribute("name");

                    String tcFilePath = testCase.getAttribute("FilePath").replace(
                            '/', File.separatorChar);

                    NodeIterator queries = getDescendantsNamed(doc, testCase, "query");
                    org.w3c.dom.Element query;
                    while ((query = (org.w3c.dom.Element) queries.nextNode()) != null) {

                        // Okay, we have a query, so we could try to parse it (etc),
                        // except that we need to be able to tell sfh.handleQueryFile()
                        // what to expect. That information is provided by the <query>
                        // element's later siblings.

                        boolean qExpectsParseError = false;

                        org.w3c.dom.Node qSib;
                        for (qSib = query.getNextSibling(); qSib != null; qSib = qSib.getNextSibling())
                        {
                            if (qSib.getNodeType() != org.w3c.dom.Node.ELEMENT_NODE) continue;

                            String specVersion = ((Element)qSib).getAttribute("spec-version");
                            boolean isRelevant = (
                                specVersion.equals("")
                                ||
                                specVersion.equals("1.0") && (language.startsWith("xquery10") || language.startsWith("xpath"))
                                ||
                                specVersion.equals("1.1") && language.startsWith("xquery30")
                                ||
                                specVersion.equals("3.0") && language.startsWith("xquery30")
                            );
                            if (!isRelevant) continue;

                            String qSibName = qSib.getNodeName();
                            if (qSibName.equals("input-query"))
                            {
                                String inputQueryName = ((Element)qSib).getAttribute("name");
                                sfh.handleQueryFile(tcFilePath + inputQueryName + ".xq", false, false);
                            }
                            else if (qSibName.equals("expected-error"))
                            {
                                String errorCode = getTextContent((Element)qSib);
                                if (
                                    errorCode.equals("XPST0003")
                                    // [Input is not a valid instance of the grammar.]
                                    // parseFile() should throw a TokenMgrError or ParseException.
                                    ||
                                    errorCode.equals("XQST0090")
                                    // [Character reference does not identify a valid character.]
                                    // parseFile() should throw a ParseException from checkCharRef().
                                    ||
                                    errorCode.equals("*")
                                    // [any error code is acceptable]
                                    // That isn't enough information to know what to expect from parseFile().
                                    // So we hard-code the knowledge of which such cases should result in an
                                    // error from parseFile().
                                    && (
                                        language.startsWith("xpath") &&
                                            (  tcName.equals("K2-Literals-35")
                                            || tcName.equals("K2-Literals-36")
                                            || tcName.equals("K2-ErrorFunc-2")
                                            )
                                        // We don't need a similar condition for xquery,
                                        // because all queries with expected-error='*'
                                        // are syntactically valid for an XQuery processor.
                                    )

                                    ||
                                    (tcName.startsWith("eqname-") || tcName.startsWith("switch-"))
                                    && language.startsWith("xquery10")
                                    // These test-cases (in XQTS) use syntax (EQName or SwitchExpr) that
                                    // doesn't exist in XQuery 1.0, so parseFile() should certainly
                                    // throw an exception.
                                    // (You might think these test-cases would have an expected-error
                                    // of XPST0003 (for spec-verion="1.0"), but they only have XQST0031
                                    // [version number in a version declaration is not supported],
                                    // which parseFile() doesn't detect, which is why we have to
                                    // special-case them here.)
                                )
                                    qExpectsParseError = true;
                            }
                        }

                        String qName = query.getAttribute("name");
                        String xqRelPath = tcFilePath + qName + ".xq";
                        sfh.handleQueryFile(xqRelPath, qExpectsParseError, false);

                        String qStaticName = query.getAttribute("static-name");
                        if (!qStaticName.equals(""))
                        {
                            sfh.handleQueryFile(tcFilePath + qStaticName + ".xq", false, false);
                        }
                    }
                }
            }
        }
        catch (TooManyProblems tmp)
        {
            System.out.println("\n\nAborting processing of the catalog due to an unusually large number of problems:");
            System.out.println(tmp.getMessage());
        }

        sfh.report();
    }

    private void processW3CTestCatalogV3(String catalogFileName)
            throws ParserConfigurationException, SAXException, IOException
    {
        System.out.println("Running catalog for: " + catalogFileName);

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document catalog_doc = db.parse(catalogFileName);

        File catalogFile = new File(catalogFileName);
        String catalogDir = catalogFile.getParent();

        SuiteFilesHandler sfh = new SuiteFilesHandler(catalogDir + File.separator);

        try
        {
            NodeIterator testsets = getDescendantsNamed(catalog_doc, catalog_doc, "test-set");
            org.w3c.dom.Element testset_ref;
            while ((testset_ref = (org.w3c.dom.Element) testsets.nextNode()) != null)
            {
                String testset_name = testset_ref.getAttribute("name");
                sfh.groupStart(testset_name);

                String testset_file_relpath = testset_ref.getAttribute("file");
                String testset_file_abspath = catalogDir + File.separator + testset_file_relpath;
                String testset_file_parentdir_relpath = (new File(testset_file_relpath)).getParent();
                assert testset_file_relpath.endsWith(".xml");
                String testset_dir_relpath = testset_file_relpath.substring(0, testset_file_relpath.length()-4);

                Document testset_doc = db.parse(testset_file_abspath);

                Element testset = getChildNamed(testset_doc, "test-set");
                if (!satisfies_dependencies(testset))
                {
                    // This "implementation" does not satisfy the <test-set>'s <dependency>s.
                    // So skip it.
                    sfh.skipGroup();
                    continue;
                }

                NodeIterator test_cases = getDescendantsNamed(testset_doc, testset_doc, "test-case");
                org.w3c.dom.Element test_case;
                while ((test_case = (org.w3c.dom.Element) test_cases.nextNode()) != null)
                {
                    String tc_name = test_case.getAttribute("name");
                    // System.out.println(tc_name);

                    if (!satisfies_dependencies(test_case))
                    {
                        // This "implementation" does not satisfy
                        // the <test-case>'s <dependency>s.
                        // So skip it.
                        sfh.handleQuerySkip();
                        continue;
                    }

                    boolean expectParseError = false;
                    boolean expectConvertError = false;
                    Element result = getChildNamed(test_case, "result");
                    NodeIterator errors = getDescendantsNamed(testset_doc, result, "error");
                    Element expected_error;
                    while ((expected_error = (Element) errors.nextNode()) != null)
                    {
                        String error_code = expected_error.getAttribute("code");
                        if (
                            error_code.equals("XPST0003")
                            // [Input is not a valid instance of the grammar.]
                            // parseFile() should throw a TokenMgrError or ParseException.
                            ||
                            error_code.equals("XQST0090")
                            // [Character reference does not identify a valid character.]
                            // parseFile() should throw a ParseException from checkCharRef().
                            ||
                            error_code.equals("XQST0118")
                            // [In a direct element constructor, the name used in the end tag
                            // must exactly match the name used in the corresponding start tag,
                            // including its prefix or absence of a prefix.]
                            // parseFile() should throw a ParseException from DirElemConstructor().
                        )
                        {
                            expectParseError = true;
                        }
                        else if (
                            error_code.equals("XQST0022")
                            // [It is a static error if the value of a namespace
                            // declaration attribute is not a URILiteral.]
                            // convertXQueryToXQueryX() should throw a
                            // PostParseException in transformNode(),
                            // under JJTDIRATTRIBUTEVALUE.
                            ||
                            error_code.equals("XQST0068")
                            // [A static error is raised if a Prolog contains
                            // more than one boundary-space declaration.]
                            // convertXQueryToXQueryX() should throw a
                            // PostParseException in checkDuplicateSetters().
                        )
                        {
                            expectConvertError = true;
                        }
                    }

                    String xqx_file_relpath = testset_dir_relpath + File.separator + tc_name + ".xqx";

                    Element test = getChildNamed(test_case, "test");
                    String file_attr = test.getAttribute("file");
                    if (file_attr.equals(""))
                    {
                        // The usual case
                        String test_string = getTextContent(test);
                        // System.out.println(test_string);
                        String tc_locator = testset_file_relpath + "#" + tc_name;
                        sfh.handleQueryString(test_string, tc_locator, xqx_file_relpath, expectParseError, expectConvertError);
                    }
                    else
                    {
                        assert test.getChildNodes().getLength() == 0;
                        String test_relpath = testset_file_parentdir_relpath + File.separator + file_attr;
                        sfh.handleQueryFile(test_relpath, expectParseError, expectConvertError);
                    }
                }
            }
        }
        catch (TooManyProblems tmp)
        {
            System.out.println("\n\nAborting processing of the catalog due to an unusually large number of problems:");
            System.out.println(tmp.getMessage());
        }

        sfh.report();
    }

    static boolean satisfies_dependencies( Element e )
    // Return true iff this "implementation" satisfies
    // all the <dependency> children (if any) of e.
    {
        NodeList children = e.getChildNodes();
        for (int i = 0; i < children.getLength(); i++)
        {
            org.w3c.dom.Node child = children.item(i);   
            if (child.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE
                &&
                child.getNodeName().equals("dependency")
            )
            {
                Element dependency = (Element) child;
                String  dep_type   =  dependency.getAttribute("type");
                String  dep_value  =  dependency.getAttribute("value");
                boolean dep_sat    = !dependency.getAttribute("satisfied").equals("false");
                boolean type_value_pair_is_satisfied;

                if (dep_type.equals("spec"))
                {
                    String sat_value;
                    if (language.startsWith("xpath20"))
                    {
                        sat_value = "XP20 XP20+";
                    }
                    else if (language.startsWith("xpath30"))
                    {
                        sat_value = "XP20+ XP30 XP30+";
                    }
                    else if (language.startsWith("xpath31"))
                    {
                        sat_value = "XP20+ XP30+ XP31 XP31+";
                    }
                    else if (language.startsWith("xquery10"))
                    {
                        sat_value = "XQ10 XQ10+";
                    }
                    else if (language.startsWith("xquery30"))
                    {
                        sat_value = "XQ10+ XQ30 XQ30+";
                    }
                    else if (language.startsWith("xquery31"))
                    {
                        sat_value = "XQ10+ XQ30+ XQ31 XQ31+";
                    }
                    else
                    {
                        assert false;
                        sat_value = "";
                    }

                    // The <dependency>'s type/value pair is satisfied iff
                    // there's some token that is in both the dep_value and sat_value.
                    type_value_pair_is_satisfied = some_token_in_common(dep_value, sat_value);
                }
                else if (dep_type.equals("feature"))
                {
                    if (dep_value.equals("namespace-axis"))
                    {
                        // XQuery does not support the namespace axis.
                        type_value_pair_is_satisfied = !language.startsWith("xquery");
                    }
                    else
                    {
                        // This feature probably isn't pertinent to parsing, so ignore it.
                        continue;
                    }
                }
                else
                {
                    // This dependency probably isn't pertinent to parsing, so ignore it.
                    continue;
                }

                // The <dependency> is satisfied iff:
                // the type/value pair is satisfied and @satisfied is unset or "true"
                // OR
                // the type/value pair is not satisfied and @satified is "false"

                if (type_value_pair_is_satisfied == dep_sat)
                {
                    // Yay, the <dependency> is satisfied.
                    // But we can't just return true, because
                    // there might be more <dependency>s...
                }
                else
                {
                    // This <dependency> isn't satisfied,
                    // so they can't all be.
                    return false;
                }
            }
        }
        // No unsatisfied dependencies!
        return true;
    }

    static boolean some_token_in_common( String s1, String s2 )
    {
        String[] tokens1 = s1.trim().split("\\s+");
        String[] tokens2 = s2.trim().split("\\s+");
        for (int i1 = 0; i1 < tokens1.length; i1++)
        {
            String token1 = tokens1[i1];
            for (int i2 = 0; i2 < tokens2.length; i2++)
            {
                String token2 = tokens2[i2];
                if (token1.equals(token2))
                {
                    return true;
                }
            }
        }
        return false;
    }

    static Element getChildNamed(org.w3c.dom.Node parent, String child_name)
    {
        assert parent.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE
            || parent.getNodeType() == org.w3c.dom.Node.DOCUMENT_NODE;
        Element result = null;
        NodeList children = parent.getChildNodes();
        int nChildren = children.getLength();
        for (int i = 0; i < nChildren; i++)
        {
            org.w3c.dom.Node child = children.item(i);
            if (child.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE
                &&
                child.getNodeName().equals(child_name)
            )
            {
                assert result == null;
                result = (Element) child;
            }
        }

        assert result != null;
        return result;
    }

    NodeIterator getDescendantsNamed(Document doc, org.w3c.dom.Node base, final String localName)
    {
        return
            ((DocumentTraversal) doc).createNodeIterator(
                base,
                NodeFilter.SHOW_ELEMENT,
                new NodeFilter()
                {
                    public short acceptNode(org.w3c.dom.Node node)
                    {
                        String nm = node.getLocalName();
                        String namespace = node.getNamespaceURI();
                        boolean nameMatches =
                            nm.equals(localName)
                            && namespace != null
                            && (
                                namespace.startsWith("http://www.w3.org/2005/02/query-test-")
                                ||
                                namespace.equals("http://www.w3.org/2010/09/qt-fots-catalog")
                            );
                        return (nameMatches ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP);
                    }
                },
                true
            );
    }

    class SuiteFilesHandler
    {
        private String xqFilePathCommonPrefix;
        private int nFilesTotal;
        private int nFilesInThisGroup;

        private FailureList failedToParse;
        private FailureList failedToRaiseParseError;
        private FailureList failedToConvertToXqx;
        private FailureList failedToRaiseConvertError;
        private FailureList failedToValidateXqx;
        private FailureList failedOddlyInParse;
        private FailureList failedOddlyInConvert;

        public SuiteFilesHandler(String xqFilePathCommonPrefix)
        {
            this.xqFilePathCommonPrefix = xqFilePathCommonPrefix;

            nFilesTotal = 0;
            nFilesInThisGroup = 0;

            failedToParse        = new FailureList("Should have parsed but raised an error");
            failedToRaiseParseError   = new FailureList("Should have raised a parse error but didn't");
            failedToConvertToXqx = new FailureList("Conversion to XQueryX failed");
            failedToRaiseConvertError = new FailureList("Conversion to XQueryX should have raised an error, but didn't");
            failedToValidateXqx  = new FailureList("XQueryX validation failed");
            failedOddlyInParse   = new FailureList("Unanticipated exception occurred during parsing");
            failedOddlyInConvert = new FailureList("Unanticipated exception occurred during conversion to XQueryX");

            System.out.println("'i' means test parsed but XQueryX is invalid (test failed).");
            System.out.println("'x' means a parse error should have taken place (test failed).");
            System.out.println("'e' means a parse error took place but shouldn't have (test failed).");
            System.out.println("'v' means parse succeeded and XQueryX output was validated (test succeeds).");
            System.out.println("',' means parse error properly took place (test succeeds).");
        }

        public void groupStart( String groupName )
        {
            System.out.println();
            System.out.print(groupName + ":");
            nFilesInThisGroup = 0;
            // which, if there are any files in this group,
            // will cause a println() before any further output.
        }

        public void skipGroup()
        {
            assert nFilesInThisGroup == 0;
            System.out.println();
            System.out.print("    (_)");
        }

        public void handleQuerySkip()
        {
            incrementCounters();
            System.out.print("_");
            System.out.flush();
        }

        public void handleQueryFile(
                String xqRelPath,
                boolean expectParseError,
                boolean expectConvertError
        )
            throws TooManyProblems
        {
            String xqFilePath = xqFilePathCommonPrefix + xqRelPath;
            boolean suppressCustomizationSection = language.startsWith("xpath");

            SimpleNode parse_tree = null;
            Throwable parse_throwable = null;
            try {
                parse_tree = parseFile(xqFilePath, suppressCustomizationSection);
            } catch (Throwable t) {
                parse_throwable = t;
            }

            handleParseResult(
                xqRelPath,
                parse_tree,
                parse_throwable,
                expectParseError,
                xqRelPath + "x",
                expectConvertError
            );
        }

        public void handleQueryString(
                final String query_string,
                String query_locator,
                String xqx_file_relpath,
                boolean expectParseError,
                boolean expectConvertError
        )
            throws TooManyProblems
        {
            SimpleNode parse_tree = null;
            Throwable parse_throwable = null;
            try {
                parse_tree = parseString(query_string);
            } catch (Throwable t) {
                parse_throwable = t;
            }

            handleParseResult(
                query_locator,
                parse_tree,
                parse_throwable,
                expectParseError,
                xqx_file_relpath,
                expectConvertError
            );
        }

        private void handleParseResult(
            String query_locator,
            SimpleNode parse_tree,
            Throwable parse_throwable,
            boolean expectParseError,
            String xqx_file_relpath,
            boolean expectConvertError
        )
            throws TooManyProblems
        {
            if (dumpFormat != DUMP_NONE && (dumpFormat != DUMP_XQUERYX)) {
                System.out.print("== ");
                System.out.print(query_locator);
                System.out.println(" ==");
            } else {
                // System.out.print(".");
            }

            incrementCounters();

            if (parse_tree != null) {
                assert parse_throwable == null;
                if (expectParseError) {
                    failedToRaiseParseError.add(query_locator);
                    System.out.print("x");
                    System.out.flush();
                } else {
                    System.out.print(".");
                    System.out.flush();
                }
                 //    System.out.println("ok");
            } else {
                assert parse_throwable != null;
                if (
                    parse_throwable instanceof TokenMgrError
                    ||
                    parse_throwable instanceof ParseException
                )
                {
                    if (expectParseError) {
                        System.out.print(",");
                        System.out.flush();
                    } else {
                        failedToParse.add(query_locator);
                        System.out.print("e");
                        System.out.flush();
                    }
                }
                else
                {
                    // It looks like something went wrong in the lexer/parser.
                    // Call it a failure, regardless of what the test-case expected.
                    failedOddlyInParse.add(query_locator);
                    System.out.print("!");
                }
            }

            if (XQueryXOutputFilename == null && XQueryXOutputHierarchyRoot == null) return;

            String xqueryxFilename = null;
            if (parse_tree != null)
            {
                try
                {
                    // dump(parse_tree);
                    if (XQueryXOutputHierarchyRoot != null)
                    {
                        xqueryxFilename =
                            XQueryXOutputHierarchyRoot + File.separatorChar + xqx_file_relpath;
                        (new File(xqueryxFilename)).getParentFile().mkdirs();
                    }
                    else
                    {
                        xqueryxFilename = XQueryXOutputFilename;
                    }
                    convertXQueryToXQueryX(parse_tree, null, xqueryxFilename);
                    if (expectConvertError)
                    {
                        // We expected an error but didn't get it.
                        failedToRaiseConvertError.add(query_locator);
                    }
                    else
                    {
                        // We expected no error, and that's what we got.
                    }
                }
                catch (PostParseException ppe)
                {
                    if (expectConvertError)
                    {
                        // We got an error, as expected.
                    }
                    else
                    {
                        // We got an error that we didn't expect.
                        failedToConvertToXqx.add(query_locator);
                    }
                    xqueryxFilename = null;
                }
                catch (Throwable t)
                {
                    failedOddlyInConvert.add(query_locator);
                    xqueryxFilename = null;
                }
            }

            if ( !validateXQueryX ) return;

            if (xqueryxFilename != null)
            {
                boolean isValid;
                try
                {
                    isValid = validateXMLFile(xqueryxFilename, null);
                }
                catch (Throwable t)
                {
                    // We treat a call that raises an exception
                    // the same as a call that returns false.
                    isValid = false;
                }
                System.out.print(isValid ? "v" : "i");
                System.out.flush();
                if (!isValid) {
                    failedToValidateXqx.add(query_locator);
                    if (maxInvalidXQueryX >= 0 && failedToValidateXqx.size() > maxInvalidXQueryX) {
                        throw new TooManyProblems(
                            "More than " + maxInvalidXQueryX + " invalid XQueryX conversions");
                    }
                }
            }
        }

        private void incrementCounters()
        {
            if ((nFilesInThisGroup % 50) == 0) {
                System.out.println();
                System.out.print("  ");
                System.out.print( leftPad(Integer.toString(nFilesInThisGroup), 4, ' ') + "+  " );
            }

            nFilesTotal++;
            nFilesInThisGroup++;
        }

        public void report()
        {
            System.out.println();
            System.out.println("All filepaths shown below are relative to:");
            System.out.println("    " + xqFilePathCommonPrefix);
            System.out.println();
            failedOddlyInParse.show();
            failedToParse.show();
            failedToRaiseParseError.show();

            int nParseFailures = failedToParse.size() + failedToRaiseParseError.size();
            if (nParseFailures > 0) {
                System.out.print("Failed " + nParseFailures + " out of ");
            } else {
                System.out.print("Total Success!! ");
            }
            System.out.println(nFilesTotal + " cases");
            System.out.println();

            failedOddlyInConvert.show();
            failedToConvertToXqx.show();
            failedToRaiseConvertError.show();
            failedToValidateXqx.show();
        }
    }

    class FailureList
    {
        private String header;
        private Vector failures = new Vector();

        public FailureList(String header)
        {
            this.header = header;
        }

        public void add(String xqRelPath)
        {
            failures.addElement(xqRelPath);
        }

        public int size()
        {
            return failures.size();
        }

        public void show()
        {
            String indent = "    ";
            if (failures.size() > 0)
            {
                System.out.println(header + " (" + failures.size() + "):");
                for (int i = 0; i != failures.size(); i++)
                {
                    String fname = (String) failures.elementAt(i);
                    System.out.println(indent + fname);
                }
                System.out.println();
            }
        }
    }

    class TooManyProblems extends Exception
    {
        TooManyProblems(String msg)
        {
            super(msg);
        }
    }

    String leftPad( String s, int width, char padChar )
    {
        // Is there a better way to do this in Java 1.4?
        if (s.length() >= width)
            return s;
        else
            return leftPad( padChar + s, width, padChar );
    }

    void processFile(String filename)
        throws FileNotFoundException, IOException, UnsupportedEncodingException, ParseException
    {
        if (dumpFormat != DUMP_XQUERYX)
            System.out.println("Running test for: " + filename);
        dump(parseFile(filename, false));
        if (dumpFormat != DUMP_XQUERYX)
            System.out.println("Test successful!!!");
    }

    void processString(String str)
        throws ParseException
    {
        if (dumpFormat != DUMP_XQUERYX)
            System.out.println("Running test for: " + str);
        dump(parseString(str));
        if (dumpFormat != DUMP_XQUERYX)
            System.out.println("Test successful!!!");
    }

    SimpleNode parseFile(String filename, boolean suppressCustomizationSection)
        throws FileNotFoundException, IOException, UnsupportedEncodingException, ParseException
    {
        File file = new File(filename);
        String encoding = parseEncoding(file.getAbsolutePath());
        FileInputStream fis = new FileInputStream(file);
        if (encoding != null
            && (encoding.equals(UTF_16_BE) || encoding.equals(UTF_16_LE)))
        {
            fis.read();
            fis.read();
        }
        Reader reader =
            (null == encoding)
            ? new InputStreamReader(fis)
            : new InputStreamReader(fis, encoding);

        if (suppressCustomizationSection)
        {
            String original = readAll(reader);
            String tweaked = original.replaceFirst("(?s)\\(: *insert-start *:\\).*?\\(: *insert-end *:\\)", "");
            reader = new StringReader(tweaked);
        }

        XParser parser = new XParser(reader);
        SimpleNode tree = parser.START();
        return tree;
    }

    SimpleNode parseString(String str)
        throws ParseException
    {
        Reader reader = new StringReader(str);
        XParser parser = new XParser(reader);
        SimpleNode tree = parser.START();
        return tree;
    }

    void dump(SimpleNode tree) {
        if (dumpFormat == DUMP_AST) {
            tree.dump("|");
        }
        if (dumpFormat == DUMP_AST_XML) {
            try {
                PrintWriter systemOutWriter = new PrintWriter(
                        new OutputStreamWriter(System.out, "UTF-8"));
                Xq2xml.convert(" ", systemOutWriter, tree);
                systemOutWriter.flush();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        } else if (dumpFormat == DUMP_XQUERYX) {
            Vector errors = new Vector();
            convertXQueryToXQueryX(tree, System.out, XQueryXOutputFilename);
            if (XQueryXOutputFilename == null)
            {
                // Perhaps we don't need to print anything?
                System.out.println("\n   Skipping validation, because the XQueryX translation isn't in a file.");
                return;
            }
            if ( !validateXQueryX ) return;
            boolean isValid = validateXMLFile(XQueryXOutputFilename, errors);
            if (!isValid) {
                System.out.println("\n   XQueryX Translation is invalid!");
                for (int i = 0; i < errors.size(); i++) {
                    String msg = (String) errors.elementAt(i);
                    System.out.println(msg);
                }
            }
        }
    }

    private boolean thisPackageHasAnXQueryXConverter()
    {
        try
        {
            Class.forName("org.w3c.xqparser.ConversionController");
            return true;
        }
        catch (ClassNotFoundException e)
        {
            return false;
        }
    }

    private void convertXQueryToXQueryX(SimpleNode tree, PrintStream ps1, String xqueryxFilename)
    {
        // System.out.println("XQueryX translator not yet supported!");
        PrintStream ps2;
        try {
            {
                ps2 =
                    xqueryxFilename != null
                    ? new PrintStream(new FileOutputStream(xqueryxFilename))
                    : null;
                Class transformerClass = Class.forName("org.w3c.xqparser.ConversionController");
                Object transformer = transformerClass.newInstance();
                Class[] argTypes = { SimpleNode.class, PrintStream.class,
                        PrintStream.class };
                Method transformMethod = transformerClass.getMethod(
                        "transform", argTypes);
                Object[] args = { tree, ps1, ps2 };
                transformMethod.invoke(transformer, args);
                if (ps2 != null) ps2.close();
            }


        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        } catch(PostParseException ppe) {
            throw ppe;
        } catch (ClassNotFoundException e) {
            System.out.println("XQueryX translator not yet supported!");
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (SecurityException e) {
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if(cause instanceof PostParseException)
                throw (RuntimeException)cause;
            if(cause instanceof RuntimeException)
                throw (RuntimeException)cause;
            else
                throw new RuntimeException(cause);
        }
    }

    private boolean validateXMLFile(String xmlFilename, Vector errors)
    {
        boolean isValidDoc = false;
        try {
                Class validatorClass = Class.forName("org.w3c.xqparser.XMLValidator");
                Object validator = validatorClass.newInstance();
                Class[] argTypes = { String.class, Vector.class };
                Method validateXMLFileMethod = validatorClass.getMethod(
                        "validateXMLFile", argTypes);
                Object[] args = { xmlFilename, errors };
                Boolean isValid = (Boolean) validateXMLFileMethod.invoke(validator,
                        args);
                isValidDoc = isValid.booleanValue();

        } catch (ClassNotFoundException e) {
            System.out.println("XML Validator class not found!");
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (SecurityException e) {
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e);
        }
        return isValidDoc;
    }

    static String getTextContent( Element e )
    // 'e' must be an Element that is either empty or has text-only content.
    // Return a string containing its content.
    {
        // In the XDM, an Element with text-only content
        // would have exactly one child, a text node.
        // But in the DOM, such an element can have lots of children,
        // including Text nodes and also CDataSection nodes.

        NodeList children = e.getChildNodes();
        for (int i = 0; i < children.getLength(); i++)
        {
            org.w3c.dom.Node child = children.item(i);
            assert child.getNodeType() == org.w3c.dom.Node.TEXT_NODE
                || child.getNodeType() == org.w3c.dom.Node.CDATA_SECTION_NODE;
        }

        return e.getTextContent();
    }

    public static String readAll(Reader reader) throws IOException
    {
        StringBuffer sb = new StringBuffer(1024);
        reader = new BufferedReader(reader);
        char[] chars = new char[1024];
        try {
            int numRead;
            while ((numRead = reader.read(chars)) != -1) {
                sb.append(chars, 0, numRead);
            }
        } finally {
            reader.close();
        }
        return sb.toString();
    }

}
// vim: sw=4 ts=4 expandtab
