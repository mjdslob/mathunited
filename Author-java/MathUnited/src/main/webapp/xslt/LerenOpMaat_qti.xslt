<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="exnum"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="comp"/>
<xsl:param name="component_title"/>
<xsl:param name="subcomponent_title"/>
<xsl:param name="subcomponent_next_id"/>
<xsl:param name="subcomponent_prev_id"/>
<xsl:param name="subcomponent_index"/>
<xsl:param name="num_of_subcomponents"/>
<xsl:param name="subcomp"/>
<xsl:param name="is_mobile"/>
<xsl:param name="viewer"/>
<xsl:param name="id"/>
<xsl:param name="parttype"/>
<xsl:param name="exsubnum"/>
<xsl:variable name="itemInner">
    <xsl:choose>
        <xsl:when test="string-length($id) gt 0"><xsl:value-of select="name(subcomponent/componentcontent/*[include[@filename=concat($id,'.xml')]])"/></xsl:when>
        <xsl:when test="$item=''"><xsl:value-of select="name(subcomponent/componentcontent/*[1])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="variant">basis</xsl:variable>
<xsl:variable name="intraLinkPrefix" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=')"/>
<xsl:variable name="urlbase"><xsl:value-of select="concat('/data/',$refbase)"/></xsl:variable>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>
<xsl:variable name="title">
    <xsl:choose>
        <xsl:when test="$itemInner='explore'">Verkennen</xsl:when>
        <xsl:when test="$itemInner='introduction'">Inleiding</xsl:when>
        <xsl:when test="$itemInner='theory'">Theorie</xsl:when>
        <xsl:when test="$itemInner='explanation'">Uitleg</xsl:when>
        <xsl:when test="$itemInner='example'">Voorbeeld</xsl:when>
        <xsl:when test="$itemInner='digest'">Verwerken</xsl:when>
        <xsl:when test="$itemInner='application'">Toepassen</xsl:when>
        <xsl:otherwise>?Title?</xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="main_identifier">AT-40eebdac-a58d-42e2-8c52-660eea5abd49</xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="false()"/>

<xsl:output method="xml" indent="yes" encoding="utf-8"/>

<xsl:include href="calstable.xslt"/>
<!--<xsl:include href="exercises.xslt"/>-->
<xsl:include href="content.xslt"/>
<xsl:include href="worksheet.xslt"/>

<xsl:template match="/">
    <xsl:choose>
        <xsl:when test="$itemInner='example'">
            <!--
            <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
            -->
            <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"/>
        </xsl:when>
        <xsl:when test="$itemInner='explanation'">
            <xsl:choose>
                <xsl:when test="number($num) gt 1">
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:when>
        <xsl:when test="$itemInner='answers'">
            <h2>Antwoorden van de opgaven</h2>
            <xsl:apply-templates select="subcomponent/componentcontent/explore | subcomponent/componentcontent//exercises">
                <xsl:with-param name="options">
                    <options>
                       <mode type="answers"/>
                    </options>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$itemInner]" />
        </xsl:otherwise>
    </xsl:choose>    
</xsl:template>

<!--   **************** -->
<!--    CONTENT TYPES   -->
<!--   **************** -->
<xsl:template match="introduction">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="explanation">
    <xsl:apply-templates select="exercises/include[position()=number($exnum)]">
        <xsl:with-param name="uitleg">
            <xsl:apply-templates select="document(concat($refbase,include/@filename))/explanation" mode="content"/>
        </xsl:with-param>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="theory">
    <xsl:apply-templates select="exercises/include[position()=number($exnum)]">
        <xsl:with-param name="uitleg">
            <xsl:apply-templates select="document(concat($refbase,examples[position()=number($exnum)]/include/@filename))/example" mode="content"/>
        </xsl:with-param>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="componentcontent/examples">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="componentcontent/theory/examples">
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>

<xsl:template match="digest">
    <xsl:apply-templates select="exercises/include[position()=number($exnum)]"/>
</xsl:template>
<xsl:template match="application">
    <xsl:apply-templates select="exercises/include">
        <xsl:with-param name="uitleg">
            <xsl:apply-templates select="*[name()!='exercises']"/>
        </xsl:with-param>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="extra">
    <xsl:choose>
        <xsl:when test="$num">
            <xsl:variable name="cont" select = "document(concat($refbase,include[position()=number($num)]/@filename))"/>
            <xsl:apply-templates select="$cont" mode="content"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="summary">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="test">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="background"></xsl:template>

<xsl:template match="explore/include">
    <xsl:param name="options"/>
    <xsl:if test="1+count(preceding-sibling::include)=number($exnum)">
        <xsl:apply-templates select="document(concat($refbase,@filename))/exercise"/>
    </xsl:if>
</xsl:template>
<xsl:template match="exercises/include">
    <xsl:param name="options"/>
    <xsl:param name="uitleg"/>
    <xsl:if test="1+count(preceding-sibling::include)=number($exnum)">
        <xsl:apply-templates select="document(concat($refbase,@filename))/exercise">
            <xsl:with-param name="uitleg" select="$uitleg"/>
        </xsl:apply-templates>
    </xsl:if>
</xsl:template>
<xsl:template match="include">
    <xsl:param name="options"/>
    <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content"/>
</xsl:template>

<!--   *********************** -->
<!--    CREATE QTI EXERCISES   -->
<!--   *********************** -->
<xsl:template match="exercise">
    <xsl:param name="uitleg"/>
    <xsl:choose>
       <xsl:when test="$parttype='assessmentTest'">
            <assessmentTest xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd" identifier="{$main_identifier}" title="{$title}">
            <outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float" />
            <testPart navigationMode="nonlinear" submissionMode="simultaneous">
                <xsl:attribute name="identifier">TP-<xsl:value-of select="generate-id()"/></xsl:attribute>
                <xsl:apply-templates select="multi-item"/>
                <xsl:apply-templates select="single-item"/>
            </testPart>
            <outcomeProcessing>
                <setOutcomeValue identifier="SCORE">
                <sum>
                    <testVariables variableIdentifier="SCORE" />
                </sum>
                </setOutcomeValue>
            </outcomeProcessing>
            <testFeedback access="atEnd" showHide="hide" outcomeIdentifier="outcomeIdentifier" identifier="outcomeValue" title="Detailed Breakdown">
                <p>The test is now complete. The following table shows a breakdown of your scores:</p>
                <table>
                <tbody>
                    <tr>
                    <td>The total score:</td>
                    <td>
                        <printedVariable identifier="SCORE" />
                    </td>
                    </tr>
                </tbody>
                </table>
            </testFeedback>
            </assessmentTest>
       </xsl:when>
       <xsl:otherwise>
            <xsl:apply-templates select="multi-item/items/item[number($exsubnum)]" mode="assessmentItem">
                <xsl:with-param name="uitleg" select="$uitleg"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="single-item/item" mode="assessmentItem">
                <xsl:with-param name="uitleg" select="$uitleg"/>
            </xsl:apply-templates>
       </xsl:otherwise>
    </xsl:choose>
        
</xsl:template>

<xsl:template match="multi-item">
    <assessmentSection required="false" fixed="false" title="" visible="true" keepTogether="true">
      <xsl:attribute name="identifier">AS-<xsl:value-of select="generate-id()"/></xsl:attribute>
      <selection withReplacement="false">
         <xsl:attribute name="select"><xsl:value-of select="count(items/item)"/></xsl:attribute>
      </selection>
      <ordering shuffle="true" />
      <xsl:for-each select="items/item">
          <assessmentItemRef>
              <xsl:attribute name="identifier">AIR-<xsl:value-of select="concat($subcomp,'-',$itemInner,'-',$num,'-',$exnum,'-',position())"/></xsl:attribute>
              <xsl:attribute name="href"><xsl:value-of select="concat($subcomp,'/',$itemInner,'/',$num,'-',$exnum,'-',position(),'.xml')"/></xsl:attribute>
          </assessmentItemRef>
      </xsl:for-each>
    </assessmentSection>
</xsl:template>

<xsl:template match="single-item">
    <assessmentSection required="false" fixed="false" title="" visible="true" keepTogether="true">
      <xsl:attribute name="identifier">AS-<xsl:value-of select="generate-id()"/></xsl:attribute>
      <selection withReplacement="false" select="1"/>
      <ordering shuffle="true" />
      <xsl:for-each select="item">
          <assessmentItemRef>
              <xsl:attribute name="identifier">AIR-<xsl:value-of select="concat($subcomp,'-',$itemInner,'-',$num,'-',$exnum)"/></xsl:attribute>
              <xsl:attribute name="href"><xsl:value-of select="concat($subcomp,'/',$itemInner,'/',$num,'-',$exnum,'.xml')"/></xsl:attribute>
          </assessmentItemRef>
      </xsl:for-each>
    </assessmentSection>
</xsl:template>

<xsl:template match="item" mode="assessmentItem">
    <xsl:param name="uitleg"/>
    <assessmentItem xmlns="http://www.imsglobal.org/xsd/imsqti_v2p0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p0 imsqti_v2p0.xsd" adaptive="false" timeDependent="false">
       <xsl:attribute name="identifier">AI-<xsl:value-of select="concat($subcomp,'-',$itemInner,'-',$num,'-',$exnum,'-',$exsubnum)"/></xsl:attribute>
       <xsl:attribute name="title">Vraag <xsl:value-of select="position()"/></xsl:attribute>
       <outcomeDeclaration identifier="ANSWER" cardinality="single" baseType="string" />
       <responseDeclaration identifier="RESPONSE" cardinality="single" baseType="string">  
          <correctResponse>
                <value>
                    <xsl:apply-templates select="answer" mode="assessmentItem"/>
                </value>
          </correctResponse>
       </responseDeclaration>
       <itemBody class="openQuestion">
          <extendedTextInteraction responseIdentifier="RESPONSE">
          <prompt>
            <link type="text/css" href="http://www.mathunited.nl/MathUnited/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet"/>
            <script type="text/javascript" src="http://www.mathunited.nl/MathUnited/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
            <script type="text/javascript" src="http://www.mathunited.nl/MathUnited/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
            <link rel="stylesheet" href="http://www.mathunited.nl/MathUnited/css/grid.css" type="text/css"/>
            <script type="text/x-mathjax-config">
                MathJax.Hub.Config({
                        extensions: ["mml2jax.js","asciimath2jax.js"],
                        config : ["MMLorHTML.js" ],
                        AsciiMath: {
                            decimal: ","
                        },
                        jax: ["input/MathML","input/AsciiMath"]
                });
            </script>
              <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AM_CHTML&amp;delayStartupUntil=configured" />
              <xsl:if test="$uitleg">
                <xsl:apply-templates select="$uitleg" mode="copy"/>
            </xsl:if>
            <xsl:apply-templates select="../../intro" mode="assessmentItem"/>
            <xsl:apply-templates select="itemcontent/question" mode="assessmentItem"/>
          </prompt>
          </extendedTextInteraction>
      </itemBody>
      <responseProcessing>
         <setOutcomeValue identifier="ANSWER">
         <variable identifier="RESPONSE" />
         </setOutcomeValue>
      </responseProcessing>
    </assessmentItem>
</xsl:template>

<xsl:template match="@*|node()" mode="copy">
    <xsl:copy>
        <xsl:apply-templates  select="@*|node()" mode="copy"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="question" mode="assessmentItem">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<xsl:template match="answer" mode="assessmentItem">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="intro" mode="assessmentItem">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<xsl:template match="textref" mode="content">
    <xsl:choose>
        <xsl:when test="@ref">
            <span class="textref" ref="{@ref}"><xsl:value-of select="."/></span>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="_comp">
                <xsl:choose>
                    <xsl:when test="@comp"><xsl:value-of select="@comp"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$comp"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="_subcomp">
                <xsl:choose>
                    <xsl:when test="@subcomp"><xsl:value-of select="@subcomp"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$subcomp"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$_cross_ref_as_links_">
                    <a>
                        <xsl:attribute name="href"><xsl:value-of select="concat($viewer,'?comp=',$_comp,'&amp;subcomp=',$_subcomp,'&amp;variant=',$variant,'&amp;id=', @item)"/></xsl:attribute>
                        <xsl:value-of select="."/>

                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span class="textref">
                        <xsl:value-of select="."/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match='block[@medium!="web"]'></xsl:template>
<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<xsl:template match="*">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="*" mode="assessmentItem">
    <xsl:apply-templates mode="assessmentItem"/>
</xsl:template>

</xsl:stylesheet>
