module.exports = (robot) ->
  messages = [null, null]
  robot.brain.autoSave = true

  robot.hear //, (msg) ->
    if match = msg.message.text.match(/^([a-z0-9]+)?\s*(\+{2,}|-{2,})\s*([a-z0-9]+)?$/)

      user =
        if match[1]
          robot.brain.userForName match[1]
        else if match[3]
          robot.brain.userForName match[3]
        else if messages[1]
          robot.brain.userForId messages[1].user.id

      amount =
        if match[2].indexOf("+") == 0
          parseInt(match[2].length/2)
        else if match[2].indexOf("-") == 0
          -parseInt(match[2].length/2)

      if user
        user.score = 0 unless user.score
        user.score = user.score + amount
        msg.send "#{user.name} #{user.score}pt"
      else
        msg.send "unknown user"

    else
      messages.shift()
      messages.push msg.message
