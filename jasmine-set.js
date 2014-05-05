//
// jasmine-beforeSuite - 0.1.0
//
// A plugin for the Jasmine behavior-driven Javascript testing framework that
// adds a `set` global function. It is inspired by rspec's very nice `let` syntax.
//
// Works in both node.js and a browser environment.
//
// Requires jasmine.js and underscore.js.
//
// @author Joe Vennix
// @copyright Rapid7 2014
// @see https://github.com/jvennix-r7/jasmine-beforeSuite
//
// Released under the MIT License.
//

(function() {
  var context, install, jasmine;

  install = function(_, jasmine) {
    var context, finish, globalPatches, namespaceStack, suites;
    suites = {};
    namespaceStack = {};
    context = this;
    globalPatches = {
      set: function(name, opts, fn) {
        var ret;
        if (_.isFunction(opts)) {
          fn = opts;
          opts = null;
        }
        opts || (opts = {});
        if (opts.now == null) {
          opts.now = false;
        }
        ret = function(fn) {
          var doit, id, _ref, _ref1;
          doit = function() {
            var cachedId, cachedResult, oncePerSuiteWrapper;
            if (opts.now) {
              return context[name] = fn();
            } else {
              cachedId = null;
              cachedResult = null;
              oncePerSuiteWrapper = function() {
                var id, _ref, _ref1, _ref2;
                id = (jasmine != null ? (_ref = jasmine.getEnv()) != null ? (_ref1 = _ref.currentSpec) != null ? (_ref2 = _ref1.suite) != null ? _ref2.id : void 0 : void 0 : void 0 : void 0) || globalPatches.__autoIncrement++;
                if (id !== cachedId) {
                  cachedResult = fn();
                  cachedId = id;
                }
                return cachedResult;
              };
              return Object.defineProperty(context, name, {
                get: oncePerSuiteWrapper,
                configurable: true
              });
            }
          };
          id = jasmine != null ? (_ref = jasmine.getEnv()) != null ? (_ref1 = _ref.currentSuite) != null ? _ref1.id : void 0 : void 0 : void 0;
          suites[id] || (suites[id] = []);
          return suites[id].push({
            fn: doit,
            name: name
          });
        };
        if (fn) {
          return ret(fn);
        } else {
          return ret;
        }
      }
    };
    _.extend(this, globalPatches);
    beforeEach(function() {
      var id, _ref, _ref1, _ref2;
      id = jasmine != null ? (_ref = jasmine.getEnv()) != null ? (_ref1 = _ref.currentSpec) != null ? (_ref2 = _ref1.suite) != null ? _ref2.id : void 0 : void 0 : void 0 : void 0;
      return _.each(suites[id], function(obj) {
        var _name;
        namespaceStack[_name = obj.name] || (namespaceStack[_name] = []);
        namespaceStack[obj.name].push(obj);
        return obj.fn();
      });
    });
    finish = jasmine.Suite.prototype.finish;
    return jasmine.Suite.prototype.finish = function(cb) {
      _.each(suites[this.id], function(obj) {
        var _ref, _ref1;
        delete context[obj.name];
        if ((_ref = namespaceStack[obj.name]) != null) {
          _ref.pop();
        }
        return (_ref1 = _.last(namespaceStack[obj.name])) != null ? typeof _ref1.fn === "function" ? _ref1.fn() : void 0 : void 0;
      });
      return finish.call(this, cb);
    };
  };

  context = (typeof window === "object" && window) || (typeof global === "object" && global) || this;

  jasmine = context.jasmine || require("jasmine");

  if (jasmine == null) {
    console.error("jasmine-beforeSuite: Jasmine must be required first. Aborting.");
  } else {
    install.call(context, context._ || require("underscore"), jasmine);
  }

}).call(this);
