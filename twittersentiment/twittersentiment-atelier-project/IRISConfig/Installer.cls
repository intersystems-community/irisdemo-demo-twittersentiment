Include (%occInclude,%IKPublic)

Class IRISConfig.Installer Extends IRISConfig.InstallerBase
{

ClassMethod LoadTransactionalData(pNamespace As %String) As %Status
{
	Set tSC = $$$OK
	Try
	{
		ZN pNamespace
		
		//Set tSC = ##class(IRISDemo.DataLoadingUtils).LoadFullDataFromCSVFile("/tmp/training_set.csv")
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	ZN "%SYS"
	
	Quit tSC 
}

ClassMethod BuildNLPDomain(pNamespace As %String) As %Status
{
	Set tSC = $$$OK
	Try
	{
		ZN pNamespace
		
		// Add a dummy source to the domain so that the %Build() will also process the matching dictionary 
		// instead of returning with the error "ERROR #8015: Nothing to process" and leaving the
		// matching dictionary unprocessed.
		/*
		Set tweet = ##class(IRISDemo.Data.Tweets).%New()
		Set tweet.TweetStatusId = 1 
		Set tweet.UserScreenName = "dummyuser"
		Set tweet.Text = "Dummy text"		
		Set tSC = tweet.%Save()
		Quit:$System.Status.IsError(tSC)
		*/
		
		// Now we can build the domain to get the matching dictionary working (just compiling the domain class 
		// isn't enough) without getting an ERROR #8015: Nothing to process
		Set tSC = ##class(IRISDemo.NLP.Twitter.TwitterAnalytics).%Build(1)
		Quit:$System.Status.IsError(tSC)
		
		// We don't need that dummy source anymore
		//Set tSC = ##class(IRISDemo.Data.Tweets).%DeleteId(tweet.%Id())
		
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	ZN "%SYS"
	
	Quit tSC 
}

/// You can customize this to run code during docker build
XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>
	<Namespace Name="${Namespace}" Create="no">
		<IfDef Var="SourceDir">
            <Log Text="SourceDir defined - offline install from ${SourceDir}" Level="0"/>
            <Import File="${SourceDir}" Recurse="true"/>
        </IfDef>
	</Namespace>
	
	<Log Text="Loading transactional data..." Level="0"/>
	<Invoke Class="IRISConfig.Installer" Method="LoadTransactionalData" CheckStatus="true">
		<Arg name="pNamespace" Value="${Namespace}"/>
	</Invoke>
	
	<Log Text="Building the NLP domain..." Level="0"/>
	<Invoke Class="IRISConfig.Installer" Method="BuildNLPDomain" CheckStatus="true">
		<Arg name="pNamespace" Value="${Namespace}"/>
	</Invoke>

</Manifest>
}
}