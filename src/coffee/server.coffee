express = require 'express'
Twitter = require 'twitter'
CBuffer = require 'CBuffer'
twitterConfig = require('config').get('Twitter')
ajaxRequest = require 'ajax-request'

twitter = new Twitter({
  consumer_key: twitterConfig.consumer_key,
  consumer_secret: twitterConfig.consumer_secret,
  access_token_key: twitterConfig.access_token_key,
  access_token_secret: twitterConfig.access_token_secret
})

buffer = new CBuffer(1000)

startStream = ->
  twitter.stream 'statuses/filter', {locations: "-180,-90,180,90"}, (stream) ->
    stream.on('data', (tweet) ->
      if tweet.coordinates
        buffer.push(tweet)
      else if tweet.place and tweet.place.id
        twitter.get('geo/id/' + tweet.place.id + '.json', (error, place, response) ->
          if place and place.centroid
            console.log(place.centroid)
        )
    )

    stream.on('error', (error) ->
      console.log("Streaming API error: " + error)
    )

    stream.on('end', (end) ->
      console.log("Streaming API ended: " + end)
      startStream()
    )

app = express()

app.use(express.static('dist'))

app.get('/tweetoembed', (req, res) ->
  ajaxRequest({
    url: "/tweetoembed"
    method: 'GET'
    data: {
      id: feature.properties.id_str
    }
  }, (err, res, body) ->
    res.send(body)
  )
)

tweetToFeature = (tweet) ->
  {
    type: "Feature"
    geometry:
      tweet.coordinates
    properties: tweet
  }

app.get('/tweetsGeoJson', (req, res) ->
  features = (tweetToFeature(tweet) for tweet in buffer.toArray())
  result =
    type: "FeatureCollection"
    features: features
  res.send(result)
)

app.listen(3000, ->
  console.log('Example app listening on port 3000!')
)

startStream()
