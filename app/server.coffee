process.chdir __dirname

# Web Server
express = require "express"
bodyParser = require "body-parser"

# Info
PORT = process.argv[2]
PUBLIC = "./public/"

# Setup Express Web Server
app = express()

require(__dirname + "/dropbox-demo.coffee")(app)

app.use bodyParser.urlencoded {extended: false}
app.use bodyParser.json()
app.use express.static PUBLIC

# Start
app.listen PORT, ->
  console.log 'Server: http://localhost:%d in %s mode', PORT, app.settings.env