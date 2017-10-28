This zipfile contains the XML source for the XPath/XQuery family 
of grammars, the XSLT files for a transformation to a test parser 
for JavaCC/JJTree (https://javacc.dev.java.net/) parser generation, 
and the generated jars.

xpath-grammar.xml is the source for the grammar.  It is used to generate both the EBNF in the 
language documents, as well as the JavaCC test parsers.

The grammar/ parser directory contains the stuff to generate xpath.jar, xquery.jar, 
and xquery-fulltext.jar as well as the jars themselves.

The parser/applets directory contains applets that run the parsers.

parser/build.xml is the ANT build script for the jars and applets.

Some test files can be found in grammar/tests.

You can run the Jars on the command line via:

java -jar xquery.jar

Which will prompt for an expression.

Running:
java -jar xquery.jar -file [filename]

Will parse a file, and report errors, but will not dump any other diagnostics.
java -jar xquery.jar -dumptree -file [filename]

will cause a diagnostic syntax tree to be dumped.

You can also run it on a XQuery test catalog:

java -jar xquery.jar -catalog ..\..\..\xquery-test\TestSuiteStagingArea\XQTSCatalog.xml

Any questions should be directed to scott_boag@us.ibm.com.

Known bug: A comment following a QName will not be parsed correctly.


