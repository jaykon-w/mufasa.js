


module.exports = function( grunt ) {

  var fs = require('fs'),
      path = require('path');

  function get_line(filename, line_no, callback) {
      var data = fs.readFileSync(filename, 'utf8');
      var lines = data.split("\n");

      if(+line_no > lines.length){
        throw new Error('File end reached without finding line');
      }

      callback(null, lines[+line_no]);
  }


  grunt.initConfig({

    uglify : {
      options : {
        mangle : false,
        compress: {
          drop_console: true
        }
      },

      my_target : {
        src: '',
        dest: ''
      }
    }, // uglify

    concat: {
      options: {
        separator: ';',
      },
      dist: {
        src: '',
        dest: '',
      },
    },

    coffee: {
      compileJoined:{
        options: {
          join: true
        },
        files:{}
      }
    },

    less: {
       development: {
         options: {
           paths: ["app/assets/css/**"],
           syncImport: true
         },
         files: {"public/css/application.css": "app/assets/css/application.less"}
       },
       production: {
         options: {
           paths: ["app/assets/css/**"],
           cleancss: true,
           syncImport: true
         },
         files: {"public/css/application.min.css": "app/assets/css/application.less"}
       }
    },

    watch: {
      dist : {
        files : [
          'app/assets/application.json',
          'app/assets/js/**/*.coffee',
          'app/assets/css/**/*.less'
        ],

        tasks : [ 'coffee', 'concat', 'uglify'],
        options: {
          spawn: false,
          event: ['changed', 'added']
        },
      }
    }

  });

  grunt.event.on('watch', function(action, filepath) {

    var config = JSON.parse(fs.readFileSync(path.join(__dirname, 'app/assets', 'application.json')));

      
    if (/\.coffee$/.test(filepath) || /application\.json$/.test(filepath)) {
     
      var configurantionForCompile = {}
      configurantionForCompile[config.destination+"/mufasa.js"] = config.files.map(function(idx){
        return path.join(__dirname, 'app/assets/js', idx);
      })

      grunt.config('coffee.compileJoined.files', configurantionForCompile);
      grunt.config('concat.dist.src', [config.extrasPath+"/**/*.js", config.destination+"/mufasa.js"]);
      grunt.config('concat.dist.dest', config.destination+"/mufasa.js");
      
      grunt.config('uglify.my_target.src', config.destination+"/mufasa.js");
      grunt.config('uglify.my_target.dest', config.destination+"/mufasa.min.js");


      grunt.config('watch.dist.tasks', ['coffee','concat','uglify']);
    }

    else if(/\.less$/.test(filepath)){

      css = {};
      cssMin = {};

      css[config.destination+"/mufasa.css"] = "app/assets/css/application.less";
      cssMin[config.destination+"/mufasa.min.css"] = "app/assets/css/application.less";

      grunt.config('less.development.files', css);
      grunt.config('less.production.files', cssMin);

      grunt.config('watch.dist.tasks', ['less']);
    }
    
  });

  // Plugins do Grunt
  grunt.loadNpmTasks( 'grunt-contrib-less' );
  grunt.loadNpmTasks( 'grunt-contrib-uglify' );
  grunt.loadNpmTasks( 'grunt-contrib-coffee' );
  grunt.loadNpmTasks( 'grunt-contrib-watch' );
  grunt.loadNpmTasks( 'grunt-contrib-concat' );


  // Tarefas que serão executadas
  grunt.registerTask( 'w', [ 'watch' ] );

};