Include DEMOMACROS

Class Twitter.API.StreamingConnection Extends %RegisteredObject
{

Property Server As %String;

Property URLPath As %String;

Property SSLConfiguration As %String [ InitialExpression = "Twitter" ];

Property Port As %String [ InitialExpression = 443 ];

Property ContentType As %String [ InitialExpression = "application/x-www-form-urlencoded" ];

Property UserAgent As %String [ InitialExpression = "InterSystems IRIS Twitter Streaming Demo Adapter 1.0" ];

Property StreamingRequest As StreamingRequest;

Parameter MODE As %String = "SCDW";

Parameter TERMINATORS As %String = {$Char(13,10)};

Property Timeout As %Integer [ InitialExpression = 5 ];

Property Connected As %Boolean [ InitialExpression = 0, Private ];

Property LastHTTPStatusCode As %String;

Property CurrentChunk As %String(MAXLEN = "") [ Private ];

Property Device As %String [ Private ];

Property OldIO As %String [ Private ];

/// Controls if we have started the streaming connection or not.
Property StreamingStarted As %Boolean [ InitialExpression = 0 ];

Method %OnNew(pStreamingRequest As StreamingRequest) As %Status
{
		
		Set ..URLPath = pStreamingRequest.URLPath
		Set ..Server = pStreamingRequest.APIServer
		Set ..Port = pStreamingRequest.APIPort
		Set ..StreamingRequest = pStreamingRequest
		
		Set tSC = ##class(Twitter.Utils).CheckSSLConfiguration(..SSLConfiguration)
		
		Quit tSC
}

Method Connect() [ Internal, Private ]
{
		Set tSC = $$$OK
		Try
		{
			Quit:..Connected
			
			Set ..OldIO=$IO
					
			Do $ZU(68,57,1) ; turn on PSW2NOTHROTTLE bit to bypass throttle
						
			Set ..Device="|TCP|"_..Port_"|"_$P($Job,":")
			
			Open ..Device:(..Server:..Port:..#MODE:..#TERMINATORS:32000:32000:/TCPNOXY::/SSL=..SSLConfiguration):..Timeout  
			Set bTimedOut='$Test
			
			If bTimedOut
			{
				$$$ThrowException("ConnectionTimeoutException","")
			}
			
			Set ..Connected=1
		}
		Catch (oException)
		{
			Do ..Disconnect()
			
			Throw oException
		}
}

Method %OnClose() As %Status
{
		Do ..Disconnect()
		
		Quit $$$OK
}

Method Disconnect()
{
		Try
		{			
			If ..Device'=""
			{
				Use ..Device 
				Write *-2
			}
		}
		Catch
		{
			//Ignore if we were already disconnected
		}
		
		Try
		{
			Close ..Device
		}
		Catch 
		{
			//Ignore if we were already disconnected
		}
		
		Set ..Device=""
		Set ..Connected=0
		Set ..StreamingStarted=0
		
		If (..OldIO'="") && ($IO'= ..OldIO) Use ..OldIO
}

Method Debug(pMsg)
{
		Set ^twitter.debug($I(^twitter.debug))=pMsg
}

Method OutputHeadersAndBody() [ Internal, Private ]
{
		// Can't use $$$TRACE here because it changes the current device
		// and, for some reason, it interferes with sending the data to Twitter
		//$$$TRACE("** SENDING HTTP HEADERS TO START CONNECTION")
		Do ..Debug("** SENDING HTTP HEADERS TO START CONNECTION")
		Do ..WriteLine("POST "_..URLPath_" HTTP/1.1")		
		Do ..WriteLine("Host: "_..Server)
		Do ..WriteLine("Content-Type: "_..ContentType)
		Do ..WriteLine("Connection: keep-alive")
		Do ..WriteLine("Accept: application/json")
		Do ..WriteLine("User-Agent: "_..UserAgent)
		
		Set tAuthHeader="Authorization: OAuth"
		Set bFirst=1
		Set tKey = ""
		For
		{
			Do ..StreamingRequest.Parameters.GetNext(.tKey)
			Quit:tKey=""
			
			Continue:$Extract(tKey,1,5)'="oauth"
			
			Set tAuthHeader=tAuthHeader_$Select(bFirst:" ",1:", ")
			Set bFirst=0
			
			Set tValue = ..StreamingRequest.Parameters.GetAt(tKey)
			
			Set tAuthHeader=tAuthHeader_tKey_"="""_tValue_""""
		}
		Do ..WriteLine(tAuthHeader)
		
		Set tBody=""
		Set tParamKey = ""
		For
		{
			Do ..StreamingRequest.Parameters.GetNext(.tParamKey)
			Quit:tParamKey=""
			
			Set tParamValue = ..StreamingRequest.Parameters.GetAt(tParamKey)
			Set tPair=##class(OAuth1.Utils).URLEncode(tParamKey)_"="_##class(OAuth1.Utils).URLEncode(tParamValue)
			Set tBody=tBody_"&"_tPair
		}
		
		Set tBody=$Extract(tBody,2,*)
		
		Do ..WriteLine("Content-Length: "_$Length(tBody))
		
		Do ..WriteLine()		
		
		//$$$TRACE("** HTTP BODY:")
		Do ..Debug("** HTTP BODY:")
		
		Do ..WriteLine(tBody)
		
		Write *-3 //Flush
		
		//$$$TRACE("** REQUEST SENT")
		Do ..Debug("** REQUEST SENT")
}

Method StartStreaming()
{
		Try
		{
			Do ..StreamingRequest.Sign()
			
			Do ..Connect()
			
			Use ..Device
			
			Do ..OutputHeadersAndBody()
			
			Do ..ParseResponse()
		}
		Catch (oException)
		{
			Do ..Disconnect()
			
			Throw oException
		}
}

/// This method assumes that you have Use of the TCP device already
Method WriteLine(pData As %String = "")
{
		Write pData,!
		// Can't use $$$TRACE here.
		//$$$TRACE(">> "_pData)
		Do ..Debug(">> "_pData)
}

Method ReadLine(Output pSC As %Status, pTimedOut As %Boolean = 0) As %String [ Internal, Private ]
{
		Set pSC = $$$OK
		
		Set tLine=""
		Try
		{			
			Use ..Device:(::..#MODE:..#TERMINATORS)
			
			Read tLine#32000:..Timeout
			If '$Test 
			{
				Set pTimedOut=1
				Quit
			}
			//$$$TRACE("<< "_tLine)
			Do ..Debug("<< "_tLine)
		}
		Catch (oException)
		{
			Set pSC = oException.AsStatus()
		}
		
		Use ..OldIO
		
		Quit tLine
}

Method Read(pNumberOfBytesToRead As %Integer, Output pSC As %Status) As %String [ Internal, Private ]
{
		Set pSC = $$$OK
		
		Set tLine=""
		Set tPreviousEncoding=""
		
		Try
		{
			//Eliminating Terminators. //Packet mode.
			Use ..Device:(:"":"")
			
			Read tLine#pNumberOfBytesToRead
			//$$$TRACE("<< "_tLine)
			Do ..Debug("<< "_tLine)
		}
		Catch (oException)
		{
			Set pSC = oException.AsStatus()
		}
		
		Use ..OldIO
		
		Quit tLine
}

Method ParseResponse() [ Internal, Private ]
{
		Set tSC = $$$OK
		
		//$$$TRACE("** PARSING RESPONSE")
		Do ..Debug("** PARSING RESPONSE")
		
		Set tHttpStatus = ..ReadLine(.tSC)
		$$$ThrowStatusExceptionIfError(tSC, "HTTPStatusCouldNotBeReadException")
		
		Set ..LastHTTPStatusCode=$Piece(tHttpStatus," ",2)
		
		// Ignore headers for now...
		For
		{
			Set tIgnored = ..ReadLine(.tSC)
			$$$ThrowStatusExceptionIfError(tSC, "HTTPHeaderCouldNotBeReadException")
			If tIgnored="" Quit
		}
		
		//OK! We know that the streaming will start on the following lines
		If ..LastHTTPStatusCode=200
		{
			// Now we can start calling GetMessage()
			Set ..StreamingStarted=1
			Quit
		}
		
		// We got an error... Let's report it
		Do ..GetMessage(.tErrorMessageDetails, $C(10))
		
		If tErrorMessageDetails="" $$$ThrowException("NoErrorInformationReturnedException", "")
		
		$$$ThrowException("HTTPStatusErrorException", tHttpStatus_": "_..LastHTTPStatusCode_tErrorMessageDetails)
}

/// Implements the chunk based streaming protocol.
/// A message may be split in one or more chunks. This method will only return a message 
/// once it has managed to assemble it completely from all its chunks
Method GetMessage(Output pOutput As %String, pMessageTerminator As %String = { $C(13,10)})
{
		Set tSC = $$$OK
		Set pOutput=""
		
		If '..Connected
		{
			$$$ThrowException("NotConnectedException","")
		}
				
		Set tChunkData = ..ReadLine(.tSC, .bTimedOut)
		$$$ThrowStatusExceptionIfError(tSC, "CouldNotReadChunkSizeException")
		
		If (tChunkData="")
		{
			If ('bTimedOut)  
			{
				//$$$TRACE("KEEP ALIVE RECEIVED")
				Do ..Debug("KEEP ALIVE RECEIVED")
				//A simple keep alive CRLF  
				//Let's just return to give the adapter the opportunity to shutdown or call us again
				Quit
			}
			ElseIf bTimedOut
			{
				//$$$TRACE("TIMEOUT - NO DATA RECEIVED")
				Do ..Debug("TIMEOUT - NO DATA RECEIVED")
				// A timeout occurred
				// Let's return to the adapter to give it the opportunity to call us back or shutdown
				Quit
			}
		}
		// We have a chunk header
		
		Set iDataLength = +$ZHex(tChunkData)
		Quit:iDataLength=0 //This should never happen
		
		// Now we know how many bytes are coming on the next chunk
		Set tData=..Read(iDataLength, .tSC)
		$$$ThrowStatusExceptionIfError(tSC, "CouldNotReadChunkException")		
		
		Set iTermLen=$Length(pMessageTerminator)
		
		// Is this the end of a message?
		If $Extract(tData,*-(iTermLen-1),*)'=pMessageTerminator
		{
			// Message is not complete. Must wait for next chunk
			Set ..CurrentChunk=..CurrentChunk_tData
		}
		Else
		{
			// Message is complete
			Set pOutput = ..CurrentChunk_$Extract(tData,1,*-iTermLen) // We don't need the CRLF 
			Set ..CurrentChunk=""
			
			If pOutput=""
			{
				Do ..Debug("KEEP ALIVE RECEIVED (2)")
			}
		}
}

}
