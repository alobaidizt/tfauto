`import Ember from 'ember'`

MacrosRoute = Ember.Route.extend
  setupController: (controller, model) ->
    console.log 'derp'
    Em.run.scheduleOnce('afterRender', this, () -> $(".button-collapse").sideNav())

`export default MacrosRoute`
