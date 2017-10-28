package org.w3c.xqparser;

public class XQueryXConverter_update30 extends XQueryXConverter {

    protected XQueryXConverter_update10 update10_converter;

    public XQueryXConverter_update30(ConversionController cc, XMLWriter xw) {
        super(cc, xw);
        update10_converter = new XQueryXConverter_update10(cc, xw);
    }

    /**
     * Process a node in the AST and its descendants.
     * @param node  The node to be processed.
     * @return true
     */
    protected boolean transformNode(SimpleNode node) {
        int id = node.id;

        switch (id) {

            case JJTUPDATINGFUNCTIONCALL: {
                // The XQueryX treatment of UpdatingFunctionCall has not
                // been specified yet, so the following is provisional...

                xw.putStartTag(node, "xqxuf:provisionalUpdatingFunctionCall");

                xw.putStartTag(node, "xqx:functionItem");
                cc.transform(node.getChild(0));
                xw.putEndTag(node);

                xw.putStartTag(node, "xqx:arguments");
                cc.transformChildren(node, 1);
                xw.putEndTag(node);

                xw.putEndTag(node);
                return true;
            }

            case JJTTRANSFORMWITHEXPR: {
                // The XQueryX treatment of TransformWithExpr has not been
                // specified yet, so the following is provisional...

                xw.putStartTag(node, "xqxuf:provisionalTransformWithExpr");
                cc.transformChildren(node);
                xw.putEndTag(node);
                return true;
            }

            default:
                return update10_converter.transformNode(node);
        }
    }

}
// vim: sw=4 ts=4 expandtab
