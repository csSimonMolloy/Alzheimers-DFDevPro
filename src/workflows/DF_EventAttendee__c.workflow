<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Champion Training Date</fullName>
        <description>Update the Date of Champion Training to the current date/time once the Event Status changes to Attended.</description>
        <field>Date_of_Champion_Training__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>DF_Contact__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>DFDate_of_Champion_Training</fullName>
        <actions>
            <name>Update Champion Training Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DF_Contact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Dementia Friend Champion</value>
        </criteriaItems>
        <criteriaItems>
            <field>DF_EventAttendee__c.EventAttendeeStatus__c</field>
            <operation>equals</operation>
            <value>Attended</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
