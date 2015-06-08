cron = (require 'cron').CronJob

module.exports = (robot) ->
  last_users = []
  robot.brain.autoSave = true

  robot.hear //, (msg) ->
    if match = msg.message.text.match(/^([a-z0-9]+)?\s*(\+{2,}|-{2,})\s*([a-z0-9]+)?$/)

      user =
        if match[1]
          robot.brain.userForName match[1]
        else if match[3]
          robot.brain.userForName match[3]
        else if last_users[0]
          robot.brain.userForId last_users[0]

      amount =
        if match[2].indexOf("+") == 0
          parseInt(match[2].length/2)

      if user
        user.score = 0 unless user.score
        user.score = user.score + amount
        msg.send "#{user.name} #{user.score}pt"
      else
        msg.send 'unknown user'

    else
      last_users.pop()
      last_users.unshift msg.message.user.id

  robot.hear /^score report$/, (msg) ->
    reportScore()

  reportScore = ->
    users = robot.brain.users()
    users = (user for id, user of users)
    active_users = users.reduce (result, user) ->
      result.push user if user.score? && user.score > 0
      result
    , []
    active_users.sort (a, b) ->
      b.score - a.score

    if active_users.length > 0
      result_message = ("#{user.name} #{user.score}pt" for user in active_users).join("\n")
      robot.send room: 'arch', result_message
      robot.send room: 'arch', ":tada: CONGRATULATIONS *#{active_users[0]?.name}* :tada:"

  resetScore = ->
    for id, user of robot.brain.users()
      user = robot.brain.userForId id
      user.score = 0 if user.score?

  new cron '0 30 18 * * 4', ->
    reportScore()
    resetScore()
  , null, true, 'Asia/Tokyo'
