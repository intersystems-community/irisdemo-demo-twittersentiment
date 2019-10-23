Include DEMOMACROS
Class Twitter.Adapter.StreamingInboundAdapter Extends Ens.InboundAdapter
{
	Parameter TwitterAPIServer As %String = "stream.twitter.com";
	
	Parameter TwitterAPIVersion As %String = "1.1";
	
	Parameter TwitterAPIMethod As %String = "statuses/filter";
	
	Parameter TwitterUserAgent As %String = "IRIS Twitter Streaming Demo Adapter 1.0";
	
	Parameter SSLCONFIG As %String = "Twitter";
		
	Property Timeout As %Integer [ InitialExpression = 5 ];
			
	/// Overriding. The username must be your Twitter Application's API Key and the password must be your Twitter's application API secret
	Property TwitterAppConsumerCredentials As %String [ InitialExpression = "None" ];

	/// This is the credentials object for TwitterAppConsumerCredentials
	Property TwitterAppConsumerCredentialsObj As Ens.Config.Credentials;

	/// Overriding. The username must be your Twitter Application's Access Key and the password must be your Twitter's application Access secret
	Property TwitterAccessTokenCredentials As %String [ InitialExpression = "None" ];

	/// This is the credentials object for TwitterUserTokenCredentials
	Property TwitterAccessTokenCredentialsObj As Ens.Config.Credentials;
		
	/// A comma-separated list of phrases which will be used to determine what Tweets will be delivered on the stream. 
	/// A phrase may be one or more terms separated by spaces, and a phrase will match if all of the terms in the phrase 
	/// are present in the Tweet, regardless of order and ignoring case. By this model, you can think of commas as logical ORs, 
	/// while spaces are equivalent to logical ANDs (e.g. ‘the twitter’ is the AND twitter, and ‘the,twitter’ is the OR twitter).
	/// More information can be found on: https://developer.twitter.com/en/docs/tweets/filter-realtime/guides/basic-stream-parameters 
	Property TwitterAPITrackString As %String(MAXLEN="");
	
	/// A comma separated list of user IDs, indicating the users to return statuses for in the stream.
	/// More information can be found on: https://developer.twitter.com/en/docs/tweets/filter-realtime/guides/basic-stream-parameters  
	Property TwitterAPIFollowString As %String(MAXLEN="");
	
	/// Setting this parameter to a comma-separated list of BCP 47 language identifiers corresponding to any of
	/// the languages listed on Twitter’s advanced search page will only return Tweets that have been detected 
	/// as being written in the specified languages. For example, connecting with language=en will only stream 
	/// Tweets detected to be in the English language.
	Property TwitterAPILanguageString As %String(MAXLEN="") [ InitialExpression = "en" ];
	
	Property TwitterConsumerKey As OAuth1.ConsumerKey;
	
	Property TwitterAccessToken As OAuth1.AccessToken;
	
	Property TwitterStreamingHasStarted As %Boolean [ InitialExpression = 0 ];
	
	Property TwitterStreamingRequest As Twitter.API.StreamingRequest;
	
	Property TwitterStreamingConnection As Twitter.API.StreamingConnection;
	
	/// OnTask is called every 100ms (by CallInterval). If we only read a single tweet on every OnTask
	/// our throughput could be too slow (10 tweets per second). This property allows one to adjust this
	/// to higher throughputs. 
	Property TweetsPerCallInterval As %Integer [ InitialExpression = 2 ];
	
	Property ConnectionAttempts As %Integer [ Private ];
	
	/// Upper limit in seconds to the waiting time for the twitter "back-off pattern".
	/// After this time, we will send a single alert but will keep trying a new connection at every FailureTimeout
	Property FailureTimeout As %Integer [ InitialExpression = 300 ];
	
	Property SentLimitAlert As %Boolean [ Private ];
	
	/// Not exposing TwitterAPIFollowString right now. It is not working.
	Parameter SETTINGS = "TweetsPerCallInterval,TwitterAPITrackString,TwitterAPILanguageString,TwitterAppConsumerCredentials:Basic:credentialsSelector,TwitterAccessTokenCredentials:Basic:credentialsSelector";
	
	Method OnInit() As %Status
	{
		Set tSC = $$$OK
		Try
		{
			Kill ^twitter.debug
			
			//$$$TRACE("Validating Twitter Credentials")
			Set tSC = ..ValidateCredentials()
			Quit:$$$ISERR(tSC)
			
			Set ..TwitterConsumerKey = ##class(OAuth1.ConsumerKey).%New(..TwitterAppConsumerCredentialsObj)
			Set ..TwitterAccessToken = ##class(OAuth1.AccessToken).%New(..TwitterAccessTokenCredentialsObj)
						
			Set tSC = ..ValidateParameters()
			Quit:$$$ISERR(tSC)
			
			Set tSC=##super()
			Quit:$$$ISERR(tSC)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Quit tSC
	}
	
	/// Validates that the credential given exists and have valid username and password.
	Method ValidateCredentials()
	{
		Set tSC = $$$OK
		Try
		{
			If ..TwitterAppConsumerCredentials=""
			{
				Set tSC = $$$ERROR(5001,"You must configure your Twitter's Application Consumer Credentials (Twitter Application's Consumer Key and Consumer Secret).")
				Quit
			}
			
			If '$IsObject(..TwitterAppConsumerCredentialsObj) 
			{
				Do ..TwitterCredentialsObjSet("TwitterAppConsumerCredentials", ..TwitterAppConsumerCredentials) 
				If '$IsObject(..TwitterAppConsumerCredentialsObj) 
				{ 
					Set tSC=$$$EnsError($$$EnsErrNoCredentials,..TwitterAppConsumerCredentials) 
					Quit 
				}
				
				If (..TwitterAppConsumerCredentialsObj.Username="") || (..TwitterAppConsumerCredentialsObj.Password="")
				{
					Set tSC = $$$ERROR(5001,"Twitter Application's Consumer Credential must have a username (consumer key) and a password (consumer secret).")
					Quit
				}
			}
			
			If ..TwitterAccessTokenCredentials=""
			{
				Set tSC = $$$ERROR(5001,"You must configure your Twitter's Application Access Token Credentials (Twitter Application's Access Token and Access Token Secret).")
				Quit
			}
			
			If '$IsObject(..TwitterAccessTokenCredentialsObj) 
			{
				Do ..TwitterCredentialsObjSet("TwitterAccessTokenCredentials", ..TwitterAccessTokenCredentials) 
				If '$IsObject(..TwitterAccessTokenCredentialsObj) 
				{ 
					Set tSC=$$$EnsError($$$EnsErrNoCredentials,..TwitterAccessTokenCredentials) 
					Quit 
				}
				
				If (..TwitterAccessTokenCredentialsObj.Username="") || (..TwitterAccessTokenCredentialsObj.Password="")
				{
					Set tSC = $$$ERROR(5001,"Twitter Application's Access Token Credential must have a username (Access Token) and a password (Access Token Secret).")
					Quit
				}				
			}
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Quit tSC
	}
	
	Method ValidateParameters()
	{
		Set tSC = $$$OK
		Try
		{
			Set ..TwitterAPILanguageString=$ZStrip(..TwitterAPILanguageString,"<>W")
			Set ..TwitterAPIFollowString=$ZStrip(..TwitterAPIFollowString,"<>W")
			Set ..TwitterAPITrackString=$ZStrip(..TwitterAPITrackString,"<>W")
			
			If (..TwitterAPIFollowString="") && (..TwitterAPITrackString="")
			{
				Set tSC = $$$ERROR(5001,"You must configure either TwitterAPIFollowString (follow) or TwitterAPITrackString (track) parameter.")
				Quit
			}
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Quit tSC
	}
	
	Method TwitterCredentialsObjSet(pCredentialsPropertyName As %String, pInVal As %String) As %Status
	{
		Set tCredentialObjPropName = pCredentialsPropertyName_"Obj"
		#; (Re)Set the Credentials object; do it always because we never know if the source row fields might have been updated
		#; make sure to instantiate even if re-setting to the InitialExpression string
		Set $property($this, tCredentialObjPropName)=$$$NULLOREF
	
		Set tClassname=$zobjmethod($this,"%ClassName",1) ; call subclass
		Set tClass = $$$comMemberKeyGet(tClassname,$$$cCLASSproperty,tCredentialObjPropName,$$$cPROPtype)
		If ""'=tClass {
			Set tSC=##Class(Ens.Config.Credentials).GetCredentialsObj(.tObj,tClassname,tClass,pInVal)
			If $$$ISOK(tSC) { Set $property($this, tCredentialObjPropName)=tObj }
			ElseIf '$$$StatusEquals(tSC,$$$EnsErrNoCallerCredentials) {
				$$$LOGSTATUS(tSC)
			}
		}
		
		Quit $$$OK
	}
	
	/// If We are here, it is because OnInit() was successful. Now we need to see if we
	/// are already connected to the Twitter Streaming API or if we need to connect
	Method OnTask() As %Status
	{
		Set tSC=$$$OK
		Try
		{
			If ..TwitterStreamingConnection.StreamingStarted
			{
				Do ..ProcessNextMessage()
			}
			Else
			{
				Do ..StartStreaming()
			}
		}
		Catch (oException)
		{
			// We will not disconnect/reconnect to twitter because an error on ProcessInput.
			If oException.Name'="ProcessInputException"
			{
				Set tSC = oException.AsStatus()
				Do ..Debug("OnTask: "_$System.Status.GetErrorText(tSC))

				If $IsObject(..TwitterStreamingConnection)
				{
					Do ..TwitterStreamingConnection.Disconnect()
					
					Do ..ComputeBackoffPatternWait()
					
					Do ..Debug("Disconnected because of error. Next reconnect attempt will be in "_..CallInterval_" seconds.")
				}
			}			
		}
		
		Quit tSC
	}
	
	Method ProcessNextMessage()
	{		
		For i=1:1:..TweetsPerCallInterval
		{
			Set json=""
			
			/// GET A TWEET or throw exception
			Do ..TwitterStreamingConnection.GetMessage(.json)
		
			Continue:json=""
			
			Try
			{
				Set message = ##class(%Library.DynamicObject).%FromJSON(json)
			}
			Catch
			{
				Do ..SendAlert("Got a non JSON error message: "_json)
				Quit
			}
			
			If message.%IsDefined("text")
			{
				// This is a tweet
				Set pInput = ##class(Twitter.BS.Streaming.Tweet).CreateFromJSON(message)

				Set tSC = ..BusinessHost.ProcessInput(pInput, .pOutputIgnored)
				$$$ThrowStatusExceptionIfError(tSC, "ProcessInputException")
			}
			ElseIf message.%IsDefined("limit")
			{
				If '..SentLimitAlert
				{
					Do ..SendAlert("Limit System Message Received: Your filters have matched more Tweets than its current rate limit allows to be delivered.")
					Set ..SentLimitAlert=1
				}
			}
			Else
			{
				// This is a system message. It can be either an error or a warning. So let's 
				// force an alert to be sent.
				Do ..SendAlertWithSystemMessage(message)
			}
		} 
	}
	
	Method SendAlertWithSystemMessage(pSystemMessageJSONObj As %Library.DynamicObject)
	{
		Set alert=##class(Ens.AlertRequest).%New()
		If pSystemMessageJSONObj.%GetIterator().%GetNext(.messageType, .message)
		{
			Set alert.AlertText="Twitter system message of type "_messageType_": "_message.%ToJSON()
		}
		Else
		{
			Set alert.AlertText="Unknown message format received from twitter:"_pSystemMessageJSONObj.%ToJSON()
		}
		Do ..BusinessHost.SendAlert(alert)
	}
	
	Method SendAlert(pMessage As %String)
	{
		Set alert=##class(Ens.AlertRequest).%New()
		Set alert.AlertText=pMessage
		Do ..BusinessHost.SendAlert(alert)
	}
	
	Method StartStreaming() As %Status
	{
		#Dim doSignedData As %Library.DynamicObject
		
		//$$$TRACE("Start streaming...")
		// STREAMING REQUEST
		Set ..TwitterStreamingRequest = ##class(Twitter.API.StreamingRequest).%New(..TwitterConsumerKey, ..TwitterAccessToken)
		Set ..TwitterStreamingRequest.Follow=..TwitterAPIFollowString
		Set ..TwitterStreamingRequest.Track=..TwitterAPITrackString
		Set ..TwitterStreamingRequest.Language=..TwitterAPILanguageString
		
		// STREAMING CONNETION
		Set ..TwitterStreamingConnection= ##class(Twitter.API.StreamingConnection).%New(..TwitterStreamingRequest)
		Set ..TwitterStreamingConnection.UserAgent=..#TwitterUserAgent
		Set ..TwitterStreamingConnection.SSLConfiguration="Twitter"
		
		// START STREAMING - This method can throw an exception
		Do ..TwitterStreamingConnection.StartStreaming()
			
		// If I didn't get an exception, it is because streaming has started.
		// So, just in case, let's resent CallInterval to its minimun value so that
		// OnTask will be called much more often (and allow us to fetch much more tweets)
		Set ..CallInterval=0.1
	}
	
	/// Implementation of "back-off pattern" as per https://developer.twitter.com/en/docs/tutorials/consuming-streaming-data.html
	/// Instead of a busy wait, we will instruct Ensemble to call OnTask again 
	/// not in 0.1 seconds (100ms) but in a number of seconds that is determined by
	/// the attempt #. The twitter "back-off pattern" suggests us that every attempt 
	/// must be made at the exponential sequence 1, 2, 4, 8, 16... up to a "reasonable upper limit".
	Method ComputeBackoffPatternWait()
	{
		Set ..ConnectionAttempts=..ConnectionAttempts+1
				
		// Waiting time for next retry is an exponential progression based on ConnectionAttempts
		Set ..CallInterval=2**..ConnectionAttempts
				
		// Is the exponential progression above our "reasonable upper limit"?
		If ..CallInterval>..FailureTimeout
		{
			// Let's change the CallInterval to our "reasonable upper limit"
			Set ..CallInterval=..FailureTimeout
		}
	}
	
	Method Debug(pMsg)
	{
		Set ^twitter.debug($I(^twitter.debug))=pMsg
	}

}