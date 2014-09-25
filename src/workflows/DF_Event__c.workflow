<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DF Event Status</fullName>
        <field>Event_Status__c</field>
        <literalValue>Closed</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Event Status</fullName>
        <field>Event_Status__c</field>
        <literalValue>Full</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Event Status Available</fullName>
        <description>Update the Status of an event to Available, if it was Full and then the number of places is changed</description>
        <field>Event_Status__c</field>
        <literalValue>Available</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DF Event Status</fullName>
        <actions>
            <name>DF Event Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Status is set to Closed, if Event is in past</description>
        <formula>DATEVALUE( Event_Date_Time__c ) &lt; TODAY()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Event Status</fullName>
        <actions>
            <name>Update Event Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Number_Of_Attendee_Records__c = Number_of_Places__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Event Status Available</fullName>
        <actions>
            <name>Update Event Status Available</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Number_of_Places__c &gt; Number_Of_Attendee_Records__c, ISPICKVAL(Event_Status__c,&apos;FULL&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
