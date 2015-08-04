# File System
fs = require "fs"
jade = require "jade"

Dropbox = require "dropbox"
marked = require "marked"
xmldoc = require "xmldoc"

# Utils
parseValueName = (input) ->
  input.replace(/[^a-z0-9]/gi, '_')

# Dropbox Error Handling
showDropboxError = (marker, error) ->
  prefix = "###{marker} Dropbox Client Error: "
  switch error.status
    when Dropbox.ApiError.INVALID_TOKEN
      console.log "#{prefix}Dropbox.ApiError.INVALID_TOKEN"
      # If you're using dropbox.js, the only cause behind this error is that
      # the user token expired.
      # Get the user through the authentication flow again.

    when Dropbox.ApiError.NOT_FOUND
      console.log "#{prefix}Dropbox.ApiError.NOT_FOUND"
      # The file or folder you tried to access is not in the user's Dropbox.
      # Handling this error is specific to your application.

    when Dropbox.ApiError.OVER_QUOTA
      console.log "#{prefix}Dropbox.ApiError.OVER_QUOTA"
      # The user is over their Dropbox quota.
      # Tell them their Dropbox is full. Refreshing the page won't help.

    when Dropbox.ApiError.RATE_LIMITED
      console.log "#{prefix}Dropbox.ApiError.RATE_LIMITED"
      # Too many API requests. Tell the user to try again later.
      # Long-term, optimize your code to use fewer API calls.

    when Dropbox.ApiError.NETWORK_ERROR
      console.log "#{prefix}Dropbox.ApiError.NETWORK_ERROR"
      # An error occurred at the XMLHttpRequest layer.
      # Most likely, the user's network connection is down.
      # API calls will not succeed until the user gets back online.

    when Dropbox.ApiError.INVALID_PARAM
      console.log "#{prefix}Dropbox.ApiError.INVALID_PARAM"
    when Dropbox.ApiError.OAUTH_ERROR
      console.log "#{prefix}Dropbox.ApiError.OAUTH_ERROR"
    when Dropbox.ApiError.INVALID_METHOD
      console.log "#{prefix}Dropbox.ApiError.INVALID_METHOD"
    else
      console.log "#{prefix}Other"
      # Caused by a bug in dropbox.js, in your application, or in Dropbox.
      # Tell the user an error occurred, ask them to refresh the page.


# Write Files
jadeOptions = {}

writeFiles = ->
  # General HTML
  jadeOptions.templates = []

  fs.readdirSync(__dirname + "/public/").forEach (filename) ->
    return if (filename.length - filename.lastIndexOf(".jade")) isnt 5
    jadeOptions.templates.push
      filename: filename
      path: "./public/#{filename}"
      htmlFilename: filename.replace ".jade", ".html"

  jadeOptions.templates.forEach (template) ->

    html = jade.renderFile template.path, jadeOptions
    fs.writeFileSync __dirname + "/public/" + template.htmlFilename, html

    console.log "## #{template.htmlFilename} generated"

tryWriteFilesCount = 0
tryWriteFiles = ->
  if tryWriteFilesCount is 0
    writeFiles()

dayOneParse = (dict, parent) ->
  if dict.children
    for key, index in dict.children by 2
      if key.name is "key"
        val = dict.children[index+1]
        keyName = parseValueName key.val
        if val.name is "dict"
          parent[keyName] = {}
          dayOneParse val, parent[keyName]
        else
          parent[keyName] = val.val
      else
        console.log "ReadDayOneFile $parse Error"


class ReadDayOneFile
  constructor: (dir, filename, client) ->
    tryWriteFilesCount++
    client.readFile dir + filename, (error, fileData) =>
      return showDropboxError 3, error if error

      # Remove XML Whitespace
      fileData = fileData.replace(/>\s*/g, '>').replace(/\s*</g, '<')

      document = new xmldoc.XmlDocument fileData
      dayOneParse document.firstChild, this

      @renderedContent = marked @Entry_Text

      tryWriteFilesCount--
      tryWriteFiles()

# Expose
module.exports = (app, config) ->

  client = new Dropbox.Client config.auth

  # General Error
  client.onError.addListener (error) ->
    showDropboxError 0, error

  # Get Account Details
  client.getAccountInfo (error, accountInfo) ->
    return showDropboxError 1, error if error

    jadeOptions.accountInfo = accountInfo

    # Get Directory Contents
    client.readdir "/Apps/DemoDropboxNodeJS/", (error, demoDirList) ->
      return showDropboxError 2, error if error

      jadeOptions.demoDirList = demoDirList

      # Read Markdown File
      client.readFile "/Apps/DemoDropboxNodeJS/markdown.md", (error, markdownFileData) ->
        return showDropboxError 3, error if error

        # Parse Markdown Data
        markdownFileData = marked markdownFileData, (err, markdownFileData) ->

          jadeOptions.markdownFileData = markdownFileData

          # Read "Day One" files
          dir = "/Apps/DemoDropboxNodeJS/dayonefiles/"
          client.readdir dir, (error, dayoneDirList) ->
            return showDropboxError 2, error if error

            jadeOptions.dayOneFiles = []

            for filename in dayoneDirList
              jadeOptions.dayOneFiles.push new ReadDayOneFile dir, filename, client

