#
# jasmine-beforeSuite - 0.1.0
#
# A plugin for the Jasmine behavior-driven Javascript testing framework that
# adds a `set` global function. It is inspired by rspec's very nice `let` syntax.
#
# Works in both node.js and a browser environment.
#
# Requires jasmine.js and underscore.js.
#
# @author Joe Vennix
# @copyright Rapid7 2014
# @see https://github.com/jvennix-r7/jasmine-beforeSuite
#
# Released under the MIT License.
#

install = (_, jasmine) ->

  # Contains a map of suite ID -> [{name: var1, installfn: ->}]
  suites = {}

  # Contains a map of varname -> [{name: var1, installfn: ->}] (a stack of installations)
  namespaceStack = {}

  # Save a ref to the global context
  context = @

  globalPatches =

    # # Patch describe so, that, I, don't, have, to, write, code, like, -> @.
    # describe: _.wrap(@describe, (it, description, suite) ->
    #   if suite
    #     it.call(@, description, suite)
    #   else # we are passing spec in as a function argument
    #     (suite) =>
    #       it.call(@, description, suite)
    # )

    # # Patch it so, that, I, don't, have, to, write, code, like, -> @.
    # it: _.wrap(@it, (it, description, spec) ->
    #   if spec
    #     it.call(@, description, spec)
    #   else # we are passing spec in as a function argument
    #     (spec) =>
    #       it.call(@, description, spec)
    # )

    # set enables a Suite-refinable storage mechanism.
    # @param name [String] the name of the var you are defining
    # @param opts [Object] the options hash (optional)
    # @option opts :now [Boolean] evaluate the anon func immediately (false)
    # @return [void]
    set: (name, opts, fn) ->    
      if _.isFunction(opts)
        fn = opts
        opts = null

      opts ||= {}
      opts.now ?= false

      ret = (fn) ->
        # we return a function that accepts a function, so we have a nicer
        # DSL syntax. Of course this clashes with jasmine's, insistence, on,
        # comma, -> so we will support both.
        doit = ->
          if opts.now
            context[name] = fn()
          else    
            cachedId = null
            cachedResult = null
            oncePerSuiteWrapper = ->
              id = jasmine?.getEnv()?.currentSpec?.suite?.id || globalPatches.__autoIncrement++
              if id != cachedId
                cachedResult = fn()
                cachedId = id
              cachedResult
            Object.defineProperty(context, name, get: oncePerSuiteWrapper, configurable: true)

        id = jasmine?.getEnv()?.currentSuite?.id
        suites[id] ||= []
        suites[id].push {fn: doit, name: name}

      if fn then ret(fn) else ret

  _.extend @, globalPatches

  #
  # Install the relevant scope before the suite runs
  #
  beforeEach ->
    id = jasmine?.getEnv()?.currentSpec?.suite?.id
    _.each suites[id], (obj) ->
      namespaceStack[obj.name] ||= []
      namespaceStack[obj.name].push obj
      obj.fn()

  #
  # Wrap Suite.prototype.finish to pop the installed scopes
  #
  finish = jasmine.Suite.prototype.finish
  jasmine.Suite.prototype.finish = (cb) ->
    _.each suites[@id], (obj) ->
      namespaceStack[obj.name]?.pop()
      _.last(namespaceStack[obj.name])?.fn?()
    finish.call @, cb

# Install the added and patched functions in the correct context
context = (typeof window == "object" && window) || (typeof global == "object" && global) || @
jasmine = context.jasmine || require("jasmine")

unless jasmine? # the user forgot to include jasmine in the environment
  console.error "jasmine-beforeSuite: Jasmine must be required first. Aborting."
else
  install.call(context, context._ || require("underscore"), jasmine)
