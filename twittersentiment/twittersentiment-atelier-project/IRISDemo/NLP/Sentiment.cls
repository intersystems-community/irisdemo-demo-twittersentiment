Include (DEMOMACROS, %IKPublic)

Class IRISDemo.NLP.Sentiment
{
	/// <p>Throws exceptions</p>
	/// <p>This method is called by the IRISDemo.Data.Tweets class service to evaluate the sentiment of a tweet that has just been saved.</p>
	/// <p>NLP can help us to evaluate sentiment more precisely because:</p>
	/// <ol>
	///		<li>It can decompose the strings into proper normalized entities and apply dictionary to correct slangs and misspellings.</li> 
	/// 	<li>It can apply dictionaries to label entities as POSITIVE or NEGATIVE.</li>
	///		<li>It can evaluate if sentences have been negated. Negation evaluation is complex and relies on NLP's language model.</li>
	///		<li>It can evaluate if business terms are being mentioned based on a NLP matching dictionary and give more importance to these sentences.</li>
	///		<li>It will compute a positive or negative score based on the positive and negative feeling</li> 
	/// </ol> 
	/// <p>As you can realize, sentiment analysis is not only about verifying if a string is on our text.</p>
	/// <p> The method will take an NLP ExternalSourceId and return a float with its score (that can be positive or negative).</p>
	ClassMethod EvaluateSentiment(pNLPDomainName As %String, pNLPExternalSourceId As %String, Output pScorePerBusinessTerm As %String, pVerbose As %Boolean = 0) As %Integer
	{			
		// The Domain Id is required by most API calls
		Set tDomainId = ##class(%SYSTEM.iKnow).GetDomainId(pNLPDomainName)
		If tDomainId="" $$$ThrowException("NLPDomainNotFoundException", pNLPDomainName) 

		// Required by SentenceAPI GetAttributes
		Set tSourceId = ##class(%iKnow.Queries.SourceAPI).GetSourceId(tDomainId, pNLPExternalSourceId, .tSC)
		$$$ThrowStatusExceptionIfError(tSC, "NLPGetSourceIdException")
		
		Quit ..EvaluateSentimentWithSourceId(tDomainId, tSourceId, .pScorePerBusinessTerm, pVerbose)	
	}
	
	ClassMethod EvaluateSentimentWithSourceId(pNLPDomainNameOrId As %String, pNLPSourceId As %String, Output pScorePerBusinessTerm As %String, pVerbose As %Boolean = 0) As %Integer
	{	
		// By default, this will be a neutral text
		Set iSentimentScore=0
		Kill pScorePerBusinessTerm
		
		If pNLPDomainNameOrId?1.N
		{
			// Received the Domain Id (a number)
			Set tDomainId=pNLPDomainNameOrId
		}
		Else
		{
			// Received the domain name. Must transform it to the domain Id
			Set tDomainId = ##class(%SYSTEM.iKnow).GetDomainId(pNLPDomainNameOrId)
			If tDomainId="" $$$ThrowException("NLPDomainNotFoundException", pNLPDomainNameOrId) 			
		}
		
		Write:pVerbose !,"Using domain with ID ",tDomainId
		
		// We will be using this matching dictionary in order to focus on sentences that are directly related to our business
		Set tMatchingDictId = ##class(%iKnow.Matching.DictionaryAPI).GetDictionaryId(tDomainId, "BusinessMatchingDictionary", .tSC)
		$$$ThrowStatusExceptionIfError(tSC, "NLPGetDictionaryIdException")
		
		Write:pVerbose !,"Using business matching dictionary with ID ",tMatchingDictId
		/* 
		
		NLP structures text in the following way:
		- A tweet is a Source
		- A source has Sentences. 
		- Sentences have entities in the form Concept-Relation-Concept (CRC) and can have many entities such as CRCRC...
		
		A tweet can have one or more sentences. Each can have a negative sentiment or not. 
		A negative sentiment is represented by the SENTNEGATIVE label while a positive sentiment is represented by 
		the SENTPOSITIVE label. 
		
		The catch is that a sentence can be negated. While "This is a very bad product" is clearly a SENTNEGATIVE,
		"This is not such a bad product" is not. The negation, negates the bad sentiment. But it is not a positive
		sentiment either...
		
		Also, a sentence such as "My mom is crazy. She bought me the phone that I wanted!" is clearly something
		positive for us.  But "crazy" has a negative sentiment associated to it and even if that sentiment was
		literal (the mom is really crazy which is a bad thing) it has nothing to do with the phone (that may be 
		a business term or product name that we are interested at). So, sentiment about things that has nothing
		to do with us should affect us less.
		
		So, instead of categorically stating our tweets as neutral, positive or negative, we will be giving
		them a score. Also, a sentence that mention words that are connected to our business will have more weight 
		(positive or negative) on the final score.
		
		This implementation is not perfect, but it demos pretty well several aspects of our NLP engine such as:
		- Sentiment analysis per sentence
		- Negation analysis per path and sentence
		- Usage of dictionary for supporting sentiment analysis 
		- Usage of dictionary for normalization and detection of business concepts
		- Abstraction of how text is parsed
		
		*/

		Write:pVerbose !,"Source Id: ",pNLPSourceId
		
		// Sources have sentences, let's get the sentences using the SentenceAPI:
		Set tSC = ##class(%iKnow.Queries.SentenceAPI).GetBySource(.vSentences, tDomainId, pNLPSourceId, 1, 20)
		$$$ThrowStatusExceptionIfError(tSC, "NLPSentenceAPIGetBySourceException")
						
		Set iSentenceNum=""
		For
		{
			Set iSentenceNum=$Order(vSentences(iSentenceNum))
			Quit:iSentenceNum=""
			
			// Getting the sentence ID and Text
			Set iSentId=$ListGet(vSentences(iSentenceNum),1)
			Set iSentText=$ListGet(vSentences(iSentenceNum),2)
			
			Write:pVerbose !!,"* SENTENCE ID: ",iSentId,", TEXT: ",iSentText,!
												
			// Let's look at the labels (sentnegative, sentpositive or none) that our dictionary assigned to it:
			Kill vSentAttributesResult
			Set tSC = ##class(%iKnow.Queries.SentenceAPI).GetAttributes(.vSentAttributesResult, tDomainId, iSentId, , 1)
			$$$ThrowStatusExceptionIfError(tSC, "GetAttributesException")
			
			// Let's index the attributes so we can easily look at them:
			Set iAttr=""
			Kill vAttributes
			For 
			{
				Set iAttr=$Order(vSentAttributesResult(iAttr))
				Quit:iAttr=""
				
				Set tAttr = $ListGet(vSentAttributesResult(iAttr),2)
				Continue:tAttr=""
				
				If '$Data(vAttributes(tAttr))
				{
					Set vAttributes(tAttr)=""
				
					Write:pVerbose $C(9),"Sentiment: ",tAttr,!
				}
			}
			
			// Now let's see if on this sentence, some terms from our BUSINESS dictionary were mentioned:
			Kill vMatches
			Set tSC = ##class(%iKnow.Matching.MatchingAPI).GetMatchesBySentence(.vMatches, tDomainId, iSentId, $ListBuild(tMatchingDictId))
			$$$ThrowStatusExceptionIfError(tSC, "NLPGetMatchesByPathException")
			
			// If the sentiment is not associated with our business concepts, it will have a very low weight
			Set iBusinessConceptMultiplier=0.2 //(20%)
			
			Set iMatch="" 
			Kill vPathURIs
			For
			{
				Set iMatch=$Order(vMatches(iMatch))
				Quit:iMatch=""
				
				Set tMatchURI=$ListGet(vMatches(iMatch), 4)
								
				If '$Data(vMatchedURIs(tMatchURI))
				{
					// So we can report what broader business category this text is about and route appropriately
					Set vMatchedURIs(tMatchURI)=""

					// If this sentence is directly connected to our business, then we should fully consider (100%) its score
					Set iBusinessConceptMultiplier=1
					
					Write:pVerbose $C(9),"Business Concept: ",tMatchURI,!
				}
			}
			
			// By default, we have a Neutral sentiment. We need to know if this is something else
			Set iSentiment=0
			
			// Let's see if this looks like a negative sentiment:
			If $Data(vAttributes("sentpositive")) && $Data(vAttributes("negation"))
			{
				Set iSentiment=-0.5 //Not good is not really BAD 
			} 
			If $Data(vAttributes("sentnegative")) && $Data(vAttributes("negation"))
			{
				Set iSentiment=0.5 //Not bad is not really good
			} 
			ElseIf $Data(vAttributes("sentnegative")) && '$Data(vAttributes("negation"))
			{
				Set iSentiment=-1 //Definitely BAD
			}
			ElseIf $Data(vAttributes("sentpositive")) && '$Data(vAttributes("negation"))
			{
				Set iSentiment=1 //Good!
			}
			
			Write:pVerbose $C(9),"BCM ",iBusinessConceptMultiplier," * Sentiment of ",iSentiment," = "
			
			// Now that we have a score, let's multiply it by a Business Concept Presence weight
			Set iSentiment=iSentiment*iBusinessConceptMultiplier
			
			Write:pVerbose iSentiment,!
			
			// Let's accumulate this sentence score on the full text sentence score 
			Set iSentimentScore=iSentimentScore+iSentiment
			
			// And let's accumulate this score associated to the business terms found or to "other" themes
			If iSentiment'=0
			{
				Set term="" 
				For iTerm=0:1  
				{
					Set term=$Order(vMatchedURIs(term))
					Quit:term=""  
					
					Set termSuffix=$Piece(term, ":", 2)
					Set pScorePerBusinessTerm(termSuffix)=$Get(pScorePerBusinessTerm(termSuffix))+iSentiment
				}
				
				// If no business term were found on this sentence:
				If iTerm=0
				{
					Set pScorePerBusinessTerm("others")=$Get(pScorePerBusinessTerm("others"))+iSentiment
				}
			}
			
		} //For
				
		Quit iSentimentScore	
	}
	
	ClassMethod Test()
	{
		Set tTestDomainName="TwitterAnalytics"
		
		Try
		{
			For
			{
				Write #,!,"Enter text:",!
				Read tText
				
				Quit:tText=""
				
				Set iIdentifier=$Increment(^NLP.Sentiment.Test)
				
				Set tSC = $System.iKnow.IndexString(tTestDomainName, iIdentifier, tText,,0, .tSrcId)
				$$$ThrowStatusExceptionIfError(tSC, "IndexStringException")
				
				Write !!,"Evaluating sentiment:",!!
				Set iSentimentScore = ..EvaluateSentimentWithSourceId(tTestDomainName, tSrcId, .vScorePerBusinessTerm, 1)
				
				Write !,"Sentiment score: ",iSentimentScore
				Write !,"Score per business term: ",!
				ZWrite vScorePerBusinessTerm
				Read pause
			}
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
			Do $System.Status.DisplayError(tSC)
		}
	}
}