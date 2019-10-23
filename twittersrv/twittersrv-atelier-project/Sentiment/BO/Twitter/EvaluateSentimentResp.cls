Class Sentiment.BO.Twitter.EvaluateSentimentResp Extends (%Persistent,Ens.Response)
{
	Property SentimentScore As %Float;
	
	/// The key is the business concept. The value is the score.
	Property SentimentScorePerBusinessTerm As Array Of %Float;
	
Storage Default
{
<Data name="EvaluateSentimentRespDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SentimentScore</Value>
</Value>
</Data>
<Data name="SentimentScorePerBusinessTerm">
<Attribute>SentimentScorePerBusinessTerm</Attribute>
<Structure>subnode</Structure>
<Subscript>"SentimentScorePerBusinessTerm"</Subscript>
</Data>
<DataLocation>^SentimentA9BC.EvaluateSen1E04D</DataLocation>
<DefaultData>EvaluateSentimentRespDefaultData</DefaultData>
<IdLocation>^SentimentA9BC.EvaluateSen1E04D</IdLocation>
<IndexLocation>^SentimentA9BC.EvaluateSen1E04I</IndexLocation>
<StreamLocation>^SentimentA9BC.EvaluateSen1E04S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}