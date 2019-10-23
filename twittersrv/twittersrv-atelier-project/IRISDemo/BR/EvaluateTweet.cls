/// 
Class IRISDemo.BR.EvaluateTweet Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "Ens.Rule.GeneralBusinessRuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="EvaluateTweet Rule" context="IRISDemo.BP.EvaluateTweet.Process.Context" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Tweet from User with Many followers?" disabled="false">
<when condition="((FollowersCount&gt;10)&amp;&amp;(RetweetCount&lt;10))&amp;&amp;(SentimentScore&lt;0)">
<return>1</return>
</when>
</rule>
<rule name="Too many retweets!" disabled="false">
<when condition="(RetweetCount&gt;10)&amp;&amp;(SentimentScore&lt;0)">
<return>1</return>
</when>
</rule>
<return>0</return>
</ruleSet>
</ruleDefinition>
}

}
