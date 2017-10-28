Saxon Test Suite Harness Tool
version 1.1
========================

What the zip file contains:
* Saxon9ee.jar
* Exception files for W3C Test Suites in directory 'exceptionFiles'


Prerequisite requirements (at least one of the following):
Test Suites download from CVS:
* XSLT 
* QT 3.0
* XSD
* XQuery Update

-------------------------------------------------------------------
Instructions on exception files:

The exception files must be inserted in the working copy of the W3C test suites directory. Specifically:
* XSLT - /TestSuiteStagingArea/SaxonResults/exceptions.xml
* QT 3.0 - /QT3-test-suite/results/saxon/exceptions.xml
* XSD - /xsts-current/saxon/exceptions.xml
* XQuery Update  - /xquery-update-10-test-suite/results/saxon/exceptions.xml

---------------------------------------------------------------------


This readme file is a guide to running the W3C test suite drivers on a custom Saxon 9.4.0.4 build.


The test driver application contains an embedded license key which activates Saxon-EE for that application only; it does not allow EE functionality to be invoked from the command line unless you have a separate license file.

The test suite harness is platform independant and can be run from the commandline with the following command:

Linux/Unix OS:
java -cp .:saxon9ee.jar com.saxonica.testdriver.gui.TestDriverForm

Windows:
java -cp .;saxon9ee.jar com.saxonica.testdriver.gui.TestDriverForm

The tool will automatically create a cache.xml file to save the working directories defined in the gui.


----------------------------------------------------------------------
Welcome feedback on the test harness,  please contact either:
O'Neil Delpratt (oneil@saxonica.com) or Mike Kay   (mike@saxonica.com)


