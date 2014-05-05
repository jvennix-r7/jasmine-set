jasmine-set brings rspec's `let` syntax to Javascript. The `set` global function is provided, which allows the spec writer to define lazy global accessors that can be refined in nested specs.

##### Why not `let`?

In Ecmascript, `let` is a reserved word that allows for block-level scoping (as opposed to `var`, which is functionally-scoped).

#### Sample Usage

    class Foo
      constructor: (opts) ->
        _.extend @, opts

    describe 'Foo', ->
      set 'opts', -> {}
      set 'foo', -> new Foo(opts)

      it 'is passed an empty hash', -> expect(opts).toBeEmpty()

      describe 'when bar is 1', ->
        set 'opts', -> { bar: 1 }

        it 'is passed a hash with a bar key', -> expect(opts.bar).toBeDefined()
        it 'creates a Foo with the bar behavior', -> expect(foo.bar).toEqual(1)

#### Dependencies

- underscore (~1.6)
- [jasmine-beforeSuite](https://github.com/jvennix-r7/jasmine-beforeSuite)

### Building from source

    $ npm i
    $ ./jake build

### Running specs

    $ ./jake spec [DEBUG=1] [SPEC=./spec/set.coffee]

### License

[MIT](http://en.wikipedia.org/wiki/MIT_License)

### Copyright

Rapid7 2014
