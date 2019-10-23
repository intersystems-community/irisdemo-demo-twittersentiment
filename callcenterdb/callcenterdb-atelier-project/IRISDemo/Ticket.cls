Class IRISDemo.Ticket Extends %Persistent
{
	Property TicketID As %String; 
	
	Property TicketUser As %String;
	  
	Property TicketText As %String(MAXLEN="");
	
	Property TicketFeedback As %String;
	 
	Property TicketDate As %Date;
	 
	Property TicketResponse As %String(MAXLEN="");

Storage Default
{
<Data name="TicketDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TicketID</Value>
</Value>
<Value name="3">
<Value>TicketUser</Value>
</Value>
<Value name="4">
<Value>TicketText</Value>
</Value>
<Value name="5">
<Value>TicketFeedback</Value>
</Value>
<Value name="6">
<Value>TicketDate</Value>
</Value>
<Value name="7">
<Value>TicketResponse</Value>
</Value>
</Data>
<DataLocation>^IRISDemo.TicketD</DataLocation>
<DefaultData>TicketDefaultData</DefaultData>
<IdLocation>^IRISDemo.TicketD</IdLocation>
<IndexLocation>^IRISDemo.TicketI</IndexLocation>
<StreamLocation>^IRISDemo.TicketS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}