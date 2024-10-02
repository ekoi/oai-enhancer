<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs math" version="3.0">
    <xsl:output indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>
<!--        <xsl:param name="json-uri" select="()"/>-->
    <xsl:param name="json-uri" select="'file:/Users/akmi/git/ODISSEI-2024/oai-enricher-service/resources/etc/dv-dutch.json'"/>
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
        <titl>
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string"/></xsl:variable>
                <xsl:call-template name="set_lang">
                    <xsl:with-param name="val" select="$val"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
        <xsl:value-of select="."/>
        </titl>
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='distStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='distrbtr']" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="xml:lang">
                    <xsl:variable name="val"><xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string"/></xsl:variable>
                    <xsl:call-template name="set_lang">
                        <xsl:with-param name="val" select="$val"></xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='distStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='distDate']" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:message>88<xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='distributionDate']/following-sibling::string[@key='value']"/></xsl:message>
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="date"><xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='distributionDate']/following-sibling::string[@key='value']"/></xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='subject']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='keyword' and not (@xml:lang)]" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="xml:lang">
                    <xsl:variable name="val"><xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string"/></xsl:variable>
                    <xsl:call-template name="set_lang">
                        <xsl:with-param name="val" select="$val"></xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
       
    </xsl:template>
    
    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='stdyInfo']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='abstract']" xmlns="ddi:codebook:2_5" xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//map[@key='metadataBlocks']/map[@key='dansRights']/array[@key='fields']/map/string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::array[@key='value']/string"/></xsl:variable>
                <xsl:call-template name="set_lang">
                    <xsl:with-param name="val" select="$val"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template name="set_lang">
        <xsl:param name="val" />
        <xsl:choose>
            <xsl:when test="contains($val, 'English')">
                <xsl:value-of select="'en'"/>
            </xsl:when>
            <xsl:when test="contains($val, 'Dutch') and not(contains($val, 'English'))">
                <xsl:value-of select="'nl'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'en'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>