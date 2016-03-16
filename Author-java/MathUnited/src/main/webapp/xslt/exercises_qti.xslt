<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p1"
xmlns:cals="http://www.someplace.org/cals"
extension-element-prefixes="exsl">



<!-- //////////////////// -->
<!-- HIGH-LEVEL STRUCTURE -->
<!-- //////////////////// -->
<xsl:template match="exercise[single-item]" mode="content">
    <xsl:param name="item"/>
    <xsl:param name="nr"/>

    <xsl:variable name="response-id">RESPONSE_<xsl:value-of select="generate-id()"/></xsl:variable>
    <xsl:variable name="asm-id" select="concat($subcomponent_id,'-',generate-id())"/>
    <qti:assessmentItem xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd" 
                identifier="{$asm-id}" 
                title="{concat($component_title,' - ', $subcomponent_title,' - Opgave ',$nr)}" adaptive="false" timeDependent="false">
        <qti:responseDeclaration identifier="{concat('RESPONSE_',generate-id(single-item/item))}" cardinality="single" baseType="string">
            <qti:correctResponse><qti:value>
                <xsl:apply-templates select="single-item/item/answer/node()" mode="text-only"/>
            </qti:value></qti:correctResponse>
        </qti:responseDeclaration>
        <qti:outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float">
            <qti:defaultValue>
                <qti:value>0</qti:value>
            </qti:defaultValue>
        </qti:outcomeDeclaration>
        <qti:outcomeDeclaration identifier="MAXSCORE" cardinality="single" baseType="float">
            <qti:defaultValue>
                <qti:value>2</qti:value>
            </qti:defaultValue>
        </qti:outcomeDeclaration>
        <qti:outcomeDeclaration identifier="{concat('FEEDBACK_',generate-id(single-item/item))}" cardinality="single" baseType="identifier">
            <qti:defaultValue>
                <qti:value>empty</qti:value>
            </qti:defaultValue>
        </qti:outcomeDeclaration>
        <qti:itemBody>
            <h1><xsl:value-of select="$item-list/item-list/*[name()=$item]/@name"/></h1>
            <h2>Opgave <xsl:value-of select="$nr"/></h2>
            <xsl:apply-templates select="single-item/item/itemcontent/itemintro/node()" mode="content"/>
            <xsl:apply-templates select="single-item/item/itemcontent/subintro/node()" mode="content"/>
            <xsl:apply-templates select="single-item/item/itemcontent/intro/node()" mode="content"/>
            <xsl:apply-templates select="single-item/item" mode="item"/>
        </qti:itemBody>
        <qti:responseProcessing>
            <qti:setOutcomeValue identifier="{concat('FEEDBACK_',generate-id(single-item/item))}">
                <qti:baseValue baseType="identifier">showsolution</qti:baseValue>
            </qti:setOutcomeValue>
        </qti:responseProcessing>
    </qti:assessmentItem>
</xsl:template>

<xsl:template match="exercise[multi-item]" mode="content">
    <xsl:param name="item"/>
    <xsl:param name="nr"/>

    <xsl:variable name="response-id">RESPONSE_<xsl:value-of select="generate-id()"/></xsl:variable>
    <xsl:variable name="asm-id" select="concat($subcomponent_id,'-',generate-id())"/>
    <qti:assessmentItem xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd" 
                identifier="{$asm-id}" 
                title="{concat($component_title,' - ', $subcomponent_title,' - Opgave ',$nr)}" adaptive="false" timeDependent="false">
        <xsl:for-each select="multi-item/items/item">
            <qti:responseDeclaration identifier="{concat('RESPONSE_',generate-id())}" cardinality="single" baseType="string">
                <qti:correctResponse><qti:value>
                    <xsl:apply-templates select="answer/node()" mode="text-only"/>
                </qti:value></qti:correctResponse>
            </qti:responseDeclaration>
        </xsl:for-each>
        <qti:outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float">
            <qti:defaultValue>
                <qti:value>0</qti:value>
            </qti:defaultValue>
        </qti:outcomeDeclaration>
        <qti:outcomeDeclaration identifier="MAXSCORE" cardinality="single" baseType="float">
            <qti:defaultValue>
                <qti:value>2</qti:value>
            </qti:defaultValue>
        </qti:outcomeDeclaration>
        <xsl:for-each select="multi-item/items/item">
            <qti:outcomeDeclaration identifier="{concat('FEEDBACK_',generate-id())}" cardinality="single" baseType="identifier">
                <qti:defaultValue>
                    <qti:value>empty</qti:value>
                </qti:defaultValue>
            </qti:outcomeDeclaration>
        </xsl:for-each>
        <qti:itemBody>
            <h1><xsl:value-of select="$item-list/item-list/*[name()=$item]/@name"/></h1>
            <h2>Opgave <xsl:value-of select="$nr"/></h2>
            <xsl:apply-templates select="multi-item/item/itemcontent/itemintro/node()" mode="content"/>
            <xsl:apply-templates select="multi-item/item/itemcontent/subintro/node()" mode="content"/>
            <xsl:apply-templates select="multi-item/intro/node()" mode="content"/>
            <xsl:apply-templates select="multi-item/items/item" mode="item"/>
        </qti:itemBody>
        <qti:responseProcessing>
            <xsl:for-each select="multi-item/items/item">
                <qti:setOutcomeValue identifier="{concat('FEEDBACK_',generate-id())}">
                    <qti:baseValue baseType="identifier">showsolution</qti:baseValue>
                </qti:setOutcomeValue>
            </xsl:for-each>
        </qti:responseProcessing>
    </qti:assessmentItem>
</xsl:template>

<xsl:template match="itemintro" mode="content"></xsl:template>
<xsl:template match="subintro" mode="content"></xsl:template>

<!-- //////////////////// -->
<!--  ITEM TYPES          -->
<!-- //////////////////// -->
<!-- default: type='open'  -->
<!-- note: precise matching rule is to prevent clash with itemize/item -->
<xsl:template match="single-item/item | items/item" priority="1" mode="item">
    <xsl:apply-templates select="itemcontent" mode="content"/>
    <qti:extendedTextInteraction responseIdentifier="{concat('RESPONSE_',generate-id())}"/>
    <qti:feedbackBlock outcomeIdentifier="{concat('FEEDBACK_',generate-id())}" identifier="showsolution" showHide="show">
        <xsl:apply-templates select="answer/node()" mode="content"/>
    </qti:feedbackBlock>
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
      <xsl:apply-templates select="*[name()!='itemintro' and name()!='subintro' and name()!='intro']" mode="content"/>
</xsl:template>

<xsl:template match="itemcontent/question" mode="content">
      <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="exercisesource" mode="content"></xsl:template>
</xsl:stylesheet>
