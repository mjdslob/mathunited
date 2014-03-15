<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:exsl="http://exslt.org/common"
        xmlns:test="http://www.jenitennison.com/xslt/unit-test"
        xmlns:math="http://www.exslt.org/math"
        xmlns:m="http://www.w3.org/1998/Math/MathML"
        extension-element-prefixes="exsl math"
        exclude-result-prefixes="test math xml xsl exsl"
        version="1.0">
    <xsl:import href="mathml/math.min.template.xslt"/>
    <xsl:variable name="operatormap">
      <operator priority="20" replacement="*">
        <match>*</match>
        <match>&#x22C5;</match> <!-- sdot -->
        <match>&#215;</match>   <!-- times -->
      </operator>
      <operator priority="10" replacement="+">
        <match>+</match>
      </operator>
      <operator priority="10" replacement="-">
        <match>-</match>
        <match>&#x2212;</match> <!-- minus -->
      </operator>
      <operator priority="20" replacement="/">
        <match>/</match>
        <match>&#x002F;</match>  <!-- sol -->
      </operator>
      <operator priority="20" replacement=":">
        <match>:</match>
      </operator>
      <operator priority="100" replacement="=">
        <match>=</match>
      </operator>
    </xsl:variable>
    
	<!-- Assign priorities to operators, numbers and identifiers -->
    <xsl:template name="set-priority">
      <xsl:param name="priority" />
      <xsl:copy>
        <xsl:attribute name="p">
          <xsl:value-of select="$priority" />
        </xsl:attribute>
        <xsl:apply-templates select="@*|node()" mode="priority" />
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:mn|m:mi" mode="priority">
      <xsl:call-template name="set-priority">
        <xsl:with-param name="priority">
          <xsl:text>100</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:mo" mode="priority">
      <xsl:call-template name="set-priority">
        <xsl:with-param name="priority">
          <xsl:value-of select="$operatormap/operator/match[text()=current()/text()]/../@priority" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:mrow" mode="priority">
      <xsl:variable name="tmp">
        <xsl:apply-templates mode="priority" />
      </xsl:variable>
      <xsl:variable name="priority">
        <xsl:call-template name="math:min">
          <xsl:with-param name="nodes" select="exsl:node-set($tmp)/*/@p" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="set-priority">
        <xsl:with-param name="priority">
          <xsl:value-of select="$priority" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:mfrac" mode="priority">
      <xsl:call-template name="set-priority">
        <xsl:with-param name="priority">
          <xsl:text>40</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:msup" mode="priority">
      <xsl:call-template name="set-priority">
        <xsl:with-param name="priority">
          <xsl:text>30</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="priority">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="priority" />
      </xsl:copy>
    </xsl:template>
    
    <!--                    -->
    <!-- convert expression -->
    <xsl:template match="@*|node()" mode="convert">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="convert" />
      </xsl:copy>
    </xsl:template>
    
    <!-- Entry point -->
    <xsl:template match="@*|node()" mode="convert-to-asciimathml">
      <xsl:variable name="prioritized">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" mode="priority" />
        </xsl:copy>
      </xsl:variable>
      <xsl:apply-templates select="exsl:node-set($prioritized)" mode="convert" />
    </xsl:template>
    
    <xsl:template name="unchanged">
      <xsl:value-of select="normalize-space(text())" />
    </xsl:template>
    
    <xsl:template match="*" mode="write-term">
        <xsl:param name="priority"/>
        <xsl:variable name="temp">
          <xsl:apply-templates select="." mode="convert" />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="number(@p) &lt; number($priority)">
               (<xsl:value-of select="normalize-space($temp)" />)
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="normalize-space($temp)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="m:mn" mode="convert">
      <xsl:call-template name="unchanged" />
    </xsl:template>
    
    <xsl:template match="m:mo" mode="convert">
        <xsl:choose>
            <xsl:when test="$operatormap/operator/match[text()=current()/text()]">
                <xsl:value-of select = "$operatormap/operator/match[text()=current()/text()]/../@replacement" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:math" mode="convert">
        <am>
            <xsl:variable name="result">
              <xsl:apply-templates mode="convert" />
            </xsl:variable>
            <xsl:value-of select="normalize-space($result)" />
        </am>
    </xsl:template>
	
    <xsl:template match="m:mfrac" mode="convert">
        <xsl:apply-templates select="*[1]" mode="write-term">
            <xsl:with-param name="priority" select="@p"/>
        </xsl:apply-templates>
        <xsl:text>/</xsl:text>
        <xsl:apply-templates select="*[2]" mode="write-term">
            <xsl:with-param name="priority" select="@p"/>
        </xsl:apply-templates>
    </xsl:template>
	
    <xsl:template match="m:msup" mode="convert">
        <xsl:apply-templates select="*[1]" mode="write-term">
            <xsl:with-param name="priority" select="@p"/>
        </xsl:apply-templates>
        <xsl:text>^</xsl:text>
        <xsl:apply-templates select="*[2]" mode="write-term">
            <xsl:with-param name="priority" select="@p"/>
        </xsl:apply-templates>
    </xsl:template>
	
    <xsl:template match="m:msub" mode="convert">
      (<xsl:apply-templates select="*[1]" mode="convert" />)
      <xsl:text>_</xsl:text>
      (<xsl:apply-templates select="*[2]" mode="convert" />)
    </xsl:template>
	
    <xsl:template match="m:mover" mode="convert">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates mode="convert" />
    </xsl:template>
    
    <xsl:template match="m:mroot" mode="convert">
      <xsl:text>root</xsl:text>
      <xsl:apply-templates select="*[1]" mode="convert" />
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="*[2]" mode="convert" />
      <xsl:text>)</xsl:text>
    </xsl:template>
    
	<xsl:template match="m:msqrt" mode="convert">
      <xsl:text>sqrt(</xsl:text>
      <xsl:apply-templates mode="convert" />
      <xsl:text>)</xsl:text>
    </xsl:template>
  </xsl:stylesheet>

