This module attempts to build LALR (bottom-up) parsers for XPath and
XQuery, using lex & yacc (specifically, JFlex and BYacc/J).
    http://jflex.de/
    http://byaccj.sourceforge.net/

When I looked in on 2011-02-18, I found that builds didn't get very far,
but I thought that perhaps they could work again with a little tweaking.
I now think it will take more than just tweaking.

Some history:

2004-01-05:
    Scott Boag adds WWW/XML/Group/xsl-query-specs/grammar/lalr to CVS.

2004-01-18:
    Scott Boag mentions this work on WG mailing lists.
    "I have recently checked in BYaccJ & JFlex LALR test parser generation."
    http://lists.w3.org/Archives/Member/w3c-xsl-query/2004Jan/0060.html

    (Other than quotes of that mention in the next few days, it looks like
    the work was never brought up again.)

2004-01-27:
    The last commits to this module (before I came along).

2005-10-10:
    Scott Boag announces major grammar/parser proposal:
    http://lists.w3.org/Archives/Member/w3c-xsl-query/2005Oct/0008.html

2005-10-21:
    Scott commits the above proposal (or something similar) to
    WWW/XML/Group/xsl-query-specs/grammar/xpath-grammar.xml
    (revision 1.134: "Merge from LLK branch")

---

I suspect that the latter commit broke this module (if it hadn't already
been broken by other changes since 2004-01-27).

In particular, one of the changes of October 2005 was that:
    "All keywords, and most other strings, are embedded directly in the 
    productions, and are no longer named tokens."

In contrast, I believe this module's current code relies fairly heavily
on the assumption that every keyword and piece of punctuation is defined
by a g:token element, and thus has a name.

-Michael Dyck
 2011-04-18
