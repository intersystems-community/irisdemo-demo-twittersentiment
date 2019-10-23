Class OAuth1.SignatureMethods.BaseSignatureMethod Extends %RegisteredObject [ Abstract ]
{
	Parameter SignatureMethodName As %String = "METHOD NAME";
		
	Method GetName() As %String [ Final ]
	{
		Quit ..#SignatureMethodName
	}
	
	/// To be implemented by subclass
	Method BuildSignature(pRequest As OAuth1.BaseRequest, pDebug As %Boolean = 0) As %String [ Abstract ]
	{
		Quit ""
	}
	
	ClassMethod GetSignatureMethod(pSignatureMethodName As %String) As BaseSignatureMethod
	{
		Quit $classmethod("OAuth1.SignatureMethods."_pSignatureMethodName, "%New")
	}
}