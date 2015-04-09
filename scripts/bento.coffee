github = new (require 'github')
  version: '3.0.0'
github.authenticate type: 'token', token: process.env['GITHUB_API_TOKEN']

module.exports = (robot) ->
  robot.brain.autoSave = true

  robot.hear /^bento\s+create\s+(.*?)\s+(.+)$/, (msg) ->
    date = msg.match[1]
    shop = msg.match[2]

    body =
      switch shop
        when 'デリカ', '木の子', 'デリカ木の子'
          'デリカ木の子 http://web.sfc.wide.ad.jp/~miyukki/rg/kinoko.pdf'
        when '大戸屋'
          '大戸屋 https://www.ootoya.com/menu.asp?bcid=1&tcid=8'
        else
          shop

    github.issues.create
      user: 'sfc-arch'
      repo: 'reading'
      title: "#{date} 輪講会お弁当調査"
      body: ":bento: 今週のお店 #{body}"
      labels: ['question']
    , (err, result) ->
      msg.send "@channel :bento: #{date} 輪講会お弁当調査 #{result.html_url}"

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
