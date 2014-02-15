{Robot, TextMessage} = require('hubot')
fs                   = require('fs')
nock                 = require('nock')
path                 = require('path')

describe('The sweetest hubot script of all time', ->
  robot = null
  user = null
  adapter = null

  beforeEach ->
    ready = false

    runs ->
      robot = new Robot(null, 'mock-adapter', false)

      robot.adapter.on('connected', ->
        require('../src/cornpatch')(robot)
        user = robot.brain.userForId('1', {name: 'jasmine', room: '#jasmine'})
        adapter = robot.adapter
        ready = true
      )

      robot.run()

    waitsFor ->
      ready

  afterEach ->
    robot.shutdown()

  it('gets the feed from the facebooks', (done) ->
    nock('http://www.facebook.com')
      .get('/feeds/page.php?format=rss20&id=114613095287223')
      .reply(200, (uri, requestBody) ->
         fs.createReadStream(path.resolve(path.join('spec/fixtures/feed.xml')))
      )

    adapter.on('send', (envelope, strings) ->
      expect(strings).toEqual(["Saturday: Today's lunch special is fried chicken, 11-4."])
      done()
    )

    adapter.receive(new TextMessage(user, 'hubot cornpatch me'))
  )
)

