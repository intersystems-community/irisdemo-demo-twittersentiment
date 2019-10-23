Include DEMOMACROS
///
/// WSDL available on:
/// http://localhost:9096/csp/app/soap/IRISDemo.SOAP.CallCenterServices.cls?WSDL=1
///
Class IRISDemo.SOAP.CallCenterServices Extends %SOAP.WebService
{
/// Name of the WebService.
Parameter SERVICENAME = "CallCenterServices"; 

/// SOAP Namespace for the WebService
Parameter NAMESPACE = "http://twitter.demo";

//Parameter LOCATION = "http://bankingcore/csp/app/IRISDemo.Services.TransactionServices.cls";

/// Namespaces of referenced classes will be used in the WSDL.
Parameter USECLASSNAMESPACES = 1;

Method CreateTicketForTwitter(pTwitterID As %String, pTwitterUser As %String, pTwitterText As %String(MAXLEN=""), pTwitterSentiment As %Float, pTwitterDate As %Date) [ WebMethod ]
{	
	Set tSC = $$$OK
	Try
	{
		If pTwitterID="" $$$ThrowException("ParameterIsRequired","pTwitterID")
		If pTwitterUser="" $$$ThrowException("ParameterIsRequired","pTwitterUser")
		If pTwitterText="" $$$ThrowException("ParameterIsRequired","pTwitterText")
		If pTwitterSentiment="" $$$ThrowException("ParameterIsRequired","pTwitterSentiment")
		If pTwitterDate="" $$$ThrowException("ParameterIsRequired","pTwitterDate")
		
		Set obj = ##class(IRISDemo.Ticket).%New()
		Set obj.TicketID = pTwitterID
		Set obj.TicketUser = pTwitterUser
		Set obj.TicketText = pTwitterText
		Set obj.TicketFeedback = pTwitterSentiment
		Set obj.TicketDate = pTwitterDate

		Set sc = obj.%Save()
		$$$ThrowStatusExceptionIfError(tSC, "CouldNotSaveCallcenterTicket")
	}
	Catch (oException)
	{
		$$$SOAPFaultWithException(oException)
	}
}


}