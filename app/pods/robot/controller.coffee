`import Ember from 'ember'`

RobotController = Ember.Controller.extend
  final_transcript: undefined
  crypton:          undefined
  recognition:      undefined
  speech:           undefined
  url:              "https://wwwp.oakland.edu/"
  cryptonIsAlive:   false
  cryptonState:     'Asleep'
  name:             ''
  mode:             ''
  option1:          undefined
  option2:          undefined
  option3:          undefined

  isListening: Ember.computed 'cryptonIsAlive', ->
    if Ember.isEqual(@get('cryptonIsAlive'),true)
      true
    else
      false

  tip: Ember.computed 'mode', 'cryptonIsAlive', ->
    switch @get('mode')
      when 'vid','pic','info'
        "Say 'Go Home','Go Back' to return"
      when 'init'
        "Say 'Hello Crypton' to start"
      when 'home'
        "Say 'Goodbye Crypton' to end"

  init: ->
    @_super()

    recognition = new webkitSpeechRecognition()
    speech = new SpeechSynthesisUtterance()

    recognition.continuous = true
    recognition.interimResults = true
    speech.lang = 'en-GB'

    @setProperties
      final_transcript: ''
      mode:             'init'
      recognition:      recognition
      speech:           speech

    window.privateVar = this

    recognition.onresult = ((event) =>
      that = window.privateVar
      speech = that.get('speech')
      final_transcript = that.get('final_transcript')
      interim_transcript = ''

      interim_transcript = ''
      i = event.resultIndex
      while i < event.results.length
        if event.results[i].isFinal
          final_transcript += event.results[i][0].transcript
        else
          interim_transcript += event.results[i][0].transcript
        ++i
      
      val = interim_transcript.toLowerCase()
      console.log val

      
      if (val.search('up') >= 0 or val.search('forward') >= 0)
        that.moveForward(recognition)

      if (val.search('down') >= 0 or val.search('back') >= 0)
        that.moveBackward(recognition)

      if val.search('left') >= 0
        that.moveLeft(recognition)

      if val.search('right') >= 0
        that.moveRight(recognition)

      if val.search('circle') >= 0
        that.callSparkFunction('relay', 'D3','HIGH')
        setTimeout(console.log('1s delay'), 1000)
        that.callSparkFunction('relay', 'D3','LOW')
        speech.text = 'making circle'
        that.set 'cryptonIsAlive', false
        recognition.abort()

      if val.search('spin') >= 0
        that.callSparkFunction('relay', 'D0','HIGH')
        setTimeout(console.log('1s delay'), 1000)
        that.callSparkFunction('relay', 'D0','LOW')
        speech.text = 'watch me spin around'
        that.set 'cryptonIsAlive', false
        recognition.abort()

      if val.search('squar') >= 0
        that.callSparkFunction('relay', 'D1','HIGH')
        setTimeout(console.log('1s delay'), 1000)
        that.callSparkFunction('relay', 'D1','LOW')
        speech.text = 'squar'
        that.set 'cryptonIsAlive', false
        recognition.abort()

      if val.search('dance') >= 0
        that.callSparkFunction('relay', 'D2','HIGH')
        setTimeout(console.log('1s delay'), 1000)
        that.callSparkFunction('relay', 'D2','LOW')
        speech.text = 'watch me dance'
        that.set 'cryptonIsAlive', false
        recognition.abort()

      )

    recognition.onstart = () ->
    recognition.onstop  = () ->
    recognition.onend   = () =>
      that = this
      that.set('cryptonIsAlive', false)


    speech.onstart      = () ->
    speech.onend        = () ->
    speech.onpause      = () ->
    speech.onresume     = () ->

  moveForward: (recognition) ->
    that = this
    speech = that.get('speech')
    that.callSparkFunction('relay', 'D4','HIGH')
    setTimeout(console.log('1s delay'), 1000)
    that.callSparkFunction('relay', 'D4','LOW')
    speech.text = 'moving forward'
    that.set 'cryptonIsAlive', false
    recognition.abort()

  moveBackward: (recognition) ->
    that = this
    speech = that.get('speech')
    that.callSparkFunction('relay', 'D5','HIGH')
    setTimeout(console.log('1s delay'), 1000)
    that.callSparkFunction('relay', 'D5','LOW')
    speech.text = 'moving backward'
    that.set 'cryptonIsAlive', false
    recognition.abort()

  moveLeft: (recognition) ->
    that = this
    speech = that.get('speech')
    that.callSparkFunction('relay', 'D6','HIGH')
    setTimeout(console.log('1s delay'), 1000)
    that.callSparkFunction('relay', 'D6','LOW')
    speech.text = 'moving left'
    that.set 'cryptonIsAlive', false
    recognition.abort()

  moveRight: (recognition) ->
    that = this
    speech = that.get('speech')
    that.callSparkFunction('relay', 'D7','HIGH')
    setTimeout(console.log('1s delay'), 1000)
    that.callSparkFunction('relay', 'D7','LOW')
    speech.text = 'moving right'
    that.set 'cryptonIsAlive', false
    recognition.abort()

  callSparkFunction: (name, arg1, arg2) ->
    $.ajax(
      url: "https://api.spark.io/v1/devices/54ff74066667515124391367/#{name}",
      type: "POST",
      data: "access_token=5917d6819c35e3aa295586eb40af878f3eac39b2&params=#{arg1},#{arg2}",
      success: () ->
        console.log('Spark core command sent successfully')
    )

  actions:
    startListening: ->
      that = this
      recognition = that.get('recognition')
      status = that.get('cryptonIsAlive')

      if !status
        recognition.start()
        that.set('cryptonIsAlive', true)
      else
        recognition.stop()
        that.set('cryptonIsAlive', false)

    moveForward: -> @moveForward
    moveLeft: -> @moveLeft
    moveRight: -> @moveRight
    moveBackward: -> @moveBackward

`export default RobotController`
