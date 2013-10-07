<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">


<xsl:template match="include" mode="worksheet">
    <xsl:apply-templates select="document(concat($docbase,@filename))" mode="worksheet"/>
</xsl:template>
<xsl:template match="worksheets" mode="worksheet">
    <xsl:if test="worksheet[@id=$ws_id]">
        <xsl:apply-templates select="worksheet[@id=$ws_id]" mode="worksheet"/>
        <input type='button' onClick='window.print()' class='printbutton' value='afdrukken'/>
    </xsl:if>
</xsl:template>
<xsl:template match="worksheet[@id=$ws_id]" mode="worksheet">
    <div class="worksheet-container">
       <xsl:apply-templates mode="content" />
    </div>
</xsl:template>
<xsl:template match="*" mode="worksheet">
    <xsl:apply-templates select="*" mode="worksheet"/>
</xsl:template>
<xsl:template match="worksheet/title" mode="content">
    <div class="worksheet-header"><xsl:value-of select="."/></div>
</xsl:template>
</xsl:stylesheet>
