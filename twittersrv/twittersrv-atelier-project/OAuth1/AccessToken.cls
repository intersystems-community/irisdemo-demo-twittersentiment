Class OAuth1.AccessToken Extends %RegisteredObject
{
	Property AccessToken As %String;
	
	Property AccessSecret As %String;
	
	Method %OnNew(pAccessToken As %String = "", pAccessSecret As %String = "") As %Status
	{
		If $IsObject(pAccessToken) && (pAccessToken.%IsA("Ens.Config.Credentials"))
		{
			Set ..AccessToken=pAccessToken.Username
			Set ..AccessSecret=pAccessToken.Password
		}
		Else
		{
			Set ..AccessToken = pAccessToken
			Set ..AccessSecret = pAccessSecret
		}
		
		Quit $$$OK
	}
}