<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:mulom="http://www.mathunited.nl/nl-lom"
xmlns:saxon="http://saxon.sf.net/"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="option"/>
<xsl:param name="is_mobile"/>
<xsl:param name="id"/>
<xsl:param name="repo"/>
<xsl:param name="repo-path"/>
<xsl:param name="baserepo-path"/>
<xsl:param name="userid"/>
<xsl:param name="username" />
<xsl:param name="registered" />
<xsl:param name="viewid"/>
<xsl:param name="threadid"/>
    
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="menu_color" select="assignments/meta/param[@name='menu-color']"/>
<xsl:variable name="cssfile">basis_studiovo.css?v=32</xsl:variable>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>
<xsl:variable name="lang">nl</xsl:variable>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for GAE (do not copy from auteurssite): -->
<!--   /////////////////////////////////////////////   -->
<xsl:variable name="host_type">GAE</xsl:variable>
<xsl:variable name="docbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('http://mathunited.pragma-ade.nl:41080/data/',$refbase)"/></xsl:variable>
<xsl:variable name="urlprefix">/</xsl:variable>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:output method="html" indent="yes" encoding="utf-8"/>

<xsl:template match="/">
<html>
<head>
   <xsl:choose>
      <!--  subtitle difference in references: leading slash or not -->
      <xsl:when test="$host_type='GAE'">
        <link type="text/css" href="/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js" />
        <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js" />
        <script type="text/javascript" src="/javascript/MathUnited.js"/>
        <script type="text/javascript" src="/javascript/MathUnited_studiovo.js?v=2"/>
		<script type="text/javascript" src="/javascript/jquery.ba-postmessage.js"/>
        <link rel="stylesheet" href="/css/content.css" type="text/css"/>
        <link rel="stylesheet" type="text/css">
	        <xsl:attribute name="href">/css/<xsl:value-of select="$cssfile"/></xsl:attribute>
        </link>
      </xsl:when>
      <xsl:otherwise>
        <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js" />
        <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js" />
        <script type="text/javascript" src="javascript/MathUnited.js"/>
        <script type="text/javascript" src="javascript/MathUnited_studiovo.js?v=2"/>
		<script type="text/javascript" src="javascript/jquery.ba-postmessage.js"/>
        <link rel="stylesheet" href="css/content.css" type="text/css"/>
		<link rel="stylesheet" type="text/css">
			<xsl:attribute name="href">css/<xsl:value-of select="$cssfile"/></xsl:attribute>
		</link>
      </xsl:otherwise>
   </xsl:choose>
</head>
<body class="result-page">
	<xsl:choose>
		<xsl:when test="$userid">
			<xsl:if test="$registered=1">
				<div class="settings-button"><a href="{$urlprefix}viewclasses.jsp?userid={$userid}&amp;repo={$repo}&amp;threadid={$threadid}"><span class="hover-text">Mijn profiel</span>&#160;<div class="icon"></div></a></div>
			</xsl:if>
			<h3>Voortgang <xsl:value-of select="$username"/></h3>
        	<table class="layout-table">
        		<tr>
        			<td class="leftcontent">
			        	<table class="grouplist">
			            	<xsl:apply-templates select="assignments/group" mode="grouplist"/>
			        	</table>
        			</td>
        			<td class="column-spacer"></td>
        			<td class="rightcontent">
		            	<xsl:apply-templates select="assignments/group" mode="group"/>
		            	<!--  tr class="totals">
			            	<td class="title">Totalen:</td>
			            	<td class="score"><xsl:value-of select="/assignments/@uniqueScore" />/<xsl:value-of select="/assignments/@uniqueTotal" /></td>
		            	</tr -->
        			</td>
        		</tr>
        	</table>
        	<xsl:if test="not($viewid='')">
			<a class="back-button" href="javascript:window.history.go(-1)">&lt; Terug</a>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<h2>Niet ingelogd</h2>
			<p>Je moet ingelogd zijn om je voortgang te bekijken. Log in door rechtsboven deze pagina op "Login" te klikken.</p>
		</xsl:otherwise>
	</xsl:choose>
	
</body>
</html>	
</xsl:template>

<xsl:template match="mulom:*"/>
<xsl:template match="mulom:*" mode="content"/>
<!--   **************** -->
<!--    NAVIGATION   -->
<!--   **************** -->
<xsl:template match="fragment" mode="navigation">
    <xsl:variable name="pos" select="position()"/>
    <div class="menu-hierarchy">
        <div class="menu-item" onclick="javascript:SVO_triggerMenuItem(this)">
            <xsl:if test="not(@education='false') and (count(../fragment) &gt; 1)">
                <xsl:value-of select="('A','B','C','D','E','F','G','H','I','J','K','L','M','N')[$pos]"/>&#160;
            </xsl:if>
            <xsl:value-of select="title"/>
        </div>
        <xsl:apply-templates select="*" mode="navigation">
            <xsl:with-param name="menuref" select="concat('explore-',$pos)"></xsl:with-param>
        </xsl:apply-templates>
    </div>
</xsl:template>

<!-- explore, exercises can be remove -->
<xsl:template match="explore" mode="navigation">
    <xsl:variable name="pos" select="position()"/>
    <div class="menu-hierarchy">
        <div class="menu-item" onclick="javascript:SVO_triggerMenuItem(this)">
            <xsl:value-of select="('A','B','C','D','E')[$pos]"/>&#160;
            <xsl:value-of select="title"/>
        </div>
        <xsl:apply-templates select="*" mode="navigation">
            <xsl:with-param name="menuref" select="concat('explore-',$pos)"></xsl:with-param>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="exercises" mode="navigation">
    <xsl:variable name="pos" select="position()"/>
    <div class="menu-hierarchy">
        <div class="menu-item" onclick="javascript:SVO_triggerMenuItem(this)">
            <xsl:value-of select="('A','B','C','D','E')[$pos]"/>&#160;
            <xsl:value-of select="title"/>
        </div>
        <xsl:apply-templates select="*" mode="navigation">
            <xsl:with-param name="menuref" select="concat('exercises-',$pos)"></xsl:with-param>
        </xsl:apply-templates>
    </div>
</xsl:template>
<xsl:template match="digest" mode="navigation">
    <xsl:variable name="pos" select="position()"/>
    <div class="menu-hierarchy">
        <div class="menu-item" onclick="javascript:SVO_triggerMenuItem(this)">
            <xsl:value-of select="('A','B','C','D','E')[$pos]"/>&#160;
            <xsl:value-of select="title"/>
        </div>
        <xsl:apply-templates select="*" mode="navigation">
            <xsl:with-param name="menuref" select="concat('digest-',$pos)"></xsl:with-param>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="block | exercise" mode="navigation">
    <xsl:param name="menuref"/>
    <div class="submenu-item" id="{concat($menuref,'-',position())}"  
            tabid="{concat('tab-',$menuref,'-',position())}" onclick="javascript:SVO_triggerSubMenuItem(this)">
        <xsl:if test="count(../*) &lt; 3">
            <!-- if there is only one submenu, hide it in css but keep its functionality (so still render it) -->
            <xsl:attribute name="style">
                display:none;
            </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="title"/>
    </div>
</xsl:template>


<!--  ******************* -->
<!--   CONTENT STRUCTURE  -->
<!--  ******************* -->
<xsl:template match="fragment">
    <xsl:apply-templates select="*">
        <xsl:with-param name="menuref" select="concat('explore-',position())"/>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="explore">
    <xsl:apply-templates select="*">
        <xsl:with-param name="menuref" select="concat('explore-',position())"/>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="exercises">
    <xsl:apply-templates select="*">
        <xsl:with-param name="menuref" select="concat('exercises-',position())"/>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="digest">
    <xsl:apply-templates select="*">
        <xsl:with-param name="menuref" select="concat('digest-',position())"/>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="block">
    <xsl:param name="menuref"/>
    <div class="content-tab" id="{concat('tab-',$menuref,'-',position())}">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<!--xsl:template match="block" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template-->
<xsl:template match="block/title" mode="content"></xsl:template>
<xsl:template match="include" mode="content">
    <xsl:apply-templates select="document(concat($docbase,@filename))" mode="content"/>
</xsl:template>

<xsl:template match="p">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="pages" mode="content">
    <div class="pages-container">
        <xsl:apply-templates select="page" mode="content"/>
    </div>
</xsl:template>

<xsl:template match="group" mode="grouplist">
	<tr>
		<td class="title" id="{translate(@title,' ','_')}" onclick="$('.group.level-1').hide(); $('#{translate(@title,' ','_')}.group.level-1').show(100); $('.grouplist .title').removeClass('selected'); $('.grouplist #{translate(@title,' ','_')}').addClass('selected')"><xsl:value-of select="@title" /></td>
	</tr>
</xsl:template>

<xsl:template match="group" mode="group">
	<div id="{translate(@title,' ','_')}">
		<xsl:attribute name="class">group level-<xsl:value-of select="count(ancestor::group)+1" /></xsl:attribute>
		<!-- td class="title"><xsl:value-of select="@title" /></td>
		<td class="score"><span><xsl:value-of select="@score" />/<xsl:value-of select="@total" /></span></td -->	
		<span class="title">
			<xsl:attribute name="onclick">
				<xsl:if test="count(ancestor::group)+1 > 1">$('.group.level-<xsl:value-of select="count(ancestor::group)+1" /> .group-content').hide(); $('.group.level-<xsl:value-of select="count(ancestor::group)+1" /> .title').removeClass('selected'); $(this).next().next().show(100); $(this).addClass('selected')</xsl:if>
			</xsl:attribute>
			<xsl:value-of select="@title" />
		</span>
		<div class="percentage"><xsl:value-of select="round(@score * 100 div @total)" />%</div>
		<div class="group-content">
			<xsl:apply-templates select="group" mode="group"/>
			<xsl:apply-templates select="assignment" mode="assignment"/>
		</div>
	</div>
</xsl:template>
<xsl:template match='assignment' mode='assignment'>
	<div class="item">
		<div class="title popup-wrapper">
  	       <span class="result-popup-label" onclick="javascript:sendToggleParentPopup('http://www.eindexamensite.nl/iframe-page.html?tx_iframequestion_pi1%5Bquestion%5D={@id}&amp;template=1')"><xsl:value-of select="@title"/></span>
		</div>
		<div>
			<xsl:attribute name="class">
				<xsl:choose>
		         	<xsl:when test="@score = @total">score score_good</xsl:when>
		         	<xsl:when test="@score = 0 and @made = 'true'">score score_bad</xsl:when>
		         	<xsl:when test="@score > 0 and @made = 'true'">score score_ok</xsl:when>
		         	<xsl:otherwise>score</xsl:otherwise>
		        </xsl:choose>
			</xsl:attribute>
			<span><xsl:value-of select="@score" />/<xsl:value-of select="@total" /></span>
		</div>
		<div class="clear-fix"></div>
	</div>
</xsl:template>
<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<!-- overrule default in content.xslt: images are in folder of xml content -->
<xsl:template match="resource" mode="content" priority="2">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img>
       <xsl:choose>
          <xsl:when test="$host_type='GAE'">
             <xsl:attribute name="src"><xsl:value-of select="name"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
             <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,name)"/></xsl:attribute>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>
<!-- overrule default in content.xslt: resources are in folder of xml content -->
<xsl:template match="resourcelink" mode="content" priority="2">
    <a target="_blank" class="dox" > <!-- @class='dox' is used in GenerateQTI to find these resourcelink, do not change -->
        <xsl:for-each select="@*">
            <xsl:choose>
                <!-- relative url w.r.t. base path of content -->
                <xsl:when test="name()='href'">
	                <xsl:choose>
	                   <xsl:when test="$host_type='GAE'">
		                    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
	                   </xsl:when>
	                   <xsl:otherwise>
		                    <xsl:attribute name="href"><xsl:value-of select="concat($urlbase,.)"/></xsl:attribute>
	                   </xsl:otherwise>
	                </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:attribute name="{name()}">
                      <xsl:value-of select="."/>
                   </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates mode="content"/>
    </a>
</xsl:template>

<xsl:template match="popup" mode="content">
    <xsl:variable name="width">
        <xsl:choose>
            <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
            <xsl:otherwise>500</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="restart">
      <xsl:choose>
        <xsl:when test="@restart">
          <xsl:value-of select="@restart"/>
        </xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  <div class="popup-wrapper">
       <span class="popup-label" onclick="{concat('javascript:togglePopup(',$width,',',$restart,', this)')}"><xsl:value-of select="@label"/></span>
       <span class="popup-label-text"><xsl:value-of select="@titel"/></span>
       <div class="popup-content">
           <xsl:attribute name="title">
               <xsl:value-of select="@titel"/>
           </xsl:attribute>
           <xsl:apply-templates mode="content"/>
       </div>
   </div>    
</xsl:template>

<xsl:template match="movie" mode="content" priority="2">
    <div class="movie-wrapper">
        <xsl:if test="@optional='true'">
            <xsl:choose>
                <xsl:when test="$host_type='GAE'">
                    <img src="/sources/movie_icon_60.gif" class="studiovo-movie-icon" onclick="javascript:toggleMovie(this)"/>
                </xsl:when>
                <xsl:otherwise>
                    <img src="sources/movie_icon_60.gif" class="studiovo-movie-icon" onclick="javascript:toggleMovie(this)"/>
                </xsl:otherwise>
            </xsl:choose>
            <span class="movie-title"><xsl:value-of select="@title"/></span>
        </xsl:if>
        <div>
            <xsl:choose>
                <xsl:when test="@optional='true'">
                    <xsl:attribute name="class">movie optional</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">movie</xsl:attribute>                    
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="style">width:<xsl:value-of select="@width"/>px;height:<xsl:value-of select="@height"/>px;</xsl:attribute>
            <xsl:choose>
                <xsl:when test="substring(@href,1,18) = 'http://www.youtube' or substring(@href,1,14) = 'http://youtube' or substring(@href,1,19) = 'https://www.youtube' or substring(@href,1,15) = 'https://youtube'">
                    <iframe frameborder="0" allowfullscreen="true">
                        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
                        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
                        <xsl:attribute name="src"><xsl:value-of select="@href"/></xsl:attribute>
                    </iframe>
                </xsl:when>
                <xsl:otherwise>
                    <video id="{generate-id()}" class="video-js vjs-default-skin" 
                            width="{@width}" height="{@height}"
                            controls="true" preload="none">
                        <xsl:choose>
                            <xsl:when test="$host_type='GAE'">
                                <source src="{@href}" type='video/mp4'/>
                            </xsl:when>
                            <xsl:otherwise>
                                <source src="{concat($urlbase,@href)}" type='video/mp4'/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </video>
                    <div style="clear:both"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </div>
</xsl:template>

<xsl:template match="audio" mode="content" priority="2">
    <xsl:choose>
        <xsl:when test="@inline='true'">
            <a onclick="this.getElementsByTagName('audio')[0].play()">
                <audio id="{generate-id()}" class="video-js vjs-default-skin"
                        width="{@width}" height="{@height}">
                    <xsl:choose>
                        <xsl:when test="$host_type='GAE'">
                            <source src="{@href}" type='audio/mp3'/>
                        </xsl:when>
                        <xsl:otherwise>
                            <source src="{concat($urlbase,@href)}" type='audio/mp3'/>
                        </xsl:otherwise>
                    </xsl:choose>
                </audio>
                <xsl:choose>
                    <xsl:when test="$host_type='GAE'">
                        <img src="/sources_studiovo/speaker-16.png" class="studiovo-speaker-icon" />
                    </xsl:when>
                    <xsl:otherwise>
                        <img src="sources_studiovo/speaker-16.png" class="studiovo-speaker-icon" />
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <div class="movie">
                <audio id="{generate-id()}" class="video-js vjs-default-skin"
                        width="{@width}" height="{@height}"
                        controls="true" preload="none">
                    <xsl:choose>
                        <xsl:when test="$host_type='GAE'">
                            <source src="{@href}" type='audio/mp3'/>
                        </xsl:when>
                        <xsl:otherwise>
                            <source src="{concat($urlbase,@href)}" type='audio/mp3'/>
                        </xsl:otherwise>
                    </xsl:choose>
                </audio>
            </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="iframe" mode="content" priority="2">
    <iframe>
        <xsl:copy-of select="@*[name()!='src']"/>
        <xsl:variable name="src">
            <xsl:choose>
              <xsl:when test="starts-with(@src,'http://') or starts-with(@src,'https://')">
                <xsl:value-of select="@src"/>
              </xsl:when>
              <xsl:when test="$host_type='GAE'">
                <xsl:value-of select="@src"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($urlbase, @src)"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
      <!-- if the iframe is in a popup, do not show the content immediately (movies could be starting etc, also can improves performance) -->
      <xsl:choose>
        <xsl:when test="ancestor::popup">
          <xsl:attribute name="src-orig"><xsl:value-of select="$src"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="src"><xsl:value-of select="$src"/></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </iframe>
</xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
