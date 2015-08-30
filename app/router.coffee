`import Ember from 'ember';`
`import config from './config/environment';`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @resource 'dash', path: '/'
  @route 'dash', path: '/dash'
  @route 'hello', path: '/hello'
  @route 'macros', path: '/macros'
  @route 'oakland', path: '/oakland'
  @route 'robot', path: '/robot'

`export default Router`
