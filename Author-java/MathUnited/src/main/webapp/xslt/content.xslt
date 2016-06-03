<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p1"
extension-element-prefixes="exsl">



<!--   ******  ********** -->
<!--   CONTENT ELEMENTS -->
<!--   **************** -->


<!-- ASCIIMATH -->
<xsl:template match="am" mode="content">
    `<xsl:value-of select='.'/>`
</xsl:template>

<!--         -->
<!-- Figures -->
<!--         -->
<xsl:template match="paperfigure"  mode="content">
      <xsl:choose>
          <xsl:when test="@location='right' or @location='margin'">
             <div class="figureDiv right">
                 <xsl:apply-templates select="*[name()!='caption']" mode="content"/>
                 <xsl:apply-templates select="caption" mode="content"/>
             </div>
          </xsl:when>
          <xsl:otherwise>
             <div class="figureDiv">
                 <xsl:apply-templates select="*[name()!='caption']" mode="content"/>
                 <xsl:apply-templates select="caption" mode="content"/>
             </div>
          </xsl:otherwise>
      </xsl:choose>
</xsl:template>

<xsl:template match="inlinefigure" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="combination" mode="content">
    <table><tbody>
        <xsl:apply-templates select="combiblock" mode="content">
            <xsl:with-param name="nx" select="number(@nx)"/>
            <xsl:with-param name="ny" select="number(@ny)"/>
        </xsl:apply-templates>
    </tbody></table>
</xsl:template>

<xsl:template match="combiblock" mode="content">
    <xsl:param name = "nx"/>
    <xsl:param name = "ny"/>
    <xsl:variable name="pos" select="position()-1"/>
        <xsl:choose>
        <xsl:when test="$pos mod $nx = 0"><tr>
            <td>
               <xsl:apply-templates select="content" mode="content"/>
               <xsl:apply-templates select="subcaption" mode="content"/>
            </td>
            <xsl:for-each select="following-sibling::combiblock[position()&lt;$nx]">
               <td>
                   <xsl:apply-templates select="content" mode="content"/>
                   <xsl:apply-templates select="subcaption" mode="content"/>
               </td>
            </xsl:for-each></tr>
        </xsl:when>
        </xsl:choose>
</xsl:template>

<xsl:template match="resource" mode="content">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img>
       <xsl:choose>
          <xsl:when test="$host_type='GAE'">
             <xsl:attribute name="src"><xsl:value-of select="name"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
             <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,'../images/highres/',replace(name,'Images/',''))"/></xsl:attribute>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>

<xsl:template match="content" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="subcaption" mode="content">
    <div class="subcaption">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>

<xsl:template match="paperfigure/caption" mode="content">
    <div class="caption">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>

<xsl:template match="movie" mode="content">
    <div class="movie-wrapper">
        <xsl:if test="@optional='true'">
            <div class="movie-icon" onclick="javascript:toggleMovie(this)"/>
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
                <xsl:when test="substring(@href,1,18) = 'http://www.youtube' or substring(@href,1,14) = 'http://youtube'">
                    <iframe frameborder="0" allowfullscreen="true">
                        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
                        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
                        <xsl:attribute name="src"><xsl:value-of select="@href"/></xsl:attribute>
                    </iframe>
                </xsl:when>
                <xsl:otherwise>
                    <video id="{generate-id()}" class="video-js vjs-default-skin" 
                            preload="auto" width="{@width}" height="{@height}"
                            data-setup="" controls="true">
                            <source src="{concat($urlbase,'../video/',@href)}" type='video/mp4'/>
                    </video>
                    <div style="clear:both"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </div>
</xsl:template>
<xsl:template match="keyword" mode="content">
   <span class="keyword"><xsl:value-of select="text"/></span>
</xsl:template>
<xsl:template match="author-remark" mode="content">
    <span class="author-remark"><xsl:apply-templates mode="content"/></span>
</xsl:template>
<xsl:template match="hyperlink" mode="content">
    <a>
        <xsl:for-each select="@*">
            <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates mode="content"/>
    </a>
</xsl:template>

<xsl:template match="resourcelink" mode="content">
    <a target="_blank" class="dox" > <!-- @class='dox' is used in GenerateQTI to find these resourcelink, do not change -->
        <xsl:for-each select="@*">
            <xsl:choose>
                <!-- relative url w.r.t. base path of content -->
                <xsl:when test="name()='href'">
	                <xsl:choose>
                            <xsl:when test="contains(., 'http://')">
                                <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
                            </xsl:when>
 	                   <xsl:when test="$host_type='GAE'">
		                    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
	                   </xsl:when>
	                   <xsl:otherwise>
                                <xsl:attribute name="href"><xsl:value-of select="concat($urlbase,'../dox/',.)"/></xsl:attribute>
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

<xsl:template match="itemize[not(@number='n')]" mode="content">
     <ul><xsl:apply-templates mode="content"/></ul>
</xsl:template>
<xsl:template match="itemize[@number='n']" mode="content">
     <ol><xsl:apply-templates mode="content"/></ol>
</xsl:template>
<xsl:template match="itemize/item" mode="content">
    <li><xsl:apply-templates mode="content"/></li>
</xsl:template>

<xsl:template match="examplecontent" mode="content">
    <div class="examplecontent">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>


<xsl:template match="examplesolution" mode="content">
    <xsl:if test="not(normalize-space()='')">
        <div class="m4a-example">
                <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; antwoord</div>
                <div class="m4a-answer">
                    <xsl:apply-templates mode="content"/>
                    <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
                </div>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="answer" mode="content">
   <xsl:param name="options"/>
   <xsl:choose>
       <xsl:when test="$options and $options/options/mode[@type='answers']">
<!--           
            <div class="m4a-problem">
                    <div onclick="javascript:M4A_ShowAnswer(this)" class="answerOpenButton"/>
            </div>
            <div class="m4a-answer" style="display:none">       
                <xsl:apply-templates mode="content"/>
                <div  onclick="javascript:M4A_CloseAnswer(this)" class="answerCloseButton"/>
            </div>
-->            
            <div class="m4a-answer selected">       
                <xsl:apply-templates mode="content"/>
                <div style="clear:both"/>
            </div>
       </xsl:when>
       <xsl:otherwise>
           
       </xsl:otherwise>
   </xsl:choose>
   
</xsl:template>

<xsl:template match="website" mode="content">
    <a target="_blank">
        <xsl:attribute name="href">http://<xsl:value-of select="."/></xsl:attribute>
        <xsl:value-of select="."/>
    </a>
</xsl:template>

<xsl:template match="separator" mode="content">
&#8212;
</xsl:template>

<xsl:template match="unknown" mode="content">...
</xsl:template>

<xsl:template match="amount" mode="content">
    <xsl:choose>
      <xsl:when test="@type='dollar'">
         $
      </xsl:when>
      <xsl:when test="@type='pound'">
         &#x00A3;
      </xsl:when>
      <xsl:otherwise>
         €
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="dots" mode="content">
    <xsl:choose>
        <xsl:when test="@n='1'">.</xsl:when>
        <xsl:when test="@n='2'">..</xsl:when>
        <xsl:when test="@n='3'">...</xsl:when>
        <xsl:when test="@n='4'">....</xsl:when>
        <xsl:when test="@n='5'">.....</xsl:when>
        <xsl:otherwise>........</xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="quotation" mode="content">
    "<xsl:apply-templates mode="content"/>"
</xsl:template>
<xsl:template match="citation" mode="content">
    <xsl:choose>
        <xsl:when test="@type='display'">
            <div class="citation">"<xsl:apply-templates mode="content"/>"</div>
        </xsl:when>
        <xsl:otherwise>
            <span class="citation">"<xsl:apply-templates mode="content"/>"</span>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="applet[@type='ggb']" mode="content">
    <xsl:choose>
        <xsl:when test="$is_mobile!='DISABLEtrue'">
            <xsl:apply-templates mode="content"/>
            <iframe style="overflow:hidden" _type='ggb'>
                <xsl:if test="@width">
                    <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@height">
                    <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@location='right'">
                    <xsl:attribute name="style">float:right</xsl:attribute>
                </xsl:if>
                <xsl:choose>
                   <xsl:when test="$host_type='GAE'">
            	       <xsl:attribute name="src"><xsl:value-of select="concat('http://math4allview.appspot.com/geogebra?file=',encode-for-uri(@filename))"/></xsl:attribute>
                   </xsl:when>
                   <xsl:otherwise>
		       <xsl:attribute name="src"><xsl:value-of select="concat('/MathUnited/geogebra?file=',$refbase,'../geogebra/',replace(@filename,'GeoGebra/','../geogebra/'),'&amp;repo=',$repo)"/></xsl:attribute>
                   </xsl:otherwise>
                </xsl:choose>
            </iframe>
        </xsl:when>
        <xsl:otherwise>
            <applet code="geogebra.GeoGebraApplet" codebase="/sources/" archive="geogebra.jar">
                <!--
                   <xsl:attribute name="archive"><xsl:value-of select="$URLgeogebra"/></xsl:attribute>
                -->
                <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
                <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
                <xsl:if test="@location='right'">
                    <xsl:attribute name="style">float:right</xsl:attribute>
                </xsl:if>
                <param name="java_arguments" value="-Xmx512m -Djnlp.packEnabled=true"/>
                <param name="filename">
                    <xsl:attribute name="value"><xsl:value-of select="@filename"/></xsl:attribute>
                </param>
                <param name="framePossible" value="false"/>
                <xsl:apply-templates mode="content"/>
                Sorry, de GeoGebra Applet start niet. Zorg dat Java 1.4.2 (of een nieuwere versie) actief is. (<a href="http://java.sun.com/getjava">klik hier om Java nu te installeren</a>)
            </applet>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template match="applet[@type='akit']" mode="content">
    <iframe>
        <xsl:if test="@width">
            <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@height">
            <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$host_type='GAE'">
		        <xsl:attribute name="src"><xsl:value-of select="concat('http://algebrakit2012.appspot.com/trainerRemote_MU.html?audience=',@audience,'&amp;assignment=',@assignment)"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
		        <xsl:attribute name="src"><xsl:value-of select="concat('../AKIT_RemoteServer/trainerRemote_MU.html?audience=',@audience,'&amp;assignment=',@assignment)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </iframe>
</xsl:template>
<xsl:template match="applet[@archive]" mode="content">
    <applet>
        <xsl:copy-of select="@*"/>
        <xsl:if test="@align='right'">
            <xsl:attribute name="style">float:right</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="content"/>
        Sorry, de GeoGebra Applet start niet. Zorg dat Java 1.4.2 (of een nieuwere versie) actief is. (<a href="http://java.sun.com/getjava">klik hier om Java nu te installeren</a>)
    </applet>
    <xsl:apply-templates select="source" mode="content"/>
</xsl:template>
<xsl:template match="applet/source" mode="content">
    <div class="applet-source">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="iframe" mode="content">
    <iframe scrolling="no">
        <xsl:choose>
            <xsl:when test="starts-with(@src,'http')">
                <xsl:copy-of select="@*"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="@*[name()!='src']"/>
                <xsl:attribute name="src" select="concat($urlbase, '../html/', @src)"/>
            </xsl:otherwise>
        </xsl:choose>
    </iframe>
</xsl:template>

<xsl:template match="media[@type='video']" mode="content">
    <iframe marginheight="0" marginwidth="0" frameborder="0" scrolling="no">
        <xsl:attribute name="src"><xsl:value-of select="@src"/></xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
    </iframe>
</xsl:template>

<xsl:template match="papertable" mode="content">
    <xsl:choose>
        <xsl:when test="@location='right'">
            <div style='float:right'>
                <xsl:apply-templates mode="content"/>
            </div>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates mode="content"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="table" mode="content">
    <table class="wm-default-table">
        <xsl:apply-templates select="@*" mode="content"/>
        <xsl:choose>
            <xsl:when test="tbody">
                <xsl:apply-templates mode="content"/>
            </xsl:when>
            <xsl:otherwise>
                <tbody>
                    <xsl:apply-templates mode="content"/>
                </tbody>
            </xsl:otherwise>
        </xsl:choose>
    </table>
</xsl:template>
<xsl:template match="m:*" mode="content">
    <xsl:element name="{local-name()}">
        <xsl:apply-templates select="@*[name()!='scriptlevel']" mode="content"/>
        <xsl:apply-templates mode="content"/>
    </xsl:element>
</xsl:template>

<xsl:template match="sheetref" mode="content">
    <xsl:choose>
        <xsl:when test="$_sheetref_as_links_">
            <a target="_blank">
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="string-length($num) > 0">
                            <xsl:value-of select="concat('view?repo=',$repo,'&amp;comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=', $item,'&amp;num=', $num,'&amp;ws_id=', @item)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('view?repo=',$repo,'&amp;comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=', $item,'&amp;ws_id=', @item)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <span target="_blank">
                <xsl:value-of select="."/>
            </span>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="sequence-widget" mode="content">
    <div class="sequence-widget">
        <xsl:if test="@width">
           <xsl:attribute name="style" select="concat('width:',number(substring-before(@width,'cm'))*$cm2px,'px')"/>
        </xsl:if>
        <xsl:apply-templates select="sequence-item" mode="content"/>
        <div class="sequence-widget-button-bar">
            <div class="sequence-widget-prev" style="display:none" onclick="javascript:MU_sequencePrev(this)"/>
            <div class="sequence-widget-next" onclick="javascript:MU_sequenceNext(this)"/>
            <div style="clear:both"/>
        </div>
    </div>
</xsl:template>
<xsl:template match="sequence-item" mode="content">
    <xsl:choose>
        <xsl:when test="position()=1">
            <div class="sequence-item visible">
                <xsl:apply-templates mode="content"/>
            </div>
        </xsl:when>
        <xsl:otherwise>
            <div class="sequence-item">
                <xsl:apply-templates mode="content"/>
                <div style="clear:both"/>
            </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="stepaligntable" mode="content">
    <table class="stepaligntable"><tbody>
        <xsl:apply-templates select="cells" mode="content"/>
    </tbody></table>
</xsl:template>
<xsl:template match="stepaligntable/cells" mode="content">
    <tr class="stepaligntable-cells">
        <xsl:apply-templates select="c1|c2|c3" mode="content"/>
        <td><div class="stepaligntable-text">
               <xsl:apply-templates select="following-sibling::text[1]" mode="content"/>
            </div>
        </td>
    </tr>
</xsl:template>
<xsl:template match="stepaligntable/cells/c1" mode="content">
    <td class="stepaligntable-c1">
        <xsl:apply-templates mode="content"/>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c2" mode="content">
    <td class="stepaligntable-c2">
        <xsl:apply-templates mode="content"/>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c3" mode="content">
    <td class="stepaligntable-c3">
        <xsl:apply-templates mode="content"/>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/text" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="justatitle" mode="content">
    <div class="justatitle">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="worksheets" mode="content"/>
<xsl:template match="placelink" mode="content"></xsl:template>
<xsl:template match="p[@medium='paper']" mode="content"></xsl:template>
<xsl:template match="p[@medium='paper']"></xsl:template>
<xsl:template match="block" mode="content">
    <xsl:if test="not(@medium='paper')">
        <xsl:apply-templates mode="content"/>
    </xsl:if>
</xsl:template>
<xsl:template match="forgetsidefloat" mode="content"/>
<xsl:template match="comment" mode="content"></xsl:template>
<xsl:template match="compound" mode="content"><xsl:value-of select="@token"/></xsl:template>
<xsl:template match="math" mode="content">
    <h1>Error: MathML tag &lt;math> found without the proper namespace. Use &lt;m:math> instead.</h1>
</xsl:template>
<!-- //////////////////// -->
<!--        HTML          -->
<!-- //////////////////// -->
<xsl:template match="center" mode="content">
    <span style="text-align:center">
        <xsl:apply-templates mode="content"/>
    </span>
</xsl:template>
<xsl:template match="mark" mode="content">
    <span style="background-color:yellow;color:black;">
        <xsl:apply-templates mode="content"/>
    </span>
</xsl:template>


<xsl:template match="img | qti:img" mode="content">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img>
       <xsl:choose>
          <xsl:when test="$host_type='GAE'">
		       <xsl:attribute name="src"><xsl:value-of select="name"/></xsl:attribute>
		  </xsl:when>
		  <xsl:otherwise>
                      <xsl:variable name="name" select="replace(@src,'[^/\.]*/','')"/>
		       <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,'../images/highres/',$name)"/></xsl:attribute>
		  </xsl:otherwise>
	   </xsl:choose>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>

<xsl:template match="@*|node()" mode="content">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="content"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
