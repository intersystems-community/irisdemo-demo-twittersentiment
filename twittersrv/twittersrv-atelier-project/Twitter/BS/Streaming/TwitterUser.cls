Class Twitter.BS.Streaming.TwitterUser  Extends (%SerialObject, %XML.Adaptor)
{
	Index TwitterUserIdIndex On UserId [ IdKey ];
	
	Property UserId As %BigInt [ Required ];
	
	Property UserName As %String [ Required ];
	
	Property ScreenName As %String [ Required ];
	
	Property Location As %String (MAXLEN="");
	
	Property URL As %String(MAXLEN="");
	
	Property Description As %String(MAXLEN="");
	
	Property FollowersCount As %Integer;
	
	Property FriendsCount As %Integer;
	
	Property ListedCount As %Integer;
	
	Property FavouritesCount As %Integer;
	
	Property StatusesCount As %Integer;
	
	Property "created_at" As %String;
	
	Property Language As %String;
	
	Property "ProfileImageURL" As %String (MAXLEN="");
	
	Method PopulateFromJSON(pJSONUser As %Library.DynamicObject)
	{
		#Dim iterator As %Iterator.Object
				
		Set ..UserId=+pJSONUser.id
		Set ..UserName = pJSONUser.name
		Set ..ScreenName = pJSONUser."screen_name"
		Set ..Location = pJSONUser.location
		Set ..URL = pJSONUser.url
		Set ..Description = pJSONUser.description
		Set ..FollowersCount = +pJSONUser."followers_count"
		Set ..FriendsCount = +pJSONUser."friends_count"
		Set ..Language=pJSONUser.lang
		Set ..ListedCount = +pJSONUser."listed_count"
		Set ..FavouritesCount = +pJSONUser."favourites_count"
		Set ..StatusesCount = +pJSONUser."statuses_count"
		Set ..ProfileImageURL = pJSONUser."profile_image_url_https"
		
		Set .."created_at" = pJSONUser."created_at"
	}
	
Storage Default
{
<Data name="TwitterUserState">
<Value name="1">
<Value>UserId</Value>
</Value>
<Value name="2">
<Value>UserName</Value>
</Value>
<Value name="3">
<Value>ScreenName</Value>
</Value>
<Value name="4">
<Value>Location</Value>
</Value>
<Value name="5">
<Value>URL</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>FollowersCount</Value>
</Value>
<Value name="8">
<Value>FriendsCount</Value>
</Value>
<Value name="9">
<Value>ListedCount</Value>
</Value>
<Value name="10">
<Value>FavouritesCount</Value>
</Value>
<Value name="11">
<Value>StatusesCount</Value>
</Value>
<Value name="12">
<Value>created_at</Value>
</Value>
<Value name="13">
<Value>Language</Value>
</Value>
<Value name="14">
<Value>ProfileImageURL</Value>
</Value>
</Data>
<State>TwitterUserState</State>
<StreamLocation>^Twitter.BS.Str6BDE.TwitterUserS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}