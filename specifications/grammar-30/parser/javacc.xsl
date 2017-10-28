<?xml version="1.0"?>

<!--
 * Copyright (c) 2002 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<!-- $Id: javacc.xsl,v 1.66 2016/05/01 19:23:27 mdyck Exp $ -->

<!-- ==============  CHANGE LOG: ==============
  $Log: javacc.xsl,v $
  Revision 1.66  2016/05/01 19:23:27  mdyck
  Rename template "input"  as "production-for-start-symbol".

  Revision 1.65  2016/05/01 19:19:37  mdyck
  Hoist PARSER_BEGIN and PARSER_END out of template "parser".
  Rename template "parser" as "parser-decls".

  Revision 1.64  2016/05/01 19:14:11  mdyck
  Unfold references to variable "parser-class".
  The parser's class-name isn't so easily changed:
  lots of code would break if it were set to anything other than 'XParser',
  so might as well hard-code it.

  Revision 1.63  2016/05/01 19:04:46  mdyck
  Hoist STATIC and LOOKAHEAD and FORCE_LA_CHECK options out of template "javacc-options",
  because jjtree.xsl shouldn't be able to override them,
  and shouldn't have to reiterate them.
  Consequently, rename the template to "other-javacc-options".

  Revision 1.62  2016/05/01 18:58:39  mdyck
  Template for g:grammar:
  move the "options {" text down to the next line,
  to make it more obvious.

  Revision 1.61  2016/05/01 18:47:46  mdyck
  Add some section-dividers.

  Revision 1.60  2016/05/01 18:40:12  mdyck
  Unfold the only invocation of template "common-token-action".

  Revision 1.59  2016/05/01 18:37:07  mdyck
  Unfold (modulo whitespace) the only invocation of template "set-parser-package".
  Ditto template "extra-parser-code".

  Revision 1.58  2016/05/01 18:24:47  mdyck
  Reorder some template declarations.
  (Put the "top-level" templates at the top of the stylesheet.)

  Revision 1.57  2016/05/01 18:08:49  mdyck
  Extract template "token-mgr-decls" from the template for g:grammar.

  Revision 1.56  2016/05/01 00:37:53  mdyck
  Remove some unused stuff.

  Revision 1.55  2011/05/24 23:33:46  mdyck
  Add <xsl:template match="g:tref">
  to check for extraneous token-references
  in the lexical state machine.

  In order to get it to fire,
  drop
      <xsl:template match="g:*" priority="-2000"/>
  and
      <xsl:template match="g:state-list"/>
  which then necessitates the addition of
      <xsl:template match="g:description"/>

  Revision 1.54  2011/05/23 23:22:24  mdyck
  In <xsl:template match="g:token">,
  unfold variables $otoken and $token.

  Revision 1.53  2011/05/23 22:40:48  mdyck
  In <xsl:template match="g:token">,
  drop support for @alias-for:
  we don't use it any more.

  Revision 1.52  2011/05/23 20:21:39  mdyck
  In <xsl:template match="g:token">,
  when there are 'conflicting' lexical transitions on a symbol:
  rather than raise an error, do state-switching in the lexical action.
  (See in-code comment for more details.)

  Revision 1.51  2011/05/20 00:10:07  mdyck
  In <xsl:template match="g:token">,
  restructure:
      <if test="foo">
          terminate
      <if>
      [stuff]
  into:
      <choose>
          <when test="not(foo)">
              [stuff]
          </when>
          <otherwise>
              terminate
          </otherwise>
      </choose>

  Revision 1.50  2011/05/19 23:56:13  mdyck
  In <xsl:template match="g:token">,
  minor refactorings:
  convert a one-arm <choose> into an <if>,
  and factor out $next_state.

  Revision 1.49  2011/05/19 23:47:17  mdyck
  In <xsl:template match="g:token">,
  eliminate dead code...

  In ../xpath-grammar.xml,
  @action (if set) is only ever 'popState' or 'pushState', so
      contains($action, '(')
  and
      normalize-space($action) = 'input_stream.backup'
  are never true.
  (And hopefully they won't ever need to be true again.)

  Revision 1.48  2011/05/19 23:24:08  mdyck
  In <xsl:template match="g:token">,
  factor out $transitions, and rename:
      $actions       -> $distinct_actions
      $nextLexStates -> $distinct_next_states

  Revision 1.47  2011/05/19 23:17:52  mdyck
  In <xsl:template match="g:token">,
  merge the two consistency-checks into one.

  Revision 1.46  2011/05/19 23:04:48  mdyck
  In <xsl:template match="g:token">,
  when we're looking for action-inconsistency,
  rather than collecting all actions
  and then comparing each against the first,
  use distinct-values() and see if it returns more than one.

  [Ditto all that for next-states.]

  Revision 1.45  2011/05/19 22:29:41  mdyck
  In <xsl:template match="g:token">,
  fix bug:

  We need to check that, for a given terminal symbol,
  the actions of all transitions on that symbol agree.

  Formerly, when we did so, we only checked that explicit
  'action' attributes agreed, but this ignored the possibility
  of implied (i.e. missing) 'action' attributes.

  To fix the bug, make $actions a sequence of strings (rather
  than attribute nodes), in which a missing 'action' attribute
  contributes the empty string.

  [Ditto all the above for next-states.]

  Revision 1.44  2011/05/19 21:53:11  mdyck
  Make javacc.xsl an XSLT 2.0 stylesheet.

  In <xsl:template match="g:token">,
  make some preliminary use of string-join().

  (More significant 2.0-isms to come.)

  Revision 1.43  2011/05/19 21:32:55  mdyck
  Prep for XSLT 2.0:

  In <xsl:template match="g:token">,
  rename variables
      $action       -> $actions
      $nextLexState -> $nextLexStates
  as a reminder that they can contain more than one item.

  Use an explicit "[1]" to get the first item.

  In <xsl:template match="g:exprProduction">,
  delete
      <xsl:with-param name="thisProd" select="$thisProd"/>
      <xsl:with-param name="nextProd" select="$nextProd"/>
  from call to template 'action-level-jjtree-label',
  since that template doesn't have those parameters.

  Revision 1.42  2011/05/19 19:42:51  mdyck
  In <xsl:template match="g:token">,
  do some minor tweaks,
  mostly just moving/adding comments and whitespace.

  Revision 1.41  2011/05/19 19:20:16  mdyck
  In <xsl:template match="g:token">,
  in the second loop over $trefs,
  we only do something at its first item.
  Moreover, what we do there is almost entirely
  unaffected by the particulars of that item.
  So dissolve the loop and the <if>,
  and unindent the content thereof.

  Revision 1.40  2011/05/19 18:48:43  mdyck
  In <xsl:template match="g:token">,
  in the second loop over $trefs,
  factor out $is_subterminal
  and unfold $state.

  Revision 1.39  2011/05/19 18:36:54  mdyck
  In <xsl:template match="g:token">,
  in the second loop over $trefs,
  there's a contorted way to detect the first item.
  Simplify it.

  Revision 1.38  2011/05/19 17:25:12  mdyck
  In <xsl:template match="g:token">,
  in the first loop over $trefs,
  do some minor tweaks:
   ~~ Change comment.
   ~~ Factor out $n_refs_in_state.
   ~~ Change "defined" to "referenced" in message.

  Revision 1.37  2011/05/19 17:17:48  mdyck
  In <xsl:template match="g:token">,
  split the loop over $trefs into two loops,
  and move one to a more appropriate spot.

  Revision 1.36  2011/05/19 16:36:55  mdyck
  In <xsl:template match="g:token">,
  variable $allTRefsOfName has the same value as $trefs,
  so drop the declaration of $allTRefsOfName
  and replace uses of $allTRefsOfName with $trefs.

  Revision 1.35  2011/05/19 07:55:24  mdyck
  <xsl:template match="g:token"> has this:

      <xsl:for-each select="$token">
          <xsl:for-each select="$trefs">
              ...
          </xsl:for-each>
      </xsl:for-each>

  where the inner <for-each> shadows any effect of the outer.
  So delete the outer tags.

  Revision 1.34  2011/05/19 07:22:48  mdyck
  In <xsl:template match="g:token">,
  add a comment about JavaCC's limitation re state transitions.

  Revision 1.33  2011/04/30 19:52:08  mdyck
  In <xsl:template match="g:token">,
  reword the "Transition not defined" error message.

  Revision 1.32  2011/02/27 09:35:25  mdyck
  Rename <xsl:key> 'ref' as 'map_name_to_defn'.

  Revision 1.31  2011/02/27 06:46:04  mdyck
  Phase out @token-kind values 'more' and 'special'...

  'more' and 'special' are JavaCC-specific;
  lex-like software doesn't seem to have analogs for them.

  xpath-grammar.xml doesn't even use 'more',
  and although it does use 'special',
  the generated parsers don't take advantage of it.
  I.e., they behave as if 'special' were 'skip'.

  So:

  In grammar.dtd, drop 'more' and 'special' from the decl for @token-kind.

  In xpath-grammar.xml, change uses of 'special' to 'skip'.

  In stylesheets,
      remove @token-kind='more' code, and
      change @token-kind='special' to @token-kind='skip'
      (or collapse it into existing 'skip'-handling code)

  Revision 1.30  2011/02/25 08:21:45  mdyck
  Attribute (of g:ref|g:xref)
      notational-only
  seems to have the same purpose as attribute (of g:token)
      exposition-only,
  so rename the former as the latter.

  (In javacc.xsl, this simplifies things, because there's
  already a blanket treatment of @exposition-only.)

  Revision 1.29  2011/02/25 01:56:14  mdyck
  Remove support for g:special and g:eof:
  they haven't existed for many years.

  Revision 1.28  2011/02/24 21:20:21  mdyck
  Now that xpath-grammar.xml doesn't use g:skip
  (and shouldn't ever need to again),
  remove support for it from DTD and stylesheets.

  Revision 1.27  2011/02/23 04:37:38  mdyck
  Re these attributes of g:token:
      special (no | yes) #IMPLIED
      more    (no | yes) #IMPLIED
      skip    (no | yes) #IMPLIED
  These declarations give the impression that any combination
  of settings is valid, but this is not the case:
  it only makes sense for (at most) one of them to be set to "yes"
  (which then determines the 'regexpr_kind' generated by javacc.xsl).

  So replace those three attributes with one:
      token-kind (special | skip | more) #IMPLIED
  and substitute:
      special='yes' -> token-kind='special'
      skip='yes'    -> token-kind='skip'
      more='yes'    -> token-kind='more'
  in
      xpath-grammar.xml
      parser/javacc.xsl
      lalr/lex.xsl
      extract-tokens.xsl

  Revision 1.26  2011/02/22 01:26:44  mdyck
  g:requiredSkip, g:optionalSkip:

  xpath-grammar.xml doesn't use them,
  hasn't for over 5 years,
  and probably never will again,
  so delete the element declarations from the DTD
  and any stylesheet code that still supports them.

  Revision 1.25  2011/02/19 08:44:12  mdyck
  g:include-transitions-of-state:
  Delete the element decl from grammar.dtd,
  and the small bit of code supporting it in javacc.xsl.

  xpath-grammar.xml doesn't use it, and probably never will.
  (And it gets in the way of some upcoming changes to javacc.xsl.)

  Revision 1.24  2011/02/12 09:04:40  mdyck
  In TOKEN_MGR_DECLS, delete obsolete stuff:

      persistentLexStates (already commented-out)

      PARENMARKER & pushParenState()

      offset

      isState()

  Revision 1.23  2010/12/28 09:48:16  mdyck
  popState():
  If (stateStack.size() == 0),
  don't call printLinePos(),
  instead throw a TokenMgrError.

  Revision 1.22  2010/12/28 06:20:06  mdyck
  checkCharRef():
  If Integer.parseInt() throws a NumberFormatException,
  re-throw it as a ParseException.

  Revision 1.21  2010/12/28 05:42:08  mdyck
  checkCharRef():
  Rather than overwrite the value of the 'ref' parameter,
  introduce the variable 'numeral'.
  Then use the parameter value in the error message.

  Revision 1.20  2010/12/28 03:04:50  mdyck
  checkCharRef():
  A character reference that doesn't identify a valid character
  isn't violating a *well-formedness constraint*
  (that term is appropriate for XML documents, not XQuery queries);
  it's an XQuery-defined static error.

  Revision 1.19  2010/10/17 07:55:38  mdyck
  Define & use SimpleNode.getChild() and SimpleNode.getParent(),
  to avoid a lot of explicit casting.

  Revision 1.18  2009/12/04 21:34:46  mdyck
  javacc.xsl, jjtree.xsl, and noast.xsl no longer
  make any use of the parameters $spec, $spec2, $spec3.
  (and really, shouldn't ever need to, given that
  they can access /g:grammar/g:language/@id).

  So remove all lingering traces of those parameters
  (just for those stylesheets).

  Revision 1.17  2009/12/04 02:48:43  mdyck
  Rename parser class 'XPath' as 'XParser'.
  (And lots of collateral renamings.)

  (The name 'XPath' is inappropriate for many of the parsers we build.)

  Revision 1.16  2009/12/04 02:05:15  mdyck
  Tweak indentation.

  Revision 1.14  2009/12/03 23:11:59  mdyck
  Rename symbol/method 'XPath2' as 'START'.

  ("XPath2" is inappropriate for most of the parsers we build.)

  Revision 1.13  2009/12/01 23:52:38  mdyck
  Eliminate the command-line option '-match':
  it's been years since it had any effect.

  Revision 1.12  2009/12/01 23:32:21  mdyck
  After the previous revision, the setting of isMatchParser
  makes no difference to the code that gets executed,
  so simplify the code and eliminate that variable.

  Also, m_isMatchPattern is no longer used, so eliminate it too.

  Revision 1.11  2009/12/01 20:43:53  mdyck
  Currently (and for the last few years),
  the value of $spec is never 'xpath', 'zpathx1', or 'zzpathx1'.
  (Closest is 'xpath1', recently changed from 'pathx1'.)
  So remove XSLT code that is conditional
  on $spec having any of those values.

  Revision 1.10  2009/11/29 22:08:42  mdyck
  javacc.xsl:
  When dealing with a g:postfix or g:prefix,
  put parentheses around the result of the 'outputChoices' call,
  because outputChoices won't necessarily supply them.
  (This is needed for XPath 1.0's UnaryExpr.)

  Revision 1.9  2009/06/15 16:57:49  mdyck
  Instead of testing whether /g:grammar/g:language/@id is 'xquery',
  generalize it to test whether the first 6 characters are 'xquery'.

  Revision 1.8  2009/05/21 08:56:04  mdyck
  Simplify some <xsl:choose> elements that
  hinge on the value of the $spec parameter.

  Revision 1.7  2009/04/20 01:20:28  mdyck
  In the template for "g:token|g:special",
  improve the error message re
  "Token multiply defined in same state".

  Revision 1.6  2009/04/14 06:57:30  mdyck
  Long lines in the input to jjtree cause huge indents in the
  output, which are an annoyance when trying to read the latter.
  One of the prime sources of long lines is a g:choice with lots
  of alternatives.  So, in the template rule for g:choice, put
  a linebreak before each '|'.

  (Surprisingly, this change also makes the build go about 4 times
  faster on my platform!)

  Revision 1.5  2008/07/08 15:06:26  jrobie3
  Grammar for XQuery 1.1 first public WD.

  Revision 1.4  2008/05/28 15:35:05  jrobie3
  Added more explanatory names for window vars.

  Revision 1.3  2008/04/14 14:01:36  jrobie3
  *** empty log message ***

  Revision 1.2  2007/07/13 22:56:55  sboag
  Added non-javacc version of parser, for xquery-update.

  Revision 1.1  2007/03/14 19:33:15  NormanWalsh
  Initial checkin

  Revision 1.16  2006/09/12 08:17:48  sboag
  Various changes.

  Revision 1.14  2006/06/08 22:50:29  sboag
  Fixed bug with trailing comments.  Also fixed the previous fix for escaped quotes and apos.

  Revision 1.13  2006/03/27 00:22:59  sboag
  Latest grammar changes, mainly update.

  Revision 1.12  2005/10/21 03:47:13  sboag
  Merge from LLK branch.

  Revision 1.11.2.6  2005/10/21 01:46:14  sboag
  XQueryX marches on.

  Revision 1.11.2.5  2005/10/08 21:19:11  sboag
  Fulltext implemented, and passes tests.  lookahead cleaned up.

  Revision 1.11.2.4  2005/10/08 03:58:15  sboag
  Basic tests pass.

  Revision 1.11.2.3  2005/10/07 17:25:30  sboag
  Fixes for processToken on binary and unary expression.

  Revision 1.11.2.2  2005/10/06 15:34:58  sboag
  Constructors in XQuery work.  States for constructors are re-instituted.
  Normally the LessThanOpOrTagO token ("<") always transitions to
  START_TAG (after pushing the existing state on a stack, because there
  are nesting issues), i.e. constructor content.  But in GeneralComp there is
  a parser-context-based lexical state switch to DEFAULT, which is
  somewhat dangerous and not reliable if lookahead is past this point.
  The alternatives have been very carefully considered!

  Revision 1.11.2.1  2005/10/04 15:08:33  sboag
  XPath Parser basically works.

  Revision 1.11  2005/08/18 14:26:12  sboag
  Just some debugging stuff.

  Revision 1.10  2005/07/28 01:39:28  sboag
  Folding in changes from branch LEXREFACTOR2

  Revision 1.9.2.1  2005/04/13 16:00:54  sboag
  First cut on restructuring of lexical states to take into account PROLOG and the lex states lex tag.
  Only XQuery compiles and passes tests.

  Revision 1.9  2004/12/14 17:44:53  sboag
  Change adapted in joint F2F Dec. 14 2004, A.1 change the grammar, *without* changing the language, to make
      the grammar easier to understand (this is what Martin wanted)

      {a) add URILiteral to be the same as the current StringLiteral

      (b) where StringLiteral is used in a context where a URI/IRI
          is expected, change teh grammar to use URILiteral.

  Revision 1.8  2004/06/02 13:46:25  sboag
  Tweak to handle double quotes in strings.

  Revision 1.7  2004/05/31 18:29:58  sboag
  Latest grammar changes, part of last call comments response.  (Sorry for lack
  of fine-grained detail, but CVS has been down for a week.)

  Revision 1.6  2004/01/26 02:04:09  sboag
  Removed some dead code.

  Revision 1.5  2004/01/25 22:16:51  sboag
  Updata language proposal integrated.  Note that the language conditional mechanism has changed a bit.

  Revision 1.4  2003/09/10 17:38:45  sboag
  Items from http://lists.w3.org/Archives/Member/w3c-query-editors/2003Sep/0028.html all addressed.  Some fixes for construction of AST.  Build target for test with formal XQuery test suite.

  Revision 1.4  2003/09/02 03:55:21  sboag
  Make isStep into a global, in order to make it possible for "dot" to be treated as a path expression (though it is now a primary expression).  Basic smoke test passes now, which is not to say I expect deeper testing to pass.

  Revision 1.3  2003/09/01 19:55:55  sboag
  Incremental checkin: basic PathExpressions seem to work (based only on test of foo/baz and foo()).

  Revision 1.2  2003/08/26 15:12:26  sboag
  On Lionel's advice, am removing the src directory and associated bat files.

  Revision 1.3  2003/07/08 16:03:49  sboag
  Add handling of exposition-only attribute.

  Revision 1.2  2003/04/18 19:27:46  sboag
  Fix problem with curly brace state transition for computed element and attribute constructors.

  Revision 1.1  2003/04/07 22:18:01  sboag
  Initial checkin of language build and parser build.

  Revision 1.19  2003/03/20 12:48:04  sboag
  no message

  Revision 1.18  2003/03/05 15:33:00  sboag
  Major changes for new SequenceType, etc.

  Revision 1.17  2003/02/10 23:01:33  sboag
  Implemented new alias-for attribute, which makes a token act as a sort of a
  proxy for another definition.  In the JavaCC transformation, this token acts as
  a true token for the sake of state transitioning.  In the BNF, the token is converted
  to the token it is acting as an alias for.

  Revision 1.16  2003/01/15 04:41:01  sboag
  Major update to redo the structure of the lexical specification in xpath-grammar.xml
  to make maintenence easier.  Also, fixed up the DTD so xpath-grammar.xml now
  validates.

  Revision 1.15  2002/11/29 17:20:57  sboag
  Minor changes for pathx1 parser.

  Revision 1.14  2002/11/06 07:42:25  sboag
  1) I did some work on BNF production numbering.  At least it is consecutive
  now in regards to the defined tokens.

  2) (XQuery only) I added URL Literal to the main list of literals, and added a
  short note that it is defined equivalently to string literal.  URL Literal has to
  exist right now for relatively esoteric purposes for transitioning the lexical
  state (to DEFAULT rather than OPERATOR as StringLiteral does).  It is
  used in DefaultCollationDecl, NamespaceDecl, SubNamespaceDecl, and
  DefaultNamespaceDecl.  To be clear, URL Literal was already in the August
  draft, I just added it to the list of literals in the main doc.

  Revision 1.13  2002/10/22 16:51:08  sboag
  New Grammar Issues List.  New productions:
  OrderBy, ComputedTextConstructor, PositionVar, Castable, As (TypeDecl).
  Removed:
  unordered, SortExpr
  Fixed reserved word bugs with:
  empty, stable
  Other minor "fixes":
  Change precedence of UnaryExpr to be looser binding than UnionExpr
  Change RangeExpr to only allow one "to".

  Revision 1.12  2002/07/28 19:54:13  sboag
  Fixed problems with import, '*', '?', and ',', reported by Jonathan and Dana.

  Revision 1.11  2002/07/18 01:17:39  sboag
  Fixed some bugs.

  Revision 1.10  2002/07/15 07:25:47  sboag
  Bug fixes, added match patterns, and responses to
  Don's email http://lists.w3.org/Archives/Member/w3c-xml-query-wg/2002Jul/0156.html.

  Revision 1.9  2002/06/28 09:02:07  sboag
  Merged Don's latest work with new grammar proposal.  Changes too numerous
  to detail.

  Revision 1.8  2002/03/17 21:31:08  sboag
  Made new grammar element, <next/> for use in primary or prefix expressions,
  to control when the next element is going to be called.  Somewhat experemental.

  Changed javacc stylesheet and bnf stylesheets to handle g:next.

  Fixed bugs with child::text(), by adding text, comment, etc., tokens to after forward
  or reverse axis.  (note: have to do the same to names after @).  This is yet
  another bad hack.

  Fixed bug with @type, by adding At token to lexical stateswitch into QNAME state
  for XQuery.

  Revision 1.7  2002/03/13 15:45:05  sboag
  Don changes (XPathXQuery.xml, introduction.xml, fragment.xml):
  I have attempted to update these files with the latest terminology
   (mainly changing "simple value" to "atomic value" and related changes.)

  Grammar changes:
  Moral equal of Philip Wadler's structural changes of 02/05/2002.
    Make lookahead(2) so that ElementNameOrFunctionCall can be broken up
    without using long tokens.
  Integrated Robie's SequenceType productions.
  Added Add Validate Production.
  Reviewed and tweaked changes against Named Typing proposal.
  Fixed Dana's bug about ContentElementConstructor and
     ContentAttributeConstructor in ElementContent.
  Allow multiple variable binding for some/every.
  Lift restrictions of "." and "..".
  add  XmlComment and XmlProcessingInstruction and also CdataSection to the
  		  Constructor production.
  Remove The Ref and Colon tokens.
  Made multiply & star one token for XQuery, in spite of the fact that this causes
  ambiguity.
  Remove XQUERY_COMMENT state that is never entered.
  Add QNAME lexical state for qnames following explicit axes, i.e. child::div.
  BUG: child::text() will fail in XQuery.
  BUG: Validate does not work so well for XPath.

  Revision 1.6  2002/03/06 12:40:55  sboag
  Tweak to make it possible to have prefix productions with optional suffixes.

  Revision 1.5  2001/12/09 22:07:16  sboag
  Fixed problem with comments from previous checkin.

 	-sb 10/29/01  Make parser productions extensible by an importing stylesheet.
 ==============  END CHANGE LOG ============== -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:g="http://www.w3.org/2001/03/XPath/grammar">

    <xsl:strip-space elements="*"/>
    <!-- workaround for Xalan bug. -->
    <xsl:preserve-space elements="g:char"/>

    <xsl:output method="text" encoding="iso-8859-1"/>

    <xsl:key name="map_name_to_defn" match="g:token|g:production"
            use="@name"/>

    <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template match="g:grammar">
        options {
            STATIC = false;
            LOOKAHEAD = 1;
            FORCE_LA_CHECK = true;
            <xsl:call-template name="other-javacc-options"/>
        }

        PARSER_BEGIN(XParser)
        <xsl:call-template name="parser-decls"/>
        PARSER_END(XParser)

        TOKEN_MGR_DECLS : {
            <xsl:call-template name="token-mgr-decls"/>
        }

        <xsl:call-template name="production-for-start-symbol"/>

        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="other-javacc-options"/>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="parser-decls">
        import java.io.*;
        import java.util.Stack;
        import java.util.Vector;
        import org.w3c.dom.Element;
        import org.w3c.dom.Document;
        import javax.xml.parsers.*;
        import org.w3c.dom.traversal.DocumentTraversal;
        import org.w3c.dom.traversal.NodeFilter;
        import org.w3c.dom.traversal.NodeIterator;
        import org.w3c.dom.traversal.TreeWalker;

        public class XParser {

            <xsl:if test="substring(/g:grammar/g:language/@id, 1, 6) = 'xquery'">
                void checkCharRef(String ref) throws ParseException
                {
                    String numeral = ref.substring(2, ref.length() - 1);
                    int val;
                    try {
                        if (numeral.charAt(0) == 'x') {
                            val = Integer.parseInt(numeral.substring(1), 16);
                        } else
                            val = Integer.parseInt(numeral);
                    } catch (NumberFormatException nfe) {
                        // "The string does not contain a parsable integer."
                        // Given the constraints imposed by the grammar/parser,
                        // I believe the only way this can happen is if the
                        // numeral is too long to fit in an 'int',
                        // which means that it's also too big to identify
                        // a valid character.
                        throw new ParseException(
                            "err:XQST0090: character reference does not identify a valid character: " + ref);
                    }

                    boolean isLegal = val == 0x9 || val == 0xA || val == 0xD
                        || (val &gt;= 0x20 &amp;&amp; val &lt;= 0xD7FF)
                        || (val &gt;= 0xE000 &amp;&amp; val &lt;= 0xFFFD)
                        || (val &gt;= 0x10000 &amp;&amp; val &lt;= 0x10FFFF);
                    if (!isLegal)
                        throw new ParseException(
                            "err:XQST0090: character reference does not identify a valid character: " + ref);
                }
            </xsl:if>


            public static void main(String args[])
                throws Exception
            {

                int numberArgsLeft = args.length;
                int argsStart = 0;
                boolean dumpTree = false;
                while (numberArgsLeft > 0) {
                    try {

                        if (args[argsStart].equals("-dumptree")) {
                            dumpTree = true;
                            argsStart++;
                            numberArgsLeft--;
                        } else if ("-file".equalsIgnoreCase(args[argsStart])) {
                            argsStart++;
                            numberArgsLeft--;
                            System.out.println("Running test for: " + args[argsStart]);
                            File file = new File(args[argsStart]);
                            argsStart++;
                            numberArgsLeft--;
                            Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                            XParser parser = new XParser(fis);
                            parser.Input();
                            // SimpleNode tree = parser.START();
                            // if (dumpTree)
                            //    tree.dump("|");
                        } else if (args[argsStart].endsWith(".xquery")) {
                            System.out.println("Running test for: " + args[argsStart]);
                            File file = new File(args[argsStart]);
                            argsStart++;
                            numberArgsLeft--;
                            Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                            XParser parser = new XParser(fis);
                            parser.Input();
                            // SimpleNode tree = parser.START();
                            // if (dumpTree)
                            //    tree.dump("|");
                        }         else if ("-catalog".equalsIgnoreCase(args[argsStart])) {
                            argsStart++;
                            numberArgsLeft--;
                            String catalogFileName = args[argsStart];
                            argsStart++;
                            numberArgsLeft--;
                            System.out.println("Running catalog for: "
                                + catalogFileName);
                            DocumentBuilderFactory dbf = DocumentBuilderFactory
                                .newInstance();
                            DocumentBuilder db = dbf.newDocumentBuilder();
                            Document doc = db.parse(catalogFileName);

                            NodeIterator testCases = ((DocumentTraversal) doc)
                                .createNodeIterator(doc, NodeFilter.SHOW_ELEMENT,
                                        new NodeFilter() {
                                            public short acceptNode(
                                                    org.w3c.dom.Node node) {
                                                String nm = node.getNodeName();
                                                return (nm.equals("test-case")) ? NodeFilter.FILTER_ACCEPT
                                                    : NodeFilter.FILTER_SKIP;
                                                }
                                        }, true);
                            org.w3c.dom.Element testCase;
                            int totalCount = 0;
                            Vector failedList = new Vector();
                            while ((testCase = (org.w3c.dom.Element) testCases
                                    .nextNode()) != null) {
                                NodeIterator queryies = ((DocumentTraversal) doc)
                                    .createNodeIterator(testCase,
                                        NodeFilter.SHOW_ELEMENT,
                                        new NodeFilter() {
                                            public short acceptNode(
                                                    org.w3c.dom.Node node) {
                                                String nm = node.getNodeName();
                                                return (nm.equals("query")) ? NodeFilter.FILTER_ACCEPT
                                                    : NodeFilter.FILTER_SKIP;
                                            }
                                        }, true);
                                org.w3c.dom.Element query;
                                while ((query = (org.w3c.dom.Element) queryies
                                        .nextNode()) != null) {
                                    String fileString = query.getAttribute("name");
                                    String locString = testCase
                                        .getAttribute("FilePath").replace('/',
                                            File.separatorChar);
                                    File catFile = new File(catalogFileName);
                                    String locCatFile = catFile.getParent();
                                    String absFileName = locCatFile + File.separator
                                        + "Queries" + File.separator + "XQuery"
                                        + File.separator + locString + fileString;

                                    if (dumpTree) {
                                        System.out.print("== ");
                                        System.out.print(absFileName);
                                        System.out.println(" ==");
                                    } else
                                        System.out.print(".");

                                    boolean isParseError = false;
                                    String scenario = testCase.getAttribute("scenario");
                                    if (scenario.equals("parse-error"))
                                        isParseError = true;

                                    totalCount++;

                                    try {
                                        File file = new File(absFileName);
                                        Reader fis = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                                        XParser parser = new XParser(fis);
                                        // SimpleNode tree =
                                        parser.Input();
                                        if(isParseError)
                                            failedList.addElement(fileString);
                                        // if (dumpTree)
                                        //    tree.dump("|");
                                    } catch (Exception e) {
                                        if(!isParseError)
                                            failedList.addElement(fileString);
                                    } catch (Error e2) {
                                        if(!isParseError)
                                            failedList.addElement(fileString);
                                    }

                                }

                            }
                            System.out.println();
                            if(failedList.size() > 0)
                            {
                                System.out.print("FAILED: ");
                                for(int i = 0; i &lt; failedList.size(); i++)
                                {
                                    String fname = (String)failedList.elementAt(i);
                                    System.out.print(fname);
                                    if((i+1) != failedList.size())
                                        System.out.print(", ");
                                }
                                System.out.println();
                                System.out.print("Failed "+failedList.size()+" out of ");
                            }
                            else
                            {
                                System.out.print("Total Success!! ");
                            }
                            System.out.println(totalCount+" cases");

                        }

                        else
                        {
                            for(int i = argsStart; i &lt; args.length; i++)
                            {
                                System.out.println();
                                System.out.println("Test["+i+"]: "+args[i]);
                                Reader fis = new BufferedReader(new InputStreamReader(new java.io.StringBufferInputStream(args[i]), "UTF-8"));
                                XParser parser = new XParser(fis);
                                // SimpleNode tree;
                                // tree =
                                parser.Input();
                                // tree.getChild(0).dump("|") ;
                                break;
                            }
                            System.out.println("Success!!!!");
                        }
                    }
                    catch(Exception pe)
                    {
                        System.err.println(pe.getMessage());
                    }
                    return;
                }
                    java.io.DataInputStream dinput = new java.io.DataInputStream(System.in);
                    while(true)
                    {
                      try
                      {
                          System.err.println("Type Expression: ");
                          String input =  dinput.readLine();
                          if(null == input || input.trim().length() == 0)
                            break;
                          XParser parser = new XParser(new BufferedReader(new InputStreamReader(new java.io.StringBufferInputStream(input), "UTF-8")));
                  // SimpleNode tree;
                            // tree =
                            parser.Input();
                          // tree.getChild(0).dump("|") ;
                      }
                      // catch(ParseException pe)
                      // {
                      //     System.err.println(pe.getMessage());
                      // }
                      catch(Exception e)
                      {
                        System.err.println(e.getMessage());
                      }
                    }
            }
        }
    </xsl:template>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="token-mgr-decls">
        <xsl:variable name="debugTokenStates" select="false()"/>

            public Stack stateStack = new Stack();

            /**
              * Push the current state onto the state stack.
              */
            private void pushState()
            {
                <xsl:if test="$debugTokenStates">System.err.println("pushing: "+lexStateNames[curLexState]); printLinePos();</xsl:if>
                stateStack.addElement(new Integer(curLexState));
            }

            /**
              * Push the given state onto the state stack.
              * @param state Must be a valid state.
              */
            private void pushState(int state)
            {
                <xsl:if test="$debugTokenStates">System.err.println("push "+lexStateNames[state]); printLinePos();</xsl:if>
                stateStack.push(new Integer(state));
            }

            /**
              * Pop the state on the state stack, and switch to that state.
              */
            private void popState()
            {
                if (stateStack.size() == 0)
                {
                    // E.g., a would-be query consisting of a single right curly brace.
                    throw new TokenMgrError(
                        "On line " + input_stream.getEndLine() + ","
                        + " the expression contains an 'ending' construct"
                        + " (e.g., a right-brace or end-tag)"
                        + " for which the corresponding 'starting' construct does not appear.",
                        TokenMgrError.LEXICAL_ERROR
                    );
                }

                int nextState = ((Integer) stateStack.pop()).intValue();
                <xsl:if test="$debugTokenStates">System.err.println("pop "+lexStateNames[nextState]); printLinePos();</xsl:if>
                SwitchTo(nextState);
            }

            /**
              * Print the current line position.
              */
            public void printLinePos()
            {
                System.err.println("Line: " + input_stream.getEndLine());
            }
    </xsl:template>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template name="production-for-start-symbol">
        void Input() :
        {}
        {
            <xsl:value-of select="g:start/@name"/>()&lt;EOF&gt;
        }
    </xsl:template>

    <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template match="g:*[@exposition-only='yes']"
            priority="+2000"/>

    <!-- Action templates for overrides from derived stylesheets -->

    <!-- xsl:template name="action-production-end">
    </xsl:template -->

    <xsl:template name="action-exprProduction">
    </xsl:template>

    <xsl:template name="action-exprProduction-assign">
    </xsl:template>

    <xsl:template name="action-exprProduction-label">
    </xsl:template>

    <xsl:template name="action-exprProduction-end">
    </xsl:template>

    <xsl:template match="g:level" mode="action-level">
    </xsl:template>

    <xsl:template name="action-level-jjtree-label"></xsl:template>
    <xsl:template name="binary-action-level-jjtree-label"></xsl:template>

    <xsl:template name="action-level-start">
    </xsl:template>

    <xsl:template match="*" mode="action-level-end">
    </xsl:template>

    <xsl:template name="action-token-ref">
    </xsl:template>

    <!-- Begin LV -->
    <xsl:template match="g:ref" mode="user-action-ref-start">
    </xsl:template>

    <xsl:template match="g:ref|g:string" mode="user-action-ref-end">
    </xsl:template>
    <!-- End LV -->

    <xsl:template match="g:sequence[not(*)]" priority="10"/>

    <xsl:template match="g:choice[count(*) = 1]" priority="100">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!--  END SB CHANGE: Make parser productions extensible by an importing stylesheet -->


    <xsl:template match="g:description"/>

    <xsl:template match="g:tref">
        <xsl:if test="not(key('map_name_to_defn', @name))">
            <xsl:message>Warning: No referent found for g:tref/@name="<xsl:value-of select="@name"/>"</xsl:message>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:token">

        <xsl:variable name="tname" select="@name"/>
        <xsl:variable name="trefs"
                select="/g:grammar/g:state-list//g:tref[@name=$tname]"/>

        <!-- At this time, flag an error if the token is not defined in the
        transition tables! -->
        <xsl:if test="not($trefs)">
            <xsl:message terminate="yes">
                <xsl:text>g:state-list does not contain any &lt;g:tref name="</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>"/&gt;&#10;</xsl:text>
                <!-- xsl:for-each select="/g:grammar/g:state-list//g:tref">
                    <xsl:value-of select="@name"/>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each -->
            </xsl:message>
        </xsl:if>

        <!-- Error if the token is referenced more than once from any given state. -->
        <xsl:for-each select="$trefs">
            <xsl:variable name="state" select="ancestor::g:state"/>
            <xsl:variable name="n_refs_in_state" select="count($state//g:tref[@name=$tname])"/>
            <xsl:if test="$n_refs_in_state > 1">
                <xsl:message terminate="yes">
                    <xsl:text>Token '</xsl:text>
                    <xsl:value-of select="$tname"/>
                    <xsl:text>' is referenced </xsl:text>
                    <xsl:value-of select="$n_refs_in_state"/>
                    <xsl:text> times in state '</xsl:text>
                    <xsl:value-of select="$state/@name"/>
                    <xsl:text>'</xsl:text>
                </xsl:message>
            </xsl:if>
        </xsl:for-each>

        <xsl:variable name="is_subterminal" select="$trefs[1]/ancestor::g:state/@name='ANY'"/>

        <xsl:text>&#10;</xsl:text>

        <!--
            List the states in which this symbol can be recognized
            (unless it's a subterminal symbol, which can be used in any state).
        -->
        <xsl:if test="not($is_subterminal)">
            <xsl:text>&lt;</xsl:text>
            <xsl:value-of select="string-join($trefs/ancestor::g:state/@name, ', ')"/>
            <xsl:text>&gt;&#10;</xsl:text>
        </xsl:if>

        <!-- Give the symbol's token-type: -->
        <xsl:choose>
            <xsl:when test="./@token-kind='skip'">
                <xsl:text>SKIP </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>TOKEN </xsl:text>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:text>:&#10;{&#10;</xsl:text>

        <!-- Give the symbol's name & definition: -->
        <xsl:text> &lt; </xsl:text>
        <xsl:if test="$is_subterminal">#</xsl:if>
        <xsl:value-of select="$tname"/>
        <xsl:text> : </xsl:text>
        <xsl:call-template name="apply-subtree"/>
        <xsl:text> &gt;</xsl:text>

        <!-- Give the symbol's effect on the state machine: -->

        <!--
            In the input to JavaCC, if there are multiple state transitions
            on a given terminal symbol, JavaCC wants them all to agree.
            That is, they can have different starting-states, but they have to
            either:
            (a) all go to the same ending-state, or
            (b) all cause no change in state.

            However, there are cases where, on the face of it, we have a symbol
            with "disagreeing" transitions.  For instance:
              in the DEFAULT state, a QName causes a transition to DEFAULT, but
              in the PRAGMA_1 state, a QName causes a transition to PRAGMA_2.

            Formerly, we would accommodate JavaCC's limitation by creating
            (in the grammar) one or more ad hoc aliases of the symbol,
            one for each of the different transitions, and then tweaking the
            grammar to expect these new symbols at the appropriate points.

            Instead, we now handle cases of conflicting transitions by generating
            state-switching code in the 'lexical action' of the token decl.
        -->

        <xsl:variable name="transitions" select="$trefs/ancestor::g:transition"/>
        <xsl:variable name="distinct_actions" select="distinct-values($transitions/string(@action))"/>
        <xsl:variable name="distinct_next_states" select="distinct-values($transitions/string(@next-state))"/>

        <xsl:choose>
            <xsl:when test="
                count($distinct_actions) eq 1
                and
                count($distinct_next_states) eq 1
            ">
                <xsl:variable name="action" select="$distinct_actions[1]"/>
                <xsl:if test="$action">
                    <xsl:text> { </xsl:text>
                    <xsl:value-of select="$action"/>
                    <xsl:text>(); }</xsl:text>
                </xsl:if>

                <xsl:variable name="next_state" select="$distinct_next_states[1]"/>
                <xsl:if test="$next_state">
                    <xsl:text> : </xsl:text>
                    <xsl:value-of select="$next_state"/>
                </xsl:if>
            </xsl:when>

            <xsl:otherwise>
                <xsl:text> {&#10;</xsl:text>
                <xsl:for-each select="$transitions">
                    <xsl:text>    if ( curLexState == </xsl:text>
                    <xsl:value-of select="./ancestor::g:state/@name"/>
                    <xsl:text> ) { </xsl:text>

                    <xsl:if test="@action">
                        <xsl:value-of select="@action"/>
                        <xsl:text>(); </xsl:text>
                    </xsl:if>

                    <xsl:if test="@next-state">
                        <xsl:text>SwitchTo(</xsl:text>
                        <xsl:value-of select="@next-state"/>
                        <xsl:text>); </xsl:text>
                    </xsl:if>

                    <xsl:text>} else&#10;</xsl:text>
                </xsl:for-each>
                <xsl:text>    { assert false; }&#10;</xsl:text>
                <xsl:text>  } </xsl:text>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&#10;}&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="g:char|g:string" mode="user-action-ref-start">
    </xsl:template>

    <xsl:template match="g:char|g:string">

        <xsl:if test="self::g:string[ancestor::g:production or ancestor::g:exprProduction]">
            <xsl:apply-templates select="." mode="user-action-ref-start"/>
        </xsl:if>
        <xsl:if test="@complement='yes'">
            <xsl:text>~</xsl:text>
        </xsl:if>
        <xsl:text>"</xsl:text>
        <xsl:call-template name="replace-char">
            <xsl:with-param name="string" select="."/>
            <xsl:with-param name="from" select="'&quot;'"/>
            <xsl:with-param name="to" select="'\&quot;'"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
        <xsl:if test="self::g:string[ancestor::g:production or ancestor::g:exprProduction]">
            <xsl:call-template name="action-token-ref"/>
        </xsl:if>
        <xsl:if test="self::g:string[ancestor::g:production or ancestor::g:exprProduction]">
            <xsl:apply-templates select="." mode="user-action-ref-end"/>
        </xsl:if>

    </xsl:template>

    <!-- For some reason, the JavaCC generated lexer produces a lexical error for a "]" if
        we use ]]> as a single token. -->
    <xsl:template match="g:string[.=']]&gt;']">
        <xsl:text>("]" "]" ">")</xsl:text>
    </xsl:template>

    <xsl:template match="g:string[@ignoreCase]">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ignore-case">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

    <xsl:template name="ignore-case">
        <xsl:param name="string" select="''"/>
        <xsl:if test="$string">
            <xsl:variable name="c" select="substring($string,1,1)"/>
            <xsl:variable name="uc" select="translate($c,$lower,$upper)"/>
            <xsl:variable name="lc" select="translate($c,$upper,$lower)"/>
            <xsl:choose>
                <xsl:when test="$lc=$uc">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$c"/>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>["</xsl:text>
                    <xsl:value-of select="$uc"/>
                    <xsl:text>", "</xsl:text>
                    <xsl:value-of select="$lc"/>
                    <xsl:text>"]</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="substring($string,2)">
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:if>
            <xsl:call-template name="ignore-case">
                <xsl:with-param name="string" select="substring($string,2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="g:charCode">
        <xsl:text>"</xsl:text>
        <xsl:choose>
            <xsl:when test="@value='000A'">
                <xsl:text>\n</xsl:text>
            </xsl:when>
            <xsl:when test="@value='000D'">
                <xsl:text>\r</xsl:text>
            </xsl:when>
            <xsl:when test="@value='0009'">
                <xsl:text>\t</xsl:text>
            </xsl:when>
            <xsl:when test="@value='0020'">
                <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\u</xsl:text>
                <xsl:value-of select="@value"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="g:charClass">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="g:charRange">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="@minChar"/>
        <xsl:text>" - "</xsl:text>
        <xsl:value-of select="@maxChar"/>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="g:charCodeRange">
        <xsl:text>"\u</xsl:text>
        <xsl:value-of select="@minValue"/>
        <xsl:text>" - "\u</xsl:text>
        <xsl:value-of select="@maxValue"/>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="g:complement">~<xsl:apply-templates/></xsl:template>

    <xsl:template match="g:production" mode="production-java-block">
    </xsl:template>

    <xsl:template match="g:production" mode="production-return-block">
    </xsl:template>

    <xsl:template match="g:production" mode="production-annotations">
        <xsl:choose>
            <xsl:when test="@is-binary='yes'">
                <xsl:call-template name="action-level-jjtree-label"/>
            </xsl:when>
            <xsl:when test="@node-type">
                <xsl:call-template name="action-level-jjtree-label">
                    <xsl:with-param name="label" select="@node-type"/>
                    <xsl:with-param name="condition" select="@condition"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Begin LV -->
            <xsl:when test="@condition">
                <xsl:call-template name="action-level-jjtree-label">
                    <xsl:with-param name="label" select="@name"/>
                    <xsl:with-param name="condition" select="@condition"/>
                </xsl:call-template>
            </xsl:when>
            <!-- End LV -->
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:production" mode="production-return-type">
        <xsl:text>void</xsl:text>
    </xsl:template>

    <xsl:template match="g:production" mode="production-parameter-list">
    </xsl:template>

    <xsl:template match="g:production">
        <xsl:apply-templates select='.' mode="production-return-type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select='.' mode="production-parameter-list"/>
        <xsl:text>) </xsl:text>
        <xsl:apply-templates select="." mode="production-annotations"/>
        <xsl:text> :</xsl:text>
        {<xsl:apply-templates select="." mode="production-java-block"/>}
        {
            <xsl:call-template name="apply-subtree"/>
            <xsl:apply-templates select="." mode="production-return-block"/>
        }

    </xsl:template>

    <xsl:template name="apply-subtree">
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="g:level" mode="binary-e1-assign"/>
    <xsl:template match="g:level" mode="binary-e1-javablock"/>
    <xsl:template match="g:level" mode="binary-e2-assign"/>
    <xsl:template match="g:level" mode="binary-e2-javablock"/>

    <xsl:template match="g:exprProduction | g:level" mode="exprProduction-parameter-list">
    </xsl:template>

    <xsl:template match="g:level | g:exprProduction" mode="production-return-type">
        <xsl:text>void</xsl:text>
    </xsl:template>

    <xsl:template match="g:level | g:exprProduction" mode="production-annotations">
    </xsl:template>

    <xsl:template match="g:*" mode="exprProduction-ref-argument-list">
    </xsl:template>

    <xsl:template match="g:exprProduction">
        <xsl:variable name="name"
            select="@name"/><xsl:apply-templates select="." mode="production-return-type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$name"/>(<xsl:apply-templates select='.' mode="exprProduction-parameter-list"/>
        <xsl:text>) </xsl:text>
        <xsl:call-template name="action-exprProduction-label"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="production-annotations"/>
        <xsl:text>: </xsl:text>
        {<xsl:call-template name="action-exprProduction"/>}
        {
            <xsl:variable name="levels" select="g:level[*]"/>
            <xsl:variable name="argsToFirst">
                <xsl:apply-templates select="$levels[1]/*" mode="exprProduction-ref-argument-list"/>
            </xsl:variable>
            <xsl:variable name="nextProd" select="concat($levels[1]/*/@name,'(', $argsToFirst,')')"/>
            <xsl:call-template name="action-exprProduction-assign"/>
            <xsl:value-of select="$nextProd"/>
            <xsl:call-template name="action-exprProduction-end"/>
        }

        <xsl:for-each select="g:level[*]">
            <!-- xsl:variable name="thisProd" select="concat($name,'_',position(),'()')"/>
            <xsl:variable name="nextProd" select="concat($name,'_',position()+1,'()')"
            / -->
            <xsl:variable name="params">
                <xsl:apply-templates select='.' mode="exprProduction-parameter-list"/>
            </xsl:variable>

            <xsl:variable name="thisProd" select="concat(*/@name,'(', $params, ')')"/>
            <xsl:variable name="levels" select="../g:level[*]"/>
            <xsl:variable name="position" select="position()"/>

            <xsl:variable name="argsToNext">
                <xsl:apply-templates select="$levels[$position+1]/*" mode="exprProduction-ref-argument-list"/>
            </xsl:variable>
            <xsl:variable name="nextProd" select="concat($levels[$position+1]/*/@name,'(', $argsToNext, ')')"/>
            <xsl:apply-templates select='.' mode="production-return-type"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$thisProd"/>
            <xsl:call-template name="action-level-jjtree-label">
                <xsl:with-param name="label">
                    <xsl:choose>
                        <xsl:when test="@node-type">
                            <xsl:value-of select="@node-type"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <!-- <xsl:when test="not(g:binary) and */g:sequence"> SMPG -->
                                <xsl:when test="g:binary or */g:sequence">
                                    <xsl:value-of select="*/@name"/>
                                    <!-- xsl:text>void</xsl:text -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>void</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>

                <!-- Begin SMPG -->
                <xsl:with-param name="condition">
                    <xsl:choose>
                        <xsl:when test="g:binary or */g:sequence or */g:choice">
                            <xsl:value-of select="*/@condition"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:with-param>
                <!-- End SMPG -->

            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="." mode="production-annotations"/>
            <xsl:text>: </xsl:text>
            {<xsl:apply-templates select="." mode="action-level">
                <xsl:with-param name="thisProd" select="$thisProd"/>
                <xsl:with-param name="nextProd" select="$nextProd"/>
                </xsl:apply-templates>}
            {
                <xsl:call-template name="action-level-start"/>
                <xsl:choose>
                    <xsl:when test="g:binary and g:postfix">
                        <xsl:value-of select="$nextProd"/>
                        <xsl:text> ((</xsl:text>

                        <xsl:call-template name="outputChoices">
                            <xsl:with-param name="choices"
                                select="g:binary"/>
                            <xsl:with-param name="lookahead" select="ancestor-or-self::*/@lookahead"/>
                        </xsl:call-template>
                        <xsl:text xml:space="preserve"> </xsl:text>
                        <xsl:value-of select="$nextProd"/>
                        <!-- xsl:value-of select="concat($name,'_1')"/><xsl:text>()</xsl:text -->

                        <xsl:call-template name="binary-action-level-jjtree-label">
                            <xsl:with-param name="label" select="*/@name"/>
                            <xsl:with-param name="which" select="1"/>
                        </xsl:call-template>

                        <xsl:text>) | </xsl:text>

                        <xsl:call-template name="outputChoices">
                            <xsl:with-param name="choices"
                                select="g:postfix"/>
                            <xsl:with-param name="lookahead" select="ancestor-or-self::*/@lookahead"/>
                        </xsl:call-template>
                        <xsl:text>)*</xsl:text>
                    </xsl:when>

                    <xsl:when test="g:binary">
                        <xsl:apply-templates select="." mode="binary-e1-assign"/>
                        <xsl:value-of select="$nextProd"/>
                        <xsl:apply-templates select="." mode="binary-e1-javablock"/>

                        <xsl:text> (</xsl:text>
                        <xsl:call-template name="outputChoices">
                            <xsl:with-param name="choices"
                                select="g:binary"/>
                            <xsl:with-param name="lookahead" select="ancestor-or-self::*/@lookahead"/>
                        </xsl:call-template>

                        <xsl:text xml:space="preserve"> </xsl:text>

                        <xsl:apply-templates select="." mode="binary-e2-assign"/>
                        <xsl:value-of select="$nextProd"/>
                        <xsl:apply-templates select="." mode="binary-e2-javablock"/>
                        <xsl:call-template name="binary-action-level-jjtree-label">
                            <xsl:with-param name="label" select="*/@name"/>
                            <xsl:with-param name="which" select="2"/>
                        </xsl:call-template>
                        <!-- xsl:value-of select="concat($name,'_1')"/><xsl:text>()</xsl:text -->

                        <!--
                        <xsl:variable name="thisName" select="g:binary/@name"/>
                        <xsl:text>(</xsl:text>
                        <xsl:for-each select="../g:level[*]">
                            <xsl:variable name="theExprName" select="concat($name,'_',position(),'()')"/>
                            <xsl:if test="not(*/@name = $thisName)">
                                <xsl:value-of select="$theExprName"/>
                                <xsl:if test="not(last()=position())"> | </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                        -->

                        <xsl:text>)</xsl:text>
                        <xsl:choose>
                            <xsl:when test="g:binary/@prefix-seq-type">
                                <xsl:value-of select="g:binary/@prefix-seq-type"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>*</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>
                    <xsl:when test="g:postfix">
                        <xsl:if test="following-sibling::g:level">
                            <xsl:apply-templates select="." mode="binary-e1-assign"/>
                            <xsl:value-of select="$nextProd"/>
                            <xsl:apply-templates select="." mode="binary-e1-javablock"/>
                        </xsl:if>
                        <xsl:text xml:space="preserve"> </xsl:text>
                        <xsl:text>(</xsl:text>
                        <xsl:call-template name="outputChoices">
                            <xsl:with-param name="choices"
                                select="g:postfix"/>
                        </xsl:call-template>
                        <xsl:text>)</xsl:text>
                        <xsl:choose>
                            <xsl:when test="g:postfix/@prefix-seq-type">
                                <xsl:value-of select="g:postfix/@prefix-seq-type"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>*</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>
                    <xsl:when test="g:prefix">
                        <xsl:choose>
                            <xsl:when test="g:prefix/@suffix-optional='yes'">
                                <xsl:text>(</xsl:text>
                                <xsl:call-template name="outputChoices">
                                    <xsl:with-param name="choices"
                                        select="g:prefix"/>
                                </xsl:call-template>
                                <xsl:text>(</xsl:text>
                                <xsl:value-of select="$nextProd"/>
                                <xsl:text>)</xsl:text>
                                <xsl:text>? </xsl:text>
                                <xsl:value-of select="$nextProd"/>
                                <xsl:text>)</xsl:text>

                                <xsl:text> | </xsl:text>
                                <xsl:if test="not(g:prefix//g:next)">
                                    <xsl:value-of select="$nextProd"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>(</xsl:text>
                                <xsl:call-template name="outputChoices">
                                    <xsl:with-param name="choices"
                                        select="g:prefix"/>
                                </xsl:call-template>
                                <xsl:text>)</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="g:prefix/@prefix-seq-type">
                                        <xsl:value-of select="g:prefix/@prefix-seq-type"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>*</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <xsl:if test="not(g:prefix//g:next)">
                                    <xsl:apply-templates select="." mode="binary-e1-assign"/>
                                    <xsl:value-of select="$nextProd"/>
                                    <xsl:apply-templates select="." mode="binary-e1-javablock"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="g:primary">
                        <xsl:call-template name="outputChoices">
                            <xsl:with-param name="choices"
                                select="g:primary"/>
                        </xsl:call-template>
                        <xsl:if test="g:primary/following-sibling::g:level | following-sibling::g:level">
                            <xsl:text> | </xsl:text>
                            <xsl:value-of select="$nextProd"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="." mode="action-level-end"/>
            }

        </xsl:for-each>
    </xsl:template>

    <xsl:template name="outputChoices">
        <xsl:param name="choices" select="/.."/>
        <xsl:param name="lookahead" select="ancestor-or-self::*/@lookahead"/>

        <xsl:if test="count($choices)>1">(</xsl:if>
        <xsl:for-each select="$choices">
            <xsl:if test="position()!=1"> | </xsl:if>
            <xsl:if test="count(*)>1">(</xsl:if>
            <xsl:for-each select="*">
                <xsl:if test="position()!=1" xml:space="preserve">  </xsl:if>
                <xsl:apply-templates select="."><xsl:with-param name="lookahead" select="$lookahead"/></xsl:apply-templates>
            </xsl:for-each>
            <xsl:if test="count(*)>1">)</xsl:if>
        </xsl:for-each>
        <xsl:if test="count($choices)>1">)</xsl:if>
    </xsl:template>

    <xsl:template match="g:choice">
        <xsl:text>(</xsl:text>
        <xsl:variable name="lookahead">
            <xsl:call-template name="lookahead"/>
        </xsl:variable>
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <!--
                Long lines in the input to jjtree cause huge indents in the output.
                One of the prime sources of long lines is a g:choice with lots of
                alternatives.  So put a linebreak before each '|'.
                -->
                <xsl:text>
                | </xsl:text>
            </xsl:if>
            <xsl:value-of select="$lookahead"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template match="g:optional">
        <xsl:text>[</xsl:text>
        <xsl:call-template name="lookahead"/>
        <xsl:call-template name="apply-subtree"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="g:token//g:optional">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="lookahead"/>  <!-- was commented out - why? -->
        <xsl:call-template name="apply-subtree"/>
        <xsl:text>)?</xsl:text>
    </xsl:template>

    <xsl:template match="g:zeroOrMore">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="lookahead"/>
        <xsl:call-template name="apply-subtree"/>
        <xsl:text>)*</xsl:text>
    </xsl:template>

    <xsl:template match="g:oneOrMore">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="lookahead"/>
        <xsl:call-template name="apply-subtree"/>
        <xsl:text>)+ </xsl:text>
    </xsl:template>

    <xsl:template match="g:sequence">
        <xsl:if test="parent::g:choice[count(*) > 1]">
            <xsl:call-template name="lookahead"/>
        </xsl:if> (
    <xsl:call-template name="apply-subtree"/>)</xsl:template>

    <xsl:template name="process-token-user-action">
        <xsl:choose>
            <xsl:when test="ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
                <xsl:choose>
                    <xsl:when test="@token-user-action">
                        {<xsl:value-of select="@token-user-action"/>
                        <xsl:apply-templates select="." mode="user-action-ref-end">
                            <xsl:with-param name="addEnclose" select="false()"/>
                        </xsl:apply-templates>}
                    </xsl:when>
                    <xsl:otherwise><xsl:apply-templates select="." mode="user-action-ref-end"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="." mode="user-action-ref-end"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- xsl:template match="g:ref|g:string" mode="user-action-ref-end">
        <xsl:if test="ancestor::g:binary or ancestor-or-self::g:*/@is-binary='yes'">
            <xsl:text>{</xsl:text>
            <xsl:if test="@token-user-action">
                <xsl:value-of select="@token-user-action"/>
            </xsl:if>
            <xsl:text> /* jjtThis.processToken(token); */</xsl:text>
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template -->

    <xsl:template match="g:ref" mode="ref-argument-list">
    </xsl:template>

    <xsl:template match="g:ref">
        <xsl:call-template name="lookahead"/>
        <xsl:choose>
            <xsl:when test="key('map_name_to_defn',@name)/self::g:token">
                <xsl:apply-templates select="." mode="user-action-ref-start"/>
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&gt;</xsl:text>
                <xsl:call-template name="process-token-user-action"/>

                <!-- show when a token match is a success.  -sb -->
                <xsl:if test="ancestor::g:level | ancestor::g:production">
                    <xsl:call-template name="action-token-ref"/>
                    <xsl:if test="ancestor::g:binary">
                        <!-- xsl:value-of select="$nextProd"/ -->

                        <!-- Awww... it's not so bad... -sb -->
                        <xsl:if test="false()">
                            <xsl:variable name="levels" select="ancestor::g:exprProduction/g:level[*]"/>
                            <xsl:variable name="position" select="count(ancestor::g:level/preceding-sibling::g:level[*])+1"/>
                            <xsl:variable name="nextProd" select="concat($levels[$position+1]/*/@name,'()')"/>

                            <!-- xsl:variable name="nextProd" select="concat(ancestor::g:exprProduction/@name,
                                '_',  count(ancestor::g:level/preceding-sibling::g:level[*])+2,'()')"/ -->

                            <!-- xsl:value-of select="concat(ancestor::g:exprProduction/@name,'_1')"/ -->
                            <!-- xsl:text>()</xsl:text -->
                            <xsl:value-of select="$nextProd"/>

                            <xsl:call-template name="binary-action-level-jjtree-label">
                                <xsl:with-param name="which" select="3"/>
                            </xsl:call-template>
                            <xsl:text>
                            </xsl:text>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- Begin LV -->
                <xsl:apply-templates select="." mode="user-action-ref-start"/>
                <!-- End LV -->

                <xsl:value-of select="@name"/>
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="." mode="ref-argument-list"/>
                <xsl:text>)</xsl:text>

                <!-- Begin LV -->
                <xsl:apply-templates select="." mode="user-action-ref-end"/>
                <!-- End LV -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="g:next">
        <!-- The assumption is this we're in a exprProduction,
        in a prefix, primary, etc., and want to call the next level. -->
        <xsl:variable name="levels" select="ancestor::g:exprProduction[1]/g:level[*]"/>
        <xsl:variable name="position">
            <xsl:variable name="uniqueIdOfThisLevel" select="generate-id(ancestor::g:level[1])"/>
            <xsl:for-each select="$levels">
                <xsl:if test="generate-id(.) = $uniqueIdOfThisLevel">
                    <xsl:value-of select="position()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="nextProd" select="concat($levels[$position+1]/*/@name,'()')"/>
        <xsl:value-of select="$nextProd"/>
        <!-- xsl:text>()</xsl:text -->
    </xsl:template>

    <!-- xsl:template match="g:choice" mode="binary">
        <xsl:param name="name"/>
        <xsl:text>(</xsl:text>
        <xsl:for-each select="*">
            <xsl:if test="position()!=1">
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="."/>
            <xsl:value-of select="$name"/><xsl:text>()</xsl:text>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
    </xsl:template -->

    <xsl:template name="lookahead" match="lookahead">
        <xsl:if test="@lookahead">
            <xsl:if test="ancestor::g:token">
                <xsl:message terminate="yes">
                    <xsl:text>lookahead can only be specified in productions! </xsl:text>
                    <xsl:value-of select="ancestor::g:token/@name"/>
                </xsl:message>
            </xsl:if>
            <xsl:text>LOOKAHEAD(</xsl:text>
            <xsl:value-of select="@lookahead"/>
            <xsl:text>) </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="replace-char">
        <xsl:param name="from" select="''"/>
        <xsl:param name="to" select="''"/>
        <xsl:param name="string" select="''"/>
        <xsl:if test="$string">
            <xsl:choose>
                <xsl:when test="substring($string,1,1)=$from">
                    <!-- Added this to avoid empty commas in sequences of
                    spaces. -sb -->
                    <xsl:if test="not(substring($string,2,1)=$from and $from=' ')">
                        <xsl:value-of select="$to"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($string,1,1)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="replace-char">
                <xsl:with-param name="string" select="substring($string, 2)"/>
                <xsl:with-param name="to" select="$to"/>
                <xsl:with-param name="from" select="$from"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
<!-- vim: sw=4 ts=4 expandtab
-->
