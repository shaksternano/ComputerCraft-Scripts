local DETECTOR = peripheral.find("playerDetector")
local AR_CONTROLLER = peripheral.find("arController")
if DETECTOR == nil then error("Player Detector not found!") end
local WEBHOOK_URL = arg[1]
local DETECTION_RANGE = tonumber(arg[2])
local DETECTION_RATE = tonumber(arg[3])
local INGORED_PLAYERS = {}
local IGNORED_PLAYERS_START_INDEX = 4
if #arg > IGNORED_PLAYERS_START_INDEX - 1 then
    for i = IGNORED_PLAYERS_START_INDEX, #arg do
        INGORED_PLAYERS[arg[i]] = true
    end
end
local INTRUDER_MESSAGE_HEADER = "Intruders detected:"

function getIntruders(range --[[number]]) --> table
    local players = DETECTOR.getPlayersInRange(range)
    local intruders = {}
    for _, player in pairs(players) do
        if not INGORED_PLAYERS[player] then
            intruderPos = DETECTOR.getPlayerPos(player)
            intruders[player] = intruderPos
        end
    end
    return intruders
end

function getIntruderDetails(intruder --[[string]], pos --[[table]]) --> string
    return intruder .. " is at (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")"
end

function drawArMessage(intruders --[[table]]) --> nothing
    if AR_CONTROLLER ~= nil then
        local x = 10
        local y = 60
        AR_CONTROLLER.drawString(INTRUDER_MESSAGE_HEADER, x, y, 0xFFFFFF)
        x = x + 20
        for intruder, pos in pairs(intruders) do
            y = y + 10
            local intruderDetails = getIntruderDetails(intruder, pos)
            AR_CONTROLLER.drawString(intruderDetails, x, y, 0xFFFFFF)
        end
    end
end

function createWebhookMessage(intruders --[[table]]) --> string
    local message = INTRUDER_MESSAGE_HEADER .. "\n"
    for intruder, pos in pairs(intruders) do
        message = message .. "    " .. getIntruderDetails(intruder, pos) .. "\n"
    end
    return message
end

function sendWebhook(message --[[string]]) --> nothing 
    local request = textutils.serializeJSON({ content = message })
    local headers = { ["Content-Type"] = "application/json" }
    http.post(WEBHOOK_URL, request, headers)
end

while true do
    if AR_CONTROLLER ~= nil then
        AR_CONTROLLER.clear()
    end
    local intruders = getIntruders(DETECTION_RANGE)
    if next(intruders) ~= nil then
        drawArMessage(intruders)
        local message = createWebhookMessage(intruders)
        sendWebhook(message)
    end
    os.sleep(DETECTION_RATE)
end
