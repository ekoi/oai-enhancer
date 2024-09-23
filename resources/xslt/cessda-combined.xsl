<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs math" version="3.0">
    <xsl:output indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>
        <xsl:param name="json-uri" select="()"/>
<!--    <xsl:param name="json-uri" select="'file:/Users/akmi/git/ODISSEI-2024/oai-enhancer-service/resources/dv.json'"/>-->
    <xsl:param name="json" select="unparsed-text($json-uri)"/>
    <xsl:param name="json-xml" select="json-to-xml($json)"/>
    
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='titlStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='titl']" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:param name="languages">
            <xsl:choose>
                <xsl:when test="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']">
                    <xsl:for-each select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>English</xsl:otherwise>
            </xsl:choose>    
        </xsl:param>
        <titl>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$languages"/>
            </xsl:attribute>
        <xsl:value-of select="."/>
        </titl>
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='distStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='distrbtr']" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:param name="languages">
            <xsl:choose>
                <xsl:when test="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']">
                    <xsl:for-each select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>English</xsl:otherwise>
            </xsl:choose>    
        </xsl:param>
        <distrbtr>
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="$languages"/>
                </xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </distrbtr>
    </xsl:template>
    
</xsl:stylesheet>