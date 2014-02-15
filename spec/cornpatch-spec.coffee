path = require('path')
{Robot, TextMessage} = require('hubot')

describe("The sweetest hubot script of all time", ->
  robot = null
  user = null
  adapter = null

  beforeEach ->
    ready = false

    runs ->
      robot = new Robot(null, 'mock-adapter', false)

      robot.adapter.on("connected", ->
        process.env.HUBOT_AUTH_ADMIN = "1"
        robot.loadFile(path.resolve(path.join("node_modules/hubot/src/scripts")), "auth.coffee")
        require("../src/cornpatch")(robot)
        user = robot.brain.userForId("1", {name: "jasmine", room: "#jasmine"})
        adapter = robot.adapter
        ready = true
      )

      robot.run()

    waitsFor ->
      ready

  afterEach ->
    robot.shutdown()

  it('does something', (done) ->
    adapter.on('send', (envelope, strings) ->
      expect(strings.length).toBe(1)
      done()
    )

    textMessage = new TextMessage(user, "hubot cornpatch me")
    adapter.receive(textMessage)
  )
)
