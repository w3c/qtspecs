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

                    } else if ("-catalog".equalsIgnoreCase(arg)) {
                        String catalogFileName = args[argsStart];
                        argsStart++;
                        processW3CTestCatalog(catalogFileName);
                    } else {
                        processExprsInXmlFile(arg);
                    }
                } catch(PostParseException ppe) {
                    System.err.println("    "+ppe.getMessage());
                    return;
                }
                catch (Exception e) {
                    System.out.println("    "+e.getMessage());
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
    private void processW3CTestCatalog(String catalogFileName)
            throws ParserConfigurationException, SAXException, IOException {
        System.out.println("Running catalog for: " + catalogFileName);
        System.out.println("'i' means test parsed but XQueryX is invalid (test failed).");
        System.out.println("'x' means a parse error should have taken place (test failed).");
        System.out.println("'e' means a parse error took place but shouldn't have (test failed).");
        System.out.println("'v' means parse succeeded and XQueryX output was validated (test succeeds).");
        System.out.println("',' means parse error properly took place (test succeeds).");
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(catalogFileName);

        int nQueries = 0;
        FailureList failedToParse        = new FailureList("Should have parsed but raised an error");
        FailureList failedToRaiseError   = new FailureList("Should have raised a parse error but didn't");
        FailureList failedToFindFile     = new FailureList("Files not found");
        FailureList failedToConvertToXqx = new FailureList("Conversion to XQueryX failed");
        FailureList failedToValidateXqx  = new FailureList("XQueryX validation failed");
        boolean hadEnough = false;

        File catFile = new File(catalogFileName);
        String catDir = catFile.getParent();
        String xqFilePathCommonPrefix =
            catDir + File.separator
            + "Queries" + File.separator
            + "XQuery" + File.separator;

        NodeIterator testCases = getDescendantsNamed(doc, doc, "test-case");
        org.w3c.dom.Element testCase;
        while (((testCase = (org.w3c.dom.Element) testCases.nextNode()) != null)
                && !hadEnough) {

            String tcFilePath = testCase.getAttribute("FilePath").replace(
                    '/', File.separatorChar);

            String tcScenario = testCase.getAttribute("scenario");
            boolean tcExpectsParseError = tcScenario.equals("parse-error");

            NodeIterator queries = getDescendantsNamed(doc, testCase, "query");
            org.w3c.dom.Element query;
            while (((query = (org.w3c.dom.Element) queries.nextNode()) != null)
                    && !hadEnough) {

                String qName = query.getAttribute("name");
                String xqRelPath = tcFilePath + qName + ".xq";
                String xqFilePath = xqFilePathCommonPrefix + xqRelPath;

                if (dumpFormat != DUMP_NONE && (dumpFormat != DUMP_XQUERYX)) {
                    System.out.print("== ");
                    System.out.print(xqFilePath);
                    System.out.println(" ==");
                } else {
                    // System.out.print(".");
                }

                if ((nQueries % 30) == 0) {
                    System.out.println();
                    System.out.print( leftPad(Integer.toString(nQueries), 5, ' ') + "+  " );
                }

                nQueries++;

                SimpleNode tree = null;
                try {
                    // System.out.print(xqFilePath);
                    tree = parseFile(xqFilePath);
                    if (tcExpectsParseError) {
                        failedToRaiseError.add(xqRelPath);
                        System.out.print("x");
                        System.out.flush();
                    } else {
                        System.out.print(".");
                        System.out.flush();
                    }
                     //    System.out.println("ok");
                } catch (FileNotFoundException e) {
                    failedToFindFile.add(xqRelPath);
                    System.out.print("f");
                    System.out.flush();
                } catch (Throwable t) {
                    if (tcExpectsParseError || tcScenario.equals("runtime-error")) {
                        System.out.print(",");
                        System.out.flush();
                    } else {
                        failedToParse.add(xqRelPath);
                        System.out.print("e");
                        System.out.flush();
                    }
                }

                if (XQueryXOutputFilename == null && XQueryXOutputHierarchyRoot == null) continue;

                String xqueryxFilename = null;
                if (tree != null)
                {
                    try
                    {
                        // dump(tree);
                        if (XQueryXOutputHierarchyRoot != null)
                        {
                            String outputDirName =
                                XQueryXOutputHierarchyRoot + File.separatorChar + tcFilePath;
                            (new File(outputDirName)).mkdirs();
                            xqueryxFilename = outputDirName + qName + ".xqx";
                        }
                        else
                        {
                            xqueryxFilename = XQueryXOutputFilename;
                        }
                        convertXQueryToXQueryX(tree, null, xqueryxFilename);
                    }
                    catch (Throwable t)
                    {
                        failedToConvertToXqx.add(xqRelPath);
                        xqueryxFilename = null;
                    }
                }

                if ( !validateXQueryX ) continue;

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
                        failedToValidateXqx.add(xqRelPath);
                        if (maxInvalidXQueryX >= 0 && failedToValidateXqx.size() > maxInvalidXQueryX) {
                            System.out.println("\n\nAborting due to more than " + maxInvalidXQueryX + " invalid XQueryX conversions");
                            System.out.flush();
                            hadEnough = true;
                            break; // from loop!
                        }
                    }
                }
            }
        }
        System.out.println();
        System.out.println("All filepaths shown below are relative to:");
        System.out.println("    " + xqFilePathCommonPrefix);
        System.out.println();
        failedToFindFile.show();
        failedToParse.show();
        failedToRaiseError.show();

        int nParseFailures = failedToParse.size() + failedToRaiseError.size();
        if (nParseFailures > 0) {
            System.out.print("Failed " + nParseFailures + " out of ");
        } else {
            System.out.print("Total Success!! ");
        }
        System.out.println(nQueries + " cases");

        failedToConvertToXqx.show();
        failedToValidateXqx.show();
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
                            && namespace.startsWith("http://www.w3.org/2005/02/query-test-");
                        return (nameMatches ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP);
                    }
                },
                true
            );
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
        dump(parseFile(filename));
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

    SimpleNode parseFile(String filename)
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
        InputStreamReader isr =
            (null == encoding)
            ? new InputStreamReader(fis)
            : new InputStreamReader(fis, encoding);
        XParser parser = new XParser(isr);
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
                System.err.println("\n   Skipping validation, because the XQueryX translation isn't in a file.");
                return;
            }
            if ( !validateXQueryX ) return;
            boolean isValid = validateXMLFile(XQueryXOutputFilename, errors);
            if (!isValid) {
                System.err.println("\n   XQueryX Translation is invalid!");
                for (int i = 0; i < errors.size(); i++) {
                    String msg = (String) errors.elementAt(i);
                    System.err.println(msg);
                }
            }
        }
    }

    private boolean thisPackageHasAnXQueryXConverter()
    {
        try
        {
            Class.forName("org.w3c.xqparser.XQueryXConverter");
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
                Class transformerClass = Class.forName("org.w3c.xqparser.XQueryXConverter");
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
            System.err.println("XQueryX translator not yet supported!");
            throw new RuntimeException(e);
            // e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (SecurityException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if(cause instanceof PostParseException)
                throw (RuntimeException)cause;
            else if(!cause.getMessage().startsWith("<err")){
                e.getCause().printStackTrace();
            }
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
            System.err.println("XML Validator class not found!");
            throw new RuntimeException(e);
            // e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (SecurityException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            e.getCause().printStackTrace();
            throw new RuntimeException(e);
        }
        return isValidDoc;
    }

}
// vim: sw=4 ts=4 expandtab
