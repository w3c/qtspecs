//### This file created by BYACC 1.8(/Java extension  1.1)
//### Java capabilities added 7 Jan 97, Bob Jamison
//### Updated : 27 Nov 97  -- Bob Jamison, Joe Nieten
//###           01 Jan 98  -- Bob Jamison -- fixed generic semantic constructor
//###           01 Jun 99  -- Bob Jamison -- added Runnable support
//###           06 Aug 00  -- Bob Jamison -- made state variables class-global
//###           03 Jan 01  -- Bob Jamison -- improved flags, tracing
//###           16 May 01  -- Bob Jamison -- added custom stack sizing
//### Please send bug reports to rjamison@lincom-asg.com
//### static char yysccsid[] = "@(#)yaccpar	1.8 (Berkeley) 01/20/90";






//#line 2 "xquery.y"

      
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
  
//#line 30 "Parser.java"




/**
 * Encapsulates yacc() parser functionality in a Java
 *        class for quick code development
 */
public class Parser
{

boolean yydebug;        //do I want debug output?
int yynerrs;            //number of errors so far
int yyerrflag;          //was there an error?
int yychar;             //the current working character

//########## MESSAGES ##########
//###############################################################
// method: debug
//###############################################################
void debug(String msg)
{
  if (yydebug)
    System.out.println(msg);
}

//########## STATE STACK ##########
final static int YYSTACKSIZE = 500;  //maximum stack size
int statestk[],stateptr;           //state stack
int stateptrmax;                     //highest index of stackptr
int statemax;                        //state when highest index reached
//###############################################################
// methods: state stack push,pop,drop,peek
//###############################################################
void state_push(int state)
{
  if (stateptr>=YYSTACKSIZE)         //overflowed?
    return;
  statestk[++stateptr]=state;
  if (stateptr>statemax)
    {
    statemax=state;
    stateptrmax=stateptr;
    }
}
int state_pop()
{
  if (stateptr<0)                    //underflowed?
    return -1;
  return statestk[stateptr--];
}
void state_drop(int cnt)
{
int ptr;
  ptr=stateptr-cnt;
  if (ptr<0)
    return;
  stateptr = ptr;
}
int state_peek(int relative)
{
int ptr;
  ptr=stateptr-relative;
  if (ptr<0)
    return -1;
  return statestk[ptr];
}
//###############################################################
// method: init_stacks : allocate and prepare stacks
//###############################################################
boolean init_stacks()
{
  statestk = new int[YYSTACKSIZE];
  stateptr = -1;
  statemax = -1;
  stateptrmax = -1;
  val_init();
  return true;
}
//###############################################################
// method: dump_stacks : show n levels of the stacks
//###############################################################
void dump_stacks(int count)
{
int i;
  System.out.println("=index==state====value=     s:"+stateptr+"  v:"+valptr);
  for (i=0;i<count;i++)
    System.out.println(" "+i+"    "+statestk[i]+"      "+valstk[i]);
  System.out.println("======================");
}


//########## SEMANTIC VALUES ##########
//public class ParserVal is defined in ParserVal.java


String   yytext;//user variable to return contextual strings
ParserVal yyval; //used to return semantic vals from action routines
ParserVal yylval;//the 'lval' (result) I got from yylex()
ParserVal valstk[];
int valptr;
//###############################################################
// methods: value stack push,pop,drop,peek.
//###############################################################
void val_init()
{
  valstk=new ParserVal[YYSTACKSIZE];
  yyval=new ParserVal(0);
  yylval=new ParserVal(0);
  valptr=-1;
}
void val_push(ParserVal val)
{
  if (valptr>=YYSTACKSIZE)
    return;
  valstk[++valptr]=val;
}
ParserVal val_pop()
{
  if (valptr<0)
    return new ParserVal(-1);
  return valstk[valptr--];
}
void val_drop(int cnt)
{
int ptr;
  ptr=valptr-cnt;
  if (ptr<0)
    return;
  valptr = ptr;
}
ParserVal val_peek(int relative)
{
int ptr;
  ptr=valptr-relative;
  if (ptr<0)
    return new ParserVal(-1);
  return valstk[ptr];
}
//#### end semantic value section ####
public final static short VT_STRING=257;
public final static short VT_NUMBER=258;
public final static short VT_ID=259;
public final static short NTQueryList=260;
public final static short NTModule=261;
public final static short NTMainModule=262;
public final static short NTLibraryModule=263;
public final static short NTModuleDecl=264;
public final static short NTProlog=265;
public final static short NTSeparator=266;
public final static short NTVersionDecl=267;
public final static short NTSetter=268;
public final static short NTImport=269;
public final static short NTModuleImport=270;
public final static short NTVarDecl=271;
public final static short NTQueryBody=272;
public final static short NTExpr=273;
public final static short NTExprSingle=274;
public final static short NTFLWORExpr=275;
public final static short NTForClause=276;
public final static short NTPositionalVar=277;
public final static short NTLetClause=278;
public final static short NTWhereClause=279;
public final static short NTOrderByClause=280;
public final static short NTOrderSpecList=281;
public final static short NTOrderSpec=282;
public final static short NTOrderModifier=283;
public final static short NTQuantifiedExpr=284;
public final static short NTTypeswitchExpr=285;
public final static short NTCaseClause=286;
public final static short NTIfExpr=287;
public final static short NTOrExpr=288;
public final static short NTAndExpr=289;
public final static short NTComparisonExpr=290;
public final static short NTRangeExpr=291;
public final static short NTAdditiveExpr=292;
public final static short NTMultiplicativeExpr=293;
public final static short NTUnaryExpr=294;
public final static short NTUnionExpr=295;
public final static short NTIntersectExceptExpr=296;
public final static short NTInstanceofExpr=297;
public final static short NTTreatExpr=298;
public final static short NTCastableExpr=299;
public final static short NTCastExpr=300;
public final static short NTValueExpr=301;
public final static short NTPathExpr=302;
public final static short NTRelativePathExpr=303;
public final static short NTStepExpr=304;
public final static short NTAxisStep=305;
public final static short NTFilterExpr=306;
public final static short NTContextItemExpr=307;
public final static short NTPrimaryExpr=308;
public final static short NTVarRef=309;
public final static short NTPredicate=310;
public final static short NTPredicateList=311;
public final static short NTValidateExpr=312;
public final static short NTValidationContext=313;
public final static short NTConstructor=314;
public final static short NTComputedConstructor=315;
public final static short NTGeneralComp=316;
public final static short NTValueComp=317;
public final static short NTNodeComp=318;
public final static short NTForwardStep=319;
public final static short NTReverseStep=320;
public final static short NTAbbrevForwardStep=321;
public final static short NTAbbrevReverseStep=322;
public final static short NTForwardAxis=323;
public final static short NTReverseAxis=324;
public final static short NTNodeTest=325;
public final static short NTNameTest=326;
public final static short NTWildcard=327;
public final static short NTLiteral=328;
public final static short NTNumericLiteral=329;
public final static short NTParenthesizedExpr=330;
public final static short NTFunctionCall=331;
public final static short NTDirElemConstructor=332;
public final static short NTCompDocConstructor=333;
public final static short NTCompElemConstructor=334;
public final static short NTCompElemBody=335;
public final static short NTCompElemNamespace=336;
public final static short NTCompAttrConstructor=337;
public final static short NTCompXmlPI=338;
public final static short NTCompXmlComment=339;
public final static short NTCompTextConstructor=340;
public final static short NTCdataSection=341;
public final static short NTXmlPI=342;
public final static short NTXmlComment=343;
public final static short NTElementContent=344;
public final static short NTAttributeList=345;
public final static short NTAttributeValue=346;
public final static short NTQuotAttrValueContent=347;
public final static short NTAposAttrValueContent=348;
public final static short NTEnclosedExpr=349;
public final static short NTXMLSpaceDecl=350;
public final static short NTDefaultCollationDecl=351;
public final static short NTBaseURIDecl=352;
public final static short NTNamespaceDecl=353;
public final static short NTDefaultNamespaceDecl=354;
public final static short NTFunctionDecl=355;
public final static short NTParamList=356;
public final static short NTParam=357;
public final static short NTTypeDeclaration=358;
public final static short NTSingleType=359;
public final static short NTSequenceType=360;
public final static short NTAtomicType=361;
public final static short NTItemType=362;
public final static short NTKindTest=363;
public final static short NTElementTest=364;
public final static short NTAttributeTest=365;
public final static short NTElementName=366;
public final static short NTAttributeName=367;
public final static short NTTypeName=368;
public final static short NTElementNameOrWildcard=369;
public final static short NTAttribNameOrWildcard=370;
public final static short NTTypeNameOrWildcard=371;
public final static short NTPITest=372;
public final static short NTDocumentTest=373;
public final static short NTCommentTest=374;
public final static short NTTextTest=375;
public final static short NTAnyKindTest=376;
public final static short NTSchemaContextPath=377;
public final static short NTSchemaContextLoc=378;
public final static short NTOccurrenceIndicator=379;
public final static short NTValidationDecl=380;
public final static short NTSchemaImport=381;
public final static short NTSchemaPrefix=382;
public final static short NTQueryListTail=383;
public final static short NTOptionalModule=384;
public final static short NTOptionalVersionDecl=385;
public final static short NTMainOrLibraryModule=386;
public final static short NTSetterList=387;
public final static short NTDeclList=388;
public final static short NTDeclChoice=389;
public final static short NTImportPrefixDecl=390;
public final static short NTLocationHint=391;
public final static short NTVarDeclOptionalTypeDecl=392;
public final static short NTVarDeclAssignmentOrExtern=393;
public final static short NTCommaExpr=394;
public final static short NTFLWORClauseList=395;
public final static short NTOptionalWhere=396;
public final static short NTOptionalOrderBy=397;
public final static short NTForTypeDeclarationOption=398;
public final static short NTPositionalVarOption=399;
public final static short NTForClauseTail=400;
public final static short NTForTailTypeDeclarationOption=401;
public final static short NTTailPositionalVarOption=402;
public final static short NTLetTypeDeclarationOption=403;
public final static short NTLetClauseTail=404;
public final static short NTLetTailTypeDeclarationOption=405;
public final static short NTOrderByOrOrderByStable=406;
public final static short NTOrderSpecListTail=407;
public final static short NTSortDirectionOption=408;
public final static short NTEmptyPosOption=409;
public final static short NTCollationSpecOption=410;
public final static short NTSomeOrEvery=411;
public final static short NTQuantifiedTypeDeclarationOption=412;
public final static short NTQuantifiedVarDeclListTail=413;
public final static short NTQuantifiedTailTypeDeclarationOption=414;
public final static short NTCaseClauseList=415;
public final static short NTDefaultClauseVarBindingOption=416;
public final static short NTCaseClauseVarBindingOption=417;
public final static short NTOptionalRootExprTail=418;
public final static short NTRelativePathExprTail=419;
public final static short NTRelativePathExprStepSep=420;
public final static short NTForwardOrReverseStep=421;
public final static short NTValidateExprSpecifiers=422;
public final static short NTValidateSchemaModeContextOption=423;
public final static short NTOptionalAtSugar=424;
public final static short NTOptionalExpr=425;
public final static short NTFunctionNameOpening=426;
public final static short NTArgList=427;
public final static short NTArgListTail=428;
public final static short NTTagOpenStart=429;
public final static short NTTagClose=430;
public final static short NTElementContentBody=431;
public final static short NTOptionalWhitespaceBeforeEndTagClose=432;
public final static short NTCompElemConstructorSpec=433;
public final static short NTOptionalCompElemBody=434;
public final static short NTCompElemNamespaceOrExprSingle=435;
public final static short NTCompElemBodyTail=436;
public final static short NTTailCompElemNamespaceOrExprSingle=437;
public final static short NTCompAttrConstructorOpening=438;
public final static short NTOptionalCompAttrValExpr=439;
public final static short NTCompXmlPIOpening=440;
public final static short NTOptionalCompXmlPIExpr=441;
public final static short NTOptionalCompTextExpr=442;
public final static short NTCdataSectionOpen=443;
public final static short NTCdataSectionBody=444;
public final static short NTProcessingInstructionStartOpen=445;
public final static short NTOptionalPIContent=446;
public final static short NTXmlPIContentBody=447;
public final static short NTXmlCommentStartOpen=448;
public final static short NTXmlCommentContents=449;
public final static short NTOptionalAttribute=450;
public final static short NTOptionalWhitespaceBeforeValueIndicator=451;
public final static short NTOptionalWhitespaceBeforeAttributeValue=452;
public final static short NTQuotAttributeValueContents=453;
public final static short NTQuotContentOrEscape=454;
public final static short NTAposAttributeValueContents=455;
public final static short NTAposContentOrEscape=456;
public final static short NTEnclosedExprOpening=457;
public final static short NTXMLSpacePreserveOrStrip=458;
public final static short NTDeclareDefaultElementOrFunction=459;
public final static short NTOptionalParamList=460;
public final static short NTFunctionDeclSigClose=461;
public final static short NTFunctionDeclBody=462;
public final static short NTParamListTail=463;
public final static short NTOptionalTypeDeclarationForParam=464;
public final static short NTOptionalOccurrenceIndicator=465;
public final static short NTOptionalOccurrenceIndicatorForSequenceType=466;
public final static short NTElementTypeOpen=467;
public final static short NTOptionalElementTestBody=468;
public final static short NTElementTestBodyOptionalParam=469;
public final static short NTNillableOption=470;
public final static short NTAttributeTestOpening=471;
public final static short NTOptionalAttributeTestBody=472;
public final static short NTAttributeTestBodyOptionalParam=473;
public final static short NTPITestOpening=474;
public final static short NTOptionalPITestBody=475;
public final static short NTDocumentTestOpening=476;
public final static short NTOptionalDocumentTestBody=477;
public final static short NTCommentTestOpen=478;
public final static short NTTextTestOpen=479;
public final static short NTAnyKindTestOpening=480;
public final static short NTSchemaContextPathTail=481;
public final static short NTOptionalSchemaContextLocContextPath=482;
public final static short NTOptionalSchemaImportPrefixDecl=483;
public final static short NTOptionalLocationHint=484;
public final static short Pragma=485;
public final static short MUExtension=486;
public final static short ExtensionStart=487;
public final static short ExprComment=488;
public final static short ExprCommentStart=489;
public final static short ExprCommentContent=490;
public final static short ExtensionContents=491;
public final static short ExtensionEnd=492;
public final static short ExprCommentEnd=493;
public final static short PragmaKeyword=494;
public final static short Extension=495;
public final static short XmlCommentStart=496;
public final static short XmlCommentStartForElementContent=497;
public final static short XmlCommentEnd=498;
public final static short IntegerLiteral=499;
public final static short DecimalLiteral=500;
public final static short DoubleLiteral=501;
public final static short StringLiteral=502;
public final static short StringLiteralForKindTest=503;
public final static short VersionStringLiteral=504;
public final static short AtStringLiteral=505;
public final static short URLLiteral=506;
public final static short ModuleNamespace=507;
public final static short NotOccurrenceIndicator=508;
public final static short S=509;
public final static short SForPI=510;
public final static short ProcessingInstructionStart=511;
public final static short ProcessingInstructionStartForElementContent=512;
public final static short ProcessingInstructionEnd=513;
public final static short AxisChild=514;
public final static short AxisDescendant=515;
public final static short AxisParent=516;
public final static short AxisAttribute=517;
public final static short AxisSelf=518;
public final static short AxisDescendantOrSelf=519;
public final static short AxisAncestor=520;
public final static short AxisFollowingSibling=521;
public final static short AxisPrecedingSibling=522;
public final static short AxisFollowing=523;
public final static short AxisPreceding=524;
public final static short AxisAncestorOrSelf=525;
public final static short DefineFunction=526;
public final static short External=527;
public final static short Or=528;
public final static short And=529;
public final static short Div=530;
public final static short Idiv=531;
public final static short Mod=532;
public final static short Multiply=533;
public final static short In=534;
public final static short ValidationMode=535;
public final static short SchemaModeForDeclareValidate=536;
public final static short Nillable=537;
public final static short DeclareValidation=538;
public final static short SchemaGlobalContextSlash=539;
public final static short SchemaGlobalTypeName=540;
public final static short SchemaGlobalContext=541;
public final static short SchemaContextStepSlash=542;
public final static short SchemaContextStep=543;
public final static short InContextForKindTest=544;
public final static short Global=545;
public final static short Satisfies=546;
public final static short Return=547;
public final static short Then=548;
public final static short Else=549;
public final static short Default=550;
public final static short DeclareXMLSpace=551;
public final static short DeclareBaseURI=552;
public final static short XMLSpacePreserve=553;
public final static short XMLSpaceStrip=554;
public final static short Namespace=555;
public final static short DeclareNamespace=556;
public final static short To=557;
public final static short Where=558;
public final static short Collation=559;
public final static short Intersect=560;
public final static short Union=561;
public final static short Except=562;
public final static short As=563;
public final static short AtWord=564;
public final static short Case=565;
public final static short Instanceof=566;
public final static short Castable=567;
public final static short RparAs=568;
public final static short Item=569;
public final static short ElementType=570;
public final static short AttributeType=571;
public final static short ElementQNameLbrace=572;
public final static short AttributeQNameLbrace=573;
public final static short NamespaceNCNameLbrace=574;
public final static short PINCNameLbrace=575;
public final static short PILbrace=576;
public final static short CommentLbrace=577;
public final static short ElementLbrace=578;
public final static short AttributeLbrace=579;
public final static short TextLbrace=580;
public final static short DeclareCollation=581;
public final static short DefaultElement=582;
public final static short DeclareDefaultElement=583;
public final static short DeclareDefaultFunction=584;
public final static short EmptyTok=585;
public final static short ImportSchemaToken=586;
public final static short ImportModuleToken=587;
public final static short Nmstart=588;
public final static short Nmchar=589;
public final static short Star=590;
public final static short AnyName=591;
public final static short NCNameColonStar=592;
public final static short StarColonNCName=593;
public final static short Root=594;
public final static short RootDescendants=595;
public final static short Slash=596;
public final static short SlashSlash=597;
public final static short Equals=598;
public final static short AssignEquals=599;
public final static short Is=600;
public final static short NotEquals=601;
public final static short LtEquals=602;
public final static short LtLt=603;
public final static short GtEquals=604;
public final static short GtGt=605;
public final static short FortranEq=606;
public final static short FortranNe=607;
public final static short FortranGt=608;
public final static short FortranGe=609;
public final static short FortranLt=610;
public final static short FortranLe=611;
public final static short ColonEquals=612;
public final static short Lt=613;
public final static short Gt=614;
public final static short Minus=615;
public final static short Plus=616;
public final static short UnaryMinus=617;
public final static short UnaryPlus=618;
public final static short OccurrenceZeroOrOne=619;
public final static short OccurrenceZeroOrMore=620;
public final static short OccurrenceOneOrMore=621;
public final static short Vbar=622;
public final static short Lpar=623;
public final static short At=624;
public final static short Lbrack=625;
public final static short Rbrack=626;
public final static short Rpar=627;
public final static short RparForKindTest=628;
public final static short Some=629;
public final static short Every=630;
public final static short ForVariable=631;
public final static short LetVariable=632;
public final static short CastAs=633;
public final static short TreatAs=634;
public final static short ValidateLbrace=635;
public final static short ValidateContext=636;
public final static short ValidateGlobal=637;
public final static short ValidateSchemaMode=638;
public final static short Digits=639;
public final static short DocumentLpar=640;
public final static short DocumentLparForKindTest=641;
public final static short DocumentLbrace=642;
public final static short NodeLpar=643;
public final static short CommentLpar=644;
public final static short TextLpar=645;
public final static short ProcessingInstructionLpar=646;
public final static short ElementTypeForKindTest=647;
public final static short ElementTypeForDocumentTest=648;
public final static short AttributeTypeForKindTest=649;
public final static short ProcessingInstructionLparForKindTest=650;
public final static short TextLparForKindTest=651;
public final static short CommentLparForKindTest=652;
public final static short NodeLparForKindTest=653;
public final static short IfLpar=654;
public final static short TypeswitchLpar=655;
public final static short Comma=656;
public final static short CommaForKindTest=657;
public final static short SemiColon=658;
public final static short QuerySeparator=659;
public final static short EscapeQuot=660;
public final static short OpenQuot=661;
public final static short CloseQuot=662;
public final static short Dot=663;
public final static short DotDot=664;
public final static short OrderBy=665;
public final static short OrderByStable=666;
public final static short Ascending=667;
public final static short Descending=668;
public final static short EmptyGreatest=669;
public final static short EmptyLeast=670;
public final static short PITarget=671;
public final static short NCName=672;
public final static short Prefix=673;
public final static short LocalPart=674;
public final static short VariableIndicator=675;
public final static short VarName=676;
public final static short DefineVariable=677;
public final static short QNameForSequenceType=678;
public final static short QNameForAtomicType=679;
public final static short QNameForItemType=680;
public final static short ExtensionQName=681;
public final static short QName=682;
public final static short QNameLpar=683;
public final static short NCNameForPrefix=684;
public final static short NCNameForPI=685;
public final static short CdataSectionStart=686;
public final static short CdataSectionStartForElementContent=687;
public final static short CdataSectionEnd=688;
public final static short PredefinedEntityRef=689;
public final static short HexDigits=690;
public final static short CharRef=691;
public final static short StartTagOpen=692;
public final static short StartTagOpenRoot=693;
public final static short StartTagClose=694;
public final static short EmptyTagClose=695;
public final static short EndTagOpen=696;
public final static short EndTagClose=697;
public final static short ValueIndicator=698;
public final static short TagQName=699;
public final static short Lbrace=700;
public final static short LbraceExprEnclosure=701;
public final static short LCurlyBraceEscape=702;
public final static short RCurlyBraceEscape=703;
public final static short EscapeApos=704;
public final static short OpenApos=705;
public final static short CloseApos=706;
public final static short ElementContentChar=707;
public final static short QuotAttContentChar=708;
public final static short AposAttContentChar=709;
public final static short CommentContentChar=710;
public final static short PIContentChar=711;
public final static short CDataSectionChar=712;
public final static short Rbrace=713;
public final static short WhitespaceChar=714;
public final static short YYERRCODE=256;
final static short yylhs[] = {                           -1,
    0,    1,    2,    3,    4,    5,    6,    7,    8,    8,
    8,    8,    8,    9,    9,   10,   11,   12,   13,   14,
   14,   14,   14,   14,   15,   16,   17,   18,   19,   20,
   21,   22,   23,   24,   25,   26,   27,   28,   28,   29,
   29,   30,   30,   30,   30,   31,   31,   32,   32,   32,
   33,   33,   33,   33,   33,   34,   34,   34,   35,   35,
   35,   36,   36,   36,   37,   37,   38,   38,   39,   39,
   40,   40,   41,   41,   42,   42,   42,   43,   44,   44,
   45,   46,   47,   48,   48,   48,   48,   48,   48,   49,
   50,   51,   51,   52,   53,   53,   54,   54,   54,   54,
   54,   55,   55,   55,   55,   55,   55,   56,   56,   56,
   56,   56,   56,   57,   57,   57,   57,   57,   57,   58,
   58,   58,   59,   59,   60,   60,   61,   62,   63,   63,
   63,   63,   63,   63,   63,   64,   64,   64,   64,   64,
   65,   65,   66,   66,   67,   67,   67,   68,   68,   69,
   69,   69,   70,   71,   72,   73,   74,   75,   76,   77,
   78,   79,   80,   81,   82,   83,   84,   84,   84,   84,
   84,   84,   84,   84,   84,   84,   85,   85,   86,   86,
   87,   87,   87,   87,   87,   87,   88,   88,   88,   88,
   88,   88,   89,   90,   91,   92,   93,   94,   95,   96,
   97,   98,   99,  100,  100,  101,  101,  102,  102,  102,
  103,  103,  103,  103,  103,  103,  103,  104,  105,  106,
  107,  108,  109,  109,  110,  110,  111,  111,  112,  113,
  114,  115,  116,  117,  118,  118,  119,  119,  119,  120,
  121,  122,  122,  123,  123,  124,  124,  125,  125,  126,
  126,  127,  127,  128,  128,  129,  129,  129,  129,  130,
  130,  131,  131,  132,  132,  133,  133,  134,  134,  135,
  135,  135,  135,  136,  136,  137,  137,  138,  138,  139,
  139,  140,  140,  141,  141,  142,  142,  143,  143,  144,
  144,  145,  145,  146,  146,  147,  147,  148,  148,  148,
  149,  149,  149,  150,  150,  151,  151,  152,  152,  153,
  153,  154,  154,  155,  155,  156,  156,  157,  157,  158,
  158,  159,  159,  160,  160,  161,  161,  162,  162,  162,
  162,  163,  163,  164,  164,  165,  165,  166,  167,  167,
  168,  168,  169,  169,  170,  170,  171,  171,  172,  172,
  173,  173,  174,  174,  175,  175,  176,  176,  177,  177,
  178,  178,  179,  179,  180,  180,  181,  181,  182,  182,
  183,  183,  184,  184,  185,  185,  186,  186,  187,  187,
  188,  188,  189,  189,  190,  190,  191,  191,  192,  192,
  193,  193,  194,  194,  195,  195,  196,  196,  197,  197,
  198,  198,  199,  199,  200,  200,  201,  201,  202,  202,
  203,  203,  204,  204,  205,  205,  206,  206,  207,  207,
  207,  208,  208,  208,  209,  209,  210,  210,  211,  211,
  212,  212,  212,  213,  213,  214,  214,  215,  215,  215,
  216,  216,  217,  217,  218,  218,  219,  219,  220,  220,
  221,  221,  222,  222,  223,  223,  224,  224,
};
final static short yylen[] = {                            2,
    2,    2,    2,    2,    5,    2,    1,    2,    1,    1,
    1,    1,    1,    1,    1,    4,    4,    1,    2,    1,
    1,    1,    1,    1,    5,    7,    3,    6,    2,    2,
    2,    2,    3,    8,    8,    5,    7,    3,    1,    3,
    1,    3,    3,    3,    1,    3,    1,    3,    3,    1,
    3,    3,    3,    3,    1,    2,    2,    1,    3,    3,
    1,    3,    3,    1,    3,    1,    3,    1,    3,    1,
    3,    1,    1,    1,    2,    2,    1,    2,    1,    1,
    2,    2,    1,    1,    1,    1,    1,    1,    1,    2,
    3,    0,    2,    3,    2,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    2,    1,    2,    1,    2,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    3,    3,    4,    3,    3,    2,    3,    3,
    3,    3,    3,    3,    4,    3,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    0,    3,    3,    3,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    3,    2,    2,    2,    4,    3,    5,    2,
    3,    2,    2,    2,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    3,    3,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    3,    3,
    2,    2,    2,    2,    2,    1,    1,    1,    1,    2,
    4,    3,    2,    0,    3,    0,    1,    0,    1,    1,
    1,    0,    3,    0,    3,    1,    1,    1,    1,    0,
    3,    0,    1,    0,    1,    3,    1,    0,    3,    2,
    2,    1,    1,    0,    1,    0,    1,    0,    1,    0,
    1,    0,    8,    0,    1,    0,    1,    0,    1,    0,
    7,    0,    1,    1,    1,    0,    3,    0,    1,    1,
    0,    1,    1,    0,    2,    1,    1,    0,    1,    0,
    7,    0,    1,    2,    1,    0,    2,    0,    3,    0,
    1,    0,    3,    1,    1,    1,    1,    1,    2,    3,
    3,    0,    1,    0,    1,    0,    1,    1,    0,    2,
    0,    3,    1,    1,    1,    6,    0,    2,    0,    1,
    1,    4,    0,    1,    1,    1,    0,    3,    1,    1,
    1,    4,    0,    1,    1,    4,    0,    1,    0,    1,
    1,    1,    0,    2,    1,    1,    0,    2,    0,    2,
    1,    1,    0,    2,    0,    5,    0,    1,    0,    1,
    0,    2,    1,    1,    0,    2,    1,    1,    1,    1,
    1,    1,    1,    1,    0,    1,    1,    2,    1,    1,
    0,    3,    0,    1,    0,    1,    0,    1,    1,    1,
    1,    0,    2,    2,    0,    3,    0,    1,    1,    1,
    0,    2,    2,    0,    2,    1,    1,    0,    1,    1,
    1,    1,    0,    1,    1,    1,    1,    1,    1,    1,
    0,    2,    0,    1,    0,    1,    0,    1,
};
final static short yydefred[] = {                         0,
    0,    0,  244,  249,    0,    7,    8,    0,    0,  250,
  251,  252,    0,    2,    0,    0,    0,    4,  382,  381,
  150,  151,  152,  149,  376,  375,  129,  130,  136,  131,
  132,  133,  137,  134,  138,  135,  139,  140,  351,  361,
  365,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  335,  306,  307,    0,    0,  328,    0,    0,    0,
    0,    0,    0,   83,  128,    0,  338,  372,  371,  344,
  343,    3,   18,  268,   20,  272,  273,   21,   22,   23,
    0,    0,    0,    0,    0,    0,   55,    0,    0,    0,
    0,    0,    0,   72,   74,   77,  322,   79,   80,   87,
   92,   85,   73,   89,   98,  326,  327,  124,  126,    0,
    0,   84,  148,   86,   88,   97,  104,  102,  103,  106,
  107,  105,  101,  100,   99,    0,    0,   92,    0,    0,
    0,    0,    0,    0,    0,  373,    0,  383,    0,    0,
    0,    0,  403,  404,    0,    9,   10,   11,   13,   12,
    0,    0,  247,  245,    0,    0,    0,    0,    0,  370,
    0,  321,   75,   76,   56,   57,  337,    0,    0,    0,
  451,  236,  454,    0,    0,  329,    0,   96,  333,    0,
    0,    0,    0,   90,    0,    0,    0,  108,  120,  109,
  111,  121,  113,  122,  114,  115,  118,  119,  116,  117,
  110,  112,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  419,  429,  145,  146,  147,  441,  442,  449,
  445,  447,  436,  420,  421,  430,  437,  448,  446,  450,
  143,  123,  142,  144,  141,  212,  213,  214,  211,  215,
  216,  217,    0,    0,    0,    0,    0,    0,    0,  125,
    0,  270,  271,  275,    0,    0,    0,    0,  127,  341,
    0,  177,    0,  356,  354,  355,    0,  357,  364,    0,
  368,    0,    0,    0,    0,  240,  401,  402,  194,  196,
  195,  253,    0,    0,    0,    0,    0,  256,   15,  258,
  257,  259,   14,    0,    0,    0,    0,  162,    0,    0,
  163,  153,    0,  279,    0,  289,    0,    0,  330,  235,
   95,  331,  156,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   52,   53,   54,   51,    0,    0,
    0,    0,  210,  205,  207,  206,   65,  208,    0,  209,
   67,   69,    0,   71,  324,  325,    0,    0,   93,  224,
  220,  223,    0,    0,    0,  226,  221,  225,    0,    0,
    0,  440,  439,    0,  444,    0,  231,  232,  233,   29,
  294,  295,  277,    0,    0,  309,    0,   94,    0,  154,
    0,    0,  157,    0,  160,  161,  164,  374,  379,    0,
  166,  384,    0,    0,    0,    0,  456,    0,    0,    0,
    0,  255,  198,    5,  366,  352,  362,  202,    0,  281,
    0,    0,  452,    0,    0,  315,    0,  269,  237,  238,
  239,  418,  204,  416,  203,  323,    0,    0,  424,  423,
  218,    0,  433,  432,  219,  229,  230,    0,    0,   30,
  296,    0,    0,    0,  347,  345,  155,  159,    0,    0,
  165,    0,  406,  411,    0,    0,    0,  243,    0,    0,
    0,  265,    0,    0,    0,  290,    0,    0,    0,    0,
  314,   91,  228,  222,  227,    0,  435,   25,  299,  300,
   32,    0,    0,  310,  342,    0,  178,    0,  360,  359,
  358,  380,    0,    0,    0,  407,    0,  197,  242,  458,
  241,  261,  263,   16,  267,    0,   17,   27,  282,    0,
    0,    0,    0,    0,    0,  428,  426,  302,  303,    0,
    0,    0,  388,    0,  174,  173,    0,  399,  400,  168,
  169,  167,  170,  172,  176,  175,  348,  171,    0,  414,
  201,    0,  408,  410,  409,  199,    0,    0,    0,   37,
  319,    0,  317,    0,    0,   33,  297,    0,    0,    0,
    0,    0,  412,  266,    0,    0,   36,   35,  305,   34,
    0,  390,    0,  350,    0,  193,    0,    0,    0,  391,
  395,  386,  346,    0,  293,    0,  313,    0,    0,    0,
  285,    0,    0,    0,  393,  179,  186,  182,  183,  184,
  181,  394,  185,  392,  192,  188,  189,  190,  397,  180,
  187,  398,  191,  396,  287,    0,  291,  311,    0,  283,
};
final static short yydgoto[] = {                          2,
    3,   10,   11,   12,   13,    7,    4,  145,  298,  299,
  300,   72,   73,   74,   75,   76,  420,   77,  264,  383,
  450,  451,  491,   78,   79,  426,   80,   81,   82,   83,
   84,   85,   86,   87,   88,   89,   90,   91,   92,   93,
   94,   95,   96,   97,   98,   99,  100,  101,  102,  359,
  222,  103,  179,  104,  105,  203,  204,  205,  106,  107,
  108,  109,  110,  111,  242,  243,  244,  112,  113,  114,
  115,  116,  117,  118,  275,  276,  119,  120,  121,  122,
  123,  124,  125,  547,  391,  592,  612,  622,  548,  146,
  147,  148,  301,  149,  302,  463,  464,  314,  352,  347,
  348,  349,  350,  246,  247,  362,  368,  485,  363,  369,
  486,  248,  249,  250,  251,  252,  173,  174,  432,  150,
  303,  407,    8,  154,    5,   14,   15,  151,  304,  410,
  514,  473,  517,  185,  126,  265,  384,  315,  421,  558,
  602,  626,  317,  520,  596,  385,  493,  492,  530,  566,
  127,  387,  532,  598,  427,  525,  479,  163,  221,  357,
  128,  129,  180,  130,  168,  131,  271,  389,  132,  457,
  498,  585,  133,  277,  278,  394,  501,  134,  280,  135,
  282,  161,  136,  283,  137,  400,  460,  138,  285,  497,
  534,  583,  599,  614,  600,  624,  549,  289,  152,  465,
  507,  556,  504,  551,  435,  433,  253,  365,  439,  527,
  254,  371,  443,  255,  374,  256,  376,  257,  258,  259,
  318,  175,  408,  511,
};
final static short yysindex[] = {                      -445,
 -574,    0,    0,    0, -416,    0,    0, -554, -577,    0,
    0,    0, 3800,    0, -326, -445, -473,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, 3800, 3800, 3800, 3800, 3800, 4029, 4029, -448, -448,
 3800,    0,    0,    0, -543, -532,    0, -478, -553, -443,
 3800, 3800, 3800,    0,    0, -469,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
 -348, -347, -112, -343, -450, -372,    0, -525, -504, -336,
 -411, -335, -399,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0, 3120,
 3120,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0, -475, -436,    0, 3800, 3120,
 3800, -449, -209, 3800, 3800,    0, -415,    0, -268, -413,
 -236, -229,    0,    0, -574,    0,    0,    0,    0,    0,
 -466, -277,    0,    0, -226, -431, -430, -427, -424,    0,
 -417,    0,    0,    0,    0,    0,    0, -333, -279, -279,
    0,    0,    0, -404, -381,    0, -478,    0,    0, -400,
 -409, -310, -308,    0, -334, -448, -448,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, -448, -448, -448, -448, -448, -448, -448, -448,
 -448, -448, 3998, 3998, 3998, 3998, -304, -304, -495, -495,
 -419, -305,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, -513, -512, -486, -537, -307, -303, -302,    0,
 3800,    0,    0,    0, -480, -279, -305, -390,    0,    0,
 -300,    0, -172,    0,    0,    0, -382,    0,    0, -379,
    0, -375, -600, -178, -488,    0,    0,    0,    0,    0,
    0,    0, -331, -330, -490, -205, -323,    0,    0,    0,
    0,    0,    0, -574, -151, -574, -345,    0, -344, -342,
    0,    0, -304,    0, -206,    0, -252, -181,    0,    0,
    0,    0,    0, -186, -193, 3800, -347, -112, -343, -343,
 -343, -450, -372, -372,    0,    0,    0,    0, -504, -504,
 -336, -336,    0,    0,    0,    0,    0,    0, -457,    0,
    0,    0, -242,    0,    0,    0, 4029, 3800,    0,    0,
    0,    0, -278, -299, -248,    0,    0,    0, -275, -297,
 -244,    0,    0, -234,    0, -233,    0,    0,    0,    0,
    0,    0,    0, -155, 3800,    0, -136,    0, -257,    0,
 -497, -312,    0, -256,    0,    0,    0,    0,    0, -111,
    0,    0, -272, -195, -274, -150,    0, -100, -273,  -94,
 -279,    0,    0,    0,    0,    0,    0,    0, -262,    0,
 -118, 3800,    0, 3800, -258,    0, -452,    0,    0,    0,
    0,    0,    0,    0,    0,    0, -201, -566,    0,    0,
    0, -566,    0,    0,    0,    0,    0, 3800, -472,    0,
    0, 3800, 3800, -269,    0,    0,    0,    0, -209, -280,
    0, -241,    0,    0, -528,  -74, -165,    0,  -69, -162,
  -66,    0, -508, -228, 3800,    0, -106, -227, -304, -225,
    0,    0,    0,    0,    0,  -90,    0,    0,    0,    0,
    0, -441, -204,    0,    0,  -58,    0, -483,    0,    0,
    0,    0, -279, -203, -304,    0, -509,    0,    0,    0,
    0,    0,    0,    0,    0, 3800,    0,    0,    0, -200,
 3800, -105,  -88, -219,  -87,    0,    0,    0,    0,  -97,
 3800, -507,    0, -231,    0,    0, -230,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0, 3800,    0,
    0, -272,    0,    0,    0,    0, -245, -191, -202,    0,
    0, 3800,    0, 3800,  -32,    0,    0, 3800, -194,  -38,
  -37, -238,    0,    0, -190, -176,    0,    0,    0,    0,
 -173,    0, -624,    0, -215,    0, -169, -279, -279,    0,
    0,    0,    0, -279,    0, -108,    0,  -28, -429, -313,
    0, -206, 3800, 3800,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  -26,    0,    0, 3800,    0,
};
final static short yyrindex[] = {                      3404,
    0,    0,    0,    0, 3602,    0,    0,  510,    0,    0,
    0,    0, 3163,    0, 3002, 2804,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, 3163, 3163, 3163, 3163, -129,    1, 3163, 3163, 3163,
 1482,    0,    0,    0,    0,    0,    0, -167,    0, -175,
 3163, 3163, 3163,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  285,  913,  171, 2417, 2241, 1946,    0, 1857, 1486, 1115,
 1001,  887,  744,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0, -531,    0,    0, 3163,    0,
 2902,    0,  485,  743, 1225,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
 3206,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0, -484,  -85,
    0,    0,    0,    0,    0,    0, -167,    0,    0,    0,
    0,    0,    0,    0,  115, 3163, 3163,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, 3163, 3163, 3163, 3163, 3163, 3163, 3163, 3163,
 3163, 3163, 3163, 3163, 3163, 3163,    0,    0,    0,    0,
  487,  259,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, -103,  -93,  -92,  -91,    0,    0,    0,    0,
 3163,    0,    0,    0,  -19,    4,  373,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   26,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   34,   35,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    9,    0,    0, -138,    0,    0,
    0,    0,    0,    0,    0, 3163, 1398,  656, 2506, 2594,
 2682, 2329, 2060, 2149,    0,    0,    0,    0, 1629, 1743,
 1229, 1372,    0,    0,    0,    0,    0,    0,  145,    0,
    0,    0,  630,    0,    0,    0, 3163, 3163,    0,    0,
    0,    0,  -84,    0,    0,    0,    0,    0,  -83,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0, 3163,    0,    0,    0,  -81,    0,
    0,    0,    0, -164,    0,    0,    0,    0,    0,    0,
    0,    0, -527,    0,    0,    0,    0,    0,    0,    0,
 -496,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, 3163,    0, 3163, 3689,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0, 3163, -517,    0,
    0, 3163, 3163, -494,    0,    0,    0,    0, 3163,   39,
    0,    0,    0,    0,    0,    0,    0,    0, -104,    0,
 -102,    0,    0,    0, 3163,    0,    0,    0,    0,   10,
    0,    0,    0,    0,    0,  -73,    0,    0,    0,    0,
    0, -502,   17,    0,    0, -133,    0,    0,    0,    0,
    0,    0, -534, -521,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0, 3163,    0,    0,    0, -523,
 3163,    0,    0,    0,    0,    0,    0,    0,    0, -501,
 3163,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0, 3163,    0,
    0,    0,    0,    0,    0,    0,    0, -515,    0,    0,
    0, 3163,    0, 3163,    0,    0,    0, 3163,    0, -623,
 -128,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  -42,   40,    0,
    0,    0,    0, -479,    0,    0,    0,    0,    0,    0,
    0,   41, 3163, 3163,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0, 3163,    0,
};
final static short yygindex[] = {                         0,
  557,    0,    0,    0,  564, -125,    0,    0,    0,    0,
    0,    0,  -40, -124,    0,  451,  -24,  453,    0,    0,
    0,   49,    0,    0,    0,  154,    0,    0,  396,  398,
  -31,  377,   29,   37,    0,   38,   27,    0,    0,    0,
    0,    0,  206,  229,    0,    0,    0,    0,    0,    0,
  459,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   -7,    0,    0,    0,    0,    0,
    0,   90,    0,    0,    0,  130,    0,    0,    0,    0,
   92,   94,   97,    0,    0,    0,    0,    0, -463,    0,
    0,    0,    0,    0,    0,    0,   45, -170,  376, -210,
   44,    0,    8,  342,    0,  236,  243,    0,    0,    0,
  176,    0,    0,    0,    0,    0,   22,  442,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,
};
final static int YYTABLESIZE=4722;
final static short yytable[] = {                        316,
  320,  156,  157,  158,  159,  160,  270,  351,  274,  401,
  167,  454,   19,   20,  385,  274,  372,  554,  515,  292,
  181,  182,  183,   28,  483,  171,  171,   25,   26,  298,
  264,   26,  223,  413,   28,  213,  590,  389,  568,  505,
  405,  298,   26,  555,  301,  304,  200,   19,   20,  278,
   21,   22,   23,   24,  284,  215,  301,  216,    1,  293,
  171,  172,   25,   26,  405,   27,   28,   29,   30,   31,
   32,   33,   34,   35,   36,   37,   38,  360,  366,  278,
  591,  389,  261,    6,  284,  165,  166,  397,  268,  294,
    9,  406,  413,  279,  281,  386,  214,  480,  506,  405,
  177,  178,  418,  260,   16,  200,   17,   28,   28,  234,
  235,  398,  425,  484,   19,   26,   26,  245,  245,  295,
  296,  413,  269,   39,   40,  155,   41,   42,   43,   44,
   45,   46,  169,  274,  274,  613,  623,  245,  298,  287,
  288,   28,   28,  170,  417,   47,   48,  176,  569,   26,
   26,  298,  298,  301,  304,   55,   56,  209,  210,  211,
  212,  429,  430,  431,  207,  208,  361,  367,   49,   50,
   41,  329,  330,  331,   51,   52,  355,  356,  412,  186,
  414,  187,  345,  346,  381,  382,   57,   58,   59,   60,
  538,  539,  516,   61,  489,  490,  455,  456,  373,  385,
  385,  428,   68,   69,  264,  535,  184,  536,   70,   71,
  297,  139,  537,  206,   64,   65,  538,  539,  540,  541,
  380,  402,  218,  542,  140,  141,   66,  528,  529,  217,
  605,  219,  606,  220,   67,  333,  334,   68,   69,  266,
  472,  341,  342,   70,   71,  335,  336,  337,  338,  272,
  339,  340,  162,  164,  142,  284,  143,  144,   82,  607,
  449,  608,  353,  353,  343,  223,  224,  286,  523,  290,
  538,  539,  609,  610,  364,  370,  291,  305,  611,  306,
  344,  307,  308,  313,   24,  309,   19,   20,  310,   21,
   22,   23,   24,  312,  553,  311,  319,  476,  320,  477,
  322,   25,   26,  323,   27,   28,   29,   30,   31,   32,
   33,   34,   35,   36,   37,   38,  324,  437,  325,  358,
  377,  326,  388,  488,  378,  379,  390,  494,  495,  392,
  393,  399,  550,  395,  499,  228,  229,  396,  230,  231,
  232,  233,  234,  235,  236,  237,  238,  239,  240,  409,
  519,  403,  411,  404,  413,  415,  416,  419,  417,  422,
  423,  424,   39,   40,  273,   41,   42,   43,   44,   45,
   46,  425,   81,  345,  346,  615,  434,  616,  438,  441,
  361,  442,  367,  445,   47,   48,  538,  539,  617,  618,
  619,  448,  620,  446,  447,  621,  560,  452,  453,  459,
  458,  461,  462,  466,  468,  469,  449,   49,   50,  467,
  470,  471,  474,   51,   52,  475,  478,  595,  597,   53,
   54,   55,   56,  601,  482,   57,   58,   59,   60,  496,
  502,  508,   61,  509,  503,  510,  512,  577,  513,  578,
  334,  334,  521,  580,   62,   63,  526,  518,  522,  524,
  533,  531,  552,   64,   65,  559,  563,  561,  562,  564,
  334,  565,  334,  334,  575,   66,  570,  574,  571,  579,
  582,  584,  576,   67,  586,  557,   68,   69,  627,  628,
  581,  593,   70,   71,  587,  188,   78,  189,  190,  191,
  192,  193,  194,  195,  196,  197,  198,  199,  200,  588,
  201,  202,  589,  603,  630,  604,  594,  629,  572,    1,
  334,  334,  453,  334,  334,  334,  334,  334,  334,  334,
  334,  334,  334,  334,  422,  332,  288,  276,  320,  320,
  320,  320,  320,  320,  431,  438,  443,  308,  377,  455,
  260,  234,  280,  425,  434,  340,  320,  320,  158,  320,
  320,  378,  334,  457,  427,  262,  316,  320,  320,  320,
  320,  320,  320,   31,  387,  320,  320,  320,  349,  292,
  334,  334,  153,  312,  286,   18,  262,  625,  263,  567,
  481,  327,  332,  369,  328,  436,  267,  543,  500,  544,
  334,  545,  334,  334,  546,  354,  573,  375,  320,  440,
  320,  320,  320,  320,  320,  320,  320,  320,  320,  320,
  320,  320,  444,  320,  320,  320,  320,  487,  321,    0,
    0,    0,  320,    0,    0,    0,  320,  320,    0,  415,
    0,  320,  320,  320,  320,    0,    0,    0,    0,    0,
  334,  334,    0,  334,  334,  334,  334,  334,  334,  334,
  334,  334,  334,  334,    0,   40,  320,    0,    0,  320,
    0,   19,    0,    0,    0,  320,  320,  320,  320,  320,
  320,  417,  417,  417,  417,  417,  417,  417,  417,    0,
    0,    0,  334,    0,    0,    0,    0,    0,    0,    0,
  417,  417,    0,  417,  417,    0,    0,    0,   41,   41,
    0,  417,  417,  417,  417,  417,  417,    0,  417,  417,
  417,    0,  417,  320,    0,    0,   41,   41,    0,   41,
   41,    0,    0,    0,    0,    0,    0,    0,   41,   41,
    0,    0,    0,    0,    0,   41,    0,    0,    0,    0,
   19,   19,  417,   70,  417,  417,  417,  417,  417,  417,
  417,  417,  417,  417,  417,  417,  417,  417,  417,  417,
  417,    0,    0,    0,    0,    0,  417,    0,    0,    0,
  417,  417,    0,   19,    0,  417,  417,    0,  417,   19,
   19,    0,    0,    0,    0,    0,   82,   82,   82,   82,
   82,   82,    0,    0,    0,    0,   41,   41,    0,    0,
  417,   41,   41,  417,   82,   82,    0,   82,   82,  417,
  417,  417,  417,  417,  417,   82,   82,   82,   82,   82,
   82,    0,    0,   82,   82,   82,   41,   19,    0,   41,
   24,   24,    0,   24,   24,   41,   41,   41,   41,   41,
   41,    0,   24,   24,  417,  417,    0,    0,    0,   24,
    0,    0,    0,    0,   82,   82,   82,  417,   82,   82,
   82,   82,   82,   82,   82,   82,   82,   82,   82,   82,
    0,   82,   82,   82,   82,    0,    0,    0,    0,    0,
   82,    0,    0,   41,   82,   82,   68,    0,    0,   82,
   82,   82,   82,    0,    0,    0,    0,    0,    0,    0,
   81,   81,   81,   81,   81,   81,    0,    0,    0,    0,
   24,   24,   39,    0,   82,   24,   24,   82,   81,   81,
    0,   81,   81,   82,   82,   82,   82,   82,   82,   81,
   81,   81,   81,   81,   81,    0,    0,   81,   81,   81,
   24,    0,    0,   24,    0,    0,    0,    0,    0,   24,
   24,   24,   24,   24,   24,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   81,   81,
   81,   82,   81,   81,   81,   81,   81,   81,   81,   81,
   81,   81,   81,   81,    0,   81,   81,   81,   81,    0,
    0,    0,    0,    0,   81,    0,    0,   24,   81,   81,
   66,    0,    0,   81,   81,   81,   81,    0,    0,    0,
    0,    0,    0,    0,   78,   78,   78,   78,   78,   78,
    0,    0,    0,    0,    0,    0,    0,    0,   81,    0,
    0,   81,   78,   78,    0,   78,   78,   81,   81,   81,
   81,   81,   81,   78,   78,   78,   78,   78,   78,    0,
    0,   78,   78,   78,  334,  334,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  334,    0,  334,  334,    0,    0,
    0,    0,    0,    0,   78,   81,   78,   78,   78,   78,
   78,   78,   78,   78,   78,   78,   78,   78,    0,   78,
   78,   78,   78,    0,    0,    0,    0,    0,   78,    0,
    0,    0,   78,   78,   64,    0,    0,   78,   78,   78,
   78,    0,    0,    0,  334,  334,    0,  334,  334,  334,
  334,  334,  334,  334,  334,  334,  334,  334,    0,    0,
    0,    0,   78,    0,    0,   78,    0,    0,    0,    0,
    0,   78,   78,   78,   78,   78,   78,  415,  415,  415,
  415,  415,  415,    0,    0,    0,  334,    0,    0,    0,
    0,    0,    0,    0,    0,  415,  415,    0,  415,  415,
    0,    0,    0,   40,   40,    0,  415,  415,  415,  415,
  415,  415,    0,    0,  415,  415,  415,  353,    0,   78,
    0,   40,   40,    0,   40,   40,    0,    0,    0,    0,
    0,    0,    0,   40,   40,    0,    0,    0,    0,    0,
   40,    0,    0,    0,    0,    0,    0,  415,   62,  415,
  415,  415,  415,  415,  415,  415,  415,  415,  415,  415,
  415,    0,  415,  415,  415,  415,    0,    0,    0,    0,
    0,  415,    0,    0,    0,  415,  415,    0,    0,    0,
  415,  415,  415,  415,    0,    0,    0,    0,    0,    0,
    0,   70,   70,   70,   70,   70,   70,    0,    0,    0,
    0,   40,   40,    0,    0,  415,   40,   40,  415,   70,
   70,    0,   70,   70,  415,  415,  415,  415,  415,  415,
   70,   70,   70,   70,   70,   70,    0,    0,   70,   70,
   70,   40,  334,  334,   40,    0,    0,    0,    0,    0,
   40,   40,   40,   40,   40,   40,    0,    0,    0,    0,
    0,    0,  334,    0,  334,  334,    0,    0,    0,    0,
    0,   70,  415,   70,   70,   70,   70,   70,   70,   70,
   70,   70,   70,   70,   70,    0,   70,   70,   70,   70,
    0,    0,    0,    0,    0,   70,    0,    0,   40,   70,
   70,   63,    0,    0,   70,   70,    0,   70,    0,    0,
    0,    0,  334,  334,    0,  334,  334,  334,  334,  334,
  334,  334,  334,  334,  334,  334,    0,   38,    0,   70,
    0,    0,   70,    0,    0,    0,    0,    0,   70,   70,
   70,   70,   70,   70,   68,   68,   68,   68,   68,   68,
    0,    0,    0,    0,  334,    0,    0,    0,    0,    0,
    0,    0,   68,   68,    0,   68,   68,    0,    0,    0,
   39,    0,    0,   68,   68,   68,   68,   68,   68,    0,
    0,   68,   68,    0,    0,  363,   70,    0,   39,   39,
    0,   39,   39,    0,    0,    0,    0,    0,    0,    0,
   39,   39,    0,    0,    0,    0,    0,   39,    0,    0,
    0,    0,    0,    0,   68,   61,   68,   68,   68,   68,
   68,   68,   68,   68,   68,   68,   68,   68,    0,   68,
   68,   68,   68,    0,    0,    0,    0,    0,   68,    0,
    0,    0,   68,   68,    0,    0,    0,   68,   68,    0,
   68,    0,    0,    0,    0,    0,    0,    0,   66,   66,
   66,   66,   66,   66,    0,    0,    0,    0,   39,   39,
    0,    0,   68,   39,   39,   68,   66,   66,    0,   66,
   66,   68,   68,   68,   68,   68,   68,   66,   66,   66,
   66,   66,   66,    0,    0,   66,   66,    0,   39,    0,
    0,   39,    0,    0,    0,    0,    0,   39,   39,   39,
   39,   39,   39,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   66,   68,
   66,   66,   66,   66,   66,   66,   66,   66,   66,   66,
   66,   66,    0,   66,   66,   66,   66,    0,    0,    0,
    0,    0,   66,    0,    0,   39,   66,   66,   59,    0,
    0,   66,   66,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   64,   64,   64,   64,   64,   64,    0,    0,
    0,    0,    0,    0,    0,    0,   66,    0,    0,   66,
   64,   64,    0,   64,   64,   66,   66,   66,   66,   66,
   66,   64,   64,   64,   64,   64,   64,    0,    0,   64,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   64,   66,   64,   64,   64,   64,   64,   64,
   64,   64,   64,   64,   64,   64,    0,   64,   64,   64,
   64,    0,    0,    0,    0,    0,   64,    0,    0,    0,
   64,   64,   60,    0,    0,   64,   64,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   62,   62,   62,   62,
   62,   62,    0,    0,    0,    0,    0,    0,    0,    0,
   64,    0,    0,   64,   62,   62,    0,   62,   62,   64,
   64,   64,   64,   64,   64,   62,   62,   62,   62,   62,
   62,    0,    0,   62,  334,  334,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  334,    0,  334,  334,    0,    0,
    0,    0,    0,    0,    0,    0,   62,   64,   62,   62,
   62,   62,   62,   62,   62,   62,   62,   62,   62,   62,
    0,   62,   62,   62,   62,    0,    0,    0,    0,    0,
   62,    0,    0,    0,   62,   62,   58,    0,    0,   62,
   62,    0,    0,    0,  334,  334,    0,  334,  334,  334,
  334,  334,  334,  334,  334,  334,  334,  334,    0,    0,
    0,    0,    0,    0,   62,    0,    0,   62,    0,    0,
    0,    0,    0,   62,   62,   62,   62,   62,   62,   63,
   63,   63,   63,   63,   63,    0,  334,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   63,   63,    0,
   63,   63,    0,    0,    0,   38,    0,    0,   63,   63,
   63,   63,   63,   63,    0,    0,   63,  367,    0,    0,
    0,   62,    0,   38,   38,   50,   38,   38,    0,    0,
    0,    0,    0,    0,    0,   38,   38,    0,    0,    0,
    0,    0,   38,    0,    0,    0,    0,    0,    0,   63,
    0,   63,   63,   63,   63,   63,   63,   63,   63,   63,
   63,   63,   63,    0,   63,   63,   63,   63,    0,    0,
    0,    0,    0,   63,    0,    0,    0,   63,   63,    0,
    0,    0,   63,   63,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   61,   61,   61,   61,   61,   61,    0,
    0,    0,    0,   38,   38,    0,    0,   63,   38,   38,
   63,   61,   61,    0,   61,   61,   63,   63,   63,   63,
   63,   63,   61,   61,   61,    0,   61,    0,    0,    0,
   61,  334,  334,   38,    0,    0,   38,    0,    0,   49,
    0,    0,   38,   38,   38,   38,   38,   38,    0,    0,
    0,  334,    0,  334,  334,    0,    0,    0,    0,    0,
    0,    0,    0,   61,   63,   61,   61,   61,   61,   61,
   61,   61,   61,   61,   61,   61,   61,    0,   61,   61,
   61,   61,    0,    0,    0,    0,    0,   61,  336,    0,
   38,   61,   61,    0,    0,    0,   61,   61,    0,    0,
    0,  334,  334,    0,  334,  334,  334,  334,  334,  334,
  334,  334,  334,  334,  334,    0,    0,    0,    0,    0,
    0,   61,    0,    0,   61,    0,    0,    0,   48,    0,
   61,   61,   61,   61,   61,   61,   59,   59,   59,   59,
   59,   59,    0,  334,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   59,   59,    0,   59,   59,    0,
    0,    0,    0,    0,    0,   59,   59,   59,    0,   59,
    0,    0,    0,   59,    0,    0,    0,    0,   61,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   59,    0,   59,   59,
   59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
   47,   59,   59,   59,   59,    0,    0,    0,    0,    0,
   59,    0,    0,    0,   59,   59,    0,    0,    0,   59,
   59,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   60,   60,   60,   60,   60,   60,    0,    0,    0,    0,
    0,    0,    0,    0,   59,    0,    0,   59,   60,   60,
    0,   60,   60,   59,   59,   59,   59,   59,   59,   60,
   60,   60,    0,   60,    0,    0,    0,   60,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   46,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   60,   59,   60,   60,   60,   60,   60,   60,   60,   60,
   60,   60,   60,   60,    0,   60,   60,   60,   60,    0,
    0,    0,    0,    0,   60,    0,    0,    0,   60,   60,
    0,    0,    0,   60,   60,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   58,   58,   58,   58,   58,   58,
    0,    0,    0,    0,    0,    0,    0,    0,   60,    0,
    0,   60,   58,   58,    0,   58,   58,   60,   60,   60,
   60,   60,   60,   58,   58,   58,   45,    0,    0,    0,
    0,   58,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   58,   60,   58,   58,   58,   58,
   58,   58,   58,   58,   58,   58,   58,   58,    0,   58,
   58,   58,   58,   50,   50,    0,    0,    0,    0,    0,
    0,    0,   58,   58,    0,    0,    0,   58,   58,    0,
    0,   50,   50,    0,   50,   50,    0,    0,    0,    0,
    0,    0,   50,   50,   50,   43,    0,    0,    0,    0,
   50,    0,   58,    0,    0,   58,    0,    0,    0,    0,
    0,   58,   58,   58,   58,   58,   58,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   50,    0,   50,   50,   50,   50,   50,
   50,   50,   50,   50,   50,   50,   50,    0,   50,   50,
   50,   50,    0,    0,    0,    0,    0,    0,    0,   58,
    0,   50,   50,    0,    0,    0,   50,   50,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   49,   49,    0,
    0,    0,    0,   42,    0,    0,    0,    0,    0,    0,
    0,   50,    0,    0,   50,   49,   49,    0,   49,   49,
   50,   50,   50,   50,   50,   50,   49,   49,   49,    0,
    0,    0,    0,    0,   49,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   49,   50,   49,
   49,   49,   49,   49,   49,   49,   49,   49,   49,   49,
   49,    0,   49,   49,   49,   49,   48,   48,    0,    0,
    0,   44,    0,    0,    0,   49,   49,    0,    0,    0,
   49,   49,    0,    0,   48,   48,    0,   48,   48,    0,
    0,    0,    0,    0,    0,   48,   48,   48,    0,    0,
    0,    0,    0,   48,    0,   49,    0,    0,   49,    0,
    0,    0,    0,    0,   49,   49,   49,   49,   49,   49,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   48,    0,   48,   48,
   48,   48,   48,   48,   48,   48,   48,   48,   48,   48,
    0,   48,   48,   48,   48,    0,    0,    0,   47,   47,
    0,    0,   49,    0,   48,   48,    0,    0,    0,   48,
   48,    0,    0,    0,    0,    0,   47,   47,    0,   47,
   47,    0,    0,    0,    0,    0,    0,   47,   47,   47,
    0,    0,    0,  246,   48,   47,    0,   48,    0,    0,
    0,    0,    0,   48,   48,   48,   48,   48,   48,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   47,    0,
   47,   47,   47,   47,   47,   47,   47,   47,   47,   47,
   47,   47,    0,   47,   47,    0,   46,   46,    0,    0,
    0,   48,    0,    0,    0,    0,   47,   47,    0,    0,
    0,   47,   47,    0,   46,   46,    0,   46,   46,    0,
    0,    0,    0,    0,    0,   46,   46,   46,    0,    0,
    0,    0,    0,   46,    0,    0,   47,    0,    0,   47,
    0,    0,    0,    0,    0,   47,   47,   47,   47,   47,
   47,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   46,    0,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
    0,   46,   46,    0,   45,   45,    0,    0,    0,    0,
    0,    0,    0,   47,   46,   46,    0,    0,    0,   46,
   46,    0,   45,   45,    0,   45,   45,    0,    0,    0,
    0,    0,    0,    0,   45,   45,    0,    0,    0,    0,
    0,   45,    0,    0,   46,    0,    0,   46,    0,    0,
    0,    0,    0,   46,   46,   46,   46,   46,   46,    0,
    0,  254,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   45,    0,   45,   45,   45,   45,
   45,   45,   45,   45,   45,   45,   45,   45,    0,   45,
   45,    0,    0,   43,   43,    0,    0,    0,    0,    0,
    0,   46,   45,   45,    0,    0,    0,   45,   45,    0,
    0,   43,   43,    0,   43,   43,    0,    0,    0,    0,
    0,    0,    0,   43,   43,    0,    0,    0,    0,    0,
   43,    0,   45,    0,    0,   45,    0,    0,    0,    0,
    0,   45,   45,   45,   45,   45,   45,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   43,    0,   43,   43,   43,   43,   43,
   43,   43,   43,   43,   43,   43,   43,    0,   43,   43,
    0,   42,   42,    0,    0,    0,    0,    0,    0,   45,
    0,   43,   43,    0,    0,    0,   43,   43,    0,   42,
   42,    0,   42,   42,    0,    0,    0,    0,    0,    0,
    0,   42,   42,    0,    0,    0,    0,    0,   42,    0,
    0,   43,    0,    0,   43,    0,    0,    0,    0,    0,
   43,   43,   43,   43,   43,   43,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   42,    0,   42,   42,   42,   42,   42,   42,   42,
   42,   42,   42,   42,   42,    6,   42,   42,    0,   44,
   44,    0,    0,    0,    0,    0,    0,    0,   43,   42,
   42,    0,    0,    0,   42,   42,    0,   44,   44,    0,
   44,   44,    0,    0,    0,    0,    0,    0,    0,   44,
   44,    0,    0,    0,    0,    0,   44,    0,    0,   42,
    0,    0,   42,    0,    0,    0,    0,    0,   42,   42,
   42,   42,   42,   42,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   44,
    0,   44,   44,   44,   44,   44,   44,   44,   44,   44,
   44,   44,   44,    0,   44,   44,    0,    0,    0,  248,
  248,    0,  248,  248,  248,  248,   42,   44,   44,    0,
  248,    0,   44,   44,  248,  248,    0,  248,  248,  248,
  248,  248,  248,  248,  248,  248,  248,  248,  248,  248,
    0,    0,    0,    0,    0,    0,    0,   44,    0,    0,
   44,  248,    0,    0,    0,    0,   44,   44,   44,   44,
   44,   44,    0,    0,  248,  248,    0,    0,    0,  248,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  248,  248,  248,  248,    0,  248,  248,
  248,  248,  248,  248,  248,    0,  248,  248,    0,  248,
  248,    0,    0,  248,   44,  248,  248,  248,  248,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  248,  248,    0,    0,    0,    0,  248,  248,    0,    0,
    0,    0,  248,  248,  248,  248,    0,    0,  248,  248,
  248,  248,    0,  248,  248,  248,  248,  248,  248,  248,
  248,  248,  248,  248,  248,  248,  248,  248,  248,    0,
    0,    0,  246,    0,    0,    0,  248,  248,    0,    0,
    0,  334,  334,    0,    0,    0,    0,    0,  248,    0,
  248,    0,    0,    0,    0,  248,  248,    0,    0,  248,
  248,  334,    0,  334,  334,  248,  248,  254,  254,    0,
  254,  254,  254,  254,    0,    0,    0,    0,    0,    0,
    0,    0,  254,  254,    0,  254,  254,  254,  254,  254,
  254,  254,  254,  254,  254,  254,  254,  254,  339,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  334,  334,    0,  334,  334,  334,  334,  334,  334,
  334,  334,  334,  334,  334,    0,    0,  254,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  254,  254,  254,  254,    0,  254,  254,  254,  254,
  254,  254,    0,  334,    0,    0,    0,  254,  254,    0,
    0,  254,    0,  254,  254,  254,  254,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  254,  254,
    0,    0,    0,    0,  254,  254,    0,    0,    0,    0,
  254,  254,  254,  254,    0,    0,  254,  254,  254,  254,
    0,  254,  254,  254,  254,  254,  254,  254,  254,  254,
  254,  254,  254,  254,  254,  254,  254,    0,    0,    0,
  254,    0,    0,    0,  254,  254,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  254,    0,  254,    0,
    0,    0,    0,  254,  254,    0,    0,  254,  254,  223,
  224,    0,    0,  254,  254,    0,    0,    0,    0,    0,
    0,    6,    6,    0,    6,    6,    6,    6,    0,  225,
    0,  226,  227,    0,    0,    0,    6,    6,    0,    6,
    6,    6,    6,    6,    6,    6,    6,    6,    6,    6,
    6,    0,  334,  334,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  334,    0,  334,  334,    0,    0,    0,  228,
  229,    0,  230,  231,  232,  233,  234,  235,  236,  237,
  238,  239,  240,    0,    0,    6,    6,    6,    6,    0,
    6,    6,    6,    6,    6,    6,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    6,    0,    6,    6,    6,
    6,  241,  334,  334,    0,  334,  334,  334,  334,  334,
  334,  334,  334,  334,  334,  334,    0,    0,    0,    0,
    0,    0,    6,    6,    0,    0,    0,    0,    6,    6,
    0,    0,    0,    0,    6,    6,    6,    6,    0,    0,
    6,    6,    6,    6,  334,    6,    6,    6,    6,    6,
    6,    6,    6,    6,    6,    6,    6,    6,    6,    6,
    6,    0,    0,    0,    6,    0,    0,    0,    6,    6,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    6,    0,    0,    0,    0,    0,    0,    6,    6,    0,
    0,    6,    6,    0,    0,    0,    0,    6,    6,  248,
  248,    0,  248,  248,  248,  248,    0,    0,    0,    0,
  248,    0,    0,    0,  248,  248,    0,  248,  248,  248,
  248,  248,  248,  248,  248,  248,  248,  248,  248,  248,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  248,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  248,  248,    0,    0,    0,  248,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,  248,  248,  248,  248,    0,  248,  248,
  248,  248,  248,  248,  248,    0,  248,  248,    0,  248,
  248,    0,    0,  248,    0,  248,  248,  248,  248,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  248,  248,    0,    0,    0,    0,  248,  248,    0,    0,
    0,    0,  248,  248,  248,  248,    0,    0,  248,  248,
  248,  248,    0,  248,  248,  248,  248,  248,  248,  248,
  248,  248,  248,  248,  248,  248,  248,  248,  248,    0,
    0,    0,    0,    0,    0,    0,  248,  248,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  248,    0,
  248,    0,    0,    0,    0,  248,  248,    0,    0,  248,
  248,    0,    0,    0,    0,  248,  248,  252,  252,    0,
  252,  252,  252,  252,    0,    0,    0,    0,    0,    0,
    0,    0,  252,  252,    0,  252,  252,  252,  252,  252,
  252,  252,  252,  252,  252,  252,  252,  252,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  252,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,  252,  252,    0,    0,    0,  252,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  252,  252,  252,  252,    0,  252,  252,  252,  252,
  252,  252,  252,    0,  252,  252,    0,  252,  252,    0,
    0,  252,    0,  252,  252,  252,  252,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  252,  252,
    0,    0,    0,    0,  252,  252,    0,    0,    0,    0,
  252,  252,  252,  252,    0,    0,  252,  252,  252,  252,
    0,  252,  252,  252,  252,  252,  252,  252,  252,  252,
  252,  252,  252,  252,  252,  252,  252,  318,  318,  318,
    0,    0,    0,    0,  252,  252,    0,    0,    0,    0,
    0,    0,    0,  318,    0,    0,  252,    0,  252,    0,
    0,    0,    0,  252,  252,    0,    0,  252,  252,    0,
    0,    0,    0,  252,  252,   19,   20,    0,   21,   22,
   23,   24,    0,    0,    0,    0,    0,    0,    0,    0,
   25,   26,    0,   27,   28,   29,   30,   31,   32,   33,
   34,   35,   36,   37,   38,    0,    0,    0,  318,  318,
    0,  318,  318,  318,  318,  318,  318,  318,  318,  318,
  318,  318,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,  318,  318,    0,    0,
    0,   39,   40,    0,   41,   42,   43,   44,   45,   46,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   47,   48,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   49,   50,    0,    0,
    0,    0,   51,   52,    0,    0,    0,    0,   53,   54,
   55,   56,    0,    0,   57,   58,   59,   60,    0,    0,
    0,   61,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   62,   63,    0,    0,    0,    0,    0,
    0,    0,   64,   65,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   66,    0,    0,    0,    0,    0,
    0,    0,   67,    0,    0,   68,   69,    0,    0,    0,
    0,   70,   71,   19,   20,    0,   21,   22,   23,   24,
    0,    0,    0,    0,    0,    0,    0,    0,   25,   26,
    0,   27,   28,   29,   30,   31,   32,   33,   34,   35,
   36,   37,   38,    0,   19,   20,    0,   21,   22,   23,
   24,    0,    0,    0,    0,    0,    0,    0,    0,   25,
   26,    0,   27,   28,   29,   30,   31,   32,   33,   34,
   35,   36,   37,   38,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   39,
   40,    0,   41,   42,   43,   44,   45,   46,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   47,   48,    0,    0,    0,    0,    0,    0,    0,
   39,   40,    0,   41,   42,   43,   44,   45,   46,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   51,   52,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   57,   58,   59,   60,    0,    0,    0,   61,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   51,   52,    0,    0,    0,    0,    0,    0,    0,
   64,   65,    0,    0,    0,    0,    0,    0,    0,    0,
   61,    0,   66,    0,    0,    0,    0,    0,    0,    0,
   67,    0,    0,   68,   69,    0,    0,    0,    0,   70,
   71,   64,   65,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   66,    0,    0,    0,    0,    0,    0,
    0,   67,    0,    0,   68,   69,    0,    0,    0,    0,
   70,   71,
};
static short yycheck[] = null;

{	int arraySizeCount = 4723;
	String yycheckTableFileName = "YYCheckTable.tbl";
	yycheck = new short[arraySizeCount];
	java.io.DataInputStream dis = null;
	try {
		java.io.InputStream in = this.getClass().getResourceAsStream(yycheckTableFileName);
		dis =
			new java.io.DataInputStream(in);
		for (int i = 0; i < arraySizeCount; i++) {
			yycheck[i] = dis.readShort();
			// System.out.println(yycheck[i]);
		}
	}
	catch (java.io.FileNotFoundException e) {
		e.printStackTrace();
	}
	catch (java.io.IOException e) {
		e.printStackTrace();
	}
	finally {
		if (dis != null) {
			try {
				dis.close();
			}
			catch (java.io.IOException e1) {
				e1.printStackTrace();
			}
		}
	}
}


final static short YYFINAL=2;
final static short YYMAXTOKEN=714;
final static String yyname[] = {
"end-of-file",null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,"VT_STRING","VT_NUMBER","VT_ID","NTQueryList","NTModule",
"NTMainModule","NTLibraryModule","NTModuleDecl","NTProlog","NTSeparator",
"NTVersionDecl","NTSetter","NTImport","NTModuleImport","NTVarDecl",
"NTQueryBody","NTExpr","NTExprSingle","NTFLWORExpr","NTForClause",
"NTPositionalVar","NTLetClause","NTWhereClause","NTOrderByClause",
"NTOrderSpecList","NTOrderSpec","NTOrderModifier","NTQuantifiedExpr",
"NTTypeswitchExpr","NTCaseClause","NTIfExpr","NTOrExpr","NTAndExpr",
"NTComparisonExpr","NTRangeExpr","NTAdditiveExpr","NTMultiplicativeExpr",
"NTUnaryExpr","NTUnionExpr","NTIntersectExceptExpr","NTInstanceofExpr",
"NTTreatExpr","NTCastableExpr","NTCastExpr","NTValueExpr","NTPathExpr",
"NTRelativePathExpr","NTStepExpr","NTAxisStep","NTFilterExpr",
"NTContextItemExpr","NTPrimaryExpr","NTVarRef","NTPredicate","NTPredicateList",
"NTValidateExpr","NTValidationContext","NTConstructor","NTComputedConstructor",
"NTGeneralComp","NTValueComp","NTNodeComp","NTForwardStep","NTReverseStep",
"NTAbbrevForwardStep","NTAbbrevReverseStep","NTForwardAxis","NTReverseAxis",
"NTNodeTest","NTNameTest","NTWildcard","NTLiteral","NTNumericLiteral",
"NTParenthesizedExpr","NTFunctionCall","NTDirElemConstructor",
"NTCompDocConstructor","NTCompElemConstructor","NTCompElemBody",
"NTCompElemNamespace","NTCompAttrConstructor","NTCompXmlPI","NTCompXmlComment",
"NTCompTextConstructor","NTCdataSection","NTXmlPI","NTXmlComment",
"NTElementContent","NTAttributeList","NTAttributeValue",
"NTQuotAttrValueContent","NTAposAttrValueContent","NTEnclosedExpr",
"NTXMLSpaceDecl","NTDefaultCollationDecl","NTBaseURIDecl","NTNamespaceDecl",
"NTDefaultNamespaceDecl","NTFunctionDecl","NTParamList","NTParam",
"NTTypeDeclaration","NTSingleType","NTSequenceType","NTAtomicType","NTItemType",
"NTKindTest","NTElementTest","NTAttributeTest","NTElementName",
"NTAttributeName","NTTypeName","NTElementNameOrWildcard",
"NTAttribNameOrWildcard","NTTypeNameOrWildcard","NTPITest","NTDocumentTest",
"NTCommentTest","NTTextTest","NTAnyKindTest","NTSchemaContextPath",
"NTSchemaContextLoc","NTOccurrenceIndicator","NTValidationDecl",
"NTSchemaImport","NTSchemaPrefix","NTQueryListTail","NTOptionalModule",
"NTOptionalVersionDecl","NTMainOrLibraryModule","NTSetterList","NTDeclList",
"NTDeclChoice","NTImportPrefixDecl","NTLocationHint",
"NTVarDeclOptionalTypeDecl","NTVarDeclAssignmentOrExtern","NTCommaExpr",
"NTFLWORClauseList","NTOptionalWhere","NTOptionalOrderBy",
"NTForTypeDeclarationOption","NTPositionalVarOption","NTForClauseTail",
"NTForTailTypeDeclarationOption","NTTailPositionalVarOption",
"NTLetTypeDeclarationOption","NTLetClauseTail","NTLetTailTypeDeclarationOption",
"NTOrderByOrOrderByStable","NTOrderSpecListTail","NTSortDirectionOption",
"NTEmptyPosOption","NTCollationSpecOption","NTSomeOrEvery",
"NTQuantifiedTypeDeclarationOption","NTQuantifiedVarDeclListTail",
"NTQuantifiedTailTypeDeclarationOption","NTCaseClauseList",
"NTDefaultClauseVarBindingOption","NTCaseClauseVarBindingOption",
"NTOptionalRootExprTail","NTRelativePathExprTail","NTRelativePathExprStepSep",
"NTForwardOrReverseStep","NTValidateExprSpecifiers",
"NTValidateSchemaModeContextOption","NTOptionalAtSugar","NTOptionalExpr",
"NTFunctionNameOpening","NTArgList","NTArgListTail","NTTagOpenStart",
"NTTagClose","NTElementContentBody","NTOptionalWhitespaceBeforeEndTagClose",
"NTCompElemConstructorSpec","NTOptionalCompElemBody",
"NTCompElemNamespaceOrExprSingle","NTCompElemBodyTail",
"NTTailCompElemNamespaceOrExprSingle","NTCompAttrConstructorOpening",
"NTOptionalCompAttrValExpr","NTCompXmlPIOpening","NTOptionalCompXmlPIExpr",
"NTOptionalCompTextExpr","NTCdataSectionOpen","NTCdataSectionBody",
"NTProcessingInstructionStartOpen","NTOptionalPIContent","NTXmlPIContentBody",
"NTXmlCommentStartOpen","NTXmlCommentContents","NTOptionalAttribute",
"NTOptionalWhitespaceBeforeValueIndicator",
"NTOptionalWhitespaceBeforeAttributeValue","NTQuotAttributeValueContents",
"NTQuotContentOrEscape","NTAposAttributeValueContents","NTAposContentOrEscape",
"NTEnclosedExprOpening","NTXMLSpacePreserveOrStrip",
"NTDeclareDefaultElementOrFunction","NTOptionalParamList",
"NTFunctionDeclSigClose","NTFunctionDeclBody","NTParamListTail",
"NTOptionalTypeDeclarationForParam","NTOptionalOccurrenceIndicator",
"NTOptionalOccurrenceIndicatorForSequenceType","NTElementTypeOpen",
"NTOptionalElementTestBody","NTElementTestBodyOptionalParam","NTNillableOption",
"NTAttributeTestOpening","NTOptionalAttributeTestBody",
"NTAttributeTestBodyOptionalParam","NTPITestOpening","NTOptionalPITestBody",
"NTDocumentTestOpening","NTOptionalDocumentTestBody","NTCommentTestOpen",
"NTTextTestOpen","NTAnyKindTestOpening","NTSchemaContextPathTail",
"NTOptionalSchemaContextLocContextPath","NTOptionalSchemaImportPrefixDecl",
"NTOptionalLocationHint","Pragma","MUExtension","ExtensionStart","ExprComment",
"ExprCommentStart","ExprCommentContent","ExtensionContents","ExtensionEnd",
"ExprCommentEnd","PragmaKeyword","Extension","XmlCommentStart",
"XmlCommentStartForElementContent","XmlCommentEnd","IntegerLiteral",
"DecimalLiteral","DoubleLiteral","StringLiteral","StringLiteralForKindTest",
"VersionStringLiteral","AtStringLiteral","URLLiteral","ModuleNamespace",
"NotOccurrenceIndicator","S","SForPI","ProcessingInstructionStart",
"ProcessingInstructionStartForElementContent","ProcessingInstructionEnd",
"AxisChild","AxisDescendant","AxisParent","AxisAttribute","AxisSelf",
"AxisDescendantOrSelf","AxisAncestor","AxisFollowingSibling",
"AxisPrecedingSibling","AxisFollowing","AxisPreceding","AxisAncestorOrSelf",
"DefineFunction","External","Or","And","Div","Idiv","Mod","Multiply","In",
"ValidationMode","SchemaModeForDeclareValidate","Nillable","DeclareValidation",
"SchemaGlobalContextSlash","SchemaGlobalTypeName","SchemaGlobalContext",
"SchemaContextStepSlash","SchemaContextStep","InContextForKindTest","Global",
"Satisfies","Return","Then","Else","Default","DeclareXMLSpace","DeclareBaseURI",
"XMLSpacePreserve","XMLSpaceStrip","Namespace","DeclareNamespace","To","Where",
"Collation","Intersect","Union","Except","As","AtWord","Case","Instanceof",
"Castable","RparAs","Item","ElementType","AttributeType","ElementQNameLbrace",
"AttributeQNameLbrace","NamespaceNCNameLbrace","PINCNameLbrace","PILbrace",
"CommentLbrace","ElementLbrace","AttributeLbrace","TextLbrace",
"DeclareCollation","DefaultElement","DeclareDefaultElement",
"DeclareDefaultFunction","EmptyTok","ImportSchemaToken","ImportModuleToken",
"Nmstart","Nmchar","Star","AnyName","NCNameColonStar","StarColonNCName","Root",
"RootDescendants","Slash","SlashSlash","Equals","AssignEquals","Is","NotEquals",
"LtEquals","LtLt","GtEquals","GtGt","FortranEq","FortranNe","FortranGt",
"FortranGe","FortranLt","FortranLe","ColonEquals","Lt","Gt","Minus","Plus",
"UnaryMinus","UnaryPlus","OccurrenceZeroOrOne","OccurrenceZeroOrMore",
"OccurrenceOneOrMore","Vbar","Lpar","At","Lbrack","Rbrack","Rpar",
"RparForKindTest","Some","Every","ForVariable","LetVariable","CastAs","TreatAs",
"ValidateLbrace","ValidateContext","ValidateGlobal","ValidateSchemaMode",
"Digits","DocumentLpar","DocumentLparForKindTest","DocumentLbrace","NodeLpar",
"CommentLpar","TextLpar","ProcessingInstructionLpar","ElementTypeForKindTest",
"ElementTypeForDocumentTest","AttributeTypeForKindTest",
"ProcessingInstructionLparForKindTest","TextLparForKindTest",
"CommentLparForKindTest","NodeLparForKindTest","IfLpar","TypeswitchLpar",
"Comma","CommaForKindTest","SemiColon","QuerySeparator","EscapeQuot","OpenQuot",
"CloseQuot","Dot","DotDot","OrderBy","OrderByStable","Ascending","Descending",
"EmptyGreatest","EmptyLeast","PITarget","NCName","Prefix","LocalPart",
"VariableIndicator","VarName","DefineVariable","QNameForSequenceType",
"QNameForAtomicType","QNameForItemType","ExtensionQName","QName","QNameLpar",
"NCNameForPrefix","NCNameForPI","CdataSectionStart",
"CdataSectionStartForElementContent","CdataSectionEnd","PredefinedEntityRef",
"HexDigits","CharRef","StartTagOpen","StartTagOpenRoot","StartTagClose",
"EmptyTagClose","EndTagOpen","EndTagClose","ValueIndicator","TagQName","Lbrace",
"LbraceExprEnclosure","LCurlyBraceEscape","RCurlyBraceEscape","EscapeApos",
"OpenApos","CloseApos","ElementContentChar","QuotAttContentChar",
"AposAttContentChar","CommentContentChar","PIContentChar","CDataSectionChar",
"Rbrace","WhitespaceChar",
};
final static String yyrule[] = {
"$accept : QueryList",
"QueryList : Module QueryListTail",
"Module : OptionalVersionDecl MainOrLibraryModule",
"MainModule : Prolog QueryBody",
"LibraryModule : ModuleDecl Prolog",
"ModuleDecl : ModuleNamespace NCNameForPrefix AssignEquals URLLiteral Separator",
"Prolog : SetterList DeclList",
"Separator : SemiColon",
"VersionDecl : VersionStringLiteral Separator",
"Setter : XMLSpaceDecl",
"Setter : DefaultCollationDecl",
"Setter : BaseURIDecl",
"Setter : ValidationDecl",
"Setter : DefaultNamespaceDecl",
"Import : SchemaImport",
"Import : ModuleImport",
"ModuleImport : ImportModuleToken ImportPrefixDecl URLLiteral LocationHint",
"VarDecl : DefineVariable VarName VarDeclOptionalTypeDecl VarDeclAssignmentOrExtern",
"QueryBody : Expr",
"Expr : ExprSingle CommaExpr",
"ExprSingle : FLWORExpr",
"ExprSingle : QuantifiedExpr",
"ExprSingle : TypeswitchExpr",
"ExprSingle : IfExpr",
"ExprSingle : OrExpr",
"FLWORExpr : FLWORClauseList OptionalWhere OptionalOrderBy Return ExprSingle",
"ForClause : ForVariable VarName ForTypeDeclarationOption PositionalVarOption In ExprSingle ForClauseTail",
"PositionalVar : AtWord VariableIndicator VarName",
"LetClause : LetVariable VarName LetTypeDeclarationOption ColonEquals ExprSingle LetClauseTail",
"WhereClause : Where Expr",
"OrderByClause : OrderByOrOrderByStable OrderSpecList",
"OrderSpecList : OrderSpec OrderSpecListTail",
"OrderSpec : ExprSingle OrderModifier",
"OrderModifier : SortDirectionOption EmptyPosOption CollationSpecOption",
"QuantifiedExpr : SomeOrEvery VarName QuantifiedTypeDeclarationOption In ExprSingle QuantifiedVarDeclListTail Satisfies ExprSingle",
"TypeswitchExpr : TypeswitchLpar Expr Rpar CaseClauseList Default DefaultClauseVarBindingOption Return ExprSingle",
"CaseClause : Case CaseClauseVarBindingOption SequenceType Return ExprSingle",
"IfExpr : IfLpar Expr Rpar Then ExprSingle Else ExprSingle",
"OrExpr : OrExpr Or AndExpr",
"OrExpr : AndExpr",
"AndExpr : AndExpr And ComparisonExpr",
"AndExpr : ComparisonExpr",
"ComparisonExpr : ComparisonExpr ValueComp RangeExpr",
"ComparisonExpr : ComparisonExpr GeneralComp RangeExpr",
"ComparisonExpr : ComparisonExpr NodeComp RangeExpr",
"ComparisonExpr : RangeExpr",
"RangeExpr : RangeExpr To AdditiveExpr",
"RangeExpr : AdditiveExpr",
"AdditiveExpr : AdditiveExpr Plus MultiplicativeExpr",
"AdditiveExpr : AdditiveExpr Minus MultiplicativeExpr",
"AdditiveExpr : MultiplicativeExpr",
"MultiplicativeExpr : MultiplicativeExpr Multiply UnaryExpr",
"MultiplicativeExpr : MultiplicativeExpr Div UnaryExpr",
"MultiplicativeExpr : MultiplicativeExpr Idiv UnaryExpr",
"MultiplicativeExpr : MultiplicativeExpr Mod UnaryExpr",
"MultiplicativeExpr : UnaryExpr",
"UnaryExpr : UnaryMinus UnaryExpr",
"UnaryExpr : UnaryPlus UnaryExpr",
"UnaryExpr : UnionExpr",
"UnionExpr : UnionExpr Union IntersectExceptExpr",
"UnionExpr : UnionExpr Vbar IntersectExceptExpr",
"UnionExpr : IntersectExceptExpr",
"IntersectExceptExpr : IntersectExceptExpr Intersect InstanceofExpr",
"IntersectExceptExpr : IntersectExceptExpr Except InstanceofExpr",
"IntersectExceptExpr : InstanceofExpr",
"InstanceofExpr : InstanceofExpr Instanceof SequenceType",
"InstanceofExpr : TreatExpr",
"TreatExpr : TreatExpr TreatAs SequenceType",
"TreatExpr : CastableExpr",
"CastableExpr : CastableExpr Castable SingleType",
"CastableExpr : CastExpr",
"CastExpr : CastExpr CastAs SingleType",
"CastExpr : ValueExpr",
"ValueExpr : ValidateExpr",
"ValueExpr : PathExpr",
"PathExpr : Root OptionalRootExprTail",
"PathExpr : RootDescendants RelativePathExpr",
"PathExpr : RelativePathExpr",
"RelativePathExpr : StepExpr RelativePathExprTail",
"StepExpr : AxisStep",
"StepExpr : FilterExpr",
"AxisStep : ForwardOrReverseStep PredicateList",
"FilterExpr : PrimaryExpr PredicateList",
"ContextItemExpr : Dot",
"PrimaryExpr : Literal",
"PrimaryExpr : VarRef",
"PrimaryExpr : ParenthesizedExpr",
"PrimaryExpr : ContextItemExpr",
"PrimaryExpr : FunctionCall",
"PrimaryExpr : Constructor",
"VarRef : VariableIndicator VarName",
"Predicate : Lbrack Expr Rbrack",
"PredicateList :",
"PredicateList : PredicateList Predicate",
"ValidateExpr : ValidateExprSpecifiers Expr Rbrace",
"ValidationContext : InContextForKindTest SchemaContextLoc",
"ValidationContext : Global",
"Constructor : DirElemConstructor",
"Constructor : ComputedConstructor",
"Constructor : XmlComment",
"Constructor : XmlPI",
"Constructor : CdataSection",
"ComputedConstructor : CompElemConstructor",
"ComputedConstructor : CompAttrConstructor",
"ComputedConstructor : CompDocConstructor",
"ComputedConstructor : CompTextConstructor",
"ComputedConstructor : CompXmlPI",
"ComputedConstructor : CompXmlComment",
"GeneralComp : Equals",
"GeneralComp : NotEquals",
"GeneralComp : Lt",
"GeneralComp : LtEquals",
"GeneralComp : Gt",
"GeneralComp : GtEquals",
"ValueComp : FortranEq",
"ValueComp : FortranNe",
"ValueComp : FortranLt",
"ValueComp : FortranLe",
"ValueComp : FortranGt",
"ValueComp : FortranGe",
"NodeComp : Is",
"NodeComp : LtLt",
"NodeComp : GtGt",
"ForwardStep : ForwardAxis NodeTest",
"ForwardStep : AbbrevForwardStep",
"ReverseStep : ReverseAxis NodeTest",
"ReverseStep : AbbrevReverseStep",
"AbbrevForwardStep : OptionalAtSugar NodeTest",
"AbbrevReverseStep : DotDot",
"ForwardAxis : AxisChild",
"ForwardAxis : AxisDescendant",
"ForwardAxis : AxisAttribute",
"ForwardAxis : AxisSelf",
"ForwardAxis : AxisDescendantOrSelf",
"ForwardAxis : AxisFollowingSibling",
"ForwardAxis : AxisFollowing",
"ReverseAxis : AxisParent",
"ReverseAxis : AxisAncestor",
"ReverseAxis : AxisPrecedingSibling",
"ReverseAxis : AxisPreceding",
"ReverseAxis : AxisAncestorOrSelf",
"NodeTest : KindTest",
"NodeTest : NameTest",
"NameTest : QName",
"NameTest : Wildcard",
"Wildcard : Star",
"Wildcard : NCNameColonStar",
"Wildcard : StarColonNCName",
"Literal : NumericLiteral",
"Literal : StringLiteral",
"NumericLiteral : IntegerLiteral",
"NumericLiteral : DecimalLiteral",
"NumericLiteral : DoubleLiteral",
"ParenthesizedExpr : Lpar OptionalExpr Rpar",
"FunctionCall : FunctionNameOpening ArgList Rpar",
"DirElemConstructor : TagOpenStart TagQName AttributeList TagClose",
"CompDocConstructor : DocumentLbrace Expr Rbrace",
"CompElemConstructor : CompElemConstructorSpec OptionalCompElemBody Rbrace",
"CompElemBody : CompElemNamespaceOrExprSingle CompElemBodyTail",
"CompElemNamespace : NamespaceNCNameLbrace StringLiteral Rbrace",
"CompAttrConstructor : CompAttrConstructorOpening OptionalCompAttrValExpr Rbrace",
"CompXmlPI : CompXmlPIOpening OptionalCompXmlPIExpr Rbrace",
"CompXmlComment : CommentLbrace Expr Rbrace",
"CompTextConstructor : TextLbrace OptionalCompTextExpr Rbrace",
"CdataSection : CdataSectionOpen CdataSectionBody CdataSectionEnd",
"XmlPI : ProcessingInstructionStartOpen PITarget OptionalPIContent ProcessingInstructionEnd",
"XmlComment : XmlCommentStartOpen XmlCommentContents XmlCommentEnd",
"ElementContent : ElementContentChar",
"ElementContent : LCurlyBraceEscape",
"ElementContent : RCurlyBraceEscape",
"ElementContent : DirElemConstructor",
"ElementContent : EnclosedExpr",
"ElementContent : CdataSection",
"ElementContent : CharRef",
"ElementContent : PredefinedEntityRef",
"ElementContent : XmlComment",
"ElementContent : XmlPI",
"AttributeList :",
"AttributeList : AttributeList S OptionalAttribute",
"AttributeValue : OpenQuot QuotAttributeValueContents CloseQuot",
"AttributeValue : OpenApos AposAttributeValueContents CloseApos",
"QuotAttrValueContent : QuotAttContentChar",
"QuotAttrValueContent : CharRef",
"QuotAttrValueContent : LCurlyBraceEscape",
"QuotAttrValueContent : RCurlyBraceEscape",
"QuotAttrValueContent : EnclosedExpr",
"QuotAttrValueContent : PredefinedEntityRef",
"AposAttrValueContent : AposAttContentChar",
"AposAttrValueContent : CharRef",
"AposAttrValueContent : LCurlyBraceEscape",
"AposAttrValueContent : RCurlyBraceEscape",
"AposAttrValueContent : EnclosedExpr",
"AposAttrValueContent : PredefinedEntityRef",
"EnclosedExpr : EnclosedExprOpening Expr Rbrace",
"XMLSpaceDecl : DeclareXMLSpace XMLSpacePreserveOrStrip",
"DefaultCollationDecl : DeclareCollation URLLiteral",
"BaseURIDecl : DeclareBaseURI URLLiteral",
"NamespaceDecl : DeclareNamespace NCNameForPrefix AssignEquals URLLiteral",
"DefaultNamespaceDecl : DeclareDefaultElementOrFunction Namespace URLLiteral",
"FunctionDecl : DefineFunction QNameLpar OptionalParamList FunctionDeclSigClose FunctionDeclBody",
"ParamList : Param ParamListTail",
"Param : VariableIndicator VarName OptionalTypeDeclarationForParam",
"TypeDeclaration : As SequenceType",
"SingleType : AtomicType OptionalOccurrenceIndicator",
"SequenceType : ItemType OptionalOccurrenceIndicatorForSequenceType",
"SequenceType : EmptyTok",
"AtomicType : QNameForAtomicType",
"AtomicType : QNameForSequenceType",
"ItemType : AtomicType",
"ItemType : KindTest",
"ItemType : Item",
"KindTest : DocumentTest",
"KindTest : ElementTest",
"KindTest : AttributeTest",
"KindTest : PITest",
"KindTest : CommentTest",
"KindTest : TextTest",
"KindTest : AnyKindTest",
"ElementTest : ElementTypeOpen OptionalElementTestBody RparForKindTest",
"AttributeTest : AttributeTestOpening OptionalAttributeTestBody RparForKindTest",
"ElementName : QNameForItemType",
"AttributeName : QNameForItemType",
"TypeName : QNameForItemType",
"ElementNameOrWildcard : ElementName",
"ElementNameOrWildcard : AnyName",
"AttribNameOrWildcard : AttributeName",
"AttribNameOrWildcard : AnyName",
"TypeNameOrWildcard : TypeName",
"TypeNameOrWildcard : AnyName",
"PITest : PITestOpening OptionalPITestBody RparForKindTest",
"DocumentTest : DocumentTestOpening OptionalDocumentTestBody RparForKindTest",
"CommentTest : CommentTestOpen RparForKindTest",
"TextTest : TextTestOpen RparForKindTest",
"AnyKindTest : AnyKindTestOpening RparForKindTest",
"SchemaContextPath : SchemaGlobalContextSlash SchemaContextPathTail",
"SchemaContextLoc : OptionalSchemaContextLocContextPath QNameForItemType",
"SchemaContextLoc : SchemaGlobalTypeName",
"OccurrenceIndicator : OccurrenceZeroOrOne",
"OccurrenceIndicator : OccurrenceZeroOrMore",
"OccurrenceIndicator : OccurrenceOneOrMore",
"ValidationDecl : DeclareValidation SchemaModeForDeclareValidate",
"SchemaImport : ImportSchemaToken OptionalSchemaImportPrefixDecl URLLiteral OptionalLocationHint",
"SchemaPrefix : Namespace NCNameForPrefix AssignEquals",
"SchemaPrefix : DefaultElement Namespace",
"QueryListTail :",
"QueryListTail : QueryListTail QuerySeparator OptionalModule",
"OptionalModule :",
"OptionalModule : Module",
"OptionalVersionDecl :",
"OptionalVersionDecl : VersionDecl",
"MainOrLibraryModule : MainModule",
"MainOrLibraryModule : LibraryModule",
"SetterList :",
"SetterList : SetterList Setter Separator",
"DeclList :",
"DeclList : DeclList DeclChoice Separator",
"DeclChoice : Import",
"DeclChoice : NamespaceDecl",
"DeclChoice : VarDecl",
"DeclChoice : FunctionDecl",
"ImportPrefixDecl :",
"ImportPrefixDecl : Namespace NCNameForPrefix AssignEquals",
"LocationHint :",
"LocationHint : AtStringLiteral",
"VarDeclOptionalTypeDecl :",
"VarDeclOptionalTypeDecl : TypeDeclaration",
"VarDeclAssignmentOrExtern : LbraceExprEnclosure Expr Rbrace",
"VarDeclAssignmentOrExtern : External",
"CommaExpr :",
"CommaExpr : CommaExpr Comma ExprSingle",
"FLWORClauseList : FLWORClauseList ForClause",
"FLWORClauseList : FLWORClauseList LetClause",
"FLWORClauseList : ForClause",
"FLWORClauseList : LetClause",
"OptionalWhere :",
"OptionalWhere : WhereClause",
"OptionalOrderBy :",
"OptionalOrderBy : OrderByClause",
"ForTypeDeclarationOption :",
"ForTypeDeclarationOption : TypeDeclaration",
"PositionalVarOption :",
"PositionalVarOption : PositionalVar",
"ForClauseTail :",
"ForClauseTail : ForClauseTail Comma VariableIndicator VarName ForTailTypeDeclarationOption TailPositionalVarOption In ExprSingle",
"ForTailTypeDeclarationOption :",
"ForTailTypeDeclarationOption : TypeDeclaration",
"TailPositionalVarOption :",
"TailPositionalVarOption : PositionalVar",
"LetTypeDeclarationOption :",
"LetTypeDeclarationOption : TypeDeclaration",
"LetClauseTail :",
"LetClauseTail : LetClauseTail Comma VariableIndicator VarName LetTailTypeDeclarationOption ColonEquals ExprSingle",
"LetTailTypeDeclarationOption :",
"LetTailTypeDeclarationOption : TypeDeclaration",
"OrderByOrOrderByStable : OrderBy",
"OrderByOrOrderByStable : OrderByStable",
"OrderSpecListTail :",
"OrderSpecListTail : OrderSpecListTail Comma OrderSpec",
"SortDirectionOption :",
"SortDirectionOption : Ascending",
"SortDirectionOption : Descending",
"EmptyPosOption :",
"EmptyPosOption : EmptyGreatest",
"EmptyPosOption : EmptyLeast",
"CollationSpecOption :",
"CollationSpecOption : Collation StringLiteral",
"SomeOrEvery : Some",
"SomeOrEvery : Every",
"QuantifiedTypeDeclarationOption :",
"QuantifiedTypeDeclarationOption : TypeDeclaration",
"QuantifiedVarDeclListTail :",
"QuantifiedVarDeclListTail : QuantifiedVarDeclListTail Comma VariableIndicator VarName QuantifiedTailTypeDeclarationOption In ExprSingle",
"QuantifiedTailTypeDeclarationOption :",
"QuantifiedTailTypeDeclarationOption : TypeDeclaration",
"CaseClauseList : CaseClauseList CaseClause",
"CaseClauseList : CaseClause",
"DefaultClauseVarBindingOption :",
"DefaultClauseVarBindingOption : VariableIndicator VarName",
"CaseClauseVarBindingOption :",
"CaseClauseVarBindingOption : VariableIndicator VarName As",
"OptionalRootExprTail :",
"OptionalRootExprTail : RelativePathExpr",
"RelativePathExprTail :",
"RelativePathExprTail : RelativePathExprTail RelativePathExprStepSep StepExpr",
"RelativePathExprStepSep : Slash",
"RelativePathExprStepSep : SlashSlash",
"ForwardOrReverseStep : ForwardStep",
"ForwardOrReverseStep : ReverseStep",
"ValidateExprSpecifiers : ValidateLbrace",
"ValidateExprSpecifiers : ValidateGlobal LbraceExprEnclosure",
"ValidateExprSpecifiers : ValidateContext SchemaContextLoc LbraceExprEnclosure",
"ValidateExprSpecifiers : ValidateSchemaMode ValidateSchemaModeContextOption LbraceExprEnclosure",
"ValidateSchemaModeContextOption :",
"ValidateSchemaModeContextOption : ValidationContext",
"OptionalAtSugar :",
"OptionalAtSugar : At",
"OptionalExpr :",
"OptionalExpr : Expr",
"FunctionNameOpening : QNameLpar",
"ArgList :",
"ArgList : ExprSingle ArgListTail",
"ArgListTail :",
"ArgListTail : ArgListTail Comma ExprSingle",
"TagOpenStart : StartTagOpenRoot",
"TagOpenStart : StartTagOpen",
"TagClose : EmptyTagClose",
"TagClose : StartTagClose ElementContentBody EndTagOpen TagQName OptionalWhitespaceBeforeEndTagClose EndTagClose",
"ElementContentBody :",
"ElementContentBody : ElementContentBody ElementContent",
"OptionalWhitespaceBeforeEndTagClose :",
"OptionalWhitespaceBeforeEndTagClose : S",
"CompElemConstructorSpec : ElementQNameLbrace",
"CompElemConstructorSpec : ElementLbrace Expr Rbrace LbraceExprEnclosure",
"OptionalCompElemBody :",
"OptionalCompElemBody : CompElemBody",
"CompElemNamespaceOrExprSingle : CompElemNamespace",
"CompElemNamespaceOrExprSingle : ExprSingle",
"CompElemBodyTail :",
"CompElemBodyTail : CompElemBodyTail Comma TailCompElemNamespaceOrExprSingle",
"TailCompElemNamespaceOrExprSingle : CompElemNamespace",
"TailCompElemNamespaceOrExprSingle : ExprSingle",
"CompAttrConstructorOpening : AttributeQNameLbrace",
"CompAttrConstructorOpening : AttributeLbrace Expr Rbrace LbraceExprEnclosure",
"OptionalCompAttrValExpr :",
"OptionalCompAttrValExpr : Expr",
"CompXmlPIOpening : PINCNameLbrace",
"CompXmlPIOpening : PILbrace Expr Rbrace LbraceExprEnclosure",
"OptionalCompXmlPIExpr :",
"OptionalCompXmlPIExpr : Expr",
"OptionalCompTextExpr :",
"OptionalCompTextExpr : Expr",
"CdataSectionOpen : CdataSectionStartForElementContent",
"CdataSectionOpen : CdataSectionStart",
"CdataSectionBody :",
"CdataSectionBody : CdataSectionBody CDataSectionChar",
"ProcessingInstructionStartOpen : ProcessingInstructionStartForElementContent",
"ProcessingInstructionStartOpen : ProcessingInstructionStart",
"OptionalPIContent :",
"OptionalPIContent : SForPI XmlPIContentBody",
"XmlPIContentBody :",
"XmlPIContentBody : XmlPIContentBody PIContentChar",
"XmlCommentStartOpen : XmlCommentStartForElementContent",
"XmlCommentStartOpen : XmlCommentStart",
"XmlCommentContents :",
"XmlCommentContents : XmlCommentContents CommentContentChar",
"OptionalAttribute :",
"OptionalAttribute : TagQName OptionalWhitespaceBeforeValueIndicator ValueIndicator OptionalWhitespaceBeforeAttributeValue AttributeValue",
"OptionalWhitespaceBeforeValueIndicator :",
"OptionalWhitespaceBeforeValueIndicator : S",
"OptionalWhitespaceBeforeAttributeValue :",
"OptionalWhitespaceBeforeAttributeValue : S",
"QuotAttributeValueContents :",
"QuotAttributeValueContents : QuotAttributeValueContents QuotContentOrEscape",
"QuotContentOrEscape : EscapeQuot",
"QuotContentOrEscape : QuotAttrValueContent",
"AposAttributeValueContents :",
"AposAttributeValueContents : AposAttributeValueContents AposContentOrEscape",
"AposContentOrEscape : EscapeApos",
"AposContentOrEscape : AposAttrValueContent",
"EnclosedExprOpening : Lbrace",
"EnclosedExprOpening : LbraceExprEnclosure",
"XMLSpacePreserveOrStrip : XMLSpacePreserve",
"XMLSpacePreserveOrStrip : XMLSpaceStrip",
"DeclareDefaultElementOrFunction : DeclareDefaultElement",
"DeclareDefaultElementOrFunction : DeclareDefaultFunction",
"OptionalParamList :",
"OptionalParamList : ParamList",
"FunctionDeclSigClose : Rpar",
"FunctionDeclSigClose : RparAs SequenceType",
"FunctionDeclBody : EnclosedExpr",
"FunctionDeclBody : External",
"ParamListTail :",
"ParamListTail : ParamListTail Comma Param",
"OptionalTypeDeclarationForParam :",
"OptionalTypeDeclarationForParam : TypeDeclaration",
"OptionalOccurrenceIndicator :",
"OptionalOccurrenceIndicator : OccurrenceZeroOrOne",
"OptionalOccurrenceIndicatorForSequenceType :",
"OptionalOccurrenceIndicatorForSequenceType : OccurrenceIndicator",
"ElementTypeOpen : ElementType",
"ElementTypeOpen : ElementTypeForKindTest",
"ElementTypeOpen : ElementTypeForDocumentTest",
"OptionalElementTestBody :",
"OptionalElementTestBody : SchemaContextPath ElementName",
"OptionalElementTestBody : ElementNameOrWildcard ElementTestBodyOptionalParam",
"ElementTestBodyOptionalParam :",
"ElementTestBodyOptionalParam : CommaForKindTest TypeNameOrWildcard NillableOption",
"NillableOption :",
"NillableOption : Nillable",
"AttributeTestOpening : AttributeType",
"AttributeTestOpening : AttributeTypeForKindTest",
"OptionalAttributeTestBody :",
"OptionalAttributeTestBody : SchemaContextPath AttributeName",
"OptionalAttributeTestBody : AttribNameOrWildcard AttributeTestBodyOptionalParam",
"AttributeTestBodyOptionalParam :",
"AttributeTestBodyOptionalParam : CommaForKindTest TypeNameOrWildcard",
"PITestOpening : ProcessingInstructionLpar",
"PITestOpening : ProcessingInstructionLparForKindTest",
"OptionalPITestBody :",
"OptionalPITestBody : NCNameForPI",
"OptionalPITestBody : StringLiteralForKindTest",
"DocumentTestOpening : DocumentLpar",
"DocumentTestOpening : DocumentLparForKindTest",
"OptionalDocumentTestBody :",
"OptionalDocumentTestBody : ElementTest",
"CommentTestOpen : CommentLpar",
"CommentTestOpen : CommentLparForKindTest",
"TextTestOpen : TextLpar",
"TextTestOpen : TextLparForKindTest",
"AnyKindTestOpening : NodeLpar",
"AnyKindTestOpening : NodeLparForKindTest",
"SchemaContextPathTail :",
"SchemaContextPathTail : SchemaContextPathTail SchemaContextStepSlash",
"OptionalSchemaContextLocContextPath :",
"OptionalSchemaContextLocContextPath : SchemaContextPath",
"OptionalSchemaImportPrefixDecl :",
"OptionalSchemaImportPrefixDecl : SchemaPrefix",
"OptionalLocationHint :",
"OptionalLocationHint : AtStringLiteral",
};

//#line 3619 "xquery.y"

        /* ===== USER CODE BEGIN ====== */
SimpleNode ASTNodeCreate(int id)
{
	return new SimpleNode(this, id);
}

// this one is a (probably temporary) hack
SimpleNode ASTNodeCreate(Object node)
{
	return (SimpleNode)node;
}

void ASTNodeAddChild( SimpleNode parent, SimpleNode child )
{
	parent.jjtAddChild(child, parent.jjtGetNumChildren());
}

void ASTNodeAddChild( Object parent, Object child )
{
	ASTNodeAddChild( (SimpleNode) parent, (SimpleNode) child );
}

void ASTNodeSetValueToString( Object astn, String val )
{
  ((SimpleNode)astn).m_value = val;
}

void ASTNodeSetValueToNumber( Object astn, String val )
{
  ((SimpleNode)astn).m_value = val;
}

void ASTNodeSetValueToID( Object astn, int val )
{
	// TODO: Confirm ASTNodeSetValueToID is correct.
	((SimpleNode)astn).m_value = new Integer(val);
}

int ASTNodeGetID( Object astn )
{
  return ((SimpleNode)astn).id;
}


/* ===== USER CODE END ====== */
         
     

  /* a reference to the lexer object */
  private XQueryLexer lexer;

  /* interface to the lexer */
  private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
    }
    catch (java.io.IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }
  
    String _error = null;

	/* error reporting */
	public void yyerror(String error) {
	    _error = error;
		System.out.flush();
	    System.err.println("XQuery Syntax Error: " + error);
	    System.err.println(
	        "Current lexer position: line #"
	            + (lexer.getLinePos()+1)
	            + ", column #"
	            + lexer.getColumnPos());
	    System.err.print("yychar is "+yychar);
	    if(yychar >= 0 && yychar < yyname.length)
	    {	
	    	System.err.print(", ");
			System.err.print(yyname[yychar]);
	    }
		System.err.println();
		System.err.println("============");
		System.err.flush();	
		System.out.println();
		System.out.flush();
	}

  /* lexer is created in the constructor */
  public Parser(java.io.Reader r) {
    lexer = new XQueryLexer(r, this);
  }
  
  public int dumpTableSizes()
  {
  	final int sizeOfByte = 1;
	final int sizeOfChar = 2;
	final int sizeOfShort = 2;
	final int sizeOfInt = 4;
	final int sizeOfRef = 4;
	System.out.println("Parser table sizes");
	
  	System.out.println("  yylhs: "+(yylhs.length * sizeOfShort));
	System.out.println("  yylen: "+(yylen.length * sizeOfShort));
	System.out.println("  yydefred: "+(yydefred.length * sizeOfShort));
	System.out.println("  yydgoto: "+(yydgoto.length * sizeOfShort));
	System.out.println("  yysindex: "+(yysindex.length * sizeOfShort));
	System.out.println("  yyrindex: "+(yyrindex.length * sizeOfShort));
	System.out.println("  yygindex: "+(yygindex.length * sizeOfShort));
	System.out.println("  yytable: "+(yytable.length * sizeOfShort));
	System.out.println("  yycheck: "+(yycheck.length * sizeOfShort));
	System.out.println("  yyname: "+(yyname.length * sizeOfRef));
	System.out.println("  yyrule: "+(yyrule.length * sizeOfRef));
	System.out.print("        Total parser table sizes: ");
    int total = (
        ((yylhs.length
            + yylen.length
            + yydefred.length
            + yydgoto.length
            + yysindex.length
            + yyrindex.length
            + yygindex.length
            + yytable.length
            + yycheck.length)
            * sizeOfShort)
            + ((yyname.length + yyrule.length) * sizeOfRef));
            
	System.out.println(total);
	return total;
  }


/* Command line function for testing. */
public static void main(String args[]) throws java.io.IOException {
    int positionIndicator = -1;
    try {

        String filename = null;
        boolean dumpTree = false;
        boolean echo = false;
        String expression = null;
        boolean isQueryFile = false;
        java.util.Vector expressionStrings = new java.util.Vector();
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-sizes")) {
				Parser dummyParser = new Parser(new StringReader("foo"));
				int parseSizes = dummyParser.dumpTableSizes();
				int lexerSizes = dummyParser.lexer.dumpTableSizes();
				System.out.println("total static table sizes: "+(parseSizes+lexerSizes)+" bytes");
				System.out.println("                          "+((parseSizes+lexerSizes)/1024)+" k");
			}
            else if (args[i].equals("-dump")) {
                dumpTree = true;
            }
            else if (args[i].equals("-echo")) {
                echo = true;
            }
            else if (args[i].equals("-f")) {
                i++;
                filename = args[i];
            }
            else if (args[i].endsWith(".xquery")) {
                filename = args[i];
                isQueryFile = true;
            }
            else
            {
				expressionStrings.add(args[i]);
            }
        }
        Parser yyparser = null;
        
        for (java.util.Iterator iter = expressionStrings.iterator(); iter.hasNext();) {
            String path = (String) iter.next();
            positionIndicator++;
			yyparser = new Parser(new StringReader(path));
			// yyparser.yydebug=true;
			yyparser.yyparse();
			SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
			if (dumpTree)
				tree.dump("|");
        }

        if (null != filename) {
            if (filename.endsWith(".xquery") || filename.endsWith(".xq")) {
                System.out.println("Running test for: " + filename);
                File file = new File(filename);
                FileInputStream fis = new FileInputStream(file);
                yyparser = new Parser(new InputStreamReader(fis));
                // yyparser.yydebug=true;
                yyparser.yyparse();
                SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
                if (dumpTree)
                    tree.dump("|");
            }
            else {
                DocumentBuilderFactory dbf =
                    DocumentBuilderFactory.newInstance();
                DocumentBuilder db = dbf.newDocumentBuilder();
                Document doc = db.parse(filename);
                Element tests = doc.getDocumentElement();
                NodeList testElems = tests.getChildNodes();
                int nChildren = testElems.getLength();
                int testid = 0;
                for (int i = 0; i < nChildren; i++) {
                    positionIndicator = i;
                    org.w3c.dom.Node node = testElems.item(i);
                    if (org.w3c.dom.Node.ELEMENT_NODE == node.getNodeType()) {
                        testid++;
                        String xpathString =
                            ((Element) node).getAttribute("value");
                        if (dumpTree || echo)
                            System.out.println(
                                "Test[" + testid + "]: " + xpathString);
                        yyparser = new Parser(new StringReader(xpathString));
                        yyparser.yyparse();
                        SimpleNode tree = (SimpleNode) yyparser.yyval.obj;
                        if (dumpTree)
                            tree.dump("|");
                    }
                }
            }
        }
        if ((yyparser != null) && (null == yyparser._error))
            System.out.println("Test successful!!!");
    }
    catch (Exception e) {
        System.out.println(e.getMessage());
        e.printStackTrace();
        if(positionIndicator >= 0)
            System.out.println("positionIndicator: "+positionIndicator);
    }
}

        
//#line 2707 "Parser.java"
//###############################################################
// method: yylexdebug : check lexer state
//###############################################################
void yylexdebug(int state,int ch)
{
String s=null;
  if (ch < 0) ch=0;
  if (ch <= YYMAXTOKEN) //check index bounds
     s = yyname[ch];    //now get it
  if (s==null)
    s = "illegal-symbol";
  debug("state "+state+", reading "+ch+" ("+s+")");
}





//The following are now global, to aid in error reporting
int yyn;       //next next thing to do
int yym;       //
int yystate;   //current parsing state from state table
String yys;    //current token string


//###############################################################
// method: yyparse : parse input and execute indicated items
//###############################################################
int yyparse()
{
boolean doaction;
  init_stacks();
  yynerrs = 0;
  yyerrflag = 0;
  yychar = -1;          //impossible char forces a read
  yystate=0;            //initial state
  state_push(yystate);  //save it
  while (true) //until parsing is done, either correctly, or w/error
    {
    doaction=true;
    if (yydebug) debug("loop"); 
    //#### NEXT ACTION (from reduction table)
    for (yyn=yydefred[yystate];yyn==0;yyn=yydefred[yystate])
      {
      if (yydebug) debug("yyn:"+yyn+"  state:"+yystate+"  yychar:"+yychar);
      if (yychar < 0)      //we want a char?
        {
        yychar = yylex();  //get next token
        if (yydebug) debug(" next yychar:"+yychar);
        //#### ERROR CHECK ####
        if (yychar < 0)    //it it didn't work/error
          {
          yychar = 0;      //change it to default string (no -1!)
          if (yydebug)
            yylexdebug(yystate,yychar);
          }
        }//yychar<0
      yyn = yysindex[yystate];  //get amount to shift by (shift index)
      if ((yyn != 0) && (yyn += yychar) >= 0 &&
          yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
        {
        if (yydebug)
          debug("state "+yystate+", shifting to state "+yytable[yyn]);
        //#### NEXT STATE ####
        yystate = yytable[yyn];//we are in a new state
        state_push(yystate);   //save it
        val_push(yylval);      //push our lval as the input for next rule
        yychar = -1;           //since we have 'eaten' a token, say we need another
        if (yyerrflag > 0)     //have we recovered an error?
           --yyerrflag;        //give ourselves credit
        doaction=false;        //but don't process yet
        break;   //quit the yyn=0 loop
        }

    yyn = yyrindex[yystate];  //reduce
    if ((yyn !=0 ) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
      {   //we reduced!
      if (yydebug) debug("reduce");
      yyn = yytable[yyn];
      doaction=true; //get ready to execute
      break;         //drop down to actions
      }
    else //ERROR RECOVERY
      {
      if (yyerrflag==0)
        {
        yyerror("syntax error");
        yynerrs++;
        }
      if (yyerrflag < 3) //low error count?
        {
        yyerrflag = 3;
        while (true)   //do until break
          {
          if (stateptr<0)   //check for under & overflow here
            {
            yyerror("stack underflow. aborting...");  //note lower case 's'
            return 1;
            }
          yyn = yysindex[state_peek(0)];
          if ((yyn != 0) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
            if (yydebug)
              debug("state "+state_peek(0)+", error recovery shifting to state "+yytable[yyn]+" ");
            yystate = yytable[yyn];
            state_push(yystate);
            val_push(yylval);
            doaction=false;
            break;
            }
          else
            {
            if (yydebug)
              debug("error recovery discarding state "+state_peek(0)+" ");
            if (stateptr<0)   //check for under & overflow here
              {
              yyerror("Stack underflow. aborting...");  //capital 'S'
              return 1;
              }
            state_pop();
            val_pop();
            }
          }
        }
      else            //discard this token
        {
        if (yychar == 0)
          return 1; //yyabort
        if (yydebug)
          {
          yys = null;
          if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
          if (yys == null) yys = "illegal-symbol";
          debug("state "+yystate+", error recovery discards token "+yychar+" ("+yys+")");
          }
        yychar = -1;  //read another
        }
      }//end error recovery
    }//yyn=0 loop
    if (!doaction)   //any reason not to proceed?
      continue;      //skip action
    yym = yylen[yyn];          //get count of terminals on rhs
    if (yydebug)
      debug("state "+yystate+", reducing "+yym+" by rule "+yyn+" ("+yyrule[yyn]+")");
    if (yym>0)                 //if count of rhs not 'nil'
      yyval = val_peek(yym-1); //get current semantic value
    switch(yyn)
      {
//########## USER-SUPPLIED ACTIONS ##########
case 1:
//#line 706 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQueryList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 2:
//#line 715 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTModule);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 3:
//#line 724 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTMainModule);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 4:
//#line 733 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLibraryModule);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 5:
//#line 745 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTModuleDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 6:
//#line 753 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTProlog);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 7:
//#line 761 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSeparator); }
break;
case 8:
//#line 768 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVersionDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 9:
//#line 774 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 10:
//#line 779 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 11:
//#line 784 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 12:
//#line 789 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 13:
//#line 794 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 14:
//#line 800 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTImport);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 15:
//#line 805 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTImport);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 16:
//#line 815 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTModuleImport);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 17:
//#line 826 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarDecl);
                             { SimpleNode astn1 = ASTNodeCreate(DefineVariable);
                             ASTNodeSetValueToString(astn1, val_peek(3).sval);
                             ASTNodeAddChild( yyval.obj, astn1); }
                             { SimpleNode astn2 = ASTNodeCreate(VarName);
                             ASTNodeSetValueToString(astn2, val_peek(2).sval);
                             ASTNodeAddChild( yyval.obj, astn2); }
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 18:
//#line 839 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQueryBody);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 19:
//#line 847 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 20:
//#line 854 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 21:
//#line 859 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 22:
//#line 864 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 23:
//#line 869 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 24:
//#line 874 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 25:
//#line 885 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFLWORExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(4).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 26:
//#line 901 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForClause);
                             ASTNodeSetValueToString(yyval.obj, val_peek(5).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(4).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 27:
//#line 914 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPositionalVar);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 28:
//#line 926 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetClause);
                             ASTNodeSetValueToString(yyval.obj, val_peek(4).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 29:
//#line 937 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTWhereClause);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 30:
//#line 945 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderByClause);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 31:
//#line 954 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderSpecList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 32:
//#line 963 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderSpec);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 33:
//#line 973 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderModifier);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 34:
//#line 989 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(7).obj ); 
                             { SimpleNode astn2 = ASTNodeCreate(VarName);
                             ASTNodeSetValueToString(astn2, val_peek(6).sval);
                             ASTNodeAddChild( yyval.obj, astn2); }
                             ASTNodeAddChild( yyval.obj, val_peek(5).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             { SimpleNode astn7 = ASTNodeCreate(Satisfies);
                             ASTNodeSetValueToID(astn7, val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, astn7); }
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 35:
//#line 1013 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTypeswitchExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(6).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(4).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 36:
//#line 1027 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCaseClause);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 37:
//#line 1042 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTIfExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(5).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 38:
//#line 1052 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 40:
//#line 1062 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 42:
//#line 1072 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).obj);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 43:
//#line 1080 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).obj);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 44:
//#line 1088 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).obj);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 46:
//#line 1098 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 48:
//#line 1108 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 49:
//#line 1116 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 51:
//#line 1126 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 52:
//#line 1134 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 53:
//#line 1142 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 54:
//#line 1150 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 56:
//#line 1160 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTUnaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 57:
//#line 1167 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTUnaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 59:
//#line 1176 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 60:
//#line 1184 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 62:
//#line 1194 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 63:
//#line 1202 "xquery.y"
{ 
                             
        	    yyval = new ParserVal(0);
                yyval.obj = ASTNodeCreate(val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 73:
//#line 1230 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 74:
//#line 1235 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 75:
//#line 1242 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPathExpr);
                             ASTNodeSetValueToID(yyval.obj, val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 76:
//#line 1249 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPathExpr);
                             ASTNodeSetValueToID(yyval.obj, val_peek(1).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 77:
//#line 1255 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPathExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 78:
//#line 1263 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTRelativePathExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 79:
//#line 1270 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTStepExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 80:
//#line 1275 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTStepExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 81:
//#line 1283 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAxisStep);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 82:
//#line 1292 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFilterExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 83:
//#line 1300 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTContextItemExpr);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 84:
//#line 1306 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 85:
//#line 1311 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 86:
//#line 1316 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 87:
//#line 1321 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 88:
//#line 1326 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 89:
//#line 1331 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 90:
//#line 1339 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarRef);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 91:
//#line 1348 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPredicate);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 92:
//#line 1354 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPredicateList); }
break;
case 94:
//#line 1366 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 95:
//#line 1374 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidationContext);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 96:
//#line 1379 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidationContext); }
break;
case 97:
//#line 1384 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 98:
//#line 1389 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 99:
//#line 1394 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 100:
//#line 1399 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 101:
//#line 1404 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 102:
//#line 1410 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 103:
//#line 1415 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 104:
//#line 1420 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 105:
//#line 1425 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 106:
//#line 1430 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 107:
//#line 1435 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 108:
//#line 1441 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 109:
//#line 1445 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 110:
//#line 1449 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 111:
//#line 1453 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 112:
//#line 1457 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 113:
//#line 1461 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTGeneralComp); }
break;
case 114:
//#line 1466 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 115:
//#line 1470 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 116:
//#line 1474 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 117:
//#line 1478 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 118:
//#line 1482 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 119:
//#line 1486 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValueComp); }
break;
case 120:
//#line 1491 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNodeComp); }
break;
case 121:
//#line 1495 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNodeComp); }
break;
case 122:
//#line 1499 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNodeComp); }
break;
case 123:
//#line 1505 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardStep);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 124:
//#line 1511 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardStep);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 125:
//#line 1518 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseStep);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 126:
//#line 1524 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseStep);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 127:
//#line 1532 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAbbrevForwardStep);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 128:
//#line 1540 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAbbrevReverseStep);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 129:
//#line 1546 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 130:
//#line 1551 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 131:
//#line 1556 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 132:
//#line 1561 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 133:
//#line 1566 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 134:
//#line 1571 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 135:
//#line 1576 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 136:
//#line 1582 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 137:
//#line 1587 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 138:
//#line 1592 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 139:
//#line 1597 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 140:
//#line 1602 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 141:
//#line 1608 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNodeTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 142:
//#line 1613 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNodeTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 143:
//#line 1619 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNameTest);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 144:
//#line 1624 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNameTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 145:
//#line 1630 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 146:
//#line 1635 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 147:
//#line 1640 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 148:
//#line 1646 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLiteral);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 149:
//#line 1651 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLiteral);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 150:
//#line 1657 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber(yyval.obj, val_peek(0).sval); }
break;
case 151:
//#line 1662 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber(yyval.obj, val_peek(0).sval); }
break;
case 152:
//#line 1667 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber(yyval.obj, val_peek(0).sval); }
break;
case 153:
//#line 1676 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTParenthesizedExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 154:
//#line 1685 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionCall);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 155:
//#line 1696 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDirElemConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 156:
//#line 1707 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompDocConstructor);
                             ASTNodeSetValueToID(yyval.obj, val_peek(2).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 157:
//#line 1717 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 158:
//#line 1726 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemBody);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 159:
//#line 1736 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemNamespace);
                             { SimpleNode astn1 = ASTNodeCreate(NamespaceNCNameLbrace);
                             ASTNodeSetValueToID(astn1, val_peek(2).ival);
                             ASTNodeAddChild( yyval.obj, astn1); }
                             { SimpleNode astn2 = ASTNodeCreate(StringLiteral);
                             ASTNodeSetValueToString(astn2, val_peek(1).sval);
                             ASTNodeAddChild( yyval.obj, astn2); } }
break;
case 160:
//#line 1750 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompAttrConstructor);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 161:
//#line 1760 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompXmlPI);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 162:
//#line 1770 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompXmlComment);
                             ASTNodeSetValueToID(yyval.obj, val_peek(2).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 163:
//#line 1780 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompTextConstructor);
                             ASTNodeSetValueToID(yyval.obj, val_peek(2).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 164:
//#line 1790 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCdataSection);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 165:
//#line 1801 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlPI);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeSetValueToString(yyval.obj, val_peek(2).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 166:
//#line 1812 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlComment);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 167:
//#line 1819 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 168:
//#line 1824 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent); }
break;
case 169:
//#line 1828 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent); }
break;
case 170:
//#line 1832 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 171:
//#line 1837 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 172:
//#line 1842 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 173:
//#line 1847 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent); }
break;
case 174:
//#line 1851 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent); }
break;
case 175:
//#line 1855 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 176:
//#line 1860 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 177:
//#line 1866 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeList); }
break;
case 179:
//#line 1878 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeValue);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 180:
//#line 1885 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeValue);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 181:
//#line 1891 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 182:
//#line 1896 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent); }
break;
case 183:
//#line 1900 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent); }
break;
case 184:
//#line 1904 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent); }
break;
case 185:
//#line 1908 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 186:
//#line 1913 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttrValueContent); }
break;
case 187:
//#line 1918 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 188:
//#line 1923 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent); }
break;
case 189:
//#line 1927 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent); }
break;
case 190:
//#line 1931 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent); }
break;
case 191:
//#line 1935 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 192:
//#line 1940 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttrValueContent); }
break;
case 193:
//#line 1948 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEnclosedExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 194:
//#line 1957 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXMLSpaceDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 195:
//#line 1965 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDefaultCollationDecl); }
break;
case 196:
//#line 1972 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTBaseURIDecl); }
break;
case 197:
//#line 1981 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNamespaceDecl); }
break;
case 198:
//#line 1989 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDefaultNamespaceDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );  }
break;
case 199:
//#line 2000 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionDecl);
                             ASTNodeSetValueToString(yyval.obj, val_peek(3).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 200:
//#line 2011 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTParamList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 201:
//#line 2021 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTParam);
                             ASTNodeSetValueToString(yyval.obj, val_peek(1).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 202:
//#line 2030 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTypeDeclaration);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 203:
//#line 2038 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSingleType);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 204:
//#line 2046 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSequenceType);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 205:
//#line 2052 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSequenceType);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 206:
//#line 2058 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAtomicType); }
break;
case 207:
//#line 2062 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAtomicType); }
break;
case 208:
//#line 2067 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTItemType);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 209:
//#line 2072 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTItemType);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 210:
//#line 2077 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTItemType);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 211:
//#line 2083 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 212:
//#line 2088 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 213:
//#line 2093 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 214:
//#line 2098 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 215:
//#line 2103 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 216:
//#line 2108 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 217:
//#line 2113 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 218:
//#line 2122 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTest);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 219:
//#line 2132 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeTest);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 220:
//#line 2140 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementName); }
break;
case 221:
//#line 2146 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeName); }
break;
case 222:
//#line 2152 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTypeName); }
break;
case 223:
//#line 2157 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementNameOrWildcard);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 224:
//#line 2162 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementNameOrWildcard); }
break;
case 225:
//#line 2167 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttribNameOrWildcard);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 226:
//#line 2172 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttribNameOrWildcard); }
break;
case 227:
//#line 2177 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTypeNameOrWildcard);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 228:
//#line 2182 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTypeNameOrWildcard); }
break;
case 229:
//#line 2190 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPITest);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 230:
//#line 2200 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDocumentTest);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 231:
//#line 2209 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCommentTest);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 232:
//#line 2217 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTextTest);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 233:
//#line 2225 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAnyKindTest);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 234:
//#line 2233 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaContextPath);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 235:
//#line 2240 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaContextLoc);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 236:
//#line 2245 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaContextLoc); }
break;
case 237:
//#line 2250 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOccurrenceIndicator); }
break;
case 238:
//#line 2254 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOccurrenceIndicator); }
break;
case 239:
//#line 2258 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOccurrenceIndicator); }
break;
case 240:
//#line 2265 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidationDecl);
                             ASTNodeSetValueToString(yyval.obj, val_peek(1).sval); }
break;
case 241:
//#line 2275 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaImport);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 242:
//#line 2284 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaPrefix); }
break;
case 243:
//#line 2289 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaPrefix); }
break;
case 244:
//#line 2295 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQueryListTail); }
break;
case 245:
//#line 2303 "xquery.y"
{ 
                             if(NTQueryListTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQueryListTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 246:
//#line 2310 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalModule); }
break;
case 247:
//#line 2316 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalModule);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 248:
//#line 2322 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalVersionDecl); }
break;
case 249:
//#line 2328 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalVersionDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 250:
//#line 2334 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTMainOrLibraryModule);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 251:
//#line 2339 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTMainOrLibraryModule);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 252:
//#line 2345 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetterList); }
break;
case 253:
//#line 2353 "xquery.y"
{ 
                             if(NTSetterList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSetterList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 254:
//#line 2361 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclList); }
break;
case 255:
//#line 2369 "xquery.y"
{ 
                             if(NTDeclList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 256:
//#line 2377 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 257:
//#line 2382 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 258:
//#line 2387 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 259:
//#line 2392 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 260:
//#line 2398 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTImportPrefixDecl); }
break;
case 261:
//#line 2406 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTImportPrefixDecl); }
break;
case 262:
//#line 2411 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLocationHint); }
break;
case 263:
//#line 2417 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLocationHint); }
break;
case 264:
//#line 2422 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarDeclOptionalTypeDecl); }
break;
case 265:
//#line 2428 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarDeclOptionalTypeDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 266:
//#line 2436 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarDeclAssignmentOrExtern);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 267:
//#line 2441 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTVarDeclAssignmentOrExtern); }
break;
case 268:
//#line 2446 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCommaExpr); }
break;
case 269:
//#line 2454 "xquery.y"
{ 
                             if(NTCommaExpr != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCommaExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 270:
//#line 2462 "xquery.y"
{ 
                             if(NTFLWORClauseList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 271:
//#line 2469 "xquery.y"
{ 
                             if(NTFLWORClauseList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 272:
//#line 2476 "xquery.y"
{ 
                             if(NTFLWORClauseList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 273:
//#line 2482 "xquery.y"
{ 
                             if(NTFLWORClauseList != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 274:
//#line 2490 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhere); }
break;
case 275:
//#line 2496 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhere);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 276:
//#line 2502 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOrderBy); }
break;
case 277:
//#line 2508 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOrderBy);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 278:
//#line 2514 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForTypeDeclarationOption); }
break;
case 279:
//#line 2520 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 280:
//#line 2526 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPositionalVarOption); }
break;
case 281:
//#line 2532 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPositionalVarOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 282:
//#line 2538 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForClauseTail); }
break;
case 283:
//#line 2551 "xquery.y"
{ 
                             if(NTForClauseTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForClauseTail);
                             ASTNodeSetValueToString(yyval.obj, val_peek(4).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 284:
//#line 2561 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForTailTypeDeclarationOption); }
break;
case 285:
//#line 2567 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForTailTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 286:
//#line 2573 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTailPositionalVarOption); }
break;
case 287:
//#line 2579 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTailPositionalVarOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 288:
//#line 2585 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetTypeDeclarationOption); }
break;
case 289:
//#line 2591 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 290:
//#line 2597 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetClauseTail); }
break;
case 291:
//#line 2609 "xquery.y"
{ 
                             if(NTLetClauseTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetClauseTail);
                             ASTNodeSetValueToString(yyval.obj, val_peek(3).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 292:
//#line 2618 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetTailTypeDeclarationOption); }
break;
case 293:
//#line 2624 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTLetTailTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 294:
//#line 2630 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderByOrOrderByStable); }
break;
case 295:
//#line 2634 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderByOrOrderByStable); }
break;
case 296:
//#line 2639 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderSpecListTail); }
break;
case 297:
//#line 2647 "xquery.y"
{ 
                             if(NTOrderSpecListTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOrderSpecListTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 298:
//#line 2654 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSortDirectionOption); }
break;
case 299:
//#line 2659 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSortDirectionOption);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 300:
//#line 2664 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSortDirectionOption);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 301:
//#line 2671 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEmptyPosOption); }
break;
case 302:
//#line 2676 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEmptyPosOption);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 303:
//#line 2681 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEmptyPosOption);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 304:
//#line 2688 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCollationSpecOption); }
break;
case 305:
//#line 2695 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCollationSpecOption);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 306:
//#line 2701 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSomeOrEvery);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 307:
//#line 2706 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSomeOrEvery);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 308:
//#line 2712 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedTypeDeclarationOption); }
break;
case 309:
//#line 2718 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 310:
//#line 2724 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedVarDeclListTail); }
break;
case 311:
//#line 2736 "xquery.y"
{ 
                             if(NTQuantifiedVarDeclListTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedVarDeclListTail);
                             ASTNodeSetValueToString(yyval.obj, val_peek(3).sval);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 312:
//#line 2745 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedTailTypeDeclarationOption); }
break;
case 313:
//#line 2751 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuantifiedTailTypeDeclarationOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 316:
//#line 2763 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDefaultClauseVarBindingOption); }
break;
case 317:
//#line 2770 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDefaultClauseVarBindingOption);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 318:
//#line 2776 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCaseClauseVarBindingOption); }
break;
case 319:
//#line 2784 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCaseClauseVarBindingOption);
                             ASTNodeSetValueToString(yyval.obj, val_peek(1).sval); }
break;
case 320:
//#line 2790 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalRootExprTail); }
break;
case 321:
//#line 2796 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalRootExprTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 322:
//#line 2802 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTRelativePathExprTail); }
break;
case 323:
//#line 2810 "xquery.y"
{ 
                             if(NTRelativePathExprTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTRelativePathExprTail);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 324:
//#line 2818 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTRelativePathExprStepSep); }
break;
case 325:
//#line 2822 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTRelativePathExprStepSep); }
break;
case 326:
//#line 2827 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardOrReverseStep);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 327:
//#line 2832 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTForwardOrReverseStep);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 328:
//#line 2838 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateExprSpecifiers); }
break;
case 329:
//#line 2843 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateExprSpecifiers); }
break;
case 330:
//#line 2849 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateExprSpecifiers);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 331:
//#line 2856 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateExprSpecifiers);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 332:
//#line 2862 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateSchemaModeContextOption); }
break;
case 333:
//#line 2868 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTValidateSchemaModeContextOption);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 334:
//#line 2874 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAtSugar); }
break;
case 335:
//#line 2880 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAtSugar); }
break;
case 336:
//#line 2885 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalExpr); }
break;
case 337:
//#line 2891 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 338:
//#line 2897 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionNameOpening);
                             ASTNodeSetValueToString(yyval.obj, val_peek(0).sval); }
break;
case 339:
//#line 2903 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTArgList); }
break;
case 340:
//#line 2910 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTArgList);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 341:
//#line 2917 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTArgListTail); }
break;
case 342:
//#line 2925 "xquery.y"
{ 
                             if(NTArgListTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTArgListTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 343:
//#line 2932 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTagOpenStart); }
break;
case 344:
//#line 2936 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTagOpenStart); }
break;
case 345:
//#line 2941 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTagClose); }
break;
case 346:
//#line 2950 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTagClose);
                             ASTNodeAddChild( yyval.obj, val_peek(4).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj );  }
break;
case 347:
//#line 2957 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContentBody); }
break;
case 348:
//#line 2964 "xquery.y"
{ 
                             if(NTElementContentBody != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementContentBody);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 349:
//#line 2971 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeEndTagClose); }
break;
case 350:
//#line 2977 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeEndTagClose); }
break;
case 351:
//#line 2982 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemConstructorSpec);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 352:
//#line 2990 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemConstructorSpec);
                             ASTNodeSetValueToID(yyval.obj, val_peek(3).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );  }
break;
case 353:
//#line 2997 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompElemBody); }
break;
case 354:
//#line 3003 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompElemBody);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 355:
//#line 3009 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 356:
//#line 3014 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 357:
//#line 3020 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemBodyTail); }
break;
case 358:
//#line 3028 "xquery.y"
{ 
                             if(NTCompElemBodyTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompElemBodyTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 359:
//#line 3035 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTailCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 360:
//#line 3040 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTailCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 361:
//#line 3046 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompAttrConstructorOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 362:
//#line 3054 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompAttrConstructorOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(3).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );  }
break;
case 363:
//#line 3061 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompAttrValExpr); }
break;
case 364:
//#line 3067 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompAttrValExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 365:
//#line 3073 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompXmlPIOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 366:
//#line 3081 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCompXmlPIOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(3).ival);
                             ASTNodeAddChild( yyval.obj, val_peek(2).obj );  }
break;
case 367:
//#line 3088 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompXmlPIExpr); }
break;
case 368:
//#line 3094 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompXmlPIExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 369:
//#line 3100 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompTextExpr); }
break;
case 370:
//#line 3106 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalCompTextExpr);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 371:
//#line 3112 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCdataSectionOpen); }
break;
case 372:
//#line 3116 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCdataSectionOpen); }
break;
case 373:
//#line 3121 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCdataSectionBody); }
break;
case 374:
//#line 3128 "xquery.y"
{ 
                             if(NTCdataSectionBody != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCdataSectionBody); }
break;
case 375:
//#line 3134 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTProcessingInstructionStartOpen); }
break;
case 376:
//#line 3138 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTProcessingInstructionStartOpen); }
break;
case 377:
//#line 3143 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalPIContent); }
break;
case 378:
//#line 3150 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalPIContent);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 379:
//#line 3156 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlPIContentBody); }
break;
case 380:
//#line 3163 "xquery.y"
{ 
                             if(NTXmlPIContentBody != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlPIContentBody); }
break;
case 381:
//#line 3169 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlCommentStartOpen); }
break;
case 382:
//#line 3173 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlCommentStartOpen); }
break;
case 383:
//#line 3178 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlCommentContents); }
break;
case 384:
//#line 3185 "xquery.y"
{ 
                             if(NTXmlCommentContents != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXmlCommentContents); }
break;
case 385:
//#line 3191 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAttribute); }
break;
case 386:
//#line 3201 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAttribute);
                             ASTNodeAddChild( yyval.obj, val_peek(3).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 387:
//#line 3209 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeValueIndicator); }
break;
case 388:
//#line 3215 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeValueIndicator); }
break;
case 389:
//#line 3220 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeAttributeValue); }
break;
case 390:
//#line 3226 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalWhitespaceBeforeAttributeValue); }
break;
case 391:
//#line 3231 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttributeValueContents); }
break;
case 392:
//#line 3237 "xquery.y"
{ 
                             if(NTQuotAttributeValueContents != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotAttributeValueContents);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 393:
//#line 3244 "xquery.y"
{ 
                             if(NTQuotContentOrEscape != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotContentOrEscape); }
break;
case 394:
//#line 3249 "xquery.y"
{ 
                             if(NTQuotContentOrEscape != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTQuotContentOrEscape);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 395:
//#line 3256 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttributeValueContents); }
break;
case 396:
//#line 3262 "xquery.y"
{ 
                             if(NTAposAttributeValueContents != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposAttributeValueContents);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 397:
//#line 3269 "xquery.y"
{ 
                             if(NTAposContentOrEscape != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposContentOrEscape); }
break;
case 398:
//#line 3274 "xquery.y"
{ 
                             if(NTAposContentOrEscape != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAposContentOrEscape);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 399:
//#line 3281 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEnclosedExprOpening); }
break;
case 400:
//#line 3285 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTEnclosedExprOpening); }
break;
case 401:
//#line 3290 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXMLSpacePreserveOrStrip); }
break;
case 402:
//#line 3294 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTXMLSpacePreserveOrStrip); }
break;
case 403:
//#line 3299 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclareDefaultElementOrFunction); }
break;
case 404:
//#line 3303 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDeclareDefaultElementOrFunction); }
break;
case 405:
//#line 3308 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalParamList); }
break;
case 406:
//#line 3314 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalParamList);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 407:
//#line 3320 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionDeclSigClose); }
break;
case 408:
//#line 3325 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionDeclSigClose);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 409:
//#line 3331 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionDeclBody);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 410:
//#line 3336 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTFunctionDeclBody); }
break;
case 411:
//#line 3341 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTParamListTail); }
break;
case 412:
//#line 3349 "xquery.y"
{ 
                             if(NTParamListTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTParamListTail);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 413:
//#line 3356 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalTypeDeclarationForParam); }
break;
case 414:
//#line 3362 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalTypeDeclarationForParam);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 415:
//#line 3368 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOccurrenceIndicator); }
break;
case 416:
//#line 3374 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOccurrenceIndicator); }
break;
case 417:
//#line 3379 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOccurrenceIndicatorForSequenceType); }
break;
case 418:
//#line 3385 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalOccurrenceIndicatorForSequenceType);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 419:
//#line 3391 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTypeOpen);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 420:
//#line 3396 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTypeOpen); }
break;
case 421:
//#line 3400 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTypeOpen); }
break;
case 422:
//#line 3405 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalElementTestBody); }
break;
case 423:
//#line 3411 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalElementTestBody);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 424:
//#line 3418 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalElementTestBody);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 425:
//#line 3426 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTestBodyOptionalParam); }
break;
case 426:
//#line 3434 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTElementTestBodyOptionalParam);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 427:
//#line 3441 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNillableOption); }
break;
case 428:
//#line 3447 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTNillableOption);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 429:
//#line 3453 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeTestOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 430:
//#line 3458 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeTestOpening); }
break;
case 431:
//#line 3463 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAttributeTestBody); }
break;
case 432:
//#line 3469 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAttributeTestBody);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 433:
//#line 3476 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalAttributeTestBody);
                             ASTNodeAddChild( yyval.obj, val_peek(1).obj ); 
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 434:
//#line 3484 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeTestBodyOptionalParam); }
break;
case 435:
//#line 3491 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAttributeTestBodyOptionalParam);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 436:
//#line 3497 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPITestOpening); }
break;
case 437:
//#line 3501 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTPITestOpening); }
break;
case 438:
//#line 3506 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalPITestBody); }
break;
case 439:
//#line 3511 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalPITestBody); }
break;
case 440:
//#line 3515 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalPITestBody); }
break;
case 441:
//#line 3521 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDocumentTestOpening);
                             ASTNodeSetValueToID(yyval.obj, val_peek(0).ival); }
break;
case 442:
//#line 3526 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTDocumentTestOpening); }
break;
case 443:
//#line 3531 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalDocumentTestBody); }
break;
case 444:
//#line 3537 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalDocumentTestBody);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 445:
//#line 3543 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCommentTestOpen); }
break;
case 446:
//#line 3547 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTCommentTestOpen); }
break;
case 447:
//#line 3552 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTextTestOpen); }
break;
case 448:
//#line 3556 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTTextTestOpen); }
break;
case 449:
//#line 3561 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAnyKindTestOpening); }
break;
case 450:
//#line 3565 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTAnyKindTestOpening); }
break;
case 451:
//#line 3570 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaContextPathTail); }
break;
case 452:
//#line 3577 "xquery.y"
{ 
                             if(NTSchemaContextPathTail != ASTNodeGetID(yyval.obj))
                               
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTSchemaContextPathTail); }
break;
case 453:
//#line 3583 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalSchemaContextLocContextPath); }
break;
case 454:
//#line 3589 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalSchemaContextLocContextPath);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 455:
//#line 3595 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalSchemaImportPrefixDecl); }
break;
case 456:
//#line 3601 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalSchemaImportPrefixDecl);
                             ASTNodeAddChild( yyval.obj, val_peek(0).obj );  }
break;
case 457:
//#line 3607 "xquery.y"
{ 
                             
        
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalLocationHint); }
break;
case 458:
//#line 3613 "xquery.y"
{ 
                             
        yyval = new ParserVal(0);
        yyval.obj = ASTNodeCreate(NTOptionalLocationHint); }
break;
//#line 6404 "Parser.java"
//########## END OF USER-SUPPLIED ACTIONS ##########
    }//switch
    //#### Now let's reduce... ####
    if (yydebug) debug("reduce");
    state_drop(yym);             //we just reduced yylen states
    yystate = state_peek(0);     //get new state
    val_drop(yym);               //corresponding value drop
    yym = yylhs[yyn];            //select next TERMINAL(on lhs)
    if (yystate == 0 && yym == 0)//done? 'rest' state and at first TERMINAL
      {
      debug("After reduction, shifting from state 0 to state "+YYFINAL+"");
      yystate = YYFINAL;         //explicitly say we're done
      state_push(YYFINAL);       //and save it
      val_push(yyval);           //also save the semantic value of parsing
      if (yychar < 0)            //we want another character?
        {
        yychar = yylex();        //get next character
        if (yychar<0) yychar=0;  //clean, if necessary
        if (yydebug)
          yylexdebug(yystate,yychar);
        }
      if (yychar == 0)          //Good exit (if lex returns 0 ;-)
         break;                 //quit the loop--all DONE
      }//if yystate
    else                        //else not done yet
      {                         //get next state and push, for next yydefred[]
      yyn = yygindex[yym];      //find out where to go
      if ((yyn != 0) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn]; //get new state
      else
        yystate = yydgoto[yym]; //else go to new defred
      debug("after reduction, shifting from state "+state_peek(0)+" to state "+yystate+"");
      state_push(yystate);     //going again, so push state & val...
      val_push(yyval);         //for next action
      }
    }//main loop
  return 0;//yyaccept!!
}
//## end of method parse() ######################################



//## run() --- for Thread #######################################
/**
 * A default run method, used for operating this parser
 * object in the background.  It is intended for extending Thread
 * or implementing Runnable.  Turn off with -Jnorun .
 */
public void run()
{
  yyparse();
}
//## end of method run() ########################################



//## Constructors ###############################################
//## The -Jnoconstruct option was used ##
//###############################################################



}
//################### END OF CLASS ##############################
