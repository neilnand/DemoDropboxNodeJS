Dropbox = require "dropbox"

# Expose
module.exports = (app, config) ->

  client = new Dropbox.Client {
    key: config.key
    secret: config.secret
  }

  app.get "/", (req, res, next) ->
    next()