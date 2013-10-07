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
</xsl:template>

<xsl:template match="qti:assessmentTest" mode="qti">
    <div class="exercise">
        <xsl:if test="@width">
            <xsl:attribute name="style">width:<xsl:value-of select="@width"/>px</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="qti:testPart" mode="qti"/>
        <div class="exercise-completed">klaar!</div>
    </div>
</xsl:template>
<xsl:template match="qti:testPart" mode="qti">
    <xsl:apply-templates select="qti:assessmentSection" mode="qti"/>
</xsl:template>
<xsl:template match="qti:assessmentSection" mode="qti">
    <div class="exercise-multi-item">
        <xsl:apply-templates select="qti:assessmentItemRef" mode="qti"/>
    </div>
</xsl:template>
<xsl:template match="qti:assessmentItemRef" mode="qti">
    <xsl:variable name="pos" select="position()"/>
    <div>
        <xsl:choose>
            <xsl:when test="$pos=1">
                <xsl:attribute name="class">exercise-item selected</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">exercise-item</xsl:attribute>                        
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="document(concat($docbase,@href))/qti:assessmentItem" mode="qti"/>
    </div>
</xsl:template>

<!-- //////////////////// -->
<!--        ITEM          -->
<!-- //////////////////// -->

<!-- meerkeuze -->
<xsl:template match="qti:assessmentItem[qti:itemBody/qti:choiceInteraction]" mode="qti">
    <div class="choice-exercise-question">
        <xsl:apply-templates select="qti:itemBody/node()[name()!='choiceInteraction']" mode="content"/>
    </div>
    <xsl:variable name="respId" select="qti:itemBody/qti:choiceInteraction/@responseIdentifier"/>
    <xsl:variable name="correctId" select="qti:responseDeclaration[@identifier=$respId]/qti:correctResponse/qti:value"/>
    <xsl:choose>
        <xsl:when test="qti:itemBody/qti:choiceInteraction/@shuffle='true'">
            <xsl:for-each select="qti:itemBody/qti:choiceInteraction/qti:simpleChoice">
                <xsl:sort select="text()"/>
                <div class="choice-exercise-option">
                    <xsl:if test="@identifier=$correctId">
                        <xsl:attribute name="state">yes</xsl:attribute>
                    </xsl:if>
                    <div class="choise-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
                    <xsl:apply-templates select="node()" mode="content"/>
                </div>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="qti:itemBody/qti:choiceInteraction/qti:simpleChoice">
                <div class="choice-exercise-option">
                    <xsl:if test="@identifier=$correctId">
                        <xsl:attribute name="state">yes</xsl:attribute>
                    </xsl:if>
                    <div class="choise-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
                    <xsl:apply-templates select="node()" mode="content"/>
                </div>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>

    
    <div style="clear:left"/>
    <div class="item-completed" onclick="javascript:nextItem(this)"></div>
</xsl:template>
<xsl:template match="qti:assessmentItem[qti:itemBody//qti:MSLO-DRAGEntryInteraction]" mode="qti">
    <div class="exercise-item-drop">
        <div class="exercise-drop-text">
           <xsl:apply-templates select="qti:itemBody/node()" mode="content"/>
        </div>
        <div class="exercise-drop-cells">
            <xsl:for-each select="qti:responseDeclaration">
                <xsl:sort select="qti:correctResponse/qti:value"/>
                <div class="exercise-drop-cell" nr="{@identifier}">
                    <xsl:value-of select="qti:correctResponse/qti:value"/>
                </div>
            </xsl:for-each>
        </div>
    </div>
</xsl:template>

<xsl:template match="qti:textEntryInteraction" mode="MSLO-DRAG">
    <span class="drop-item" nr="{@responseIdentifier}"></span>
</xsl:template>


<xsl:template match="qti:assessmentItem[qti:itemBody//qti:textEntryInteraction]" mode="qti">
    <div class="exercise-item-drop">
        <div class="exercise-drop-text">
           <xsl:apply-templates select="qti:itemBody/node()" mode="content"/>
        </div>
    </div>
    <div style="clear:left"/>
    <div class="item-completed" onclick="javascript:nextItem(this)"></div>
</xsl:template>
<xsl:template match="qti:textEntryInteraction" mode="content">
    <input type="text" class="textentry-item" nr="{@responseIdentifier}"></input>
</xsl:template>



</xsl:stylesheet>
