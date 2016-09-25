module.exports = (grunt) ->
  grunt.initConfig
    less:
      compile:
        files: [
          expand: true
          cwd: 'lib/web/styles'
          src: ['main.less']
          dest: 'lib/web/public'
          ext: '.css'
        ]

    browserify:
      compile:
        files:
          'lib/web/public/bundle.js': ['lib/web/scripts/main.js']
        options:
          transform: ['coffeeify', 'babelify']
          browserifyOptions:
            debug: true

    handlebars:
      compile:
        files:
          'lib/web/public/templates.js': 'lib/web/templates/**/*.hbs'
        options:
          namespace: 'Templates'
          processName: (path) ->
            path.replace('lib/web/templates/', '').replace('.hbs', '')

    watch:
      html:
        files: ['**/*.html']
      less:
        files: ['lib/web/styles/**/*.less']
        tasks: ['less']
      browserify:
        files: ['**/*.coffee', 'lib/web/scripts/**/*.js']
        tasks: ['browserify']
      handlebars:
        files: ['lib/web/templates/**/*.hbs']
        tasks: ['handlebars']

  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-handlebars'

  grunt.registerTask 'default', ['less', 'browserify', 'handlebars', 'watch']