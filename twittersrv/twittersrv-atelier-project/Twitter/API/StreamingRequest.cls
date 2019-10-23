Class Twitter.API.StreamingRequest Extends BaseAPIRequest
{
	Property APIServer As %String [ InitialExpression = "stream.twitter.com" ];
	
	Property APIPort As %String [ InitialExpression = "443" ];
	
	Property APIVersion As %String [ InitialExpression = "1.1" ];
	
	Property APIMethod As %String [ InitialExpression = "statuses/filter" ];

	Property Language As %String;
	
	Property Track As %String;
	
	Property Follow As %String;
	
	Method LanguageSet(pVal As %String) As %Status
	{
		Do ..Parameters.SetAt(pVal, "language")
	}

	Method TrackSet(pVal As %String) As %Status 
	{
		Do ..Parameters.SetAt(pVal, "track")
	}

	Method FollowSet(pVal As %String) As %Status
	{
		Do ..Parameters.SetAt(pVal, "follow")
	}	

	Method %OnNew(pConsumerKey As OAuth1.ConsumerKey, pAccessToken As OAuth1.AccessToken) As %Status
	{
		// Support tweets with more than 140 characters	
		Do ..Parameters.SetAt("extended","tweet_mode")
		
		Quit ##super(pConsumerKey, pAccessToken, "HMACSHA1")
	}	

}