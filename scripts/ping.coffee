module.exports = (robot) ->
  robot.hear /^ping$/, (msg) ->
    msg.send "pong"
