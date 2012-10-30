/*globals define: false, Lab: true */

define(function (require) {
  var version = require('lab.version'),
      config  = require('lab.config');

  // Require public-api modules
  // defining other global variables.
  require('md2d/public-api');
  require('grapher/public-api');
  // ###

  // Create or get 'Lab' global object (namespace).
  window.Lab = window.Lab || {};
  // Export config and version modules.
  window.Lab.version = version;
  window.Lab.config = config;
});
