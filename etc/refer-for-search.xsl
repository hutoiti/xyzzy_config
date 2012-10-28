<?xml version="1.0" encoding="shift_jis"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:kia="http://www.geocities.jp/kiaswebsite">
  <msxsl:script language="JScript" implements-prefix="kia"><![CDATA[

function test(re_str, str) {
  var re = new RegExp(re_str);
  return re.test(str);
}

  ]]></msxsl:script>
  <xsl:param name="pattern" select="''"/>
  <xsl:param name="bytitle" select="0"/>
  <xsl:template match="/">
    <chapters>
      <xsl:choose>
        <xsl:when test="$bytitle">
          <xsl:apply-templates select="//chapter[kia:test($pattern,string(title))]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//chapter[kia:test($pattern,string(.))]" />
        </xsl:otherwise>
      </xsl:choose>
    </chapters>
  </xsl:template>
  <xsl:template match="chapter">
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
