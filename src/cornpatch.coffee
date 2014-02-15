# Description:
#   Return The Corn Patch special of the day
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cornpatch me
#
# Author:
#   Darrin Holst (darrinholst)
#

Entities = require('html-entities').AllHtmlEntities
FeedParser = require('feedparser')
request = require('request')

WEEKDAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

getTheSpecials = (callback) ->
  feedparser = new FeedParser()

  req = request(
    url: 'http://www.facebook.com/feeds/page.php?format=rss20&id=114613095287223'

    headers:
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36'
  )

  req.on('error', (error) ->
    callback("(poo) something bad happened with the request. #fufielding. #{error}")
  )

  req.on('response', (res) ->
    return callback("bad response code bro - #{res.statusCode}") unless res.statusCode == 200
    @pipe(feedparser)
  )

  feedparser.on('error', (error) ->
    callback("(wtf) feedparser error - #{error}")
  )

  feedparser.on('readable', ->
    while item = @read()
      for line in item.description.split(/<br *\/>/)
        callback(line.replace(/^\s+|\s+$/g, ""), WEEKDAYS[item.meta.date.getDay()]) if line.match(/lunch.*special/i)
  )

module.exports = (robot) ->
  robot.respond /cornpatch( me)?/i, (msg) ->
    gotItThanks = false

    getTheSpecials (theSpecial, theDate = "") ->
      msg.send "#{theDate}: #{new Entities().decode(theSpecial)}" unless gotItThanks
      gotItThanks = true

