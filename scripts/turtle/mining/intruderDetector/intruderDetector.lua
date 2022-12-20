local detector = peripheral.find("playerDetector")
if detector == nil then error("Player Detector not found!") end
local webhook = arg[1]
local detectionRange = tonumber(arg[2])
local detectionRate = tonumber(arg[3])
local ignoredPlayers = {}
local ignoredPlayersStartIndex = 4
if #arg > ignoredPlayersStartIndex - 1 then
    for i = ignoredPlayersStartIndex, #arg do
        ignoredPlayers[arg[i]] = true
    end
end

function getIntruders(range)
    local players = detector.getPlayersInRange(range)
    local intruders = {}
    for _, player in pairs(players) do
        if not ignoredPlayers[player] then
            intruderPos = detector.getPlayerPos(player)
            intruders[player] = intruderPos
        end
    end
    return intruders
end

function intruderMessage(intruders)
    local message = "Intruders detected:\n"
    for intruder, pos in pairs(intruders) do
        message = message .. "    " .. intruder .. " is at (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")\n"
    end
    return message
end

function sendWebhook(message)
    local request = textutils.serializeJSON({ content = message })
    local headers = { ["Content-Type"] = "application/json" }
    local response = http.post(webhook, request, headers)
    if response == nil then
        print("Failed to send webhook")
    end
end

while true do
    local intruders = getIntruders(detectionRange)
    if next(intruders) ~= nil then
        local message = intruderMessage(intruders)
        sendWebhook(message)
    end
    os.sleep(detectionRate)
end
