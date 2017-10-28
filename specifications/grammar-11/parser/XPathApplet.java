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

import java.applet.Applet;
import java.awt.BorderLayout;
import java.awt.Button;
import java.awt.TextArea;
import java.awt.event.ActionEvent;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class XPathApplet extends Applet {
  boolean isStandalone = false;
  Button button1 = new Button();
  TextArea textArea1 = new TextArea("", 100, 30, TextArea.SCROLLBARS_VERTICAL_ONLY);
  BorderLayout borderLayout1 = new BorderLayout();
  TextArea textArea2 = new TextArea("", 100, 30, TextArea.SCROLLBARS_VERTICAL_ONLY);
  /**Get a parameter value*/
  public String getParameter(String key, String def) {
    return isStandalone ? System.getProperty(key, def) :
      (getParameter(key) != null ? getParameter(key) : def);
  }

  /**Construct the applet*/
  public XPathApplet() {
  }
  /**Initialize the applet*/
  public void init() {
    try {
      jbInit();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  /**Component initialization*/
  private void jbInit() throws Exception {
    button1.setLabel("Parse");
    button1.addActionListener(new ParseBAL(this));
    textArea1.setRows(6);
    textArea1.setText("");
    this.setLayout(borderLayout1);
    textArea2.setText("Abstract Syntax Tree will appear here");
		textArea2.setRows(15);
    this.add(button1, BorderLayout.NORTH);
    this.add(textArea1, BorderLayout.CENTER);
    this.add(textArea2, BorderLayout.SOUTH);
    this.doLayout();
  }

  /**Start the applet*/
  public void start() {
  }
  /**Stop the applet*/
  public void stop() {
  }
  /**Destroy the applet*/
  public void destroy() {
  }
  /**Get Applet information*/
  public String getAppletInfo() {
    return "Applet Information";
  }
  /**Get parameter info*/
  public String[][] getParameterInfo() {
    return null;
  }

  void button2_action(ActionEvent evt) {
  }


  void button1_action(ActionEvent evt) {

    try
    {
      String expr = textArea1.getText();
      XParser parser = new XParser(new java.io.StringBufferInputStream(expr));
      SimpleNode tree = parser.START();
      if(null == tree)
        textArea2.setText("Error!");
      else
      {
        ByteArrayOutputStream baos = new ByteArrayOutputStream(62*1024);
        PrintStream ps = new PrintStream(baos);
        tree.dump("|", ps);
        String s = new String(baos.toByteArray());
        textArea2.setText(s);
      }
    }
    catch(ParseException e)
    {
      textArea2.setText(e.getMessage());
    }
    catch(Error err)
    {
        String msg = err.getMessage();
        if(msg == null || msg.equals(""))
            msg = "Unknown Error: "+err.getClass().getName();
        textArea2.setText(msg);
    }
  }

}
