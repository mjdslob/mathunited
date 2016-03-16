<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
extension-element-prefixes="exsl">


<xsl:template match="intro" mode="content">
    <xsl:param name="options"/>
    <div class="intro">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="itemintro" mode="content">
    <xsl:param name="options"/>
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="itemintro">
            <xsl:apply-templates mode="content">
                <xsl:with-param name="options" select="$options"/>
            </xsl:apply-templates>
        </div>
        <div style="clear:both"/>
    </xsl:if>
</xsl:template>
<xsl:template match="subintro" mode="content">
    <xsl:param name="options"/>
    <div class="subintro">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="items" mode="content">
    <xsl:param name="options"/>    
    <div class="multi-item-items">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="items/item" mode="content">
    <xsl:param name="options"/>        
    <div class="multi-item-item">
        <xsl:choose>
            <xsl:when test="$options and $options/options/mode[@type='answers']">
                <div class="question">
                    <div class="multi-item-item-label"><xsl:value-of select="@label"/></div>
                    <xsl:apply-templates select="answer" mode="content">
                        <xsl:with-param name="options" select="$options"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="content">
                    <xsl:with-param name="options" select="$options"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </div>
    <div style="clear:left"/>
</xsl:template>
<xsl:template match="items/item/itemcontent/question" mode="content">
        <div class="question">
            <div class="multi-item-item-label"><xsl:value-of select="ancestor::item/@label"/></div>
            <div class="answer-toggle-button" onclick="javascript:LOM_toggleAnswer(this)"/>
            <xsl:apply-templates mode="content"/>
        </div>
        <div class="answer-container">
            <xsl:apply-templates select="ancestor::item/answer/*" mode="content"/>
        </div>
</xsl:template>
<xsl:template match="single-item/item" mode="content">
    <xsl:param name="options"/>    
    <div class="single-item-item">
        <div class="answer-toggle-button" onclick="javascript:LOM_toggleAnswer(this)"/>
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
    <div class="answer-container">
        <xsl:apply-templates select="answer/*" mode="content"/>
    </div>
    <div style="clear:left"/>
</xsl:template>
<xsl:template match="multi-item//item/itemcontent" mode="content">
    <xsl:param name="options"/>    
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="multi-item-item-itemcontent">
            <xsl:apply-templates mode="content"/>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="single-item//itemcontent" mode="content">
    <xsl:param name="options"/>    
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="single-item-item-itemcontent">
            <xsl:apply-templates mode="content"/>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="single-item" mode="content">
    <xsl:param name="options"/>    
    <div class="single-item">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="multi-item" mode="content">
    <xsl:param name="options"/>    
    <div class="multi-item">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="multi-item/intro" mode="content">
    <xsl:param name="options"/>
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="itemintro">
            <xsl:apply-templates mode="content">
                <xsl:with-param name="options" select="$options"/>
            </xsl:apply-templates>
        </div>
        <div style="clear:both"/>
    </xsl:if>
    <div style="clear:left"/>
</xsl:template>
<xsl:template match="itemcontent/itemintro" mode="content">
    <xsl:param name="options"/>
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="itemintro">
            <xsl:apply-templates mode="content">
                <xsl:with-param name="options" select="$options"/>
            </xsl:apply-templates>
        </div>
        <div style="clear:both"/>
    </xsl:if>
</xsl:template>

<xsl:template match="single-item/item/itemcontent/question" mode="content">
        <xsl:apply-templates mode="content"/>
</xsl:template>

</xsl:stylesheet>
