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
package org.w3c.xqparser;

import java.awt.event.ActionEvent;

public class ParseBAL implements java.awt.event.ActionListener {
    XPathApplet _myApplet;

    int whichButton = 0;

    public ParseBAL(XPathApplet applet) {
        _myApplet = applet;
        whichButton = 0;
    }

    public ParseBAL(XPathApplet applet, int which) {
        _myApplet = applet;
        whichButton = which;
    }

    public void actionPerformed(ActionEvent e) {
        if (whichButton == 0)
            _myApplet.button1_action(e);
        else
            _myApplet.button2_action(e);
    }
}