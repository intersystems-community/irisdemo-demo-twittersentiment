/// 
Class IRISDemo.BP.EvaluateTweet.Process Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Twitter.BS.Streaming.Tweet' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='SentimentScore' type='%Integer' instantiate='0' />
<property name='RetweetCount' type='%Integer' instantiate='0' />
<property name='OriginUserFollowersCount' type='%Integer' instantiate='0' />
<property name='FollowersCount' type='%Integer' instantiate='0' />
<property name='SendAlert' type='%Boolean' instantiate='0' />
</context>
<sequence xend='200' yend='1200' >
<call name='Store and Evaluate' target='Twitter Sentiment Operation' async='0' xpos='200' ypos='250' >
<annotation><![CDATA[Store tweet on database and evaluate sentiment]]></annotation>
<request type='Sentiment.BO.Twitter.EvaluateSentimentReq' >
<assign property="callrequest.TweetStatusId" value="request.TweetStatusId" action="set" />
<assign property="callrequest.CreatedAt" value="request.CreatedAt" action="set" />
<assign property="callrequest.UserScreenName" value="request.User.ScreenName" action="set" />
<assign property="callrequest.Text" value="request.Text" action="set" />
<assign property="callrequest.Language" value="request.Language" action="set" />
<assign property="callrequest.ReplyCount" value="request.ReplyCount" action="set" />
<assign property="callrequest.RetweetCount" value="request.RetweetCount" action="set" />
<assign property="callrequest.IsRetweet" value="request.IsRetweet" action="set" />
</request>
<response type='Sentiment.BO.Twitter.EvaluateSentimentResp' >
<assign property="context.SentimentScore" value="callresponse.SentimentScore" action="set" />
</response>
</call>
<assign name="Get Retweet Count" property="context.RetweetCount" value="request.RetweetedStatus.RetweetCount" action="set" xpos='200' ypos='350' >
<annotation><![CDATA[How many times the original tweet was retweeted already?]]></annotation>
</assign>
<assign name="Get Followers Count" property="context.FollowersCount" value="request.User.FollowersCount" action="set" xpos='200' ypos='450' >
<annotation><![CDATA[How many followers has this new user?]]></annotation>
</assign>
<assign name="Get orig. user followers cnt" property="context.OriginUserFollowersCount" value="request.RetweetedStatus.User.FollowersCount" action="set" xpos='200' ypos='550' >
<annotation><![CDATA[How many followers had the original user?]]></annotation>
</assign>
<rule name='Rules' rule='IRISDemo.BR.EvaluateTweet'  resultLocation='context.SendAlert' ruleContext='context' xpos='200' ypos='650' >
</rule>
<if name='Send Alert?' condition='context.SendAlert' xpos='200' ypos='750' xend='200' yend='1100' >
<true>
<call name='Open Ticket on Callcenter' target='Call Center Operations' async='1' xpos='335' ypos='900' >
<request type='CallCenter.BO.CreateTicketForTwitterRequest' >
<assign property="callrequest.pTwitterID" value="request.TweetStatusId" action="set" />
<assign property="callrequest.pTwitterSentiment" value="context.SentimentScore" action="set" />
<assign property="callrequest.pTwitterUser" value="request.User.ScreenName" action="set" />
<assign property="callrequest.pTwitterDate" value="$ZDateH($Piece(request.CreatedAt,&quot; &quot;),3)" action="set" />
<assign property="callrequest.pTwitterText" value="request.Text" action="set" />
</request>
<response type='Ens.Response' />
</call>
<alert value='"Alert!"' xpos='335' ypos='1000' />
</true>
</if>
</sequence>
</process>
}

}
