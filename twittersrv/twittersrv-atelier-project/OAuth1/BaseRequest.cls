Class OAuth1.BaseRequest Extends %RegisteredObject
{
	Property ConsumerKey As ConsumerKey;
	
	Property AccessToken As AccessToken;
	
	Property SignatureMethod As OAuth1.SignatureMethods.BaseSignatureMethod;
	
	Property Method As %String (VALUELIST=",GET,POST,DELETE") [ InitialExpression = "POST" ];
	
	/// Must be set by subclass and have the form: <scheme>://server_address/path/path/...
	/// No port number should be set even when it is different from the typical (80, 443, etc...).
	Property URL As %String;
	
	Property URLPath As %String [ Calculated, Readonly ];
	
	/// Subclasses should implement properties that will add keys to this array
	Property Parameters As Array Of %String;
	
	Property Time As %String;
	
	Property NONCE As %String;
	
	Method %OnNew(pConsumerKey As ConsumerKey, pAccessToken As AccessToken, pSignatureMethod As %String) As %Status
	{
		Set ..ConsumerKey=pConsumerKey
		Set ..AccessToken=pAccessToken
		Set ..SignatureMethod=##class(OAuth1.SignatureMethods.BaseSignatureMethod).GetSignatureMethod(pSignatureMethod)
		
		Quit $$$OK
	}
	
	Method URLPathGet() As %String
	{
		Quit "/"_$Piece(..URL,"/",4,*)
	}
	
	/// https://oauth.net/core/1.0/#signing_process
	Method Sign(pDebug As %Boolean = 0)
	{
		Do ..Parameters.SetAt(..ConsumerKey.ConsumerKey, "oauth_consumer_key")
		Do ..Parameters.SetAt(..AccessToken.AccessToken, "oauth_token")
		Do ..Parameters.SetAt(..SignatureMethod.GetName(), "oauth_signature_method")
		Do ..Parameters.SetAt("1.0", "oauth_version")
		
		Set ..Time = ##class(OAuth1.Utils).GetTime()
		Do ..Parameters.SetAt(..Time, "oauth_timestamp")
		
		Set ..NONCE = ##class(OAuth1.Utils).GenerateNonce()
		
		Do ..Parameters.SetAt(..NONCE, "oauth_nonce")
		
		Set tSignature = ..SignatureMethod.BuildSignature($this, pDebug)
		
		Do ..Parameters.SetAt(tSignature, "oauth_signature")
	}
		
    Method GetSignatureBaseString()
    {
    	#Dim iterator As %Iterator.Object
    	
    	Set tString=##class(OAuth1.Utils).URLEncode(..Method)_ 
    				"&"_##class(OAuth1.Utils).URLEncode(..URL)
    	
    	// Eliminating oauth_signature and reordering by key and value (in case of duplicates)
    	Set key=""
    	For 
    	{
    		Do ..Parameters.GetNext(.key)
    		Quit:key=""
    		
    		Set value = ..Parameters.GetAt(key)
    		
			Set valueEncoded = ##class(OAuth1.Utils).URLEncode(value)
			If valueEncoded'=""
			{
				Set keyEncoded = ##class(OAuth1.Utils).URLEncode(key)
				Set vParams(keyEncoded, valueEncoded)=""
			}
			Else
			{
				Do ..Parameters.RemoveAt(key)
			}
    	}
    	
    	Set tParams=""
    	Set key=""
    	For
    	{
    		Set key=$Order(vParams(key))
    		Quit:key=""
    		
    		Set val=""
    		For
    		{
    			Set val = $Order(vParams(key, val))
    			Quit:val=""
    			
    			Set pair=key_"="_val
    			Set tParams=tParams_"&"_pair
    		} 	
    	}
    	
    	Set tString = tString_"&"_##class(OAuth1.Utils).URLEncode($Extract(tParams, 2, *))
    	
    	Quit tString
    }
}