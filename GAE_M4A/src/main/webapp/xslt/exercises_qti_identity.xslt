<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p1"
extension-element-prefixes="exsl">

<!-- //////////////////// -->
<!--        ASSESSMENT    -->
<!-- //////////////////// -->
<xsl:template match="/" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="qti:assessmentTest" mode="content">
    <xsl:apply-templates select="." mode="qti"/>
    <xsl:for-each select=".//qti:assessmentItemRef"> 
        <xsl:apply-templates select="document(concat($docbase,@href))/qti:assessmentItem" mode="qti"/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="node() | @*" mode="qti">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*" mode="qti"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
