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

    PrintStream xqout1 = System.out;

    PrintStream xqout2;

    String XQueryXOutputFilename = null;

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
        try {
            int numberArgsLeft = args.length;
            int argsStart = 0;
            // boolean isMatchParser = false;
            int dumpFormat = DUMP_NONE;
            while (numberArgsLeft > 0) {
                try {

                    if (args[argsStart].equals("-dumptree")) {
                        argsStart++;
                        numberArgsLeft--;
                        dumpFormat = DUMP_AST;
                    } else if (args[argsStart].equals("-dumpxml")) {
                        argsStart++;
                        numberArgsLeft--;
                        dumpFormat = DUMP_AST_XML;
                    } else if (args[argsStart].equals("-xqueryx")) {
                        argsStart++;
                        numberArgsLeft--;
                        dumpFormat = DUMP_XQUERYX;
                    }
                    else if ("-xqueryxfile".equalsIgnoreCase(args[argsStart])) {
                        argsStart++;
                        numberArgsLeft--;
                        dumpFormat = DUMP_XQUERYX;
                        XQueryXOutputFilename = args[argsStart];
                        xqout2 = new PrintStream(new FileOutputStream(
                                XQueryXOutputFilename));
                        argsStart++;
                        numberArgsLeft--;
                    } else if (args[argsStart].equals("-match")) {
                        // isMatchParser = true;
                        System.out.println("Match Pattern Parser");
                        argsStart++;
                        numberArgsLeft--;
                    } else if ("-file".equalsIgnoreCase(args[argsStart])) {
                        argsStart++;
                        numberArgsLeft--;
                        if (dumpFormat != DUMP_XQUERYX)
                            System.out.println("Running test for: "
                                    + args[argsStart]);
                        File file = new File(args[argsStart]);
                        argsStart++;
                        numberArgsLeft--;
                        String encoding = parseEncoding(file.getAbsolutePath());
                        FileInputStream fis = new FileInputStream(file);
                        if (encoding != null
                                && (encoding.equals(UTF_16_BE) || encoding
                                        .equals(UTF_16_LE))) {
                            fis.read();
                            fis.read();
                        }
                        InputStreamReader isr = (null == encoding) ?
                                new InputStreamReader(fis)
                                : new InputStreamReader(fis, encoding);
                        XPath parser = new XPath(isr);
                        SimpleNode tree = parser.XPath2();
                        dump(tree, dumpFormat);
                    } else if (args[argsStart].endsWith(".xquery")) {
                        if (dumpFormat != DUMP_XQUERYX)
                            System.out.println("Running test for: "
                                    + args[argsStart]);
                        File file = new File(args[argsStart]);
                        argsStart++;
                        numberArgsLeft--;
                        String encoding = parseEncoding(file.getAbsolutePath());
                        FileInputStream fis = new FileInputStream(file);
                        if (encoding != null
                                && (encoding.equals(UTF_16_BE) || encoding
                                        .equals(UTF_16_LE))) {
                            fis.read();
                            fis.read();
                        }
                        InputStreamReader isr = (null == encoding) ?
                                new InputStreamReader(fis)
                                : new InputStreamReader(fis, encoding);
                        XPath parser = new XPath(isr);
                        SimpleNode tree = parser.XPath2();
                        dump(tree, dumpFormat);
                    } else if ("-catalog".equalsIgnoreCase(args[argsStart])) {
                        argsStart++;
                        numberArgsLeft--;
                        String catalogFileName = args[argsStart];
                        argsStart++;
                        numberArgsLeft--;
                        processW3CTestCatalog(dumpFormat, catalogFileName);

                    } else if ("-expr".equalsIgnoreCase(args[argsStart])) {
                        if (dumpFormat != DUMP_XQUERYX)
                            System.out.println("Running test for: "
                                    + args[argsStart]);
                        argsStart++;
                        numberArgsLeft--;
                        Reader reader = new StringReader(args[argsStart]);
                        XPath parser = new XPath(reader);
                        SimpleNode tree = parser.XPath2();
                        dump(tree, dumpFormat);
                        break;
                    } else {
                        DocumentBuilderFactory dbf = DocumentBuilderFactory
                                .newInstance();
                        DocumentBuilder db = dbf.newDocumentBuilder();
                        Document doc = db.parse(args[argsStart]);
                        argsStart++;
                        numberArgsLeft--;
                        Element tests = doc.getDocumentElement();
                        NodeList testElems = tests.getChildNodes();
                        int nChildren = testElems.getLength();
                        int testid = 0;
                        for (int i = 0; i < nChildren; i++) {
                            org.w3c.dom.Node node = testElems.item(i);
                            if (org.w3c.dom.Node.ELEMENT_NODE == node
                                    .getNodeType()) {
                                testid++;
                                String xpathString = ((Element) node)
                                        .getAttribute("value");
                                if (dumpFormat != DUMP_NONE)
                                    System.out.println("  Test[" + testid + "]: "
                                            + xpathString);
                                else {
                                    System.out.print("[" + testid + "]");
                                    System.out.flush();
                                    // hmm... there must be a cool mathmatical
                                    // way
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
                                XPath parser = new XPath(new StringReader(
                                        xpathString));
                                SimpleNode tree = parser.XPath2();
                                dump(tree, dumpFormat);
                            }
                        }
                        System.out.println();
                        if (dumpFormat != DUMP_XQUERYX)
                            System.out.println("Test successful!!!");
                        System.out.flush();
                        break;
                    }
                    if (dumpFormat != DUMP_XQUERYX)
                        System.out.println("Test successful!!!");
                } catch(PostParseException ppe) {
                    System.err.println("    "+ppe.getMessage());
                    return;
                }
                catch (Exception e) {
                    System.out.println("    "+e.getMessage());
                    e.printStackTrace();
                }
            }
        } finally {
            if (xqout2 != null) {
                xqout2.close();
                xqout2 = null;
            }
        }

    }

    /**
     * @param dumpFormat
     * @param catalogFileName
     * @throws ParserConfigurationException
     * @throws SAXException
     * @throws IOException
     */
    private void processW3CTestCatalog(int dumpFormat, String catalogFileName)
            throws ParserConfigurationException, SAXException, IOException {
        System.out.println("Running catalog for: " + catalogFileName);
        System.out.println("'i' means test parsed but XQueryX is invalid (test failed).");
        System.out.println("'x' means a parse error should have taken place (test failed).");
        System.out.println("'e' means a parse error took place but shouldn't have (test failed).");
        System.out.println("'v' means parse succeeded and XQueryX output was validated (test succeeds).");
        System.out.println("'g' or 'h' means parse error properly took place (test succeeds).");
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(catalogFileName);

        NodeIterator testCases = ((DocumentTraversal) doc).createNodeIterator(
                doc, NodeFilter.SHOW_ELEMENT, new NodeFilter() {
                    public short acceptNode(org.w3c.dom.Node node) {
                        String nm = node.getLocalName();
                        String namespace = node.getNamespaceURI();
                        return (nm.equals("test-case") && namespace != null
                                && namespace.equals("http://www.w3.org/2005/02/query-test-XQTSCatalog")) ? NodeFilter.FILTER_ACCEPT
                                : NodeFilter.FILTER_SKIP;
                    }
                }, true);
        org.w3c.dom.Element testCase;
        int totalCount = 0;
        Vector failedList = new Vector();
        Vector failedErrorList = new Vector();
        Vector filesNotFound = new Vector();
        Vector filesNotXQueryXValid = new Vector();
        boolean hadEnough = false;
        int wobblycount = 0;

        while (((testCase = (org.w3c.dom.Element) testCases.nextNode()) != null)
                && !hadEnough) {
            NodeIterator queryies = ((DocumentTraversal) doc)
                    .createNodeIterator(testCase, NodeFilter.SHOW_ELEMENT,
                            new NodeFilter() {
                                public short acceptNode(org.w3c.dom.Node node) {
                                    String nm = node.getLocalName();
                                    String namespace = node.getNamespaceURI();
                                    return (nm.equals("query") && namespace != null && namespace.equals("http://www.w3.org/2005/02/query-test-XQTSCatalog")) ? NodeFilter.FILTER_ACCEPT
                                            : NodeFilter.FILTER_SKIP;
                                }
                            }, true);

            org.w3c.dom.Element query;
            while (((query = (org.w3c.dom.Element) queryies.nextNode()) != null)
                    && !hadEnough) {
                String fileString = query.getAttribute("name");
                String locString = testCase.getAttribute("FilePath").replace(
                        '/', File.separatorChar);
                File catFile = new File(catalogFileName);
                String locCatFile = catFile.getParent();
                String absFileName = locCatFile + File.separator + "Queries"
                        + File.separator + "XQuery" + File.separator
                        + locString + fileString + ".xq";

                if (dumpFormat != DUMP_NONE && (dumpFormat != DUMP_XQUERYX)) {
                    System.out.print("== ");
                    System.out.print(absFileName);
                    System.out.println(" ==");
                } else {
                    // System.out.print(".");
                }

                boolean isParseError = false;
                String scenario = testCase.getAttribute("scenario");
                if (scenario.equals("parse-error"))
                    isParseError = true;

                totalCount++;

                try {
                    // System.out.print(absFileName);
                    File file = new File(absFileName);
                    String encoding = parseEncoding(file.getAbsolutePath());
                    FileInputStream fis = new FileInputStream(file);
                    if (encoding != null
                            && (encoding.equals(UTF_16_BE) || encoding
                                    .equals(UTF_16_LE))) {
                        fis.read();
                        fis.read();
                    }
                    InputStreamReader isr = (null == encoding) ?
                            new InputStreamReader(fis)
                            : new InputStreamReader(fis, encoding);

                    XPath parser = new XPath(isr);
                    SimpleNode tree = parser.XPath2();
                    if (isParseError) {
                        failedErrorList.addElement(fileString);
                        System.out.print("x");
                        System.out.flush();
                    } else {
                        System.out.print(".");
                        System.out.flush();
                        XQueryXOutputFilename = "t.xqueryx";
                        xqout2 = new PrintStream(new FileOutputStream(
                                XQueryXOutputFilename));
                        xqout1 = null;
                        boolean isValid = processToXQueryXAndValidate(tree,
                                null);
                        System.out.print(isValid ? "v" : "i");
                        if (!isValid) {
                            filesNotXQueryXValid.addElement(file
                                    .getCanonicalPath());
                            if (filesNotXQueryXValid.size() > 5) {
                                hadEnough = true;
                                break; // from loop!
                            }
                        }
                    }
                     //    System.out.println("ok");
                    // dump(tree, dumpFormat);
                } catch (FileNotFoundException e) {
                    filesNotFound.addElement(fileString);
                    System.out.print("f");
                    System.out.flush();
                } catch (Exception e) {
                    if (!isParseError && !scenario.equals("runtime-error")) {
                        failedList.addElement(fileString);
                        System.out.print("e");
                        System.out.flush();
                    } else {
                        System.out.print(",g");
                        System.out.flush();
                    }
                } catch (Error e2) {
                    if (!isParseError && !scenario.equals("runtime-error")) {
                        failedList.addElement(fileString);
                        System.out.print("e");
                        System.out.flush();
                    } else {
                        System.out.print(",h");
                        System.out.flush();
                    }
                }
                finally {
//                    System.out.println();
                    System.out.flush();
//                    System.err.flush();
                }
                if (((totalCount * 2) % 60) == 0) {
                    System.out.println();
                    for (int i = 0; i < wobblycount; i++) {
                        System.out.print('>');
                    }
                    wobblycount++;
                    if (wobblycount > 2)
                        wobblycount = 0;
                }

            }
        }
        System.out.println();
        if (filesNotFound.size() > 0) {
            System.out.println("Files not found: ");
            for (int i = 0; i != filesNotFound.size(); i++) {
                String fname = (String) filesNotFound.elementAt(i);
                System.out.print(fname);
                if ((i + 1) != filesNotFound.size())
                    System.out.print(", ");
                if (((i + 1) % 4) == 0)
                    System.out.println();
            }
            System.out.println();
        }
        if (failedList.size() > 0 || failedErrorList.size() > 0) {
            if (failedList.size() > 0) {
                System.out.println("SHOULD HAVE SUCCEEDED BUT DIDN'T: ");
                for (int i = 0; i != failedList.size(); i++) {
                    String fname = (String) failedList.elementAt(i);
                    System.out.print(fname);
                    if ((i + 1) != failedList.size())
                        System.out.print(", ");
                    if (((i + 1) % 4) == 0)
                        System.out.println();
                }
                System.out.println();
            }
            if (failedErrorList.size() > 0) {
                System.out.println("SHOULD HAVE FAILED BUT DIDN'T: ");
                for (int i = 0; i != failedErrorList.size(); i++) {
                    String fname = (String) failedErrorList.elementAt(i);
                    System.out.print(fname);
                    if ((i + 1) != failedErrorList.size())
                        System.out.print(", ");
                    if (((i + 1) % 4) == 0)
                        System.out.println();
                }
                System.out.println();
            }

            System.out
                    .print("Failed "
                            + (failedList.size() + failedErrorList.size())
                            + " out of ");
        } else {
            System.out.print("Total Success!! ");
        }
        System.out.println(totalCount + " cases");
        if (filesNotXQueryXValid.size() > 0) {
            // PrintStream errfileLog = new PrintStream(new FileOutputStream(
            //        "scratch.txt"));
            System.out.println("\n   XQueryX Translation Failed: ");
            for (int i = 0; i != filesNotXQueryXValid.size(); i++) {
                String fname = (String) filesNotXQueryXValid.elementAt(i);
                System.out.println("\n      "+fname);
                // errfileLog.println(fname);
            }
            // errfileLog.close();
        }
    }

    void dump(SimpleNode tree, int format) {
        if (format == DUMP_AST) {
            tree.dump("|");
        }
        if (format == DUMP_AST_XML) {
            try {
                if (null != XQueryXOutputFilename)
                    xqout1 = new PrintStream(new FileOutputStream(
                            XQueryXOutputFilename));
                PrintWriter systemOutWriter = new PrintWriter(
                        new OutputStreamWriter(xqout1, "UTF-8"));
                Xq2xml.convert(" ", systemOutWriter, tree);
                systemOutWriter.close();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        } else if (format == DUMP_XQUERYX) {
            Vector errors = new Vector();
            boolean isValid = processToXQueryXAndValidate(tree, errors);
            if (!isValid) {
                System.err.println("\n   XQueryX Translation is invalid!");
                for (int i = 0; i < errors.size(); i++) {
                    String msg = (String) errors.elementAt(i);
                    System.err.println(msg);
                }
            }
        }
    }

    /**
     * @param tree
     */
    private boolean processToXQueryXAndValidate(SimpleNode tree, Vector errors) {
        // System.out.println("XQueryX translator not yet supported!");
        boolean isValidDoc = false;
        try {
            {
                Class transformerClass = Class.forName("org.w3c.xqparser.XQueryToXQueryX");
                Object transformer = transformerClass.newInstance();
                Class[] argTypes = { SimpleNode.class, PrintStream.class,
                        PrintStream.class };
                Method transformMethod = transformerClass.getMethod(
                        "transform", argTypes);
                Object[] args = { tree, xqout1, xqout2 };
                transformMethod.invoke(transformer, args);
            }

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
        try {
            if (null != xqout2) {
                xqout2.close();
                xqout2 = null;
                Class validatorClass = Class.forName("org.w3c.xqparser.XMLValidator");
                Object validator = validatorClass.newInstance();
                Class[] argTypes = { String.class, Vector.class };
                Method validateXMLFile = validatorClass.getMethod(
                        "validateXMLFile", argTypes);
                Object[] args = { XQueryXOutputFilename, errors };
                Boolean isValid = (Boolean) validateXMLFile.invoke(validator,
                        args);
                isValidDoc = isValid.booleanValue();
            }
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