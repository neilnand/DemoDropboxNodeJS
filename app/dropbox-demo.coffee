# File System
fs = require "fs"
jade = require "jade"

Dropbox = require "dropbox"
marked = require "marked"

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


# Expose
module.exports = (app, config) ->

  client = new Dropbox.Client config.auth

  # General Error
  client.onError.addListener (error) ->
    showDropboxError error

  # Get Account Details
  client.getAccountInfo (error, accountInfo) ->
    return showDropboxError 1, error if error

    # Get Directory Contents
    client.readdir "/Apps/DemoDropboxNodeJS/", (error, demoDirList) ->
      return showDropboxError 2, error if error

      # Read Markdown File
      client.readFile "/Apps/DemoDropboxNodeJS/markdown.md", (error, markdownFileData) ->
        return showDropboxError 3, error if error

        # Parse Markdown Data
        markdownFileData = marked markdownFileData, (err, markdownFileData) ->

          # Read "Day One" files
          client.readdir "/Apps/DemoDropboxNodeJS/dayonefiles/", (error, dayoneDirList) ->
            return showDropboxError 2, error if error

            console.log 111, dayoneDirList





          # General HTML
          templates = []

          fs.readdirSync(__dirname + "/public/").forEach (filename) ->
            return if (filename.length - filename.lastIndexOf(".jade")) isnt 5
            templates.push
              filename: filename
              path: "./public/#{filename}"
              htmlFilename: filename.replace ".jade", ".html"

          options =
            accountInfo: accountInfo
            demoDirList: demoDirList
            templates: templates
            markdownFileData: markdownFileData

          templates.forEach (template) ->

            html = jade.renderFile template.path, options
            fs.writeFileSync __dirname + "/public/" + template.htmlFilename, html

            console.log "## #{template.htmlFilename} generated"

