jQuery ->
  $('body').prepend('<div id="twitter-root"></div>')

  $.ajax
    url: "#{window.location.protocol}//connect.twitter.net/en_US/all.js"
    dataType: 'script'
    cache: true


window.fbAsyncInit = ->
  Twitter.init(appId: 'YOUR-APP-ID', cookie: true)

  $('#sign_in').click (e) ->
    e.preventDefault()
    Twitter.login (response) ->
      window.location = '/auth/twitter/callback' if response.authResponse

  $('#sign_out').click (e) ->
    Twitter.getLoginStatus (response) ->
      Twitter.logout() if response.authResponse
    true