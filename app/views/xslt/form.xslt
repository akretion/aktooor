<xsl:stylesheet 
      version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="//notebook">
  <div class="tabbable columns row">
    <ul id="myTab" class="nav nav-tabs">
      <xsl:apply-templates select="page" mode="nav"/>
    </ul>
    <div class="tab-content">
      <xsl:attribute name="id"><xsl:value-of select="translate(@string, ' ', '')" /></xsl:attribute>
      <xsl:apply-templates select="page" mode="content"/>
    </div>
  </div>
</xsl:template>

<xsl:template match="page" mode="nav">
  <li>
    <xsl:attribute name="class">
      <xsl:if test="count(preceding-sibling::*) &lt; 1">active</xsl:if>
    </xsl:attribute>
    <a data-toggle="tab">
      <xsl:attribute name="href">#<xsl:value-of select="translate(translate(@string, ' ', ''), '&amp;', '')" /></xsl:attribute>
      <xsl:value-of select="@string"/>
    </a>
  </li>
</xsl:template>

<xsl:template match="page" mode="content">
    <div class="tab-pane fade">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="count(preceding-sibling::*) &lt; 1">tab-pane fade active in</xsl:when>
          <xsl:otherwise>tab-pane fade</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="translate(translate(@string, ' ', ''), '&amp;', '')" /></xsl:attribute>
      <xsl:apply-templates select="*" />
      <br></br>
    </div>
</xsl:template>

<xsl:template match="group">
  <div class="row span12">
      <xsl:apply-templates select="*" mode="row"/>
  </div>
</xsl:template>

<xsl:template match="group" mode="row">
      <div class="span6">
      <xsl:apply-templates select="*" />
      </div>
</xsl:template>

<xsl:template match="//separator">
    <br></br><hr></hr><p><xsl:value-of select="@string" /></p>
</xsl:template>

<xsl:template match="div">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
      <xsl:apply-templates select="*" />
<span></span>
    </div>
</xsl:template>


<xsl:template match="h1"><!-- FIXME no CSS effect with Bootstrap -->
    <h1><xsl:apply-templates select="*" /></h1>
</xsl:template>

<xsl:template match="label">
    <xsl:text disable-output-escaping="yes">&lt;%= </xsl:text>f.oe_form_label(for:"<xsl:value-of select="@name"/>", string:"<xsl:value-of select="@string"/>")<xsl:text disable-output-escaping="yes">%></xsl:text>
</xsl:template>

<xsl:template match="field">
    <xsl:text disable-output-escaping="yes">&lt;%= </xsl:text>f.ooor_input(:<xsl:value-of select="@name"/>, label:"<xsl:value-of select="@string"/>", widget:'<xsl:value-of select="@widget"/>', class:'<xsl:value-of select="@class"/>', options: "<xsl:value-of select="@options"/>", modifiers: "<xsl:value-of select="@modifiers"/>", on_change: "<xsl:value-of select="@on_change"/>", placeholder: "<xsl:value-of select="@placeholder"/>", domain:"<xsl:value-of select="@domain"/>", context:"<xsl:value-of select="@context"/>", style:"<xsl:value-of select="@style"/>", attrs: "<xsl:value-of select="@attrs"/>", invisible: "<xsl:value-of select="@invisible"/>", readonly: "<xsl:value-of select="@readonly"/>", nolabel: "<xsl:value-of select="@nolabel"/>")<xsl:text disable-output-escaping="yes">%></xsl:text>
  <xsl:apply-templates select="*" />
</xsl:template>

<xsl:template match="button">
    <xsl:text disable-output-escaping="yes">&lt;%= </xsl:text>f.oe_form_button(type:"<xsl:value-of select="@type"/>", string:"<xsl:value-of select="@string"/>", name:"<xsl:value-of select="@name"/>", context:"<xsl:value-of select="@context"/>", attrs: "<xsl:value-of select="@attrs"/>", modifiers: "<xsl:value-of select="@modifiers"/>", style:"<xsl:value-of select="@style"/>")<xsl:text disable-output-escaping="yes">%></xsl:text>
</xsl:template>

</xsl:stylesheet>
