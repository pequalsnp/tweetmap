CBuffer = require 'CBuffer'
ajaxRequest = require 'ajax-request'
mapboxgl = require 'mapbox-gl'
leaflet = require 'leaflet'

mapboxgl.accessToken = 'pk.eyJ1IjoicGVxdWFsc25wIiwiYSI6ImNpbXBuZTRodzAwNXl2N2trM2VtaHh6NDYifQ.l_ew-97Qg_dypuFs5H7JQA'
map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/dark-v8',
    center: [0, 0],
    zoom: 2
})

buffer = new CBuffer(10)

buffer.overflow = (tooltip) ->
  tooltip.remove()

addTweetToMapPopup = (tweet) ->
  tooltip = new mapboxgl.Popup()
    .setLngLat(tweet.longLat)
    .setText(tweet.text)
    .addTo(map)
  buffer.push(tooltip)

addTweetToMap = (tweet) ->
  console.log("Adding tweet at " + tweet)
  addTweetToMapPopup(tweet)

getNewTweets = ->
  console.log("Getting tweets")
  ajaxRequest('/tweets', (err, res, body) ->
    console.log(body)
    addTweetToMap tweet for tweet in JSON.parse(body)
  )
  setTimeout(getNewTweets, 2000)

map.on 'style.load', ->
  map.addSource('point', {
      "type": "geojson",
      "data": "/tweetsGeoJson"
  });

  map.addLayer({
      "id": "point",
      "source": "point",
      "type": "circle",
      "paint": {
          "circle-radius": 5,
          "circle-color": "#55acee"
      }
  });

  window.setInterval( ->
    map.getSource('point').setData("/tweetsGeoJson")
  , 2000)
