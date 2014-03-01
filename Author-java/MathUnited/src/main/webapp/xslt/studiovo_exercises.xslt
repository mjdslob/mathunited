<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">

  <!--  ******************** -->
  <!--   EXERCISES (NON-QTI  -->
  <!--  ******************** -->
  <xsl:template match="exercise">
    <xsl:param name="menuref"/>
    <div class="content-tab" id="{concat('tab-',$menuref,'-',position())}">
      <xsl:apply-templates select="." mode="content"/>
    </div>
  </xsl:template>

  <xsl:template match="exercise-sequence" mode="content">
    <div class="exercise-sequence">
      <xsl:for-each select="*">
        <xsl:variable name="pos" select="position()"/>
        <div nr="{position()}">
          <xsl:choose>
            <xsl:when test="$pos=1">
              <xsl:attribute name="class">exercise-seq-item selected</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">exercise-seq-item</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="." mode="content"/>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <xsl:template match="exercise" mode="content">
    <div class="exercise">
      <xsl:if test="@width">
        <xsl:attribute name="style">
          width:<xsl:value-of select="@width"/>px
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="content"/>
      <div class="exercise-completed">klaar!</div>
    </div>
  </xsl:template>

  <xsl:template match="multi-item" mode="content">
    <div class="exercise-multi-item">
      <xsl:apply-templates select="items/item" mode="content"/>
    </div>
  </xsl:template>

  <xsl:template match="item" mode="content">
    <xsl:variable name="pos" select="position()"/>
    <div>
      <xsl:choose>
        <xsl:when test="$pos=1">
          <xsl:attribute name="class">exercise-item selected</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">exercise-item</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="." mode="exercise-item"/>
    </div>
  </xsl:template>
  
  <xsl:template match="item[@type='closed']" mode="exercise-item">
    <xsl:if test="itemcontent/intro">
      <div class="exercise-intro">
        <xsl:apply-templates select="itemcontent/intro" mode="content"/>
      </div>
    </xsl:if>
    <div class="choice-exercise-question">
      <xsl:apply-templates select="itemcontent/itemintro/*" mode="content"/>
    </div>
    <xsl:for-each select="alternatives/alternative">
      <div class="choice-exercise-option">
        <xsl:if test="@state='yes'">
          <xsl:attribute name="state">yes</xsl:attribute>
        </xsl:if>
        <div class="choise-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
        <xsl:apply-templates select="*" mode="content"/>
      </div>
    </xsl:for-each>
    <div style="clear:left"/>
    <div class="item-completed" onclick="javascript:nextItem(this)"></div>
  </xsl:template>

  <xsl:template match="item[@type='dragtexttotext']" mode="exercise-item">
    <xsl:variable name="hintmode" select="@hintmode" />
    <xsl:variable name="drag-item-back-color" select="@drag-item-back-color" />
    <xsl:variable name="drag-item-text-color" select="@drag-item-text-color" />
    <xsl:variable name="exercise-id" select="generate-id()" />
    <xsl:attribute name="exercise-id">
      <xsl:value-of select="$exercise-id" />
    </xsl:attribute>
    <div class="exercise-item-drop">
      <xsl:if test="itemcontent/intro">
        <div class="exercise-intro">
          <xsl:apply-templates select="itemcontent/intro" mode="content"/>
        </div>
      </xsl:if>
      <div class="exercise-text">
        <xsl:apply-templates select="itemcontent/question" mode="content"/>
      </div>
      <div class="exercise-drop-cells">
        <div class="exercise-result">
          <div class="exercise-result-check" onclick="checkDragExercise('{$exercise-id}')" style="display: none" exercise-id="{$exercise-id}">Controleer</div>
          <div class="clear-fix"></div>
          <div class="exercise-result-mark" style="display: none" exercise-id="{$exercise-id}">Alle antwoorden zijn correct!</div>
        </div>
        <xsl:for-each select="itemcontent/question//drop-item">
          <xsl:sort select="."/>
          <div class="exercise-drop-cell" nr="{count(preceding-sibling::drop-item)+1}">
            <xsl:attribute name="exercise-id">
              <xsl:value-of select="$exercise-id" />
            </xsl:attribute>
            <xsl:if test="$hintmode='drag'">
              <xsl:attribute name="class">exercise-drop-cell hintmode-drag</xsl:attribute>
            </xsl:if>
            <xsl:if test="$hintmode='drop'">
              <xsl:attribute name="class">exercise-drop-cell hintmode-drop</xsl:attribute>
            </xsl:if>
            <xsl:if test="$hintmode='revert'">
              <xsl:attribute name="class">exercise-drop-cell hintmode-revert</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="style">
              <xsl:choose>
                <xsl:when test="$drag-item-back-color">
                  background-color: <xsl:value-of select="$drag-item-back-color" />;
                </xsl:when>
                <xsl:otherwise>
                  background-color: <xsl:value-of select="$menu_color" />;
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$drag-item-text-color">
                color: <xsl:value-of select="$drag-item-text-color" />;
              </xsl:if>
            </xsl:attribute>
            <div class="exercise-drop-cell-inner">
              <xsl:value-of select="."/>
            </div>
          </div>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="drop-item" mode="content">
    <span class="drop-item" nr="{count(preceding-sibling::drop-item)+1}"></span>
  </xsl:template>

  <xsl:template match="item[@type='entry']" mode="exercise-item">
    <xsl:variable name="casesensitive">
      <xsl:choose>
        <xsl:when test="not(@casesensitive)">false</xsl:when>
        <xsl:otherwise><xsl:value-of select="@casesensitive"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="showanwsersbutton">
      <xsl:choose>
        <xsl:when test="not(@showanwsersbutton)">false</xsl:when>
        <xsl:otherwise><xsl:value-of select="@showanwsersbutton"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>    
    <xsl:variable name="exercise-id" select="generate-id()" />
    <xsl:attribute name="exercise-id"><xsl:value-of select="$exercise-id" /></xsl:attribute>
    <div class="exercise-item-entry">
      <div class="exercise-result">
        <div class="exercise-result-check" onclick="checkEntryExercise('{$exercise-id}', {$casesensitive}, {$showanwsersbutton})" style="display: none" exercise-id="{$exercise-id}">Controleer</div>
        <div class="clear-fix"></div>
        <div class="exercise-result-show" onclick="showEntryExercise('{$exercise-id}')" style="display: none" exercise-id="{$exercise-id}">Toon antwoorden</div>
        <div class="clear-fix"></div>
        <div class="exercise-result-mark" style="display: none" exercise-id="{$exercise-id}">Alle antwoorden zijn correct!</div>
      </div>
      <xsl:if test="itemcontent/intro">
        <div class="exercise-intro">
          <xsl:apply-templates select="itemcontent/intro" mode="content"/>
        </div>
      </xsl:if>
      <div class="exercise-text">
        <xsl:apply-templates select="itemcontent/question" mode="question">
          <xsl:with-param name="exercise-id" select="$exercise-id"></xsl:with-param>
        </xsl:apply-templates>
      </div>
      <div class="clear-fix"></div>
    </div>
  </xsl:template>
  
  <xsl:template match="entry-item" mode="question">
    <xsl:param name="exercise-id" />
    <input class="entry-item" nr="{count(preceding-sibling::entry-item)+1}" exercise-id="{$exercise-id}">
      <xsl:attribute name="answers">
        <xsl:for-each select='answers/answer'>
          <xsl:value-of select='translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890","4250318697qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM")' />
          <xsl:value-of select='"|"'/>
        </xsl:for-each>
      </xsl:attribute>
    </input>
  </xsl:template>

  <xsl:template match="item[@type='open']" mode="exercise-item">
    <div class="label">
      <xsl:value-of select="@label"/>
    </div>
    <xsl:if test="itemcontent/intro">
      <div class="exercise-intro">
        <xsl:apply-templates select="itemcontent/intro" mode="content"/>
      </div>
    </xsl:if>
    <div class="exercise-item-open">
      <xsl:apply-templates select="itemcontent/question" mode="content"/>
    </div>
  </xsl:template>


  <!--  ******************** -->
  <!--   OPEN ITEM ANSWERS   -->
  <!--  ******************** -->

  <xsl:template match="answers-section" mode="content">
    <div class="answers-section">
      <xsl:apply-templates select="//item[@type='open']" mode="answers" />
    </div>
  </xsl:template>

  <xsl:template match="item" mode="answers">
    <div class="answer">
      <div class="label">
        <xsl:value-of select="@label"/>
      </div>
      <div class="content">
        <xsl:apply-templates select="answer" mode="answer" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="answer" mode="answer">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>