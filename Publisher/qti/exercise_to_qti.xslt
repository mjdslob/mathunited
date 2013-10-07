<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt"
    version="1.0">
<xsl:strip-space elements="*"/>

<xsl:param name="ex-id"/>
<xsl:param name="title"/>

<xsl:template match="/">
    <assessmentItem xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" 
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                    xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd" 
                    identifier="{$ex-id}" 
                    title="{$title}" 
                    adaptive="false" 
                    timeDependent="false">
        <responseDeclaration identifier="RESPONSE_28413677" cardinality="single" baseType="string">
            <correctResponse>
                <value>a) Doen, zie figuur.&#xD;
                    b) Doen.&#xD;
                    c) Die zijn elkaars spiegelbeeld.&#xD;
                    d) Ja.
                </value>
            </correctResponse>
            <mapping defaultValue="0">
                <mapEntry mapKey="a) Doen, zie figuur.&#xD;&#xA;b) Doen.&#xD;&#xA;c) Die zijn elkaars spiegelbeeld.&#xD;&#xA;d) Ja." mappedValue="5.0" caseSensitive="false" />
            </mapping>
        </responseDeclaration>
        <outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float">
            <defaultValue>
                <value>0</value>
            </defaultValue>
        </outcomeDeclaration>
        <outcomeDeclaration identifier="MAXSCORE" cardinality="single" baseType="float">
            <defaultValue>
                <value>5</value>
            </defaultValue>
        </outcomeDeclaration>
        <outcomeDeclaration identifier="FEEDBACKBASIC" cardinality="single" baseType="identifier" view="testConstructor">
            <defaultValue>
                <value>empty</value>
            </defaultValue>
        </outcomeDeclaration>
        <itemBody>
            <div xmlns="" class="exercise-heading">
                <strong>
                    <font size="3" color="#ff0000">Verkennen</font>
                </strong>
            </div>
            <div xmlns="" class="exercise-heading"> </div>
            <div xmlns="" class="exercise-heading">
                <strong>Opgave 1</strong>
            </div>
            <div xmlns="" class="exercise-contents">
                <div class="multi-item">
                    <div class="itemintro">
                        <div class="figurediv right">
                            <div class="caption">
                                <img xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" src="media/4450eba87a8140bfafbfce7127c131a0.jpg" alt="" />
                            </div>
                        </div>
                        <p>Neem een vierkant stukje papier. </p>
                    </div>
                    <div class="multi-item-items">
                        <div class="multi-item-item">
                            <div class="multi-item-item-itemcontent">
                                <div class="question">
                                    <div class="multi-item-item-label">a) Vouw het dubbel langs één van beide diagonalen en daarna langs de andere diagonaal. </div>
                                </div>
                            </div>
                        </div>
                        <div class="multi-item-item">
                            <div class="multi-item-item-itemcontent">
                                <div class="question">
                                    <div class="multi-item-item-label">b) Knip een hoekje uit het twee keer dubbel gevouwen blaadje en vouw het daarna open. </div>
                                </div>
                            </div>
                        </div>
                        <div class="multi-item-item">
                            <div class="multi-item-item-itemcontent">
                                <div class="question">
                                    <div class="multi-item-item-label">c) Als je het blaadje nu zo voor je houdt dat één van beide vouwlijnen verticaal is wat kun je dan zeggen over de figuur links en de figuur rechts van de vouwlijn? </div>
                                </div>
                            </div>
                        </div>
                        <div class="multi-item-item">
                            <div class="multi-item-item-itemcontent">
                                <div class="question">
                                    <div class="multi-item-item-label">d) Is dat altijd zo, waar je er ook maar een hoekje uit knipt? </div>
                                </div>
                            </div>
                        </div>
                        <div class="multi-item-item">
                            <div class="multi-item-item-itemcontent">
                                <div class="question">
                                    <div class="multi-item-item-label">e) En hoe zit het met de onderste en de bovenste helft van het vierkant? </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <extendedTextInteraction responseIdentifier="RESPONSE_28413677" />
        </itemBody>
        <responseProcessing>
            <responseCondition>
                <responseIf>
                    <not>
                        <isNull>
                            <variable identifier="RESPONSE_28413677" />
                        </isNull>
                    </not>
                    <setOutcomeValue identifier="FEEDBACKBASIC">
                        <baseValue baseType="identifier">incorrect</baseValue>
                    </setOutcomeValue>
                </responseIf>
            </responseCondition>
        </responseProcessing>
    </assessmentItem>    
</xsl:template>
</xsl:stylesheet>
