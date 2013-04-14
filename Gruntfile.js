module.exports = function(grunt) {
  grunt.initConfig({
    less:{
      dev:{
        files: {
          "public/css/EMT.css": "less/EMT.less"
        } 
      }
    },
    cssmin: {
      compress: {
        files: {
          "public/css/EMT.css": "public/css/EMT.css",
          "public/css/EMT.libs.css": "public/css/EMT.libs.css"
        }
      }
    },
    concat: {
      vendorcss: {
        src:[
          "public/lib/bootstrap/css/bootstrap.css",
          "public/lib/bootstrap/css/bootstrap-responsive.css",
          "public/lib/flat-ui/css/flat-ui.css",
          "public/lib/font-awesome/font-awesome.min.css"
        ],
        dest: 'public/css/EMT.libs.css'
      },
      vendor: {
        src:[
          "public/lib/jquery.min.1.9.0.js",
          "public/lib/jquery.hammer.min.js",
          "public/lib/jquery.cookie.js",
          "public/lib/jquery.base64.min.js",
          "public/lib/json2.js",
          "public/lib/underscore.js",
          "public/lib/bootstrap/js/bootstrap.min.js",
          "public/lib/backbone/backbone.min.js",
          "public/lib/mustache.js",
          "public/lib/jquery.timeago.js",
          "public/lib/jquery.dateformat.js",
          "public/lib/jquery.hoverIntent.js",
          "public/lib/jquery.jplayer.min.js"
        ],
        dest: 'public/lib/EMT.libs.js'
      },
      app: {
        src: [
          'coffee/main.coffee',
          'coffee/socketio.coffee',
          'coffee/utils.coffee',
          'coffee/YT.coffee',
          'coffee/SC.coffee',
          'coffee/playerControls.coffee',
          'coffee/mixcard.coffee',
          'coffee/mix.coffee'
        ],
        dest: 'coffee/cat/EMT.coffee'
      }
    },
    coffee: {
      client: {
        files: {
          'public/js/EMT.js': 'coffee/cat/EMT.coffee'
        },
        options:{
          bare:true
        }
      },
      server: {
        files: {
          'server.js': 'server.coffee'
        }
      },
      businesslayer: {
        files: [
          {
            expand: true,     // Enable dynamic expansion.
            src: ['businesslayer/*.coffee'], // Actual pattern(s) to match.
            dest: './',   // Destination path prefix.
            ext: '.js',   // Dest filepaths will have this extension.
          }
        ]
      }
    },
    uglify: {
      js: {
        files: {
          'public/js/EMT.js': ['public/js/EMT.js']
        }
      },
      lib: {
        files: {
          'public/lib/EMT.libs.js': ['public/lib/EMT.libs.js']
        }
      }
    },
    copy: {
    },
    watch: {
      less: {
        files: 'less/**/*.less',
        tasks: ['less:dev']
      },
      coffee: {
        files: 'coffee/*.coffee',
        tasks: ['concat:app','coffee:client']
      },
      vendorjs: {
        files: 'public/lib/*.js',
        tasks: 'concat:vendor'
      },
      vendorcss: {
        files: 'public/lib/*.css',
        tasks: 'concat:vendorcss'
      },
      restartServer: {
        files: ['public/templates/partials/*.html', 'dsl/*.json'],
        tasks: 'coffee:server'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mindirect');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask('default', ['less:dev', 'concat:app', 'concat:vendor', 'concat:vendorcss', 'coffee:client', 'watch']);
  grunt.registerTask('prod', ['less:dev', 'concat:vendorcss', 'cssmin', 'concat:app', 'concat:vendor', 'coffee:client', 'coffee:server', 'coffee:businesslayer','uglify']);
};