gulp = require('gulp')
concat = require('gulp-concat')
coffee = require('gulp-coffee')
watch = require('gulp-watch')
sourcemaps = require('gulp-sourcemaps')
uglify = require('gulp-uglify')

files = [
  'index.coffee'
  'masks.coffee'
  'home.coffee'
  'products.coffee'
  'login.coffee'
  'nav.coffee'
  'cart.coffee'
].map((f) -> 'client/' + f )

toJs = (transforms) ->
  stream = gulp
    .src(files)
    .pipe(sourcemaps.init())
    .pipe(concat('main.js'))
    .pipe(coffee(bare: true))

  if transforms then transforms(stream)

  stream
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest('.'))

gulp.task('watch', ->
  watch('client/*.coffee', -> toJs())
)

gulp.task('build', ->
  toJs((stream) -> stream.pipe(uglify()) )
)
