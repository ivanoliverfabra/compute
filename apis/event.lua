local Event = {}

function Event.listen(eventName, callback)
  while true do
    local event = {os.pullEvent(eventName)}
    callback(table.unpack(event))
  end
end

function Event.schedule(callback, delay)
  local startTime = os.epoch("utc")
  while os.epoch("utc") - startTime < delay do
    coroutine.yield()
  end
  callback()
end

return Event
