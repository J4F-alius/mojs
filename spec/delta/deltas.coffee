Deltas = mojs._pool.Deltas
Delta  = mojs._pool.Delta

options = {}
props   = {}

describe 'Deltas ->', ->
  it 'should have _o', ->
    deltas = new Deltas
      options: options,
      props: props

    expect( deltas._o.options ).toBe options
    expect( deltas._o.props ).toBe props

  describe '_createTimeline method', ->
    it 'should create a Timeline', ->
      deltas = new Deltas
        options:  options,
        props:    props

      deltas.timeline = null

      deltas._createTimeline()
      
      expect(deltas.timeline instanceof mojs.Timeline).toBe true

    it 'should be called on initialization', ->
      spyOn Deltas::, '_createTimeline'
      timeline = {}
      deltas = new Deltas
        options:  options,
        props:    props
        timeline: timeline

      expect( Deltas::_createTimeline ).toHaveBeenCalledWith timeline

    it 'should pass timeline options to the timeline', ->
      timeline = {}
      deltas = new Deltas
        options:  options,
        props:    props
        timeline: {}

      expect(deltas.timeline._o).toEqual timeline

    it 'should pass callbackOverrides to the timeline', ->
      
      fun = ->
      deltas = new Deltas
        options:  options,
        props:    props,
        onUpdate: fun
      
      expect(deltas.timeline._callbackOverrides.onUpdate).toBe fun

    it 'should add _deltas to the Timeline', ->
      options = {
        stroke: 'cyan',
        x: { 20: 0, easing: 'cubic.in' },
        y: { 0: 40, easing: 'cubic.out' },
        radius: { 0: 40, duration: 400 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas = new Deltas
        options:  options,
        props:    props

      expect( deltas.timeline._timelines.length ).toBe 4

  describe '_parseDeltas method ->', ->
    it 'should parse main tween options', ->
      deltas = new Deltas
        options:  options,
        props:    props

      opts = {
        stroke: 'cyan',
        x: { 20: 0 },
        y: { 0: 40 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas._mainTweenOptions = null
      deltas._parseDeltas opts

      expect( deltas._mainTweenOptions ).toEqual { duration: 1000, backwardEasing: 'cubic.out' }

    it 'should parse main deltas', ->
      deltas = new Deltas
        options:  options,
        props:    props

      opts = {
        stroke: 'cyan',
        x: { 20: 0 },
        y: { 0: 40 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas._mainDeltas = null

      deltas._parseDeltas opts

      expect( deltas._mainDeltas )
      .toEqual [
        deltas._parseDelta('x', { 20: 0 }),
        deltas._parseDelta('y', { 0:  40 }),
        deltas._parseDelta('fill', { 'cyan':  'red' }),
      ]

    it 'should parse child deltas', ->
      deltas = new Deltas
        options:  options,
        props:    props

      opts = {
        stroke: 'cyan',
        x: { 20: 0, duration: 4000 },
        y: { 0: 40, delay: 200 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas._childDeltas = null

      deltas._parseDeltas opts

      expect( deltas._childDeltas )
      .toEqual [
        { delta: deltas._parseDelta('x', { 20: 0 }), tweenOptions: { duration: 4000 } },
        { delta: deltas._parseDelta('y', { 0: 40 }), tweenOptions: { delay: 200 } }
      ]

    it 'should be called on initialization', ->
      spyOn(Deltas.prototype, '_parseDeltas').and.callThrough()
      deltas = new Deltas
        options:  options,
        props:    props

      expect( Deltas.prototype._parseDeltas ).toHaveBeenCalledWith options


  describe '_splitAndParseDelta method ->', ->
    it 'should call _splitTweenOptions method with passed object', ->
      deltas = new Deltas
        options:  options,
        props:    props

      deltas.isIt = 1
      spyOn(deltas, '_splitTweenOptions').and.callThrough()

      result = deltas._splitAndParseDelta 'x', { 20: 10 }

    it 'should parse delta object', ->
      deltas = new Deltas
        options:  options,
        props:    props

      spyOn deltas, '_parseDelta'
      result = deltas._splitAndParseDelta 'x', { 20: 10, duration: 2000 }
      expect( deltas._parseDelta ).toHaveBeenCalledWith 'x', { 20: 10 }

    it 'should return parsed delta and tween properties', ->
      deltas = new Deltas
        options:  options,
        props:    props

      result = deltas._splitAndParseDelta 'x', { 20: 10, duration: 2000 }
      expect( result.delta ).toEqual deltas._parseDelta 'x', { 20: 10 }
      expect( result.tweenOptions ).toEqual { duration: 2000 }

    it 'should return falsy tweenOptions if none', ->
      deltas = new Deltas
        options:  options,
        props:    props

      result = deltas._splitAndParseDelta 'x', { 20: 10 }
      expect( result.delta ).toEqual deltas._parseDelta 'x', { 20: 10 }
      expect( result.tweenOptions ).toBeFalsy()

  describe '_splitTweenOptions method', ->
    it 'should return tween options separated from delta', ->
      deltas = new Deltas
        options:  options,
        props:    props

      result = deltas._splitTweenOptions { 0: 20, duration: 2000, delay: 200, easing: 'cubic.in' }

      expect( result.delta ).toEqual { 0: 20 }
      expect( result.tweenOptions ).toEqual { duration: 2000, delay: 200, easing: 'cubic.in' }

    it 'should not return tweenOptions if any', ->
      deltas = new Deltas
        options:  options,
        props:    props

      result = deltas._splitTweenOptions { 0: 20 }

      expect( result.delta ).toEqual { 0: 20 }
      expect( result.tweenOptions ).toBeFalsy()

    it 'should parse curve as part of delta', ->
      deltas = new Deltas
        options:  options,
        props:    props

      result = deltas._splitTweenOptions { 0: 20, curve: 'M0,0 L100,0' }

      expect( result.delta ).toEqual { 0: 20, curve: 'M0,0 L100,0' }
      expect( result.tweenOptions ).toBeFalsy()

  describe '_createDeltas method ->', ->
    it 'should create deltas from parsed object ->', ->
      options = {
        stroke: 'cyan',
        x: { 20: 0, duration: 4000 },
        y: { 0: 40, delay: 200 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas = new Deltas
        options:  options,
        props:    props

      deltas._deltas = null

      deltas._createDeltas()
      mainDelta = deltas._deltas[0]

      expect( mainDelta._o.deltas ).toBe deltas._mainDeltas
      expect( mainDelta._o.tweenOptions ).toBe deltas._mainTweenOptions
      expect( mainDelta._o.props ).toBe props
      expect( mainDelta instanceof Delta ).toBe true

    it 'should create deltas from parsed child objects ->', ->
      options = {
        stroke: 'cyan',
        x: { 20: 0, duration: 4000 },
        y: { 0: 40, delay: 200 },
        fill: { 'cyan' : 'red' },
        duration: 1000,
        backwardEasing: 'cubic.out'
      }

      deltas = new Deltas
        options:  options,
        props:    props

      deltas._deltas = null

      deltas._createDeltas()
      childDelta1 = deltas._deltas[1]
      childDelta2 = deltas._deltas[2]

      expect( childDelta1._o.deltas ).toEqual [deltas._childDeltas[0].delta]
      expect( childDelta1._o.tweenOptions ).toBe deltas._childDeltas[0].tweenOptions
      expect( childDelta1._o.props ).toBe props
      expect( childDelta1 instanceof Delta ).toBe true

      expect( childDelta2._o.deltas ).toEqual [deltas._childDeltas[1].delta]
      expect( childDelta2._o.tweenOptions ).toBe deltas._childDeltas[1].tweenOptions
      expect( childDelta2._o.props ).toBe props
      expect( childDelta2 instanceof Delta ).toBe true

    it 'should be called on initialization', ->
      spyOn(Deltas.prototype, '_createDeltas').and.callThrough()
      deltas = new Deltas
        options:  options,
        props:    props

      expect( Deltas.prototype._createDeltas ).toHaveBeenCalled()


  describe '_isDelta method ->', ->
    it 'should detect if value is not a delta value', ->
      deltas = new Deltas
        options:  options,
        props:    props

      expect(deltas._isDelta(45))    .toBe false
      expect(deltas._isDelta('45'))  .toBe false
      expect(deltas._isDelta(['45'])).toBe false
      expect(deltas._isDelta({ unit: 'px', value: 20 })).toBe false
      expect(deltas._isDelta({ 20: 30 })).toBe true


  describe '_createDelta method ->', ->
    it 'should create delta from passed objects', ->
      deltas = new Deltas
        options:  options,
        props:    props

      deltasArr = []
      tweenOpts = {}
      result = deltas._createDelta deltasArr, tweenOpts

      expect( result instanceof Delta ).toBe true
      expect( result._o.deltas ).toBe deltasArr
      expect( result._o.tweenOptions ).toBe tweenOpts
      expect( result._o.props ).toBe props

  describe '_parseColorDelta method ->', ->
    it 'should calculate color delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseColorDelta 'stroke',  {'#000': 'rgb(255,255,255)'}
      expect(delta.start.r)    .toBe   0
      expect(delta.end.r)      .toBe   255
      expect(delta.delta.r)    .toBe   255
      expect(delta.type)       .toBe   'color'
      expect(delta.name)       .toBe   'stroke'

    it 'should ignore stroke-linecap prop, use start prop and warn', ->
      deltas = new Deltas options: options, props: props

      spyOn console, 'warn'
      delta = deltas._parseColorDelta 'strokeLinecap', {'round': 'butt'}
      expect(-> deltas._parseColorDelta 'strokeLinecap', {'round': 'butt'})
        .not.toThrow()
      expect(console.warn).toHaveBeenCalled()
      expect(delta.type).not.toBeDefined()

    it 'should parse color curve values', ->
      deltas = new Deltas options: options, props: props

      spyOn(mojs.easing, 'parseEasing').and.callThrough()
      curve = "M0,100 L100,0"
      startDelta = {'#000': 'rgb(255,255,255)', curve: curve }
      delta = deltas._parseColorDelta 'stroke', startDelta
      expect(delta.start.r)    .toBe   0
      expect(delta.end.r)      .toBe   255
      expect(delta.delta.r)    .toBe   255
      expect(delta.type)       .toBe   'color'

      expect(typeof delta.curve).toBe   'function'
      expect(delta.curve(.5))   .toBeCloseTo  .5, 2

      expect(mojs.easing.parseEasing).toHaveBeenCalledWith curve


  describe '_parseArrayDelta method ->', ->
    it 'should calculate array delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseArrayDelta 'strokeDasharray', { '200 100%': '300' }
      expect(delta.type)           .toBe   'array'
      expect(delta.start[0].value) .toBe   200
      expect(delta.start[0].unit)  .toBe   'px'
      expect(delta.end[0].value)   .toBe   300
      expect(delta.end[0].unit)    .toBe   'px'
      expect(delta.start[1].value) .toBe   100
      expect(delta.start[1].unit)  .toBe   '%'
      expect(delta.end[1].value)   .toBe   0
      expect(delta.end[1].unit)    .toBe   '%'
      expect(delta.name)           .toBe   'strokeDasharray'
    it 'should calculate array delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseArrayDelta 'strokeDashoffset', { '200 100%': '300' }
      expect(delta.type)           .toBe   'array'
      expect(delta.start[0].value) .toBe   200
      expect(delta.start[0].unit)  .toBe   'px'
      expect(delta.end[0].value)   .toBe   300
      expect(delta.end[0].unit)    .toBe   'px'
      expect(delta.start[1].value) .toBe   100
      expect(delta.start[1].unit)  .toBe   '%'
      expect(delta.end[1].value)   .toBe   0
      expect(delta.end[1].unit)    .toBe   '%'
    it 'should calculate array delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseArrayDelta 'origin', { '200 100%': '300' }
      expect(delta.type)           .toBe   'array'
      expect(delta.start[0].value) .toBe   200
      expect(delta.start[0].unit)  .toBe   'px'
      expect(delta.end[0].value)   .toBe   300
      expect(delta.end[0].unit)    .toBe   'px'
      expect(delta.start[1].value) .toBe   100
      expect(delta.start[1].unit)  .toBe   '%'
      expect(delta.end[1].value)   .toBe   0
      expect(delta.end[1].unit)    .toBe   '%'

    it 'should parse array curve values', ->
      deltas = new Deltas options: options, props: props
      spyOn(mojs.easing, 'parseEasing').and.callThrough()
      curve = "M0,100 L100,0"
      delta = deltas._parseArrayDelta 'origin', { '200 100%': '300', curve: curve }
      expect(delta.type)           .toBe   'array'
      expect(delta.start[0].value) .toBe   200
      expect(delta.start[0].unit)  .toBe   'px'
      expect(delta.end[0].value)   .toBe   300
      expect(delta.end[0].unit)    .toBe   'px'
      expect(delta.start[1].value) .toBe   100
      expect(delta.start[1].unit)  .toBe   '%'
      expect(delta.end[1].value)   .toBe   0
      expect(delta.end[1].unit)    .toBe   '%'

      expect(typeof delta.curve).toBe   'function'
      expect(delta.curve(.5))   .toBeCloseTo  .5, 2

      expect(mojs.easing.parseEasing).toHaveBeenCalledWith curve

  describe '_parseUnitDelta method ->', ->
    it 'should calculate unit delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseUnitDelta 'x', {'0%': '100%'}
      expect(delta.start.string)    .toBe   '0'
      expect(delta.end.string)      .toBe   '100%'
      expect(delta.delta)           .toBe   100
      expect(delta.type)            .toBe   'unit'

    it 'should parse array curve values', ->
      deltas = new Deltas options: options, props: props
      spyOn(mojs.easing, 'parseEasing').and.callThrough()
      curve = "M0,100 L100,0"
      delta = deltas._parseUnitDelta 'x', { '0%': '100%', curve: curve }
      expect(delta.start.string)    .toBe   '0'
      expect(delta.end.string)      .toBe   '100%'
      expect(delta.delta)           .toBe   100
      expect(delta.type)            .toBe   'unit'

      expect(typeof delta.curve).toBe   'function'
      expect(delta.curve(.5))   .toBeCloseTo  .5, 2

      expect(mojs.easing.parseEasing).toHaveBeenCalledWith curve

  describe '_parseNumberDelta method ->', ->
    it 'should calculate delta', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseNumberDelta 'radius', {25: 75}
      expect(delta.start)   .toBe   25
      expect(delta.delta)   .toBe   50
      expect(delta.type)    .toBe   'number'
      expect(delta.name)    .toBe   'radius'
    it 'should parse curve', ->
      deltas = new Deltas options: options, props: props

      spyOn(mojs.easing, 'parseEasing').and.callThrough()
      curve = "M0,100 L100,0"
      startDelta = { 25: 75, curve: curve }
      delta = deltas._parseNumberDelta 'radius', startDelta
      expect(delta.start)   .toBe   25
      expect(delta.delta)   .toBe   50
      expect(delta.type)    .toBe   'number'
      
      expect(typeof delta.curve).toBe 'function'
      expect(delta.curve(.5)).toBeCloseTo .5, 2
      expect(mojs.easing.parseEasing).toHaveBeenCalledWith curve
      
      expect(startDelta.curve).toBe curve

    it 'should calculate delta with string arguments', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseNumberDelta 'radius', {25: 75}
      expect(delta.start)   .toBe   25
      expect(delta.delta)   .toBe   50
    it 'should calculate delta with float arguments', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseNumberDelta 'radius',  {'25.50': 75.50}
      expect(delta.start)   .toBe   25.5
      expect(delta.delta)   .toBe   50
    it 'should calculate delta with negative start arguments', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseNumberDelta 'radius',  {'-25.50': 75.50}
      expect(delta.start)   .toBe   -25.5
      expect(delta.delta)   .toBe   101
    it 'should calculate delta with negative end arguments', ->
      deltas = new Deltas options: options, props: props

      delta = deltas._parseNumberDelta 'radius',  {'25.50': -75.50}
      expect(delta.start)   .toBe   25.5
      expect(delta.end)     .toBe   -75.5
      expect(delta.delta)   .toBe   -101

  describe '_preparseDelta method', ->
    it 'should parse start and end values of passed delta', ->
      deltas = new Deltas options: options, props: props
      delta = deltas._preparseDelta { '25.50': -75.50 }
      expect( delta.start ).toBe '25.50'
      expect( delta.end ).toBe -75.50

    it 'should parse curve', ->
      deltas = new Deltas options: options, props: props


      curve = "M0,100 L100,0"
      startDelta = { 25: 75, curve: curve }

      spyOn(mojs.easing, 'parseEasing').and.callThrough()

      delta = deltas._preparseDelta startDelta
      expect( delta.start ).toBe '25'
      expect( delta.end ).toBe 75

      expect(typeof delta.curve).toBe 'function'
      expect(delta.curve(.5)).toBeCloseTo .5, 2
      expect(mojs.easing.parseEasing).toHaveBeenCalledWith curve
      
      expect(startDelta.curve).toBe curve

    it 'should not parse curve if not set', ->
      deltas = new Deltas options: options, props: props

      startDelta = { 25: 75 }

      spyOn(mojs.easing, 'parseEasing').and.callThrough()

      delta = deltas._preparseDelta startDelta
      expect( delta.start ).toBe '25'
      expect( delta.end ).toBe 75

      expect(typeof delta.curve).toBe 'undefined'
      expect(mojs.easing.parseEasing).not.toHaveBeenCalled()

  describe 'color parsing - _makeColorObj method', ->
    deltas = new Deltas options: options, props: props
    it 'should have _shortColors map', ->
      expect(deltas._shortColors).toBeDefined()
    it 'should parse 3 hex color', ->
      colorObj = deltas._makeColorObj '#f0f'
      expect(colorObj.r)  .toBe 255
      expect(colorObj.g)  .toBe 0
      expect(colorObj.b)  .toBe 255
      expect(colorObj.a)  .toBe 1
    it 'should parse 6 hex color', ->
      colorObj = deltas._makeColorObj '#0000ff'
      expect(colorObj.r)  .toBe 0
      expect(colorObj.g)  .toBe 0
      expect(colorObj.b)  .toBe 255
      expect(colorObj.a)  .toBe 1
    it 'should parse color shorthand', ->
      colorObj = deltas._makeColorObj 'deeppink'
      expect(colorObj.r)  .toBe 255
      expect(colorObj.g)  .toBe 20
      expect(colorObj.b)  .toBe 147
      expect(colorObj.a)  .toBe 1
    it 'should parse none color shorthand', ->
      colorObj = deltas._makeColorObj 'none'
      expect(colorObj.r)  .toBe 0
      expect(colorObj.g)  .toBe 0
      expect(colorObj.b)  .toBe 0
      expect(colorObj.a)  .toBe 0
    it 'should parse rgb color', ->
      colorObj = deltas._makeColorObj 'rgb(200,100,0)'
      expect(colorObj.r)  .toBe 200
      expect(colorObj.g)  .toBe 100
      expect(colorObj.b)  .toBe 0
      expect(colorObj.a)  .toBe 1
    it 'should parse rgba color', ->
      colorObj  = deltas._makeColorObj 'rgba(0,200,100,.1)'
      expect(colorObj.r)  .toBe 0
      expect(colorObj.g)  .toBe 200
      expect(colorObj.b)  .toBe 100
      expect(colorObj.a)  .toBe .1
    it 'should parse rgba color with float starting by 0', ->
      colorObj = deltas._makeColorObj 'rgba(0,200,100,0.5)'
      expect(colorObj.r)  .toBe 0
      expect(colorObj.g)  .toBe 200
      expect(colorObj.b)  .toBe 100
      expect(colorObj.a)  .toBe .5

  describe 'strToArr method', ->
    deltas = new Deltas options: options, props: props

    it 'should parse string to array',->
      array = deltas._strToArr('200 100')
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  'px'
    it 'should parse % string to array',->
      array = deltas._strToArr('200% 100')
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  '%'
      expect(array[1].value).toBe 100
      expect(array[1].unit).toBe  'px'
    it 'should parse number to array',->
      array = deltas._strToArr(200)
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  'px'
    it 'should parse string with multiple spaces to array',->
      array = deltas._strToArr('200   100%')
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  'px'
      expect(array[1].value).toBe 100
      expect(array[1].unit).toBe  '%'
    it 'should trim string before parse',->
      array = deltas._strToArr('  200   100% ')
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  'px'
      expect(array[1].value).toBe 100
      expect(array[1].unit).toBe  '%'
    it 'should parse rand values',->
      array = deltas._strToArr('  200   rand(10,20) ')
      expect(array[0].value).toBe 200
      expect(array[0].unit).toBe  'px'
      expect(array[1].value).toBeGreaterThan     10
      expect(array[1].value).not.toBeGreaterThan 20
      expect(array[1].unit).toBe  'px'

  describe '_parseDelta method ->', ->
    describe 'color values ->', ->
      it 'should parse color objects', ->
        deltas = new Deltas options: options, props: props
        spyOn(deltas, '_parseColorDelta').and.callThrough()

        name = 'color'; sourceDelta = { 'cyan' : 'white' }
        delta = deltas._parseDelta name, sourceDelta

        expect( deltas._parseColorDelta ).toHaveBeenCalledWith name, sourceDelta
        expect( delta ).toEqual deltas._parseColorDelta name, sourceDelta

      it 'should not react on rand values', ->
        deltas = new Deltas options: options, props: props
        spyOn(deltas, '_parseColorDelta').and.callThrough()

        name = 'color'; sourceDelta = { 'rand(1,20)' : 'white' }
        delta = deltas._parseDelta name, sourceDelta

        expect( deltas._parseColorDelta ).not.toHaveBeenCalled()

      it 'should not react on stagger values', ->
        deltas = new Deltas options: options, props: props
        spyOn(deltas, '_parseColorDelta').and.callThrough()

        name = 'color'; sourceDelta = { 'stagger(20)' : 'white' }
        delta = deltas._parseDelta name, sourceDelta

        expect( deltas._parseColorDelta ).not.toHaveBeenCalled()

    describe 'array values ->', ->
      arrayPropertyMap = { transformOrigin: 1 }
      it 'should treat the value as array if it is set in arrayPropertyMap object', ->
        deltas = new Deltas
          options: options, props: props, arrayPropertyMap: arrayPropertyMap
        spyOn(deltas, '_parseArrayDelta').and.callThrough()

        name = 'transformOrigin'; sourceDelta = { '100 200' : '0 50' }
        delta = deltas._parseDelta name, sourceDelta

        expect( deltas._parseArrayDelta ).toHaveBeenCalledWith name, sourceDelta
        expect( delta ).toEqual deltas._parseArrayDelta name, sourceDelta

    describe 'unit values ->', ->
      it 'should parse unit values by default', ->
        deltas = new Deltas options: options, props: props
        spyOn(deltas, '_parseUnitDelta').and.callThrough()

        name = 'x'; sourceDelta = { '20' : '30' }
        delta = deltas._parseDelta name, sourceDelta

        expect( deltas._parseUnitDelta ).toHaveBeenCalledWith name, sourceDelta, undefined
        expect( delta ).toEqual deltas._parseUnitDelta name, sourceDelta

      it 'should pass the index', ->
        deltas = new Deltas options: options, props: props
        spyOn(deltas, '_parseUnitDelta').and.callThrough()

        name = 'x'; sourceDelta = { '20' : '30' }; index = 3
        delta = deltas._parseDelta name, sourceDelta, index

        expect( deltas._parseUnitDelta ).toHaveBeenCalledWith name, sourceDelta, index
        expect( delta ).toEqual deltas._parseUnitDelta name, sourceDelta, index

      it 'should parse properties that are in numberPropertyMap as numbers', ->
        numberPropertyMap = { opacity: 1 }
        deltas = new Deltas
          options: options, props: props, numberPropertyMap: numberPropertyMap
        spyOn(deltas, '_parseUnitDelta').and.callThrough()
        spyOn(deltas, '_parseNumberDelta').and.callThrough()

        name = 'opacity'; sourceDelta = { '20' : '30' }; index = 3
        delta = deltas._parseDelta name, sourceDelta, index

        expect( deltas._parseUnitDelta ).not.toHaveBeenCalled()
        expect( deltas._parseNumberDelta ).toHaveBeenCalledWith name, sourceDelta, index
        expect( delta ).toEqual deltas._parseNumberDelta name, sourceDelta, index




