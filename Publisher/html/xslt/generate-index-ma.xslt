<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt"
    version="1.0">
<xsl:strip-space elements="*"/>
<xsl:param name="refbase"/>
<xsl:template match="/component">
    <xsl:variable name="pass">
        <index>
            <component id="{@id}">
                <xsl:apply-templates select="*" mode="collect"/>
            </component>
        </index>
    </xsl:variable>
    <xsl:apply-templates select="exslt:node-set($pass)" mode="numbering"/>

<!--
<xsl:apply-templates select="$pass" mode="numbering"/>
-->
</xsl:template>
<xsl:template match="subcomponent" mode="collect">
   <subcomponent id="{@id}">
       <xsl:apply-templates mode="collect"/>
   </subcomponent>
</xsl:template>

<xsl:template match="subcomponent/file" mode="collect">
    <xsl:variable name="path" select="concat($refbase, substring-before(.,'/'),'/')"/>
    <xsl:apply-templates select="document(concat($refbase,.))/subcomponent/*" mode="collect">
        <xsl:with-param name="path" select="$path"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="theory" mode="collect">
    <xsl:param name="path"/>
    <xsl:element name="{name()}">
        <xsl:apply-templates  mode="collect">
            <xsl:with-param name="path" select="$path"/>
        </xsl:apply-templates>
    </xsl:element>
</xsl:template>
<xsl:template match="examples" mode="collect">
    <xsl:param name="path"/>
    <xsl:element name="{name()}">
        <xsl:apply-templates  mode="collect">
            <xsl:with-param name="path" select="$path"/>
        </xsl:apply-templates>
    </xsl:element>
</xsl:template>
<xsl:template match="explanation" mode="collect">
    <xsl:param name="path"/>
    <explanation-parent>
        <xsl:if test="@id">
            <xsl:attribute name="id" select="@id"/>
        </xsl:if>
        <xsl:apply-templates  mode="collect">
            <xsl:with-param name="path" select="$path"/>
        </xsl:apply-templates>
    </explanation-parent>
</xsl:template>

<xsl:template match="include" mode="collect">
    <xsl:param name="path"/>
    <xsl:apply-templates select="document(concat($path,@filename))" mode="included">
        <xsl:with-param name="path" select="$path"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="explore | introduction | digest | application | extra |test | summary | exam | exercise | example | application | explanation" mode="included">
    <xsl:variable name="id" select="@id"/>
    <xsl:element name="{name()}">
        <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
    </xsl:element>
</xsl:template>

<xsl:template match="*" mode="included"></xsl:template>

<xsl:template match="block[@medium='paper']"></xsl:template>
<xsl:template match="*" mode="collect">
    <xsl:param name="path"/>
    <xsl:apply-templates select="*" mode="collect">
        <xsl:with-param name="path" select="$path"/>
    </xsl:apply-templates>
</xsl:template>
<!--
<xsl:template match="exercise" mode="numbering">
    
</xsl:template>

    -->

    <xsl:template match="subcomponent" mode="numbering">
        <xsl:copy>
            <xsl:attribute name="_nr">
                <xsl:value-of select="1+count(preceding-sibling::subcomponent)"/>
            </xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="numbering">
                <xsl:with-param name="exbase" select="count(preceding::exercise)"/>
                <xsl:with-param name="examplebase">
                    <xsl:choose>
                        <xsl:when test="count(./theory/examples/example)>1">
                            <xsl:value-of select="count(preceding::example)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="number(-1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="explanationbase">
                    <xsl:choose>
                        <xsl:when test="count(./explanation-parent/explanation)>1">
                            <xsl:value-of select="count(preceding::explanation)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="number(-1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="exercise" mode="numbering">
        <xsl:param name="exbase"/>
        <xsl:param name="examplebase"/>
        <xsl:param name="explanationbase"/>
        <xsl:copy>
            <xsl:attribute name="_nr">
                <xsl:value-of select="1+count(preceding::exercise)-$exbase"/>
            </xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="numbering"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="example" mode="numbering">
        <xsl:param name="exbase"/>
        <xsl:param name="examplebase"/>
        <xsl:param name="explanationbase"/>
        <xsl:copy>
            <xsl:if test="$examplebase >= 0">
                <xsl:attribute name="_nr">
                    <xsl:value-of select="1+count(preceding::example)-$examplebase"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="numbering"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="explanation" mode="numbering">
        <xsl:param name="exbase"/>
        <xsl:param name="examplebase"/>
        <xsl:param name="explanationbase"/>
        <xsl:copy>
            <xsl:if test="$explanationbase >= 0">
                <xsl:attribute name="_nr">
                    <xsl:value-of select="1+count(preceding::explanation)-$explanationbase"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="numbering">
                <xsl:with-param name="exbase" select="$exbase"/>
                <xsl:with-param name="examplebase" select="$examplebase"/>
                <xsl:with-param name="explanationbase" select="$explanationbase"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|node()" mode="numbering" >
        <xsl:param name="exbase"/>
        <xsl:param name="examplebase"/>
        <xsl:param name="explanationbase"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="numbering">
                <xsl:with-param name="exbase" select="$exbase"/>
                <xsl:with-param name="examplebase" select="$examplebase"/>
                <xsl:with-param name="explanationbase" select="$explanationbase"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
