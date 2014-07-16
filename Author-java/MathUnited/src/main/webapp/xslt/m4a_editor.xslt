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

    <xsl:param name="item"/>
    <xsl:param name="num"/>
    <xsl:param name="ws_id"/>   <!-- is of worksheet, if applicable -->
    <xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
    <xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
    <xsl:param name="option"/>
    <xsl:param name="thread"/>
    <xsl:param name="parent"/>  <!-- eg.: mathunited.nl/wiskundemenu/WM_overview.html -->
    <xsl:param name="is_mobile"/>
    <xsl:param name="componentsURL"/>
    <xsl:param name="threadsURL"/>
    <xsl:param name="id"/>
    <xsl:param name="repo"/>
    <xsl:param name="repo-path"/>
    <xsl:param name="baserepo-path"/>
    <xsl:param name="component"/>
    <xsl:param name="dopreprocess"/>
    <xsl:param name="lock_owner"/>
    <xsl:variable name="parsed_component" select="saxon:parse($component)"/>
    <xsl:variable name="subcomponent" select="$parsed_component/component/subcomponents/subcomponent[@id=$subcomp]"/>
    <xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurssite (do not copy from GAE): -->
<!--   /////////////////////////////////////////////   -->
    <xsl:variable name="host_type">auteur</xsl:variable>
    <xsl:variable name="docbase" select="$refbase"></xsl:variable>
    <xsl:variable name="urlbase">
        <xsl:value-of select="concat('../data/',$refbase)"/>
    </xsl:variable>
    <xsl:variable name="indexDoc" select="document(concat($refbase,'../index.xml'))"/>
    <xsl:template match="subcomponent" mode="numbering">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="numbering"/>
            <internal-meta>
                <subcomponents>
                    <xsl:for-each select="$indexDoc/index/component[@id=$comp]/subcomponent">
                        <subcomponent id="{@id}" _nr="{@_nr}"/>
                    </xsl:for-each>
                </subcomponents>
            </internal-meta>
            <xsl:apply-templates mode="numbering"/>
        </xsl:copy>
    </xsl:template>
    
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

    <xsl:include href="editor/main.xslt"/>
    
    <xsl:variable name="item-list">
        <xsl:choose>
            <xsl:when test="subcomponent/componentcontent/summary">
                <item-list>
                    <summary name="Samenvatten" optional="true"/>
                    <background name="Achtergronden" optional="true"/>
                    <test name="Testen" multiplicity="multiple" min="1" max="3"/>
                    <application name="Toepassen" optional="true"/>
                    <exam name="Examenopgaven" optional="true"/>
                </item-list>
            </xsl:when>
            <xsl:otherwise>
                <item-list>
                    <introduction name="Inleiding" optional="true"/>
                    <explore name="Verkennen" optional="true"/>
                    <explanation name="Uitleg" multiplicity="multiple" min="1" max="3"/>
                    <theory name="Theorie"/>
                    <digest name="Verwerken"/>
                    <application name="Toepassen" optional="true"/>
                    <extra name="Practicum" multiplicity="multiple"/>
                    <test name="Test jezelf" multiplicity="option"/>
                </item-list>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="itemInner">
        <xsl:choose>
            <xsl:when test="string-length($id) > 0">
                <xsl:value-of select="name(subcomponent/componentcontent/*[descendant::include[@filename=concat($id,'.xml')]])"/>
            </xsl:when>
            <xsl:when test="$item=''">
                <xsl:value-of select="name(subcomponent/componentcontent/*[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$item"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cm2px" select="number(50)"/>
    <xsl:variable name="variant">m4a_editor</xsl:variable>
    <xsl:variable name="arg_option">
        <xsl:choose>
            <xsl:when test="$option">&amp;option=<xsl:value-of select="$option"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_repo">
        <xsl:choose>
            <xsl:when test="$repo">&amp;repo=<xsl:value-of select="$repo"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_parent">
        <xsl:choose>
            <xsl:when test="$parent">&amp;parent=<xsl:value-of select="$parent"/>&amp;thread=<xsl:value-of select="$thread"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="intraLinkPrefix">
        <xsl:value-of select="concat('edit?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,$arg_option,$arg_parent,$arg_repo,'&amp;item=')"/>
    </xsl:variable>
    <xsl:variable name="overviewRef">
        <xsl:choose>
            <xsl:when test="$parent">
                <xsl:value-of select="concat('http://',$parent,'&amp;thread=',$thread)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string('/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="_cross_ref_as_links_" select="true()"/>
    <xsl:variable name="_sheetref_as_links_" select="true()"/>

    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
                indent="yes" encoding="utf-8"/>



<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$dopreprocess">
                <xsl:variable name="prepare">
                    <xsl:apply-templates mode="editor-prepare"/>
                </xsl:variable>
                <xsl:variable name="xml">
                    <xsl:apply-templates select="$prepare" mode="numbering"/>
                </xsl:variable>
                <xsl:apply-templates select="$xml" mode="process"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="xml">
                    <xsl:apply-templates mode="numbering"/>
                </xsl:variable>
                <xsl:apply-templates select="$xml" mode="process"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*|node()" mode="numbering">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="numbering"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="/" mode="process">
        <xsl:choose>
            <xsl:when test="$option='editor-process-item'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="main-page"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="main-page">
        <html  xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <head>
                <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
                <script data-main="javascript/editor.js?nocache=3" src="javascript/require.js"></script>
                <link rel="stylesheet" href="css/content.css" type="text/css"/>
                <link rel="stylesheet" href="css/exercises.css?nocache=3" type="text/css"/>
                <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
                <link rel="stylesheet" href="css/editor.css" type="text/css"/>
                <link rel="stylesheet" href="javascript/lib/chosen_v1.1.0/chosen.css"/>
                <link rel="stylesheet" type="text/css" media="screen" href="/elfinder/css/elfinder.min.css"/>
            </head>
            <body>
                <div class="hidden-templates">
                    <xsl:call-template name="exercise-templates"/>
                </div>
                <div id="meta-data-container" style="display:none">
                    <span id="meta-data-comp"><xsl:value-of select="$comp"/></span>
                    <span id="meta-data-subcomp"><xsl:value-of select="$subcomp"/></span>
                    <span id="meta-data-variant"><xsl:value-of select="$variant"/></span>
                    <span id="meta-data-refbase"><xsl:value-of select="$refbase"/></span>
                    <span id="meta-data-repo-path"><xsl:value-of select="$repo-path"/></span>
                    <span id="meta-data-baserepo-path"><xsl:value-of select="$baserepo-path"/></span>
                    <span id="meta-components-url"><xsl:value-of select="$componentsURL"/></span>
                    <span id="meta-threads-url"><xsl:value-of select="$threadsURL"/></span>
                </div>
                <div style="display:none">
                    <div id="dialog-remove-item-confirm" title="Item verwijderen?">
                        <p>
                            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>Weet u zeker dat u dit item wilt verwijderen?
                        </p>
                    </div>
        
                </div>
                <div class="editorDiv">
                    <div id="startup-msg">
                        <h3>Even geduld aub...</h3><p></p>
                    </div>
                    <div class="headingDiv">
                        <div class="headingContentDiv">
                            <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
                            <xsl:if test="$is_mobile='true'">
                                (m)
                            </xsl:if>
                            <xsl:value-of select="$parsed_component/component/title"/> &gt; 
                            <xsl:value-of select="$subcomponent/title"/>
                        </div>
                        <div id="show-backups-wrapper">backups</div>
                        <div class="overzichtDiv">
                            <a href="{$overviewRef}" class="_warn_if_doc_changed_">
                                Overzicht
                            </a>
                        </div>
                        <div style="clear:both"/>
                    </div>
                    <div class="sectionDiv">
                        <div class="balk">
                            <xsl:call-template name="list-section-nrs">
                                <xsl:with-param name="i"><xsl:value-of select="number(1)"/></xsl:with-param>
                                <xsl:with-param name="count"><xsl:value-of select="count($parsed_component/component/subcomponents/subcomponent)"/></xsl:with-param>
                                <xsl:with-param name="highlight"><xsl:value-of select="1+count($subcomponent/preceding-sibling::subcomponent)"/></xsl:with-param>
                                <xsl:with-param name="subcomponents" select="subcomponent/internal-meta/subcomponents"/>
                            </xsl:call-template>
                            <span class="subcomponent-title">
                                <xsl:value-of select="$subcomponent/title"/> 
                            </span>
                            <span class="subcomponent-id">
                                <xsl:value-of select="$subcomponent/@id"/>
                            </span>
                        </div>
                    </div>

                    <xsl:variable name="lockstatus">
                        <xsl:choose>
                            <xsl:when test="not(/subcomponent/@status) or /subcomponent/@status='bewerking'"></xsl:when>
                            <xsl:when test="/subcomponent/@status='auteur_gereed'"></xsl:when>
                            <xsl:when test="/subcomponent/@status='coauteur_gereed'"></xsl:when>
                            <xsl:otherwise>lock</xsl:otherwise>
                    </xsl:choose>
                    </xsl:variable>

                    <div class="contentDiv">
                        <div class="contentDiv-content">
                            <xsl:apply-templates select="*"/>
                        </div>
                        <div style="clear:both"/>
                        <xsl:if test="$lock_owner">
                            <div id="locked-message">
                                Het is nu niet mogelijk deze paragraaf te bewerken, omdat deze 
                                momenteel bewerkt wordt door de auteur met username '<xsl:value-of select="$lock_owner"/>'.
                            </div>
                        </xsl:if>
                        <xsl:if test="$lockstatus='lock'">
                            <div id="locked-message">
                                Het is niet meer mogelijk deze paragraaf te bewerken via de auteurstool. Indien u toch 
                                nog een wijziging wilt (laten) uitvoeren, neem dan contact op met Meyke Bos.
                            </div>
                        </xsl:if> 
                    </div>
                    
                    <xsl:if test="not(string-length($lock_owner)>0) and not($lockstatus='lock')">
                      <div class="footer">
                        <div id="commit-button">
                            <div id="commit-button-image"/>
                            <p>Opslaan</p>
                        </div>
                        <div id="workflow-container">
                            <div class="workflow-item"><input type="radio" name="workflow" value="bewerking">
                                <xsl:if test="not(/subcomponent/@status) or /subcomponent/@status='bewerking'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>In bewerking</span>
                            </div>
                            <div class="workflow-item"><input type="radio" name="workflow" value="auteur_gereed">
                                <xsl:if test="/subcomponent/@status='auteur_gereed'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>Auteur gereed</span>
                            </div>
                            <div class="workflow-item"><input type="radio" name="workflow" value="coauteur_gereed">
                                <xsl:if test="/subcomponent/@status='coauteur_gereed'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>Co-auteur gereed</span>
                            </div>
                            <div class="workflow-item"><input type="radio" name="workflow" value="assets_gereed">
                                <xsl:if test="/subcomponent/@status='assets_gereed'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>Assets gereed</span>
                            </div>
                            <div class="workflow-item"><input type="radio" name="workflow" value="eindredactie_gereed">
                                <xsl:if test="/subcomponent/@status='eindredactie_gereed'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>Eindredactie gereed</span>
                            </div>
                            <div class="workflow-item"><input type="radio" name="workflow" value="productie_gereed">
                                <xsl:if test="/subcomponent/@status='productie_gereed'"><xsl:attribute name="checked" select="checked"/></xsl:if>
                                </input>
                                <span>Klaar voor productie</span>
                            </div>
                        </div>
                        <div style="clear:both"/>
                      </div>
                    </xsl:if>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="list-section-nrs">
        <xsl:param name="i"/>
        <xsl:param name="count"/>
        <xsl:param name="highlight"/>
        <xsl:param name="subcomponents"/>
        <xsl:choose>
            <xsl:when test="number($i) = number($highlight)">
                <span class="list-section-nr highlight"><xsl:value-of select="$i"/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="list-section-nr">
                    <a class="_warn_if_doc_changed_">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('edit?comp=',$comp,'&amp;subcomp=',$subcomponents/subcomponent[number(@_nr)=$i]/@id,'&amp;variant=',$variant,$arg_parent,$arg_repo,'&amp;thread=',$thread)"/>
                        </xsl:attribute>
                        <xsl:value-of select="$i"/>
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="number($count) > number($i)">
            <xsl:call-template name="list-section-nrs">
               <xsl:with-param name="i"><xsl:value-of select="$i+1"/></xsl:with-param>
               <xsl:with-param name="count"><xsl:value-of select="$count"/></xsl:with-param>
               <xsl:with-param name="highlight"><xsl:value-of select="$highlight"/></xsl:with-param>
               <xsl:with-param name="subcomponents" select="$subcomponents"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>



    <xsl:template match="subcomponent">
        <div tag="subcomponent">
            <xsl:apply-templates select="@*" mode="editor"/>
            <xsl:apply-templates select="metadata" mode="editor"/>
            <xsl:apply-templates select="description" mode="editor"/>
            <div tag="componentcontent"><!--using for-each to set scope, though there can be only one -->
                <xsl:for-each select="componentcontent">
                    <xsl:call-template name="display-items-template"/>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="display-items-template">
        <xsl:variable name="this" select="."/>
        <xsl:for-each select="$item-list/item-list/*">
            <xsl:variable name="item" select="."/>
            <xsl:choose>
                <xsl:when test="$this/*[name()=$item/name()]">
                    <!-- item exists -->
                    <xsl:for-each select="$this/*[name()=$item/name()]">
                        <div class="_editor_context_base">
                            <xsl:choose>
                                <xsl:when test="$item/@multiplicity='multiple'">
                                    <div class="_editor_option" type="repeat" function="actions/OptionalContentItem" name="{$item/@name}">
                                        <xsl:attribute name="params">{item: '<xsl:value-of select="$item/name()"/>'}</xsl:attribute>
                                        <xsl:if test="$item/@min">
                                            <xsl:attribute name="min">
                                                <xsl:value-of select="$item/@min"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="$item/@max">
                                            <xsl:attribute name="max">
                                                <xsl:value-of select="$item/@max"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </xsl:when>
                                <xsl:when test="$item/@optional='true'">
                                    <div class="_editor_option" type="optional" function="actions/OptionalContentItem" name="{$item/@name}">
                                        <xsl:attribute name="params">{item: '<xsl:value-of select="$item/name()"/>'}</xsl:attribute>
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <div class="m4a-editor-item nonexistent">
                                <div class="menu-button-div section-button">
                                    <span class="menu-button"></span>
                                </div>
                                <div class="m4a-editor-item-title nonexistent">
                                    <xsl:value-of select="$item/@name"/>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- item does not exist yet -->
                    <div class="_editor_context_base">
                        <div class="_editor_option" type="optional" function="actions/OptionalContentItem" name="{$item/@name}">
                             <xsl:attribute name="params">{item: '<xsl:value-of select="$item/name()"/>'}</xsl:attribute>
                        </div>
                        <div class="m4a-editor-item nonexistent visible">
                            <div class="menu-button-div section-button">
                                <span class="menu-button"></span>
                            </div>
                            <div class="m4a-editor-item-title nonexistent">
                                <xsl:value-of select="$item/@name"/>
                            </div>
                        </div>
                    </div>                                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="subcomponent/description" mode="editor">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Metadata<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:choose>
                        <!-- je kunt geen leerdoelen aanpassen of aanmaken bij Totaalbeeld -->
                        <!-- die worden door Javascript opgehaald door de server uit de andere paragrafen -->
                        <xsl:when test="/subcomponent/componentcontent/summary">
                            <b>Leerdoelen</b>
                            <div class="objective-wrapper load-objectives">
                                <!-- will be filled by javascript -->
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="editor"/>
                            <xsl:if test='not(objectives)'>
                                <xsl:call-template name="objectives-handler"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="description/objectives" mode="editor">
        <xsl:call-template name="objectives-handler"/>
    </xsl:template>
    
    <xsl:template name="objectives-handler">
        <div tag="objectives">
            <b>Leerdoelen</b>
            <xsl:for-each select="objective">
                <div class="objective-wrapper">
                    <input class="objective-input" type="text" value="{text()}"/>
                    <div tag="objective" id="{@id}">
                        <xsl:value-of select="text()"/>
                    </div>
                    <div class="objective-remove-button"/>
                    <div style="clear:both"/>
                </div>
            </xsl:for-each>
            <div class="objective-new-item">
                <input type="text" size="120"/>
                <div class="objective-add-button"/>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="include">
        <xsl:apply-templates select="." mode="editor"/>
    </xsl:template>

    <xsl:template match="explore">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verkennen<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <div class="item-container shift-item-anchor"/> <!-- dummy shift-container that marks beginning of 'exercises' section. Should not move -->
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="introduction">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Inleiding<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="explanation">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Uitleg<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="context">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Context<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="theory">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <xsl:if test="include">
                <div class="m4a-editor-item-container">
                    <div class="m4a-editor-item-title">Theorie<div class="item-label-button"/></div>
                    <div class="m4a-editor-item-content">
                        <xsl:apply-templates select="include" mode="editor"/>
                    </div>
                    <div style="clear:both"/>
                </div>
            </xsl:if>
                        
            <xsl:for-each select="examples">
                    <xsl:apply-templates select="."/>
            </xsl:for-each>
            <div class="m4a-editor-item nonexistent">
                <div class="menu-button-div section-button">
                    <span class="menu-button"></span>
                </div>
                <div class="m4a-editor-item-title nonexistent">
                    <xsl:value-of select="Voorbeeld"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="examples">
        <xsl:variable name="num" select="count(preceding-sibling::examples)+1"/>
        <xsl:variable name="header">
            <xsl:choose>
                <!-- if example was just created, there is not a number yet -->
                <xsl:when test="$option='editor-process-item'">(nieuw)</xsl:when>
                <xsl:otherwise><xsl:value-of select="$num"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="_editor_context_base">
            <div class="_editor_option" type="repeat" function="actions/OptionalMenuItem" name="Voorbeeld">
                <xsl:attribute name="params">{item: 'examples'}</xsl:attribute>
            </div>
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Voorbeeld <xsl:value-of select="$header"/>
                    <div class="item-label-button"/>
                </div>
                <div class="m4a-editor-item-content">
                    <div tag="examples">
                        <xsl:apply-templates select="include" mode="editor"/>
                    </div>
                    <xsl:apply-templates select="../exercises[position()=$num]" mode="editor"/>
                </div>
            </div>
            <div style="clear:both"/>
        </div>
    </xsl:template>
    <!-- skip loose exercises-tag. Applicable when inserting a snippet of xml from the editor -->
    <xsl:template match="exercises"></xsl:template>
    
    <xsl:template match="digest">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verwerken<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="application">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Toepassing<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="extra">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Practicum<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="test">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Test jezelf<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="summary">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Samenvatten<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="background">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Achtergronden<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>

        
    <xsl:template match="exam">
        <div tag="{name()}">
            <div class="menu-button-div section-button">
                <span class="menu-button"></span>
            </div>
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Examenopgaven <div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
        </div>
    </xsl:template>


    <xsl:template match="examplesolution" mode="editor">
        <div tag="{name()}">
            <xsl:if test="count(node())>0">
                <div class="example-answer-button">&gt; antwoord</div>
                <div class="example-answer-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="exercise">
        <xsl:apply-templates select="." mode="editor"/>
    </xsl:template>
    <xsl:template match="p | xhtml:p">
        <xsl:apply-templates select="." mode="paragraph"/>
    </xsl:template>


</xsl:stylesheet>
