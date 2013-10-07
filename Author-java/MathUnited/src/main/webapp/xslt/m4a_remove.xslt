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
<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/">
        <xsl:message>REMOVE: ITEM: 
            <xsl:value-of select="$item"/>
        </xsl:message>
        <xsl:message>REMOVE: ITEMPOS: 
            <xsl:value-of select="$itempos"/>
        </xsl:message>
        <xsl:processing-instruction name="context-directive">
            <xsl:text>job ctxfile ../m4all-leertaak.ctx</xsl:text>
        </xsl:processing-instruction> 
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[name()=$item and count(preceding-sibling::*[name()=$item])+1=number($itempos)]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="*[name()=$item and not(preceding-sibling::*[name()=$item]) and number($itempos)=0]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>

<!-- examples zijn anders, want opgaven komen later. -->
    <xsl:template match="theory/exercises[$item='examples' and count(preceding-sibling::exercises)+1=number($itempos)]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>        
    <xsl:template match="theory/exampls[$item='examples' and count(preceding-sibling::examples)+1=number($itempos)]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>        
    <xsl:template match="theory/exercises[$item='examples' and not(preceding-sibling::exercises) and number($itempos)=0]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="theory/exampls[$item='examples' and not(preceding-sibling::examples) and number($itempos)=0]">
        <xsl:for-each select=".//include">
            <remove-include filename="{@filename}"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
