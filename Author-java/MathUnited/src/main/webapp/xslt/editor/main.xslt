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

<xsl:include href="editor/exercise.xslt"/>
<xsl:include href="editor/content.xsl"/>
<xsl:include href="editor/figure.xslt"/>
<xsl:include href="editor/paragraph.xslt"/>
<xsl:include href="editor/include.xslt"/>
<xsl:include href="editor/combination.xslt"/>
    
<!--
MSLO 2 juni 2014: keep cals:table intact 
<xsl:include href="editor/calstable.xslt"/>

<xsl:template match="cals:table" mode="editor">
    <xsl:variable name="preptable">
        <xsl:apply-templates select="." mode="content"/>
    </xsl:variable>
    <xsl:apply-templates select="$preptable" mode="editor"/>
</xsl:template>
<xsl:template match="cals:table" mode="paragraph">
    <xsl:variable name="preptable">
        <xsl:apply-templates select="." mode="content"/>
    </xsl:variable>
    <xsl:apply-templates select="$preptable" mode="editor"/>
</xsl:template>
-->

<xsl:template match="node() | @*" mode="editor-prepare">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="editor-prepare"/>
    </xsl:copy>
</xsl:template>

<!-- combine list of nodes with identical @medium-tag into one block -->
<xsl:template match="p[@medium] | paperfigure[@medium] | papertable[@medium]" mode="editor-prepare">
    <block medium="{@medium}">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*[name()!='medium'] | node()" mode="editor-prepare"/>
        </xsl:element>
    </block>
</xsl:template>

<!-- DEFAULT -->
<xsl:template match="*" mode="editor">
    <div tag="{name()}">
        <xsl:apply-templates select="@* | node()" mode="editor"/>
    </div>
</xsl:template>

<xsl:template match="@*" mode="editor">
    <xsl:copy/>
</xsl:template>
<xsl:template match="*" mode="editor-span">
    <span tag="{name()}">
        <xsl:apply-templates select="@* | node()" mode="editor-span"/>
    </span>
</xsl:template>
<xsl:template match="@* | text()" mode="editor-span">
    <xsl:copy/>
</xsl:template>

<!-- identity template -->
<xsl:template match="@* | node()" mode="copy">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="copy"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="xhtml:*" mode="remove-xhtml">
    <xsl:element name="{name()}">
        <xsl:apply-templates select="@* | node()" mode="remove-xhtml"/>
    </xsl:element>
</xsl:template>
<xsl:template match="node() | @*" mode="remove-xhtml">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="remove-xhtml"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="applet[@type='ggb']" mode="editor">
    <div tag="{name()}">
        <xsl:apply-templates select="@* | node()" mode="editor"/>
    </div>
    <xsl:apply-templates select="." mode="content"/>
</xsl:template>

<!-- ///////////////////////// -->
<!-- Multi-channel: WEB, PAPER -->
<!-- ///////////////////////// -->
<xsl:template match="block" mode="editor">
    <xsl:if test="*">
        <div tag="block">
            <xsl:apply-templates select="@*" mode="editor"/>
            <div class="block-button visible">
                <xsl:value-of select="@medium"/>
            </div>
            <div class="block-content visible">
                <xsl:apply-templates select="node()" mode="editor"/>
            </div>
            <div style="clear:both"/>
        </div>
    </xsl:if>
</xsl:template>


<!-- ////////// -->
<!-- Worksheets -->
<!-- ////////// -->
<xsl:template match="worksheet" mode="editor">
    <div tag="worksheet">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div class="worksheet-button">werkblad</div>
        <div class="worksheet-content">
            <div class="worksheet-id"><xsl:value-of select="@id"/></div>
            <xsl:apply-templates select="node()" mode="editor"/>
        </div>
    </div>
</xsl:template>


<!-- TABLES -->
<!-- copy the table (it it html anyway) but add the @tag attributes -->
<xsl:template match="table" mode="editor">
    <table tag="table">
         <xsl:apply-templates select="@*|node()" mode="editor"/>
    </table>
</xsl:template>
<xsl:template match="table" mode="paragraph">
    <table tag="table">
         <xsl:apply-templates select="@*|node()" mode="editor"/>
    </table>
</xsl:template>

<xsl:template match="tr|tbody|col|colgroup" mode="editor">
    <xsl:copy>
         <xsl:attribute name="tag" select="name()"/>
         <xsl:apply-templates select="@*|node()" mode="editor"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="td | th" mode="editor">
    <xsl:copy>
         <xsl:attribute name="tag" select="name()"/>
<!--         
         <xsl:if test="@paperwidth"><xsl:attribute name="paperwidth" select="@paperwidth"/></xsl:if>
-->         
         <xsl:apply-templates select="@*|node()" mode="paragraph"/>
    </xsl:copy>
</xsl:template>
<!-- others -->
<xsl:template match="learningaspects" mode="editor">
   <div tag="learningaspects">
      <span class="headline"><b>Je leert in dit onderwerp:</b></span>
          <xsl:choose>
              <xsl:when test="aspect">
                  <ul class="paragraph">
                    <xsl:for-each select="aspect">
                        <li><xsl:apply-templates mode="paragraph"/></li>
                    </xsl:for-each>
                  </ul>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:apply-templates mode="paragraph"/>
              </xsl:otherwise>
          </xsl:choose>
   </div>
</xsl:template>
<xsl:template match="knownaspects" mode="editor">
 <div tag="knownaspects">
    <span class="headline"><b>Voorkennis:</b></span>
          <xsl:choose>
              <xsl:when test="aspect">
                  <ul class="paragraph">
                    <xsl:for-each select="aspect">
                        <li><xsl:apply-templates mode="paragraph"/></li>
                    </xsl:for-each>
                  </ul>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:apply-templates mode="paragraph"/>
              </xsl:otherwise>
          </xsl:choose>
 </div>
</xsl:template>
<xsl:template match="aspect" mode="paragraph">
    <xsl:apply-templates mode="paragraph"/>
</xsl:template>
<xsl:template match="applet" mode="editor">
    <div tag="applet">
        <xsl:apply-templates select="@*" mode="editor"/>
        <xsl:if test="count(*)=0 and text()">
            <p><xsl:value-of select="text()"/></p>
        </xsl:if>
        <xsl:apply-templates select="*" mode="editor"/>
    </div>
</xsl:template>

<xsl:template match="stepaligntable" mode="editor">
    <div class="wrapper-prevent-paragraph-mode">
        <table class="stepaligntable" tag="stepaligntable" editor="false"><tbody>
            <xsl:apply-templates select="cells" mode="editor"/>
        </tbody></table>
    </div>
</xsl:template>
<xsl:template match="stepaligntable/cells" mode="editor">
    <tr class="stepaligntable-cells" tag="cells">
        <xsl:apply-templates select="c1|c2|c3" mode="editor"/>
        <td class="stepaligntable-text" tag="text">
            <xsl:apply-templates select="following-sibling::text[1]" mode="editor"/>
        </td>
    </tr>
</xsl:template>
<xsl:template match="stepaligntable/cells/c1" mode="editor">
    <td class="stepaligntable-c1" tag="c1">
        <xsl:choose>
            <xsl:when test="p">
                <xsl:apply-templates mode="paragraph"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:apply-templates mode="paragraph"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c2" mode="editor">
    <td class="stepaligntable-c2" tag="c2">
        <xsl:choose>
            <xsl:when test="p">
                <xsl:apply-templates mode="paragraph"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:apply-templates mode="paragraph"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c3" mode="editor">
    <td class="stepaligntable-c3" tag="c3">
        <xsl:choose>
            <xsl:when test="p">
                <xsl:apply-templates mode="paragraph"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:apply-templates mode="paragraph"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/text" mode="editor">
    <xsl:choose>
        <xsl:when test="p">
            <xsl:apply-templates mode="paragraph"/>
        </xsl:when>
        <xsl:otherwise>
            <p><xsl:apply-templates mode="paragraph"/></p>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
