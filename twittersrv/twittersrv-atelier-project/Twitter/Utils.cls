Class Twitter.Utils
{
	ClassMethod CheckSSLConfiguration(pSSLConfiguration As %String) As %Status
	{
		Set tSC = $$$OK
		Try
		{
			Set tNS=$Namespace
			Set $Namespace="%SYS"
			
			Quit:##class(Security.SSLConfigs).Exists(pSSLConfiguration)
			
			Set vParams("CipherList")="ALL:!aNULL:!eNULL:!EXP"
			Set vParams("Protocols")=30
			
			Set tSC = ##class(Security.SSLConfigs).Create(pSSLConfiguration, .vParams)
			
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Set $Namespace=tNS
		Quit tSC
	}	
	
	/// Convert miliseconds since start of the Unix epoch to $h format.
	ClassMethod TwitterTimestampInH(time As %Integer) As %String [ Internal ]
	{
		Set time=time/1000
		Set days=time\86400+47117
		Set seconds=time#86400
		Quit days_","_seconds
	}

}