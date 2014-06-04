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
          'lib/web/public/bundle.js': ['lib/web/scripts/main.coffee']
        options:
          transform: ['coffeeify']

    watch:
      html:
        files: ['**/*.html']
      sass:
        files: ['lib/web/styles/**/*.less']
        tasks: ['sass']
      browserify:
        files: ['lib/web/scripts/**/*.coffee']
        tasks: ['browserify']
      options:
        livereload: true

  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['less', 'browserify', 'watch']