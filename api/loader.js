export default function handler(req, res) {
  const loaderScript = `
    -- Zvio Hub Universal Loader
    if getgenv().ScriptExecuted then
        warn("Script already running! Re-execution blocked.")
        return
    end
    getgenv().ScriptExecuted = true

    -- Execution Tracking
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if request then
        pcall(function()
            request({
                Url = "https://executiontracker.gegidzezviad05.workers.dev/api/count",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" }
            })
        end)
    end

    -- Game Detection
    local gameScripts = {
        [16732694052] = "https://yoursite.vercel.app/api/fisch",      -- Fisch Main
        [131716211654599] = "https://yoursite.vercel.app/api/fisch",  -- New Fisch
        [76558904092080] = "https://yoursite.vercel.app/api/forge",   -- The Forge Main
        [129009554587176] = "https://yoursite.vercel.app/api/forge"   -- The Forge World 2
    }

    local currentGameId = game.PlaceId
    local scriptUrl = gameScripts[currentGameId]

    if scriptUrl then
        print("✅ Loading script for Game ID:", currentGameId)
        loadstring(game:HttpGet(scriptUrl))()
    else
        warn("❌ Unsupported Game ID:", currentGameId)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Zvio Hub";
            Text = "Game not supported! ID: " .. currentGameId;
            Duration = 5;
        })
    end
  `;

  res.setHeader('Content-Type', 'text/plain');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).send(loaderScript);
}
