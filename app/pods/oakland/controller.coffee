`import Ember from 'ember'`

OaklandController = Ember.Controller.extend
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
      option1:          'Videos'
      option2:          'Images'
      option3:          'Info'
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

      
      if (val.search('hello') >= 0 or val.search('halo') >= 0)
        if !Ember.isEmpty(that.get('name'))
          speech.text = 'Hello there!'
        else
          speech.text = 'Hello there! What is your name?'
        that.set 'cryptonIsAlive', true
        recognition.abort()
        speechSynthesis.speak(speech)

      if (val.search('goodbye') >= 0 or val.search('bye') >= 0 or val.search('buy') >= 0)  && (val.search('krypton') >= 0 or val.search('crypton') >= 0)
        speech.text = 'goodbye, ' + that.get('name')
        that.set 'cryptonIsAlive', false
        that.set 'name', ''
        recognition.abort()
        speechSynthesis.speak(speech)

      #Listen
      if (val.search('crypton') >= 0  or val.search('krypton') >= 0)
        if !Ember.isEmpty(that.get('name')) and Ember.isEqual(that.get('cryptonIsAlive'),false)
          switch that.get('mode')
            when 'vid','pic','info','home'
              speech.text = 'yes, ' + that.get('name')
              that.set 'cryptonIsAlive', true
              recognition.abort()
              speechSynthesis.speak(speech)

      #Robot Mode
      if (val.search('robot') >= 0  and val.search('mode') >= 0)
        speech.text = 'activating robot mode, please say the password to control the robot'
        that.set('mode', 'auth')
        that.setOptions('auth')
        recognition.abort()
        speechSynthesis.speak(speech)

      if that.get('mode') == 'auth'
        val = final_transcript.toLowerCase()
        #authentication complete
        if (val.search('i love maker faire') >= 0)
          speech.text = 'authentication complete. What would you like the robot to do?'
          that.set('mode', 'robot')
          that.setOptions('robot')
          recognition.abort()
          speechSynthesis.speak(speech)
        #Home
        else if val.search('home') >= 0 && val.search('back') >= 0
          url ="https://wwwp.oakland.edu/"
          that.changeUrl(url)
          that.set('mode', 'home')
          that.setOptions('home')
        #authentication failed
        else if val.length > 4
          speech.text = 'authentication failed. Please say the password again!'
          recognition.abort()
          speechSynthesis.speak(speech)

      if that.get('mode') == 'robot'
        #SparkCore Commands
        if val.search('squar') >= 0
          that.callSparkFunction('relay', 'D1','HIGH')
          setTimeout(console.log('1s delay'), 2000)
          that.callSparkFunction('relay', 'D1','LOW')
          speech.text = 'The robot will make a squar for you!'
          that.set 'cryptonIsAlive', false
          recognition.abort()
          speechSynthesis.speak(speech)

        if val.search('circle') >= 0
          that.callSparkFunction('relay', 'D2','HIGH')
          setTimeout(console.log('1s delay'), 2000)
          that.callSparkFunction('relay', 'D2','LOW')
          speech.text = 'The robot will make a circle for you!'
          that.set 'cryptonIsAlive', false
          recognition.abort()
          speechSynthesis.speak(speech)

        if val.search('dance') >= 0
          that.callSparkFunction('relay', 'D3', 'HIGH')
          setTimeout(console.log('1s delay'), 2000)
          that.callSparkFunction('relay', 'D3','LOW')
          speech.text = 'The robot will impress you with some samba!'
          that.set 'cryptonIsAlive', false
          recognition.abort()
          speechSynthesis.speak(speech)

        #Home
        if val.search('home') >= 0 or val.search('back') >= 0
          url ="https://wwwp.oakland.edu/"
          that.changeUrl(url)
          that.set('mode', 'home')
          that.setOptions('home')


      if that.get('cryptonIsAlive')
        
        #get name
        if final_transcript.search('name') >= 0 && final_transcript.search('my') >= 0
          valArray = final_transcript.split(' ')
          name = valArray[valArray.length - 1]
          that.set 'name', name
          speech.text = 'Well, hello there. Nice to meet you,' + name + '. . What would you like to do?'
          recognition.abort()
          speechSynthesis.speak(speech)

        #Explore OU
        if (val.search('video') >= 0)
          speech.text = 'Here are some videos from Oakland, select one.'
          that.set('mode', 'vid')
          that.setOptions('vid')
          recognition.abort()
          speechSynthesis.speak(speech)

        if (val.search('picture') >= 0) or (val.search('image') >= 0)
          speech.text = 'I have picked-up few pictures for you. Please select one'
          that.set('mode', 'pic')
          that.setOptions('pic')
          recognition.abort()
          speechSynthesis.speak(speech)

        if (val.search('info') >= 0)
          speech.text = 'Select one of the pages to find-out more about Oakland University.'
          that.set('mode', 'info')
          that.setOptions('info')
          recognition.abort()
          speechSynthesis.speak(speech)
        
        
        #Video: OU Engineering
        if that.get('mode') == 'vid'
          if (val.search('engineer') >= 0)
            speech.text = 'Here is a video of the Engineering school at Oakland University'
            url ="https://www.youtube.com/embed/Si40YPA7Uhc?autoplay=1"
            that.set 'cryptonIsAlive', false
            recognition.abort()
            speechSynthesis.speak(speech)
            setTimeout((-> that.changeUrl(url)), 2000)
          #Video: Oakland Campus
          if val.search('campus') >= 0
            speech.text = "Here is a video of Oakland's beautiful campus"
            url ="https://www.youtube.com/embed/xJsbnW6H28o?autoplay=1"
            that.set 'cryptonIsAlive', false
            recognition.abort()
            speechSynthesis.speak(speech)
            setTimeout((-> that.changeUrl(url)), 2000)
          #Video: TEDxOakland
          if val.search('ted') >= 0 or val.search('tedx') >= 0 or val.search('products') >= 0 or val.search('text') >= 0 or val.search('connects') >= 0
            speech.text = 'Join us at Ted x Oakland'
            url ="https://www.youtube.com/embed/ucphcla8T8Y?autoplay=1"
            that.set 'cryptonIsAlive', false
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Home
          if val.search('home') >= 0 or val.search('back') >= 0
            url ="https://wwwp.oakland.edu/"
            that.changeUrl(url)
            that.set('mode', 'home')
            that.setOptions('home')


        #Pictures: Oakland Engineering
        if that.get('mode') == 'pic'
          if val.search('tower') >= 0
            speech.text = "Here is a beautiful picture of Oakland's Elliot Tower"
            url ="https://instagram.com/p/4rv3AjHXUl/embed/"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Pictures: Oakland
          if (val.search('organic') >= 0 or val.search('farm') >= 0)
            speech.text = 'Oakland has its own student organic farm'
            url ="https://instagram.com/p/3wnW2UnXXA/embed/"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Pictures: Midnight Breakfast
          if val.search('midnight') >= 0 or (val.search('breakfast') >= 0)
            speech.text = 'Good choice, you must be feeling hungry'
            url ="https://instagram.com/p/1RDI-ZHXRn/embed/"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Home
          if val.search('home') >= 0 or val.search('back') >= 0
            url ="https://wwwp.oakland.edu/"
            that.changeUrl(url)
            that.set('mode', 'home')
            that.setOptions('home')


        #Info: Oakland Info
        if that.get('mode') == 'info'
          #Campus Map
          if val.search('campus') >= 0 && val.search('map') >= 0
            speech.text = 'Wonderful! Here is a map of Oakland for you to explore!'
            url ="http://www.myatlascms.com/map/index.php?id=566#!ct/5468,6596,6597,6598,6600"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Oakland History
          if val.search('oakland') >= 0 && val.search('history') >= 0
            speech.text = "Here is a timeline of Oakland's history. Explore it at your leisure"
            url ="https://www.oakland.edu/apps/timeline/"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Oakland News
          if val.search('oakland') >= 0 && val.search('news') >= 0
            speech.text = "Here is Oakland's spring magazine. You will find some new about Oaklad here."
            url ="http://viewer.zmags.com/publication/9ce482b8#/9ce482b8/2"
            that.changeUrl(url)
            recognition.abort()
            speechSynthesis.speak(speech)
          #Home
          if val.search('home') >= 0 or val.search('back') >= 0
            url ="https://wwwp.oakland.edu/"
            that.changeUrl(url)
            that.set('mode', 'home')
            that.setOptions('home')

      )

    speech.onend = () ->
      that = window.privateVar
      that.get('recognition').start()

    recognition.onstart = () ->
    recognition.onstop  = () ->
    recognition.onend   = () ->
    speech.onstart      = () ->
    speech.onpause      = () ->
    speech.onresume     = () ->

    recognition.start()

  sparkLogin: (->
    spark.login(
      accessToken: '5917d6819c35e3aa295586eb40af878f3eac39b2').then(
        (token) -> console.log('API call completed on promise resolve: ', token),
        (err) -> console.log('API call completed on promise fail: ', err))

    spark.listDevices((err, devices) ->
      device = devices[0]

      console.log('Device name: ' + device.name)
      console.log('- connected?: ' + device.connected)
      console.log('- variables: ' + device.variables)
      console.log('- functions: ' + device.functions)
      console.log('- version: ' + device.version)
      console.log('- requires upgrade?: ' + device.requiresUpgrade)
    )

    spark.callFunction('54ff74066667515124391367', 'relay', 'D0:HIGH', (err, data) ->
      if (err)
        console.log('An error occurred:', err)
      else
        console.log('Function called succesfully:', data)
    )

    console.log spark
    #.then (token) ->
      #console.log('API call completed on promise resolve: ', token)
    #.catch (err) ->
      #console.log('API call completed on promise fail: ', err)

    #console.log spark
    #spark.listDevices().then (data) ->
      #console.log data

    #spark.getDevice('48ff6f065067555022451287').then (device) ->

      #device.callFunction('relay', 'D7:HIGH').then () ->
        #console.log('Function called succesfully:', data)

  ).on('init')

  callSparkFunction: (name, arg1, arg2) ->
    $.ajax(
      url: "https://api.spark.io/v1/devices/54ff74066667515124391367/#{name}",
      type: "POST",
      data: "access_token=5917d6819c35e3aa295586eb40af878f3eac39b2&params=#{arg1},#{arg2}",
      success: () ->
        console.log('Spark core command sent successfully')
    )

  changeUrl: (url) ->
    @set 'url', url

  setOptions: (mode) ->
    switch mode
      when 'vid'
        @setProperties
          option1:  'School of Engineering'
          option2:  'Oakland Campus'
          option3:  'TEDx Oakland'
      when 'pic'
        @setProperties
          option1:  'Oakland Tower'
          option2:  'Midnight Breakfast'
          option3:  'Organic Farm'
      when 'info'
        @setProperties
          option1:  'Campus Map'
          option2:  'Oakland History'
          option3:  'Oakland News'
      when 'home'
        @setProperties
          option1:  'Videos'
          option2:  'Images'
          option3:  'Info'
      when 'auth'
        @setProperties
          option1:  '******'
          option2:  '******'
          option3:  '******'
      when 'robot'
        @setProperties
          option1:  'Sequare Shape'
          option2:  'Circle Shape'
          option3:  'Dance'

  actions:
    changeUrl: -> @changeUrl("http://viewer.zmags.com/publication/9ce482b8#/9ce482b8/2")

    startListening: ->
      that = this
      recognition = that.get('recognition')
      recognition.stop()
      recognition.start()

`export default OaklandController`
