<?xml version="1.0" encoding="shift_jis"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output encoding="shift_jis" method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="//chapter">

    <xsl:text>================================ (</xsl:text><xsl:value-of select="@resultNumber"/><xsl:text>)&#10;</xsl:text>

    <xsl:text>■</xsl:text><xsl:value-of select="title"/><xsl:text>&#10;</xsl:text>

    <xsl:text>[Type       ]: </xsl:text><xsl:value-of select="type"/>
    <xsl:if test="type/@interactive = 't'">
      <xsl:text> (interactive)</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>

    <xsl:if test="arguments[. != '']">
      <xsl:text>[Arguments  ]: </xsl:text>
      <xsl:value-of select="arguments"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>

    <xsl:if test="package[. != '']">
      <xsl:text>[Package    ]: </xsl:text>
      <xsl:value-of select="package"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>

    <xsl:for-each select="seealso[. != '']">
      <xsl:text>[See also   ]: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    
    <xsl:for-each select="link[. != '']">
      <xsl:text>[Link       ]:</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>

    <xsl:if test="file[. != '']">
      <xsl:text>[File       ]: </xsl:text>
      <xsl:value-of select="file"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>

    <xsl:text>[Section    ]: </xsl:text>
    <xsl:value-of select="section"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:text>[Description]:&#10;</xsl:text>
    <xsl:value-of select="description"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:text>&#10;</xsl:text>

  </xsl:template>

</xsl:stylesheet>
