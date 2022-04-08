local api = vim.api
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local _local_1_ = math
local abs = _local_1_["abs"]
local ceil = _local_1_["ceil"]
local max = _local_1_["max"]
local min = _local_1_["min"]
local pow = _local_1_["pow"]
local function clamp(val, min0, max0)
  if (val < min0) then
    return min0
  elseif (val > max0) then
    return max0
  elseif "else" then
    return val
  end
end
local function inc(x)
  return (x + 1)
end
local function dec(x)
  return (x - 1)
end
local function echo(msg)
  vim.cmd("redraw")
  return api.nvim_echo({{msg}}, false, {})
end
local function replace_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end
local _3cctrl_v_3e = replace_keycodes("<c-v>")
local _3cesc_3e = replace_keycodes("<esc>")
local function get_motion_force(mode)
  local _3_
  if mode:match("o") then
    _3_ = mode:sub(-1)
  else
  _3_ = nil
  end
  if (nil ~= _3_) then
    local last_ch = _3_
    if ((last_ch == _3cctrl_v_3e) or (last_ch == "V") or (last_ch == "v")) then
      return last_ch
    end
  end
end
local function get_cursor_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
end
local function char_at_pos(_7_, _9_)
  local _arg_8_ = _7_
  local line = _arg_8_[1]
  local byte_col = _arg_8_[2]
  local _arg_10_ = _9_
  local char_offset = _arg_10_["char-offset"]
  local line_str = vim.fn.getline(line)
  local char_idx = vim.fn.charidx(line_str, dec(byte_col))
  local char_nr = vim.fn.strgetchar(line_str, (char_idx + (char_offset or 0)))
  if (char_nr ~= -1) then
    return vim.fn.nr2char(char_nr)
  end
end
local function get_fold_edge(lnum, reverse_3f)
  local _12_
  local _13_
  if reverse_3f then
    _13_ = vim.fn.foldclosed
  else
    _13_ = vim.fn.foldclosedend
  end
  _12_ = _13_(lnum)
  if (_12_ == -1) then
    return nil
  elseif (nil ~= _12_) then
    local fold_edge = _12_
    return fold_edge
  end
end
local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local labels = {"s", "f", "n", "j", "k", "l", "o", "d", "w", "e", "h", "m", "v", "g", "u", "t", "c", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local opts = {case_insensitive = true, labels = labels, safe_labels = safe_labels, special_keys = {eol = "<space>", next_group = "<space>", next_match = "<enter>", prev_group = "<tab>", prev_match = "<tab>", repeat_search = "<enter>"}}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local function user_forced_autojump_3f()
  return (not opts.labels or empty_3f(opts.labels))
end
local function user_forced_no_autojump_3f()
  return (not opts.safe_labels or empty_3f(opts.safe_labels))
end
local hl
local function _16_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {cleanup = _16_, group = {["label-primary"] = "LeapLabelPrimary", ["label-secondary"] = "LeapLabelSecondary", backdrop = "LeapBackdrop", match = "LeapMatch"}, ns = api.nvim_create_namespace(""), priority = {backdrop = 65533, cursor = 65534, label = 65535}}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local _19_
  do
    local _18_ = bg
    if (_18_ == "light") then
      _19_ = "#222222"
    else
      local _ = _18_
      _19_ = "#ccff88"
    end
  end
  local _24_
  do
    local _23_ = bg
    if (_23_ == "light") then
      _24_ = "#ff8877"
    else
      local _ = _23_
      _24_ = "#ccff88"
    end
  end
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "#77aaff"
    else
      local _ = _28_
      _29_ = "#99ccff"
    end
  end
  for name, def_map in pairs({[hl.group.backdrop] = {cterm = "none", gui = "none"}, [hl.group.match] = {cterm = "underline,nocombine", ctermbg = "none", ctermfg = "red", gui = "underline,nocombine", guibg = "none", guifg = _19_}, [hl.group["label-primary"]] = {cterm = "none", ctermbg = "red", ctermfg = "black", gui = "none", guibg = _24_, guifg = "black"}, [hl.group["label-secondary"]] = {cterm = "none", ctermbg = "blue", ctermfg = "black", gui = "none", guibg = _29_, guifg = "black"}}) do
    local attr_str
    local _33_
    do
      local tbl_12_auto = {}
      for k, v in pairs(def_map) do
        tbl_12_auto[(#tbl_12_auto + 1)] = (k .. "=" .. v)
      end
      _33_ = tbl_12_auto
    end
    attr_str = table.concat(_33_, " ")
    local _34_
    if force_3f then
      _34_ = ""
    else
      _34_ = "default "
    end
    vim.cmd(("highlight " .. _34_ .. name .. " " .. attr_str))
  end
  return nil
end
local function apply_backdrop(reverse_3f, _3ftarget_windows)
  if _3ftarget_windows then
    for _, win in ipairs(_3ftarget_windows) do
      vim.highlight.range(win.bufnr, hl.ns, hl.group.backdrop, {dec(win.topline), 0}, {dec(win.botline), -1}, {priority = hl.priority.backdrop})
    end
    return nil
  else
    local _let_36_ = map(dec, get_cursor_pos())
    local curline = _let_36_[1]
    local curcol = _let_36_[2]
    local _let_37_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_37_[1]
    local win_bot = _let_37_[2]
    local function _39_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_38_ = _39_()
    local start = _let_38_[1]
    local finish = _let_38_[2]
    return vim.highlight.range(0, hl.ns, hl.group.backdrop, start, finish, {priority = hl.priority.backdrop})
  end
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local function _42_()
    local _41_ = direction
    if (_41_ == "fwd") then
      return "W"
    elseif (_41_ == "bwd") then
      return "bW"
    end
  end
  return vim.fn.search("\\_.", _42_())
end
local function force_matchparen_refresh()
  pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchparen"})
  return pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchup_matchparen"})
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function add_restore_virtualedit_autocmd(saved_val)
  local function _44_()
    vim.o.virtualedit = saved_val
    return nil
  end
  return api.nvim_create_autocmd({"CursorMoved", "WinLeave", "BufLeave", "InsertEnter", "CmdlineEnter", "CmdwinEnter"}, {callback = _44_, once = true})
end
local function jump_to_21_2a(target, _45_)
  local _arg_46_ = _45_
  local add_to_jumplist_3f = _arg_46_["add-to-jumplist?"]
  local adjust = _arg_46_["adjust"]
  local inclusive_motion_3f = _arg_46_["inclusive-motion?"]
  local mode = _arg_46_["mode"]
  local reverse_3f = _arg_46_["reverse?"]
  local op_mode_3f = string.match(mode, "o")
  local motion_force = get_motion_force(mode)
  local virtualedit_saved = vim.o.virtualedit
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  end
  vim.fn.cursor(target)
  adjust()
  if not op_mode_3f then
    force_matchparen_refresh()
  end
  if (op_mode_3f and not reverse_3f and inclusive_motion_3f) then
    local _49_ = motion_force
    if (_49_ == nil) then
      if not cursor_before_eof_3f() then
        return push_cursor_21("fwd")
      else
        vim.o.virtualedit = "onemore"
        vim.cmd("norm! l")
        return add_restore_virtualedit_autocmd(virtualedit_saved)
      end
    elseif (_49_ == "V") then
      return nil
    elseif (_49_ == _3cctrl_v_3e) then
      return nil
    elseif (_49_ == "v") then
      return push_cursor_21("bwd")
    end
  end
end
local function highlight_cursor(_3fpos)
  local _let_53_ = (_3fpos or get_cursor_pos())
  local line = _let_53_[1]
  local col = _let_53_[2]
  local pos = _let_53_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {hl_mode = "combine", priority = hl.priority.cursor, virt_text = {{ch_at_curpos, "Cursor"}}, virt_text_pos = "overlay"})
end
local function handle_interrupted_change_op_21()
  echo("")
  local curcol = vim.fn.col(".")
  local endcol = vim.fn.col("$")
  local _3fright
  if (not vim.o.insertmode and (curcol > 1) and (curcol < endcol)) then
    _3fright = "<RIGHT>"
  else
    _3fright = ""
  end
  return api.nvim_feedkeys(replace_keycodes(("<C-\\><C-G>" .. _3fright)), "n", true)
end
local function exec_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {modeline = false, pattern = pattern})
end
local function get_input()
  local _55_, _56_ = pcall(vim.fn.getcharstr)
  local function _57_()
    local ch = _56_
    return (ch ~= _3cesc_3e)
  end
  if (((_55_ == true) and (nil ~= _56_)) and _57_()) then
    local ch = _56_
    return ch
  end
end
local function set_dot_repeat(cmd, _3fcount)
  local op = vim.v.operator
  local change
  if (op == "c") then
    change = replace_keycodes("<c-r>.<esc>")
  else
  change = nil
  end
  local seq = (op .. (_3fcount or "") .. cmd .. (change or ""))
  pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
  return pcall(vim.fn["repeat#set"], seq, -1)
end
local function get_plug_key(reverse_3f, x_mode_3f, dot_repeat_3f)
  local _60_
  if dot_repeat_3f then
    _60_ = "dotrepeat-"
  else
    _60_ = ""
  end
  local _63_
  do
    local _62_ = {not not reverse_3f, not not x_mode_3f}
    if ((type(_62_) == "table") and ((_62_)[1] == false) and ((_62_)[2] == false)) then
      _63_ = "forward)"
    elseif ((type(_62_) == "table") and ((_62_)[1] == true) and ((_62_)[2] == false)) then
      _63_ = "backward)"
    elseif ((type(_62_) == "table") and ((_62_)[1] == false) and ((_62_)[2] == true)) then
      _63_ = "forward-x)"
    elseif ((type(_62_) == "table") and ((_62_)[1] == true) and ((_62_)[2] == true)) then
      _63_ = "backward-x)"
    else
    _63_ = nil
    end
  end
  return ("<Plug>(leap-" .. _60_ .. _63_)
end
local function get_targetable_windows()
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local get_wininfo
  local function _69_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  get_wininfo = _69_
  local get_buf = api.nvim_win_get_buf
  local curr_winid = vim.fn.win_getid()
  local ids = string.gmatch(vim.fn.string(vim.fn.winlayout()), "%d+")
  local ids0
  do
    local tbl_12_auto = {}
    for id in ids do
      local _70_
      if not ((tonumber(id) == curr_winid) or (visual_or_OP_mode_3f and (get_buf(tonumber(id)) ~= get_buf(curr_winid)))) then
        _70_ = id
      else
      _70_ = nil
      end
      tbl_12_auto[(#tbl_12_auto + 1)] = _70_
    end
    ids0 = tbl_12_auto
  end
  return map(get_wininfo, ids0)
end
local function get_horizontal_bounds()
  local match_length = 2
  local textoff = vim.fn.getwininfo(vim.fn.win_getid())[1].textoff
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_length))
  return {left_bound, right_bound}
end
local function get_match_positions(pattern, _72_)
  local _arg_73_ = _72_
  local _arg_74_ = _arg_73_["bounds"]
  local left_bound = _arg_74_[1]
  local right_bound = _arg_74_[2]
  local reverse_3f = _arg_73_["reverse?"]
  local source_winid = _arg_73_["source-winid"]
  local whole_window_3f = _arg_73_["whole-window?"]
  local reverse_3f0
  if whole_window_3f then
    reverse_3f0 = false
  else
    reverse_3f0 = reverse_3f
  end
  local curr_winid = vim.fn.win_getid()
  local view = vim.fn.winsaveview()
  local cpo = vim.o.cpo
  local opts0
  if reverse_3f0 then
    opts0 = "b"
  else
    opts0 = ""
  end
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local stopline
  if reverse_3f0 then
    stopline = wintop
  else
    stopline = winbot
  end
  local cleanup
  local function _78_()
    vim.fn.winrestview(view)
    vim.o.cpo = cpo
    return nil
  end
  cleanup = _78_
  local function reach_right_bound()
    while ((vim.fn.virtcol(".") < right_bound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
      vim.cmd("norm! l")
    end
    return nil
  end
  local function skip_to_fold_edge_21()
    local _79_
    local _80_
    if reverse_3f0 then
      _80_ = vim.fn.foldclosed
    else
      _80_ = vim.fn.foldclosedend
    end
    _79_ = _80_(vim.fn.line("."))
    if (_79_ == -1) then
      return "not-in-fold"
    elseif (nil ~= _79_) then
      local fold_edge = _79_
      vim.fn.cursor(fold_edge, 0)
      local function _82_()
        if reverse_3f0 then
          return 1
        else
          return vim.fn.col("$")
        end
      end
      vim.fn.cursor(0, _82_())
      return "moved-the-cursor"
    end
  end
  local function skip_to_next_in_window_pos_21()
    local _local_84_ = {vim.fn.line("."), vim.fn.virtcol(".")}
    local line = _local_84_[1]
    local virtcol = _local_84_[2]
    local from_pos = _local_84_
    local _85_
    if (virtcol < left_bound) then
      if reverse_3f0 then
        if (dec(line) >= stopline) then
          _85_ = {dec(line), right_bound}
        else
        _85_ = nil
        end
      else
        _85_ = {line, left_bound}
      end
    elseif (virtcol > right_bound) then
      if reverse_3f0 then
        _85_ = {line, right_bound}
      else
        if (inc(line) <= stopline) then
          _85_ = {inc(line), left_bound}
        else
        _85_ = nil
        end
      end
    else
    _85_ = nil
    end
    if (nil ~= _85_) then
      local to_pos = _85_
      if (from_pos ~= to_pos) then
        vim.fn.cursor(to_pos)
        if reverse_3f0 then
          reach_right_bound()
        end
        return "moved-the-cursor"
      end
    end
  end
  vim.o.cpo = cpo:gsub("c", "")
  local win_enter_3f = nil
  local match_count = 0
  local orig_curpos = get_cursor_pos()
  if whole_window_3f then
    win_enter_3f = true
    vim.fn.cursor({wintop, left_bound})
  end
  local function recur(match_at_curpos_3f)
    local match_at_curpos_3f0
    local function _95_()
      if win_enter_3f then
        win_enter_3f = false
        return true
      end
    end
    match_at_curpos_3f0 = (match_at_curpos_3f or _95_())
    local _96_
    local _97_
    if match_at_curpos_3f0 then
      _97_ = "c"
    else
      _97_ = ""
    end
    _96_ = vim.fn.searchpos(pattern, (opts0 .. _97_), stopline)
    if ((type(_96_) == "table") and ((_96_)[1] == 0) and true) then
      local _ = (_96_)[2]
      return cleanup()
    elseif ((type(_96_) == "table") and (nil ~= (_96_)[1]) and (nil ~= (_96_)[2])) then
      local line = (_96_)[1]
      local col = (_96_)[2]
      local pos = _96_
      local _99_ = skip_to_fold_edge_21()
      if (_99_ == "moved-the-cursor") then
        return recur(false)
      elseif (_99_ == "not-in-fold") then
        if ((curr_winid == source_winid) and (view.lnum == line) and (inc(view.col) == col)) then
          push_cursor_21("fwd")
          return recur(true)
        elseif ((function(_100_,_101_,_102_) return (_100_ <= _101_) and (_101_ <= _102_) end)(left_bound,col,right_bound) or vim.wo.wrap) then
          match_count = (match_count + 1)
          return pos
        else
          local _103_ = skip_to_next_in_window_pos_21()
          if (_103_ == "moved-the-cursor") then
            return recur(true)
          else
            local _ = _103_
            return cleanup()
          end
        end
      end
    end
  end
  return recur
end
local function get_targets_2a(input, _108_)
  local _arg_109_ = _108_
  local reverse_3f = _arg_109_["reverse?"]
  local source_winid = _arg_109_["source-winid"]
  local targets = _arg_109_["targets"]
  local wininfo = _arg_109_["wininfo"]
  local targets0 = (targets or {})
  local prev_match = {}
  local _let_110_ = get_horizontal_bounds()
  local _ = _let_110_[1]
  local right_bound = _let_110_[2]
  local bounds = _let_110_
  local pattern
  local _111_
  if opts.case_insensitive then
    _111_ = "\\c"
  else
    _111_ = "\\C"
  end
  pattern = ("\\V" .. _111_ .. input:gsub("\\", "\\\\") .. "\\_.")
  for _113_ in get_match_positions(pattern, {["reverse?"] = reverse_3f, ["source-winid"] = source_winid, ["whole-window?"] = wininfo, bounds = bounds}) do
    local _each_114_ = _113_
    local line = _each_114_[1]
    local col = _each_114_[2]
    local pos = _each_114_
    local ch1 = char_at_pos(pos, {})
    local ch2, eol_3f = nil, nil
    do
      local _115_ = char_at_pos(pos, {["char-offset"] = 1})
      if (nil ~= _115_) then
        local char = _115_
        ch2, eol_3f = char
      else
        local _0 = _115_
        ch2, eol_3f = replace_keycodes(opts.special_keys.eol), true
      end
    end
    local same_char_triplet_3f
    local _117_
    if reverse_3f then
      _117_ = dec
    else
      _117_ = inc
    end
    same_char_triplet_3f = ((ch2 == prev_match.ch2) and (line == prev_match.line) and (col == _117_(prev_match.col)))
    prev_match = {ch2 = ch2, col = col, line = line}
    if not same_char_triplet_3f then
      table.insert(targets0, {["edge-pos?"] = (eol_3f or (col == right_bound)), pair = {ch1, ch2}, pos = pos, wininfo = wininfo})
    end
  end
  if next(targets0) then
    return targets0
  end
end
local function distance(_121_, _123_)
  local _arg_122_ = _121_
  local l1 = _arg_122_[1]
  local c1 = _arg_122_[2]
  local _arg_124_ = _123_
  local l2 = _arg_124_[1]
  local c2 = _arg_124_[2]
  local editor_grid_aspect_ratio = 0.3
  local _let_125_ = {abs((c1 - c2)), abs((l1 - l2))}
  local dx = _let_125_[1]
  local dy = _let_125_[2]
  local dx0 = (dx * editor_grid_aspect_ratio)
  return pow((pow(dx0, 2) + pow(dy, 2)), 0.5)
end
local function get_targets(input, _126_)
  local _arg_127_ = _126_
  local reverse_3f = _arg_127_["reverse?"]
  local target_windows = _arg_127_["target-windows"]
  if target_windows then
    local targets = {}
    local cursor_positions = {}
    local cross_win_3f = not ((#target_windows == 1) and (target_windows[1].winid == vim.fn.win_getid()))
    local source_winid = vim.fn.win_getid()
    for _, w in ipairs(target_windows) do
      if cross_win_3f then
        api.nvim_set_current_win(w.winid)
      end
      cursor_positions[w.winid] = get_cursor_pos()
      get_targets_2a(input, {["source-winid"] = source_winid, targets = targets, wininfo = w})
    end
    if cross_win_3f then
      api.nvim_set_current_win(source_winid)
    end
    if not empty_3f(targets) then
      local by_screen_pos_3f = (vim.o.wrap and (#targets < 200))
      if by_screen_pos_3f then
        for winid, _130_ in pairs(cursor_positions) do
          local _each_131_ = _130_
          local line = _each_131_[1]
          local col = _each_131_[2]
          local _132_ = vim.fn.screenpos(winid, line, col)
          if ((type(_132_) == "table") and (nil ~= (_132_).row) and ((_132_).col == col)) then
            local row = (_132_).row
            cursor_positions[winid] = {row, col}
          end
        end
      end
      for _, _135_ in ipairs(targets) do
        local _each_136_ = _135_
        local t = _each_136_
        local _each_137_ = _each_136_["pos"]
        local line = _each_137_[1]
        local col = _each_137_[2]
        local _each_138_ = _each_136_["wininfo"]
        local winid = _each_138_["winid"]
        if by_screen_pos_3f then
          local _139_ = vim.fn.screenpos(winid, line, col)
          if ((type(_139_) == "table") and (nil ~= (_139_).row) and ((_139_).col == col)) then
            local row = (_139_).row
            t["screenpos"] = {row, col}
          end
        end
        t["rank"] = distance((t.screenpos or t.pos), cursor_positions[winid])
      end
      local function _142_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _142_)
      return targets
    end
  else
    return get_targets_2a(input, {["reverse?"] = reverse_3f})
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.case_insensitive then
    local function _145_(self, k)
      return rawget(self, k:lower())
    end
    local function _146_(self, k, v)
      return rawset(self, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _145_, __newindex = _146_})
  end
  for _, _148_ in ipairs(targets) do
    local _each_149_ = _148_
    local target = _each_149_
    local _each_150_ = _each_149_["pair"]
    local _0 = _each_150_[1]
    local ch2 = _each_150_[2]
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function set_autojump(sublist, force_no_autojump_3f)
  sublist["autojump?"] = (not (force_no_autojump_3f or user_forced_no_autojump_3f()) and (user_forced_autojump_3f() or (#opts.safe_labels >= dec(#sublist))))
  return nil
end
local function attach_label_set(sublist)
  local _152_
  if user_forced_autojump_3f() then
    _152_ = opts.safe_labels
  elseif user_forced_no_autojump_3f() then
    _152_ = opts.labels
  elseif sublist["autojump?"] then
    _152_ = opts.safe_labels
  else
    _152_ = opts.labels
  end
  sublist["label-set"] = _152_
  return nil
end
local function set_sublist_attributes(targets, _154_)
  local _arg_155_ = _154_
  local force_no_autojump_3f = _arg_155_["force-no-autojump?"]
  for _, sublist in pairs(targets.sublists) do
    set_autojump(sublist, force_no_autojump_3f)
    attach_label_set(sublist)
  end
  return nil
end
local function set_labels(targets)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local autojump_3f = sublist["autojump?"]
      local labels0 = sublist["label-set"]
      for i, target in ipairs(sublist) do
        local _156_
        if not (autojump_3f and (i == 1)) then
          local _157_
          local _159_
          if autojump_3f then
            _159_ = dec(i)
          else
            _159_ = i
          end
          _157_ = (_159_ % #labels0)
          if (_157_ == 0) then
            _156_ = (labels0)[#labels0]
          elseif (nil ~= _157_) then
            local n = _157_
            _156_ = (labels0)[n]
          else
          _156_ = nil
          end
        else
        _156_ = nil
        end
        target["label"] = _156_
      end
    end
  end
  return nil
end
local function set_label_states(sublist, _166_)
  local _arg_167_ = _166_
  local group_offset = _arg_167_["group-offset"]
  local labels0 = sublist["label-set"]
  local _7clabels_7c = #labels0
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local _168_
  if sublist["autojump?"] then
    _168_ = 2
  else
    _168_ = 1
  end
  primary_start = (offset + _168_)
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    if target.label then
      local _170_
      if (function(_171_,_172_,_173_) return (_171_ <= _172_) and (_172_ <= _173_) end)(primary_start,i,primary_end) then
        _170_ = "active-primary"
      elseif (function(_174_,_175_,_176_) return (_174_ <= _175_) and (_175_ <= _176_) end)(secondary_start,i,secondary_end) then
        _170_ = "active-secondary"
      elseif (i > secondary_end) then
        _170_ = "inactive"
      else
      _170_ = nil
      end
      target["label-state"] = _170_
    end
  end
  return nil
end
local function set_initial_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function set_beacons(target_list, _179_)
  local _arg_180_ = _179_
  local force_no_labels_3f = _arg_180_["force-no-labels?"]
  if force_no_labels_3f then
    for _, target in ipairs(target_list) do
      target["beacon"] = {0, {{(target.pair[1] .. target.pair[2]), hl.group.match}}}
    end
    return nil
  else
    for _, target in ipairs(target_list) do
      local _local_181_ = target
      local edge_pos_3f = _local_181_["edge-pos?"]
      local label = _local_181_["label"]
      local label_state = _local_181_["label-state"]
      local _local_182_ = _local_181_["pair"]
      local ch1 = _local_182_[1]
      local ch2 = _local_182_[2]
      local offset
      local _183_
      if edge_pos_3f then
        _183_ = 0
      else
        _183_ = ch2:len()
      end
      offset = (ch1:len() + _183_)
      local virttext
      do
        local _185_ = label_state
        if (_185_ == "active-primary") then
          virttext = {{label, hl.group["label-primary"]}}
        elseif (_185_ == "active-secondary") then
          virttext = {{label, hl.group["label-secondary"]}}
        elseif (_185_ == "inactive") then
          virttext = {{" ", hl.group["label-secondary"]}}
        else
        virttext = nil
        end
      end
      local beacon
      if virttext then
        beacon = {offset, virttext}
      else
      beacon = nil
      end
      target["beacon"] = beacon
    end
    local label_positions = {}
    for i, _188_ in ipairs(target_list) do
      local _each_189_ = _188_
      local target = _each_189_
      local label = _each_189_["label"]
      local _each_190_ = _each_189_["pair"]
      local ch1 = _each_190_[1]
      local ch2 = _each_190_[2]
      local _let_191_ = map(dec, target.pos)
      local lnum = _let_191_[1]
      local col = _let_191_[2]
      local bufnr
      local function _193_()
        local t_192_ = target.wininfo
        if (nil ~= t_192_) then
          t_192_ = (t_192_).bufnr
        end
        return t_192_
      end
      bufnr = (_193_() or 0)
      local winid
      local function _196_()
        local t_195_ = target.wininfo
        if (nil ~= t_195_) then
          t_195_ = (t_195_).winid
        end
        return t_195_
      end
      winid = (_196_() or 0)
      local _198_ = target.beacon
      if (_198_ == nil) then
        local k1 = (bufnr .. " " .. winid .. " " .. lnum .. " " .. col)
        local k2 = (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + ch1:len()))
        for _, k in ipairs({k1, k2}) do
          local _199_ = label_positions[k]
          if (nil ~= _199_) then
            local target_2a = _199_
            target_2a["beacon"] = nil
            target["beacon"] = {0, {{(target.pair[1] .. target.pair[2]), hl.group.match}}}
          end
        end
      elseif ((type(_198_) == "table") and (nil ~= (_198_)[1]) and true) then
        local offset = (_198_)[1]
        local _ = (_198_)[2]
        local col0 = (col + offset)
        local k = (bufnr .. " " .. winid .. " " .. lnum .. " " .. col0)
        do
          local _201_ = label_positions[k]
          if (nil ~= _201_) then
            local target_2a = _201_
            target_2a["beacon"] = nil
            target["beacon"][2][1][1] = " "
          end
        end
        label_positions[k] = target
      end
    end
    return nil
  end
end
local function light_up_beacons(target_list, _3fstart_from)
  for i = (_3fstart_from or 1), #target_list do
    local target = target_list[i]
    local _205_ = target.beacon
    if ((type(_205_) == "table") and (nil ~= (_205_)[1]) and (nil ~= (_205_)[2])) then
      local offset = (_205_)[1]
      local virttext = (_205_)[2]
      local _let_206_ = map(dec, target.pos)
      local lnum = _let_206_[1]
      local col = _let_206_[2]
      local bufnr
      local function _208_()
        local t_207_ = target.wininfo
        if (nil ~= t_207_) then
          t_207_ = (t_207_).bufnr
        end
        return t_207_
      end
      bufnr = (_208_() or 0)
      api.nvim_buf_set_extmark(bufnr, hl.ns, lnum, (col + offset), {hl_mode = "combine", priority = hl.priority.label, virt_text = virttext, virt_text_pos = "overlay"})
    end
  end
  return nil
end
local state = {["dot-repeat"] = {["target-idx"] = nil, in1 = nil, in2 = nil}, ["repeat"] = {in1 = nil, in2 = nil}}
local function leap(_211_)
  local _arg_212_ = _211_
  local cross_window_3f = _arg_212_["cross-window?"]
  local dot_repeat_3f = _arg_212_["dot-repeat?"]
  local omni_3f = _arg_212_["omni?"]
  local reverse_3f = _arg_212_["reverse?"]
  local traversal_state = _arg_212_["traversal-state"]
  local x_mode_3f = _arg_212_["x-mode?"]
  local omni_3f0 = (cross_window_3f or omni_3f)
  local mode = api.nvim_get_mode().mode
  local visual_mode_3f = ((mode == _3cctrl_v_3e) or (mode == "V") or (mode == "v"))
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and not omni_3f0 and (vim.v.operator ~= "y"))
  local traversal_3f = traversal_state
  local force_no_autojump_3f = (op_mode_3f or (omni_3f0 and visual_mode_3f) or cross_window_3f)
  local force_no_labels_3f = (traversal_3f and not traversal_state.targets["autojump?"])
  local _3ftarget_windows
  if cross_window_3f then
    _3ftarget_windows = get_targetable_windows()
  elseif omni_3f0 then
    _3ftarget_windows = {vim.fn.getwininfo(vim.fn.win_getid())[1]}
  else
  _3ftarget_windows = nil
  end
  local spec_keys
  local function _214_(_, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _214_})
  local new_search_3f = not (dot_repeat_3f or traversal_3f)
  local function get_first_input()
    if traversal_3f then
      return state["repeat"].in1
    elseif dot_repeat_3f then
      return state["dot-repeat"].in1
    else
      local _215_
      local function _216_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _217_()
        if change_op_3f then
          handle_interrupted_change_op_21()
        end
        do
        end
        exec_autocmds("LeapLeave")
        return nil
      end
      _215_ = (_216_() or _217_())
      if (_215_ == spec_keys.repeat_search) then
        new_search_3f = false
        local function _219_()
          if change_op_3f then
            handle_interrupted_change_op_21()
          end
          do
            echo_no_prev_search()
          end
          exec_autocmds("LeapLeave")
          return nil
        end
        return (state["repeat"].in1 or _219_())
      elseif (nil ~= _215_) then
        local _in = _215_
        return _in
      end
    end
  end
  local function update_state_2a(in1)
    local function _225_(_223_)
      local _arg_224_ = _223_
      local dot_repeat = _arg_224_["dot-repeat"]
      local _repeat = _arg_224_["repeat"]
      if not dot_repeat_3f then
        if _repeat then
          local _226_ = _repeat
          _226_["in1"] = in1
          state["repeat"] = _226_
        end
        if (dot_repeat and dot_repeatable_op_3f) then
          do
            local _228_ = dot_repeat
            _228_["in1"] = in1
            state["dot-repeat"] = _228_
          end
          return nil
        end
      end
    end
    return _225_
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _231_(target)
      if target.wininfo then
        api.nvim_set_current_win(target.wininfo.winid)
      end
      local function _233_()
        if x_mode_3f then
          push_cursor_21("fwd")
          if reverse_3f then
            return push_cursor_21("fwd")
          end
        end
      end
      jump_to_21_2a(target.pos, {["add-to-jumplist?"] = (first_jump_3f and not traversal_3f), ["inclusive-motion?"] = (x_mode_3f and not reverse_3f), ["reverse?"] = reverse_3f, adjust = _233_, mode = mode})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _231_
  end
  local function get_last_input(sublist, _236_)
    local _arg_237_ = _236_
    local display_targets_from = _arg_237_["display-targets-from"]
    local function recur(group_offset, initial_invoc_3f)
      set_beacons(sublist, {["force-no-labels?"] = force_no_labels_3f})
      do
        if new_search_3f then
          apply_backdrop(reverse_3f, _3ftarget_windows)
        end
        do
          light_up_beacons(sublist, display_targets_from)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _239_
      do
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        _239_ = res_2_auto
      end
      if (nil ~= _239_) then
        local input = _239_
        if (sublist["autojump?"] and not user_forced_autojump_3f()) then
          return {input, 0}
        else
          local _240_
          if not initial_invoc_3f then
            _240_ = spec_keys.prev_group
          else
          _240_ = nil
          end
          if (not traversal_3f and ((input == spec_keys.next_group) or (input == _240_))) then
            local labels0 = sublist["label-set"]
            local num_of_groups = ceil((#sublist / #labels0))
            local max_offset = dec(num_of_groups)
            local new_group_offset
            local _243_
            do
              local _242_ = input
              if (_242_ == spec_keys.next_group) then
                _243_ = inc
              else
                local _ = _242_
                _243_ = dec
              end
            end
            new_group_offset = clamp(_243_(group_offset), 0, max_offset)
            set_label_states(sublist, {["group-offset"] = new_group_offset})
            return recur(new_group_offset)
          else
            return {input, group_offset}
          end
        end
      end
    end
    return recur(0, true)
  end
  local function get_traversal_action(_in)
    if (_in == spec_keys.next_match) then
      return "to-next"
    elseif (traversal_3f and (_in == spec_keys.prev_match)) then
      return "to-prev"
    end
  end
  local function get_target_with_active_primary_label(target_list, input)
    local res = nil
    for idx, _250_ in ipairs(target_list) do
      local _each_251_ = _250_
      local target = _each_251_
      local label = _each_251_["label"]
      local label_state = _each_251_["label-state"]
      if res then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      end
    end
    return res
  end
  if not (dot_repeat_3f or traversal_3f) then
    exec_autocmds("LeapEnter")
    echo("")
    if new_search_3f then
      apply_backdrop(reverse_3f, _3ftarget_windows)
    end
    do
    end
    highlight_cursor()
    vim.cmd("redraw")
  end
  local _255_ = get_first_input()
  if (nil ~= _255_) then
    local in1 = _255_
    local update_state = update_state_2a(in1)
    local prev_in2
    if not new_search_3f then
      if dot_repeat_3f then
        prev_in2 = state["dot-repeat"].in2
      else
        prev_in2 = state["repeat"].in2
      end
    else
    prev_in2 = nil
    end
    local _258_
    local function _260_()
      local t_259_ = traversal_state
      if (nil ~= t_259_) then
        t_259_ = (t_259_).targets
      end
      return t_259_
    end
    local function _262_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      end
      do
        echo_not_found((in1 .. (prev_in2 or "")))
      end
      exec_autocmds("LeapLeave")
      return nil
    end
    _258_ = (_260_() or get_targets(in1, {["reverse?"] = reverse_3f, ["target-windows"] = _3ftarget_windows}) or _262_())
    if ((type(_258_) == "table") and (nil ~= (_258_)[1])) then
      local first = (_258_)[1]
      local targets = _258_
      if not traversal_3f then
        local _264_ = targets
        populate_sublists(_264_)
        set_sublist_attributes(_264_, {["force-no-autojump?"] = force_no_autojump_3f})
        set_labels(_264_)
        set_initial_label_states(_264_)
      end
      if new_search_3f then
        set_beacons(targets, {})
        if new_search_3f then
          apply_backdrop(reverse_3f, _3ftarget_windows)
        end
        do
          light_up_beacons(targets)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _268_
      local function _269_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _270_()
        if change_op_3f then
          handle_interrupted_change_op_21()
        end
        do
        end
        exec_autocmds("LeapLeave")
        return nil
      end
      _268_ = (prev_in2 or _269_() or _270_())
      local function _272_()
        return (not traversal_3f and not omni_3f0)
      end
      if ((_268_ == spec_keys.next_match) and _272_()) then
        jump_to_21(first)
        if op_mode_3f then
          if dot_repeatable_op_3f then
            set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
          end
          do
            update_state({["dot-repeat"] = {["target-idx"] = 1, in2 = first.pair[2]}})
          end
          exec_autocmds("LeapLeave")
          return nil
        else
          set_beacons(targets, {["force-no-labels?"] = true})
          return leap({["reverse?"] = reverse_3f, ["traversal-state"] = {idx = 1, targets = targets}, ["x-mode?"] = x_mode_3f})
        end
      elseif (nil ~= _268_) then
        local in2 = _268_
        if dot_repeat_3f then
          local _275_ = targets.sublists[in2][state["dot-repeat"]["target-idx"]]
          if (nil ~= _275_) then
            local target = _275_
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
            end
            do
              jump_to_21(target)
            end
            exec_autocmds("LeapLeave")
            return nil
          else
            local _ = _275_
            if change_op_3f then
              handle_interrupted_change_op_21()
            end
            do
            end
            exec_autocmds("LeapLeave")
            return nil
          end
        else
          local _279_
          if traversal_3f then
            _279_ = targets[traversal_state.idx].pair[2]
          else
            _279_ = in2
          end
          update_state({["repeat"] = {in2 = _279_}})
          local _281_
          local function _283_()
            local t_282_ = traversal_state
            if (nil ~= t_282_) then
              t_282_ = (t_282_).targets
            end
            return t_282_
          end
          local function _285_()
            if change_op_3f then
              handle_interrupted_change_op_21()
            end
            do
              echo_not_found((in1 .. in2))
            end
            exec_autocmds("LeapLeave")
            return nil
          end
          _281_ = (_283_() or targets.sublists[in2] or _285_())
          if ((type(_281_) == "table") and (nil ~= (_281_)[1]) and ((_281_)[2] == nil)) then
            local only = (_281_)[1]
            if dot_repeatable_op_3f then
              set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
            end
            do
              update_state({["dot-repeat"] = {["target-idx"] = 1, in2 = in2}})
              jump_to_21(only)
            end
            exec_autocmds("LeapLeave")
            return nil
          elseif ((type(_281_) == "table") and (nil ~= (_281_)[1])) then
            local sublist_first = (_281_)[1]
            local sublist = _281_
            local curr_idx
            local function _289_()
              local t_288_ = traversal_state
              if (nil ~= t_288_) then
                t_288_ = (t_288_).idx
              end
              return t_288_
            end
            curr_idx = (_289_() or 0)
            if not traversal_3f then
              if sublist["autojump?"] then
                jump_to_21(sublist_first)
                curr_idx = 1
              end
            end
            local _293_
            local function _294_()
              if change_op_3f then
                handle_interrupted_change_op_21()
              end
              do
              end
              exec_autocmds("LeapLeave")
              return nil
            end
            _293_ = (get_last_input(sublist, {["display-targets-from"] = inc(curr_idx)}) or _294_())
            if ((type(_293_) == "table") and (nil ~= (_293_)[1]) and (nil ~= (_293_)[2])) then
              local in3 = (_293_)[1]
              local group_offset = (_293_)[2]
              local _296_
              if not (omni_3f0 or (group_offset > 0)) then
                _296_ = get_traversal_action(in3)
              else
              _296_ = nil
              end
              if (nil ~= _296_) then
                local action = _296_
                local new_idx
                do
                  local _298_ = action
                  if (_298_ == "to-next") then
                    new_idx = min(inc(curr_idx), #targets)
                  elseif (_298_ == "to-prev") then
                    new_idx = max(dec(curr_idx), 1)
                  else
                  new_idx = nil
                  end
                end
                jump_to_21(sublist[new_idx])
                if op_mode_3f then
                  if dot_repeatable_op_3f then
                    set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
                  end
                  do
                    update_state({["dot-repeat"] = {["target-idx"] = 1, in2 = in2}})
                  end
                  exec_autocmds("LeapLeave")
                  return nil
                else
                  return leap({["reverse?"] = reverse_3f, ["traversal-state"] = {idx = new_idx, targets = sublist}, ["x-mode?"] = x_mode_3f})
                end
              else
                local _ = _296_
                local _302_
                if not force_no_labels_3f then
                  _302_ = get_target_with_active_primary_label(sublist, in3)
                else
                _302_ = nil
                end
                if ((type(_302_) == "table") and (nil ~= (_302_)[1]) and (nil ~= (_302_)[2])) then
                  local idx = (_302_)[1]
                  local target = (_302_)[2]
                  if dot_repeatable_op_3f then
                    set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
                  end
                  do
                    update_state({["dot-repeat"] = {["target-idx"] = idx, in2 = in2}})
                    jump_to_21(target)
                  end
                  exec_autocmds("LeapLeave")
                  return nil
                else
                  local _0 = _302_
                  if (sublist["autojump?"] or traversal_3f) then
                    if dot_repeatable_op_3f then
                      set_dot_repeat(replace_keycodes(get_plug_key(reverse_3f, x_mode_3f, true)))
                    end
                    do
                      vim.fn.feedkeys(in3, "i")
                    end
                    exec_autocmds("LeapLeave")
                    return nil
                  else
                    if change_op_3f then
                      handle_interrupted_change_op_21()
                    end
                    do
                    end
                    exec_autocmds("LeapLeave")
                    return nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local function set_default_keymaps(force_3f)
  for _, _316_ in ipairs({{"n", "s", "<Plug>(leap-forward)"}, {"n", "S", "<Plug>(leap-backward)"}, {"x", "s", "<Plug>(leap-forward)"}, {"x", "S", "<Plug>(leap-backward)"}, {"o", "z", "<Plug>(leap-forward)"}, {"o", "Z", "<Plug>(leap-backward)"}, {"o", "x", "<Plug>(leap-forward-x)"}, {"o", "X", "<Plug>(leap-backward-x)"}, {"n", "gs", "<Plug>(leap-cross-window)"}, {"x", "gs", "<Plug>(leap-cross-window)"}, {"o", "gs", "<Plug>(leap-cross-window)"}}) do
    local _each_317_ = _316_
    local mode = _each_317_[1]
    local lhs = _each_317_[2]
    local rhs = _each_317_[3]
    if (force_3f or ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0))) then
      vim.keymap.set(mode, lhs, rhs, {silent = true})
    end
  end
  return nil
end
local function _319_()
  return leap({["dot-repeat?"] = true, ["reverse?"] = true})
end
local function _320_()
  return leap({["dot-repeat?"] = true, ["reverse?"] = true, ["x-mode?"] = true})
end
local function _321_()
  return leap({["dot-repeat?"] = true})
end
local function _322_()
  return leap({["dot-repeat?"] = true, ["x-mode?"] = true})
end
for lhs, rhs in pairs({["<Plug>(leap-dotrepeat-backward)"] = _319_, ["<Plug>(leap-dotrepeat-backward-x)"] = _320_, ["<Plug>(leap-dotrepeat-forward)"] = _321_, ["<Plug>(leap-dotrepeat-forward-x)"] = _322_}) do
  vim.keymap.set("o", lhs, rhs, {silent = true})
end
local temporary_editor_opts = {["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_323_ = vim.split(opt, ".", true)
    local _0 = _let_323_[1]
    local scope = _let_323_[2]
    local name = _let_323_[3]
    saved_editor_opts[opt] = _G.vim[scope][name]
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_324_ = vim.split(opt, ".", true)
    local _ = _let_324_[1]
    local scope = _let_324_[2]
    local name = _let_324_[3]
    _G.vim[scope][name] = val
  end
  return nil
end
local function set_temporary_editor_opts()
  return set_editor_opts(temporary_editor_opts)
end
local function restore_editor_opts()
  return set_editor_opts(saved_editor_opts)
end
init_highlight()
api.nvim_create_augroup("LeapDefault", {})
api.nvim_create_autocmd("ColorScheme", {callback = init_highlight, group = "LeapDefault"})
local function _325_()
  save_editor_opts()
  return set_temporary_editor_opts()
end
api.nvim_create_autocmd("User", {callback = _325_, group = "LeapDefault", pattern = "LeapEnter"})
api.nvim_create_autocmd("User", {callback = restore_editor_opts, group = "LeapDefault", pattern = "LeapLeave"})
return {init_highlight = init_highlight, leap = leap, opts = opts, set_default_keymaps = set_default_keymaps, setup = setup, state = state}
