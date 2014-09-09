fs = require 'fs'
_ = require 'underscore'
child_process = require 'child_process'
JASMINE_PATH = './node_modules/jasmine-node/bin/jasmine-node'
SRC_PATH = './src/set.coffee'
DIST_PATH = './jasmine-set.js'

run_task = (cmd, args, cmpl_fn=complete) ->
  term = child_process.spawn(cmd, args, detached: false, stdio: ['ignore', process.stdout, process.stderr])
  term.on('end', cmpl_fn)

desc 'Runs the test spec'
task 'spec', { async: true }, ->
  debug = if process.env.DEBUG? then '--debug-brk' else ''
  spec_file = process.env.SPEC || './spec'
  run_task JASMINE_PATH, "#{debug} --coffee --verbose #{spec_file}".split(' '), complete

desc "Compiles ./src into #{DIST_PATH}"
task 'build', ->
  source = fs.readFileSync(SRC_PATH).toString()
  js = require('coffee-script').compile(source)
  comments = _.filter(source.split("\n\n")[0].split("\n"), (line) -> line.match(/^#.*$/))
  header = _.map(comments, (comment) -> comment.replace(/^#/, '//')).join("\n")
  fs.writeFileSync(DIST_PATH, header+"\n\n"+js)
  console.log("Compiled successfully. Saved in #{DIST_PATH}")
