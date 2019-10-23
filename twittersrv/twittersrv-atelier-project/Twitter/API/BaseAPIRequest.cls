Class Twitter.API.BaseAPIRequest Extends OAuth1.BaseRequest
{
	/// Example: api.twitter.com, stream.twitter.com, etc.
	Property APIServer As %String;
	
	Property APIPort As %String [ InitialExpression = "443" ];
	
	Property APIVersion As %String [ InitialExpression = "1.1" ];
	
	/// Example: statuses/filter
	Property APIMethod As %String;
		
	Method %OnNew(pConsumerKey As OAuth1.ConsumerKey, pAccessToken As OAuth1.AccessToken, pSignatureMethod As %String) As %Status
	{		
		Set ..URL = "https://"_..APIServer_"/"_..APIVersion_"/"_..APIMethod_".json"

		Quit ##super(pConsumerKey, pAccessToken, pSignatureMethod)
	}	

}