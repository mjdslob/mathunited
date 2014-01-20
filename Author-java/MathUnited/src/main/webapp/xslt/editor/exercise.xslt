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

<!-- EXERCISE WIDGET -->
<!-- EXERCISE WIDGET -->
<xsl:template name="exercise-templates">
    <div id="exercise-item-open-template">
        <div tag="item" label="" type="open">
            <div class="item-label">a</div>
            <div class="menu-button-div">
                <span class="menu-button"></span>
            </div>
            <div tag="itemcontent">
                <div tag="question">
                    <xsl:call-template name="paragraph-template"/>
                </div>
            </div>
            <div tag="answer">
                <div class="answer-button"></div>
                <div class="answer-content">
                    <xsl:call-template name="paragraph-template"/>
                </div>
            </div>
        </div>
    </div>
    <div id="exercise-itemintro-template">
        <div tag="itemintro">
            <xsl:call-template name="paragraph-template"/>
        </div>
    </div>
    <div id="exercise-intro-template">
        <div tag="intro">
            <xsl:call-template name="paragraph-template"/>
        </div>
    </div>
</xsl:template>
<xsl:template match="exercises" mode="editor">
    <div tag="exercises">
            <xsl:apply-templates mode="editor"/>
    </div>
</xsl:template>

<xsl:template match="exercise" mode="editor">
        <div  class="_editor_option" type="action" name="metadata invullen" function="setExerciseMetadata"/>
        <div  class="_editor_option" type="repeat" name="opgave" function="repeatExercise">
            <div class="menu-button-div item-container-menu">
                <span class="menu-button"></span>
            </div>
            <div tag="exercise">
                <xsl:apply-templates select="@*" mode="editor"/>
                
                <div class="exercise-with-heading open">
                    <xsl:apply-templates select="@*" mode="editor"/>
                    <div  class="_editor_option" type="action" name="schuif omhoog" function="shiftItemUp"/>
                    <div  class="_editor_option" type="action" name="schuif omlaag" function="shiftItemDown"/>
                    <div class="exercise-heading">
                      Opgave <span class="opgave-title-span"><xsl:value-of select="title"/></span> <div class="opgave-label-button"/>
                    </div>

                    <div class="metadata-container">
                        <div tag="metadata">
                            <form>
                                id : <xsl:value-of select="@id"/><br/>
                                <span>Niveau: </span>
                                <input type="radio" name="level" value="1">1</input>
                                <input type="radio" name="level" value="2">2</input>
                                <input type="radio" name="level" value="3">3</input>
                                <input type="radio" name="level" value="4">4</input>
                                <input type="radio" name="level" value="5">5</input><br/>
                                <input type="checkbox" name="kloonopgave" value="clone">Kloonopgave</input>
                            </form>
                            <xsl:apply-templates select="metadata/*" mode="editor"></xsl:apply-templates>
                        </div>
                    </div>
                    <div class="exercise-contents">
                        <xsl:apply-templates select="*[name()!='metadata']" mode="editor"/>
                    </div>
                </div>
            </div>
    </div>
</xsl:template>

<xsl:template match="single-item" mode="editor">
        <div tag="{name()}">
            <xsl:apply-templates mode="editor"/>
        </div>
</xsl:template>

<!-- needed to display label of subitem-->
<xsl:template match="items" mode="editor">
    <div tag="{name()}">
        <xsl:for-each select="item">
            <xsl:variable name="items-pass1">
                    <xsl:apply-templates select="." mode="editor"/>
            </xsl:variable>
            <xsl:apply-templates select="exsl:node-set($items-pass1)/*[1]" mode="insert-label"/>
        </xsl:for-each>
    </div>
</xsl:template>
<xsl:template match="div[@tag='item']" mode="insert-label">
    <div class="_editor_context_base">
        <div  class="_editor_option" type="repeat" name="deelvraag" function="repeatExerciseItem">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="editor"/>
                <div class="item-label"><xsl:value-of select="@label"/></div>
                <div class="menu-button-div">
                    <span class="menu-button"></span>
                </div>

                <xsl:apply-templates mode="copy"/>        
            </xsl:copy>
        </div>
    </div>
</xsl:template>

<!-- item types -->
<xsl:template match="item[@type='open']" mode="editor">
    <div tag="{name()}">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div tag="itemcontent">
            <div class="_editor_option" type="optional" template="exercise-itemintro-template" name="item intro">
                <xsl:choose>
                    <xsl:when test="itemcontent/subintro">
                        <xsl:apply-templates select="itemcontent/subintro" mode="editor"/>
                    </xsl:when>
                    <xsl:when test="itemcontent/itemintro">
                        <xsl:apply-templates select="itemcontent/itemintro" mode="editor"/>
                    </xsl:when>
                    <xsl:when test="itemcontent/intro">
                        <xsl:apply-templates select="itemcontent/intro" mode="editor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--<div tag="itemintro"><p></p></div> -->               
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <xsl:apply-templates select="itemcontent/question" mode="editor"/>
        </div>
        <!-- make sure a container is always present for the anser -->
        <xsl:choose>
            <xsl:when test="answer">
                <xsl:apply-templates select="answer" mode="editor"/>
            </xsl:when>
            <xsl:otherwise>
                <div tag="answer"><p></p></div>                
            </xsl:otherwise>
        </xsl:choose>
    </div>    
</xsl:template>

<xsl:template match="answer" mode="editor">
    <div tag="answer">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div class="answer-button"></div>
        <div class="answer-content">
            <xsl:apply-templates select="node()" mode="editor"/>
        </div>
    </div>
</xsl:template>
</xsl:stylesheet>

