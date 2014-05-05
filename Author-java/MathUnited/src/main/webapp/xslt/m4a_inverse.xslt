<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="saxon cals"
extension-element-prefixes="exsl">
<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="m:*"/>
<xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
<xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
<xsl:param name="option"/>
<xsl:variable name="cm2px" select="number(50)"/>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>

<xsl:include href="editor/inverse.xslt"/>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/">
    <xsl:if test="not($option='editor-process-item')">
        <xsl:processing-instruction name="context-directive"><xsl:text>job ctxfile ../m4all-leertaak.ctx</xsl:text></xsl:processing-instruction> 
    </xsl:if>
<root>
    <xsl:variable name="pass1">
        <xsl:apply-templates mode="editor-prepare"/>
    </xsl:variable>
    <xsl:variable name="pass2">
        <xsl:apply-templates select="$pass1" mode="editor"/>
    </xsl:variable>
    <xsl:apply-templates select="$pass2" mode="cleanup"/>
</root>
</xsl:template>


<xsl:template match="xhtml:div[@tag='learningaspects']" priority="2" mode="editor">
    <learningaspects>
        <xsl:for-each select=".//xhtml:div[@class='paragraph-content']/xhtml:ul/xhtml:li">
            <aspect>
                <xsl:choose>
                    <xsl:when test="p | xhtml:p">
                        <xsl:apply-templates mode="paragraph"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <p><xsl:apply-templates mode="paragraph"/></p>
                    </xsl:otherwise>
                </xsl:choose>
            </aspect>
        </xsl:for-each>
    </learningaspects>
</xsl:template>
<xsl:template match="xhtml:div[@tag='knownaspects']"  priority="2" mode="editor">
    <knownaspects>
        <xsl:for-each select=".//xhtml:div[@class='paragraph-content']/xhtml:ul/xhtml:li">
            <aspect>
                <xsl:choose>
                    <xsl:when test="p | xhtml:p">
                        <xsl:apply-templates mode="paragraph"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <p><xsl:apply-templates mode="paragraph"/></p>
                    </xsl:otherwise>
                </xsl:choose>
            </aspect>
        </xsl:for-each>
    </knownaspects>
</xsl:template>

<xsl:template match="div[@class='hidden-templates']" mode="editor"/>

</xsl:stylesheet>
