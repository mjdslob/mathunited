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
           <div class="answer-button"></div>
           <div class="answer-content">
              <div class="answer-heading">Antwoord:</div>
              <div tag="answer">
                 <p></p>
              </div>
              <div class="answer-heading">Uitwerking:</div>
              <div tag="explanation">
                  <p></p>
              </div>
              <div class="answer-heading">Hint:</div>
              <div tag="feedback">
                  <p></p>
              </div>
              <div class="answer-heading">Uitwerking voor de docent:</div>
              <div tag="teacheranswer">
                 <p></p>
              </div>
           </div>
        </div>
    </div>
    <div id="exercise-item-closed-template">
          <div tag="item" label="" type="closed">
            <div class="item-label">a</div>
            <div class="menu-button-div">
                <span class="menu-button"></span>
            </div>
            <div tag="itemcontent">
                <div class="_editor_option" type="optional" template="exercise-itemintro-template" name="item intro"></div>
                <div tag="question">
                   <p>...(vraag)...</p>
                </div>
             </div>
             <div tag="alternatives">
                <div class="_editor_context_base">
                   <div class="_editor_option" type="repeat" name="optie" template="repeatAlternative">
                      <div class="menu-button-div"><span class="menu-button"></span></div>
                      <div tag="alternative" state="no">
                         <div class="editor-choice-exercise-label" onclick="javascript:EditorChoiceLabelClick(this)"></div>
                         <div class="choice-exercise-content">
                            <div tag="alternative-content">
                               <p>...(optie)...</p>
                            </div>
                         </div>
                         <div style="clear:both"></div>
                      </div>
                   </div>
                </div>
             </div>
             <div style="clear:left"></div>
             <div class="answer-heading">Uitwerking:</div>
             <div tag="explanation"><p></p></div>
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
    <div id="repeatAlternative">
        <div class="_editor_context_base">
            <div class="_editor_option" type="repeat" name="optie" template="repeatAlternative">
               <div class="menu-button-div"><span class="menu-button"></span></div>
               <div tag="alternative" state="no">
                  <div class="editor-choice-exercise-label" onclick="javascript:EditorChoiceLabelClick(this)"></div>
                  <div class="choice-exercise-content">
                     <div tag="alternative-content">
                        <p>...</p>
                     </div>
                  </div>
                  <div style="clear:both"></div>
               </div>
            </div>
         </div>
    </div>


</xsl:template>
<xsl:template match="exercises" mode="editor">
    <div tag="exercises">
        <div class="_editor_context_base">
            <!-- add an extra menu button to insert the first item -->
            <div class="menu-button-div">
                <span class="menu-button"></span>
            </div>
            <div class="exercises-insertion-point"/>
            <div  class="_editor_option" type="repeat" name="opgave" function="repeatExercise"/>
        </div>

        <xsl:apply-templates mode="editor"/>
    </div>
</xsl:template>

<xsl:template match="exercise" mode="editor">
    <xsl:param name="fname"/>
    <xsl:variable name="isclone" select="metadata/clone/@active='true'"/>
    <div  class="_editor_option" type="action" name="metadata invullen" function="setExerciseMetadata"/>
    <xsl:if test="not($isclone)">
        <div  class="_editor_option" type="action" name="Maak kloonopgave" function="createCloneExercise"/>
    </xsl:if>
    <div  class="_editor_option" type="repeat" name="opgave" function="repeatExercise">
        <div class="menu-button-div item-container-menu">
            <span class="menu-button"></span>
        </div>
        <div class="exercise-container">
            <xsl:if test="$isclone">
                <xsl:attribute name="clone">true</xsl:attribute>
            </xsl:if>
            <div tag="exercise">
                <xsl:apply-templates select="@*" mode="editor"/>

                <div class="exercise-with-heading open">
                    <xsl:apply-templates select="@*" mode="editor"/>
                    <div  class="_editor_option" type="action" name="schuif omhoog" function="shiftItemUp"/>
                    <div  class="_editor_option" type="action" name="schuif omlaag" function="shiftItemDown"/>
                    <div class="exercise-heading">
                        <xsl:choose>
                            <xsl:when test="$isclone">
                                  Kloonopgave <span class="opgave-title-span"><xsl:value-of select="title"/></span> <div class="opgave-label-button"/>
                            </xsl:when>
                            <xsl:otherwise>
                                  Opgave <span class="opgave-title-span"><xsl:value-of select="title"/></span> <div class="opgave-label-button"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>

                    <div class="metadata-container">
                        <div tag="metadata">
                            <form>
                                id : <xsl:value-of select="replace($fname,'.xml','')"/><br/>
                                <span>Niveau: </span>
                                <input type="radio" name="level" value="1">1</input>
                                <input type="radio" name="level" value="2">2</input>
                                <input type="radio" name="level" value="3">3</input>
                                <input type="radio" name="level" value="4">4</input>
                                <input type="radio" name="level" value="5">5</input><br/>
                                <xsl:if test="string-length(metadata/clone)>0">
                                    <input type="checkbox" name="kloonopgave" value="clone">Kloonopgave van <xsl:value-of select="metadata/clone"/></input><br/>
                                </xsl:if>
                                <input type="checkbox" name="olympiadevraag">olympiadevraag</input><br/>
                                <input type="checkbox" name="examenvraag">examenvraag</input><br/>
                                <input type="checkbox" name="wda">wiskunde-denkactiviteit (WDA)</input><br/>
                                Groepslabels: <input type="text" name="groepslabel" size="30">
                                    <xsl:for-each select="metadata/group-label/@value"> <xsl:value-of select="."/> </xsl:for-each>
                                </input><br/>
                                Gerelateerde theorie (id van paragraaf):<input type="text" name="ref-id" size="30">
                                    <xsl:value-of select="metadata/ref-id/@value"/>
                                </input>
                                <br/>
                                <div class="close-metadata-button" onclick="javascript:closeMetadata(this)"/>
                            </form>
                            <div class="metadata-data">
                                 <xsl:apply-templates select="metadata/*" mode="editor"></xsl:apply-templates>
                            </div>
                        </div>
                    </div>
                    <div class="exercise-contents">
                        <xsl:apply-templates select="*[name()!='metadata']" mode="editor"/>
                    </div>
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
        <div  class="_editor_option" type="repeat" name="deelvraag">
            <xsl:choose>
                <xsl:when test="@type='closed'">
                    <xsl:attribute name="function">repeatClosedExerciseItem</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="function">repeatExerciseItem</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
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
        <!-- make sure a container is always present for the answer -->
        <div class="answer-button"></div>
        <div class="answer-content">
            <xsl:choose>
                <xsl:when test="answer">
                    <div class="answer-heading">Antwoord:</div>
                    <xsl:apply-templates select="answer" mode="editor"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="answer-heading">Antwoord:</div>
                    <div tag="answer"><p></p></div>                
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="explanation">
                    <div class="answer-heading">Uitwerking:</div>
                    <xsl:apply-templates select="explanation" mode="editor"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="answer-heading">Uitwerking:</div>
                    <div tag="explanation"><p></p></div>                
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="feedback">
                    <div class="answer-heading">Hint:</div>
                    <xsl:apply-templates select="feedback" mode="editor"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="answer-heading">Hint:</div>
                    <div tag="feedback"><p></p></div>                
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="teacheranswer">
                    <div class="answer-heading">Uitwerking voor de docent:</div>
                    <xsl:apply-templates select="teacheranswer" mode="editor"/>
                </xsl:when>
                <xsl:otherwise>
                    <div class="answer-heading">Uitwerking voor de docent:</div>
                    <div tag="teacheranswer"><p></p></div>                
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </div>    
</xsl:template>

<xsl:template match="answer" mode="editor">
    <div tag="answer">
        <xsl:apply-templates select="@*" mode="editor"/>
        <xsl:if test="not(p)"><p/></xsl:if>
        <xsl:apply-templates select="node()" mode="editor"/>
    </div>
</xsl:template>
<xsl:template match="explanation" mode="editor">
    <div tag="explanation">
        <xsl:apply-templates select="@*" mode="editor"/>
        <xsl:if test="not(p)"><p/></xsl:if>
        <xsl:apply-templates select="node()" mode="editor"/>
    </div>
</xsl:template>
<xsl:template match="feedback" mode="editor">
    <div tag="feedback">
        <xsl:apply-templates select="@*" mode="editor"/>
        <xsl:if test="not(p)"><p/></xsl:if>
        <xsl:apply-templates select="node()" mode="editor"/>
    </div>
</xsl:template>
<xsl:template match="teacheranswer" mode="editor">
    <div tag="teacheranswer">
        <xsl:apply-templates select="@*" mode="editor"/>
        <xsl:if test="not(p)"><p/></xsl:if>
        <xsl:apply-templates select="node()" mode="editor"/>
    </div>
</xsl:template>


<!-- multiple choice item -->
<xsl:template match="item[@type='closed']" priority="2" mode="editor">
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
        <div tag="alternatives">
            <xsl:for-each select="alternatives/alternative">
                <div class="_editor_context_base">
                    <div  class="_editor_option" type="repeat" name="optie" template="repeatAlternative">
                        <div class="menu-button-div">
                            <span class="menu-button"></span>
                        </div>

                        <div tag="alternative">
                            <xsl:apply-templates select="@*" mode="editor"/>
                            <div class="editor-choice-exercise-label" onclick="javascript:EditorChoiceLabelClick(this)"/>
                            <div class="choice-exercise-content">
                                 <xsl:apply-templates select="alternative-content" mode="editor"/>
                            </div>
                            <div style="clear:both"/>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
        <div style="clear:left"/>
        <xsl:if test="explanation">
            <div class="answer-heading">Uitwerking:</div>
            <xsl:apply-templates select="explanation" mode="editor"/>
        </xsl:if>
    </div>
</xsl:template>

</xsl:stylesheet>

