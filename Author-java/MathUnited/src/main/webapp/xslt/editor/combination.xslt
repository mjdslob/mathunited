<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">


    <!-- Two pass processing of paperfigures with combinations. -->
    <xsl:template match="paperfigure[.//combination]" mode="editor">
        <!-- Create the div tags to carry over metadata -->
        <div tag="{name()}"><xsl:apply-templates select="@* | node()" mode="divtag"/></div>
        <!-- Create visual representation -->
        <xsl:apply-templates select="." mode="paragraph" />
    </xsl:template>

    <!-- Put all XML as <div tag=> elements -->
    <xsl:template match="*" mode="divtag"><div tag="{name()}"><xsl:apply-templates select="@* | node()" mode="divtag"/></div></xsl:template>

    <xsl:template match="am" mode="divtag">
        <span class="am-container"><span tag="{name()}"><xsl:apply-templates select="@* | node()" mode="divtag"/></span></span>
    </xsl:template>
    
    <!-- Copy all attributes. -->
    <xsl:template match="@*" mode="divtag">
        <xsl:copy/>
    </xsl:template>


    <!-- The rest is for creating a table (inside a figure) later we can add tags -->

    <xsl:template match="paperfigure[.//combination]" mode="paragraph">
        <div>
        <xsl:choose>
            <xsl:when test="@location='right' or @location='margin'">
                <xsl:attribute name="class">figureDiv right</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">figureDiv</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>

        <figure no-edit="true">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            <xsl:attribute name="label"><xsl:value-of select="@label"/></xsl:attribute>
            <xsl:attribute name="location"><xsl:value-of select="@location"/></xsl:attribute>
            <figcaption><xsl:value-of select="caption"/></figcaption>
            <xsl:apply-templates select="*[name()!='caption']" mode="table"/>
        </figure>
        </div>
    </xsl:template>

    <xsl:template match="combination" mode="table">
        <table no-edit="true"><thead><th>Onbewerkbare XML</th></thead><tbody>
        <xsl:apply-templates select="combiblock" mode="table">
            <xsl:with-param name="nx" select="number(@nx)"/>
            <xsl:with-param name="ny" select="number(@ny)"/>
        </xsl:apply-templates>
        </tbody></table>
    </xsl:template>

    <xsl:template match="combiblock" mode="table">
        <xsl:param name = "nx"/>
        <xsl:param name = "ny"/>
        <xsl:variable name="pos" select="position()-1"/>
        <xsl:choose>
            <xsl:when test="$pos mod $nx = 0"><tr>
                <td>
                    <xsl:apply-templates select="content" mode="table"/>
                    <xsl:apply-templates select="subcaption" mode="table"/>
                </td>
                <xsl:for-each select="following-sibling::combiblock[position()&lt;$nx]">
                    <td>
                        <xsl:apply-templates select="content" mode="table"/>
                        <xsl:apply-templates select="subcaption" mode="table"/>
                    </td>
                </xsl:for-each></tr>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="resource" mode="table">
        <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
        <img>
            <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,'../images/highres/',replace(name,'Images/',''))"/></xsl:attribute>
            <xsl:attribute name="alt"><xsl:value-of select="description"/></xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="id"/></xsl:attribute>
            <xsl:attribute name="owner"><xsl:value-of select="owner"/></xsl:attribute>
            <xsl:if test="$width>0">
                <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
                <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>

    <xsl:template match="content" mode="table">
        <xsl:apply-templates mode="table"/>
    </xsl:template>

    <xsl:template match="subcaption" mode="table">
        <div class="subcaption">
            <xsl:apply-templates mode="table"/>
        </div>
    </xsl:template>

    <xsl:template match="am" mode="table">`<xsl:value-of select='.'/>`</xsl:template>

</xsl:stylesheet>
