Class IRISDemo.REST.Dispatcher Extends %CSP.REST
{

Parameter UseSession = 1;

Parameter CONVERTINPUTSTREAM = 1;

Parameter CHARSET = "utf-8";

Parameter HandleCorsRequest = 1;

XData UrlMap
{
  <Routes>
    <Map Prefix="/twittersentiment" Forward="IRISDemo.REST.Twitter.Service"/>
  </Routes>
}

}
