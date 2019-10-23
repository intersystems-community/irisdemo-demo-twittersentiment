Class OAuth1.Utils
{
	
	/// As per Section 5.1 (Parameter Encoding) on https://oauth.net/core/1.0/
	/// As per RFC3986: https://tools.ietf.org/html/rfc3986
	ClassMethod URLEncode(pString As %String)
	{
		Set tEncoded=$ZConvert($ZConvert(pString,"O","UTF8"),"O","URL")
		
		Set vEncTable("/")="%2F"
		Set vEncTable("!")="%21"
		Set vEncTable("$")="%24"
		Set vEncTable("$")="%24"
		Set vEncTable("'")="%27"
		Set vEncTable("(")="%28"
		Set vEncTable(")")="%29"
		Set vEncTable("'")="%27"
		Set vEncTable("*")="%2A"
		
		Set tChar=""
		For
		{
			Set tChar=$Order(vEncTable(tChar))
			Quit:tChar=""
			Set tEncoded=$Replace(tEncoded,tChar,vEncTable(tChar))
		}
		Quit tEncoded
	}
	
	ClassMethod GenerateNonce() As %String
	{
		Set text=$H_$Random(99999999)
		
		Quit ..MD5Encode(text)
	}
	
	ClassMethod MD5Encode(tText) As %String
	{
        Set bin=$System.Encryption.MD5Encode(tText)
        Set tMD5Hex=""
        For i=1:1:$L(bin) 
        {
        	Set tMD5Hex=tMD5Hex_$ZHex($Ascii($Extract(bin,i)))
        }
        
        Quit $ZConvert(tMD5Hex,"L")
	}
	
	ClassMethod GetTime() As %String
	{
		Quit ##class(%OAuth2.Utils).TimeInSeconds($ZTimeStamp,0)
	}
	
	/// Encode binary value using base64url encoding
	ClassMethod Base64Encode(bin As %Binary) As %String 
	{
		//##class(%OAuth2.Utils).Base64UrlEncode(bin)
		Quit $System.Encryption.Base64Encode(bin, 1)
	}
	
	/// Decode base64url encoded string
	ClassMethod Base64Decode(text As %String) As %Binary 
	{
		//Quit ##class(%OAuth2.Utils).Base64UrlDecode(text)
		Quit $System.Encryption.Base64Decode(bin)
	}
}