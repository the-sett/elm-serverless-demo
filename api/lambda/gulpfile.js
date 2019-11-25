var gulp = require('gulp');
var gprint = require('gulp-print');
var gutil = require("gulp-util");
var del = require('del');
var vinylPaths = require('vinyl-paths');
var exec = require('gulp-exec');
var spawn = require('child_process').spawn;
const {
  start_offline,
  stop_offline
} = require('./test-server.js')


var paths = {
  src: 'src',
  build: 'dist',
  serverless: './serverless.yml'
};

var execOptions = {
  continueOnError: false,
  pipeStdout: true
};

var execOptionsContinueOnError = {
  continueOnError: true,
  pipeStdout: true
};

gulp.task('clean', function() {
  return gulp.src(`${paths.build}*`)
    .pipe(gprint())
    .pipe(vinylPaths(del));
});

gulp.task('package', async function() {
  var child = spawn('serverless', ['package']);

  child.stdout.on('data', function(data) {
    console.log(data.toString());
  });
  child.stderr.on('data', function(data) {
    console.error(data.toString());
  });
});

gulp.task('deploy_api_stack', async function() {
  var child = spawn('serverless', ['deploy']);

  child.stdout.on('data', function(data) {
    console.log(data.toString());
  });
  child.stderr.on('data', function(data) {
    console.error(data.toString());
  });
});

gulp.task('delete_api_stack', async function() {
  var child = spawn('serverless', ['remove']);

  child.stdout.on('data', function(data) {
    console.log(data.toString());
  });
  child.stderr.on('data', function(data) {
    console.error(data.toString());
  });
});

gulp.task('update_functions', async function() {
  var child = spawn('serverless', ['deploy', 'function', '-f', 'health']);

  child.stdout.on('data', function(data) {
    console.log(data.toString());
  });
  child.stderr.on('data', function(data) {
    console.error(data.toString());
  });

  var child = spawn('serverless', ['deploy', 'function', '-f', 'revenue']);

  child.stdout.on('data', function(data) {
    console.log(data.toString());
  });
  child.stderr.on('data', function(data) {
    console.error(data.toString());
  });
});

gulp.task('dev', function() {
  return gulp.watch('src/**/*.elm', gulp.series('update_functions'));
});

gulp.task('offline_api_stack', async function() {
  start_offline();
});

gulp.task('delete_offline_api_stack', async function() {
  stop_offline();
});
