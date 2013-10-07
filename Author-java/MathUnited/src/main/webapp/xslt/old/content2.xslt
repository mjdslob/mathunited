<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">
<xsl:include href="calstable.xslt"/>
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="parent"/>
<xsl:param name="ref"/>
<xsl:variable name="cm2px" select="number(55)"/>
<xsl:variable name="domain" select="component/description/domain"/>
<xsl:variable name="subdomain" select="component/description/subdomain"/>
<xsl:variable name="section" select="component/description/section"/>
<xsl:variable name="refbase" select="concat(substring-before($ref,'/'),'/')"/>

<xsl:variable name="URLbase" select="string('http://demonstrator.webhop.org/MathUnited/')"/>
<xsl:variable name="parentPrefix" select="substring($parent,0, string-length($parent))"/>
<xsl:variable name="intraLinkPrefix" select="concat('view?ref=',$ref,'&amp;variant=basis&amp;parent=',encode-for-uri($parent),'&amp;item=')"/>
<xsl:variable name="overviewRef" select="$parent"/>
<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" />


<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/" name="main" >
<html  xmlns:m="http://www.w3.org/1998/Math/MathML">
<head>
   <link type="text/css" href="http://demonstrator.webhop.org/MathUnited/jquery/css/blitzer/jquery-ui-1.8.7.custom.css" rel="stylesheet" />
   <link rel="stylesheet" href="http://demonstrator.webhop.org:8080/MathUnited/css/grid.css" type="text/css"/>
   <script type="text/javascript" src="http://www.math4all.nl/MathJax/MathJax.js"></script>
<!--
   <script type="text/javascript" src="http://demonstrator.webhop.org/MathUnited/jquery/js/jquery-1.4.4.min.js"></script>
   <script type="text/javascript" src="http://demonstrator.webhop.org/MathUnited/jquery/js/jquery-ui-1.8.7.custom.min.js"></script>
-->
   <script type="text/javascript">
      //<![CDATA[
      function getElementsByClass(searchClass,node,tag) {
            var classElements = new Array();
            if ( node == null )
                    node = document;
            if ( tag == null )
                    tag = '*';
            var els = node.getElementsByTagName(tag);
            var elsLen = els.length;
            var pattern = new RegExp("(^|\\s)"+searchClass+"(\\s|$)");
            for (i = 0, j = 0; i < elsLen; i++) {
                    if ( pattern.test(els[i].className) ) {
                            classElements[j] = els[i];
                            j++;
                    }
            }
            return classElements;
       }
       function M4A_ShowAnswer() {
          var elm = document.getElementById('m4a-answer');
          if(elm) {
             elm.style.display = 'block';
          }
          var elm = document.getElementById('m4a-problem');
          if(elm) {
             elm.style.display = 'none';
          }
       }
       function M4A_NaarVorigePagina() {
         var elm = document.getElementById('selected-menu-item');
         if(elm) elm = elm.parentNode;
         elm = elm.previousSibling;
         while(elm && elm.nodeType!=1) {
            elm = elm.previousSibling;
         }//elm = td[class='leeg'], find next
         elm = elm.previousSibling;
         while(elm && elm.nodeType!=1) {
            elm = elm.previousSibling;
         }
         if(elm){
           elm = getElementsByClass('navigatie',elm,'a')[0];
           if(elm) {
              var ref = elm.getAttribute('href');
              document.location.href = ref;
           }
         }
       }
       function M4A_NaarVorigOnderdeel() {}
       function M4A_NaarVolgendePagina() {
         var elm = document.getElementById('selected-menu-item');
         if(elm) elm = elm.parentNode;
         elm = elm.nextSibling;
         while(elm && elm.nodeType!=1) {
            elm = elm.nextSibling;
         }//elm = td[class='leeg'], find next
         elm = elm.nextSibling;
         while(elm && elm.nodeType!=1) {
            elm = elm.nextSibling;
         }
         if(elm){
           elm = getElementsByClass('navigatie',elm,'a')[0];
           if(elm) {
              var ref = elm.getAttribute('href');
              document.location.href = ref;
           }
         }
       }
       function M4A_NaarVolgendOnderdeel() {}
       function M4A_NaarTotaalbeeld() {}
       function M4A_NaarOverzicht() {}
      //]]>
   </script>
   <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
   <title><xsl:value-of select="component/description/subdomain"/></title>
</head>
<body>
<div class="shadow-ul"/>
<div class="pageDiv ui-corner-all">
<div class="headingDiv container_12 clearfix">
    <div class="headingContentDiv grid_10">
        <img class="logo" src="http://www.math4all.nl/MathAdore/Images/LogoMAThADORE.gif" align="middle" width="57" height="33" border="0"/>
        <xsl:value-of select="component/description/subdomain"/>
    </div>
    <div class="overzichtDiv grid_2">
        <div class="ui-icon ui-icon-triangle-1-e"></div>
        <a class="navigatie">
           <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>Overzicht
        </a>
    </div>
</div>
<div class="sectionDiv container_12  ui-corner-all">
   <div class="balk grid_12">
       <xsl:value-of select="component/description/section"/>
   </div>
</div>
<div class="contentDiv container_12 clearfix">
<div class="grid_10">
    <xsl:choose>
        <xsl:when test="$item='example'">
            <xsl:apply-templates select="component/componentcontent/theory/examples"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="component/componentcontent/*[name()=$item]" />
        </xsl:otherwise>
    </xsl:choose>
</div>
<div class="menuDiv grid_2">
    <xsl:apply-templates select="component/componentcontent/*" mode="navigation"/>
    <!--
    <embed class="audio" src="http://www.basiswiskunde.nl/Vocal/ha-b11-ep1.mp3" autoplay="false" width="70" height="26" volume="80" align="right"></embed>
    -->
</div>
</div>
</div>
<div class="shadow-lr"/>
</body>
</html>
</xsl:template>


<xsl:template match="explore">
    <h3>Verkennen</h3>
    <xsl:for-each select="include">
       <div class="exercise-with-heading">
           <div class="exercise-heading">
               Opgave <xsl:value-of select="position()"/>
           </div>
           <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content"/>
       </div>
    </xsl:for-each>
</xsl:template>
<xsl:template match="introduction">
    <h3>Inleiding</h3>
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>
<xsl:template match="explanation">
    <h3>Uitleg</h3>
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>
<xsl:template match="theory">
    <h3>Theorie</h3>
    <xsl:for-each select="examples">
       <div class="example-with-heading">
           <div class="example-heading">
               Voorbeeld <xsl:value-of select="position()"/>
           </div>
           <xsl:apply-templates select="document(concat($refbase,include/@filename))" mode="content"/>
       </div>
    </xsl:for-each>
<!--
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
-->
</xsl:template>
<xsl:template match="examples">
    <h3>Voorbeeld <xsl:value-of select="$num"/></h3>
    <xsl:variable name="cont" select = "document(concat($refbase,include[number($num)]/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>
<xsl:template match="summary">
    <h3>Samenvatting</h3>
    <xsl:apply-templates  mode="content"/>
</xsl:template>
<xsl:template match="background">
    <h3>Achtergronden</h3>
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>



<!--
    Templates for navigation bar
-->
<xsl:template match="explore" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explore')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='explore'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Verkennen</a>
   </div><div class="menu-item-leeg"/>
</xsl:template>
<xsl:template match="introduction" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'introduction')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='introduction'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Inleiding</a>
   </div><div class="menu-item-leeg"/>
</xsl:template>
<xsl:template match="explanation" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explanation')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='explanation'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Uitleg</a>
   </div><div class="menu-item-leeg"/>
</xsl:template>
<xsl:template match="theory" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'theory')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='theory'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Theorie</a>
   </div><div class="menu-item-leeg"/>
   <xsl:apply-templates select="examples" mode="navigation"/>
</xsl:template>

<xsl:template match="examples" mode="navigation">
   <xsl:for-each select="include">
       <div class="menu-item-div">
           <a>
                <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'example&amp;num=',position())"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$item='example' and position()=number($num)">
                        <xsl:attribute name="class">knop2</xsl:attribute>
                        <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    </xsl:when><xsl:otherwise>
                        <xsl:attribute name="class">navigatie</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
               Voorbeeld <xsl:value-of select="position()"/></a>
        </div><div class="menu-item-leeg"/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="summary" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'summary')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='theory'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Samenvatting</a>
   </div><div class="menu-item-leeg"/>
   <xsl:apply-templates select="examples" mode="navigation"/>
</xsl:template>
<xsl:template match="background" mode="navigation">
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'background')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$item='theory'">
                    <xsl:attribute name="class">knop2</xsl:attribute>
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Achtergronden</a>
   </div><div class="menu-item-leeg"/>
   <xsl:apply-templates select="examples" mode="navigation"/>
</xsl:template>

<xsl:template match="paperfigure" mode="content">
   <div class="figureDiv">
       <xsl:if test="@location='right'">
           <xsl:attribute name="style">float:right;margin-left:10px;</xsl:attribute>
       </xsl:if>
       <xsl:apply-templates mode="content"/>
   </div>
</xsl:template>

<xsl:template match="combination" mode="content">
    <table>
        <xsl:apply-templates select="combiblock" mode="content">
            <xsl:with-param name="nx" select="number(@nx)"/>
            <xsl:with-param name="ny" select="number(@ny)"/>
        </xsl:apply-templates>
    </table>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="combiblock" mode="content">
    <xsl:param name = "nx"/>
    <xsl:param name = "ny"/>
    <xsl:variable name="pos" select="position()-1"/>
        <xsl:choose>
        <xsl:when test="$pos mod $nx = 0"><tr>
            <td><xsl:apply-templates mode="content"/></td>
            <xsl:for-each select="following-sibling::combiblock[position()&lt;$nx]">
               <td><xsl:apply-templates mode="content"/></td>
            </xsl:for-each></tr>
        </xsl:when>
        </xsl:choose>
</xsl:template>
<xsl:template match="combiblock" mode="inRow">
     <tr><td><xsl:apply-templates mode="content"/></td></tr>
</xsl:template>

<xsl:template match="resource" mode="content">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img>
       <xsl:attribute name="src"><xsl:value-of select="concat($URLbase,name)"/></xsl:attribute>
       <xsl:if test="$width>0">
           <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>


<!--
    Introduction
-->
<xsl:template match="learningaspects" mode="content">
 <p>
    <b>Je leert nu:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
       </xsl:for-each>
    </ul>
 </p>
</xsl:template>

<xsl:template match="knownaspects" mode="content">
 <p>
    <b>Je kunt al:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
        </xsl:for-each>
    </ul>
 </p>
</xsl:template>

<xsl:template match="keyword" mode="content">
   <span class="keyword"><xsl:value-of select="text"/></span>
</xsl:template>

<xsl:template match="hyperlink" mode="content">
    <a>
        <xsl:for-each select="@*">
           <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
           </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates mode="content"/>
    </a>
</xsl:template>

<xsl:template match="itemize" mode="content">
    <xsl:choose>
        <xsl:when test="@number">
            <ol><xsl:apply-templates mode="content"/></ol>
        </xsl:when>
        <xsl:otherwise>
            <ul><xsl:apply-templates mode="content"/></ul>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="item" mode="content">
    <li><xsl:apply-templates mode="content"/></li>
</xsl:template>

<xsl:template match="examplesolution" mode="content">
   <div id="m4a-problem">
      <h3><a href="javascript:M4A_ShowAnswer()">&gt;&gt; Antwoord</a></h3>
   </div>
   <div id="m4a-answer" style="display:none">
       <h3>Antwoord</h3>
       <xsl:apply-templates mode="content"/>
   </div>
</xsl:template>

<xsl:template match="website" mode="content">
    <a target="_blank">
        <xsl:attribute name="href">http://<xsl:value-of select="."/></xsl:attribute>
        <xsl:value-of select="."/>
    </a>
</xsl:template>

<xsl:template match="definitions" mode="content">
    <div class="definitionsDiv">
        <div class="header">Begrippen:</div>
        <xsl:for-each select="definition">
            <div class="item-label"><xsl:value-of select="position()"/>: </div>
            <div class="item"><a><xsl:attribute name="href">view?ref=<xsl:value-of select="concat($parentPrefix,string(position()))"/>.xml&amp;item=theory&amp;variant=basis</xsl:attribute>
                <xsl:apply-templates mode="content"/></a></div>
        </xsl:for-each>
    </div><div style="clear:both"/>
</xsl:template>
<xsl:template match="activities" mode="content">
    <div class="definitionsDiv">
        <div class="header">Vaardigheden:</div>
        <xsl:for-each select="activity">
            <div class="item-label"><xsl:value-of select="position()"/>: </div>
            <div class="item"><a>
                <xsl:attribute name="href">view?ref=<xsl:value-of select="concat($parentPrefix,string(position()))"/>.xml&amp;item=theory&amp;variant=basis</xsl:attribute>
                <xsl:apply-templates mode="content"/></a></div>
        </xsl:for-each>
    </div><div style="clear:both"/>
</xsl:template>

<xsl:template match="exercise" mode="content">
    <div class="exercise">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="items" mode="content">
    <div class="multi-item-items">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="items/item" mode="content">
    <div class="multi-item-item">
        <div class="multi-item-item-label"><xsl:value-of select="@label"/></div>
        <xsl:apply-templates mode="content"/>
        <div style="clear:both"/>
    </div>
</xsl:template>
<xsl:template match="single-item/item" mode="content">
    <div class="single-item-item">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="multi-item//item/itemcontent" mode="content">
    <div class="multi-item-item-itemcontent">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="single-item//itemcontent" mode="content">
    <div class="single-item-item-itemcontent">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="single-item" mode="content">
    <div class="single-item">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="multi-item" mode="content">
    <div class="multi-item">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="multi-item/intro" mode="content">
    <div class="multi-item-intro">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>
<xsl:template match="item/answer" mode="content"></xsl:template>
<xsl:template match="itemcontent/question" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<xsl:template match="itemcontent/question/p[1]" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="separator" mode="content">
&#151;
</xsl:template>

<xsl:template match="unknown" mode="content">...
</xsl:template>

<xsl:template match="amount" mode="content">
    € <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="m:*" mode="content">
    <xsl:element name="{local-name()}">
        <xsl:apply-templates  mode="content"/>
    </xsl:element>
</xsl:template>
<xsl:template match="@*|node()" mode="content">

    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="content"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
