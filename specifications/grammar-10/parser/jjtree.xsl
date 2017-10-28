<?xml version="1.0" encoding="UTF-8"?>

<!--
 * Copyright (c) 2002 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                                                xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
	<xsl:import href="javacc.xsl"/>

	<xsl:template match="g:sequence[not(*)]" priority="10"/>

	<xsl:template name="javacc-options">
	  <!-- xsl:apply-imports/ -->
       STATIC = false;
	   MULTI=false;
	   VISITOR=true ;     // invokes the JJTree Visitor support
	   NODE_SCOPE_HOOK=false;
	   NODE_USES_PARSER=true;
	   FORCE_LA_CHECK=false;
	   NODE_PACKAGE="org.w3c.xqparser";
	   NODE_PREFIX="";
	</xsl:template>

	<xsl:template name="set-parser-package">
		<xsl:text>package org.w3c.xqparser;&#10;&#10;</xsl:text>
		<xsl:text>import org.w3c.xqparser.Node;&#10;</xsl:text>
		<xsl:text>import org.w3c.xqparser.SimpleNode;&#10;</xsl:text>
	</xsl:template>

	<xsl:template name="input">
		SimpleNode <xsl:choose>
			<xsl:when test="$spec='xquery'">XPath2</xsl:when>
			<xsl:when test="$spec='xpath'">XPath2</xsl:when>
			<xsl:when test="$spec='pathx1'">XPath2</xsl:when>
      <xsl:otherwise>XPath2</xsl:otherwise>
		</xsl:choose>() :
		{}
		{
		  <xsl:value-of select="g:start/@name"/>()&lt;EOF&gt;
		  { if(this.token_source.curLexState == XPathConstants.EXPR_COMMENT)
                            throw new ParseException("Unterminated comment.");
			return jjtThis ; }
		}
      <xsl:if test="$spec='xpath' or $spec='zzpathx1'">
		SimpleNode <xsl:choose>
			<xsl:when test="$spec='xpath'">MatchPattern</xsl:when>
			<xsl:when test="$spec='pathx1'">MatchPattern</xsl:when>
      <xsl:otherwise>MatchPattern</xsl:otherwise>
		</xsl:choose>() :
		{m_isMatchPattern = true;}
		{
		  <xsl:value-of select="g:start[contains(@if,'xslt-patterns')]/@name"/>()&lt;EOF&gt;
		  { if(this.token_source.curLexState == XPathConstants.EXPR_COMMENT)
                            throw new ParseException("Unterminated comment.");
			return jjtThis ; }
		}
    </xsl:if>
	</xsl:template>

  <xsl:template name="extra-parser-code"/>

  <xsl:template name="parser">

    <xsl:variable name="parser-class">
      <xsl:choose>
			<xsl:when test="$spec='xpath'">XPath</xsl:when>
			<xsl:when test="$spec='pathx1'">XPath</xsl:when>
      <xsl:otherwise>XPath</xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    PARSER_BEGIN(<xsl:value-of select="$parser-class"/>)

<xsl:call-template name="set-parser-package"/>
import java.io.*;
import java.util.Stack;
import java.util.Vector;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import javax.xml.parsers.*;
import org.w3c.dom.traversal.DocumentTraversal;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.NodeIterator;
import org.w3c.dom.traversal.TreeWalker;

public class <xsl:value-of select="$parser-class"/> {
      <xsl:call-template name="extra-parser-code"/>

      boolean m_isMatchPattern = false;
      boolean isStep = false;

	  Stack _elementStack = new Stack();

		  Stack binaryTokenStack = new Stack();

		  public Node createNode(int id) {
			  return null;
		  }


 		 void processToken(SimpleNode n, Token t)
		  {
			<!-- TODO: These need to be done declarativly from the grammar file!!! -->
		    <xsl:if test="not(/g:grammar/g:language/@id = 'core')">
			  if(t.kind == XPathConstants.Slash &amp;&amp; n.id != XPathTreeConstants.JJTSLASH)
				  return;
		    </xsl:if>
			<xsl:if test="/g:grammar/g:language/@id = 'xquery'">
			  if(t.kind == XPathConstants.TagQName &amp;&amp; n.id != XPathTreeConstants.JJTTAGQNAME)
				  return;
			  if(t.kind == XPathConstants.S &amp;&amp; n.id != XPathTreeConstants.JJTS)
				  return;
			</xsl:if>
			  n.processToken(t);
		  }

		  <xsl:if test="/g:grammar/g:language/@id = 'xquery'">
		void checkCharRef(String ref) throws ParseException
		{
            ref = ref.substring(2, ref.length() - 1);
            int val;
            if (ref.charAt(0) == 'x') {
                val = Integer.parseInt(ref.substring(1), 16);
            } else
                val = Integer.parseInt(ref);
            boolean isLegal = val == 0x9 || val == 0xA || val == 0xD
                    || (val &gt;= 0x20 &amp;&amp; val &lt;= 0xD7FF)
                    || (val &gt;= 0xE000 &amp;&amp; val &lt;= 0xFFFD)
                    || (val &gt;= 0x10000 &amp;&amp; val &lt;= 0x10FFFF);
            if (!isLegal)
                throw new ParseException(
                        "Well-formedness constraint: Legal Character, \n"
                                + "Characters referred to using character references MUST match the production for Char.");
        }
		</xsl:if>


		  public static void main(String args[])
		     throws Exception
		  {

        int numberArgsLeft = args.length;
        int argsStart = 0;
        boolean isMatchParser = false;
        boolean dumpTree = false;
        while (numberArgsLeft > 0) {
            try {

                if (args[argsStart].equals("-dumptree")) {
                    dumpTree = true;
                    argsStart++;
                    numberArgsLeft--;
                }
                else if (args[argsStart].equals("-match")) {
                    isMatchParser = true;
                    System.out.println("Match Pattern Parser");
                    argsStart++;
                    numberArgsLeft--;
                } else if ("-file".equalsIgnoreCase(args[argsStart])) {
                    argsStart++;
                    numberArgsLeft--;
                    System.out.println("Running test for: " + args[argsStart]);
                    File file = new File(args[argsStart]);
                    argsStart++;
                    numberArgsLeft--;
                    Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                    XPath parser = new XPath(fis);
                    SimpleNode tree = parser.XPath2();
                    if (dumpTree)
                        tree.dump("|");
                } else if (args[argsStart].endsWith(".xquery")) {
                    System.out.println("Running test for: " + args[argsStart]);
                    File file = new File(args[argsStart]);
                    argsStart++;
                    numberArgsLeft--;
                    Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                    XPath parser = new XPath(fis);
                    SimpleNode tree = parser.XPath2();
                    if (dumpTree)
                        tree.dump("|");
                }         else if ("-catalog".equalsIgnoreCase(args[argsStart])) {
                    argsStart++;
                    numberArgsLeft--;
                    String catalogFileName = args[argsStart];
                    argsStart++;
                    numberArgsLeft--;
                    System.out.println("Running catalog for: "
                            + catalogFileName);
                    DocumentBuilderFactory dbf = DocumentBuilderFactory
                            .newInstance();
                    DocumentBuilder db = dbf.newDocumentBuilder();
                    Document doc = db.parse(catalogFileName);

                    NodeIterator testCases = ((DocumentTraversal) doc)
                            .createNodeIterator(doc, NodeFilter.SHOW_ELEMENT,
                                    new NodeFilter() {
                                        public short acceptNode(
                                                org.w3c.dom.Node node) {
                                            String nm = node.getNodeName();
                                            return (nm.equals("test-case")) ? NodeFilter.FILTER_ACCEPT
                                                    : NodeFilter.FILTER_SKIP;
                                        }
                                    }, true);
                    org.w3c.dom.Element testCase;
                    int totalCount = 0;
                    Vector failedList = new Vector();
                    while ((testCase = (org.w3c.dom.Element) testCases
                            .nextNode()) != null) {
                        NodeIterator queryies = ((DocumentTraversal) doc)
                                .createNodeIterator(testCase,
                                        NodeFilter.SHOW_ELEMENT,
                                        new NodeFilter() {
                                            public short acceptNode(
                                                    org.w3c.dom.Node node) {
                                                String nm = node.getNodeName();
                                                return (nm.equals("query")) ? NodeFilter.FILTER_ACCEPT
                                                        : NodeFilter.FILTER_SKIP;
                                            }
                                        }, true);
                        org.w3c.dom.Element query;
                        while ((query = (org.w3c.dom.Element) queryies
                                .nextNode()) != null) {
                            String fileString = query.getAttribute("name");
                            String locString = testCase
                                    .getAttribute("FilePath").replace('/',
                                            File.separatorChar);
                            File catFile = new File(catalogFileName);
                            String locCatFile = catFile.getParent();
                            String absFileName = locCatFile + File.separator
                                    + "Queries" + File.separator + "XQuery"
                                    + File.separator + locString + fileString;

                            if (dumpTree) {
                                System.out.print("== ");
                                System.out.print(absFileName);
                                System.out.println(" ==");
                            } else
                                System.out.print(".");

                            boolean isParseError = false;
                            String scenario = testCase.getAttribute("scenario");
                            if (scenario.equals("parse-error"))
                                isParseError = true;

                            totalCount++;

                            try {
                                File file = new File(absFileName);
                                Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                                XPath parser = new XPath(fis);
                                SimpleNode tree = parser.XPath2();
                                if(isParseError)
                                    failedList.addElement(fileString);
                                if (dumpTree)
                                    tree.dump("|");
                            } catch (Exception e) {
                                if(!isParseError)
                                    failedList.addElement(fileString);
                            } catch (Error e2) {
                                if(!isParseError)
                                    failedList.addElement(fileString);
                            }

                        }

                    }
                    System.out.println();
                    if(failedList.size() > 0)
                    {
                        System.out.print("FAILED: ");
                        for(int i = 0; i &lt; failedList.size(); i++)
                        {
                            String fname = (String)failedList.elementAt(i);
                            System.out.print(fname);
                            if((i+1) != failedList.size())
                                System.out.print(", ");
                        }
                        System.out.println();
                        System.out.print("Failed "+failedList.size()+" out of ");
                    }
                    else
                    {
                        System.out.print("Total Success!! ");
                    }
                    System.out.println(totalCount+" cases");

                }

        else
        {
				for(int i = argsStart; i &lt; args.length; i++)
				{
					System.out.println();
					System.out.println("Test["+i+"]: "+args[i]);
          Reader fis = new BufferedReader(new InputStreamReader(new java.io.StringBufferInputStream(args[i]), "UTF-8"));
					XPath parser = new XPath(fis);
          SimpleNode tree;
          if(isMatchParser)
          {
					tree = parser.<xsl:choose>
						<xsl:when test="$spec='xquery'">XPath2</xsl:when>
						<xsl:when test="$spec='xpath'">MatchPattern</xsl:when>
						<xsl:when test="$spec='zpathx1'">MatchPattern</xsl:when>
            <xsl:otherwise>XPath2</xsl:otherwise>
					</xsl:choose>();
          }
          else
          {
					tree = parser.<xsl:choose>
						<xsl:when test="$spec='xquery'">XPath2</xsl:when>
						<xsl:when test="$spec='xpath'">XPath2</xsl:when>
						<xsl:when test="$spec='pathx1'">XPath2</xsl:when>
            <xsl:otherwise>XPath2</xsl:otherwise>
					</xsl:choose>();
          }
					((SimpleNode)tree.jjtGetChild(0)).dump("|") ;
          break;
				}
				System.out.println("Success!!!!");
        }
			}
			catch(ParseException pe)
			{
				System.err.println(pe.getMessage());
			}
			  catch(Error e)
			  {
				  String msg = e.getMessage();
				  if(msg == null || msg.equals(""))
					  msg = "Unknown Error: "+e.getClass().getName();
			  	System.err.println(msg);
			  }
			return;
		   }
		    java.io.DataInputStream dinput = new java.io.DataInputStream(System.in);
		    while(true)
		    {
			  try
			  {
			      System.err.println("Type Expression: ");
			      String input =  dinput.readLine();
			      if(null == input || input.trim().length() == 0)
			        break;
			      XPath parser = new XPath(new BufferedReader(new InputStreamReader(new java.io.StringBufferInputStream(input), "UTF-8")));
          SimpleNode tree;
          if(isMatchParser)
          {
					tree = parser.<xsl:choose>
						<xsl:when test="$spec='xquery'">XPath2</xsl:when>
						<xsl:when test="$spec='xpath'">MatchPattern</xsl:when>
						<xsl:when test="$spec='zpathx1'">MatchPattern</xsl:when>
            <xsl:otherwise>XPath2</xsl:otherwise>
					</xsl:choose>();
          }
          else
          {
					tree = parser.<xsl:choose>
						<xsl:when test="$spec='xquery'">XPath2</xsl:when>
						<xsl:when test="$spec='xpath'">XPath2</xsl:when>
						<xsl:when test="$spec='pathx1'">XPath2</xsl:when>
            <xsl:otherwise>XPath2</xsl:otherwise>
					</xsl:choose>();
          }
			      ((SimpleNode)tree.jjtGetChild(0)).dump("|") ;
			  }
			  catch(ParseException pe)
			  {
			  	System.err.println(pe.getMessage());
			  }
			  catch(Exception e)
			  {
			  	System.err.println(e.getMessage());
			  }
			  catch(Error e)
			  {
				  String msg = e.getMessage();
				  if(msg == null || msg.equals(""))
					  msg = "Unknown Error: "+e.getClass().getName();
			  	System.err.println(msg);
			  }
		    }
		  }
		}

    PARSER_END(<xsl:value-of select="$parser-class"/>)

	</xsl:template>

	<xsl:template match="g:production" mode="production-java-block">
		<!-- Begin LV -->
		<xsl:if test="@prod-user-action">
				<xsl:value-of select="@prod-user-action"/>
		</xsl:if>
		<!-- End LV -->
	</xsl:template>

	<!-- xsl:template name="action-production-end">
	</xsl:template -->

	<xsl:template name="action-exprProduction-label">
    <xsl:if test="@node-type='void'">
      <xsl:text> #void </xsl:text>
    </xsl:if>
	</xsl:template>


	<xsl:template name="action-exprProduction">
	</xsl:template>

	<xsl:template name="action-exprProduction-end">
	</xsl:template>

	<xsl:template match="g:level" mode="action-level">
		<xsl:param name="thisProd"/>
		<xsl:param name="nextProd"/>

		<xsl:if test="@level-user-action">
				<xsl:value-of select="@level-user-action"/>
		</xsl:if>
		<!-- xsl:text>
printIndent(); System.err.println("</xsl:text>
	   <xsl:value-of select="$thisProd"/>
	   <xsl:text>");
</xsl:text -->
	</xsl:template>

	<xsl:template name="action-level-jjtree-label">
    <xsl:param name="label">
      <xsl:text>void</xsl:text>
    </xsl:param>
		<!-- Begin SMPG -->
    <xsl:param name="condition"></xsl:param>
		<!-- End SMPG -->

    <xsl:text> #</xsl:text>
    <xsl:value-of select="$label"/>

		<!-- Begin SMPG -->
		<xsl:if test="$condition != ''">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="$condition"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<!-- End SMPG -->
  </xsl:template>

	<xsl:template name="binary-action-level-jjtree-label">
    <xsl:param name="label"/>
    <xsl:param name="which" select="'unknown'"/>
    <!-- xsl:message>
      <xsl:text>In binary-action-level-jjtree-label: </xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>  (</xsl:text>
      <xsl:value-of select="$which"/>
      <xsl:text>)</xsl:text>
    </xsl:message -->
    <xsl:if test="ancestor-or-self::g:binary or self::g:level/g:binary">
		<xsl:text>
		{
         try
         {
			   processToken(jjtThis, (Token)binaryTokenStack.pop());
         }
         catch(java.util.EmptyStackException e)
         {
           token_source.printLinePos();
           e.printStackTrace();
           throw e;
         }
		}
		</xsl:text>
		<xsl:text> #</xsl:text><xsl:value-of select="$label"/><xsl:text>(2)</xsl:text>
    </xsl:if>
	</xsl:template>

	<xsl:template name="action-level-start">
	</xsl:template>

	<xsl:template match="*" mode="action-level-end">
	</xsl:template>

	<xsl:template name="action-token-ref">
		<!-- xsl:if test="ancestor::g:binary">
		<xsl:text> #</xsl:text><xsl:value-of select="@name"/>
		</xsl:if -->
		<xsl:choose>
	  <xsl:when test="self::g:string">
		<xsl:if test="@process-value='yes' or @token-user-action or ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
			<xsl:text>{</xsl:text>
			<xsl:if test="@token-user-action">
				<xsl:value-of select="@token-user-action"/>
			</xsl:if>
			<xsl:if test="@process-value='yes'">
				<xsl:choose>
					<xsl:when test="ancestor-or-self::*/@node-type='void' or key('ref',@name)/self::g:token/@node-type='void'">
						<xsl:text>jjtThis.processValue("</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>jjtThis.processValue("</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test=". = '&quot;'">\</xsl:if>
				<xsl:value-of select="."/>
				<xsl:text>");</xsl:text>
			</xsl:if>
			<xsl:if test="ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
				binaryTokenStack.push(token);
			</xsl:if>
			<xsl:text>}</xsl:text>
		</xsl:if>
	  </xsl:when>
      <xsl:when test="not(ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes')">

        <xsl:choose>
          <xsl:when test="@node-type='void' or key('ref',@name)/self::g:token/@node-type='void'">
            <!-- Don't produce a node.  #void doesn't seem to work here, for some reason. -->
            <xsl:text>{</xsl:text>
						<xsl:if test="@token-user-action">
							<xsl:value-of select="@token-user-action"/>
						</xsl:if>
						<xsl:text>processToken(((SimpleNode)jjtree.peekNode()), token);}</xsl:text>
          </xsl:when>
          <xsl:when test="key('ref',@name)/self::g:token/@node-type">
            <xsl:text>{</xsl:text>
						<xsl:if test="@token-user-action">
							<xsl:value-of select="@token-user-action"/>
						</xsl:if>
						<xsl:text>processToken(jjtThis, token);}</xsl:text>
            <xsl:text> #</xsl:text>
            <xsl:value-of select="key('ref',@name)/self::g:token/@node-type"/>
            <!-- See JTree doc for why I do the following... -->
            <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
              <xsl:text>(true)</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:when test="@node-type">
            <xsl:text>{</xsl:text>
						<xsl:if test="@token-user-action">
							<xsl:value-of select="@token-user-action"/>
						</xsl:if>
						<xsl:text>processToken(jjtThis, token);}</xsl:text>
            <xsl:text> #</xsl:text>
            <xsl:value-of select="@node-type"/>
            <!-- See JTree doc for why I do the following... -->
            <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
              <xsl:text>(true)</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>{</xsl:text>
						<xsl:if test="@token-user-action">
							<xsl:value-of select="@token-user-action"/>
						</xsl:if>
						<xsl:text>processToken(jjtThis, token);}</xsl:text>
            <xsl:text> #</xsl:text>
            <xsl:value-of select="@name"/>
            <!-- See JTree doc for why I do the following... -->
            <xsl:if test="true() or following-sibling::*[1][self::g:zeroOrMore or self::g:oneOrMore]">
              <xsl:text>(true)</xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>


			</xsl:when>
			<xsl:otherwise>
		        <!-- xsl:message>
          <xsl:text>In binary-action-level-jjtree-label: </xsl:text>
          <xsl:value-of select="name(.)"/>
        </xsl:message -->
         {binaryTokenStack.push(token);}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Begin LV -->
<xsl:template match="g:ref" mode="user-action-ref-start">
<xsl:if test="@nt-user-action-start">{<xsl:value-of select="@nt-user-action-start"/>}</xsl:if>
</xsl:template>

<xsl:template match="g:ref" mode="user-action-ref-end">
	<xsl:param name="addEnclose" select="true()"/>
	<xsl:if test="@nt-user-action-end">
		<xsl:if test="$addEnclose">{</xsl:if>
		<xsl:value-of select="@nt-user-action-end"/>
		<xsl:if test="$addEnclose">}</xsl:if>
	</xsl:if>
</xsl:template>
<!-- End LV -->

</xsl:stylesheet>
