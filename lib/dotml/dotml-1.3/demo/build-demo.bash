#/bin/bash

# The path of the executable dot tool. Change this to the location of dot.
# by default, 'dot' is used 
# export DOT=/usr/bin/dot

# The directory that contains the DotML Schema and the XSLT stylesheets
export DOTML_DIR=../dotml-1.3

# The path to a XSLT processor (LibXML works fine, but others work well too.)
export XSLT="xsltproc"

# How to invoke the XSLT processor. "(XSL)" is a placeholder for the stylesheet,
# "(INPUT)" for the input file.
export DOTML_XSLT="$XSLT (XSL) (INPUT)"

# The directory for the output
export OUTPUT_DIR=.

# Generates the SVG charts
$DOTML_DIR/generate-svg-graphics.bash embedded-dotml-demo-source.xhtml .
$DOTML_DIR/generate-svg-graphics.bash standalone-dotml-demo-source.xml .

# Embeds the SVG charts
$XSLT -o embedded-dotml-demo.html $DOTML_DIR/embed-svg-graphics.xsl embedded-dotml-demo-source.xhtml

