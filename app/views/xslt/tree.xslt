<xsl:stylesheet 
      version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- TODO buttons -->

<xsl:template match="//field">
  <td>
    <xsl:text disable-output-escaping="yes">&lt;%= f.oe_field(obj, {name:'</xsl:text>
    <xsl:value-of select="@name"/>', string:'<xsl:value-of select="@string"/>', widget:'<xsl:value-of select="@widget"/>', class:'<xsl:value-of select="@class"/>', options: "<xsl:value-of select="@options"/>", modifiers: "<xsl:value-of select="@modifiers"/>", on_change: "<xsl:value-of select="@on_change"/>", placeholder: "<xsl:value-of select="@placeholder"/>", domain:"<xsl:value-of select="@domain"/>", context:"<xsl:value-of select="@context"/>", style:'<xsl:value-of select="@style"/>', attrs: "<xsl:value-of select="@attrs"/>", invisible: "<xsl:value-of select="@invisible"/>", readonly: "<xsl:value-of select="@readonly"/>", nolabel: "<xsl:value-of select="@nolabel"/>"<xsl:text disable-output-escaping="yes">}) %></xsl:text>
  </td>
</xsl:template>

</xsl:stylesheet>
