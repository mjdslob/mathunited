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

  <xsl:template match="exercise[not(@slider) or @slider='false']" mode="content">
    <xsl:if test="@auto-number">
      <span class="auto-number">
        <xsl:if test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:if>
        <xsl:number level="any" count="//exercise[@type='theory']" format="{@auto-number}" />
      </span>
    </xsl:if>
    <div class="exercise">
      <xsl:if test="@width">
        <xsl:attribute name="style">
          width:<xsl:value-of select="@width"/>px
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="content"/>
    </div>
  </xsl:template>

  <xsl:template match="exercise[@slider='true']" mode="content">

    <xsl:variable name="title">
      <xsl:if test="@auto-number">
        <span class="auto-number">
          <xsl:if test="@prefix">
            <xsl:value-of select="@prefix"/>
          </xsl:if>
          <xsl:number level="any" count="//exercise[@type='theory']" format="{@auto-number}" />
        </span>
      </xsl:if>
    </xsl:variable>

    <div class="slider-wrapper">
      <span class="slider-label" onclick="javascript:toggleSlider(this)">
        <xsl:value-of select="$title" />
      </span>
      <div class="slider-content" style="display: none">
        <xsl:attribute name="title">
          <xsl:value-of select="$title" />
        </xsl:attribute>
        <div class="exercise">
          <xsl:apply-templates mode="content"/>
          <div class="exercise-completed">klaar!</div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="multi-item[count(items/item[@type='closed' or @type='multiple']) &gt; 0]" mode="content">
    <xsl:variable name="showscore" select="@showscore" />
    <div class="exercise-multi-item rotate">
      <xsl:apply-templates select="items/item" mode="exercise-item-top">
        <xsl:with-param name="showscore" select="$showscore" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="multi-item[count(items/item[@type='closed' or @type='multiple']) = 0]" mode="content">
    <div class="exercise-multi-item">
      <xsl:apply-templates select="items/item" mode="exercise-item-top" />
    </div>
    <div class="clear-fix"></div>
  </xsl:template>

  <xsl:template match="single-item" mode="content">
    <div class="exercise-single-item">
      <xsl:apply-templates select="item" mode="exercise-item-top" />
    </div>
    <div class="clear-fix"></div>
  </xsl:template>

  <xsl:template match="item" mode="exercise-item-top">
    <xsl:param name="showscore" />
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
      <xsl:apply-templates select="." mode="exercise-item">
        <xsl:with-param name="showscore" select="$showscore" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="item[@type='closed']" mode="exercise-item">
    <xsl:param name="showscore" />
    <xsl:if test="itemcontent/intro">
      <div class="exercise-intro">
        <xsl:apply-templates select="itemcontent/intro" mode="content"/>
      </div>
    </xsl:if>
    <div class="choice-exercise-question">
      <xsl:apply-templates select="itemcontent/itemintro/*" mode="content"/>
    </div>
    <table class="exercise-layout-table">
      <tr>
        <td class="choice-exercise-options">
          <xsl:for-each select="alternatives/alternative">
            <div class="choice-exercise-option">
              <xsl:if test="@state='yes'">
                <xsl:attribute name="state">yes</xsl:attribute>
              </xsl:if>
              <div class="choise-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
              <xsl:apply-templates select="content" mode="content"/>
              <xsl:if test="feedback">
                <div class="feedback">
                  <xsl:value-of select="feedback"/>
                </div>
              </xsl:if>
            </div>
          </xsl:for-each>
        </td>
        <td align="right">
          <div class="item-next"></div>
          <div class="exercise-completed">klaar!</div>
        </td>
      </tr>
      <tr>
        <td>
          <div class="item-feedback">Feedback</div>
        </td>
        <td align="right">
          <xsl:if test="$showscore = 'true'">
            <div class="item-score"></div>
          </xsl:if>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="item[@type='multiple']" mode="exercise-item">
    <xsl:param name="showscore" />
    <xsl:if test="itemcontent/intro">
      <div class="exercise-intro">
        <xsl:apply-templates select="itemcontent/intro" mode="content"/>
      </div>
    </xsl:if>
    <div class="multiple-exercise-question">
      <xsl:apply-templates select="itemcontent/itemintro/*" mode="content"/>
    </div>
    <table class="exercise-layout-table">
      <tr>
        <td class="multiple-exercise-options">
          <xsl:for-each select="alternatives/alternative">
            <div class="multiple-exercise-option">
              <xsl:if test="@state='yes'">
                <xsl:attribute name="state">yes</xsl:attribute>
              </xsl:if>
              <div class="multiple-exercise-label" onclick="javascript:multipleLabelClick(this)"/>
              <xsl:apply-templates select="content" mode="content"/>
              <xsl:if test="feedback">
                <div class="feedback">
                  <xsl:value-of select="feedback"/>
                </div>
              </xsl:if>
            </div>
          </xsl:for-each>
        </td>
        <td align="right">
          <div class="item-next"></div>
          <div class="exercise-completed">klaar!</div>
        </td>
      </tr>
      <tr>
        <td>
          <div class="item-feedback">Feedback</div>
        </td>
        <td align="right">
          <xsl:if test="$showscore = 'true'">
            <div class="item-score"></div>
          </xsl:if>
        </td>
      </tr>
    </table>
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
          <div class="exercise-drop-cell">
            <xsl:attribute name="nr">
              <xsl:number level="any" />
            </xsl:attribute>
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
    <span class="drop-item">
      <xsl:attribute name="nr">
        <xsl:number level="any" />
      </xsl:attribute>
    </span>
  </xsl:template>

  <xsl:template match="item[@type='entry']" mode="exercise-item">
    <xsl:variable name="casesensitive">
      <xsl:choose>
        <xsl:when test="not(@casesensitive)">false</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@casesensitive"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="showanwsersbutton">
      <xsl:choose>
        <xsl:when test="not(@showanwsersbutton)">false</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@showanwsersbutton"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="exercise-id" select="generate-id()" />
    <xsl:attribute name="exercise-id">
      <xsl:value-of select="$exercise-id" />
    </xsl:attribute>
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
        <xsl:apply-templates select="itemcontent/question" mode="content"/>
      </div>
      <div class="clear-fix"></div>
    </div>
  </xsl:template>

  <xsl:template match="entry-item" mode="content">
    <input class="entry-item" nr="{count(preceding-sibling::entry-item)+1}">
      <xsl:attribute name="answers">
        <xsl:for-each select='answers/answer'>
          <xsl:value-of select='translate(.,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890","4250318697qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM")' />
          <xsl:value-of select='"|"'/>
        </xsl:for-each>
      </xsl:attribute>
    </input>
  </xsl:template>

  <xsl:template match="item[@type='open']" mode="exercise-item">
    <table>
      <tr>
        <xsl:if test="@label">
          <td class="label">
            <xsl:value-of select="@label"/>
          </td>
        </xsl:if>
        <td class="exercise-body">
          <xsl:if test="itemcontent/intro">
            <div class="exercise-intro">
              <xsl:apply-templates select="itemcontent/intro" mode="content"/>
            </div>
          </xsl:if>
          <div class="exercise-item-open">
            <xsl:apply-templates select="itemcontent/question" mode="content"/>
          </div>
        </td>
      </tr>
    </table>
  </xsl:template>


  <!--  ******************** -->
  <!--   OPEN ITEM ANSWERS   -->
  <!--  ******************** -->

  <xsl:template match="answers-section" mode="content">
    <div class="answers-section">
      <xsl:for-each select="//block/include">
        <xsl:if test="count(document(concat($docbase,@filename))//exercise//item[@type='open']) > 0">
          <div class="answer-header">
            <xsl:value-of select="../title"/>
          </div>
          <xsl:apply-templates select="document(concat($docbase,@filename))//exercise" mode="exercise-answers" />
        </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="exercise" mode="exercise-answers">
    <xsl:if test="@auto-number">
      <span class="auto-number">
        <xsl:if test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:if>
        <xsl:number level="any" count="//exercise[@type='theory']" format="{@auto-number}" />
      </span>
    </xsl:if>
    <xsl:apply-templates select=".//item[@type='open']" mode="answers" />
  </xsl:template>

  <xsl:template match="item" mode="answers">
    <table class="answer">
      <tr>
        <xsl:if test="@label">
          <td class="label">
            <xsl:value-of select="@label"/>
          </td>
        </xsl:if>
        <td class="content">
          <xsl:apply-templates select=".//answer" mode="answer" />
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="answer" mode="answer">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>