
# Expose
module.exports = (app) ->

  app.get "/", (req, res, next) ->

    console.log 111

    next()