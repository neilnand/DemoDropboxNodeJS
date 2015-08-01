process.chdir __dirname

# Web Server
express = require "express"
bodyParser = require "body-parser"

# Utilities
jf = require "jsonfile"
_ = require "underscore"

# Info
PORT = process.argv[2]
PUBLIC = "./public/"

jf.readFile "./config.json", (err, config) ->
  jf.readFile "./config-override.json", (err, configOverride) ->
    config = _.extend {}, config, configOverride

    # Setup Express Web Server
    app = express()

    require(__dirname + "/dropbox-demo.coffee")(app, config)

    app.use bodyParser.urlencoded {extended: false}
    app.use bodyParser.json()
    app.use express.static PUBLIC

    # Start
    app.listen PORT, ->
      console.log 'Server: http://localhost:%d in %s mode', PORT, app.settings.env