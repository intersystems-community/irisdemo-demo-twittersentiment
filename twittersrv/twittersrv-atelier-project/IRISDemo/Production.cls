Class IRISDemo.Production Extends IRISDemo.BaseProduction
{

XData ProductionDefinition
{
<Production Name="IRISDemo.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Java Gateway Service" Category="Datalake" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Twitter Streaming Service" Category="" ClassName="Twitter.BS.Streaming.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="TwitterAPIFollowString"></Setting>
    <Setting Target="Adapter" Name="TwitterAccessTokenCredentials">TwitterAppUserTokenCredentials</Setting>
    <Setting Target="Adapter" Name="TwitterAppConsumerCredentials">TwitterAppConsumerCredentials</Setting>
    <Setting Target="Adapter" Name="TwitterAPITrackString">#irisdemo</Setting>
    <Setting Target="Host" Name="TargetConfigName">Evaluate Tweet Process</Setting>
  </Item>
  <Item Name="Evaluate Tweet Process" Category="" ClassName="IRISDemo.BP.EvaluateTweet.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Twitter Sentiment Operation" Category="" ClassName="Sentiment.BO.Twitter.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="HTTPServer">twittersentiment</Setting>
    <Setting Target="Adapter" Name="URL">/csp/app/rest/twittersentiment/</Setting>
    <Setting Target="Adapter" Name="Credentials">SentimentAnalytics</Setting>
    <Setting Target="Adapter" Name="HTTPPort">52773</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=R</Setting>
  </Item>
  <Item Name="Call Center Operations" Category="" ClassName="CallCenter.BO.CallCenterServicesSoap" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="WebServiceURL">http://callcenterdb:52773/csp/app/soap/IRISDemo.SOAP.CallCenterServices.cls</Setting>
    <Setting Target="Adapter" Name="SOAPCredentials">Callcenter</Setting>
  </Item>
</Production>
}

}
