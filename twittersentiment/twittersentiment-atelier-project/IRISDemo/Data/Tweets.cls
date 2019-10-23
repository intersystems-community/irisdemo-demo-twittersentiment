Include DEMOMACROS

Class IRISDemo.Data.Tweets Extends %Persistent
{
	Property TweetStatusId As %BigInt [ Required ];
	
	Property Text As %String (MAXLEN="") [ Required ];

	Property UserScreenName As %String [ Required ];
	
	Property RetweetCount As %Integer;
	
	Property Language As %String;
	
	Property ReplyCount As %Integer;
	
	Property IsRetweet As %Boolean;
	
	Property RetweetedStatusId As %BigInt;
	
	/// 0 is neutral. The more negative is the value the more negative is the sentiment. 
	/// The more positive is the value, the more positive is the sentiment.
	Property SentimentScore As %Float [ InitialExpression = 0, Required ];
	
	/// The key of the array is a business term defined as a matching dictionary in the NLP domain. 
	/// The value of the array is the score accumulated by this business term in the whole Text
	Property SentimentScorePerBusinessTerm As Array Of %Float;
	
	Property NLPExternalSourceId As %String [ SqlComputed, SqlComputeCode = {Set {NLPExternalSourceId}=":SQL:"_{UserScreenName}_":"_{TweetStatusId} } ];
		
	Index TweetStatusIdIndex On TweetStatusId [ Unique ];
	
	Trigger OnAddOrUpdate [Event = INSERT/UPDATE, Foreach = row/object, Time = AFTER ]
	{
		// A trigger runs inside a TRANSACTION. So it is all or nothing. If we throw an error
		// here, we will rollback the entire transaction, which is good.
		
		// A trigger is different from a method. There is no scope. So we must New the variable
		// names we create in order to prevent reusing an existing variable from another "scope".
		New tDomainId,tMetadataFields,tSC,tSourceId,tID
		
		// We are going to need the DomainId to call GetSourceId
		Set tDomainId = ##class(%SYSTEM.iKnow).GetDomainId("TwitterAnalytics")
		
		// One way of returning an error is by setting the variables %ok and %msg. But throwing
		// an exception is much more elegant. IRIS will catch the exception and do the rest for us.
		If tDomainId="" $$$ThrowException("NLPDomainNotFoundException", "TwitterAnalytics") 

		// We only want to populate the NLP Domain once. If we did that already
		// we don't want to do it again. I will find out how to do that in the future.
		// So we will try to find the internal SourceId for our ExternalSourceId. If we don't find
		// one, it is safe to assume this is a brand new tweet that needs to be populated into the domain
		Set tSourceId = ##class(%iKnow.Queries.SourceAPI).GetSourceId(tDomainId, {NLPExternalSourceId*N}, .tSCIgnored)

		// Found it! So, we have already saved this tweet's data on the domain.
		// We need to delete it before trying to load it again.
		If tSourceId'="" 
		{
			Set tSC = $System.iKnow.DeleteSource("TwitterAnalytics", tSourceId)
			$$$ThrowStatusExceptionIfError(tSC, "NLPDeleteSourceException")
		}
		
		// Ok, that is brand new tweet. Let's populate the domain with its data
		
		Set tMetadataFields=$ListBuild("TweetStatusId", "UserScreenName","RetweetCount","ReplyCount","IsRetweet")
		
		Set tSC = $System.iKnow.IndexTable("TwitterAnalytics", "IRISDemo_Data.Tweets", "TweetStatusId", "UserScreenName", "Text", tMetadataFields, "ID='"_{ID*N}_"'")
		$$$ThrowStatusExceptionIfError(tSC, "NLPIndexTableException")
	}
	
	ClassMethod OpenByTweetId(pTweetId As %String) As IRISDemo.Data.Tweets
	{
		Quit ..TweetStatusIdIndexOpen(pTweetId)
	}
	
	/*
	/// <p>Throws exceptions</p>
	/// <p>This method must is called by the REST service to evaluate the sentiment of a tweet that has just been saved.</p>
	/// <p>NLP can help us to evaluate sentiment more precisely because:</p>
	/// <ol>
	///		<li>It can decompose the strings into proper normalized entities and apply dictionary to correct slangs and misspellings.</li> 
	/// 	<li>It can apply dictionaries to label entities as POSITIVE or NEGATIVE.</li>
	///		<li>It can evaluate if sentences have been negated. Negation evaluation is complex and relies on NLP's language model.</li> 
	/// </ol> 
	/// <p>As you can realize, sentiment analysis is not only about verifying if a string is on our text.</p> 
	Method EvaluateSentiment()
	{
		// If we change this object, we will save it again at the end
		Set bChanged=0
		
		// By default, people only say nice things
		
		If ..Sentiment'=0
		{
			// I am using this to avoid persisting an object that hasn't changed.
			// But I am almost sure %Save is smart enough to detect that by itself
			// and avoid the work. I should check this in the future.
			Set ..Sentiment=0
			Set bChanged=1 
		}
		
		// If we don't have an ID, the trigger has never been called, so NLPExternalSourceId will be invalid
		// This tweet's data is not still on the NLP domain...
		If ..%Id()="" 
		{
			Set tSC = ..%Save()
			$$$ThrowStatusExceptionIfError(tSC, "PersistingTweetException")
		}
				
		Set ..Sentiment = ##class(IRISDemo.NLP.Sentiment).EvaluateSentiment("TwitterAnalytics", ..NLPExternalSourceId)
		
		// If we changed the object in a way or the other...
		If bChanged || (..Sentiment'=0)
		{
			Set tSC = ..%Save()
			$$$ThrowStatusExceptionIfError(tSC, "PersistUpdatedSentimentException")
		}
	}
	*/
	
	/// <p>Throws exceptions</p>
	/// <p>This method must is called by the REST service to evaluate the sentiment of a tweet that has just been saved.</p>
	/// <p>NLP can help us to evaluate sentiment more precisely because:</p>
	/// <ol>
	///		<li>It can decompose the strings into proper normalized entities and apply dictionary to correct slangs and misspellings.</li> 
	/// 	<li>It can apply dictionaries to label entities as POSITIVE or NEGATIVE.</li>
	///		<li>It can evaluate if sentences have been negated. Negation evaluation is complex and relies on NLP's language model.</li> 
	/// </ol> 
	/// <p>As you can realize, sentiment analysis is not only about verifying if a string is on our text.</p> 
	Method EvaluateSentiment()
	{
		// If we don't have an ID, the trigger has never been called, so NLPExternalSourceId will be invalid
		// This tweet's data is not still on the NLP domain...
		If ..%Id()="" 
		{
			Set tSC = ..%Save()
			$$$ThrowStatusExceptionIfError(tSC, "PersistingTweetException")
		}
				
		Set ..SentimentScore = ##class(IRISDemo.NLP.Sentiment).EvaluateSentiment("TwitterAnalytics", ..NLPExternalSourceId, .vSentimentScorePerBusinessTerm)
		
		Do ..SentimentScorePerBusinessTerm.Clear()
		
		Set term=""
		For
		{
			Set term=$Order(vSentimentScorePerBusinessTerm(term))
			Quit:term=""
			
			Set iScore = vSentimentScorePerBusinessTerm(term)
			
			Do ..SentimentScorePerBusinessTerm.SetAt(iScore, term)
		}
		
		Set tSC = ..%Save()
		$$$ThrowStatusExceptionIfError(tSC, "PersistUpdatedSentimentException")
	}
	
	/*
	/// This has been replaced by a new version that uses $System.iKnow.IndexTable()
	Trigger OnAddOrUpdateOld [Event = INSERT/UPDATE, Foreach = row/object, Time = AFTER ]
	{
		// A trigger runs inside a TRANSACTION. So it is all or nothing. If we throw an error
		// here, we will rollback the entire transaction, which is good.
		
		// A trigger is different from a method. There is no scope. So we must New the variable
		// names we create in order to prevent reusing an existing variable from another "scope".
		New tDomainId,oNLPSQLLister,tMetadataFields,tDataField,tGroupField,tIdField,tTableName,tQuery,tSC,tSourceId,tID
		
		// We are going to need the DomainId to create the Lister and call other API methods
		Set tDomainId = ##class(%SYSTEM.iKnow).GetDomainId("TwitterAnalytics")
		
		// One way of returning an error is by setting the variables %ok and %msg. But throwing
		// an exception is much more elegant. IRIS will catch the exception and do the rest for us.
		If tDomainId="" $$$ThrowException("NLPDomainNotFoundException", "TwitterAnalytics") 

		// We only want to populate the NLP Domain once. If we did that already
		// we don't want to do it again. I will find out how to do that in the future.
		// So we will try to find the internal SourceId for our ExternalSourceId. If we don't find
		// one, it is safe to assume this is a brand new tweet that needs to be populated into the domain
		Set tSourceId = ##class(%iKnow.Queries.SourceAPI).GetSourceId(tDomainId, {NLPExternalSourceId*N}, .tSCIgnored)

		// Found it! So, we have already saved this tweet's data on the domain.
		// Until we find a way to update the domain data for a single record, we 
		// will not allow updating the domain data, but we will allow updating other
		// fields of the object for additional metadata we want to store in the future
		If tSourceId'="" Quit
		
		// Ok, that is brand new tweet. Let's populate the domain with its data

		// The lister is responsible for running our query and using its fields as TEXT and METADATE to
		// populate the domain
		SET oNLPSQLLister = ##class(%iKnow.Source.SQL.Lister).%New(tDomainId)
		
		// Populatig the variables we are going to use to call the Lister
		Set tMetadataFields=$ListBuild("TweetStatusId", "UserScreenName","RetweetCount","ReplyCount","IsRetweet")
		Set tDataField="Text"
		Set tGroupField="UserScreenName"
		Set tIdField="TweetStatusId"
		Set tTableName="IRISDemo_Data.Tweets"
		Set tQuery="select TweetStatusId, UserScreenName, Text, RetweetCount, ReplyCount, ReplyCount, IsRetweet from IRISDemo_Data.Tweets where ID='"_{ID*N}_"'"
		
		// Calling the Lister (internally the lister use a Loader)
		Set tSC = oNLPSQLLister.ProcessList(tQuery, tIdField, tGroupField, tDataField, tMetadataFields)
		$$$ThrowStatusExceptionIfError(tSC, "NLPSQLListerProcessListException")		
	}
	*/
	
Storage Default
{
<Data name="SentimentScorePerBusinessTerm">
<Attribute>SentimentScorePerBusinessTerm</Attribute>
<Structure>subnode</Structure>
<Subscript>"SentimentScorePerBusinessTerm"</Subscript>
</Data>
<Data name="TweetsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TweetStatusId</Value>
</Value>
<Value name="3">
<Value>Text</Value>
</Value>
<Value name="4">
<Value>UserScreenName</Value>
</Value>
<Value name="5">
<Value>RetweetCount</Value>
</Value>
<Value name="6">
<Value>Language</Value>
</Value>
<Value name="7">
<Value>ReplyCount</Value>
</Value>
<Value name="8">
<Value>IsRetweet</Value>
</Value>
<Value name="9">
<Value>RetweetedStatusId</Value>
</Value>
<Value name="10">
<Value>SentimentScore</Value>
</Value>
<Value name="11">
<Value>NLPExternalSourceId</Value>
</Value>
</Data>
<DataLocation>^IRISDemo.Data.TweetsD</DataLocation>
<DefaultData>TweetsDefaultData</DefaultData>
<IdLocation>^IRISDemo.Data.TweetsD</IdLocation>
<IndexLocation>^IRISDemo.Data.TweetsI</IndexLocation>
<StreamLocation>^IRISDemo.Data.TweetsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}