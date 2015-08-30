`import Ember from 'ember'`

OaklandRoute = Ember.Route.extend
  actions:
    triggerSpark: -> @get('controller').callSparkFunction('relay')

`export default OaklandRoute`
