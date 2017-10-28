<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
  <xsl:import href="../../../style/xsl-query.xsl"/>

  <!-- Baseline date from which differences will be shown -->
  <xsl:param name="baseline" select="'0001-01-01'"/>

<xsl:param name="add-color" select="'#ffff99'"/>
<xsl:param name="chg-color" select="'#99ff99'"/>

<xsl:param name="additional.css">
<xsl:if test="$show.diff.markup = '1'">
div.diff-add  { background-color: <xsl:value-of select="$add-color"/> }
div.diff-del  { text-decoration: line-through }
div.diff-chg  { background-color: <xsl:value-of select="$chg-color"/> }
div.diff-off  {  }

span.diff-add { background-color: <xsl:value-of select="$add-color"/> }
span.diff-del { text-decoration: line-through }
span.diff-chg { background-color: <xsl:value-of select="$chg-color"/> }
span.diff-off {  }

td.diff-add   { background-color: <xsl:value-of select="$add-color"/> }
td.diff-del   { text-decoration: line-through }
td.diff-chg   { background-color: <xsl:value-of select="$chg-color"/> }
td.diff-off   {  }
</xsl:if>
<xsl:text>
dd.indent { margin-left: 2em; }
p.element-syntax { border: solid thin; background-color: #ffccff }
div.proto { border: solid thin; background-color: #ffccff }
div.example { border: solid thin; background-color: blue; padding: 1em }
span.verb { font: small-caps 100% sans-serif }
span.error { font-size: small }
</xsl:text>
</xsl:param>

<!-- ==================================================================== -->

  <!-- spec: the specification itself -->
  <xsl:template match="spec">
    <html>
      <xsl:if test="header/langusage/language">
        <xsl:attribute name="lang">
          <xsl:value-of select="header/langusage/language/@id"/>
        </xsl:attribute>
      </xsl:if>
      <head>
        <title>
          <xsl:apply-templates select="header/title"/>
          <xsl:if test="header/version">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="header/version"/>
          </xsl:if>
          <xsl:if test="$additional.title != ''">
            <xsl:text> -- </xsl:text>
            <xsl:value-of select="$additional.title"/>
          </xsl:if>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <xsl:if test="$show.diff.markup != '0'">
          <div>
            <p>The presentation of this document has been augmented to
            identify changes from a previous version. Three kinds of changes
            are highlighted: <span class="diff-add">new, added text</span>,
            <span class="diff-chg">changed text</span>, and
            <span class="diff-del">deleted text</span>.</p>
            <hr/>
          </div>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="//footnote[not(ancestor::table)]">
          <hr/>
          <div class="endnotes">
            <xsl:text>&#10;</xsl:text>
            <h3>
              <xsl:call-template name="anchor">
                <xsl:with-param name="conditional" select="0"/>
                <xsl:with-param name="default.id" select="'endnotes'"/>
              </xsl:call-template>
              <xsl:text>End Notes</xsl:text>
            </h3>
            <dl>
              <xsl:apply-templates select="//footnote[not(ancestor::table)]"
                                   mode="notes"/>
            </dl>
          </div>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

<!-- ==================================================================== -->

<xsl:template name="diff-markup">
  <xsl:param name="diff">off</xsl:param>
  <xsl:choose>
    <xsl:when test="ancestor::scrap">
      <!-- forget it, we can't add stuff inside tables -->
      <!-- handled in base stylesheet -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="self::gitem or self::bibl">
      <!-- forget it, we can't add stuff inside dls; handled below -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="ancestor-or-self::phrase">
      <span class="diff-{$diff}">
        <xsl:apply-imports/>
      </span>
    </xsl:when>
    <xsl:when test="ancestor::p and not(self::p)">
      <span class="diff-{$diff}">
        <xsl:apply-imports/>
      </span>
    </xsl:when>
    <xsl:when test="ancestor-or-self::affiliation">
      <span class="diff-{$diff}">
        <xsl:apply-imports/>
      </span>
    </xsl:when>
    <xsl:when test="ancestor-or-self::name">
      <span class="diff-{$diff}">
        <xsl:apply-imports/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <div class="diff-{$diff}">
        <xsl:apply-imports/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@diff='chg' and $show.diff.markup='1' and (string(@at) gt $baseline or not(@at))]"
              priority="3">
  <xsl:call-template name="diff-markup">
        <xsl:with-param name="diff">chg</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="*[@diff='add' and $show.diff.markup='1' and (string(@at) gt $baseline or not(@at))]"
              priority="3">
  <xsl:call-template name="diff-markup">
        <xsl:with-param name="diff">add</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="*[@diff='del' and $show.diff.markup='1' and (string(@at) gt $baseline or not(@at))]"
              priority="3">
  <xsl:call-template name="diff-markup">
        <xsl:with-param name="diff">del</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="*[@diff='del']" priority="2"/>
<xsl:template match="*[@diff='del']" mode="text" priority="2"/>
<xsl:template match="*[@diff='del']" mode="toc" priority="2"/>

<xsl:template match="*[@diff='off' and $show.diff.markup='1' and (string(@at) gt $baseline or not(@at))]">
  <xsl:call-template name="diff-markup">
        <xsl:with-param name="diff">off</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- ================================================================= -->

  <xsl:template match="bibl[@diff]" priority="1">
    <xsl:variable name="dt">
      <xsl:if test="@id">
        <a name="{@id}"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@key">
          <xsl:value-of select="@key"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dd">
      <xsl:apply-templates/>
      <xsl:if test="@href">
        <xsl:text>  (See </xsl:text>
        <a href="{@href}">
          <xsl:value-of select="@href"/>
        </a>
        <xsl:text>.)</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@diff and $show.diff.markup = '1'">
        <dt class="label">
          <span class="diff-{@diff}">
            <xsl:copy-of select="$dt"/>
          </span>
        </dt>
        <dd>
          <div class="diff-{@diff}">
            <xsl:copy-of select="$dd"/>
          </div>
        </dd>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup='0'">
        <!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
        <dt class="label">
          <xsl:copy-of select="$dt"/>
        </dt>
        <dd>
          <xsl:copy-of select="$dd"/>
        </dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gitem/label">
    <xsl:variable name="diffval" select="ancestor-or-self::*/@diff"/>
    <xsl:choose>
      <xsl:when test="$diffval != '' and $show.diff.markup='1'">
        <dt class="label">
          <span class="diff-{ancestor-or-self::*/@diff}">
            <xsl:apply-templates/>
          </span>
        </dt>
      </xsl:when>
      <xsl:when test="$diffval='del' and $show.diff.markup='0'">
        <!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
        <dt class="label">
          <xsl:apply-templates/>
        </dt>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gitem/def">
    <xsl:variable name="diffval" select="ancestor-or-self::*/@diff"/>
    <xsl:choose>
      <xsl:when test="$diffval != '' and $show.diff.markup='1'">
        <dd>
          <div class="diff-{ancestor-or-self::*/@diff}">
            <xsl:apply-templates/>
          </div>
        </dd>
      </xsl:when>
      <xsl:when test="$diffval='del' and $show.diff.markup='0'">
        <!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
        <dd>
          <xsl:apply-templates/>
        </dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- authlist: list of authors (editors, really) -->
  <!-- called in enforced order from header's template, in <dl>
       context -->
  <xsl:template match="authlist[@diff]">
    <xsl:choose>
      <xsl:when test="$show.diff.markup='1'">
        <dt>
          <span class="diff-{ancestor-or-self::*/@diff}">
            <xsl:text>Editor</xsl:text>
            <xsl:if test="count(author) > 1">
              <xsl:text>s</xsl:text>
            </xsl:if>
            <xsl:text>:</xsl:text>
          </span>
        </dt>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup='0'">
        <!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
        <dt>
          <xsl:text>Editor</xsl:text>
          <xsl:if test="count(author) > 1">
            <xsl:text>s</xsl:text>
          </xsl:if>
          <xsl:text>:</xsl:text>
        </dt>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- author: an editor of a spec -->
  <!-- only appears in authlist -->
  <!-- called in <dl> context -->
  <xsl:template match="author[@diff]" priority="1">
    <xsl:choose>
      <xsl:when test="@diff and $show.diff.markup='1'">
        <dd>
          <span class="diff-{ancestor-or-self::*/@diff}">
            <xsl:apply-templates/>
            <xsl:if test="@role = '2e'">
              <xsl:text> - Second Edition</xsl:text>
            </xsl:if>
          </span>
        </dd>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup='0'">
        <!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
        <dd>
          <xsl:apply-templates/>
          <xsl:if test="@role = '2e'">
            <xsl:text> - Second Edition</xsl:text>
          </xsl:if>
        </dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!-- changed templates to auto generate an appendix with a list
     of links to open issues. -->
<xsl:template name="autogenerated-appendices-toc"/>

<xsl:template name="autogenerated-appendices"/>

  <xsl:template match="processing-instruction('schema-for-params')">
    <pre>
      <xsl:sequence
         select="unparsed-text('../src/schema-for-serialization-parameters.xsd')"/>
    </pre>
  </xsl:template>

</xsl:stylesheet>

