<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt"
    version="1.0">
<xsl:param name="refbase"/>
<xsl:template match="/component">
    <xsl:variable name="pass">
        <index>
            <component id="{@id}">
                <xsl:apply-templates select="*" mode="collect"/>
            </component>
        </index>
    </xsl:variable>
    <xsl:variable name="pass2"><!--count exercises in exercisegroup-->
        <xsl:apply-templates select="exslt:node-set($pass)" mode="pass2"/>
    </xsl:variable>
    <xsl:variable name="pass3"><!--calc max of exercisegroup-->
        <xsl:apply-templates select="exslt:node-set($pass2)" mode="pass3"/>
    </xsl:variable>
    <xsl:variable name="pass4"><!--calc size of subcomponent-->
        <xsl:apply-templates select="exslt:node-set($pass3)" mode="pass4"/>
    </xsl:variable>
    <xsl:variable name="pass5"><!--calc size of subcomponent-->
        <xsl:apply-templates select="exslt:node-set($pass4)" mode="pass5"/>
    </xsl:variable>
    <xsl:apply-templates select="exslt:node-set($pass5)" mode="numbering"/>

<!--
<xsl:apply-templates select="$pass" mode="numbering"/>
-->
</xsl:template>

<xsl:template match="subcomponent" mode="collect">
   <subcomponent id="{@id}">
       <xsl:apply-templates mode="collect"/>
   </subcomponent>
</xsl:template>
<xsl:template match="subcomponent/file" mode="collect">
    <xsl:apply-templates select="document(concat($refbase,.))/subcomponent/*" mode="collect"/>
</xsl:template>
<xsl:template match="exercise" mode="collect">
    <exercise id="{@id}" level="{@level}"/>
</xsl:template>
<xsl:template match="exercisechoice" mode="collect">
    <xsl:copy>
        <xsl:apply-templates mode="collect"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="exercisegroup" mode="collect">
    <exercisegroup level="{@level}">
        <xsl:apply-templates mode="collect"/>
    </exercisegroup>
</xsl:template>
<xsl:template match="explore" mode="collect">
    <explore/>
</xsl:template>
<xsl:template match="introduction" mode="collect">
    <introduction/>
</xsl:template>
<xsl:template match="*" mode="collect">
    <xsl:apply-templates select="*" mode="collect"/>
</xsl:template>

<!--
//////////////////////////////////////////////////////
            PASS 2: count exercises in the groups
//////////////////////////////////////////////////////
-->

<xsl:template match="exercisegroup" mode="pass2">
    <exercisegroup level="{@level}" _size="{count(exercise)}">
        <xsl:apply-templates mode="pass2"/>
    </exercisegroup>
</xsl:template>
<xsl:template match="@*|node()" mode="pass2" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="pass2" />
    </xsl:copy>
</xsl:template>

<!--
//////////////////////////////////////////////////////
            PASS 3: calculate max of exercisegroups to determine size of exercisechoice
//////////////////////////////////////////////////////
-->

<xsl:template match="exercisechoice" mode="pass3">
    <xsl:variable name="calcMax">
        <xsl:for-each select="exercisegroup/@_size">
            <xsl:sort data-type="number" order="descending"/>
            <xsl:if test="position()=1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    <exercisechoice _size="{$calcMax}">
        <xsl:apply-templates mode="pass3"/>
    </exercisechoice>
</xsl:template>
<xsl:template match="exercisegroup" mode="pass3">
    <!-- delete the _size attribute -->
    <exercisegroup level="{@level}">
        <xsl:apply-templates mode="pass3"/>
    </exercisegroup>
</xsl:template>
<xsl:template match="@*|node()" mode="pass3" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="pass3" />
    </xsl:copy>
</xsl:template>

<!--
//////////////////////////////////////////////////////
            PASS 4: calc size of subcomponent
//////////////////////////////////////////////////////
-->

<xsl:template match="subcomponent" mode="pass4">
    <xsl:copy>
        <xsl:attribute name="_size"><xsl:value-of select="sum(./exercisechoice/@_size)+count(./exercise)"/></xsl:attribute>
        <xsl:apply-templates select="@*" mode="pass4" />
        <xsl:apply-templates mode="pass4"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="@*|node()" mode="pass4" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="pass4" />
    </xsl:copy>
</xsl:template>

<!--
//////////////////////////////////////////////////////
            PASS 5: calc base nrs
//////////////////////////////////////////////////////
-->

<xsl:template match="subcomponent" mode="pass5">
    <xsl:copy>
        <xsl:choose>
            <xsl:when test="count(following-sibling::subcomponent)=0">
                <xsl:attribute name="_base">1</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="_base"><xsl:value-of select="1+sum(preceding-sibling::subcomponent/@_size)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="@*" mode="pass5" />
        <xsl:apply-templates mode="pass5"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="exercisechoice" mode="pass5">
    <xsl:copy>
        <xsl:attribute name="_base"><xsl:value-of select="1+count(preceding-sibling::exercise)+sum(preceding-sibling::exercisechoice/@_size)+sum(preceding::subcomponent/@_size)"/></xsl:attribute>
        <xsl:apply-templates select="@*|node()" mode="pass5" />
    </xsl:copy>
</xsl:template>
<xsl:template match="@*|node()" mode="pass5" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="pass5" />
    </xsl:copy>
</xsl:template>


<!--
//////////////////////////////////////////////////////
            Numbering
//////////////////////////////////////////////////////
-->

<xsl:template match="exercise" mode="numbering">
    <xsl:copy>
        <xsl:attribute name="_nr">
            <xsl:choose>
                <xsl:when test="ancestor::exercisechoice">
                    <xsl:value-of select="sum(ancestor::exercisechoice/@_base)+count(preceding-sibling::exercise)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::subcomponent/@_base+sum(preceding-sibling::exercisechoice/@_size)+count(preceding-sibling::exercise)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="numbering"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="exercisechoice" mode="numbering">
    <xsl:copy>
        <xsl:apply-templates select="@*[name()!='_size' and name()!='_base']|node()" mode="numbering" />
    </xsl:copy>
</xsl:template>
<xsl:template match="subcomponent" mode="numbering">
    <xsl:copy>
        <xsl:attribute name="_nr"><xsl:value-of select="1+count(preceding-sibling::subcomponent)"/></xsl:attribute>
        <xsl:apply-templates select="@*[name()!='_size']|node()" mode="numbering" />
    </xsl:copy>
</xsl:template>
<xsl:template match="@*|node()" mode="numbering" >
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="numbering" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
