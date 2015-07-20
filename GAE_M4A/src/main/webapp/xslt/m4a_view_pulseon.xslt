<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:exsl="http://exslt.org/common"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:cals="http://www.someplace.org/cals"
                xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p1"
                xmlns:mslob="http://math4all.nl"
                xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1"
                xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2p2"
                exclude-result-prefixes="saxon cals"
                extension-element-prefixes="exsl">

    <xsl:param name="item"/>
    <xsl:param name="num"/>
    <xsl:param name="ws_id"/>   <!-- is of worksheet, if applicable -->
    <xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
    <xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
    <xsl:param name="option"/>
    <xsl:param name="parent"/>  <!-- eg.: mathunited.nl/wiskundemenu/WM_overview.html -->
    <xsl:param name="is_mobile"/>
    <xsl:param name="repo"/>
    <xsl:param name="id"/>
	<xsl:param name="component_id"/>
	<xsl:param name="component_number"/>
	<xsl:param name="component_file"/>
	<xsl:param name="component_title"/>
	<xsl:param name="component_subtitle"/>
	<xsl:param name="subcomponent_number"/>
	<xsl:param name="subcomponent_title"/>
	<xsl:param name="subcomponent_index"/>
	<xsl:param name="subcomponent_count"/>
	
    <xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
    <xsl:variable name="lang">nl</xsl:variable>
    <xsl:variable name="item-list">
        <item-list>
            <introduction name="Inleiding" optional="true"/>
            <explore name="Verkennen" optional="true"/>
            <explanation name="Uitleg" multiplicity="multiple" optional="true"/>
            <theory name="Theorie"/>
            <example name="Voorbeeld"/>
            <digest name="Verwerken" multiplicity="multiple"/>
            <application name="Toepassen" multiplicity="multiple" optional="true"/>
            <extra name="Practicum" multiplicity="multiple" optional="true"/>
            <test name="Testen" multiplicity="multiple" optional="true"/>
        </item-list>
    </xsl:variable>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for GAE (do not copy from auteurssite): -->
<!--   /////////////////////////////////////////////   -->
<xsl:variable name="host_type">GAE</xsl:variable>
<xsl:variable name="docbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="'http://mathunited.nl'"/></xsl:variable>
<xsl:variable name="prikbord-url" select="concat('/view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=prikbord-m4a')"/>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

    <xsl:variable name="cm2px" select="number(50)"/>
    <xsl:variable name="variant">m4a_view</xsl:variable>
    <xsl:variable name="arg_option">
        <xsl:choose>
            <xsl:when test="$option">&amp;option=
                <xsl:value-of select="$option"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_parent">
        <xsl:choose>
            <xsl:when test="$parent">&amp;parent=
                <xsl:value-of select="$parent"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_repo">
        <xsl:choose>
            <xsl:when test="$repo">&amp;repo=
                <xsl:value-of select="$repo"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="intraLinkPrefix">
        <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,$arg_option,$arg_parent,$arg_repo,'&amp;item=')"/>
    </xsl:variable>
    <xsl:variable name="overviewRef">
        <xsl:choose>
            <xsl:when test="$parent">
                <xsl:value-of select="concat('http://',$parent)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string('/wiskundemenu/WM_overview.html?tab=TabLeerlijn')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="_cross_ref_as_links_" select="true()"/>
    <xsl:variable name="_sheetref_as_links_" select="true()"/>

    <xsl:output method="xml" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
                indent="yes" encoding="utf-8"/>

    <xsl:include href="calstable.xslt"/>
    <xsl:include href="exercises_qti.xslt"/>
    <xsl:include href="content_qti.xslt"/>
    <xsl:include href="worksheet.xslt"/>

<!--   **************** -->
<!--   PRE PROCESS      -->
<!--   **************** -->
    <xsl:template match="/">
        <xsl:variable name="xml">
            <xsl:apply-templates mode="numbering"/>
        </xsl:variable>
        <xsl:apply-templates select="$xml" mode="process"/>
    </xsl:template>
    <xsl:template match="exercises/include" mode="numbering">
        <include>
            <xsl:attribute name="filename" select="@filename"/>
            <xsl:attribute name="num" select="1+count(preceding::explore/include)+count(preceding-sibling::include)+count(preceding::exercises/include)+count(preceding::exercises/block[@medium='web']/include)"/>
        </include>
    </xsl:template>
    <xsl:template match="exercises/block[@medium='web']/include" mode="numbering">
        <include>
            <xsl:attribute name="filename" select="@filename"/>
            <xsl:attribute name="num" select="1+count(preceding-sibling::include)+count(preceding::explore/include)+count(preceding::exercises/block[@medium='web']/include)"/>
        </include>
    </xsl:template>
    <xsl:template match="examples/include" mode="numbering">
        <include>
            <xsl:attribute name="filename" select="@filename"/>
            <xsl:attribute name="num" select="1+count(preceding::examples/include)"/>
        </include>
    </xsl:template>


    <xsl:template match="@*|node()" mode="numbering">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="numbering"/>
        </xsl:copy>
    </xsl:template>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/" mode="process" >
        <xsl:variable name="assignments">
            <xsl:choose>
                <xsl:when test="($item='example') and $num">
                    <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]" mode="assessmentItem"/>
                </xsl:when>
                <xsl:when test="$item='explanation'">
                    <xsl:choose>
                        <xsl:when test="number($num) > 1">
                            <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]" mode="assessmentItem"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]" mode="assessmentItem"/>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$item='extra'">
                    <xsl:choose>
                        <xsl:when test="number($num) > 1">
                            <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=number($num)-1]" mode="assessmentItem"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=0]" mode="assessmentItem"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not(subcomponent/componentcontent/*[name()=$item])">
                    <!-- include all items -->
                    <xsl:apply-templates select="subcomponent/componentcontent/*" mode="assessmentItem" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$item]" mode="assessmentItem" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="assessment-test">
            <mslob:file name="{concat($subcomponent_id,'.xml')}">
                <qti:assessmentTest xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd"
                identifier="{$subcomponent_id}" title="{concat($component_title,' - ', $subcomponent_title)}">
                    <qti:outcomeDeclaration identifier="SCORE" cardinality="single"
                            baseType="float">
                        <qti:defaultValue>
                            <qti:value>0</qti:value>
                        </qti:defaultValue>
                    </qti:outcomeDeclaration>
                    <qti:outcomeDeclaration identifier="PASS" cardinality="single"
                            baseType="boolean">
                        <qti:defaultValue>
                            <qti:value>false</qti:value>
                        </qti:defaultValue>
                    </qti:outcomeDeclaration>
                    <qti:outcomeDeclaration identifier="MAXSCORE"
                            cardinality="single" baseType="float">
                        <qti:defaultValue>
                            <qti:value><xsl:value-of select="count($assignments//qti:assessmentItem)"/></qti:value>
                        </qti:defaultValue>
                    </qti:outcomeDeclaration>
                    <qti:testPart identifier="testpartID" navigationMode="nonlinear" submissionMode="individual">
                        <xsl:choose>
                            <xsl:when test="($item='example') and $num">
                                <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
                            </xsl:when>
                            <xsl:when test="$item='explanation'">
                                <xsl:choose>
                                    <xsl:when test="number($num) > 1">
                                        <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]"/>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$item='extra'">
                                <xsl:choose>
                                    <xsl:when test="number($num) > 1">
                                        <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=number($num)-1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=0]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="not(subcomponent/componentcontent/*[name()=$item])">
                                <!-- include all items -->
                                <xsl:apply-templates select="subcomponent/componentcontent/*" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$item]" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </qti:testPart>
                    <qti:outcomeProcessing>
                        <qti:setOutcomeValue identifier="SCORE">
                            <qti:sum>
                                <qti:testVariables variableIdentifier="SCORE" />
                            </qti:sum>
                        </qti:setOutcomeValue>
                        <qti:outcomeCondition>
                            <qti:outcomeIf>
                                <qti:gte>
                                    <qti:sum>
                                        <qti:testVariables variableIdentifier="SCORE" />
                                    </qti:sum>
                                    <qti:baseValue baseType="float">35</qti:baseValue>
                                </qti:gte>
                                <qti:setOutcomeValue identifier="PASS">
                                    <qti:baseValue baseType="boolean">true</qti:baseValue>
                                </qti:setOutcomeValue>
                            </qti:outcomeIf>
                            <qti:outcomeElse>
                                <qti:setOutcomeValue identifier="PASS">
                                    <qti:baseValue baseType="boolean">false</qti:baseValue>
                                </qti:setOutcomeValue>
                            </qti:outcomeElse>
                        </qti:outcomeCondition>
                    </qti:outcomeProcessing>
                </qti:assessmentTest>
            </mslob:file>
        </xsl:variable>
        <mslob:root>
            <mslob:file name="imsmanifest.xml">
                <imscp:manifest xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1" xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2p2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" xsi:schemaLocation="http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd http://www.imsglobal.org/xsd/imsqti_v2p1 imsqti_v2p1.xsd http://www.imsglobal.org/xsd/imsmd_v1p2p2 imsmd_v1p2p2.xsd" 
                                identifier="manifestID">
                    <imscp:organizations />
                    <imscp:resources>
                        <imscp:resource identifier="{$subcomponent_id}" type="imsqti_assessment_xmlv2p1" href="{concat($subcomponent_id,'.xml')}">
                            <imsmd:metadata>
                                <imsmd:lom>
                                    <imsmd:general>
                                        <imsmd:identifier>
                                            <xsl:value-of select="$subcomponent_id"/>
                                        </imsmd:identifier>
                                        <imsmd:title>
                                            <imsmd:langstring>
                                                <xsl:value-of select="concat($component_title,' - ', $subcomponent_title)"/>
                                            </imsmd:langstring>
                                        </imsmd:title>
                                        <imsmd:language>nl</imsmd:language>
                                    </imsmd:general>
                                    <imsmd:lifecycle>
                                        <imsmd:contribute>
                                            <imsmd:role>
                                                <imsmd:source>
                                                    <imsmd:langstring lang="en">LOMv1.0</imsmd:langstring>
                                                </imsmd:source>
                                                <imsmd:value>
                                                    <imsmd:langstring lang="en">author</imsmd:langstring>
                                                </imsmd:value>
                                            </imsmd:role>
                                            <imsmd:entity>
                                                <imsmd:vcard>BEGIN:VCARD VERSION:3.0 N:Learn2grow; FN: Learn2grow ORG: URL: TITLE: TEL;TYPE=WORK,VOICE: ADR;TYPE=intl,postal,parcel,work:;;;;;;EMAIL;TYPE=PREF,INTERNET: END:VCARD</imsmd:vcard>
                                            </imsmd:entity>
                                        </imsmd:contribute>
                                    </imsmd:lifecycle>
                                </imsmd:lom>
                            </imsmd:metadata>
                            <imscp:file href="{concat($subcomponent_id,'.xml')}" />
                            <xsl:apply-templates select="$assessment-test" mode="imscp-dependency"/>
                            <xsl:apply-templates select="$assignments" mode="imscp-dependency"/>
                        </imscp:resource>
                        <xsl:apply-templates select="$assignments" mode="imscp-resource"/>
                    </imscp:resources>
                </imscp:manifest>
            </mslob:file>
            <xsl:apply-templates select="$assessment-test" mode="copy"/>
            <xsl:apply-templates select="$assignments" mode="copy"/>
        </mslob:root>
    </xsl:template>

    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/" mode="imscp-resource">
        <xsl:apply-templates select="mslob:file/qti:assessmentItem" mode="imscp-resource"/>
    </xsl:template>
    <xsl:template match="qti:assessmentItem" mode="imscp-resource">
        <imscp:resource identifier="{@identifier}" type="imsqti_item_xmlv2p1" 
                        href="{concat(@identifier,'.xml')}">
            <imsmd:metadata>
                <imsmd:lom>
                    <imsmd:general>
                        <imsmd:identifier>
                            <xsl:value-of select="@identifier"/>
                        </imsmd:identifier>
                        <imsmd:title>
                            <imsmd:langstring>
                                <xsl:value-of select="@title"/>
                            </imsmd:langstring>
                        </imsmd:title>
                        <imsmd:language>nl</imsmd:language>
                    </imsmd:general>
                    <imsmd:lifecycle>
                        <imsmd:contribute>
                            <imsmd:role>
                                <imsmd:source>
                                    <imsmd:langstring lang="en">LOMv1.0</imsmd:langstring>
                                </imsmd:source>
                                <imsmd:value>
                                    <imsmd:langstring lang="en">author</imsmd:langstring>
                                </imsmd:value>
                            </imsmd:role>
                            <imsmd:entity>
                                <imsmd:vcard>BEGIN:VCARD VERSION:3.0 N:Learn2grow; FN: Learn2grow ORG: URL: TITLE: TEL;TYPE=WORK,VOICE: ADR;TYPE=intl,postal,parcel,work:;;;;;;EMAIL;TYPE=PREF,INTERNET: END:VCARD</imsmd:vcard>
                            </imsmd:entity>
                        </imsmd:contribute>
                    </imsmd:lifecycle>
                </imsmd:lom>
            </imsmd:metadata>
            <imscp:file href="{concat(@identifier,'.xml')}" />
        </imscp:resource>
    </xsl:template>

    <xsl:template match="/" mode="imscp-dependency">
        <xsl:apply-templates select="mslob:file/qti:assessmentItem" mode="imscp-dependency"/>
        <xsl:apply-templates select="mslob:file/qti:assessmentTest/qti:testPart/qti:assessmentSection" mode="imscp-dependency"/>
    </xsl:template>
    <xsl:template match="qti:assessmentItem" mode="imscp-dependency">
        <imscp:dependency identifierref="{@identifier}" />
        <xsl:apply-templates mode="imscp-dependency"/>
    </xsl:template>
<!--      
    <xsl:template match="img" mode="imscp-dependency">
        <imscp:file href="{@src}" />
    </xsl:template>
    <xsl:template match="a[@class='dox']" mode="imscp-dependency">
        <imscp:file href="{@href}" />
    </xsl:template>
-->    
    <!--
    <xsl:template match="iframe[@_type='ggb']" mode="imscp-dependency">
        <imscp:file href="{@src}" />
    </xsl:template>
    -->
    <xsl:template match="*" mode="imscp-dependency">
        <xsl:apply-templates select="*" mode="imscp-dependency"/>
    </xsl:template>

    <xsl:template match="node() | @*" mode="answer">
        <xsl:apply-templates select="*" mode="answer"/>
    </xsl:template>
    <xsl:template match="item" mode="answer">
        <xsl:value-of select="@label"/>) 
        <xsl:apply-templates mode="answer"/>
    </xsl:template>
    <xsl:template match="answer" mode="answer">
        <xsl:apply-templates mode="content"/>
    </xsl:template>



<!--   ****************** -->
<!--    ASSESSMENT TEST   -->
<!--   ****************** -->
    <xsl:template match="subcomponent/componentcontent/*[name()!='theory' and name()!='extra']">
        <xsl:variable name="name" select="name()"/>
        <qti:assessmentSection identifier="{concat('section-',$subcomponent_id,'-',$name,$num)}" fixed="false" title="{$item-list/item-list/*[name()=$name]/@name}" visible="true">
            <xsl:apply-templates select="include" mode="rubric">
                <xsl:with-param name="item">
                    <xsl:value-of select="name()"/>
                </xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select=".//include" mode="link-assignments"/>
        </qti:assessmentSection>
    </xsl:template>
    <xsl:template match="subcomponent/componentcontent/extra"></xsl:template>
    <xsl:template match="subcomponent/componentcontent/theory">
        <xsl:if test="include">
            <qti:assessmentSection identifier="{concat('section-',$subcomponent_id,'-theory')}" fixed="false" title="{$item-list/item-list/theory/@name}" visible="true">
                <xsl:apply-templates select="include" mode="rubric">
                    <xsl:with-param name="item">
                        <xsl:value-of select="name()"/>
                    </xsl:with-param>
                </xsl:apply-templates>
            </qti:assessmentSection>
        </xsl:if>
        <xsl:apply-templates select="examples"/>
    </xsl:template>
    <xsl:template match="examples">
        <qti:assessmentSection identifier="{concat('section-',$subcomponent_id,'-example-',position())}" fixed="false" title="{$item-list/item-list/example/@name}" visible="true">
            <xsl:apply-templates select="include" mode="rubric">
                <xsl:with-param name="item">
                    <xsl:value-of select="name()"/>
                </xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="following-sibling::exercises[1]/include" mode="link-assignments"/>
        </qti:assessmentSection>
    </xsl:template>

    <xsl:template match="include" mode="rubric">
        <xsl:param name="item"/>
        <xsl:apply-templates select="document(concat($docbase,@filename))" mode="rubric">
            <xsl:with-param name="item" select="$item"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="include" mode="link-assignments">
        <xsl:param name="item"/>
        <xsl:if test="not(parent::block[@medium='paper'])">
            <xsl:apply-templates select="document(concat($docbase,@filename))//exercise" mode="link-assignments">
                <xsl:with-param name="item" select="$item"/>
                <xsl:with-param name="nr" select="@num"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="theory" mode="rubric">
        <qti:rubricBlock view="candidate">
            <div xmlns="">
               <xsl:apply-templates mode="content"/>
            </div>
        </qti:rubricBlock>
    </xsl:template>
        
    <xsl:template match="example | explanation | application" mode="rubric">
        <qti:rubricBlock view="candidate">
            <div xmlns="">
	            <xsl:apply-templates mode="content"/>
	        </div>
        </qti:rubricBlock>
    </xsl:template>
    <xsl:template match="*" mode="rubric"></xsl:template>
    
    <xsl:template match="exercise" mode="link-assignments">
        <xsl:variable name="asm-id" select="concat($subcomponent_id,'-',generate-id())"/>
        <qti:assessmentItemRef identifier="{$asm-id}" href="{concat($asm-id,'.xml')}" fixed="false" />
    </xsl:template>


<!--   ****************** -->
<!--    ASSESSMENT ITEM   -->
<!--   ****************** -->
    <xsl:template match="subcomponent/componentcontent/*[name()!='theory' and name()!='extra']" mode="assessmentItem">
        <xsl:variable name="name" select="name()"/>
            <xsl:apply-templates select=".//include" mode="assessmentItem">
                <xsl:with-param name="item">
                    <xsl:value-of select="name()"/>
                </xsl:with-param>
            </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="subcomponent/componentcontent/extra" mode="assessmentItem"></xsl:template>
    <xsl:template match="subcomponent/componentcontent/theory" mode="assessmentItem">
        <xsl:apply-templates select="examples" mode="assessmentItem"/>
    </xsl:template>
    <xsl:template match="examples" mode="assessmentItem">
        <xsl:apply-templates select="following-sibling::exercises[1]/include" mode="assessmentItem"/>
    </xsl:template>

    <xsl:template match="include" mode="assessmentItem">
        <xsl:param name="item"/>
        <xsl:apply-templates select="document(concat($docbase,@filename))//exercise" mode="assessmentItem">
            <xsl:with-param name="item" select="$item"/>
            <xsl:with-param name="nr" select="@num"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="exercise" mode="assessmentItem">
        <xsl:param name="item"/>
        <xsl:param name="nr"/>
        <xsl:variable name="asm-id" select="concat($subcomponent_id,'-',generate-id())"/>
        <mslob:file name="{concat($asm-id,'.xml')}">
            <xsl:apply-templates select="." mode="content">
                <xsl:with-param name="item" select="$item"/>
                <xsl:with-param name="nr" select="@num"/>
            </xsl:apply-templates>
        </mslob:file>
    </xsl:template>



<!--   ****************** -->
<!--       REMAINING      -->
<!--   ****************** -->



    <xsl:template match="title" mode="content-title">
        <xsl:apply-templates mode="content"/>
    </xsl:template>
    <xsl:template match="p">
        <xsl:apply-templates mode="content"/>
    </xsl:template>
    <xsl:template match="exercise" mode="content">
        <xsl:param name="options"/>
        <div class="exercise" xmlns="">
            <xsl:apply-templates mode="content">
                <xsl:with-param name="options" select="$options"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

<!--
    Introduction
-->
    <xsl:template match="learningaspects" mode="content">
        <p xmlns="">
            <b>Je leert in dit onderwerp:</b>
            <ul>
                <xsl:for-each select="aspect">
                    <li>
                        <xsl:apply-templates mode="content"/>
                    </li>
                </xsl:for-each>
            </ul>
        </p>
    </xsl:template>

    <xsl:template match="knownaspects" mode="content">
        <p xmlns="">
            <b>Voorkennis:</b>
            <ul>
                <xsl:for-each select="aspect">
                    <li>
                        <xsl:apply-templates mode="content"/>
                    </li>
                </xsl:for-each>
            </ul>
        </p>
    </xsl:template>

    <xsl:template match="definitions" mode="content">
        <div class="definitions" xmlns="">
            Begrippenlijst
        </div>
        <xsl:apply-templates mode="content"/>
    </xsl:template>

    <xsl:template match="definition" mode="content">
        <div class="definition" xmlns="">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',@id,'&amp;variant=',$variant,'&amp;item=theory')"/>
                </xsl:attribute>
                <xsl:apply-templates mode="content"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="activities" mode="content">
        <div class="definitions" xmlns="">
            Activiteitenlijst
        </div>
        <xsl:apply-templates mode="content"/>
    </xsl:template>

    <xsl:template match="activity" mode="content">
        <div class="definition" xmlns="">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',@id,'&amp;variant=',$variant,'&amp;item=theory')"/>
                </xsl:attribute>
                <xsl:apply-templates mode="content"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="proof" mode="content">
        <div class="m4a-example" xmlns="">
            <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; bewijs</div>
            <div class="m4a-answer">
                <xsl:apply-templates mode="content"/>
                <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
            </div>
        </div>
    </xsl:template>


    <xsl:template match='block[@medium="web"]' mode="content">
        <xsl:apply-templates mode="content"/>
    </xsl:template>

    <xsl:template match="*"/>
</xsl:stylesheet>
