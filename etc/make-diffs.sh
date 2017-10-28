# XPath / XQuery
pushd specifications/xquery-11/html/
rm -rf tmp
mkdir -p tmp
mkdir -p tmp/xquery
pushd tmp/xquery
wget http://www.w3.org/TR/2007/REC-xquery-20070123/
popd
mkdir -p tmp/xpath
pushd tmp/xpath
wget http://www.w3.org/TR/2007/REC-xpath20-20070123/
popd
htmldiff tmp/xquery/index.html xquery-11.html >xquery-11-diffs.html
htmldiff tmp/xpath/index.html xpath-21.html >xpath-21-diffs.html
popd

# Data Model
pushd specifications/xpath-datamodel-11/html/
rm index.html
wget http://www.w3.org/TR/2007/REC-xpath-datamodel-20070123/
htmldiff index.html Overview.html >Overview-diffs.html
popd

# Functions and Operators
pushd specifications/xpath-functions-11/html/
rm index.html
wget http://www.w3.org/TR/2007/REC-xpath-functions-20070123/
htmldiff index.html Overview.html >Overview-diffs.html
popd

# Serialization
pushd specifications/xslt-xquery-serialization-11/html/
rm index.html
wget http://www.w3.org/TR/2007/REC-xslt-xquery-serialization-20070123/
htmldiff index.html Overview.html >Overview-diffs.html
popd

# XQueryX
pushd specifications/xqueryx-11/html/
rm index.html
wget http://www.w3.org/TR/2007/REC-xqueryx-20070123
htmldiff index.html Overview.html >Overview-diffs.html
popd
