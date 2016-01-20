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

<xsl:template match="include" mode="editor">
    <xsl:variable name="rawcontent">
        <xsl:choose>
            <xsl:when test="$option='editor-process-item'">
                <!--dit is geen document, maar slechts 1 item van xml, gebruikt door de editor om een stukje content
                in te voegen -->
                <xsl:apply-templates mode="remove-xhtml"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- default: lees content uit het xml-bestand -->
                <xsl:copy-of select="document(concat($docbase,@filename))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="content">
        <xsl:apply-templates select="$rawcontent" mode="editor-prepare"/>
    </xsl:variable>
    
    <div class="_editor_context_base">
        <div class="item-container">
            <!-- set item-specific menu-options -->
            <xsl:for-each select="$content/*[1]">
                <!-- this is no real loop, just setting context -->
                <xsl:call-template name="set-contextmenu-options"/>
            </xsl:for-each>

            <!-- place the menu button here -->
            <div class="menu-button-div item-container-menu">
                <span class="menu-button"></span>
            </div>
            
            <div tag="include">
                <xsl:apply-templates select="@*" mode="editor"/>

                <xsl:call-template name="set-included-title">
                    <xsl:with-param name="name" select="name($content/*[1])"/>
                    <xsl:with-param name="isclone" select="$content/*[1]/metadata/clone/@active='true'"/>
                </xsl:call-template>
                
                <xsl:variable name="fname" select="@filename"/>
                <xsl:for-each select="$content/*[1]"> <!-- not a real loop, just setting context -->
                    <xsl:call-template name="generate-included-content">
                        <xsl:with-param name="fname" select="$fname"/>
                    </xsl:call-template>
                </xsl:for-each>
            </div>
            <div style="clear:both"/>
        </div>
    </div>
</xsl:template>

<xsl:template name="set-included-title">
    <xsl:param name="name"/>
    <xsl:param name="isclone"/>
    <xsl:choose>
        <xsl:when test="$name='exercise'">
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
        </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="generate-included-content">
    <xsl:param name="fname"/> <!-- filename of included xml-file -->

    <xsl:variable name="isclone" select="metadata/clone/@active='true'"/>
    <xsl:variable name="medium">
        <xsl:choose>
            <xsl:when test="@medium">
                <xsl:value-of select="@medium"/>
            </xsl:when>
            <xsl:otherwise>both</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <div class="included-item-wrapper" medium="{$medium}">
        <!-- isclone: only relevant for exercises ("Kloonopgaven") -->
        <xsl:if test="$isclone">
            <xsl:attribute name="clone">true</xsl:attribute>
        </xsl:if>
                    
        <!-- visual element for publication channel: web, paper, both or none -->
        <div class="block-button visible">
            <xsl:choose>
                <xsl:when test="$medium='paper'">papier</xsl:when>
                <xsl:when test="$medium='web'">web</xsl:when>
                <xsl:when test="$medium='none'">verborgen</xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </div>        
                
        <div tag="{name()}">
            <xsl:apply-templates select="@*" mode="editor"/>                    
            <!-- add metadata section. If not present in xml, generate one -->
            <xsl:call-template name="set-metadata">
                <xsl:with-param name="name" select="name()"/>
                <xsl:with-param name="fname" select="$fname"/>
            </xsl:call-template>
            <!-- create remaining content of the item -->
            <xsl:apply-templates select="*[name()!='metadata']" mode="editor">
                <xsl:with-param name="fname" select="$fname"/>
            </xsl:apply-templates>                    
        </div>
    </div>
</xsl:template>


<xsl:template name="set-contextmenu-options">
    <xsl:choose>
        <xsl:when test="name()='example'">
            <div  class="_editor_option" type="action" name="metadata invullen" function="actions/SetGeneralMetadata"/>
            <div  class="_editor_option" type="action" name="kopiëren" function="actions/CopyHandler">
                <xsl:attribute name="params">{itemtype: 'example'}</xsl:attribute>
            </div>
            <div class="_editor_option" type="repeat" function="actions/OptionalMenuItem" name="Voorbeeldtekst">
                <xsl:attribute name="params">{item: 'example'}</xsl:attribute>
            </div>
        </xsl:when>
        <xsl:when test="name()='explanation'">
            <div  class="_editor_option" type="action" name="metadata invullen" function="actions/SetGeneralMetadata"/>
            <div  class="_editor_option" type="action" name="kopiëren" function="actions/CopyHandler">
                <xsl:attribute name="params">{itemtype: 'explanation'}</xsl:attribute>
            </div>
            <div class="_editor_option" type="repeat" function="actions/OptionalMenuItem" name="Uitlegtekst">
                <xsl:attribute name="params">{item: 'explanation'}</xsl:attribute>
            </div>
        </xsl:when>
        <xsl:when test="name()='theory'">
            <div  class="_editor_option" type="action" name="metadata invullen" function="actions/SetGeneralMetadata"/>
            <div  class="_editor_option" type="action" name="kopiëren" function="actions/CopyHandler">
                <xsl:attribute name="params">{itemtype: 'theory'}</xsl:attribute>
            </div>
            <div class="_editor_option" type="repeat" function="actions/OptionalMenuItem" name="Theorietekst">
                <xsl:attribute name="params">{item: 'theory'}</xsl:attribute>
            </div>
        </xsl:when>
        <xsl:when test="name()='exercise'">
            <xsl:variable name="isclone" select="metadata/clone/@active='true'"/>
            <div  class="_editor_option" type="action" name="metadata invullen" function="actions/SetExerciseMetadata"/>
            <div  class="_editor_option" type="action" name="kopiëren" function="actions/CopyHandler">
                <xsl:attribute name="params">{itemtype: 'exercises'}</xsl:attribute>
            </div>
            <xsl:if test="not($isclone)">
                <div  class="_editor_option" type="action" name="Maak kloonopgave" function="actions/CreateCloneExercise"/>
            </xsl:if>
            <div  class="_editor_option" type="repeat" name="opgave" function="actions/RepeatExercise"/>
            <div  class="_editor_option" type="action" name="schuif omhoog" function="actions/ShiftItemUp"/>
            <div  class="_editor_option" type="action" name="schuif omlaag" function="actions/ShiftItemDown"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="set-metadata">
    <!-- context: -->
    <xsl:param name="name"/><!-- item name: example, exercise, etc -->
    <xsl:param name="fname"/><!-- filename attribute of the include-tag -->
    <div class="metadata-container">
        <form>
            <xsl:choose>
                <xsl:when test="$name='example' or $name='explanation' or $name='theory'">
                    <div class="meta-medium">
                        <b>Medium:</b>
                        <input type="radio" name="medium" value="paper">papier</input>
                        <input type="radio" name="medium" value="web">web</input>
                        <input type="radio" name="medium" value="both">beide</input>
                        <input type="radio" name="medium" value="none">verborgen</input>
                    </div>
                </xsl:when>
                <xsl:when test="$name='exercise'">
                        id : <xsl:value-of select="replace($fname,'.xml','')"/>
                        <br/>
                        <span>
                            <b>Niveau:</b> 
                        </span>
                        <input type="radio" name="level" value="1">1</input>
                        <input type="radio" name="level" value="2">2</input>
                        <input type="radio" name="level" value="3">3</input>
                        <input type="radio" name="level" value="4">4</input>
                        <input type="radio" name="level" value="5">5</input>
                        <br/>
                        <xsl:if test="string-length(metadata/clone)>0">
                            <input type="checkbox" name="kloonopgave" value="clone">Kloonopgave van <xsl:value-of select="metadata/clone"/></input>
                            <br/>
                        </xsl:if>
                        <div class="meta-medium">
                            <b>Medium:</b>
                            <input type="radio" name="medium" value="paper">papier</input>
                            <input type="radio" name="medium" value="web">web</input>
                            <input type="radio" name="medium" value="both">beide</input>
                            <input type="radio" name="medium" value="none">verborgen</input>
                        </div>
                        <b>Soort opgave: </b>
                        <br/>
                        <input type="checkbox" name="olympiadevraag">olympiadevraag</input>
                        <br/>
                        <input type="checkbox" name="examenvraag">examenvraag</input>
                        <br/>
                        <input type="checkbox" name="kangoeroevraag">kangoeroevraag</input>
                        <br/>
                        <input type="checkbox" name="wda">wiskunde-denkactiviteit (WDA)</input>
                        <br/>
                        <b>Rekenmachine toegestaan</b> 
                        <input type="checkbox" name="calculator_allowed"></input>
                        <br/>
                        <b>Groepslabels:</b> 
                        <input type="text" name="groepslabel" size="30">
                            <xsl:for-each select="metadata/group-label/@value"> 
                                <xsl:value-of select="."/> 
                            </xsl:for-each>
                        </input>
                        <br/>
                        <b>Gerelateerde theorie:</b>
                        <ul class="related-theory">
                            <li>
                                <div class="add-item-button">Voeg toe...</div>
                            </li>
                        </ul>
                        <br/>
                        <b>Leerdoelen</b>: <div class="metadata-obj-selector-container"/>
                        <br/>
                        <div class="close-metadata-button"/>
                </xsl:when>
                <xsl:otherwise>
            
                </xsl:otherwise>    
            </xsl:choose>
            <br/>
            <div class="close-metadata-button"/>
        </form>
        <div tag="metadata">
            <xsl:apply-templates select="metadata/*" mode="editor"></xsl:apply-templates>
        </div>
    </div>
</xsl:template>


</xsl:stylesheet>
