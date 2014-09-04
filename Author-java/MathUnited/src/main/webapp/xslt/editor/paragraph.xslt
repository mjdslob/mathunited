<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">

<xsl:import href="mathml/to-asciimathml.xslt"/>


<!-- Switch to paragraph mode -->
<xsl:template match="p | itemize | paperfigure" mode="editor">
    <xsl:apply-templates select="." mode="paragraph"/>
</xsl:template>

<!-- DEFAULT -->
<xsl:template match="*" mode="paragraph">
    <div tag="{name()}">
        <xsl:apply-templates select="@* | node()" mode="paragraph"/>
    </div>
</xsl:template>
<xsl:template match="@*" mode="paragraph">
    <xsl:copy/>
</xsl:template>
<xsl:template match="*" mode="paragraph-span">
    <span tag="{name()}">
        <xsl:apply-templates select="@* | node()" mode="paragraph-span"/>
    </span>
</xsl:template>
<xsl:template match="@* | text()" mode="paragraph-span">
    <xsl:copy/>
</xsl:template>

<!-- specific behaviour -->
<xsl:template match="am" mode="paragraph">
   <span class="am-container"> 
     <span tag="am"><xsl:apply-templates mode="paragraph"/></span>
     `<xsl:value-of select='.'/>`
   </span>
</xsl:template>
<xsl:template match="m:math" mode="paragraph">
    <xsl:choose>
        <xsl:when test="@prevent-am">
            <span class="math-container">
                <span tag="m:math"><xsl:apply-templates mode="paragraph-span"/></span>
                <xsl:apply-templates select="." mode="copy"/>
            </span>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="am">
                <xsl:apply-templates select="." mode="convert-to-asciimathml"/>
            </xsl:variable>
            <xsl:apply-templates select="$am" mode="paragraph"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="author-remark" mode="paragraph">
    <span tag="author-remark">
        <xsl:apply-templates mode="paragraph"/>
    </span>
</xsl:template>

<xsl:template match="keyword" mode="paragraph">
    <span tag="keyword">
        <span tag="text">
            <xsl:apply-templates select="text"/>
        </span>
        <xsl:if test="word">
            <span tag="word">
                <xsl:apply-templates select="word"/>
            </span>
        </xsl:if>
    </span>
</xsl:template>

<!-- elements in span -->
<xsl:template match="textref" mode="paragraph">
    <xsl:choose>
        <xsl:when test="word">
            <span tag="textref">
                <xsl:attribute name="item" select="id"/>
                <xsl:value-of select="word"/>
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span tag="textref"><xsl:apply-templates select="@* | node()" mode="paragraph"/></span>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="sheetref" mode="paragraph">
    <span tag="sheetref"><xsl:apply-templates select="@* | node()" mode="paragraph"/></span>
</xsl:template>
<xsl:template match="sheetref" mode="editor">
     <span tag="sheetref"><xsl:apply-templates select="@* | node()" mode="editor"/>&#160;<span><xsl:value-of select="@item"/></span></span>
</xsl:template>

<xsl:template match="text" mode="paragraph">
    <span tag="text"><xsl:apply-templates mode="paragraph"/></span>
</xsl:template>
<xsl:template match="p" mode="paragraph">
    <p><xsl:apply-templates mode="paragraph"/></p>
</xsl:template>
<xsl:template match="quotation" mode="paragraph">
    <span tag="quotation"><xsl:apply-templates mode="paragraph"/></span>
</xsl:template>
<xsl:template match="mark" mode="paragraph">
    <span tag="mark"><xsl:apply-templates mode="paragraph"/></span>
</xsl:template>

<xsl:template match="citation" mode="paragraph">
    <span tag="quotation"><xsl:apply-templates mode="paragraph"/></span>
</xsl:template>
<xsl:template match="sup" mode="paragraph">
    <sup><xsl:apply-templates mode="paragraph"/></sup>
</xsl:template>
<xsl:template match="sub" mode="paragraph">
    <sub><xsl:apply-templates mode="paragraph"/></sub>
</xsl:template>
<xsl:template match="i" mode="paragraph">
    <i><xsl:apply-templates mode="paragraph"/></i>
</xsl:template>
<xsl:template match="br" mode="paragraph"><br/></xsl:template>
<xsl:template match="b" mode="paragraph">
    <b><xsl:apply-templates mode="paragraph"/></b>
</xsl:template>
<xsl:template match="amount" mode="paragraph">
    <xsl:choose>
      <xsl:when test="@type='paragraph'">
         $
      </xsl:when>
      <xsl:when test="@type='paragraph'">
         &#x00A3;
      </xsl:when>
      <xsl:otherwise>
         €
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="hyperlink" mode="paragraph">
    <a>
        <xsl:apply-templates select="@*" mode="paragraph"/>
        <xsl:apply-templates mode="paragraph"/>
    </a>
</xsl:template>
<xsl:template match="resourcelink" mode="paragraph">
    <a target="_blank" class="dox" > <!-- @class='dox' is used in GenerateQTI to find these resourcelink, do not change -->
        <xsl:for-each select="@*">
            <xsl:choose>
                <!-- relative url w.r.t. base path of content -->
                <xsl:when test="name()='href'">
	              <xsl:attribute name="href"><xsl:value-of select="concat($urlbase,'../dox/',.)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:attribute name="{name()}">
                      <xsl:value-of select="."/>
                   </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates mode="paragraph"/>
    </a>
</xsl:template>


<!-- ITEMIZE -->
<!-- ITEMIZE -->
<xsl:template match="itemize[not(@number='n')]" mode="paragraph">
        <ul class="paragraph">
            <xsl:apply-templates select="@*" mode="paragraph"/>
            <xsl:apply-templates mode="paragraph"/>
        </ul>
</xsl:template>
<xsl:template match="itemize[@number='n']" mode="paragraph">
        <ol class="paragraph">
            <xsl:apply-templates select="@*" mode="paragraph"/>
            <xsl:apply-templates mode="paragraph"/>
        </ol>
</xsl:template>

<xsl:template match="itemize/item" mode="paragraph">
    <li>
            <xsl:apply-templates select="@*" mode="paragraph"/>
            <xsl:choose>
                <xsl:when test="not(p) and not(paperfigure)">
                    <p><xsl:apply-templates mode="paragraph"/></p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="paragraph"/>
                </xsl:otherwise>
            </xsl:choose>
    </li>
</xsl:template>


</xsl:stylesheet>
