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


<xsl:include href="calstable.xslt"/>
<xsl:template match="cals:table" mode="editor"><xsl:apply-templates select="." mode="content"/></xsl:template>
<xsl:template match="cals:table" mode="paragraph"><xsl:apply-templates select="." mode="content"/></xsl:template>

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


<!-- elements with special behaviour -->
<xsl:template match="include" mode="editor">
    <div class="item-container">
        <div class="_editor_context_base">
            <div  class="_editor_option" type="optional" name="invoegen..." function="insertContentItem">
                <div class="menu-button-div item-container-menu">
                    <span class="menu-button"></span>
                </div>
            </div>
        
            <div tag="{name()}">
                <xsl:apply-templates select="@*" mode="editor"/>
                <xsl:apply-templates select="document(concat($docbase,@filename))" mode="editor"/>
            </div>
        </div>
    </div>
</xsl:template>

<!-- BLOCKS -->
<xsl:template match="block" mode="editor">
    <div tag="block">
        <xsl:apply-templates select="@*" mode="editor"/>
        <div class="block-button visible"><xsl:value-of select="@medium"/></div>
        <div class="block-content visible">
            <xsl:apply-templates select="node()" mode="editor"/>
        </div>
        <div style="clear:both"/>
    </div>
</xsl:template>
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
         <xsl:apply-templates mode="editor"/>
    </table>
</xsl:template>
<xsl:template match="tr|td|th|tbody|col|colgroup" mode="editor">
    <xsl:copy>
         <xsl:attribute name="tag" select="name()"/>
         <xsl:apply-templates mode="editor"/>
    </xsl:copy>
</xsl:template>
    
<!-- others -->
<xsl:template match="learningaspects" mode="editor">
   <div tag="learningaspects">
      <span class="headline"><b>Je leert in dit onderwerp:</b></span>
      <div class="close-paragraph"></div>
      <ul class="paragraph-content">
         <xsl:for-each select="aspect">
             <li><xsl:apply-templates mode="paragraph"/></li>
         </xsl:for-each>
      </ul>
   </div>
</xsl:template>
<xsl:template match="knownaspects" mode="editor">
 <div tag="knownaspects">
    <span class="headline"><b>Voorkennis:</b></span>
    <div class="close-paragraph"></div>
    <ul class="paragraph-content">
        <xsl:for-each select="aspect">
            <li><xsl:apply-templates mode="paragraph"/></li>
        </xsl:for-each>
    </ul>
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
    <table class="stepaligntable" tag="stepaligntable" editor="false"><tbody>
        <xsl:apply-templates select="cells" mode="editor"/>
    </tbody></table>
</xsl:template>
<xsl:template match="stepaligntable/cells" mode="editor">
    <tr class="stepaligntable-cells" tag="cells">
        <xsl:apply-templates select="c1|c2|c3" mode="editor"/>
        <td tag="text">
            <xsl:apply-templates select="following-sibling::text[1]" mode="editor"/>
        </td>
    </tr>
</xsl:template>
<xsl:template match="stepaligntable/cells/c1" mode="editor">
    <td class="stepaligntable-c1" tag="c1">
        <p><xsl:apply-templates mode="paragraph"/></p>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c2" mode="editor">
    <td class="stepaligntable-c2" tag="c2">
        <p><xsl:apply-templates mode="paragraph"/></p>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/cells/c3" mode="editor">
    <td class="stepaligntable-c3" tag="c3">
        <p><xsl:apply-templates mode="paragraph"/></p>
    </td>
</xsl:template>
<xsl:template match="stepaligntable/text" mode="editor">
    <p><xsl:apply-templates mode="paragraph"/></p>
</xsl:template>


</xsl:stylesheet>
