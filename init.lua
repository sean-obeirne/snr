local M = {}
local main_window = vim.api.nvim_get_current_win()

local buffer_len = 60
local commands = " edit: (s)earch (r)eplace; (n)ext (p)rev; (e)xecute-replace "
local search_text = ""
local replace_text = ""
local show_replace = false
-- local inputting_search = true
-- local inputting_replace = false

-- Buffer IDs for different popups
local search_popup_buf
local search_helper_popup_buf
local replace_popup_buf
local replace_helper_popup_buf
local cmd_popup_buf

-- Window IDs for the popups
local search_popup_win
local search_helper_popup_win
local replace_popup_win
local replace_helper_popup_win
local cmd_popup_win



local function search_init()
    if not search_helper_popup_buf or not vim.api.nvim_buf_is_valid(search_helper_popup_buf) then
        search_helper_popup_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
        vim.api.nvim_buf_set_lines(search_helper_popup_buf, 0, -1, false, { "Search: " })
        vim.api.nvim_buf_set_option(search_helper_popup_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(search_helper_popup_buf, 'readonly', true)
    end

    if not search_popup_buf or not vim.api.nvim_buf_is_valid(search_popup_buf) then
        search_popup_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
        vim.api.nvim_buf_set_lines(search_popup_buf, 0, -1, false, { search_text })
        vim.api.nvim_buf_set_option(search_popup_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(search_popup_buf, 'readonly', true)
    end
end

local function replace_init()
    if not replace_helper_popup_buf or not vim.api.nvim_buf_is_valid(replace_helper_popup_buf) then
        replace_helper_popup_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
        vim.api.nvim_buf_set_lines(replace_helper_popup_buf, 0, -1, false, { "Replace:" })
        vim.api.nvim_buf_set_option(replace_helper_popup_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(replace_helper_popup_buf, 'readonly', true)
    end

    -- replace input popup
    if not replace_popup_buf or not vim.api.nvim_buf_is_valid(replace_popup_buf) then
        replace_popup_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
        vim.api.nvim_buf_set_lines(replace_popup_buf, 0, -1, false, { replace_text })
        vim.api.nvim_buf_set_option(replace_popup_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(replace_popup_buf, 'readonly', true)
    end

end


-- popups
local function search_popup()
    -- "Search:" popup

    -- Create or reuse the window
    if not search_helper_popup_win or not vim.api.nvim_win_is_valid(search_helper_popup_win) then
        local search_helper_popup_opts = {
            style = "minimal",
            relative = "editor",
            width = 8,
            height = 1,
            col = vim.o.columns - buffer_len - 12,
            row = 0,
            border = "rounded",
        }
        search_helper_popup_win = vim.api.nvim_open_win(search_helper_popup_buf, false, search_helper_popup_opts)
    end

    -- Search input popup
    -- Create or reuse the window
    if not search_popup_win or not vim.api.nvim_win_is_valid(search_popup_win) then
        local search_popup_opts = {
            style = "minimal",
            relative = "editor",
            width = buffer_len,
            height = 1,
            col = vim.o.columns,
            row = 0,
            border = "rounded",
        }
        search_popup_win = vim.api.nvim_open_win(search_popup_buf, true, search_popup_opts)
    end
end

local function replace_popup()
    -- "replace:" popup

    -- Create or reuse the window
    if not replace_helper_popup_win or not vim.api.nvim_win_is_valid(replace_helper_popup_win) then
        local replace_helper_popup_opts = {
            style = "minimal",
            relative = "editor",
            width = 8,
            height = 1,
            col = vim.o.columns - buffer_len - 12,
            row = 3,
            border = "rounded",
        }
        replace_helper_popup_win = vim.api.nvim_open_win(replace_helper_popup_buf, false, replace_helper_popup_opts)
    end


    -- Create or reuse the window
    if not replace_popup_win or not vim.api.nvim_win_is_valid(replace_popup_win) then
        local replace_popup_opts = {
            style = "minimal",
            relative = "editor",
            width = buffer_len,
            height = 1,
            col = vim.o.columns,
            row = 3,
            border = "rounded",
        }
        replace_popup_win = vim.api.nvim_open_win(replace_popup_buf, true, replace_popup_opts)
    end
end

local function cmd_popup()

    if not cmd_popup_buf or not vim.api.nvim_buf_is_valid(cmd_popup_buf) then
        cmd_popup_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
        vim.api.nvim_buf_set_lines(cmd_popup_buf, 0, -1, false, { commands })
        vim.api.nvim_buf_set_option(cmd_popup_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(cmd_popup_buf, 'readonly', true)
    end

    -- Create or reuse the window
    if not cmd_popup_win or not vim.api.nvim_win_is_valid(cmd_popup_win) then
        local cmd_popup_opts = {
            style = "minimal",
            relative = "editor",
            width = #commands,
            height = 1,
            col = vim.o.columns,
            row = 0,
            border = "double",
        }
        cmd_popup_win = vim.api.nvim_open_win(cmd_popup_buf, false, cmd_popup_opts)
    end
end

local function close_win(win)
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

local function close_buf(buf)
    if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
    end
end

function M.init()
end


local function edit_search()
    vim.api.nvim_set_current_win(search_popup_win)
    search_text = vim.fn.input("Search for string: ")
    vim.api.nvim_buf_set_option(search_popup_buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(search_popup_buf, 'readonly', false)
    vim.api.nvim_buf_set_lines(search_popup_buf, 0, -1, false, { search_text })
    vim.api.nvim_buf_set_option(search_popup_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(search_popup_buf, 'readonly', true)

    vim.fn.setreg('/', search_text)
end

local function edit_replace()
    if not show_replace then
        replace_popup()
        show_replace = true
    end
    -- vim.api.nvim_set_current_win(replace_popup_win)
    replace_text = vim.fn.input("Replace string with: ")
    vim.api.nvim_buf_set_option(replace_popup_buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(replace_popup_buf, 'readonly', false)
    vim.api.nvim_buf_set_lines(replace_popup_buf, 0, -1, false, { replace_text })
    vim.api.nvim_buf_set_option(replace_popup_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(replace_popup_buf, 'readonly', true)

    vim.fn.setreg('/', replace_text)
    -- inputting_search = false
    -- inputting_replace = true
end

local function next_inst()
end

local function prev_inst()
end

local function initial_search()
    vim.api.nvim_set_current_win(main_window)
    -- Escape the search string to treat as a literal by using very no magic (\V)
    local literal_string = '\\V' .. search_text:gsub('\\', '\\\\')

    -- Search for the literal string, starting from the cursor position
    -- The 'c' flag ensures the search wraps around the document
    local result = vim.fn.search(literal_string, 'c')

    -- Check if the search_text was found
    if result ~= 0 then
        print("Search text found at line " .. vim.fn.line('.'))
        -- Set the last search used in Vim so that 'n' can be used
        vim.fn.setreg('/', literal_string)
        vim.fn.setreg(':', '/' .. literal_string)
    else
        print("Search text not found")
    end
    vim.api.nvim_set_current_win(search_popup_win)
end

local function quit()
    close_win(search_helper_popup_win)
    close_buf(search_helper_popup_buf)
    close_win(search_popup_win)
    close_buf(search_popup_buf)

    close_win(replace_helper_popup_win)
    close_buf(replace_helper_popup_buf)
    close_win(replace_popup_win)
    close_buf(replace_popup_buf)

    close_win(cmd_popup_win)
    close_buf(cmd_popup_buf)

    show_replace = false
end

-- local function escape_literal(text)
    -- Escapes Lua magic characters (regex special characters in Lua patterns)
    -- return text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
-- end
local function escape_vim_regex(text)
    -- Escapes characters that are special in Vim regex
    local escaped_text = text:gsub("([\\%^$.[%]*+?-])", "\\%1")
    escaped_text = escaped_text:gsub("/", "\\/")
    return escaped_text
end

local function escape_vim_replacement(text)
    -- Escapes characters that are special in Vim replacement strings
    local escaped_text = text:gsub("([&\\~])", "\\%1")
    return escaped_text
end

local function execute()
    vim.api.nvim_set_current_win(main_window)
    local escaped_search_text = escape_vim_regex(search_text)
    local escaped_replace_text = escape_vim_replacement(replace_text)
    if show_replace then
        vim.cmd(string.format("%%s/%s/%s/gce", escaped_search_text, escaped_replace_text))
        -- print("running " .. string.format("%%s/%s/%s/ce", escaped_search_text, escaped_replace_text))
    else -- means we are just searching
        -- Perform the search operation and check if the search text is found
        local found = vim.fn.search(escaped_search_text, 'cW')
        if found == 0 then
            -- No matches found, provide feedback
            print("No matches found for:", escaped_search_text)
        else
            -- Matches found, jump to the first occurrence
            vim.cmd(string.format("/%s", escaped_search_text))
        end
    end
    vim.api.nvim_set_current_win(search_popup_win)
    quit()
end

local function help()
    cmd_popup()
end

local function create_keybinds(buf)
    local keymaps = {
        q = quit,
        s = edit_search,
        r = edit_replace,
        n = next_inst,
        p = prev_inst,
        i = initial_search,
        e = execute,
        h = help,
    }

    for key, action in pairs(keymaps) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
            noremap = true,
            silent = true,
            nowait = true,
            callback = action
        })
    end
end


function M.main()

    main_window = vim.api.nvim_get_current_win()

    search_init()
    replace_init()
    -- while true do
        search_popup()
        -- create_keybinds(search_popup_buf)
        -- search_text = vim.fn.input("Search for string: ")
        edit_search()
        -- reopen_search()
        create_keybinds(search_popup_buf)
        create_keybinds(search_helper_popup_buf)
        create_keybinds(replace_popup_buf)
        create_keybinds(replace_helper_popup_buf)
        -- replace_popup()
        -- create_keybinds(replace_popup_buf)
        -- replace_text = vim.fn.input("Replace string with: ")
        -- reopen_replace()
        -- create_keybinds(replace_popup_buf)
    -- end

end


vim.api.nvim_create_user_command('SnR', M.main, {})

return M
