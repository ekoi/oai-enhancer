<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:js="http://www.w3.org/2005/xpath-functions"
    xmlns="http://www.openarchives.org/OAI/2.0/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs math" version="3.0">
    <xsl:output indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:param name="pp" select="()"/>
    <xsl:param name="pid" select="unparsed-text($pp)"/>
    <xsl:param name="json-uri" select="()"/>
    <!--<xsl:param name="pid" select="'doi:10.17026/dans-224-vn3g'"/>
    <xsl:param name="json-uri" select="'file:/Users/akmi/git/ODISSEI-2024/oai-enricher-service/resources/etc/doi-10.17026-dans-224-vn3g_dv_json.json'"/>
    --><xsl:param name="json" select="unparsed-text($json-uri)"/>
    <xsl:param name="json-xml" select="json-to-xml($json)"/>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//*[local-name()='record']">
        <xsl:message>==kkkk==<xsl:value-of select="./*[local-name()='header']/*[local-name()='identifier']"/></xsl:message>
        <xsl:message>----<xsl:value-of select="$pid"/>--</xsl:message>  
        <xsl:choose>
            <xsl:when test="./*[local-name()='header']/*[local-name()='identifier' and text()=$pid]">
                
                <xsl:message>PID:<xsl:value-of select="$pid"/> and identifier = <xsl:value-of select="./*[local-name()='header']/*[local-name()='identifier']/text()"/></xsl:message>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="record">
                <xsl:copy-of select="node() | @*"></xsl:copy-of>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='citation']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='titlStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='titl']" xmlns="ddi:codebook:2_5"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:element name="titl">
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//js:map[@key='metadataBlocks']/js:map[@key='dansRights']/js:array[@key='fields']/js:map/js:string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::js:array[@key='value']/js:string"/></xsl:variable>
                <xsl:call-template name="set_lang">
                    <xsl:with-param name="val" select="$val"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='distStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='distrbtr']" xmlns="ddi:codebook:2_5" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//js:map[@key='metadataBlocks']/js:map[@key='dansRights']/js:array[@key='fields']/js:map/js:string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::js:array[@key='value']/js:string"/></xsl:variable>
                <xsl:call-template name="set_lang">
                    <xsl:with-param name="val" select="$val"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='distStmt']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='distDate']" xmlns="ddi:codebook:2_5" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="date"><xsl:value-of select="."/></xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='subject']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='keyword' and not (@xml:lang)]" xmlns="ddi:codebook:2_5" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//js:map[@key='metadataBlocks']/js:map[@key='dansRights']/js:array[@key='fields']/js:map/js:string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::js:array[@key='value']/js:string"/></xsl:variable>
                <xsl:call-template name="set_lang">
                    <xsl:with-param name="val" select="$val"></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>

    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='subject']" xmlns="ddi:codebook:2_5" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="$json-xml//js:map[@key='metadataBlocks']/js:map[@key='dansSocialSciences']/js:array[@key='fields']/js:map/js:string[@key='typeName' and text()='dansElsstClassification']/following-sibling::js:array[@key='value']/js:string">
                <xsl:variable name="kw"><xsl:value-of select="."/></xsl:variable>
                <keyword xml:lang="en" vocab="ELSST"><xsl:attribute name="vocabURI"><xsl:value-of select="$kw"/></xsl:attribute>
                    <xsl:value-of select="../following-sibling::js:array[@key='expandedvalue']/js:map/js:string[@key='@id' and text()=$kw]/following-sibling::js:array/js:map/js:string[@key='lang' and text()='en']/following-sibling::js:string[@key='value']"/>
                </keyword>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>

    </xsl:template>

    <xsl:template match="//*[namespace-uri()='ddi:codebook:2_5' and local-name()='stdyInfo']/*[namespace-uri()='ddi:codebook:2_5' and local-name()='abstract']" xmlns="ddi:codebook:2_5" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
        >
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang">
                <xsl:variable name="val"><xsl:value-of select="$json-xml//js:map[@key='metadataBlocks']/js:map[@key='dansRights']/js:array[@key='fields']/js:map/js:string[@key='typeName' and text()='dansMetadataLanguage']/following-sibling::js:array[@key='value']/js:string"/></xsl:variable>
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