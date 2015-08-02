APP = "./app/"
PUBLIC = "#{APP}public/"

module.exports = (grunt) ->


  npmPackage = grunt.file.readJSON "package.json"


  # Grunt Tasks
  gruntTaskList = {
    default: [
      "coffeelint:dev"
      "coffee:demo"
      "sass:demo"
#      "jade:demo"
      "exec:dev"
    ]
    devwatch: [
      "watch:demo"
    ]
  }


  # Configuration
  grunt.initConfig
    name: npmPackage.name

    # Ensure we're using good coding standards
    coffeelint:
      dev: [
        APP + "**/*.coffee"
      ]
      options:
        max_line_length:
          value: 120

    # Convert JADE to HTML
    jade:
      demo:
        options:
          pretty: true
          data:
            debug: true
        expand: true
        src: "#{PUBLIC}/**/*.jade"
        ext: ".html"

    # Convert SASS into CSS
    sass:
      demo:
        files: [{
          expand: true
          cwd: PUBLIC
          src: ["**/*.sass"]
          dest: PUBLIC
          ext: ".css"
        }]
        options:
          style: "expanded"

    # Watch for changes in development
    watch:
      options:
        livereload: npmPackage.ports.livereload
      demo:
        files: [
          "#{PUBLIC}/**/*.sass"
        ]
        tasks: [
          "sass:demo"
        ]

    # Convert CoffeeScript into JavaScript
    coffee:
      demo:
        expand: true,
        cwd: PUBLIC
        src: "**/*.coffee"
        dest: PUBLIC
        ext: ".js"

    # Terminal Commands
    exec:
      dev: "nodemon #{npmPackage.main} #{npmPackage.ports.main}"


  # Load NPM modules
  matchdep = require "matchdep"
  matchdep.filterDev("grunt-*").forEach(grunt.loadNpmTasks)

  # Register Tasks
  for taskName, taskList of gruntTaskList
    grunt.registerTask taskName, taskList