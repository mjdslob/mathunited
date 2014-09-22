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
                    <p></p>
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
                <div class="_editor_option" type="optional" function="actions/OptionalTemplate" name="item intro">
                    <xsl:attribute name="params">{template:'exercise-itemintro-template'}</xsl:attribute>
                </div>
                <div tag="question">
                   <p>...(vraag)...</p>
                </div>
             </div>
             <div tag="alternatives">
                <div class="_editor_context_base">
                   <div class="_editor_option" type="repeat" name="optie" function="actions/RepeatTemplate">
                      <xsl:attribute name="params">{template:'repeatAlternative'}</xsl:attribute>
                      <div class="menu-button-div"><span class="menu-button"></span></div>
                      <div tag="alternative" state="no">
                         <div class="editor-choice-exercise-label"></div>
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
             <div class="answer-heading">Hint:</div>
             <div tag="feedback">
                  <p></p>
             </div>
          </div>
    </div>
    <div id="exercise-itemintro-template">
        <div tag="itemintro">
            <p>...</p>
        </div>
    </div>
    <div id="exercise-intro-template">
        <div tag="intro">
            <p>...</p>
        </div>
    </div>
    <div id="repeatAlternative">
        <div class="_editor_context_base">
            <div class="_editor_option" type="repeat" name="optie" function="actions/RepeatTemplate">
                <xsl:attribute name="params">{template:'repeatAlternative'}</xsl:attribute>
               <div class="menu-button-div"><span class="menu-button"></span></div>
               <div tag="alternative" state="no">
                  <div class="editor-choice-exercise-label"></div>
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

    <div id="repeatFigureAlternative">
        <div class="_editor_context_base">
            <div class="_editor_option" type="repeat" name="optie" function="actions/RepeatTemplate">
                <xsl:attribute name="params">{template:'repeatFigureAlternative'}</xsl:attribute>
                <div class="menu-button-div">
                    <span class="menu-button"></span>
                </div>

                <div tag="alternative" state="no">
                    <div class="editor-choice-exercise-label"/>
                    <div tag="alternative-figure">
                        <p/>
                    </div>    
                    <div style="clear:both"/>
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
            <div  class="_editor_option" type="repeat" name="opgave" function="actions/RepeatExercise"/>
        </div>

        <xsl:apply-templates mode="editor"/>
    </div>
</xsl:template>

<xsl:template match="exercise" mode="editor">
    <xsl:param name="fname"/>
    <xsl:variable name="isclone" select="metadata/clone/@active='true'"/>
    <div class="exercise-container">
        <xsl:if test="$isclone">
            <xsl:attribute name="clone">true</xsl:attribute>
        </xsl:if>
        <div tag="exercise">
            <xsl:if test="not(@id)">
                <xsl:attribute name='id' select="replace($fname,'.xml','')"/>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="editor"/>

            <div class="exercise-with-heading open">
                <xsl:apply-templates select="@*" mode="editor"/>
                <div class="exercise-heading">
                    <xsl:choose>
                        <xsl:when test="$isclone">
                            Kloonopgave <span class="opgave-title-span">
                                <xsl:value-of select="title"/>
                            </span> 
                            <span class="exercise-icon-wrapper"/>
                        </xsl:when>
                        <xsl:otherwise>
                            Opgave <span class="opgave-title-span">
                                <xsl:value-of select="title"/>
                            </span> 
                            <span class="exercise-icon-wrapper"/>
                        </xsl:otherwise>
                    </xsl:choose>
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
        <xsl:apply-templates select="@*" mode="editor"/>
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
        <div  class="_editor_option" type="repeat" function="actions/RepeatExerciseItem" name="deelvraag">
            <xsl:choose>
                <xsl:when test="@type='closed'">
                    <xsl:attribute name="params">{template: 'exercise-item-closed-template'}</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="params">{template: 'exercise-item-open-template'}</xsl:attribute>
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
<xsl:template match="item[@type='open'] | item[@type='algebrakit']" mode="editor">
    <div tag="{name()}">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div tag="itemcontent">
            <div class="_editor_option" type="optional" function="actions/OptionalTemplate" name="item intro">
                <xsl:attribute name="params">{template:'exercise-itemintro-template'}</xsl:attribute>
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
            <xsl:if test="@type='algebrakit'">
                <xsl:choose>
                    <xsl:when test="evaluation">
                        <div class="answer-heading">AlgebraKIT:</div>
                        <xsl:call-template name="algebrakit-spec"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="answer-heading">AlgebraKIT:</div>
                        <xsl:call-template name="algebrakit-spec"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
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


<xsl:template name="algebrakit-spec">
    <div class="algebrakit-spec-wrapper">
        <span class="algebrakit-spec-item">Doelgroep:</span>
        <select class='audience-select'>
            <option value="onderbouw">onderbouw</option>
            <option value="havo-a">havo-a</option>
            <option value="havo-b">havo-b</option>
            <option value="vwo-a">vwo-a</option>
            <option value="vwo-b">vwo-b</option>
        </select><br/>
        <span class="algebrakit-spec-item">Formule-palet:</span>
        <select class='item-palette-select'>
            <option value="default">Standaard</option>
            <option value="vergelijkingen">Vergelijkingen</option>
        </select><br/>
        <span class="algebrakit-spec-item">Antwoord modus:</span>
        <select class='algebrakit-mode-select'>
            <option value="EXACT">Precies hetzelfde</option>
            <option value="EQUIVALENT">Wiskundig gelijkwaardig</option>
            <option value="EQUIVALENT_MANUAL_COMMIT">Wiskundig gelijkwaardig zonder controle</option>
        </select><br/>
        <span class="algebrakit-spec-item">Toon hints:</span>
        <select class='algebrakit-hint-select'>
            <option value="true">Ja</option>
            <option value="false">Nee</option>
        </select><br/>
        <span class="algebrakit-spec-item">Opgave (AlgebraKIT):</span>
        <input type="text" name="solve" size="70" value="{evaluation/@solve}"/><br/>
        <span class="algebrakit-spec-item">Invoer naar AlgebraKIT:</span>
        <input type="text" name="submit" size="70" value="{evaluation/@submit}"/><br/>
        <span class="algebrakit-spec-item">Label:</span>
        <input type="text" name="question" size="70" value="{evaluation/@question}"/><br/>
        <span class="algebrakit-spec-item">Antwoord (AlgebraKIT):</span>
        <input type="text" name="answer" size="70" value="{evaluation/@answer}"/><br/>
        <xsl:apply-templates select="evaluation" mode="editor"/>
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
            <div class="_editor_option" type="optional" function="actions/OptionalTemplate" name="item intro">
                <xsl:attribute name="params">{template:'exercise-itemintro-template'}</xsl:attribute>
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
                    <div  class="_editor_option" type="repeat" name="optie" function="actions/RepeatTemplate">
                        <xsl:attribute name="params">{template:'repeatAlternative'}</xsl:attribute>
                        <div class="menu-button-div">
                            <span class="menu-button"></span>
                        </div>

                        <div tag="alternative">
                            <xsl:apply-templates select="@*" mode="editor"/>
                            <div class="editor-choice-exercise-label"/>
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
        <xsl:if test="feedback">
            <div class="answer-heading">Hint:</div>
            <xsl:apply-templates select="feedback" mode="editor"/>
        </xsl:if>

    </div>
</xsl:template>

<!-- multiple choice item -->
<xsl:template match="item[@type='mpcfigures']" priority="2" mode="editor">
    <div tag="{name()}">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div tag="itemcontent">
            <div class="_editor_option" type="optional" function="actions/OptionalTemplate" name="item intro">
                <xsl:attribute name="params">{template:'exercise-itemintro-template'}</xsl:attribute>
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
        <div tag="figurealternatives">
            <xsl:for-each select="figurealternatives/alternative">
                <div class="_editor_context_base">
                    <div  class="_editor_option" type="repeat" name="optie" function="actions/RepeatTemplate">
                        <xsl:attribute name="params">{template:'repeatFigureAlternative'}</xsl:attribute>
                        <div class="menu-button-div">
                            <span class="menu-button"></span>
                        </div>

                        <div tag="alternative">
                            <xsl:apply-templates select="@*" mode="editor"/>
                            <div class="editor-choice-exercise-label"/>
                            <div tag="alternative-figure">
                                <xsl:apply-templates select="alternative-figure/resource" mode="editor"/>
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
        <xsl:if test="feedback">
            <div class="answer-heading">Hint:</div>
            <xsl:apply-templates select="feedback" mode="editor"/>
        </xsl:if>
    </div>
</xsl:template>


</xsl:stylesheet>

