<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">


<xsl:template match="paperfigure[not(.//combination)]"  mode="paragraph">
   <xsl:variable name="width" select="number(substring-before(content/resource/width,'cm'))*$cm2px"/>
   <img class="paperfigure">
       <xsl:attribute name="alt"><xsl:value-of select="content/resource/description"/></xsl:attribute>
       <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,'../images/highres/',replace(content/resource/name,'Images/',''))"/></xsl:attribute>
       <xsl:attribute name="location"><xsl:value-of select="@location"/></xsl:attribute>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
           <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
       </xsl:if>
       <xsl:if test="@paperlocation">
           <xsl:attribute name="paperlocation" select="@paperlocation"/>
       </xsl:if>
           
           
   </img>
</xsl:template>

<!-- applicable when an image is not part of a paperfigure -->
<xsl:template match="resource"  mode="editor">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img class="resource">
       <xsl:attribute name="alt"><xsl:value-of select="description"/></xsl:attribute>
       <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,'../images/highres/',replace(name,'Images/',''))"/></xsl:attribute>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
           <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>

<!--
<xsl:template match="combination" mode="paragraph">
    <table>
        <xsl:apply-templates select="combiblock" mode="content">
            <xsl:with-param name="nx" select="number(@nx)"/>
            <xsl:with-param name="ny" select="number(@ny)"/>
        </xsl:apply-templates>
    </table>
</xsl:template>
<xsl:template match="combiblock" mode="paragraph">
    <xsl:param name = "nx"/>
    <xsl:param name = "ny"/>
    <xsl:variable name="pos" select="position()-1"/>
        <xsl:choose>
        <xsl:when test="$pos mod $nx = 0"><tr>
            <td>
               <xsl:apply-templates select="content" mode="content"/>
               <xsl:apply-templates select="subcaption" mode="content"/>
            </td>
            <xsl:for-each select="following-sibling::combiblock[position()&lt;$nx]">
               <td>
                   <xsl:apply-templates select="content" mode="content"/>
                   <xsl:apply-templates select="subcaption" mode="content"/>
               </td>
            </xsl:for-each></tr>
        </xsl:when>
        </xsl:choose>
</xsl:template>

-->
</xsl:stylesheet>
