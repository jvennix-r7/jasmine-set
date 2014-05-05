#
# jasmine-set - 0.1.4
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
# @see https://github.com/jvennix-r7/jasmine-set
#
# Released under the MIT License.
#

install = (_, jasmine, beforeSuite, afterSuite) ->

  # Contains a map of suite ID -> [{name: var1, installfn: ->}]
  suites = {}

  # Contains a map of varname -> [{name: var1, installfn: ->}] (a stack of installations)
  namespaceStack = {}

  # Save a ref to the global context
  context = @

  globalPatches =

    # set enables a Suite-refinable storage mechanism.
    # @param name [String] the name of the var you are defining
    # @param opts [Object] the options hash (optional)
    # @option opts :now [Boolean] evaluate the anon func immediately (false)
    # @return [void]
    set: (name, opts, fn) ->

      # Install callbacks to make sure our global variable is set-up/torn down correctly.
      beforeSuite ->
        id = jasmine?.getEnv()?.currentSpec?.suite?.id
        obj = _.find suites[id], (obj) -> obj.name is name
        return unless obj?
        namespaceStack[name] ||= []
        namespaceStack[name].push obj
        obj?.fn?()

      afterSuite ->
        delete context[name]
        namespaceStack[name]?.pop()
        _.last(namespaceStack[name])?.fn?()

      if _.isFunction(opts)
        fn = opts
        opts = null

      opts ||= {}
      opts.now ?= false

      # we return a function that accepts a function, so we have a nicer
      # DSL syntax. Of course this clashes with jasmine's, insistence, on,
      # comma, -> so we will support both.
      ret = (fn) ->
        setter = (x) ->
          oncePerSuiteWrapper()
          delete context[name]
          context[name] = x

        oncePerSuiteWrapper = null
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
            Object.defineProperty(context, name, get: oncePerSuiteWrapper, set: setter, configurable: true)

        id = jasmine?.getEnv()?.currentSuite?.id
        suites[id] ||= []
        suites[id].push {fn: doit, name: name}

      if fn then ret(fn) else ret

  _.extend @, globalPatches

# Install the added and patched functions in the correct context
context = (typeof window == "object" && window) || (typeof global == "object" && global) || @
jasmine = context.jasmine || require("jasmine")
require("jasmine-before-suite") unless @beforeSuite?

unless jasmine? # the user forgot to include jasmine in the environment
  console.error "jasmine-set: Jasmine must be required first. Aborting."
else
  install.call(context, context._ || require("underscore"), jasmine, context.beforeSuite, context.afterSuite)
