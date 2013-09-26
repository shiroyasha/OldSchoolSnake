module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      dev_html:
        expand: true
        src: ['build/**/*.html']

      dev_vendor:
        expand: true
        src: ['build/vendor/**/*.js']

      dev_images:
        expand: true
        src: ['build/images/**/*']

      dev_coffee:
        expand: true
        src: ['build/js/**/.js']

      dev_sass:
        expand: true
        src: ['build/css/**/*.css']

      dev_font:
        expand: true
        src: ['build/font/**/*']

      dev_tmp:
        src: ['.tmp']

    coffeelint:
      app:
        src: ['src/coffee/**/*.coffee']

    sass:
      dev:
        expand: true
        cwd: 'src/sass'
        src: ['**/*.scss', '!**/_*.scss']
        dest: 'build/css'
        ext: '.css'

        options:
          compass: true

    coffee:
      dev:
        expand: true
        cwd: 'src/coffee'
        src: ['**/*.coffee']
        dest: '.tmp/js'
        ext: '.js'

        options:
          bare: true

    wrap:
      dev:
        expand: true
        cwd: '.tmp/js'
        src: ['**/*.js']
        dest: 'build/js'
        options:
          wrapper: ['define(function (require, exports, module) {\n', '\n});']

    copy:
      dev_html:
        expand: true
        cwd: 'src/'
        src: ['**/*.html']
        dest: 'build'

      dev_vendor:
        expand: true
        cwd: 'src/vendor'
        src: ['**/*.js']
        dest: 'build/vendor'

      dev_images:
        expand: true
        cwd: 'src/images'
        src: ['**/*.png','**/*.jpg']
        dest: 'build/images'

      dev_font:
        expand: true
        cwd: 'src/font'
        src: ['**/*']
        dest: 'build/font'

    watch:
      dev_html:
        files: ['src/**/*.html']
        tasks: ['clean:dev_html','copy:dev_html', 'notify:dev']

      dev_vendor:
        files: ['src/vendor/**/*.js']
        tasks: ['clean:dev_vendor','copy:dev_vendor', 'notify:dev']

      dev_sass:
        files: ['src/sass/**/*.scss']
        tasks: ['clean:dev_sass','sass:dev', 'notify:dev']

      dev_images:
        files: ['src/images/**/*']
        tasks: ['clean:dev_images','copy:dev_images', 'notify:dev']

      dev_coffee:
        files: ['src/coffee/**/*.coffee']
        tasks: ['coffeelint:app', 'clean:dev_coffee','coffee:dev', 'wrap:dev', 'clean:dev_tmp', 'notify:dev']

      dev_font:
        files: ['src/font/**/*']
        tasks: ['clean:dev_font','copy:dev_font', 'notify:dev']

      livereload:
        files: ['build/**/*']

        options:
          livereload: true
          event: ['added', 'changed']

    notify:
      dev:
        options:
          title: 'Watch task'
          message: 'done'

    express:
      all:
        options:
          port: 3000
          bases: ['build']



  # Load the plugins
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-sass')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-wrap')
  grunt.loadNpmTasks('grunt-notify')
  grunt.loadNpmTasks('grunt-express')
  grunt.loadNpmTasks('grunt-open')

  grunt.registerTask('igor', ['express:all', 'watch'])

  # Watch task, defaults to the default task
  # grunt.registerTask('watch', ['development'])

  grunt.event.on 'watch', (action, filepath, target) ->
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action)
