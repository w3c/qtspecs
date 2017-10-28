#!/bin/bash

#
# file: generate-svg-graphics.bash
# author: Martin Loetzsch
#
# Generates for each DotML "graph" element in a XML document 
# - a SVG graphic and 
# - a CSS style sheet containing the width and the height of the graphic.
#
# First, the XSL style sheet dotml2dot.xsl is applied to the source XML file.
# It generates for each graph a notation that is understood by the 'dot' tool.
# Then, the dot tool generates the SVG graphics from the output of the XSLT 
# transformation. The file names for the .svg files are taken from the "file-name" 
# attribute of the DotML "graph" element in the source XML file.
#
# As at the moment most of the HTML browsers can't scale SVG graphics automatically,
# a CSS file that only contains the width and the height for each .svg file is also 
# generated.
#
#
# Usage: generate-svg-graphics.bash SOURCE_XML_FILE OUTPUT_DIR
# SOURCE_XML_FILE can contain one or more elements "graph" from the dotml namespace
# at any position. OUTPUT_DIR is the directory where the images are stored.
#
# The following environment variables have to be set:
# - "DOT": the executable Graphviz dot tool. If not defined, "dot" is used.
# - "DOTML_DIR": the directory of "dotml2dot.xsl"
# - "DOTML_XSLT": a parameterized call of a XSLT processor of your choice. 
#   Use the string "(INPUT)" as a variable for the input XML file 
#   and the string "(XSL)" for the stylesheet.
#   Examples:
#     export DOTML_XSLT="Xalan -XD -Q -IN (INPUT) -XSL (XSL)"
#     export DOTML_XSLT="MyXSLTProcessor (INPUT) (XSL)"
#   Set the parameters of the XSLT processor such that the output is written to stdout
#

if test $1'x' = 'x'; then
  echo "generate-svg-graphics.bash: Parameter 1 (input XML file) is missing."
else
  if !(test -e $1); then
    echo "generate-svg-graphics.bash: Input file $1 does not exist"
  else
    if test $2'x' = 'x'; then
      echo "generate-svg-graphics.bash: Parameter 2 (output directory) is missing."
    else
      if !(test -d $2); then
        echo "generate-svg-graphics.bash: Output directory $2 does not exist"
      else
        if !(test -e $DOTML_DIR/dotml2dot.xsl); then
          echo "generate-svg-graphics.bash: Environment variable DOTML_DIR (path to DotML stylesheets) was not set correct. (Can't find dotml2dot.xsl there.)"
        else
          if test "$DOTML_XSLT"'x' = 'x'; then
            echo "generate-svg-graphics.bash: Environment variable DOTML_XSLT (executable XSLT processor with parameters) was not set."
          else
            if test $DOT'x' = 'x'; then 
              export DOT=dot
            fi
#quote some "/"
            input=$(echo $1 | sed "s/\//\\\\\//g")
            dotml_dir=$(echo $DOTML_DIR | sed "s/\//\\\\\//g")
            output_dir=$(echo $2 | sed "s/\//\\\\\//g")
#generate the call to the xslt
            xslt=$(echo $DOTML_XSLT | sed "s/(INPUT)/$input/;s/(XSL)/$dotml_dir\/dotml2dot.xsl/;")
#call the xslt            
            $xslt \
              | sed -n \
                "s/\"/\\\\\\\"/g; \
                 s/^[ ]*digraph/echo \"digraph/; \
                 s/<dot-filename>\([^<]*\)<\/dot-filename>/ \
                   \" > $output_dir\/\1.dot.new \; \
                   echo $output_dir\/\1.dot \; \
                   if ! test -f $output_dir\/\1.dot\; then echo new > $output_dir\/\1.dot\; fi\; \
                   diff -q $output_dir\/\1.dot $output_dir\/\1.dot.new >\& \/dev\/null \
                   || \(echo $output_dir\/\1.svg \; \
                   \$DOT -Tsvg -o $output_dir\/\1.svg $output_dir\/\1.dot.new\; \
                   echo $output_dir\/\1.size.css \; \
                   mv $output_dir\/\1.dot.new $output_dir\/\1.dot\; \
                   echo .svg-size-\$(echo \1 | sed \"s\/.*\\\\\/\/\/\;\"\
                     ){\$(cat $output_dir\/\1.svg \
                        | grep \"<svg\" \
                        | sed -n \"s\/.*<svg .*width=\\\\\"\\\\\(.*\\\\\)\\\\\".*height=\\\\\"\\\\\(.*\\\\\)\\\\\"\/\
                                   width:\\\1\;height:\\\2\;\/\;p\;\" \;\
                     )} > $output_dir\/\1.size.css\)/;\
                 p;" \
             | bash
          fi
        fi
      fi
    fi
  fi  
fi
