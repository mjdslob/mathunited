<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:exsl="http://exslt.org/common"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:cals="http://www.someplace.org/cals"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="saxon cals xhtml"
                extension-element-prefixes="exsl">
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="m:*"/>
    <xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
    <xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
    <xsl:param name="item"/>
    <xsl:param name="itempos"/>

    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>

    <xsl:variable name="item-list">
        <item-list>
            <introduction name="Inleiding" optional="true"/>
            <explore name="Verkennen" optional="true"/>
            <explanation name="Uitleg" multiplicity="multiple" optional="true"/>
            <theory name="Theorie"/>
            <digest name="Verwerken" multiplicity="multiple"/>
            <application name="Toepassen" multiplicity="multiple" optional="true"/>
            <extra name="Practicum" multiplicity="multiple" optional="true"/>
            <test name="Testen" multiplicity="multiple" optional="true"/>
        </item-list>
    </xsl:variable>


<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/">
        <xsl:message>INSERT: ITEM: 
            <xsl:value-of select="$item"/>
        </xsl:message>
        <xsl:message>INSERT: ITEMPOS: 
            <xsl:value-of select="$itempos"/>
        </xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="componentcontent">
        <xsl:variable name="this" select="."/>
        <xsl:copy>
            <xsl:choose>
                
                <xsl:when test="not(*[name()=$item])"> <!-- if the item does not yet exist -->
                    <xsl:for-each select="$item-list/item-list/*"> <!-- loop over the item list to enforce correct order -->
                        <xsl:variable name="this-item" select="name()"/>
                        <xsl:choose>
                            <xsl:when test="name()=$item"> <!-- arrived at the item we want to insert -->
                                <xsl:apply-templates select="." mode="insert"/>
                            </xsl:when>
                            <xsl:otherwise> <!-- if not, just copy the content -->
                                <xsl:apply-templates select="$this/*[name()=$this-item]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:copy>
    </xsl:template>
    
    <!-- template to insert a new item to a series of existing siblings -->
    <xsl:template match="*[name()=$item and count(preceding-sibling::*[name()=$item])+1=number($itempos)]">
        <!-- copy siblings -->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <!-- insert new item -->
        <xsl:apply-templates select="." mode="insert"/>
    </xsl:template>
    
    <!-- template to insert new item as first of its kind -->
    <xsl:template match="*[name()=$item and count(preceding-sibling::*[name()=$item])=0 and number($itempos)=0]">
        <xsl:apply-templates select="." mode="insert"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

<!-- examples zijn anders, want opgaven komen later. Dus invoegen na <exercises> of voor <examples> -->
    <xsl:template match="theory/exercises[$item='examples' and count(preceding-sibling::examples)=number($itempos) and number($itempos)>0]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:call-template name="example-exercises"/>
    </xsl:template>
    <xsl:template match="theory/examples[$item='examples' and not(preceding-sibling::examples) and number($itempos)=0]">
        <xsl:call-template name="example-exercises"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="explanation" mode="insert">
        <xsl:call-template name="explanation"/>
    </xsl:template>
    <xsl:template name="explanation">
        <explanation>
            <include filename="{concat($subcomp,'-u*.xml')}">
                <explanation id="*">
                    <p>
                        Uitleg...
                    </p>
                </explanation>
            </include>
            <exercises>
                <include filename="{concat($subcomp,'-u*1.xml')}">
                    <exercise id='*'>
                        <multi-item>
                            <intro>
                                <p>
                                    intro...
                                </p>
                            </intro>
                            <items>
                                <item label='a' type='open'>
                                    <itemcontent>
                                        <question>
                                            <p>
                                                vraag...
                                            </p>
                                        </question>
                                    </itemcontent>
                                    <answer>
                                        <p>
                                            antwoord...
                                        </p>
                                    </answer>
                                </item>
                            </items>
                        </multi-item>
                    </exercise>

                
                </include>
            </exercises>
        </explanation>
    </xsl:template>

    <xsl:template match="introduction" mode="insert">
        <xsl:call-template name="introduction"/>
    </xsl:template>
    <xsl:template name="introduction">
        <introduction>
            <include filename="{concat($subcomp,'-in*.xml')}">
                <introduction id="*">
                    <p>
                        Inleiding...
                    </p>
                </introduction>
            </include>
        </introduction>
    </xsl:template>
    
    <xsl:template match="explore" mode="insert">
        <xsl:call-template name="explore"/>
    </xsl:template>
    <xsl:template name="explore">
        <explore>
            <include filename="{concat($subcomp,'-e*.xml')}">
                <exercise id='*'>
                    <multi-item>
                        <intro>
                            <p>
                                intro...
                            </p>
                        </intro>
                        <items>
                            <item label='a' type='open'>
                                <itemcontent>
                                    <question>
                                        <p>
                                            vraag...
                                        </p>
                                    </question>
                                </itemcontent>
                                <answer>
                                    <p>
                                        antwoord...
                                    </p>
                                </answer>
                            </item>
                        </items>
                    </multi-item>
                </exercise>
            </include>
        </explore>
    </xsl:template>

    <xsl:template match="extra" mode="insert">
        <xsl:call-template name="extra"/>
    </xsl:template>
    <xsl:template name="extra">
        <extra>
            <include filename="{concat($subcomp,'-xa*.xml')}">
                <extra id="*">
                    <p>
                        Practicum...
                    </p>
                </extra>
            </include>
        </extra>
    </xsl:template>

    <xsl:template match="application" mode="insert">
        <xsl:call-template name="application"/>
    </xsl:template>
    <xsl:template name="application">
        <application>
            <include filename="{concat($subcomp,'-a*.xml')}">
                <application id="*">
                    <p>
                        Toepassen...
                    </p>
                </application>
            </include>
            <exercises>
                <include filename="{concat($subcomp,'-a*.xml')}">
                    <exercise id='*'>
                        <multi-item>
                            <intro>
                                <p>
                                    intro...
                                </p>
                            </intro>
                            <items>
                                <item label='a' type='open'>
                                    <itemcontent>
                                        <question>
                                            <p>
                                                vraag...
                                            </p>
                                        </question>
                                    </itemcontent>
                                    <answer>
                                        <p>
                                            antwoord...
                                        </p>
                                    </answer>
                                </item>
                            </items>
                        </multi-item>
                    </exercise>
                </include>
            </exercises>
        </application>
    </xsl:template>

    <xsl:template match="test" mode="insert">
        <xsl:call-template name="test"/>
    </xsl:template>
    <xsl:template name="test">
        <test>
            <exercises>
                <include filename="{concat($subcomp,'-os*.xml')}">
                    <exercise id='*'>
                        <multi-item>
                            <intro>
                                <p>
                                    intro...
                                </p>
                            </intro>
                            <items>
                                <item label='a' type='open'>
                                    <itemcontent>
                                        <question>
                                            <p>
                                                vraag...
                                            </p>
                                        </question>
                                    </itemcontent>
                                    <answer>
                                        <p>
                                            antwoord...
                                        </p>
                                    </answer>
                                </item>
                            </items>
                        </multi-item>
                    </exercise>
                </include>
            </exercises>
        </test>
    </xsl:template>

    <xsl:template match="examples" mode="insert"/>
    <xsl:template name="example-exercises">
        <examples>
            <include filename="{concat($subcomp,'-ex*.xml')}">
                <explanation id="*">
                    <p>
                        Uitleg...
                    </p>
                </explanation>
            </include>
        </examples>
        <exercises>
            <include filename="{concat($subcomp,'-ot*.xml')}">
                    <exercise id='*'>
                        <multi-item>
                            <intro>
                                <p>
                                    intro...
                                </p>
                            </intro>
                            <items>
                                <item label='a' type='open'>
                                    <itemcontent>
                                        <question>
                                            <p>
                                                vraag...
                                            </p>
                                        </question>
                                    </itemcontent>
                                    <answer>
                                        <p>
                                            antwoord...
                                        </p>
                                    </answer>
                                </item>
                            </items>
                        </multi-item>
                    </exercise>
            </include>
        </exercises>
    </xsl:template>

</xsl:stylesheet>
