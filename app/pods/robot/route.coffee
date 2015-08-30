`import Ember from 'ember'`

RobotRoute = Ember.Route.extend
  actions:
    triggerSpark: -> @get('controller').callSparkFunction('relay')

`export default RobotRoute`
