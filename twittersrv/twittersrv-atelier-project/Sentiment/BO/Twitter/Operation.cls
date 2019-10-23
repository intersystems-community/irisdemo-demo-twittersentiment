Include DEMOMACROS

Class Sentiment.BO.Twitter.Operation extends Ens.BusinessOperation {

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method EvaluateSentiment(pInput As Sentiment.BO.Twitter.EvaluateSentimentReq, Output pOutput As Ens.Response) As %Status
{
	#Dim oHttpResponse As %Net.HttpResponse
	#Dim doRequest As %Library.DynamicObject
	
	Set tSC = $$$OK
	Try
	{
		Set doRequest = 
			{
				"TweetStatusId": (pInput.TweetStatusId),
				"CreatedAt": (pInput.CreatedAt),
				"UserScreenName": (pInput.UserScreenName),
				"Text": (pInput.Text),
				"RetweetCount": (pInput.RetweetCount),
				"Language": (pInput.Language),
				"ReplyCount": (pInput.ReplyCount)
			}
			
		Do doRequest.%Set("IsRetweet", pInput.ReplyCount, "boolean")
		
		Set oJSONStream = ##class(%Stream.TmpCharacter).%New()
		Do doRequest.%ToJSON(.oJSONStream)
		
		Set arParams(1)=oJSONStream
		
		Set tSC = ..Adapter.PostFormDataArray(.oHttpResponse, , .arParams)
		$$$ThrowStatusExceptionIfError(tSC, "PostFormDataArrayException")
		
		If oHttpResponse.Data="" $$$ThrowException("NoResponseReceivedException","")
		
		Try
		{
			Set doResponse = ##class(%Library.DynamicObject).%FromJSON(oHttpResponse.Data)
		}
		Catch (oJSONException)
		{
			Set tResponse = oHttpResponse.Data
			If $IsObject(tResponse) Do tResponse.Rewind() Set tResponse=tResponse.Read()
			$$$ThrowException("CouldNotParseResponseException", oJSONException.Name_":"_tResponse)
		}
		
		If doResponse.CallResult.Status'="OK"
		{
			$$$ThrowException("RESTServiceException", doResponse.CallResult.Exception)
		}
		
		Set pOutput = ##class(EvaluateSentimentResp).%New()
		Set pOutput.SentimentScore=doResponse.sentimentScore
		
		If $IsObject(doResponse.scoreByBusinessTerm)
		{
			Set doIterator = doResponse.scoreByBusinessTerm.%GetIterator()
			
			While doIterator.%GetNext(,.obj)
			{
				Do pOutput.SentimentScorePerBusinessTerm.SetAt(obj.score, obj.term)
			}
		}
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	Quit tSC
}

XData MessageMap {
<MapItems>
    <MapItem MessageType="Sentiment.BO.Twitter.EvaluateSentimentReq">
        <Method>EvaluateSentiment</Method>
    </MapItem>
</MapItems>
}

}