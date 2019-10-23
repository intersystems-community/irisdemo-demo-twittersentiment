Class OAuth1.ConsumerKey Extends %RegisteredObject
{
	Property ConsumerKey As %String;
	
	Property ConsumerSecret As %String;

	Method %OnNew(pConsumerKey As %String = "", pConsumerSecret As %String = "") As %Status
	{
		If $IsObject(pConsumerKey) && (pConsumerKey.%IsA("Ens.Config.Credentials"))
		{
			Set ..ConsumerKey=pConsumerKey.Username
			Set ..ConsumerSecret=pConsumerKey.Password
		}
		Else
		{
			Set ..ConsumerKey = pConsumerKey
			Set ..ConsumerSecret = pConsumerSecret
		}
		
		Quit $$$OK
	}

}