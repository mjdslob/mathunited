<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">

<!-- //////////////////// -->
<!-- HIGH-LEVEL STRUCTURE -->
<!-- //////////////////// -->
<xsl:template match="single-item" mode="content">
    <xsl:param name="options"/>    
    <div class="single-item">
        <div class="item">
            <div class="item-content">
                <xsl:if test="not($options and $options/options/mode[@type='answers'])">
                    <xsl:if test="item/itemcontent/itemintro">
                        <div class="itemintro">
                            <xsl:apply-templates select="item/itemcontent/itemintro/node()" mode="content">
                                <xsl:with-param name="options" select="$options"/>
                            </xsl:apply-templates>
                        </div>
                    </xsl:if>
                    <xsl:if test="item/itemcontent/subintro">
                        <div class="subintro">
                            <xsl:apply-templates select="item/itemcontent/subintro/node()" mode="content">
                                <xsl:with-param name="options" select="$options"/>
                            </xsl:apply-templates>
                        </div>
                    </xsl:if>
                    <xsl:if test="item/itemcontent/intro">
                        <div class="subintro">
                            <xsl:apply-templates select="item/itemcontent/intro/node()" mode="content">
                                <xsl:with-param name="options" select="$options"/>
                            </xsl:apply-templates>
                        </div>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="item" mode="item">
                    <xsl:with-param name="options" select="$options"/>
                </xsl:apply-templates>
             </div>
        </div>
        <div style="clear:left"/>
    </div>
</xsl:template>
<xsl:template match="multi-item" mode="content">
    <xsl:param name="options"/>    
    <div class="multi-item">
        <xsl:choose>
            <xsl:when test="not($options and $options/options/mode[@type='answers'])">
                <!-- intro -->
                <xsl:apply-templates select="intro" mode="content">
                    <xsl:with-param name="options" select="$options"/>
                </xsl:apply-templates>

                <!-- items -->
                <div class="multi-item-items">
                    <xsl:for-each select="items/item">
                        <div class="item">
                            <xsl:if test="itemcontent/itemintro">
                                <div class="itemintro">
                                    <xsl:apply-templates select="itemcontent/itemintro/node()" mode="content">
                                        <xsl:with-param name="options" select="$options"/>
                                    </xsl:apply-templates>
                                </div>
                            </xsl:if>
                            <xsl:if test="itemcontent/subintro">
                                <div class="subintro">
                                    <xsl:apply-templates select="itemcontent/subintro/node()" mode="content">
                                        <xsl:with-param name="options" select="$options"/>
                                    </xsl:apply-templates>
                                </div>
                            </xsl:if>
                            <xsl:if test="itemcontent/intro">
                                <div class="itemintro">
                                    <xsl:apply-templates select="itemcontent/intro/node()" mode="content">
                                        <xsl:with-param name="options" select="$options"/>
                                    </xsl:apply-templates>
                                </div>
                            </xsl:if>
                            <div class="item-content">
                                <div class="item-label"><xsl:value-of select="@label"/></div>
                                <xsl:apply-templates select="." mode="item">
                                    <xsl:with-param name="options" select="$options"/>
                                </xsl:apply-templates>
                            </div>
                        </div>
                        <div style="clear:left"/>
                    </xsl:for-each>
                </div>
            </xsl:when>            
            <xsl:otherwise>
                <div class="multi-item-items">
                    <xsl:for-each select="items/item">
                        <div class="item">
                            <div class="item-content">
                                <div class="item-label"><xsl:value-of select="@label"/></div>
                                <xsl:apply-templates select="." mode="item">
                                    <xsl:with-param name="options" select="$options"/>
                                </xsl:apply-templates>
                            </div>
                        </div>
                        <div style="clear:left"/>
                    </xsl:for-each>
                </div>
                
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>

<xsl:template match="intro" mode="content">
    <xsl:param name="options"/>
    <div class="intro">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="itemintro" mode="content"></xsl:template>
<xsl:template match="subintro" mode="content"></xsl:template>

<!-- //////////////////// -->
<!--  ITEM TYPES          -->
<!-- //////////////////// -->
<!-- default: type='open'  -->
<!-- note: precise matching rule is to prevent clash with itemize/item -->
<xsl:template match="single-item/item | items/item" priority="1" mode="item">
    <xsl:param name="options"/>        
        <xsl:choose>
            <xsl:when test="$options and $options/options/mode[@type='answers']">
                <div class="question">
                    <xsl:apply-templates select="answer" mode="content">
                        <xsl:with-param name="options" select="$options"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="itemcontent" mode="content">
                    <xsl:with-param name="options" select="$options"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="item[@type='closed']" priority="2" mode="item">
    <xsl:param name="options"/>       
    
    <xsl:apply-templates select="itemcontent" mode="content"/>
    
    <xsl:for-each select="alternatives/alternative">
        <div class="choice-exercise-option">
            <xsl:if test="@state='yes'">
                <xsl:attribute name="state">yes</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$options and $options/options/mode[@type='answers']">
                    <div>
                        <xsl:choose>
                            <xsl:when test="@state='yes'">
                                <xsl:attribute name="class">choice-exercise-label good-answer</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">choice-exercise-label wrong-answer</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="choice-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
                </xsl:otherwise>
            </xsl:choose>
            <div class="choice-exercise-content">
                 <xsl:apply-templates select="alternative-content" mode="content"/>
            </div>
        </div>
    </xsl:for-each>
    <div style="clear:left"/>
    <!--
    <div class="item-completed" onclick="javascript:nextItem(this)"></div>
    -->
</xsl:template>

<xsl:template match="alternative-content" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<!-- //////////////////// -->
<!--  ITEM CONTENT        -->
<!-- //////////////////// -->
<xsl:template match="itemcontent" mode="content">
    <xsl:param name="options"/>    
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <div class="item-itemcontent">
            <xsl:apply-templates select="*[name()!='itemintro' and name()!='subintro' and name()!='intro']" mode="content"/>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="itemcontent/question" mode="content">
        <div class="question">
            <xsl:apply-templates mode="content"/>
        </div>
</xsl:template>

<xsl:template match="exercisesource" mode="content"></xsl:template>
</xsl:stylesheet>
