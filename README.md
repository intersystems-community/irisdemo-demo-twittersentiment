# Twitter Sentiment Analysis with InterSystems IRIS NLP

This demo shows how we can use IRIS Interoperability to stream tweets using the standard HTTP Streaming Protocol and the Twitter Streaming API. This Twitter API is different from the Search API because we can receive the tweets in real time. It is also different from the Firehose Streaming API because we are not receiving all the tweets but a fraction that will depend on the traffic. But for many applications such as sentiment analysis that is just fine.

You will be able to take your phone and make a tweet with the content you want (ex.: "This phone is not that bad! The weather will be great today! #irisdemo"). You have to use the #irisdemo hashtag because the Business Service is configured to filter tweets by this hash tag. 

Then you will be able to see the tweet coming into your production and being stored on the database layer. The production will then go on and call a service on the database layer that uses IRIS Natural Language Processing (NLP) to give you a sentiment score. The service layer picks the sentiment score and uses the rest of the metadata on the tweet such as number of followers the user has, and number of times the tweet has been retwetted. An IRIS Business Rule will use all this information to determine if the call center needs to be notified about this tweet or not.

The picture bellow shows the workflow:

![Demo Landing Page](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-twittersentiment/master/README.png?raw=true)

## Twitter Developer Account

To run this demo you must have a [Twitter Developer account](https://developer.twitter.com/en/apps) and a twitter application created on twitter. The application you create on twitter will provide you with your Consumer API Keys and Access token & access token secret credentials. 

Start the process of getting the developer account WEEKS BEFORE you decide to try this demo. There is no formula to getting a twitter developer account. They are very strict about giving developer accounts to people. You can try opening one with your personal e-mail account, telling them that you are studying the Twitter API and that you don't have an application in mind right now. Or you can say that you are a consultant that is studying a twitter library and need a developer account to do some tests (I like this better). They will ask you what is the nature of your business or customer. They are very worried about how you are going to use twitter data.

## Twitter Application

Once you get your twitter developer account, you can [create your twitter application](https://developer.twitter.com/en/apps). Here is the screenshot of the twitter application I created for me:

![Twitter App Example](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-twittersentiment/master/TwitterAppExample.png?raw=true)

After creating the App, click on the Details button on the right of your new application and click on the Keys and Tokens tab. You will see your Consumer API Keys and Access token & access token secret credentials.

Don't forget to click on the Instructions button at the landing page of the demo. It will give you detailed instructions on how to use the demo.

## How to run the demo

To just run the demo on your PC, make sure you have Docker installed on your machine. You can quickly get it up and running with the folloing commands:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-twittersentiment/master/docker-compose.yml
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-twittersentiment/master/.env
docker-compose up
```

You can also clone this repository to you local machine to get the entire source code. You will need git installed and you would need to be on your git folder:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-twittersentiment
cd irisdemo-demo-twittersentiment
docker-compose up
```

Both techniques should work and should trigger the download of the images that compose this demo and it will soon start all the containers. 

When starting, it is going to show you lots of messages from all the containers that are staring. That is fine. Don't worry.

When it is done, it will just hang there, without returning control to you. That is fine too. Just leave this window open. If you CTRL+C on this window, docker compose will stop all the containers (and stop the demo!).

After all the containers have started, open the demo landing page on [http://localhost:52773/csp/appint/demo.csp](http://localhost:52773/csp/appint/demo.csp).

Use the username **SuperUser** and the password **sys**. This is just a demo that is running on your machine, so we are using a default password.


# Architecture

This demo uses docker-compose to start four services:

* twittersrv - This service runs an IRIS integration production that has a native business service that implements the HTTP Streaming Protocol and the statuses/filter API for streaming tweets in real time. You are going to need Twitter Credentials to use the API (and run the demo). 
* twittersentiment - This is where all tweets are being stored. We want to do that in order to use NLP capabilities to explore past and current tweets to keep enhancing our dictionaries and services. This box exposes a REST service we call from the twittersrv to get the sentiment score.
* callcenterdb - This service is the database of a simulated legacy CRM application. This database is IRIS and it exposes a SOAP service that the twittersrv calls to create a ticket in the callcenter application.
* callcenterui - This is a Java application that simulates the UI of the CRM application. 

# Highlights

This demo helps us to demonstrate:
* IRIS Community
* Product features:
    - Containers Support
    - Native Twitter Streaming Integration (requires a Twitter credential)
    - Basic IRIS Productions (Business Services, Processes and Operations)
    - Business Processes
    - Business Rules with Tweets Metadata (number of followers, number of retweets, etc) and the sentiment score of the tweets' text.
    - Message Trace
    - IRIS NLP with Sentiment Analysis, Business Dictionaries and Negation
    - IRIS NLP Explorer
    - SQL
    - SOAP Integration 
    - REST Integration
* Java Application built with Java Prime Faces and IRIS JDBC

# Report any Issues

Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-twittersentiment/issues).
