<xsl:stylesheet 
      version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
<xsl:template match="//div">
  <xsl:copy-of select="*"/>
</xsl:template>
-->

<!-- TODO buttons -->

<xsl:template match="//notebook">
 <div class="tabbable columns">
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
    <a data-toggle="tab">
      <xsl:attribute name="href">#<xsl:value-of select="translate(translate(@string, ' ', ''), '&amp;', '')" /></xsl:attribute>
      <xsl:value-of select="@string"/>
    </a>
  </li>
</xsl:template>

<xsl:template match="page" mode="content">
    <div class="tab-pane fade active in">
      <xsl:attribute name="id"><xsl:value-of select="translate(translate(@string, ' ', ''), '&amp;', '')" /></xsl:attribute>
      <xsl:apply-templates select="*" />
    </div>
</xsl:template>

<xsl:template match="//separator">
    <br></br><hr></hr>
    <p><xsl:value-of select="@string" /></p>
</xsl:template>

<xsl:template match="div">
    <div class="control-group">
      <xsl:apply-templates select="*" />
    </div>
</xsl:template>

<xsl:template match="field">
  <div class="field">
    <xsl:text disable-output-escaping="yes">&lt;%= oe_form_field(f, {name:'</xsl:text>
    <xsl:value-of select="@name"/>', string:'<xsl:value-of select="@string"/>', widget:'<xsl:value-of select="@widget"/>', class:'<xsl:value-of select="@class"/>', options: "<xsl:value-of select="@options"/>", modifiers: "<xsl:value-of select="@modifiers"/>", on_change: "<xsl:value-of select="@on_change"/>", placeholder: "<xsl:value-of select="@placeholder"/>", domain:"<xsl:value-of select="@domain"/>", context:"<xsl:value-of select="@context"/>", style:'<xsl:value-of select="@style"/>', attrs: "<xsl:value-of select="@attrs"/>", invisible: "<xsl:value-of select="@invisible"/>", readonly: "<xsl:value-of select="@readonly"/>", nolabel: "<xsl:value-of select="@nolabel"/>"
    <xsl:text disable-output-escaping="yes">}) %></xsl:text>
  </div>
  <xsl:apply-templates select="*" />
</xsl:template>

</xsl:stylesheet>
