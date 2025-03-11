local Thread = {}
Thread.__index = Thread

function Thread.new(func)
  local self = setmetatable({}, Thread)
  self.coroutine = coroutine.create(func)
  self.running = false
  self.paused = false
  return self
end

function Thread:start()
  if not self.running and coroutine.status(self.coroutine) ~= "dead" then
    self.running = true
    self.paused = false
  end
end

function Thread:stop()
  self.running = false
  self.paused = false
  self.coroutine = nil
end

function Thread:pause()
  if self.running then self.paused = true end
end

function Thread:resume()
  if self.paused then self.paused = false end
end

function Thread:isRunning()
  return self.running
end

function Thread:isPaused()
  return self.paused
end

function Thread:execute()
  if self.running and coroutine.status(self.coroutine) ~= "dead" then
    local success, err = coroutine.resume(self.coroutine)
    if not success then error("Thread error: " .. err) end
  elseif coroutine.status(self.coroutine) == "dead" then
    self.running = false
  end
end

return Thread
