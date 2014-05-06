#!/usr/bin/env node

var cli = require('../lib/cli'),
    argv = require('yargs')
      .alias('h', 'host')
      .alias('p', 'port')
      .alias('d', 'database')
      .argv;

function exit(message, exit_code) {
  if (!exit_code) { exit_code = 0; }
  if (!message) { message = 'bye...'; }
  console.log(message);
  process.exit(exit_code);
}

process.on('SIGINT', function () {
  exit('Recieved SIGINT. bye')
});
cli.run(argv, exit);
