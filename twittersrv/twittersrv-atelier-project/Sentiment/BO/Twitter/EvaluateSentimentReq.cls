Class Sentiment.BO.Twitter.EvaluateSentimentReq Extends (%Persistent,Ens.Request)
{

	Property TweetStatusId As %BigInt [ Required ];
	
	Property CreatedAt As %TimeStamp [ Required ];
	
	Property UserScreenName As %String [ Required ];
	
	Property Text As %String (MAXLEN="")[ Required ];
	
	Property Language As %String  [ InitialExpression = {"en"}, Required ];
	
	Property RetweetCount As %Integer [ InitialExpression = 0, Required ];
	
	Property ReplyCount As %Integer [ InitialExpression = 0, Required ];
	
	Property IsRetweet As %Boolean [ InitialExpression = 0, Required ];
	
Storage Default
{
<Data name="EvaluateSentimentReqDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TweetStatusId</Value>
</Value>
<Value name="3">
<Value>CreatedAt</Value>
</Value>
<Value name="4">
<Value>UserScreenName</Value>
</Value>
<Value name="5">
<Value>Text</Value>
</Value>
<Value name="6">
<Value>RetweetCount</Value>
</Value>
<Value name="7">
<Value>Language</Value>
</Value>
<Value name="8">
<Value>ReplyCount</Value>
</Value>
<Value name="9">
<Value>IsRetweet</Value>
</Value>
</Data>
<DataLocation>^SentimentA9BC.EvaluateSenC5D9D</DataLocation>
<DefaultData>EvaluateSentimentReqDefaultData</DefaultData>
<IdLocation>^SentimentA9BC.EvaluateSenC5D9D</IdLocation>
<IndexLocation>^SentimentA9BC.EvaluateSenC5D9I</IndexLocation>
<StreamLocation>^SentimentA9BC.EvaluateSenC5D9S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

} 