Class CallCenter.WSClient.CallCenterServicesSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
Parameter LOCATION = "http://callcenterdb:52773/csp/app/soap/IRISDemo.SOAP.CallCenterServices.cls";

/// This is the namespace used by the Service
Parameter NAMESPACE = "http://twitter.demo";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// Determines handling of Security header.
Parameter SECURITYIN = "ALLOW";

/// This is the name of the Service
Parameter SERVICENAME = "CallCenterServices";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

/// Overrides default handling of string arguments.
Parameter XMLIGNORENULL = 1;

Method CreateTicketForTwitter(pTwitterID As %String, pTwitterUser As %String, pTwitterText As %String, pTwitterSentiment As %Float, pTwitterDate As %Date) [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Do (..WebMethod("CreateTicketForTwitter")).Invoke($this,"http://twitter.demo/IRISDemo.SOAP.CallCenterServices.CreateTicketForTwitter",.pTwitterID,.pTwitterUser,.pTwitterText,.pTwitterSentiment,.pTwitterDate)
}

}
