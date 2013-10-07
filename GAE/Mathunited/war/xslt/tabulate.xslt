<?xml version='1.0' encoding="UTF-8" ?>
<xsl:stylesheet
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'
xmlns:ct="http://www.pragma-ade.com/context">

<xsl:template match="ct:tabulate" mode="content">
    <table class="tabulate">
        <xsl:apply-templates mode="content"/>
    </table>
</xsl:template>
<xsl:template match="ct:body" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<xsl:template match="ct:row" mode="content">
    <tr>
        <xsl:apply-templates mode="content"/>
    </tr>
</xsl:template>
<xsl:template match="ct:cell" mode="content">
    <td>
        <xsl:apply-templates mode="content"/>
    </td>
</xsl:template>


</xsl:stylesheet>

