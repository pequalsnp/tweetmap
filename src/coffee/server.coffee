express = require 'express'
Twitter = require 'twitter'
CBuffer = require 'CBuffer'
twitterConfig = require('config').get('Twitter')

twitter = new Twitter({
  consumer_key: twitterConfig.consumer_key,
  consumer_secret: twitterConfig.consumer_secret,
  access_token_key: twitterConfig.access_token_key,
  access_token_secret: twitterConfig.access_token_secret
})

buffer = new CBuffer(1000)

twitter.stream 'statuses/filter', {locations: "-180,-90,180,90"}, (stream) ->
  stream.on('data', (tweet) ->
    if (tweet.coordinates)
      buffer.push(tweet)
  )

app = express()

app.use(express.static('dist'))

app.get('/tweets', (req, res) ->
  oldBuf = buffer
  buffer = new CBuffer(1000)
  result =
    {text: tweet.text, url: 'https://twitter.com/' + tweet.user.screen_name + '/status/' + tweet.id_str, longLat: tweet.coordinates.coordinates} for tweet in oldBuf.toArray()
  res.send(result)
)

app.get('/tweetsGeoJson', (req, res) ->
  result =
    type: "Feature"
    geometry:
      type: "Point"
      coordinates: buffer.pop()
    properties: {}
  res.send(result)
)

app.listen(3000, ->
  console.log('Example app listening on port 3000!')
)
