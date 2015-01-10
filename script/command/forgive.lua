--[[

  A player command to forgive a teamkill
  By piernov <piernov@piernov.org>

]]

local teamkills = {}

server.event_handler("teamkill", function(actor, target)
  server.player_msg(target, string.format(server.forgive_propose_message, server.player_displayname(actor)))
  actor_id = server.player_id(actor)
  target_id = server.player_id(target)
  if not teamkills[actor_id] then
    teamkills[actor_id] = { teamkilled_by = {}, teamkilled = {target_id}, cn = actor }
  else
    table.insert(teamkills[actor_id]["teamkilled"], target_id)
  end
  if not teamkills[target_id] then 
    teamkills[target_id] = { teamkilled_by = {actor_id}, teamkilled = {}, cn = target } 
  else
    table.insert(teamkills[target_id]["teamkilled_by"], actor_id)
  end
end)

server.event_handler("connect", function(cn)
  cn_id = server.player_id(cn)
  if not teamkills[cn_id] then return end
  teamkills[cn_id]["cn"] = cn
end)

server.event_handler("intermission", function()
  teamkills = {}
end)

server.event_handler("text", function(cn, text)
  if (string.match(text, "np") or string.match(text, "no problem") or string.match(text, "NO PROBLEM") or string.match(text, "NP")) then 
  server.player_msg(cn, string.format(server.forgive_analysetext_message))
  end
end)

return function(cn)
  cn_id = server.player_id(cn)
  if not teamkills[cn_id] then return false, server.forgive_not_teamkilled_message end

  actor_id = teamkills[cn_id]["teamkilled_by"][table_size(teamkills[cn_id]["teamkilled_by"])] or nil
  if not actor_id then return false, server.forgive_not_teamkilled_message end

  actor_cn = teamkills[actor_id]["cn"]
  for _,actor_teamkilled in pairs(teamkills[actor_id]["teamkilled"]) do
    if cn_id == actor_teamkilled then
      server.player_forgive_tk(actor_cn)

      teamkills[cn_id]["teamkilled_by"][table_size(teamkills[cn_id]["teamkilled_by"])] = nil
      teamkills[actor_id]["teamkilled"][table_size(teamkills[actor_id]["teamkilled"])] = nil

      server.player_msg(actor_cn, string.format(server.forgive_actor_forgiven_message, server.player_displayname(cn)))
      server.player_msg(cn, string.format(server.forgive_target_forgiven_message, server.player_displayname(actor_cn)))
      return
    end
  end

  return false, server.forgive_not_teamkilled_message
end
