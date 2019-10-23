Class Twitter.BS.Streaming.Tweet Extends (%Persistent,%XML.Adaptor)
{
	Index TweetStatusIdIndex On TweetStatusId [ IdKey ];
	
	Property TweetStatusId As %BigInt [ Required ];
	
	Property CreatedAt As %TimeStamp [ Required ];
	
	Property Text As %String (MAXLEN="") [ Required ];
	
	Property InReplyToStatusId As %Integer;
	
	Property InReplyToUserId As %Integer;
	
	Property InReplyToScreenName As %String;
	
	Property User As Twitter.BS.Streaming.TwitterUser [ Required ];
	
	Property ReplyCount As %Integer;
	
	Property RetweetCount As %Integer;
	
	Property FavoriteCount As %Integer;
	
	Property QuoteCount As %Integer;
	
	Property Entities As Twitter.BS.Streaming.TwitterEntities;
	
	Property Retweeted As %Boolean [ InitialExpression = 0, Required ];
	
	Property Language As %String;
	
	Property IsRetweet As %Boolean [ InitialExpression = 0, Required ];
	
	Property RetweetedStatus As Tweet;
	
	ClassMethod CreateFromJSON(pJSONTweet As %Library.DynamicObject) As Twitter.BS.Streaming.Tweet
	{
		#Dim iterator As %Iterator.Object
		
		Set tweet = ..%New()
		Set tweet.TweetStatusId = pJSONTweet.id
		Set tweet.CreatedAt = $ZDateTime(##class(Twitter.Utils).TwitterTimestampInH(+pJSONTweet."timestamp_ms"),3)
		
		// https://developer.twitter.com/en/docs/tweets/tweet-updates
		If pJSONTweet.%IsDefined("extended_tweet")
		{
			Set tweet.Text = pJSONTweet."extended_tweet"."full_text"
			
			Do tweet.Entities.PopulateFromJSON(pJSONTweet."extended_tweet".entities)
		}
		Else
		{
			If pJSONTweet.%IsDefined("full_text")
			{
				Set tweet.Text = pJSONTweet."full_text"
			}
			Else
			{
				Set tweet.Text = pJSONTweet."text"
			}
			
			Do tweet.Entities.PopulateFromJSON(pJSONTweet.entities)
		}
		
		Do tweet.User.PopulateFromJSON(pJSONTweet.user)
		
		Set tweet.InReplyToStatusId = +pJSONTweet."in_reply_to_status_id"
		Set tweet.InReplyToUserId = +pJSONTweet."in_reply_to_user_id"
		Set tweet.InReplyToScreenName = pJSONTweet."in_reply_to_screen_name"		
		Set tweet.ReplyCount = +pJSONTweet."reply_count"
		Set tweet.RetweetCount = +pJSONTweet."retweet_count"
		Set tweet.Retweeted = +pJSONTweet.retweeted
		Set tweet.FavoriteCount = +pJSONTweet."favorite_count"
		Set tweet.QuoteCount = +pJSONTweet."quote_count"
		Set tweet.Language = pJSONTweet.lang
		
		If pJSONTweet.%IsDefined("retweeted_status")
		{
			// This tweet is a retweet
			Set tweet.IsRetweet = 1
			
			Set tweet.RetweetedStatus=..%OpenId(pJSONTweet."retweeted_status".id)
			If tweet.RetweetedStatus=""
			{
				Set tweet.RetweetedStatus=..CreateFromJSON(pJSONTweet."retweeted_status")
				Set tweet.RetweetedStatus.Retweeted =1
			}
			Else
			{
				Do tweet.RetweetedStatus.UpdateRetweetStatisticsFromJSON(pJSONTweet."retweeted_status")
			}
		}
		
		Quit tweet
	}
	
	/// We only want to update the retweet statistics
	Method UpdateRetweetStatisticsFromJSON(pJSONTweet As %Library.DynamicObject)
	{
		#Dim iterator As %Iterator.Object
				
		Set ..ReplyCount = +pJSONTweet."reply_count"
		Set ..RetweetCount = +pJSONTweet."retweet_count"
		Set ..FavoriteCount = +pJSONTweet."favorite_count"
		Set ..QuoteCount = +pJSONTweet."quote_count"		
	}
	


Storage Default
{
<Data name="TweetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CreatedAt</Value>
</Value>
<Value name="3">
<Value>Text</Value>
</Value>
<Value name="4">
<Value>InReplyToStatusId</Value>
</Value>
<Value name="5">
<Value>InReplyToUserId</Value>
</Value>
<Value name="6">
<Value>InReplyToScreenName</Value>
</Value>
<Value name="7">
<Value>User</Value>
</Value>
<Value name="8">
<Value>ReplyCount</Value>
</Value>
<Value name="9">
<Value>RetweetCount</Value>
</Value>
<Value name="10">
<Value>FavoriteCount</Value>
</Value>
<Value name="11">
<Value>QuoteCount</Value>
</Value>
<Value name="12">
<Value>Entities</Value>
</Value>
<Value name="13">
<Value>Retweeted</Value>
</Value>
<Value name="14">
<Value>Language</Value>
</Value>
<Value name="15">
<Value>IsRetweet</Value>
</Value>
<Value name="16">
<Value>RetweetedStatus</Value>
</Value>
</Data>
<DataLocation>^Twitter.BS.Streaming.TweetD</DataLocation>
<DefaultData>TweetDefaultData</DefaultData>
<IdLocation>^Twitter.BS.Streaming.TweetD</IdLocation>
<IndexLocation>^Twitter.BS.Streaming.TweetI</IndexLocation>
<StreamLocation>^Twitter.BS.Streaming.TweetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}