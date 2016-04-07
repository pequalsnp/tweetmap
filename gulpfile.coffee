gulp = require 'gulp'
gbrowserify = require 'gulp-browserify'
gcoffee = require 'gulp-coffee'
grename = require 'gulp-rename'
gutil = require 'gulp-util'

gulp.task 'coffee', ->
  gulp.src('src/coffee/client.coffee', { read: false })
    .pipe(gbrowserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(grename({extname: '.js'}))
    .pipe(gulp.dest('./dist'))

gulp.task 'server', ->
  gulp.src('./src/coffee/server.coffee')
    .pipe(gcoffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('.'))

gulp.task('copy-index-html', ->
    gulp.src('./src/index.html')
      .pipe(gulp.dest('./dist'));
);

gulp.task 'watch', ->
  gulp.watch('src/coffee/client.coffee', ['coffee'])

gulp.task 'default', ['coffee', 'server', 'copy-index-html']
