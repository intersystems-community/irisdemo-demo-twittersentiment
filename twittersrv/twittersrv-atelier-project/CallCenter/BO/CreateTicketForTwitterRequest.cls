Class CallCenter.BO.CreateTicketForTwitterRequest Extends Ens.Request [ ProcedureBlock ]
{

Parameter RESPONSECLASSNAME = "CallCenter.BO.CreateTicketForTwitterResponse";

Property pTwitterID As %String;

Property pTwitterUser As %String;

Property pTwitterText As %String(MAXLEN="");

Property pTwitterSentiment As %Float;

Property pTwitterDate As %Date;

Storage Default
{
<Data name="CreateTicketForTwitterRequestDefaultData">
<Subscript>"CreateTicketForTwitterRequest"</Subscript>
<Value name="1">
<Value>pTwitterID</Value>
</Value>
<Value name="2">
<Value>pTwitterUser</Value>
</Value>
<Value name="3">
<Value>pTwitterText</Value>
</Value>
<Value name="4">
<Value>pTwitterSentiment</Value>
</Value>
<Value name="5">
<Value>pTwitterDate</Value>
</Value>
</Data>
<DefaultData>CreateTicketForTwitterRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
