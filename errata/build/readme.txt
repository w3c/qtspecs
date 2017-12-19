
Creating errata documents
====================

1. Apply edits to the relevant errata.xml file

Some hints:

(a) er:errata is a sequence of er:erratum elements
     er:erratum contains a sequence of (er:change | er:manual-change) elements

(b) er:change elements select the old text by XPath expression. The "ref" attribute is an id
in the baseline document, the "select" attribute is an XPath expression relative to this id,
and "action" is for example "insert-after" to indicate where the new text goes relative to the old. 
The new text is in xmlspec markup format.

(c) er:manual change allows a more free-form description of the change.

(d) use xmlspec diff markup (optionally) to highlight the phrases in the new text that have changed.

Because the old text is extracted from the baseline document it is important to have a stable baseline
for the entire XML. Since many of the specs are assembled from multiple source documents this may need
to be created for the purpose. When the system was first set up, there was a stylesheet to apply 
the errata automatically to the baseline document: this is unlikely to be feasible when source documents 
are in multiple parts or with additional markup for variants.

2. Check schema-validity against build/errata.xsd

3. Run the stylesheet to generate the corresponding errata.html

This needs a schema-aware XSLT 2.0 engine. With Saxon the transformation can be run from the 
command line using for example

java net.sf.saxon.Transform -xsl:build/errata.xsl -s:xslt-30/errata.xml -o:xslt-30/html/errata.html -t -val:lax

with the "errata" directory as the current directory. Note in particular the -val:lax which is needed because 
the transformation is schema aware ("lax" because some XML documents have an associated schema and others do not).