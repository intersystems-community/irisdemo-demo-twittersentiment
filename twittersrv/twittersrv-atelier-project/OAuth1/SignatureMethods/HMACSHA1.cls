Class OAuth1.SignatureMethods.HMACSHA1 Extends BaseSignatureMethod
{
	Parameter SignatureMethodName As %String = "HMAC-SHA1";
		
	Method BuildSignature(pRequest As OAuth1.BaseRequest, pDebug As %Boolean = 0) As %String
	{
		Set tBaseString = pRequest.GetSignatureBaseString()
		Write:pDebug !,"SIGNATURE BASE STRING: ",tBaseString
		
		Set tKeys=##class(OAuth1.Utils).URLEncode(pRequest.ConsumerKey.ConsumerSecret)_
			  "&"_##class(OAuth1.Utils).URLEncode(pRequest.AccessToken.AccessSecret)
		
		Set tSignature = $System.Encryption.HMACSHA1(tBaseString, tKeys)
		Write:pDebug !,"SIGNATURE: ",tSignature
		
		Quit ##class(OAuth1.Utils).Base64Encode(tSignature) 
		
	}
}