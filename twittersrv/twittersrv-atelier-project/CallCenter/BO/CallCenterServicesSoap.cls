Class CallCenter.BO.CallCenterServicesSoap Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Method CreateTicketForTwitter(pRequest As CallCenter.BO.CreateTicketForTwitterRequest, Output pResponse As CallCenter.BO.CreateTicketForTwitterResponse) As %Library.Status
{
 Set ..Adapter.WebServiceClientClass = "CallCenter.WSClient.CallCenterServicesSoap"
 Set tSC = ..Adapter.InvokeMethod("CreateTicketForTwitter",,pRequest.pTwitterID,pRequest.pTwitterUser,pRequest.pTwitterText,pRequest.pTwitterSentiment,pRequest.pTwitterDate)  Quit:$$$ISERR(tSC) tSC
 Set tSC = pRequest.NewResponse(.pResponse)  Quit:$$$ISERR(tSC) tSC
 Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CallCenter.BO.CreateTicketForTwitterRequest">
		<Method>CreateTicketForTwitter</Method>
	</MapItem>
</MapItems>
}

}
