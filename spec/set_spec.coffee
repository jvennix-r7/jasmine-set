require('../src/set') unless @set?

describe 'jasmine-set plugin', ->

  describe 'a top-level set (a=1)', ->
    set 'a', -> 1

    it 'sets a to 1', -> expect(a).toEqual(1)

    describe 'a nested refining set', ->
      set 'a', -> 2

      it 'sets a to 2', -> expect(a).toEqual(2)

    describe 'a nested set that does not change a', ->

      it 'sets a to 1', -> expect(a).toEqual(1)

      describe 'a nested refining set', ->
        set 'a', -> 3

        it 'sets a to 3', -> expect(a).toEqual(3)

        describe 'a nested set that does not change a', ->

          it 'sets a to 3', -> expect(a).toEqual(3)


  describe 'the next suite (a=3)', ->
    set 'a', -> 3

    it 'sets a to 3', -> expect(a).toEqual(3)

  describe 'the next suite, which does not set a', ->

    it 'does not set a', -> expect(-> a).toThrow()