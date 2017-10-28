%{

      
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
  
%}
%start QueryList
%token VT_STRING
%token VT_NUMBER
%token VT_ID

%token NTQueryList
%type <obj> QueryList
%token NTModule
%type <obj> Module
%token NTMainModule
%type <obj> MainModule
%token NTLibraryModule
%type <obj> LibraryModule
%token NTModuleDecl
%type <obj> ModuleDecl
%token NTProlog
%type <obj> Prolog
%token NTSeparator
%type <obj> Separator
%token NTVersionDecl
%type <obj> VersionDecl
%token NTSetter
%type <obj> Setter
%token NTImport
%type <obj> Import
%token NTModuleImport
%type <obj> ModuleImport
%token NTVarDecl
%type <obj> VarDecl
%token NTQueryBody
%type <obj> QueryBody
%token NTExpr
%type <obj> Expr
%token NTExprSingle
%type <obj> ExprSingle
%token NTFLWORExpr
%type <obj> FLWORExpr
%token NTForClause
%type <obj> ForClause
%token NTPositionalVar
%type <obj> PositionalVar
%token NTLetClause
%type <obj> LetClause
%token NTWhereClause
%type <obj> WhereClause
%token NTOrderByClause
%type <obj> OrderByClause
%token NTOrderSpecList
%type <obj> OrderSpecList
%token NTOrderSpec
%type <obj> OrderSpec
%token NTOrderModifier
%type <obj> OrderModifier
%token NTQuantifiedExpr
%type <obj> QuantifiedExpr
%token NTTypeswitchExpr
%type <obj> TypeswitchExpr
%token NTCaseClause
%type <obj> CaseClause
%token NTIfExpr
%type <obj> IfExpr
%token NTOrExpr
%type <obj> OrExpr
%token NTAndExpr
%type <obj> AndExpr
%token NTComparisonExpr
%type <obj> ComparisonExpr
%token NTRangeExpr
%type <obj> RangeExpr
%token NTAdditiveExpr
%type <obj> AdditiveExpr
%token NTMultiplicativeExpr
%type <obj> MultiplicativeExpr
%token NTUnaryExpr
%type <obj> UnaryExpr
%token NTUnionExpr
%type <obj> UnionExpr
%token NTIntersectExceptExpr
%type <obj> IntersectExceptExpr
%token NTInstanceofExpr
%type <obj> InstanceofExpr
%token NTTreatExpr
%type <obj> TreatExpr
%token NTCastableExpr
%type <obj> CastableExpr
%token NTCastExpr
%type <obj> CastExpr
%token NTValueExpr
%type <obj> ValueExpr
%token NTPathExpr
%type <obj> PathExpr
%token NTRelativePathExpr
%type <obj> RelativePathExpr
%token NTStepExpr
%type <obj> StepExpr
%token NTAxisStep
%type <obj> AxisStep
%token NTFilterExpr
%type <obj> FilterExpr
%token NTContextItemExpr
%type <obj> ContextItemExpr
%token NTPrimaryExpr
%type <obj> PrimaryExpr
%token NTVarRef
%type <obj> VarRef
%token NTPredicate
%type <obj> Predicate
%token NTPredicateList
%type <obj> PredicateList
%token NTValidateExpr
%type <obj> ValidateExpr
%token NTValidationContext
%type <obj> ValidationContext
%token NTConstructor
%type <obj> Constructor
%token NTComputedConstructor
%type <obj> ComputedConstructor
%token NTGeneralComp
%type <obj> GeneralComp
%token NTValueComp
%type <obj> ValueComp
%token NTNodeComp
%type <obj> NodeComp
%token NTForwardStep
%type <obj> ForwardStep
%token NTReverseStep
%type <obj> ReverseStep
%token NTAbbrevForwardStep
%type <obj> AbbrevForwardStep
%token NTAbbrevReverseStep
%type <obj> AbbrevReverseStep
%token NTForwardAxis
%type <obj> ForwardAxis
%token NTReverseAxis
%type <obj> ReverseAxis
%token NTNodeTest
%type <obj> NodeTest
%token NTNameTest
%type <obj> NameTest
%token NTWildcard
%type <obj> Wildcard
%token NTLiteral
%type <obj> Literal
%token NTNumericLiteral
%type <obj> NumericLiteral
%token NTParenthesizedExpr
%type <obj> ParenthesizedExpr
%token NTFunctionCall
%type <obj> FunctionCall
%token NTDirElemConstructor
%type <obj> DirElemConstructor
%token NTCompDocConstructor
%type <obj> CompDocConstructor
%token NTCompElemConstructor
%type <obj> CompElemConstructor
%token NTCompElemBody
%type <obj> CompElemBody
%token NTCompElemNamespace
%type <obj> CompElemNamespace
%token NTCompAttrConstructor
%type <obj> CompAttrConstructor
%token NTCompXmlPI
%type <obj> CompXmlPI
%token NTCompXmlComment
%type <obj> CompXmlComment
%token NTCompTextConstructor
%type <obj> CompTextConstructor
%token NTCdataSection
%type <obj> CdataSection
%token NTXmlPI
%type <obj> XmlPI
%token NTXmlComment
%type <obj> XmlComment
%token NTElementContent
%type <obj> ElementContent
%token NTAttributeList
%type <obj> AttributeList
%token NTAttributeValue
%type <obj> AttributeValue
%token NTQuotAttrValueContent
%type <obj> QuotAttrValueContent
%token NTAposAttrValueContent
%type <obj> AposAttrValueContent
%token NTEnclosedExpr
%type <obj> EnclosedExpr
%token NTXMLSpaceDecl
%type <obj> XMLSpaceDecl
%token NTDefaultCollationDecl
%type <obj> DefaultCollationDecl
%token NTBaseURIDecl
%type <obj> BaseURIDecl
%token NTNamespaceDecl
%type <obj> NamespaceDecl
%token NTDefaultNamespaceDecl
%type <obj> DefaultNamespaceDecl
%token NTFunctionDecl
%type <obj> FunctionDecl
%token NTParamList
%type <obj> ParamList
%token NTParam
%type <obj> Param
%token NTTypeDeclaration
%type <obj> TypeDeclaration
%token NTSingleType
%type <obj> SingleType
%token NTSequenceType
%type <obj> SequenceType
%token NTAtomicType
%type <obj> AtomicType
%token NTItemType
%type <obj> ItemType
%token NTKindTest
%type <obj> KindTest
%token NTElementTest
%type <obj> ElementTest
%token NTAttributeTest
%type <obj> AttributeTest
%token NTElementName
%type <obj> ElementName
%token NTAttributeName
%type <obj> AttributeName
%token NTTypeName
%type <obj> TypeName
%token NTElementNameOrWildcard
%type <obj> ElementNameOrWildcard
%token NTAttribNameOrWildcard
%type <obj> AttribNameOrWildcard
%token NTTypeNameOrWildcard
%type <obj> TypeNameOrWildcard
%token NTPITest
%type <obj> PITest
%token NTDocumentTest
%type <obj> DocumentTest
%token NTCommentTest
%type <obj> CommentTest
%token NTTextTest
%type <obj> TextTest
%token NTAnyKindTest
%type <obj> AnyKindTest
%token NTSchemaContextPath
%type <obj> SchemaContextPath
%token NTSchemaContextLoc
%type <obj> SchemaContextLoc
%token NTOccurrenceIndicator
%type <obj> OccurrenceIndicator
%token NTValidationDecl
%type <obj> ValidationDecl
%token NTSchemaImport
%type <obj> SchemaImport
%token NTSchemaPrefix
%type <obj> SchemaPrefix
%token NTQueryListTail
%type <obj> QueryListTail
%token NTOptionalModule
%type <obj> OptionalModule
%token NTOptionalVersionDecl
%type <obj> OptionalVersionDecl
%token NTMainOrLibraryModule
%type <obj> MainOrLibraryModule
%token NTSetterList
%type <obj> SetterList
%token NTDeclList
%type <obj> DeclList
%token NTDeclChoice
%type <obj> DeclChoice
%token NTImportPrefixDecl
%type <obj> ImportPrefixDecl
%token NTLocationHint
%type <obj> LocationHint
%token NTVarDeclOptionalTypeDecl
%type <obj> VarDeclOptionalTypeDecl
%token NTVarDeclAssignmentOrExtern
%type <obj> VarDeclAssignmentOrExtern
%token NTCommaExpr
%type <obj> CommaExpr
%token NTFLWORClauseList
%type <obj> FLWORClauseList
%token NTOptionalWhere
%type <obj> OptionalWhere
%token NTOptionalOrderBy
%type <obj> OptionalOrderBy
%token NTForTypeDeclarationOption
%type <obj> ForTypeDeclarationOption
%token NTPositionalVarOption
%type <obj> PositionalVarOption
%token NTForClauseTail
%type <obj> ForClauseTail
%token NTForTailTypeDeclarationOption
%type <obj> ForTailTypeDeclarationOption
%token NTTailPositionalVarOption
%type <obj> TailPositionalVarOption
%token NTLetTypeDeclarationOption
%type <obj> LetTypeDeclarationOption
%token NTLetClauseTail
%type <obj> LetClauseTail
%token NTLetTailTypeDeclarationOption
%type <obj> LetTailTypeDeclarationOption
%token NTOrderByOrOrderByStable
%type <obj> OrderByOrOrderByStable
%token NTOrderSpecListTail
%type <obj> OrderSpecListTail
%token NTSortDirectionOption
%type <obj> SortDirectionOption
%token NTEmptyPosOption
%type <obj> EmptyPosOption
%token NTCollationSpecOption
%type <obj> CollationSpecOption
%token NTSomeOrEvery
%type <obj> SomeOrEvery
%token NTQuantifiedTypeDeclarationOption
%type <obj> QuantifiedTypeDeclarationOption
%token NTQuantifiedVarDeclListTail
%type <obj> QuantifiedVarDeclListTail
%token NTQuantifiedTailTypeDeclarationOption
%type <obj> QuantifiedTailTypeDeclarationOption
%token NTCaseClauseList
%type <obj> CaseClauseList
%token NTDefaultClauseVarBindingOption
%type <obj> DefaultClauseVarBindingOption
%token NTCaseClauseVarBindingOption
%type <obj> CaseClauseVarBindingOption
%token NTOptionalRootExprTail
%type <obj> OptionalRootExprTail
%token NTRelativePathExprTail
%type <obj> RelativePathExprTail
%token NTRelativePathExprStepSep
%type <obj> RelativePathExprStepSep
%token NTForwardOrReverseStep
%type <obj> ForwardOrReverseStep
%token NTValidateExprSpecifiers
%type <obj> ValidateExprSpecifiers
%token NTValidateSchemaModeContextOption
%type <obj> ValidateSchemaModeContextOption
%token NTOptionalAtSugar
%type <obj> OptionalAtSugar
%token NTOptionalExpr
%type <obj> OptionalExpr
%token NTFunctionNameOpening
%type <obj> FunctionNameOpening
%token NTArgList
%type <obj> ArgList
%token NTArgListTail
%type <obj> ArgListTail
%token NTTagOpenStart
%type <obj> TagOpenStart
%token NTTagClose
%type <obj> TagClose
%token NTElementContentBody
%type <obj> ElementContentBody
%token NTOptionalWhitespaceBeforeEndTagClose
%type <obj> OptionalWhitespaceBeforeEndTagClose
%token NTCompElemConstructorSpec
%type <obj> CompElemConstructorSpec
%token NTOptionalCompElemBody
%type <obj> OptionalCompElemBody
%token NTCompElemNamespaceOrExprSingle
%type <obj> CompElemNamespaceOrExprSingle
%token NTCompElemBodyTail
%type <obj> CompElemBodyTail
%token NTTailCompElemNamespaceOrExprSingle
%type <obj> TailCompElemNamespaceOrExprSingle
%token NTCompAttrConstructorOpening
%type <obj> CompAttrConstructorOpening
%token NTOptionalCompAttrValExpr
%type <obj> OptionalCompAttrValExpr
%token NTCompXmlPIOpening
%type <obj> CompXmlPIOpening
%token NTOptionalCompXmlPIExpr
%type <obj> OptionalCompXmlPIExpr
%token NTOptionalCompTextExpr
%type <obj> OptionalCompTextExpr
%token NTCdataSectionOpen
%type <obj> CdataSectionOpen
%token NTCdataSectionBody
%type <obj> CdataSectionBody
%token NTProcessingInstructionStartOpen
%type <obj> ProcessingInstructionStartOpen
%token NTOptionalPIContent
%type <obj> OptionalPIContent
%token NTXmlPIContentBody
%type <obj> XmlPIContentBody
%token NTXmlCommentStartOpen
%type <obj> XmlCommentStartOpen
%token NTXmlCommentContents
%type <obj> XmlCommentContents
%token NTOptionalAttribute
%type <obj> OptionalAttribute
%token NTOptionalWhitespaceBeforeValueIndicator
%type <obj> OptionalWhitespaceBeforeValueIndicator
%token NTOptionalWhitespaceBeforeAttributeValue
%type <obj> OptionalWhitespaceBeforeAttributeValue
%token NTQuotAttributeValueContents
%type <obj> QuotAttributeValueContents
%token NTQuotContentOrEscape
%type <obj> QuotContentOrEscape
%token NTAposAttributeValueContents
%type <obj> AposAttributeValueContents
%token NTAposContentOrEscape
%type <obj> AposContentOrEscape
%token NTEnclosedExprOpening
%type <obj> EnclosedExprOpening
%token NTXMLSpacePreserveOrStrip
%type <obj> XMLSpacePreserveOrStrip
%token NTDeclareDefaultElementOrFunction
%type <obj> DeclareDefaultElementOrFunction
%token NTOptionalParamList
%type <obj> OptionalParamList
%token NTFunctionDeclSigClose
%type <obj> FunctionDeclSigClose
%token NTFunctionDeclBody
%type <obj> FunctionDeclBody
%token NTParamListTail
%type <obj> ParamListTail
%token NTOptionalTypeDeclarationForParam
%type <obj> OptionalTypeDeclarationForParam
%token NTOptionalOccurrenceIndicator
%type <obj> OptionalOccurrenceIndicator
%token NTOptionalOccurrenceIndicatorForSequenceType
%type <obj> OptionalOccurrenceIndicatorForSequenceType
%token NTElementTypeOpen
%type <obj> ElementTypeOpen
%token NTOptionalElementTestBody
%type <obj> OptionalElementTestBody
%token NTElementTestBodyOptionalParam
%type <obj> ElementTestBodyOptionalParam
%token NTNillableOption
%type <obj> NillableOption
%token NTAttributeTestOpening
%type <obj> AttributeTestOpening
%token NTOptionalAttributeTestBody
%type <obj> OptionalAttributeTestBody
%token NTAttributeTestBodyOptionalParam
%type <obj> AttributeTestBodyOptionalParam
%token NTPITestOpening
%type <obj> PITestOpening
%token NTOptionalPITestBody
%type <obj> OptionalPITestBody
%token NTDocumentTestOpening
%type <obj> DocumentTestOpening
%token NTOptionalDocumentTestBody
%type <obj> OptionalDocumentTestBody
%token NTCommentTestOpen
%type <obj> CommentTestOpen
%token NTTextTestOpen
%type <obj> TextTestOpen
%token NTAnyKindTestOpening
%type <obj> AnyKindTestOpening
%token NTSchemaContextPathTail
%type <obj> SchemaContextPathTail
%token NTOptionalSchemaContextLocContextPath
%type <obj> OptionalSchemaContextLocContextPath
%token NTOptionalSchemaImportPrefixDecl
%type <obj> OptionalSchemaImportPrefixDecl
%token NTOptionalLocationHint
%type <obj> OptionalLocationHint

%token <ival> Pragma
%token <ival> MUExtension
%token <ival> ExtensionStart
%token <ival> ExprComment
%token <ival> ExprCommentStart
%token <ival> ExprCommentContent
%token <ival> ExtensionContents
%token <ival> ExtensionEnd
%token <ival> ExprCommentEnd
%token <ival> PragmaKeyword
%token <ival> Extension
%token <ival> XmlCommentStart
%token <ival> XmlCommentStartForElementContent
%token <ival> XmlCommentEnd
%token <sval> IntegerLiteral
%token <sval> DecimalLiteral
%token <sval> DoubleLiteral
%token <sval> StringLiteral
%token <ival> StringLiteralForKindTest
%token <ival> VersionStringLiteral
%token <ival> AtStringLiteral
%token <ival> URLLiteral
%token <ival> ModuleNamespace
%token <ival> NotOccurrenceIndicator
%token <ival> S
%token <ival> SForPI
%token <ival> ProcessingInstructionStart
%token <ival> ProcessingInstructionStartForElementContent
%token <ival> ProcessingInstructionEnd
%token <sval> AxisChild
%token <sval> AxisDescendant
%token <sval> AxisParent
%token <sval> AxisAttribute
%token <sval> AxisSelf
%token <sval> AxisDescendantOrSelf
%token <sval> AxisAncestor
%token <sval> AxisFollowingSibling
%token <sval> AxisPrecedingSibling
%token <sval> AxisFollowing
%token <sval> AxisPreceding
%token <sval> AxisAncestorOrSelf
%token <ival> DefineFunction
%token <ival> External
%token <ival> Or
%token <ival> And
%token <ival> Div
%token <ival> Idiv
%token <ival> Mod
%token <ival> Multiply
%token <ival> In
%token <sval> ValidationMode
%token <ival> SchemaModeForDeclareValidate
%token <ival> Nillable
%token <sval> DeclareValidation
%token <ival> SchemaGlobalContextSlash
%token <ival> SchemaGlobalTypeName
%token <ival> SchemaGlobalContext
%token <ival> SchemaContextStepSlash
%token <ival> SchemaContextStep
%token <ival> InContextForKindTest
%token <ival> Global
%token <ival> Satisfies
%token <ival> Return
%token <ival> Then
%token <ival> Else
%token <ival> Default
%token <ival> DeclareXMLSpace
%token <ival> DeclareBaseURI
%token <ival> XMLSpacePreserve
%token <ival> XMLSpaceStrip
%token <ival> Namespace
%token <ival> DeclareNamespace
%token <ival> To
%token <ival> Where
%token <ival> Collation
%token <ival> Intersect
%token <ival> Union
%token <ival> Except
%token <ival> As
%token <ival> AtWord
%token <ival> Case
%token <ival> Instanceof
%token <ival> Castable
%token <ival> RparAs
%token <ival> Item
%token <ival> ElementType
%token <ival> AttributeType
%token <ival> ElementQNameLbrace
%token <ival> AttributeQNameLbrace
%token <ival> NamespaceNCNameLbrace
%token <ival> PINCNameLbrace
%token <ival> PILbrace
%token <ival> CommentLbrace
%token <ival> ElementLbrace
%token <ival> AttributeLbrace
%token <ival> TextLbrace
%token <ival> DeclareCollation
%token <ival> DefaultElement
%token <ival> DeclareDefaultElement
%token <ival> DeclareDefaultFunction
%token <ival> EmptyTok
%token <ival> ImportSchemaToken
%token <ival> ImportModuleToken
%token <ival> Nmstart
%token <ival> Nmchar
%token <sval> Star
%token <ival> AnyName
%token <sval> NCNameColonStar
%token <sval> StarColonNCName
%token <ival> Root
%token <ival> RootDescendants
%token <ival> Slash
%token <ival> SlashSlash
%token <ival> Equals
%token <ival> AssignEquals
%token <ival> Is
%token <ival> NotEquals
%token <ival> LtEquals
%token <ival> LtLt
%token <ival> GtEquals
%token <ival> GtGt
%token <ival> FortranEq
%token <ival> FortranNe
%token <ival> FortranGt
%token <ival> FortranGe
%token <ival> FortranLt
%token <ival> FortranLe
%token <ival> ColonEquals
%token <ival> Lt
%token <ival> Gt
%token <ival> Minus
%token <ival> Plus
%token <ival> UnaryMinus
%token <ival> UnaryPlus
%token <ival> OccurrenceZeroOrOne
%token <ival> OccurrenceZeroOrMore
%token <ival> OccurrenceOneOrMore
%token <ival> Vbar
%token <ival> Lpar
%token <ival> At
%token <ival> Lbrack
%token <ival> Rbrack
%token <ival> Rpar
%token <ival> RparForKindTest
%token <ival> Some
%token <ival> Every
%token <ival> ForVariable
%token <ival> LetVariable
%token <ival> CastAs
%token <ival> TreatAs
%token <ival> ValidateLbrace
%token <ival> ValidateContext
%token <ival> ValidateGlobal
%token <ival> ValidateSchemaMode
%token <ival> Digits
%token <ival> DocumentLpar
%token <ival> DocumentLparForKindTest
%token <ival> DocumentLbrace
%token <ival> NodeLpar
%token <ival> CommentLpar
%token <ival> TextLpar
%token <ival> ProcessingInstructionLpar
%token <ival> ElementTypeForKindTest
%token <ival> ElementTypeForDocumentTest
%token <ival> AttributeTypeForKindTest
%token <ival> ProcessingInstructionLparForKindTest
%token <ival> TextLparForKindTest
%token <ival> CommentLparForKindTest
%token <ival> NodeLparForKindTest
%token <ival> IfLpar
%token <ival> TypeswitchLpar
%token <ival> Comma
%token <ival> CommaForKindTest
%token <ival> SemiColon
%token <ival> QuerySeparator
%token <ival> EscapeQuot
%token <ival> OpenQuot
%token <ival> CloseQuot
%token <ival> Dot
%token <ival> DotDot
%token <ival> OrderBy
%token <ival> OrderByStable
%token <ival> Ascending
%token <ival> Descending
%token <ival> EmptyGreatest
%token <ival> EmptyLeast
%token <sval> PITarget
%token <sval> NCName
%token <sval> Prefix
%token <sval> LocalPart
%token <ival> VariableIndicator
%token <sval> VarName
%token <sval> DefineVariable
%token <ival> QNameForSequenceType
%token <ival> QNameForAtomicType
%token <ival> QNameForItemType
%token <ival> ExtensionQName
%token <sval> QName
%token <sval> QNameLpar
%token <ival> NCNameForPrefix
%token <ival> NCNameForPI
%token <ival> CdataSectionStart
%token <ival> CdataSectionStartForElementContent
%token <ival> CdataSectionEnd
%token <ival> PredefinedEntityRef
%token <ival> HexDigits
%token <ival> CharRef
%token <ival> StartTagOpen
%token <ival> StartTagOpenRoot
%token <ival> StartTagClose
%token <ival> EmptyTagClose
%token <ival> EndTagOpen
%token <ival> EndTagClose
%token <ival> ValueIndicator
%token <ival> TagQName
%token <ival> Lbrace
%token <ival> LbraceExprEnclosure
%token <ival> LCurlyBraceEscape
%token <ival> RCurlyBraceEscape
%token <ival> EscapeApos
%token <ival> OpenApos
%token <ival> CloseApos
%token <sval> ElementContentChar
%token <sval> QuotAttContentChar
%token <sval> AposAttContentChar
%token <ival> CommentContentChar
%token <ival> PIContentChar
%token <ival> CDataSectionChar
%token <ival> Rbrace
%token <ival> WhitespaceChar
%%
QueryList: Module
                    QueryListTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQueryList);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

Module: OptionalVersionDecl
                    MainOrLibraryModule
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTModule);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

MainModule: Prolog
                    QueryBody
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTMainModule);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

LibraryModule: ModuleDecl
                    Prolog
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLibraryModule);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ModuleDecl: ModuleNamespace
                    NCNameForPrefix
                    AssignEquals
                    URLLiteral
                    Separator
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTModuleDecl);
                             ASTNodeAddChild( $$, $5 );  } ;

Prolog: SetterList
                    DeclList
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTProlog);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

Separator: SemiColon
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSeparator); } ;

VersionDecl: VersionStringLiteral
                    Separator
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVersionDecl);
                             ASTNodeAddChild( $$, $2 );  } ;

Setter: XMLSpaceDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( $$, $1 );  } 
 | DefaultCollationDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( $$, $1 );  } 
 | BaseURIDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( $$, $1 );  } 
 | ValidationDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( $$, $1 );  } 
 | DefaultNamespaceDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetter);
                             ASTNodeAddChild( $$, $1 );  } ;

Import: SchemaImport { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTImport);
                             ASTNodeAddChild( $$, $1 );  } 
 | ModuleImport { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTImport);
                             ASTNodeAddChild( $$, $1 );  } ;

ModuleImport: ImportModuleToken
                    ImportPrefixDecl
                    URLLiteral
                    LocationHint
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTModuleImport);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $4 );  } ;

VarDecl: DefineVariable
                    VarName
                    VarDeclOptionalTypeDecl
                    VarDeclAssignmentOrExtern
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarDecl);
                             { SimpleNode astn1 = ASTNodeCreate(DefineVariable);
                             ASTNodeSetValueToString(astn1, $1);
                             ASTNodeAddChild( $$, astn1); }
                             { SimpleNode astn2 = ASTNodeCreate(VarName);
                             ASTNodeSetValueToString(astn2, $2);
                             ASTNodeAddChild( $$, astn2); }
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $4 );  } ;

QueryBody: Expr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQueryBody);
                             ASTNodeAddChild( $$, $1 );  } ;

Expr: ExprSingle
                    CommaExpr
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ExprSingle: FLWORExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | QuantifiedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | TypeswitchExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | IfExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | OrExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTExprSingle);
                             ASTNodeAddChild( $$, $1 );  } ;

FLWORExpr: FLWORClauseList
                    OptionalWhere
                    OptionalOrderBy
                    Return
                    ExprSingle
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFLWORExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $5 );  } ;

ForClause: ForVariable
                    VarName
                    ForTypeDeclarationOption
                    PositionalVarOption
                    In
                    ExprSingle
                    ForClauseTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForClause);
                             ASTNodeSetValueToString($$, $2);
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $4 ); 
                             ASTNodeAddChild( $$, $6 ); 
                             ASTNodeAddChild( $$, $7 );  } ;

PositionalVar: AtWord
                    VariableIndicator
                    VarName
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPositionalVar);
                             ASTNodeSetValueToString($$, $3); } ;

LetClause: LetVariable
                    VarName
                    LetTypeDeclarationOption
                    ColonEquals
                    ExprSingle
                    LetClauseTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetClause);
                             ASTNodeSetValueToString($$, $2);
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $6 );  } ;

WhereClause: Where
                    Expr
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTWhereClause);
                             ASTNodeAddChild( $$, $2 );  } ;

OrderByClause: OrderByOrOrderByStable
                    OrderSpecList
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderByClause);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

OrderSpecList: OrderSpec
                    OrderSpecListTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderSpecList);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

OrderSpec: ExprSingle
                    OrderModifier
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderSpec);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

OrderModifier: SortDirectionOption
                    EmptyPosOption
                    CollationSpecOption
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderModifier);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 );  } ;

QuantifiedExpr: SomeOrEvery
                    VarName
                    QuantifiedTypeDeclarationOption
                    In
                    ExprSingle
                    QuantifiedVarDeclListTail
                    Satisfies
                    ExprSingle
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             { SimpleNode astn2 = ASTNodeCreate(VarName);
                             ASTNodeSetValueToString(astn2, $2);
                             ASTNodeAddChild( $$, astn2); }
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $6 ); 
                             { SimpleNode astn7 = ASTNodeCreate(Satisfies);
                             ASTNodeSetValueToID(astn7, $7);
                             ASTNodeAddChild( $$, astn7); }
                             ASTNodeAddChild( $$, $8 );  } ;

TypeswitchExpr: TypeswitchLpar
                    Expr
                    Rpar
                    CaseClauseList
                    Default
                    DefaultClauseVarBindingOption
                    Return
                    ExprSingle
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTypeswitchExpr);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $4 ); 
                             ASTNodeAddChild( $$, $6 ); 
                             ASTNodeAddChild( $$, $8 );  } ;

CaseClause: Case
                    CaseClauseVarBindingOption
                    SequenceType
                    Return
                    ExprSingle
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCaseClause);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $5 );  } ;

IfExpr: IfLpar
                    Expr
                    Rpar
                    Then
                    ExprSingle
                    Else
                    ExprSingle
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTIfExpr);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $7 );  } ;

OrExpr: OrExpr
                        Or
                        AndExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | AndExpr;

AndExpr: AndExpr
                        And
                        ComparisonExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | ComparisonExpr;

ComparisonExpr: ComparisonExpr
                            ValueComp
                            RangeExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | ComparisonExpr
                            GeneralComp
                            RangeExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | ComparisonExpr
                            NodeComp
                            RangeExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | RangeExpr;

RangeExpr: RangeExpr
                        To
                        AdditiveExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | AdditiveExpr;

AdditiveExpr: AdditiveExpr
                            Plus
                            MultiplicativeExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | AdditiveExpr
                            Minus
                            MultiplicativeExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | MultiplicativeExpr;

MultiplicativeExpr: MultiplicativeExpr
                            Multiply
                            UnaryExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | MultiplicativeExpr
                            Div
                            UnaryExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | MultiplicativeExpr
                            Idiv
                            UnaryExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | MultiplicativeExpr
                            Mod
                            UnaryExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | UnaryExpr;

UnaryExpr: UnaryMinus
                UnaryExpr
                 { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTUnaryExpr);
                             ASTNodeAddChild( $$, $2 );  } 
 | UnaryPlus
                UnaryExpr
                 { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTUnaryExpr);
                             ASTNodeAddChild( $$, $2 );  } 
 | UnionExpr;

UnionExpr: UnionExpr
                            Union
                            IntersectExceptExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | UnionExpr
                            Vbar
                            IntersectExceptExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | IntersectExceptExpr;

IntersectExceptExpr: IntersectExceptExpr
                            Intersect
                            InstanceofExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | IntersectExceptExpr
                            Except
                            InstanceofExpr { 
                             
        	    yyval = new ParserVal(0);
                $$ = ASTNodeCreate($2);
                             ASTNodeAddChild( $$, $1 );
                             ASTNodeAddChild( $$, $3 );  } 
 | InstanceofExpr;

InstanceofExpr: InstanceofExpr
        Instanceof
                                SequenceType
 | TreatExpr;

TreatExpr: TreatExpr
        TreatAs
                                SequenceType
 | CastableExpr;

CastableExpr: CastableExpr
        Castable
                                SingleType
 | CastExpr;

CastExpr: CastExpr
        CastAs
                                SingleType
 | ValueExpr;

ValueExpr: ValidateExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | PathExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

PathExpr: Root
                                OptionalRootExprTail { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPathExpr);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } 
 | RootDescendants
                                RelativePathExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPathExpr);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } 
 | RelativePathExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPathExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

RelativePathExpr: StepExpr
                    RelativePathExprTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTRelativePathExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

StepExpr: AxisStep { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTStepExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | FilterExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTStepExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

AxisStep: ForwardOrReverseStep
                    PredicateList
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAxisStep);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

FilterExpr: PrimaryExpr
                    PredicateList
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFilterExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ContextItemExpr: Dot
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTContextItemExpr);
                             ASTNodeSetValueToID($$, $1); } ;

PrimaryExpr: Literal { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | VarRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | ParenthesizedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | ContextItemExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | FunctionCall { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } 
 | Constructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPrimaryExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

VarRef: VariableIndicator
                    VarName
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarRef);
                             ASTNodeSetValueToString($$, $2); } ;

Predicate: Lbrack
                    Expr
                    Rbrack
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPredicate);
                             ASTNodeAddChild( $$, $2 );  } ;

PredicateList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPredicateList); } 
 | PredicateList
                Predicate
            ;

ValidateExpr: ValidateExprSpecifiers
                    Expr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ValidationContext: InContextForKindTest
                                SchemaContextLoc { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidationContext);
                             ASTNodeAddChild( $$, $2 );  } 
 | Global { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidationContext); } ;

Constructor: DirElemConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | ComputedConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | XmlComment { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | XmlPI { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CdataSection { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTConstructor);
                             ASTNodeAddChild( $$, $1 );  } ;

ComputedConstructor: CompElemConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CompAttrConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CompDocConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CompTextConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CompXmlPI { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } 
 | CompXmlComment { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTComputedConstructor);
                             ASTNodeAddChild( $$, $1 );  } ;

GeneralComp: Equals { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } 
 | NotEquals { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } 
 | Lt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } 
 | LtEquals { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } 
 | Gt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } 
 | GtEquals { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTGeneralComp); } ;

ValueComp: FortranEq { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } 
 | FortranNe { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } 
 | FortranLt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } 
 | FortranLe { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } 
 | FortranGt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } 
 | FortranGe { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValueComp); } ;

NodeComp: Is { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNodeComp); } 
 | LtLt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNodeComp); } 
 | GtGt { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNodeComp); } ;

ForwardStep: ForwardAxis
                                NodeTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardStep);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
 | AbbrevForwardStep { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardStep);
                             ASTNodeAddChild( $$, $1 );  } ;

ReverseStep: ReverseAxis
                                NodeTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseStep);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
 | AbbrevReverseStep { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseStep);
                             ASTNodeAddChild( $$, $1 );  } ;

AbbrevForwardStep: OptionalAtSugar
                    NodeTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAbbrevForwardStep);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

AbbrevReverseStep: DotDot
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAbbrevReverseStep);
                             ASTNodeSetValueToID($$, $1); } ;

ForwardAxis: AxisChild { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisDescendant { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisAttribute { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisSelf { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisDescendantOrSelf { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisFollowingSibling { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisFollowing { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardAxis);
                             ASTNodeSetValueToString($$, $1); } ;

ReverseAxis: AxisParent { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisAncestor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisPrecedingSibling { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisPreceding { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString($$, $1); } 
 | AxisAncestorOrSelf { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTReverseAxis);
                             ASTNodeSetValueToString($$, $1); } ;

NodeTest: KindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNodeTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | NameTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNodeTest);
                             ASTNodeAddChild( $$, $1 );  } ;

NameTest: QName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNameTest);
                             ASTNodeSetValueToString($$, $1); } 
 | Wildcard { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNameTest);
                             ASTNodeAddChild( $$, $1 );  } ;

Wildcard: Star { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString($$, $1); } 
 | NCNameColonStar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString($$, $1); } 
 | StarColonNCName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTWildcard);
                             ASTNodeSetValueToString($$, $1); } ;

Literal: NumericLiteral { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLiteral);
                             ASTNodeAddChild( $$, $1 );  } 
 | StringLiteral { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLiteral);
                             ASTNodeSetValueToString($$, $1); } ;

NumericLiteral: IntegerLiteral { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber($$, $1); } 
 | DecimalLiteral { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber($$, $1); } 
 | DoubleLiteral { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNumericLiteral);
                             ASTNodeSetValueToNumber($$, $1); } ;

ParenthesizedExpr: Lpar
                    OptionalExpr
                    Rpar
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTParenthesizedExpr);
                             ASTNodeAddChild( $$, $2 );  } ;

FunctionCall: FunctionNameOpening
                    ArgList
                    Rpar
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionCall);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

DirElemConstructor: TagOpenStart
                    TagQName
                    AttributeList
                    TagClose
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDirElemConstructor);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $4 );  } ;

CompDocConstructor: DocumentLbrace
                    Expr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompDocConstructor);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

CompElemConstructor: CompElemConstructorSpec
                    OptionalCompElemBody
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemConstructor);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

CompElemBody: CompElemNamespaceOrExprSingle
                    CompElemBodyTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemBody);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

CompElemNamespace: NamespaceNCNameLbrace
                    StringLiteral
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemNamespace);
                             { SimpleNode astn1 = ASTNodeCreate(NamespaceNCNameLbrace);
                             ASTNodeSetValueToID(astn1, $1);
                             ASTNodeAddChild( $$, astn1); }
                             { SimpleNode astn2 = ASTNodeCreate(StringLiteral);
                             ASTNodeSetValueToString(astn2, $2);
                             ASTNodeAddChild( $$, astn2); } } ;

CompAttrConstructor: CompAttrConstructorOpening
                    OptionalCompAttrValExpr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompAttrConstructor);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

CompXmlPI: CompXmlPIOpening
                    OptionalCompXmlPIExpr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompXmlPI);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

CompXmlComment: CommentLbrace
                    Expr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompXmlComment);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

CompTextConstructor: TextLbrace
                    OptionalCompTextExpr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompTextConstructor);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

CdataSection: CdataSectionOpen
                    CdataSectionBody
                    CdataSectionEnd
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCdataSection);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

XmlPI: ProcessingInstructionStartOpen
                    PITarget
                    OptionalPIContent
                    ProcessingInstructionEnd
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlPI);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeSetValueToString($$, $2);
                             ASTNodeAddChild( $$, $3 );  } ;

XmlComment: XmlCommentStartOpen
                    XmlCommentContents
                    XmlCommentEnd
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlComment);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ElementContent: ElementContentChar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeSetValueToString($$, $1); } 
 | LCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent); } 
 | RCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent); } 
 | DirElemConstructor { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | EnclosedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | CdataSection { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | CharRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent); } 
 | PredefinedEntityRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent); } 
 | XmlComment { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | XmlPI { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContent);
                             ASTNodeAddChild( $$, $1 );  } ;

AttributeList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeList); } 
 | AttributeList
                S
            OptionalAttribute
            ;

AttributeValue: OpenQuot
                                QuotAttributeValueContents
                                CloseQuot { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeValue);
                             ASTNodeAddChild( $$, $2 );  } 
 | OpenApos
                                AposAttributeValueContents
                                CloseApos { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeValue);
                             ASTNodeAddChild( $$, $2 );  } ;

QuotAttrValueContent: QuotAttContentChar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent);
                             ASTNodeSetValueToString($$, $1); } 
 | CharRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent); } 
 | LCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent); } 
 | RCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent); } 
 | EnclosedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | PredefinedEntityRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttrValueContent); } ;

AposAttrValueContent: AposAttContentChar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent);
                             ASTNodeSetValueToString($$, $1); } 
 | CharRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent); } 
 | LCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent); } 
 | RCurlyBraceEscape { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent); } 
 | EnclosedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent);
                             ASTNodeAddChild( $$, $1 );  } 
 | PredefinedEntityRef { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttrValueContent); } ;

EnclosedExpr: EnclosedExprOpening
                    Expr
                    Rbrace
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEnclosedExpr);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

XMLSpaceDecl: DeclareXMLSpace
                    XMLSpacePreserveOrStrip
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXMLSpaceDecl);
                             ASTNodeAddChild( $$, $2 );  } ;

DefaultCollationDecl: DeclareCollation
                    URLLiteral
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDefaultCollationDecl); } ;

BaseURIDecl: DeclareBaseURI
                    URLLiteral
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTBaseURIDecl); } ;

NamespaceDecl: DeclareNamespace
                    NCNameForPrefix
                    AssignEquals
                    URLLiteral
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNamespaceDecl); } ;

DefaultNamespaceDecl: DeclareDefaultElementOrFunction
                    Namespace
                    URLLiteral
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDefaultNamespaceDecl);
                             ASTNodeAddChild( $$, $1 );  } ;

FunctionDecl: DefineFunction
                    QNameLpar
                    OptionalParamList
                    FunctionDeclSigClose
                    FunctionDeclBody
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionDecl);
                             ASTNodeSetValueToString($$, $2);
                             ASTNodeAddChild( $$, $3 ); 
                             ASTNodeAddChild( $$, $4 ); 
                             ASTNodeAddChild( $$, $5 );  } ;

ParamList: Param
                    ParamListTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTParamList);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

Param: VariableIndicator
                    VarName
                    OptionalTypeDeclarationForParam
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTParam);
                             ASTNodeSetValueToString($$, $2);
                             ASTNodeAddChild( $$, $3 );  } ;

TypeDeclaration: As
                    SequenceType
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTypeDeclaration);
                             ASTNodeAddChild( $$, $2 );  } ;

SingleType: AtomicType
                    OptionalOccurrenceIndicator
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSingleType);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

SequenceType: ItemType
                                OptionalOccurrenceIndicatorForSequenceType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSequenceType);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
 | EmptyTok { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSequenceType);
                             ASTNodeSetValueToID($$, $1); } ;

AtomicType: QNameForAtomicType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAtomicType); } 
 | QNameForSequenceType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAtomicType); } ;

ItemType: AtomicType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTItemType);
                             ASTNodeAddChild( $$, $1 );  } 
 | KindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTItemType);
                             ASTNodeAddChild( $$, $1 );  } 
 | Item { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTItemType);
                             ASTNodeSetValueToID($$, $1); } ;

KindTest: DocumentTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | ElementTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | AttributeTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | PITest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | CommentTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | TextTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } 
 | AnyKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTKindTest);
                             ASTNodeAddChild( $$, $1 );  } ;

ElementTest: ElementTypeOpen
                    OptionalElementTestBody
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTest);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

AttributeTest: AttributeTestOpening
                    OptionalAttributeTestBody
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeTest);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ElementName: QNameForItemType
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementName); } ;

AttributeName: QNameForItemType
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeName); } ;

TypeName: QNameForItemType
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTypeName); } ;

ElementNameOrWildcard: ElementName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementNameOrWildcard);
                             ASTNodeAddChild( $$, $1 );  } 
 | AnyName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementNameOrWildcard); } ;

AttribNameOrWildcard: AttributeName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttribNameOrWildcard);
                             ASTNodeAddChild( $$, $1 );  } 
 | AnyName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttribNameOrWildcard); } ;

TypeNameOrWildcard: TypeName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTypeNameOrWildcard);
                             ASTNodeAddChild( $$, $1 );  } 
 | AnyName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTypeNameOrWildcard); } ;

PITest: PITestOpening
                    OptionalPITestBody
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPITest);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

DocumentTest: DocumentTestOpening
                    OptionalDocumentTestBody
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDocumentTest);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

CommentTest: CommentTestOpen
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCommentTest);
                             ASTNodeAddChild( $$, $1 );  } ;

TextTest: TextTestOpen
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTextTest);
                             ASTNodeAddChild( $$, $1 );  } ;

AnyKindTest: AnyKindTestOpening
                    RparForKindTest
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAnyKindTest);
                             ASTNodeAddChild( $$, $1 );  } ;

SchemaContextPath: SchemaGlobalContextSlash
                    SchemaContextPathTail
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaContextPath);
                             ASTNodeAddChild( $$, $2 );  } ;

SchemaContextLoc: OptionalSchemaContextLocContextPath
                                QNameForItemType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaContextLoc);
                             ASTNodeAddChild( $$, $1 );  } 
 | SchemaGlobalTypeName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaContextLoc); } ;

OccurrenceIndicator: OccurrenceZeroOrOne { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOccurrenceIndicator); } 
 | OccurrenceZeroOrMore { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOccurrenceIndicator); } 
 | OccurrenceOneOrMore { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOccurrenceIndicator); } ;

ValidationDecl: DeclareValidation
                    SchemaModeForDeclareValidate
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidationDecl);
                             ASTNodeSetValueToString($$, $1); } ;

SchemaImport: ImportSchemaToken
                    OptionalSchemaImportPrefixDecl
                    URLLiteral
                    OptionalLocationHint
                     { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaImport);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $4 );  } ;

SchemaPrefix: Namespace
                                NCNameForPrefix
                                AssignEquals { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaPrefix); } 
 | DefaultElement
                                Namespace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaPrefix); } ;


QueryListTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQueryListTail); } 
 | QueryListTail
            QuerySeparator
                        OptionalModule
                         { 
                             if(NTQueryListTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQueryListTail);
                             ASTNodeAddChild( $$, $3 );  } ;

OptionalModule: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalModule); } 
 | Module
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalModule);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalVersionDecl: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalVersionDecl); } 
 | VersionDecl
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalVersionDecl);
                             ASTNodeAddChild( $$, $1 );  } ;

MainOrLibraryModule: MainModule { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTMainOrLibraryModule);
                             ASTNodeAddChild( $$, $1 );  } 
 | LibraryModule { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTMainOrLibraryModule);
                             ASTNodeAddChild( $$, $1 );  } ;

SetterList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetterList); } 
 | SetterList
            Setter
                        Separator
                         { 
                             if(NTSetterList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSetterList);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 );  } ;

DeclList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclList); } 
 | DeclList
            DeclChoice
                        Separator
                         { 
                             if(NTDeclList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclList);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 );  } ;

DeclChoice: Import { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( $$, $1 );  } 
 | NamespaceDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( $$, $1 );  } 
 | VarDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( $$, $1 );  } 
 | FunctionDecl { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclChoice);
                             ASTNodeAddChild( $$, $1 );  } ;

ImportPrefixDecl: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTImportPrefixDecl); } 
 | Namespace
            NCNameForPrefix
            AssignEquals
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTImportPrefixDecl); } ;

LocationHint: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLocationHint); } 
 | AtStringLiteral
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLocationHint); } ;

VarDeclOptionalTypeDecl: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarDeclOptionalTypeDecl); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarDeclOptionalTypeDecl);
                             ASTNodeAddChild( $$, $1 );  } ;

VarDeclAssignmentOrExtern: LbraceExprEnclosure
                                Expr
                                Rbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarDeclAssignmentOrExtern);
                             ASTNodeAddChild( $$, $2 );  } 
 | External { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTVarDeclAssignmentOrExtern); } ;

CommaExpr: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCommaExpr); } 
 | CommaExpr
            Comma
                        ExprSingle
                         { 
                             if(NTCommaExpr != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCommaExpr);
                             ASTNodeAddChild( $$, $3 );  } ;

FLWORClauseList: FLWORClauseList
                    ForClause { 
                             if(NTFLWORClauseList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( $$, $2 );  } 
 | FLWORClauseList
                    LetClause { 
                             if(NTFLWORClauseList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( $$, $2 );  } 
            
 | ForClause { 
                             if(NTFLWORClauseList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( $$, $1 );  } 
 | LetClause { 
                             if(NTFLWORClauseList != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFLWORClauseList);
                             ASTNodeAddChild( $$, $1 );  } 
            ;

OptionalWhere: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhere); } 
 | WhereClause
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhere);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalOrderBy: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOrderBy); } 
 | OrderByClause
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOrderBy);
                             ASTNodeAddChild( $$, $1 );  } ;

ForTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

PositionalVarOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPositionalVarOption); } 
 | PositionalVar
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPositionalVarOption);
                             ASTNodeAddChild( $$, $1 );  } ;

ForClauseTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForClauseTail); } 
 | ForClauseTail
            Comma
                        VariableIndicator
                        VarName
                        ForTailTypeDeclarationOption
                        TailPositionalVarOption
                        In
                        ExprSingle
                         { 
                             if(NTForClauseTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForClauseTail);
                             ASTNodeSetValueToString($$, $4);
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $6 ); 
                             ASTNodeAddChild( $$, $8 );  } ;

ForTailTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForTailTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForTailTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

TailPositionalVarOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTailPositionalVarOption); } 
 | PositionalVar
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTailPositionalVarOption);
                             ASTNodeAddChild( $$, $1 );  } ;

LetTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

LetClauseTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetClauseTail); } 
 | LetClauseTail
            Comma
                        VariableIndicator
                        VarName
                        LetTailTypeDeclarationOption
                        ColonEquals
                        ExprSingle
                         { 
                             if(NTLetClauseTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetClauseTail);
                             ASTNodeSetValueToString($$, $4);
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $7 );  } ;

LetTailTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetTailTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTLetTailTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

OrderByOrOrderByStable: OrderBy { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderByOrOrderByStable); } 
 | OrderByStable { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderByOrOrderByStable); } ;

OrderSpecListTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderSpecListTail); } 
 | OrderSpecListTail
            Comma
                        OrderSpec
                         { 
                             if(NTOrderSpecListTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOrderSpecListTail);
                             ASTNodeAddChild( $$, $3 );  } ;

SortDirectionOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSortDirectionOption); } 
 | Ascending { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSortDirectionOption);
                             ASTNodeSetValueToID($$, $1); } 
 | Descending { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSortDirectionOption);
                             ASTNodeSetValueToID($$, $1); } 
            ;

EmptyPosOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEmptyPosOption); } 
 | EmptyGreatest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEmptyPosOption);
                             ASTNodeSetValueToID($$, $1); } 
 | EmptyLeast { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEmptyPosOption);
                             ASTNodeSetValueToID($$, $1); } 
            ;

CollationSpecOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCollationSpecOption); } 
 | Collation
            StringLiteral
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCollationSpecOption);
                             ASTNodeSetValueToString($$, $2); } ;

SomeOrEvery: Some { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSomeOrEvery);
                             ASTNodeSetValueToID($$, $1); } 
 | Every { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSomeOrEvery);
                             ASTNodeSetValueToID($$, $1); } ;

QuantifiedTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

QuantifiedVarDeclListTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedVarDeclListTail); } 
 | QuantifiedVarDeclListTail
            Comma
                        VariableIndicator
                        VarName
                        QuantifiedTailTypeDeclarationOption
                        In
                        ExprSingle
                         { 
                             if(NTQuantifiedVarDeclListTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedVarDeclListTail);
                             ASTNodeSetValueToString($$, $4);
                             ASTNodeAddChild( $$, $5 ); 
                             ASTNodeAddChild( $$, $7 );  } ;

QuantifiedTailTypeDeclarationOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedTailTypeDeclarationOption); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuantifiedTailTypeDeclarationOption);
                             ASTNodeAddChild( $$, $1 );  } ;

CaseClauseList: CaseClauseList
                CaseClause
            
 | CaseClause
            ;

DefaultClauseVarBindingOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDefaultClauseVarBindingOption); } 
 | VariableIndicator
            VarName
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDefaultClauseVarBindingOption);
                             ASTNodeSetValueToString($$, $2); } ;

CaseClauseVarBindingOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCaseClauseVarBindingOption); } 
 | VariableIndicator
            VarName
            As
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCaseClauseVarBindingOption);
                             ASTNodeSetValueToString($$, $2); } ;

OptionalRootExprTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalRootExprTail); } 
 | RelativePathExpr
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalRootExprTail);
                             ASTNodeAddChild( $$, $1 );  } ;

RelativePathExprTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTRelativePathExprTail); } 
 | RelativePathExprTail
            RelativePathExprStepSep
                        StepExpr
                         { 
                             if(NTRelativePathExprTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTRelativePathExprTail);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 );  } ;

RelativePathExprStepSep: Slash { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTRelativePathExprStepSep); } 
 | SlashSlash { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTRelativePathExprStepSep); } ;

ForwardOrReverseStep: ForwardStep { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardOrReverseStep);
                             ASTNodeAddChild( $$, $1 );  } 
 | ReverseStep { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTForwardOrReverseStep);
                             ASTNodeAddChild( $$, $1 );  } ;

ValidateExprSpecifiers: ValidateLbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateExprSpecifiers); } 
 | ValidateGlobal
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateExprSpecifiers); } 
 | ValidateContext
                                SchemaContextLoc
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateExprSpecifiers);
                             ASTNodeAddChild( $$, $2 );  } 
 | ValidateSchemaMode
                                ValidateSchemaModeContextOption
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateExprSpecifiers);
                             ASTNodeAddChild( $$, $2 );  } ;

ValidateSchemaModeContextOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateSchemaModeContextOption); } 
 | ValidationContext
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTValidateSchemaModeContextOption);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalAtSugar: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAtSugar); } 
 | At
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAtSugar); } ;

OptionalExpr: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalExpr); } 
 | Expr
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

FunctionNameOpening: QNameLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionNameOpening);
                             ASTNodeSetValueToString($$, $1); } ;

ArgList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTArgList); } 
 | ExprSingle
            ArgListTail
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTArgList);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } ;

ArgListTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTArgListTail); } 
 | ArgListTail
            Comma
                        ExprSingle
                         { 
                             if(NTArgListTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTArgListTail);
                             ASTNodeAddChild( $$, $3 );  } ;

TagOpenStart: StartTagOpenRoot { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTagOpenStart); } 
 | StartTagOpen { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTagOpenStart); } ;

TagClose: EmptyTagClose { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTagClose); } 
 | StartTagClose
                                ElementContentBody
                                EndTagOpen
                                TagQName
                                OptionalWhitespaceBeforeEndTagClose
                                EndTagClose { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTagClose);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $5 );  } ;

ElementContentBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContentBody); } 
 | ElementContentBody
            ElementContent
                         { 
                             if(NTElementContentBody != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementContentBody);
                             ASTNodeAddChild( $$, $2 );  } ;

OptionalWhitespaceBeforeEndTagClose: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeEndTagClose); } 
 | S
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeEndTagClose); } ;

CompElemConstructorSpec: ElementQNameLbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemConstructorSpec);
                             ASTNodeSetValueToID($$, $1); } 
 | ElementLbrace
                                Expr
                                Rbrace
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemConstructorSpec);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

OptionalCompElemBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompElemBody); } 
 | CompElemBody
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompElemBody);
                             ASTNodeAddChild( $$, $1 );  } ;

CompElemNamespaceOrExprSingle: CompElemNamespace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | ExprSingle { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( $$, $1 );  } ;

CompElemBodyTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemBodyTail); } 
 | CompElemBodyTail
            Comma
                        TailCompElemNamespaceOrExprSingle
                         { 
                             if(NTCompElemBodyTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompElemBodyTail);
                             ASTNodeAddChild( $$, $3 );  } ;

TailCompElemNamespaceOrExprSingle: CompElemNamespace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTailCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( $$, $1 );  } 
 | ExprSingle { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTailCompElemNamespaceOrExprSingle);
                             ASTNodeAddChild( $$, $1 );  } ;

CompAttrConstructorOpening: AttributeQNameLbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompAttrConstructorOpening);
                             ASTNodeSetValueToID($$, $1); } 
 | AttributeLbrace
                                Expr
                                Rbrace
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompAttrConstructorOpening);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

OptionalCompAttrValExpr: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompAttrValExpr); } 
 | Expr
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompAttrValExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

CompXmlPIOpening: PINCNameLbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompXmlPIOpening);
                             ASTNodeSetValueToID($$, $1); } 
 | PILbrace
                                Expr
                                Rbrace
                                LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCompXmlPIOpening);
                             ASTNodeSetValueToID($$, $1);
                             ASTNodeAddChild( $$, $2 );  } ;

OptionalCompXmlPIExpr: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompXmlPIExpr); } 
 | Expr
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompXmlPIExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalCompTextExpr: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompTextExpr); } 
 | Expr
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalCompTextExpr);
                             ASTNodeAddChild( $$, $1 );  } ;

CdataSectionOpen: CdataSectionStartForElementContent { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCdataSectionOpen); } 
 | CdataSectionStart { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCdataSectionOpen); } ;

CdataSectionBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCdataSectionBody); } 
 | CdataSectionBody
            CDataSectionChar
                         { 
                             if(NTCdataSectionBody != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCdataSectionBody); } ;

ProcessingInstructionStartOpen: ProcessingInstructionStartForElementContent { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTProcessingInstructionStartOpen); } 
 | ProcessingInstructionStart { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTProcessingInstructionStartOpen); } ;

OptionalPIContent: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalPIContent); } 
 | SForPI
            XmlPIContentBody
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalPIContent);
                             ASTNodeAddChild( $$, $2 );  } ;

XmlPIContentBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlPIContentBody); } 
 | XmlPIContentBody
            PIContentChar
                         { 
                             if(NTXmlPIContentBody != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlPIContentBody); } ;

XmlCommentStartOpen: XmlCommentStartForElementContent { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlCommentStartOpen); } 
 | XmlCommentStart { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlCommentStartOpen); } ;

XmlCommentContents: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlCommentContents); } 
 | XmlCommentContents
            CommentContentChar
                         { 
                             if(NTXmlCommentContents != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXmlCommentContents); } ;

OptionalAttribute: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAttribute); } 
 | TagQName
            OptionalWhitespaceBeforeValueIndicator
            ValueIndicator
            OptionalWhitespaceBeforeAttributeValue
            AttributeValue
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAttribute);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $4 ); 
                             ASTNodeAddChild( $$, $5 );  } ;

OptionalWhitespaceBeforeValueIndicator: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeValueIndicator); } 
 | S
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeValueIndicator); } ;

OptionalWhitespaceBeforeAttributeValue: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeAttributeValue); } 
 | S
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalWhitespaceBeforeAttributeValue); } ;

QuotAttributeValueContents: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttributeValueContents); } 
 | QuotAttributeValueContents
            QuotContentOrEscape { 
                             if(NTQuotAttributeValueContents != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotAttributeValueContents);
                             ASTNodeAddChild( $$, $2 );  } ;

QuotContentOrEscape: EscapeQuot { 
                             if(NTQuotContentOrEscape != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotContentOrEscape); } 
 | QuotAttrValueContent { 
                             if(NTQuotContentOrEscape != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTQuotContentOrEscape);
                             ASTNodeAddChild( $$, $1 );  } ;

AposAttributeValueContents: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttributeValueContents); } 
 | AposAttributeValueContents
            AposContentOrEscape { 
                             if(NTAposAttributeValueContents != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposAttributeValueContents);
                             ASTNodeAddChild( $$, $2 );  } ;

AposContentOrEscape: EscapeApos { 
                             if(NTAposContentOrEscape != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposContentOrEscape); } 
 | AposAttrValueContent { 
                             if(NTAposContentOrEscape != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAposContentOrEscape);
                             ASTNodeAddChild( $$, $1 );  } ;

EnclosedExprOpening: Lbrace { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEnclosedExprOpening); } 
 | LbraceExprEnclosure { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTEnclosedExprOpening); } ;

XMLSpacePreserveOrStrip: XMLSpacePreserve { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXMLSpacePreserveOrStrip); } 
 | XMLSpaceStrip { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTXMLSpacePreserveOrStrip); } ;

DeclareDefaultElementOrFunction: DeclareDefaultElement { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclareDefaultElementOrFunction); } 
 | DeclareDefaultFunction { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDeclareDefaultElementOrFunction); } ;

OptionalParamList: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalParamList); } 
 | ParamList
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalParamList);
                             ASTNodeAddChild( $$, $1 );  } ;

FunctionDeclSigClose: Rpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionDeclSigClose); } 
 | RparAs
                                SequenceType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionDeclSigClose);
                             ASTNodeAddChild( $$, $2 );  } ;

FunctionDeclBody: EnclosedExpr { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionDeclBody);
                             ASTNodeAddChild( $$, $1 );  } 
 | External { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTFunctionDeclBody); } ;

ParamListTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTParamListTail); } 
 | ParamListTail
            Comma
                        Param
                         { 
                             if(NTParamListTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTParamListTail);
                             ASTNodeAddChild( $$, $3 );  } ;

OptionalTypeDeclarationForParam: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalTypeDeclarationForParam); } 
 | TypeDeclaration
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalTypeDeclarationForParam);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalOccurrenceIndicator: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOccurrenceIndicator); } 
 | OccurrenceZeroOrOne
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOccurrenceIndicator); } ;

OptionalOccurrenceIndicatorForSequenceType: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOccurrenceIndicatorForSequenceType); } 
 | OccurrenceIndicator
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalOccurrenceIndicatorForSequenceType);
                             ASTNodeAddChild( $$, $1 );  } ;

ElementTypeOpen: ElementType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTypeOpen);
                             ASTNodeSetValueToID($$, $1); } 
 | ElementTypeForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTypeOpen); } 
 | ElementTypeForDocumentTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTypeOpen); } ;

OptionalElementTestBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalElementTestBody); } 
 | SchemaContextPath
                                ElementName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalElementTestBody);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
 | ElementNameOrWildcard
                                ElementTestBodyOptionalParam { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalElementTestBody);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
            ;

ElementTestBodyOptionalParam: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTestBodyOptionalParam); } 
 | CommaForKindTest
            TypeNameOrWildcard
            NillableOption
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTElementTestBodyOptionalParam);
                             ASTNodeAddChild( $$, $2 ); 
                             ASTNodeAddChild( $$, $3 );  } ;

NillableOption: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNillableOption); } 
 | Nillable
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTNillableOption);
                             ASTNodeSetValueToID($$, $1); } ;

AttributeTestOpening: AttributeType { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeTestOpening);
                             ASTNodeSetValueToID($$, $1); } 
 | AttributeTypeForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeTestOpening); } ;

OptionalAttributeTestBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAttributeTestBody); } 
 | SchemaContextPath
                                AttributeName { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAttributeTestBody);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
 | AttribNameOrWildcard
                                AttributeTestBodyOptionalParam { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalAttributeTestBody);
                             ASTNodeAddChild( $$, $1 ); 
                             ASTNodeAddChild( $$, $2 );  } 
            ;

AttributeTestBodyOptionalParam: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeTestBodyOptionalParam); } 
 | CommaForKindTest
            TypeNameOrWildcard
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAttributeTestBodyOptionalParam);
                             ASTNodeAddChild( $$, $2 );  } ;

PITestOpening: ProcessingInstructionLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPITestOpening); } 
 | ProcessingInstructionLparForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTPITestOpening); } ;

OptionalPITestBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalPITestBody); } 
 | NCNameForPI { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalPITestBody); } 
 | StringLiteralForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalPITestBody); } 
            ;

DocumentTestOpening: DocumentLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDocumentTestOpening);
                             ASTNodeSetValueToID($$, $1); } 
 | DocumentLparForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTDocumentTestOpening); } ;

OptionalDocumentTestBody: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalDocumentTestBody); } 
 | ElementTest
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalDocumentTestBody);
                             ASTNodeAddChild( $$, $1 );  } ;

CommentTestOpen: CommentLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCommentTestOpen); } 
 | CommentLparForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTCommentTestOpen); } ;

TextTestOpen: TextLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTextTestOpen); } 
 | TextLparForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTTextTestOpen); } ;

AnyKindTestOpening: NodeLpar { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAnyKindTestOpening); } 
 | NodeLparForKindTest { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTAnyKindTestOpening); } ;

SchemaContextPathTail: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaContextPathTail); } 
 | SchemaContextPathTail
            SchemaContextStepSlash
                         { 
                             if(NTSchemaContextPathTail != ASTNodeGetID($$))
                               
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTSchemaContextPathTail); } ;

OptionalSchemaContextLocContextPath: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalSchemaContextLocContextPath); } 
 | SchemaContextPath
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalSchemaContextLocContextPath);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalSchemaImportPrefixDecl: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalSchemaImportPrefixDecl); } 
 | SchemaPrefix
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalSchemaImportPrefixDecl);
                             ASTNodeAddChild( $$, $1 );  } ;

OptionalLocationHint: /* Empty */ { 
                             
        
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalLocationHint); } 
 | AtStringLiteral
             { 
                             
        yyval = new ParserVal(0);
        $$ = ASTNodeCreate(NTOptionalLocationHint); } ;

%%

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

        