do

  local function getUserIds(chat_id, msg_id, user)
    local fname = util.escapeHtml(user.first_name_)
    local name = _msg("<b>%s</b>\nFirst name: %s"):format(fname, fname)

    if user.last_name_ then
      local lname = util.escapeHtml(user.last_name_)
      name = _msg("<b>%s %s</b>\nFirst name: %s\nLast name: %s"):format(fname, lname, fname, lname)
    end

    local text =  name .. '\nID: <code>' .. user.id_ .. '</code>'

    if user.username_ then
      text = _msg('%s\nUsername: @%s\nLink: https://t.me/%s'):format(text, user.username_, user.username_)
    end

    sendText(chat_id, msg_id, text, 0)
  end

  local function getUser_cb(arg, data)
    getUserIds(arg.chat_id, arg.msg_id, data)
  end

--------------------------------------------------------------------------------

  local function run(msg, matches)
    local chat_id, user_id, _, _ = util.extractIds(msg)
    local input = msg.content_.text_
    local extra = {chat_id = chat_id, msg_id = msg.id_}

    if util.isMod(user_id, chat_id) then
      if util.isReply(msg) and matches[1] == 'id' then
        td.getMessage(chat_id, msg.reply_to_message_id_, function(a, d)
          td.getUser(d.sender_user_id_, getUser_cb, {
              chat_id = a.chat_id,
              msg_id = d.id_
          })
        end, {chat_id = chat_id})
      elseif matches[1] == '@' then
        td.searchPublicChat(matches[2], function(a, d)
          local exist, err = util.checkUsername(d)
          local username = a.username
          local chat_id = a.chat_id
          local msg_id = a.msg_id

          if not exist then
            return sendText(chat_id, msg_id, _msg(err):format(username))
          end
          getUserIds(chat_id, msg_id, d.type_.user_)
        end, extra)
      elseif matches[1]:match('%d+$') then
        td.getUser(matches[1], getUser_cb, extra)
      end
    end

    if msg.reply_to_message_id_ == 0 and matches[1] == 'id' then
      td.getUser(user_id, getUser_cb, extra)
    end
  end

--------------------------------------------------------------------------------

  return {
    description = _msg('Sends the name, ID, and (if applicable) username for the given user, group, channel or bot.'),
    usage = {
      --moderator = {
        --'<code>!id</code>',
        --_msg('Returns the IDs of the replied users.'),
        --'',
        --'<code>!id [user_id]</code>',
        --_msg('Return the IDs for the given user_id.'),
        --'',
        --'<code>!id @[username]</code>',
        --_msg('Return the IDs for the given username.'),
        --'',
      --},
      user = {
        'See: https://t.me/tdclibotmanual/63'
        --'<code>!id</code>',
        --_msg('Returns your IDs.'),
        --'',
      },
    },
    patterns = {
      _config.cmd .. '(id)$',
      _config.cmd .. 'id (@)(.+)$',
      _config.cmd .. 'id (%d+)$',
    },
    run = run
  }

end
