/* global require, module */

var vulcanize   = require('broccoli-vulcanize');  
var pickFiles   = require('broccoli-static-compiler');  
var mergeTrees  = require('broccoli-merge-trees');  
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var app = new EmberApp();

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

var polymerVulcanize = vulcanize('app', {
    input: 'elements.html',
    output: 'assets/vulcanized.html',
    excludes: [/^data:/, /^http[s]?:/, /^\//],
    abspath: '',
    stripExcludes: false,
    stripComments: false,
    inlineScripts: true,
    inlineCss: true,
    implicitStrip: false
});

var polymer = pickFiles('bower_components/', {  
  srcDir: '',
  files: [
    'webcomponentsjs/webcomponents.js',
    'webcomponentsjs/webcomponents-lite.js',
    'polymer/polymer.html'
//  'polymer/polymer.js'
  ],
  destDir: '/assets'
});

app.import('bower_components/materialize/dist/css/materialize.css')
app.import('bower_components/materialize/dist/js/materialize.js')
app.import('bower_components/moment/moment.js')
app.import('bower_components/jquery/dist/jquery.js')
app.import('bower_components/spark/dist/spark.min.js')

//module.exports = app.toTree();
module.exports = mergeTrees([polymerVulcanize, polymer, app.toTree()]);
