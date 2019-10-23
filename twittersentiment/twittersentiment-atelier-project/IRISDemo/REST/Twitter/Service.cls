Include DEMOMACROS
Class IRISDemo.REST.Twitter.Service Extends %CSP.REST
{

	Parameter UseSession = 1;
	
	Parameter CONVERTINPUTSTREAM = 1;
	
	Parameter CHARSET = "utf-8";
	
	Parameter HandleCorsRequest = 1;

	XData UrlMap
	{
		<Routes>
		  <Route Url="/" Method="POST" Call="StoreAndAnalyse"/>
		</Routes>
	}
	
	/// <p>We are storing the tweet on our persistent table because we may decide to rebuild the entire domain
	/// with new configurations, dictionaries, etc. and we don't want to re-read all this data from Twitter again.</p>
	/// <p>Also, having the data locally will allow us to apply other techniques in the future, combining NLP with ML
	/// for instance.</p>
	/// <p>By storing the tweeet on disk, a trigger will add its text to the TwitterAnalytics NLP domain. We will
	/// then call EvaluateSentiment() on the tweet to compute if it has a negative sentiment or positive sentiment.</p>
	ClassMethod StoreAndAnalyse() As %Status
	{
		Set tSC = $$$OK
		
		Try
		{
			/* 
			First, let's prepare our response object. "do" is a prefix for variables that
			stands for "dynamic object". It is just a convention.
			*/
			Set %response.ContentType=..#CONTENTTYPEJSON
			Set doResponse={} 
			Set doResponse.CallResult={} //If there is an error, this property will hold the error information
			
			// Let's now take the JSON POST data and parse it as a dynamic object so we can use its properties.
			Set doPOSTData = ##class(%DynamicObject).%FromJSON(%request.Content)
			
			//Verify if the right parameters are present and throw an exception if they aren't
			If doPOSTData.TweetStatusId ="" $$$ThrowException("MissingFieldsException", "TweetStatusId")
			If doPOSTData.CreatedAt ="" $$$ThrowException("MissingFieldsException", "CreatedAt")
			If doPOSTData.Text ="" $$$ThrowException("MissingFieldsException", "Text")
			If doPOSTData.UserScreenName ="" $$$ThrowException("MissingFieldsException", "UserScreenName")
			If doPOSTData.RetweetCount ="" $$$ThrowException("MissingFieldsException", "RetweetCount")
			If doPOSTData.Language ="" $$$ThrowException("MissingFieldsException", "Language")
			If doPOSTData.ReplyCount ="" $$$ThrowException("MissingFieldsException", "ReplyCount")
			If doPOSTData.IsRetweet ="" $$$ThrowException("MissingFieldsException", "IsRetweet")
			
			If doPOSTData.IsRetweet
			{
				If doPOSTData.RetweetedStatusId ="" $$$ThrowException("MissingFieldsException", "RetweetedStatusId")
			}
			
			// Here is the first thing this method does. Let's create a a new record on our
			// persistent table to store the data. Our persistent table has a trigger that will make sure
			// that the tweet data will be kept in sync with the NLP Domain
			
			Set tweet = ##class(IRISDemo.Data.Tweets).OpenByTweetId(doPOSTData.TweetStatusId)
			If '$IsObject(tweet)
			{			
				Set tweet = ##class(IRISDemo.Data.Tweets).%New()
				Set tweet.TweetStatusId = doPOSTData.TweetStatusId 
				Set tweet.UserScreenName = doPOSTData.UserScreenName
				Set tweet.Text = doPOSTData.Text
				Set tweet.RetweetCount = doPOSTData.RetweetCount
				Set tweet.Language = doPOSTData.Language
				Set tweet.ReplyCount = doPOSTData.ReplyCount
				Set tweet.IsRetweet = doPOSTData.IsRetweet
				Set tweet.RetweetedStatusId = doPOSTData.RetweetedStatusId
				
				Set tSC = tweet.%Save()
				$$$ThrowStatusExceptionIfError(tSC, "PersistingTweetException")
				
				Do tweet.EvaluateSentiment()
			}
			
			// Populating our REST response
			Set doResponse.sentimentScore=tweet.SentimentScore
			Set doResponse.scoreByBusinessTerm=[]
			
			Set tTerm=""
			For
			{
				Do tweet.SentimentScorePerBusinessTerm.GetNext(.tTerm)
				Quit:tTerm=""

				Set term = {}
				Set term.term=tTerm
				Set term.score=tweet.SentimentScorePerBusinessTerm.GetAt(tTerm)				
				
				Do doResponse.scoreByBusinessTerm.%Push(term)
			}
			
			Set doResponse.CallResult.Status="OK"
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
			
			Set doResponse.CallResult.Status="Error"
			Set doResponse.CallResult.Exception=$$$ExceptionAsJSON(oException)
		}
		
		Write doResponse.%ToJSON()
		
		// As all %Status errors have been transformed into exceptions
		// we don't need to worry about returning tSC
		Quit tSC
	}
}