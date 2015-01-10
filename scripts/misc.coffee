module.exports = (robot) ->
  MEETING_CONTENTS_URL = "https://api.github.com/repos/sfc-arch/meeting/contents"
  robot.hear /^議事録$/i, (msg) ->
    robot.http(MEETING_LOG).get() (err, res, body) ->
      contents = JSON.parse body
      log = contents[contents.length - 2]
      msg.send log.html_url
