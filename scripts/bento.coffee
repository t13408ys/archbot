module.exports = (robot) ->
  robot.brain.autoSave = true

  robot.respond /(.*(bento|:bento:|お?弁当).*)/i, (msg) ->
    user = robot.brain.userForId(msg.message.user.id)
    user.lastBento = msg.match[1]
    msg.send "good choice!"

  robot.hear /^bento\s+list$/i, (msg) ->
    users = robot.brain.users()
    msg.send ":bento: BENTO LIST :bento:"
    for i, user of users
      if user.lastBento
        msg.send "#{user.name} #{user.lastBento}"

  robot.hear /^bento\s+reset$/, (msg) ->
    users = robot.brain.users()
    msg.send "bento was reset."
    for i, user of users
      user.lastBento = null if user.lastBento
