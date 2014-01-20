<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:exsl="http://exslt.org/common"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:cals="http://www.someplace.org/cals"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="saxon"
                extension-element-prefixes="exsl">

    <xsl:include href="editor/main.xslt"/>
    <xsl:include href="editor/exercise.xslt"/>
    <xsl:include href="editor/content.xsl"/>
    <xsl:include href="editor/figure.xslt"/>
    <xsl:include href="editor/paragraph.xslt"/>

    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
                indent="yes" encoding="utf-8"/>



<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/">
    </xsl:template>

    <xsl:template match="include">
        <xsl:apply-templates select="." mode="editor"/>
    </xsl:template>

    <xsl:template match="explore">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verkennen<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <div class="item-container shift-item-anchor"/> <!-- dummy shift-container that marks beginning of 'exercises' section. Should not move -->
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="introduction">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Inleiding<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="explanation">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Uitleg<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="context">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Context<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="theory">
            <xsl:if test="include">
                <div class="m4a-editor-item-container">
                    <div class="m4a-editor-item-title">Theorie<div class="item-label-button"/></div>
                    <div class="m4a-editor-item-content">
                        <xsl:apply-templates select="include" mode="editor"/>
                    </div>
                    <div style="clear:both"/>
                </div>
            </xsl:if>
            <xsl:for-each select="examples">
                <xsl:variable name="num" select="count(preceding-sibling::examples)+1"/>
                <div class="_editor_context_base">
                    <div class="_editor_option" type="repeat" function="optionalMenuItem" item="examples" name="Voorbeeld">
                        <div class="m4a-editor-item-container">
                            <div class="m4a-editor-item-title">Voorbeeld <xsl:value-of select="$num"/><div class="item-label-button"/></div>
                            <div class="m4a-editor-item-content">
                            <div class="menu-button-div section-button">
                                <span class="menu-button"></span>
                            </div>
                                <div tag="{name()}">
                                    <xsl:apply-templates mode="editor"/>
                                </div>
                                <xsl:apply-templates select="../exercises[position()=$num]" mode="editor"/>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
            <div class="m4a-editor-item nonexistent">
                <div class="menu-button-div section-button">
                    <span class="menu-button"></span>
                </div>
                <div class="m4a-editor-item-title nonexistent">
                    <xsl:value-of select="Voorbeeld"/>
                </div>
            </div>
    </xsl:template>
    <xsl:template match="digest">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verwerken<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="application">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Toepassing<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="extra">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Practicum<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="test">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Toets<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>

    <xsl:template match="examples">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">
                    <xsl:choose>
                        <xsl:when test="count(preceding-sibling::examples)+count(following-sibling::examples)>0">
                            Voorbeeld <xsl:value-of select="1+count(preceding-sibling::examples)"/><div class="item-label-button"/>
                        </xsl:when>
                        <xsl:otherwise>
                            Voorbeeld <div class="item-label-button"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates select="include" mode="editor"/>
                </div>
            </div>
            <div style="clear:both"/>
    </xsl:template>
    
    <xsl:template match="examplesolution[not(normalize-space()='')]" mode="editor">
        <div tag="examplesolution" class="m4a-example">
            <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; antwoord</div>
            <div class="m4a-answer">
                <xsl:apply-templates mode="editor"/>
                <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
            </div>
        </div>
        <div style="clear:both"/>
    </xsl:template>



</xsl:stylesheet>
