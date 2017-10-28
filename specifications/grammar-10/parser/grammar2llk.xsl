<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:g="http://www.w3.org/2001/03/XPath/grammar">
	<xsl:output method="xml" indent="yes" xmlns:xalan="http://xml.apache.org/xalan" xalan:indent-amount="2"
		doctype-system="grammar.dtd"/>
		
	<!-- xsl:output method="xml"/ -->
	<xsl:strip-space elements="*"/>
	<!-- workaround for Xalan bug. -->
	<xsl:preserve-space elements="g:char"/>
	<xsl:key name="ref" match="g:token|g:production" use="@name"/>
	<xsl:key name="singleTokens" match="g:token//g:string" use="."/>
	<xsl:param name="LLM" select="false()"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="g:grammar">
		<xsl:copy>
		  <xsl:apply-templates select="@*|node()"/>
		  <g:production name="QName" is-xml="yes" xhref="http://www.w3.org/TR/REC-xml-names/#NT-QName" xgc-id="xml-version">
			<g:choice  name="QNameChoiceList">
				<g:ref name="NotKeywordQName"/>
				<xsl:variable name="trefs" select="/g:grammar/g:state-list/g:state[(@name = 'DEFAULT') or (@name = 'PROLOG') or (@name = 'OPERAND')]//g:tref"/>
				<xsl:call-template name="makeQNameKeywordList">
					<xsl:with-param name="nodelist" select="$trefs"/>
				</xsl:call-template>
			</g:choice>
		  </g:production>
		</xsl:copy>
		
	</xsl:template>
	
	<xsl:template name="makeQNameKeywordList">
		<xsl:param name="nodelist"/>
		<xsl:param name="index" select="1"/>
		<xsl:param name="string-list" select="''"/>
			
		<xsl:for-each select="$nodelist[$index]">	
			<xsl:variable name="ref" select="."/>
			<xsl:variable name="otoken" select="key('ref',@name)/self::g:token"/>
			<xsl:variable name="token" select="key('ref', key('ref', $otoken/@alias-for)/@alias-for)|
										 key('ref', $otoken/@alias-for)[not(@alias-for)]|
										 $otoken[not(@alias-for)]"/>
			<xsl:variable name="isRegExpr" select="count($token/g:string) = 0 or $token/g:zeroOrMore or $token/g:charClass or $token/g:char or $token/g:optional or $token/g:choice or $token/g:oneOrMore or $token/g:sequence or $token/g:complement"/>
			<xsl:variable name="isCompound" select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)]) > 1"/>
			
			<xsl:choose>
				<xsl:when test="$isRegExpr">
					<xsl:call-template name="makeQNameKeywordList">
						<xsl:with-param name="nodelist" select="$nodelist"/>
						<xsl:with-param name="index" select="$index+1"/>
						<xsl:with-param name="string-list" select="$string-list"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="not($isCompound)">
					<xsl:choose>
						<xsl:when test="$token/*[not(self::g:string)]">
							<xsl:call-template name="makeQNameKeywordList">
								<xsl:with-param name="nodelist" select="$nodelist"/>
								<xsl:with-param name="index" select="$index+1"/>
								<xsl:with-param name="string-list" select="$string-list"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$token/g:string[1][contains('AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz', substring(., 1, 1))]">
							<xsl:if test="not(contains($string-list, concat('::', $token/g:string, '::')))">
								<g:string>
									<xsl:for-each select="$ref/@*[not(name()='name') 
										and not(name()='needs-exposition-parens') 
										and not(name()='node-type')]">
										<xsl:copy/>
									</xsl:for-each>						
									<!-- xsl:for-each select="$otoken/@*[not(name()='name') and not(name()='value-type')]">
										<xsl:copy/>
									</xsl:for-each -->
									<xsl:value-of select="$token/g:string"/>
								</g:string>
							</xsl:if>
							
							<xsl:call-template name="makeQNameKeywordList">
								<xsl:with-param name="nodelist" select="$nodelist"/>
								<xsl:with-param name="index" select="$index+1"/>
								<xsl:with-param name="string-list" select="concat($string-list, '::', $token/g:string, '::')"/>
							</xsl:call-template>
							
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="makeQNameKeywordList">
								<xsl:with-param name="nodelist" select="$nodelist"/>
								<xsl:with-param name="index" select="$index+1"/>
								<xsl:with-param name="string-list" select="$string-list"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="str">
						<xsl:for-each select="$token/*[not(self::g:optionalSkip or self::g:requiredSkip)][1]
							[contains('AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz', substring(self::g:string, 1, 1))]">
							<xsl:if test="self::g:string">
									<xsl:value-of select="."/>
							</xsl:if>
						</xsl:for-each>						
					</xsl:variable>
					<xsl:if test="not(contains($string-list, concat('::', $token/g:string, '::')))">
						<xsl:for-each select="$token/*[not(self::g:optionalSkip or self::g:requiredSkip)][1]
							[contains('AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz', substring(self::g:string, 1, 1))]">
							<xsl:if test="self::g:string">
								<g:string>
									<xsl:for-each select="$ref/@*[not(name()='name') 
										and not(name()='needs-exposition-parens') 
										and not(name()='node-type')]">
										<xsl:copy/>
									</xsl:for-each>						
									<xsl:value-of select="."/>
								</g:string>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:call-template name="makeQNameKeywordList">
						<xsl:with-param name="nodelist" select="$nodelist"/>
						<xsl:with-param name="index" select="$index+1"/>
						<xsl:with-param name="string-list" select="concat($string-list, '::', $str, '::')"/>
					</xsl:call-template>
					
				</xsl:otherwise>
			  </xsl:choose>
							
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="comment()[contains(., 'g:token') or contains(., 'g:production')]" priority="2"/>
	
	<xsl:template match="g:token|g:special">
		<xsl:param name="isTRef" select="false()"/>
		<xsl:variable name="tname" select="@name"/>
		<xsl:variable name="otoken" select="."/>
		<xsl:variable name="trefs" select="/g:grammar/g:state-list//g:tref[@name=$tname]"/>
		<xsl:variable name="token" select="key('ref', key('ref', @alias-for)/@alias-for)|
                                     key('ref', @alias-for)[not(@alias-for)]|
                                     self::*[not(@alias-for)]"/>
		<xsl:if test="$token/@alias-for">
			<xsl:message terminate="yes">
				<xsl:text>Can not resolve alias: </xsl:text>
				<xsl:value-of select="@alias-for"/>
			</xsl:message>
		</xsl:if>
		<xsl:if test="not($token)">
			<xsl:message terminate="yes">
				<xsl:text>Can't resolve token: </xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="isCompound" select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)]) > 1"/>
		<xsl:variable name="isRegExpr" select="count($token/g:string) = 0 or $token/g:zeroOrMore or $token/g:charClass or $token/g:char or $token/g:optional or $token/g:choice or $token/g:oneOrMore or $token/g:sequence or $token/g:complement"/>
		
		<xsl:choose>
			<xsl:when test="$isCompound and not($token/@inline='false' or $otoken/@inline='false')">
						
				<xsl:for-each select="$token">
					<xsl:for-each select="$trefs">
						<!-- Assert that this token occurs only once in this state! -->
						<xsl:variable name="state" select="ancestor::g:state"/>
						<xsl:variable name="allTRefsOfName" select="/g:grammar/g:state-list/g:state//g:tref[@name=$tname]"/>
						<xsl:variable name="isFirstOccurance" select="$allTRefsOfName[(position() = 1) 
						and (ancestor::g:state/@name = $state/@name)]"/>
						<xsl:if test="$isFirstOccurance">
							<xsl:choose>
								<xsl:when test="$isRegExpr or $token/@inline='false' or $otoken/@inline='false'">
									<xsl:call-template name="processToken">
										<xsl:with-param name="state" select="$state"/>
										<xsl:with-param name="allTRefsOfName" select="$allTRefsOfName"/>
										<xsl:with-param name="token" select="$token"/>
										<xsl:with-param name="otoken" select="$otoken"/>
										<xsl:with-param name="tname" select="$tname"/>
										<xsl:with-param name="trefs" select="$trefs"/>
										<xsl:with-param name="isRegExpr" select="true()"/>
										<xsl:with-param name="isTRef" select="$isTRef"/>
										<xsl:with-param name="tcomponent" select="."/>									
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="false()">
									<xsl:for-each select="$token/*[not(self::g:optionalSkip or self::g:requiredSkip)]">
										<xsl:if test="not($otoken/@alias-for) and key('singleTokens', .)[1]/ancestor::g:token/@name = $token/@name">
											<!-- xsl:if test="$token/@name = 'XQueryEncoding'">
									<xsl:message terminate="no">
										<xsl:text>Found XQueryEncoding: </xsl:text>
										<xsl:value-of select="key('singleTokens', .)[1]/ancestor::g:token/@name"/>
									</xsl:message>
								</xsl:if -->
											<xsl:call-template name="processToken">
												<xsl:with-param name="state" select="$state"/>
												<xsl:with-param name="allTRefsOfName" select="$allTRefsOfName"/>
												<xsl:with-param name="token" select="$token"/>
												<xsl:with-param name="otoken" select="$otoken"/>
												<xsl:with-param name="tname">
													<xsl:call-template name="makeTokenComponentName">
														<xsl:with-param name="tcomponent" select="."/>
														<xsl:with-param name="tname" select="$tname"/>
													</xsl:call-template>
												</xsl:with-param>
												<xsl:with-param name="trefs" select="$trefs"/>
												<xsl:with-param name="isTRef" select="$isTRef"/>
												<xsl:with-param name="tcomponent" select="."/>
											</xsl:call-template>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
		
			</xsl:when>
			
			<xsl:when test="($isRegExpr or $token/@inline='false' or $otoken/@inline='false' 
				or /g:grammar/g:token//g:ref[@name = $otoken/@name]) 
				and (not($otoken/@alias-for) or $otoken/@name='URILiteral')">
				<xsl:choose>
					<xsl:when test="$isTRef">
						<g:tref>
							<xsl:attribute name="name">
								<xsl:value-of select="@name"/>
							</xsl:attribute>
							<xsl:for-each select="$token/@if">
								<xsl:copy/>
							</xsl:for-each>
						</g:tref>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy>
							<xsl:attribute name="name">
								<xsl:choose>
									<xsl:when test="$tname = 'QName'">
										<xsl:text>NotKeywordQName</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@name"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							
							<xsl:apply-templates select="@*[not(name()='name')]|node()"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="makeTokenComponentName">
		<xsl:param name="tcomponent" select="."/>
		<xsl:param name="tname"/>
		<xsl:variable name="ttname">
		<xsl:choose>
			<!-- xsl:when test="count($tcomponent/ancestor::g:token/*) = 1">
			<xsl:value-of select="key('singleTokens', .)[1]/ancestor::g:token/@name"/>
		</xsl:when -->
			<xsl:when test="$tcomponent[self::g:string] and not(contains($tcomponent, '-')) and
			contains('AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz', substring($tcomponent, 1, 1))">
				<xsl:variable name="newTName">
					<xsl:value-of select="translate(substring($tcomponent, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
					<xsl:value-of select="substring($tcomponent, 2)"/>
				</xsl:variable>
				<xsl:value-of select="$newTName"/>
				<xsl:variable name="tokOfSameName" select="/g:grammar/g:token[@name = $newTName]"/>
				<xsl:if test="$tokOfSameName and not(string($tokOfSameName) = string($tcomponent))">
					<!-- Need to uniquely identify because it conflicts with other token -->
					<xsl:text>X2</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- if this is a sub-token, is there a token already declared, whose name we can use! -->
				<xsl:variable name="tokenEquiv" select="/g:grammar/g:token[. = $tcomponent and 
				not(g:zeroOrMore or g:charClass or g:optional or g:choice or g:oneOrMore or g:sequence or g:complement)]"/>
				<xsl:choose>
					<xsl:when test="$tokenEquiv">
						<xsl:value-of select="$tokenEquiv/@name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$tname"/>
						<xsl:if test="position() &gt; 1">
							<xsl:value-of select="position()"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$ttname"/>
		<xsl:if test="/g:grammar/g:production[@name = $ttname]">
			<xsl:text>Tok</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="processToken">
		<xsl:param name="state"/>
		<xsl:param name="allTRefsOfName"/>
		<xsl:param name="token"/>
		<xsl:param name="otoken"/>
		<xsl:param name="tname"/>
		<xsl:param name="trefs"/>
		<xsl:param name="isRegExpr" select="false()"/>
		<xsl:param name="isTRef" select="false()"/>
		<xsl:param name="tcomponent" select="."/>		
		
		<xsl:choose>
			<xsl:when test="/g:grammar/g:token[(@name = $tname) and (string(*) = string($tcomponent))]">
				<!-- already there -->
			</xsl:when>			
			<xsl:when test="$isTRef">
				<g:tref>
					<xsl:attribute name="name">
						<xsl:value-of select="$tname"/>
					</xsl:attribute>
					<xsl:for-each select="$token/@if">
						<xsl:copy/>
					</xsl:for-each>
				</g:tref>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#10;&#10;  </xsl:text>
				<xsl:element name="g:token">
					<xsl:for-each select="$token/@*[not(self::name)]">
						<xsl:copy/>
					</xsl:for-each>
		
					<xsl:attribute name="name">
						<xsl:value-of select="$tname"/>
					</xsl:attribute>
					
					<xsl:choose>
						<xsl:when test="$isRegExpr or $token/@inline='false' or $otoken/@inline='false'">
							<xsl:apply-templates select="$token/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="."/>
						</xsl:otherwise>
					</xsl:choose>
				
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="space">
		<xsl:for-each select="*">
			<xsl:if test="position()!=1">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="g:production//g:ref | g:exprProduction//g:ref">
		<xsl:variable name="ref" select="."/>
		<xsl:variable name="otoken" select="key('ref',@name)/self::g:token"/>
		<xsl:variable name="token" select="key('ref', key('ref', $otoken/@alias-for)/@alias-for)|
                                     key('ref', $otoken/@alias-for)[not(@alias-for)]|
                                     $otoken[not(@alias-for)]"/>
		<xsl:variable name="isRegExpr" select="count($token/g:string) = 0 or $token/g:zeroOrMore or $token/g:charClass or $token/g:char or $token/g:optional or $token/g:choice or $token/g:oneOrMore or $token/g:sequence or $token/g:complement"/>
		<xsl:variable name="isCompound" select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)]) > 1"/>
		
		<xsl:choose>
			<xsl:when test="$isRegExpr and $token">
				<xsl:copy>
					<xsl:for-each select="$token/@name">
						<xsl:copy/>
					</xsl:for-each>
					<xsl:apply-templates select="@*[not(name()='name')]|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$isRegExpr">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="not($isCompound)">
				<xsl:choose>
					<xsl:when test="$token/*[not(self::g:string)]">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<g:string>
							<xsl:for-each select="$ref/@*[not(name()='name') 
								and not(name()='needs-exposition-parens') 
								and not(name()='node-type')]">
								<xsl:copy/>
							</xsl:for-each>						
							<!-- xsl:for-each select="$otoken/@*[not(name()='name') and not(name()='value-type')]">
								<xsl:copy/>
							</xsl:for-each -->
							<xsl:value-of select="$token/g:string"/>
						</g:string>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="boolean(parent::g:choice | parent::g:binary) and (count($token/*) > 1)">
				<g:sequence>
					<xsl:call-template name="makeCompoundReference">
						<xsl:with-param name="isCompound" select="$isCompound"/>
						<xsl:with-param name="token" select="$token"/>
						<xsl:with-param name="otoken" select="$otoken"/>
						<xsl:with-param name="ref" select="$ref"/>
					</xsl:call-template>
				</g:sequence>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="makeCompoundReference">
					<xsl:with-param name="isCompound" select="$isCompound"/>
					<xsl:with-param name="token" select="$token"/>
					<xsl:with-param name="otoken" select="$otoken"/>
					<xsl:with-param name="ref" select="$ref"/>
				</xsl:call-template>
			</xsl:otherwise>
		  </xsl:choose>
				
	</xsl:template>
	
	<xsl:template name="makeCompoundReference">
		<xsl:param name="isCompound"/>
		<xsl:param name="token"/>
		<xsl:param name="otoken"/>
		<xsl:param name="ref"/>
		
		<xsl:for-each select="$token/*[not(self::g:optionalSkip or self::g:requiredSkip)]">
			<xsl:choose>
				<xsl:when test="self::g:string">
					<xsl:copy>
						<xsl:if test="$isCompound and position() = 1">
							<xsl:attribute name="lookahead">
								<xsl:value-of select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)])"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:for-each select="$ref/@*[not(name()='name') 
							 and not(name()='needs-exposition-parens') 
							 and not(name()='node-type')]">
							<xsl:copy/>
						</xsl:for-each>
						<!-- xsl:for-each select="$otoken/@*[not(name()='name') and not(name()='value-type')]">
							<xsl:copy/>
						</xsl:for-each -->
						<xsl:value-of select="."/>
					</xsl:copy>			
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy>
						<xsl:if test="$isCompound and position() = 1">
							<xsl:attribute name="lookahead">
								<xsl:value-of select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)])"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="@*|node()"/>
					</xsl:copy>
				</xsl:otherwise>
			</xsl:choose>
			
				<!-- g:ref>
					<xsl:attribute name="name">
						<xsl:variable name="tname">
							<xsl:call-template name="makeTokenComponentName">
								<xsl:with-param name="tcomponent" select="."/>
								<xsl:with-param name="tname" select="$token/@name"/>
							</xsl:call-template>
						</xsl:variable>
						
						<xsl:value-of select="$tname"/>
					</xsl:attribute>
					
					<xsl:for-each select="$ref/@*[not(name() = 'name')]">
						<xsl:copy/>
					</xsl:for-each>
					
					<xsl:if test="$isCompound and position() = 1">
						<xsl:attribute name="lookahead">
							<xsl:value-of select="count($token/*[not(self::g:optionalSkip or self::g:requiredSkip)])"/>
						</xsl:attribute>
					</xsl:if>

				</g:ref -->
		</xsl:for-each>		
		
	</xsl:template>
	
	<xsl:template match="g:state[not(@name='ANY')]"/>
	
	<xsl:template match="g:state-list">
		<xsl:copy>
			<xsl:apply-templates select="g:state[@name='ANY']"/>
			<g:state name="DEFAULT">
				<g:description>XXX</g:description>
				<xsl:variable name="anystates" select="/g:grammar/g:state-list/g:state[@name='ANY']/g:transition/g:tref/@name"/>
				<g:transition>
					<xsl:apply-templates select="/g:grammar/g:token[not($anystates = @name)]">
						<xsl:with-param name="isTRef" select="true()"/>
					</xsl:apply-templates>
				</g:transition>
			</g:state>
			
		</xsl:copy>		
	</xsl:template>
	
</xsl:stylesheet>
