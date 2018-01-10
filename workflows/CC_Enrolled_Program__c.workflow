<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Program_Case</fullName>
        <field>Case_Program__c</field>
        <formula>Case__r.Id +&apos;:&apos;+ Program_Detail__r.Master_Program__r.Id</formula>
        <name>Populate Program &amp; Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Duplicate Program Enrollment</fullName>
        <actions>
            <name>Populate_Program_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK( Case__r.CaseNumber ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
