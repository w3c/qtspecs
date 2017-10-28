package org.w3c.xqparser;

public class XQueryXConverter_dummy extends XQueryXConverter {

    public XQueryXConverter_dummy(ConversionController cc, XMLWriter xw) {
        super(cc, xw);
    }

    protected boolean transformNode(SimpleNode node)
    {
        return false;
    }
}
