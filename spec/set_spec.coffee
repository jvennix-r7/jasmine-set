_ = require('underscore')
require('jasmine-before-suite')
require('../src/set') unless @set?

describe 'jasmine-set plugin', ->

  describe 'a top-level set (a=1)', ->
    set 'a', -> 1

    _.times 3, -> it 'sets a to 1', -> expect(a).toEqual(1)

    describe 'a nested refining set', ->
      set 'a', -> 2

      _.times 3, ->  it 'sets a to 2', -> expect(a).toEqual(2)

    describe 'a nested set that does not change a', ->

      _.times 3, -> it 'sets a to 1', -> expect(a).toEqual(1)

      describe 'a nested refining set', ->
        set 'a', -> 3

        _.times 3, -> it 'sets a to 3', -> expect(a).toEqual(3)

        describe 'a nested set that does not change a', ->

          _.times 3, -> it 'sets a to 3', -> expect(a).toEqual(3)

  describe 'the next suite (a=3)', ->

    set 'a', -> 3

    _.times 3, -> it 'sets a to 3', -> expect(a).toEqual(3)

  describe 'the next suite, which does not set a', ->

    _.times 3, -> it 'does not set a', -> expect(typeof a).toEqual("undefined")

  describe 'a suite that accesses the a in beforeEach', ->

    set 'a', -> 4

    beforeEach ->
      `a = 5`

    _.times 3, -> it 'sets a to 5', -> expect(a).toEqual(5)

  describe 'a suite that calls set after beforeEach', ->

    set 'b', -> 7

    beforeEach ->
      `b = 6`

    _.times 3, -> it 'sets b to 6', -> expect(b).toEqual(6)
