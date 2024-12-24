-- Import Hammerspoon HTTP library
local http = require("hs.http")

-- Function to call the LLM API
function queryLLM(prompt)
    local url = "http://127.0.0.1:1337/v1/chat/completions"
    local headers = { ["accept"] = "application/json", ["Content-Type"] = "application/json" }
    local body = { 
        messages = {
            { 
            content = prompt,
            role = "user"
            }
        },
        model = "qwen2.5-7b-instruct",
        stream = false,
        max_tokens = 2048,
        stop = {
            "hello"
        },
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0.7,
        top_p = 0.95
    }

    local data = hs.json.encode(body)

    -- Send HTTP POST request
    local status, response = http.post(url, data, headers)

    if status == 200 then
        local parsedResponse = hs.json.decode(response)
        return parsedResponse.choices[1].message.content -- Adjusted for OpenAI-compatible API response
    else
        return "Error: Unable to connect to the LLM. Status code: " .. status
    end
end


-- Function to show a dialog and send input to the LLM
function promptUserAndQueryLLM()
    -- Show input dialog
    local button, text = hs.dialog.textPrompt(
        "Query LLM",
        "Enter your prompt for the LLM:",
        "", -- Default text
        "Submit",
        "Cancel"
    )

    -- Check if the user clicked "Submit" and provided input
    if button == "Submit" and text ~= "" then
        -- Query the LLM with the input
        local llmResponse = queryLLM(text)

        -- Display the response in another dialog
        -- hs.dialog.alert("LLM Response", llmResponse, "OK", llmResponse)
        hs.dialog.alert(nil, nil, function() end, llmResponse)
        local dialogWidth = 400

    else
        -- Notify if the user canceled or left the input empty
        hs.notify.new({ title = "LLM Query Canceled", informativeText = "No prompt was sent." }):send()
    end
end

-- Bind the function to a hotkey (Cmd + Alt + Ctrl + G)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "G", promptUserAndQueryLLM)
