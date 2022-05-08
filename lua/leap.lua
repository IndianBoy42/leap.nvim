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
  else
    return nil
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
    else
      return nil
    end
  else
    return nil
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
  else
    return nil
  end
end
local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local labels = {"s", "f", "n", "j", "k", "l", "o", "d", "w", "e", "h", "m", "v", "g", "u", "t", "c", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local opts = {case_insensitive = true, safe_labels = safe_labels, labels = labels, special_keys = {repeat_search = "<enter>", next_match = "<enter>", prev_match = "<tab>", next_group = "<space>", prev_group = "<tab>", eol = "<space>"}}
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
local function _12_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, wininfo in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(wininfo.bufnr, self.ns, dec(wininfo.topline), wininfo.botline)
    end
  else
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {group = {["label-primary"] = "LeapLabelPrimary", ["label-secondary"] = "LeapLabelSecondary", match = "LeapMatch", backdrop = "LeapBackdrop"}, priority = {label = 65535, cursor = 65534, backdrop = 65533}, ns = api.nvim_create_namespace(""), cleanup = _12_}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local def_maps
  local _15_
  do
    local _14_ = bg
    if (_14_ == "light") then
      _15_ = "#222222"
    elseif true then
      local _ = _14_
      _15_ = "#ccff88"
    else
      _15_ = nil
    end
  end
  local _20_
  do
    local _19_ = bg
    if (_19_ == "light") then
      _20_ = "#ff8877"
    elseif true then
      local _ = _19_
      _20_ = "#ccff88"
    else
      _20_ = nil
    end
  end
  local _25_
  do
    local _24_ = bg
    if (_24_ == "light") then
      _25_ = "#77aaff"
    elseif true then
      local _ = _24_
      _25_ = "#99ccff"
    else
      _25_ = nil
    end
  end
  def_maps = {[hl.group.match] = {fg = _15_, ctermfg = "red", underline = true, nocombine = true}, [hl.group["label-primary"]] = {fg = "black", bg = _20_, ctermfg = "black", ctermbg = "red", nocombine = true}, [hl.group["label-secondary"]] = {fg = "black", bg = _25_, ctermfg = "black", ctermbg = "blue", nocombine = true}}
  for name, def_map in pairs(def_maps) do
    if not force_3f then
      def_map["default"] = true
    else
    end
    api.nvim_set_hl(0, name, def_map)
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
    local _let_30_ = map(dec, get_cursor_pos())
    local curline = _let_30_[1]
    local curcol = _let_30_[2]
    local _let_31_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_31_[1]
    local win_bot = _let_31_[2]
    local function _33_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_32_ = _33_()
    local start = _let_32_[1]
    local finish = _let_32_[2]
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
  local function _36_()
    local _35_ = direction
    if (_35_ == "fwd") then
      return "W"
    elseif (_35_ == "bwd") then
      return "bW"
    else
      return nil
    end
  end
  return vim.fn.search("\\_.", _36_())
end
local function cursor_before_eol_3f()
  return (vim.fn.search("\\_.", "Wn") ~= vim.fn.line("."))
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function add_offset_21(offset)
  if (offset < 0) then
    return push_cursor_21("bwd")
  elseif (offset > 0) then
    if not cursor_before_eol_3f() then
      push_cursor_21("fwd")
    else
    end
    if (offset > 1) then
      return push_cursor_21("fwd")
    else
      return nil
    end
  else
    return nil
  end
end
local function push_beyond_eof_21()
  local saved = vim.o.virtualedit
  vim.o.virtualedit = "onemore"
  vim.cmd("norm! l")
  local function _41_()
    vim.o.virtualedit = saved
    return nil
  end
  return api.nvim_create_autocmd({"CursorMoved", "WinLeave", "BufLeave", "InsertEnter", "CmdlineEnter", "CmdwinEnter"}, {callback = _41_, once = true})
end
local function simulate_inclusive_op_21(motion_force)
  local _42_ = motion_force
  if (_42_ == nil) then
    if cursor_before_eof_3f() then
      return push_beyond_eof_21()
    else
      return push_cursor_21("fwd")
    end
  elseif (_42_ == "v") then
    return push_cursor_21("bwd")
  else
    return nil
  end
end
local function force_matchparen_refresh()
  pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchparen"})
  return pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchup_matchparen"})
end
local function jump_to_21_2a(pos, _45_)
  local _arg_46_ = _45_
  local winid = _arg_46_["winid"]
  local add_to_jumplist_3f = _arg_46_["add-to-jumplist?"]
  local mode = _arg_46_["mode"]
  local offset = _arg_46_["offset"]
  local reverse_3f = _arg_46_["reverse?"]
  local inclusive_op_3f = _arg_46_["inclusive-op?"]
  local op_mode_3f = mode:match("o")
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  else
  end
  if (winid ~= vim.fn.win_getid()) then
    api.nvim_set_current_win(winid)
  else
  end
  vim.fn.cursor(pos)
  if offset then
    add_offset_21(offset)
  else
  end
  if (op_mode_3f and inclusive_op_3f and not reverse_3f) then
    simulate_inclusive_op_21(get_motion_force(mode))
  else
  end
  if not op_mode_3f then
    return force_matchparen_refresh()
  else
    return nil
  end
end
local function highlight_cursor(_3fpos)
  local _let_52_ = (_3fpos or get_cursor_pos())
  local line = _let_52_[1]
  local col = _let_52_[2]
  local pos = _let_52_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch_at_curpos, "Cursor"}}, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.cursor})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _53_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _53_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
end
local function exec_user_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {pattern = pattern, modeline = false})
end
local function get_input()
  local _54_, _55_ = pcall(vim.fn.getcharstr)
  local function _56_()
    local ch = _55_
    return (ch ~= _3cesc_3e)
  end
  if (((_54_ == true) and (nil ~= _55_)) and _56_()) then
    local ch = _55_
    return ch
  else
    return nil
  end
end
local function set_dot_repeat()
  local op = vim.v.operator
  local cmd = replace_keycodes("<cmd>lua require'leap'.leap {['dot-repeat?'] = true}<cr>")
  local change
  if (op == "c") then
    change = replace_keycodes("<c-r>.<esc>")
  else
    change = nil
  end
  local seq = (op .. cmd .. (change or ""))
  pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
  return pcall(vim.fn["repeat#set"], seq, -1)
end
local function get_other_windows_on_tabpage()
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local get_wininfo
  local function _59_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  get_wininfo = _59_
  local get_buf = api.nvim_win_get_buf
  local curr_winid = vim.fn.win_getid()
  local ids = string.gmatch(vim.fn.string(vim.fn.winlayout()), "%d+")
  local ids0
  do
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for id in ids do
      local val_17_auto
      if not ((tonumber(id) == curr_winid) or (visual_or_OP_mode_3f and (get_buf(tonumber(id)) ~= get_buf(curr_winid)))) then
        val_17_auto = id
      else
        val_17_auto = nil
      end
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    ids0 = tbl_15_auto
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
local function to_closed_fold_edge_21(reverse_3f)
  local _62_
  local _63_
  if reverse_3f then
    _63_ = vim.fn.foldclosed
  else
    _63_ = vim.fn.foldclosedend
  end
  _62_ = _63_(vim.fn.line("."))
  if (_62_ == -1) then
    return nil
  elseif (nil ~= _62_) then
    local edge_line = _62_
    vim.fn.cursor(edge_line, 0)
    local function _65_()
      if reverse_3f then
        return 1
      else
        return vim.fn.col("$")
      end
    end
    vim.fn.cursor(0, _65_())
    return "moved"
  else
    return nil
  end
end
local function reach_right_bound()
  while ((vim.fn.virtcol(".") < __fnl_global__right_2dbound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
    vim.cmd("norm! l")
  end
  return nil
end
local function to_next_in_window_pos_21(reverse_3f, left_bound, right_bound, stopline)
  local _local_67_ = {vim.fn.line("."), vim.fn.virtcol(".")}
  local line = _local_67_[1]
  local virtcol = _local_67_[2]
  local from_pos = _local_67_
  local _68_
  if (virtcol < left_bound) then
    if reverse_3f then
      if (dec(line) >= stopline) then
        _68_ = {dec(line), right_bound}
      else
        _68_ = nil
      end
    else
      _68_ = {line, left_bound}
    end
  elseif (virtcol > right_bound) then
    if reverse_3f then
      _68_ = {line, right_bound}
    else
      if (inc(line) <= stopline) then
        _68_ = {inc(line), left_bound}
      else
        _68_ = nil
      end
    end
  else
    _68_ = nil
  end
  if (nil ~= _68_) then
    local to_pos = _68_
    if (from_pos ~= to_pos) then
      vim.fn.cursor(to_pos)
      if reverse_3f then
        reach_right_bound()
      else
      end
      return "moved"
    else
      return nil
    end
  else
    return nil
  end
end
local function get_match_positions(pattern, _77_)
  local _arg_78_ = _77_
  local reverse_3f = _arg_78_["reverse?"]
  local whole_window_3f = _arg_78_["whole-window?"]
  local skip_curpos_3f = _arg_78_["skip-curpos?"]
  local _arg_79_ = _arg_78_["bounds"]
  local left_bound = _arg_79_[1]
  local right_bound = _arg_79_[2]
  local reverse_3f0
  if whole_window_3f then
    reverse_3f0 = false
  else
    reverse_3f0 = reverse_3f
  end
  local skip_orig_curpos_3f = skip_curpos_3f
  local _let_81_ = get_cursor_pos()
  local orig_line = _let_81_[1]
  local orig_col = _let_81_[2]
  local saved_view = vim.fn.winsaveview()
  local saved_cpo = vim.o.cpo
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local stopline
  if reverse_3f0 then
    stopline = wintop
  else
    stopline = winbot
  end
  local cleanup
  local function _83_()
    vim.fn.winrestview(saved_view)
    vim.o.cpo = saved_cpo
    return nil
  end
  cleanup = _83_
  vim.o.cpo = saved_cpo:gsub("c", "")
  local match_count = 0
  local set_to_topleft_3f
  if whole_window_3f then
    vim.fn.cursor({wintop, left_bound})
    set_to_topleft_3f = true
  else
    set_to_topleft_3f = nil
  end
  local function rec(match_at_curpos_3f)
    local match_at_curpos_3f0 = (match_at_curpos_3f or set_to_topleft_3f)
    local flags
    local function _85_()
      if reverse_3f0 then
        return "b"
      else
        return ""
      end
    end
    local function _86_()
      if match_at_curpos_3f0 then
        return "c"
      else
        return ""
      end
    end
    flags = (_85_() .. _86_())
    set_to_topleft_3f = false
    local _87_ = vim.fn.searchpos(pattern, flags, stopline)
    if ((_G.type(_87_) == "table") and (nil ~= (_87_)[1]) and (nil ~= (_87_)[2])) then
      local line = (_87_)[1]
      local col = (_87_)[2]
      local pos = _87_
      if (line == 0) then
        return cleanup()
      elseif ((line == orig_line) and (col == orig_col) and skip_orig_curpos_3f) then
        push_cursor_21("fwd")
        return rec(true)
      elseif ((col < left_bound) and (col > right_bound) and not vim.wo.wrap) then
        local _88_ = to_next_in_window_pos_21(reverse_3f0, left_bound, right_bound, stopline)
        if (_88_ == "moved") then
          return rec(true)
        elseif true then
          local _ = _88_
          return cleanup()
        else
          return nil
        end
      else
        local _90_ = to_closed_fold_edge_21(reverse_3f0)
        if (_90_ == "moved") then
          return rec(false)
        elseif true then
          local _ = _90_
          match_count = (match_count + 1)
          return pos
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  return rec
end
local function get_targets_2a(input, _94_)
  local _arg_95_ = _94_
  local reverse_3f = _arg_95_["reverse?"]
  local wininfo = _arg_95_["wininfo"]
  local targets = _arg_95_["targets"]
  local source_winid = _arg_95_["source-winid"]
  local targets0 = (targets or {})
  local pattern
  local function _96_()
    if opts.case_insensitive then
      return "\\c"
    else
      return "\\C"
    end
  end
  pattern = ("\\V" .. _96_() .. input:gsub("\\", "\\\\") .. "\\_.")
  local _let_97_ = get_horizontal_bounds()
  local _ = _let_97_[1]
  local right_bound = _let_97_[2]
  local bounds = _let_97_
  local whole_window_3f = wininfo
  local wininfo0 = (wininfo or vim.fn.getwininfo(vim.fn.win_getid())[1])
  local skip_curpos_3f = (whole_window_3f and (vim.fn.win_getid() == source_winid))
  local kwargs = {bounds = bounds, ["reverse?"] = reverse_3f, ["skip-curpos?"] = skip_curpos_3f, ["whole-window?"] = whole_window_3f}
  local prev_match = {}
  for _98_ in get_match_positions(pattern, kwargs) do
    local _each_99_ = _98_
    local line = _each_99_[1]
    local col = _each_99_[2]
    local pos = _each_99_
    local ch1 = char_at_pos(pos, {})
    local ch2, eol_3f = nil, nil
    do
      local _100_ = char_at_pos(pos, {["char-offset"] = 1})
      if (nil ~= _100_) then
        local char = _100_
        ch2, eol_3f = char
      elseif true then
        local _0 = _100_
        ch2, eol_3f = replace_keycodes(opts.special_keys.eol), true
      else
        ch2, eol_3f = nil
      end
    end
    local same_char_triplet_3f
    local _102_
    if reverse_3f then
      _102_ = dec
    else
      _102_ = inc
    end
    same_char_triplet_3f = ((ch2 == prev_match.ch2) and (line == prev_match.line) and (col == _102_(prev_match.col)))
    prev_match = {line = line, col = col, ch2 = ch2}
    if not same_char_triplet_3f then
      table.insert(targets0, {wininfo = wininfo0, pos = pos, pair = {ch1, ch2}, ["edge-pos?"] = (eol_3f or (col == right_bound))})
    else
    end
  end
  if next(targets0) then
    return targets0
  else
    return nil
  end
end
local function distance(_106_, _108_)
  local _arg_107_ = _106_
  local l1 = _arg_107_[1]
  local c1 = _arg_107_[2]
  local _arg_109_ = _108_
  local l2 = _arg_109_[1]
  local c2 = _arg_109_[2]
  local editor_grid_aspect_ratio = 0.3
  local _let_110_ = {abs((c1 - c2)), abs((l1 - l2))}
  local dx = _let_110_[1]
  local dy = _let_110_[2]
  local dx0 = (dx * editor_grid_aspect_ratio)
  return pow((pow(dx0, 2) + pow(dy, 2)), 0.5)
end
local function get_targets(input, _111_)
  local _arg_112_ = _111_
  local reverse_3f = _arg_112_["reverse?"]
  local target_windows = _arg_112_["target-windows"]
  if target_windows then
    local targets = {}
    local cursor_positions = {}
    local source_winid = vim.fn.win_getid()
    local curr_win_only_3f
    do
      local _113_ = target_windows
      if ((_G.type(_113_) == "table") and ((_G.type((_113_)[1]) == "table") and (((_113_)[1]).winid == source_winid)) and ((_113_)[2] == nil)) then
        curr_win_only_3f = true
      else
        curr_win_only_3f = nil
      end
    end
    local cross_win_3f = not curr_win_only_3f
    for _, _115_ in ipairs(target_windows) do
      local _each_116_ = _115_
      local winid = _each_116_["winid"]
      local wininfo = _each_116_
      if cross_win_3f then
        api.nvim_set_current_win(winid)
      else
      end
      cursor_positions[winid] = get_cursor_pos()
      get_targets_2a(input, {wininfo = wininfo, ["source-winid"] = source_winid, targets = targets})
    end
    if cross_win_3f then
      api.nvim_set_current_win(source_winid)
    else
    end
    if not empty_3f(targets) then
      local by_screen_pos_3f = (vim.o.wrap and (#targets < 200))
      if by_screen_pos_3f then
        for winid, _119_ in pairs(cursor_positions) do
          local _each_120_ = _119_
          local line = _each_120_[1]
          local col = _each_120_[2]
          local _121_ = vim.fn.screenpos(winid, line, col)
          if ((_G.type(_121_) == "table") and (nil ~= (_121_).row) and ((_121_).col == col)) then
            local row = (_121_).row
            cursor_positions[winid] = {row, col}
          else
          end
        end
      else
      end
      for _, _124_ in ipairs(targets) do
        local _each_125_ = _124_
        local _each_126_ = _each_125_["pos"]
        local line = _each_126_[1]
        local col = _each_126_[2]
        local _each_127_ = _each_125_["wininfo"]
        local winid = _each_127_["winid"]
        local t = _each_125_
        if by_screen_pos_3f then
          local _128_ = vim.fn.screenpos(winid, line, col)
          if ((_G.type(_128_) == "table") and (nil ~= (_128_).row) and ((_128_).col == col)) then
            local row = (_128_).row
            t["screenpos"] = {row, col}
          else
          end
        else
        end
        t["rank"] = distance((t.screenpos or t.pos), cursor_positions[winid])
      end
      local function _131_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _131_)
      return targets
    else
      return nil
    end
  else
    return get_targets_2a(input, {["reverse?"] = reverse_3f})
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.case_insensitive then
    local function _134_(t, k)
      return rawget(t, k:lower())
    end
    local function _135_(t, k, v)
      return rawset(t, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _134_, __newindex = _135_})
  else
  end
  for _, _137_ in ipairs(targets) do
    local _each_138_ = _137_
    local _each_139_ = _each_138_["pair"]
    local _0 = _each_139_[1]
    local ch2 = _each_139_[2]
    local target = _each_138_
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    else
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
  local _141_
  if user_forced_autojump_3f() then
    _141_ = opts.safe_labels
  elseif user_forced_no_autojump_3f() then
    _141_ = opts.labels
  elseif sublist["autojump?"] then
    _141_ = opts.safe_labels
  else
    _141_ = opts.labels
  end
  sublist["label-set"] = _141_
  return nil
end
local function set_sublist_attributes(targets, _143_)
  local _arg_144_ = _143_
  local force_no_autojump_3f = _arg_144_["force-no-autojump?"]
  for _, sublist in pairs(targets.sublists) do
    set_autojump(sublist, force_no_autojump_3f)
    attach_label_set(sublist)
  end
  return nil
end
local function set_labels(targets)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      local _local_145_ = sublist
      local autojump_3f = _local_145_["autojump?"]
      local label_set = _local_145_["label-set"]
      for i, target in ipairs(sublist) do
        local i_2a
        if autojump_3f then
          i_2a = dec(i)
        else
          i_2a = i
        end
        if (i_2a > 0) then
          local _148_
          do
            local _147_ = (i_2a % #label_set)
            if (_147_ == 0) then
              _148_ = label_set[#label_set]
            elseif (nil ~= _147_) then
              local n = _147_
              _148_ = label_set[n]
            else
              _148_ = nil
            end
          end
          target["label"] = _148_
        else
        end
      end
    else
    end
  end
  return nil
end
local function set_label_states(sublist, _154_)
  local _arg_155_ = _154_
  local group_offset = _arg_155_["group-offset"]
  local _7clabel_set_7c = #sublist["label-set"]
  local offset = (group_offset * _7clabel_set_7c)
  local primary_start
  local function _156_()
    if sublist["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _156_())
  local primary_end = (primary_start + dec(_7clabel_set_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabel_set_7c)
  for i, target in ipairs(sublist) do
    if target.label then
      local _157_
      if (function(_158_,_159_,_160_) return (_158_ <= _159_) and (_159_ <= _160_) end)(primary_start,i,primary_end) then
        _157_ = "active-primary"
      elseif (function(_161_,_162_,_163_) return (_161_ <= _162_) and (_162_ <= _163_) end)(secondary_start,i,secondary_end) then
        _157_ = "active-secondary"
      elseif (i > secondary_end) then
        _157_ = "inactive"
      else
        _157_ = nil
      end
      target["label-state"] = _157_
    else
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
local function inactivate_labels(target_list)
  for _, target in ipairs(target_list) do
    target["label-state"] = "inactive"
  end
  return nil
end
local function set_beacon_for_labeled(target)
  if target["label-state"] then
    local _let_166_ = target
    local _let_167_ = _let_166_["pair"]
    local ch1 = _let_167_[1]
    local ch2 = _let_167_[2]
    local edge_pos_3f = _let_166_["edge-pos?"]
    local label = _let_166_["label"]
    local offset
    local function _168_()
      if edge_pos_3f then
        return 0
      else
        return ch2:len()
      end
    end
    offset = (ch1:len() + _168_())
    local virttext
    do
      local _169_ = target["label-state"]
      if (_169_ == "active-primary") then
        virttext = {{label, hl.group["label-primary"]}}
      elseif (_169_ == "active-secondary") then
        virttext = {{label, hl.group["label-secondary"]}}
      elseif (_169_ == "inactive") then
        virttext = {{" ", hl.group["label-secondary"]}}
      else
        virttext = nil
      end
    end
    target["beacon"] = {offset, virttext}
    return nil
  else
    return nil
  end
end
local function set_beacon_to_match_hl(target)
  local _let_172_ = target
  local _let_173_ = _let_172_["pair"]
  local ch1 = _let_173_[1]
  local ch2 = _let_173_[2]
  target["beacon"] = {0, {{(ch1 .. ch2), hl.group.match}}}
  return nil
end
local function set_beacon_to_empty_label(target)
  target["beacon"][2][1][1] = " "
  return nil
end
local function resolve_conflicts(target_list)
  local unlabeled_match_positions = {}
  local label_positions = {}
  for i, target in ipairs(target_list) do
    local _let_174_ = target
    local _let_175_ = _let_174_["pos"]
    local lnum = _let_175_[1]
    local col = _let_175_[2]
    local _let_176_ = _let_174_["pair"]
    local ch1 = _let_176_[1]
    local _ = _let_176_[2]
    local _let_177_ = _let_174_["wininfo"]
    local bufnr = _let_177_["bufnr"]
    local winid = _let_177_["winid"]
    local _178_ = target.beacon
    if (_178_ == nil) then
      local keys = {(bufnr .. " " .. winid .. " " .. lnum .. " " .. col), (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + ch1:len()))}
      for _0, k in ipairs(keys) do
        do
          local _179_ = label_positions[k]
          if (nil ~= _179_) then
            local other = _179_
            other.beacon = nil
            set_beacon_to_match_hl(target)
          else
          end
        end
        unlabeled_match_positions[k] = target
      end
    elseif ((_G.type(_178_) == "table") and (nil ~= (_178_)[1]) and true) then
      local offset = (_178_)[1]
      local _0 = (_178_)[2]
      local k = (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + offset))
      do
        local _181_ = unlabeled_match_positions[k]
        if (nil ~= _181_) then
          local other = _181_
          target.beacon = nil
          set_beacon_to_match_hl(other)
        elseif true then
          local _1 = _181_
          local _182_ = label_positions[k]
          if (nil ~= _182_) then
            local other = _182_
            target.beacon = nil
            set_beacon_to_empty_label(other)
          else
          end
        else
        end
      end
      label_positions[k] = target
    else
    end
  end
  return nil
end
local function set_beacons(target_list, _186_)
  local _arg_187_ = _186_
  local force_no_labels_3f = _arg_187_["force-no-labels?"]
  if force_no_labels_3f then
    for _, target in ipairs(target_list) do
      set_beacon_to_match_hl(target)
    end
    return nil
  else
    for _, target in ipairs(target_list) do
      set_beacon_for_labeled(target)
    end
    return resolve_conflicts(target_list)
  end
end
local function light_up_beacons(target_list, _3fstart)
  for i = (_3fstart or 1), #target_list do
    local target = target_list[i]
    local _189_ = target.beacon
    if ((_G.type(_189_) == "table") and (nil ~= (_189_)[1]) and (nil ~= (_189_)[2])) then
      local offset = (_189_)[1]
      local virttext = (_189_)[2]
      local _let_190_ = map(dec, target.pos)
      local lnum = _let_190_[1]
      local col = _let_190_[2]
      api.nvim_buf_set_extmark(target.wininfo.bufnr, hl.ns, lnum, (col + offset), {virt_text = virttext, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.label})
    else
    end
  end
  return nil
end
local state = {["repeat"] = {in1 = nil, in2 = nil}, ["dot-repeat"] = {in1 = nil, in2 = nil, ["target-idx"] = nil, ["reverse?"] = nil, ["inclusive-op?"] = nil, ["offset?"] = nil}}
local function leap(_192_)
  local _arg_193_ = _192_
  local dot_repeat_3f = _arg_193_["dot-repeat?"]
  local target_windows = _arg_193_["target-windows"]
  local kwargs = _arg_193_
  local function _195_()
    if dot_repeat_3f then
      return state["dot-repeat"]
    else
      return kwargs
    end
  end
  local _let_194_ = _195_()
  local reverse_3f = _let_194_["reverse?"]
  local inclusive_op_3f = _let_194_["inclusive-op?"]
  local offset = _let_194_["offset"]
  local _3ftarget_windows
  do
    local _196_ = target_windows
    if (_G.type(_196_) == "table") then
      local t = _196_
      _3ftarget_windows = t
    elseif (_196_ == true) then
      _3ftarget_windows = get_other_windows_on_tabpage()
    else
      _3ftarget_windows = nil
    end
  end
  local bidirectional_3f = _3ftarget_windows
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and not bidirectional_3f and (vim.v.operator ~= "y"))
  local force_no_autojump_3f = (op_mode_3f or bidirectional_3f)
  local spec_keys
  local function _198_(_, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _198_})
  local function get_target_with_active_primary_label(sublist, input)
    local res = nil
    for idx, _199_ in ipairs(sublist) do
      local _each_200_ = _199_
      local label = _each_200_["label"]
      local label_state = _each_200_["label-state"]
      local target = _each_200_
      if (res or (label_state == "inactive")) then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      else
      end
    end
    return res
  end
  local function update_state(state_2a)
    if not dot_repeat_3f then
      if state_2a["repeat"] then
        state["repeat"] = state_2a["repeat"]
      else
      end
      if (state_2a["dot-repeat"] and dot_repeatable_op_3f) then
        state["dot-repeat"] = vim.tbl_extend("error", state_2a["dot-repeat"], {["reverse?"] = reverse_3f, offset = offset, ["inclusive-op?"] = inclusive_op_3f})
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _205_(target)
      jump_to_21_2a(target.pos, {winid = target.wininfo.winid, ["add-to-jumplist?"] = first_jump_3f, mode = mode, offset = offset, ["reverse?"] = reverse_3f, ["inclusive-op?"] = inclusive_op_3f})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _205_
  end
  local function traverse(targets, idx, _206_)
    local _arg_207_ = _206_
    local force_no_labels_3f = _arg_207_["force-no-labels?"]
    if force_no_labels_3f then
      inactivate_labels(targets)
    else
    end
    set_beacons(targets, {["force-no-labels?"] = force_no_labels_3f})
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        light_up_beacons(targets, inc(idx))
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local _209_
    local function _210_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _211_()
      if dot_repeatable_op_3f then
        set_dot_repeat()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _209_ = (_210_() or _211_())
    if (nil ~= _209_) then
      local input = _209_
      if ((input == spec_keys.next_match) or (input == spec_keys.prev_match)) then
        local new_idx
        do
          local _213_ = input
          if (_213_ == spec_keys.next_match) then
            new_idx = min(inc(idx), #targets)
          elseif (_213_ == spec_keys.prev_match) then
            new_idx = max(dec(idx), 1)
          else
            new_idx = nil
          end
        end
        update_state({["repeat"] = {in1 = state["repeat"].in1, in2 = targets[new_idx].pair[2]}})
        jump_to_21(targets[new_idx])
        return traverse(targets, new_idx, {["force-no-labels?"] = force_no_labels_3f})
      else
        local _215_ = get_target_with_active_primary_label(targets, input)
        if ((_G.type(_215_) == "table") and true and (nil ~= (_215_)[2])) then
          local _ = (_215_)[1]
          local target = (_215_)[2]
          if dot_repeatable_op_3f then
            set_dot_repeat()
          else
          end
          do
            jump_to_21(target)
          end
          exec_user_autocmds("LeapLeave")
          return nil
        elseif true then
          local _ = _215_
          if dot_repeatable_op_3f then
            set_dot_repeat()
          else
          end
          do
            vim.fn.feedkeys(input, "i")
          end
          exec_user_autocmds("LeapLeave")
          return nil
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  local function get_first_pattern_input()
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        echo("")
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local _221_
    local function _222_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _223_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _221_ = (_222_() or _223_())
    if (_221_ == spec_keys.repeat_search) then
      if state["repeat"].in1 then
        return state["repeat"].in1, state["repeat"].in2
      else
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_no_prev_search()
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
    elseif (nil ~= _221_) then
      local in1 = _221_
      return in1
    else
      return nil
    end
  end
  local function get_second_pattern_input(targets)
    do
      local _228_ = targets
      set_initial_label_states(_228_)
      set_beacons(_228_, {})
    end
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        light_up_beacons(targets)
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local function _229_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _230_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    return (_229_() or _230_())
  end
  local function post_pattern_input_loop(sublist)
    local function loop(group_offset, initial_invoc_3f)
      do
        local _232_ = sublist
        set_label_states(_232_, {["group-offset"] = group_offset})
        set_beacons(_232_, {})
      end
      do
        apply_backdrop(reverse_3f, _3ftarget_windows)
        do
          light_up_beacons(sublist)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _233_
      local function _234_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _235_()
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
      _233_ = (_234_() or _235_())
      if (nil ~= _233_) then
        local input = _233_
        if (((input == spec_keys.next_group) or ((input == spec_keys.prev_group) and not initial_invoc_3f)) and (not sublist["autojump?"] or user_forced_autojump_3f)) then
          local _7cgroups_7c = ceil((#sublist / #sublist["label-set"]))
          local max_offset = dec(_7cgroups_7c)
          local inc_2fdec
          if (input == spec_keys.next_group) then
            inc_2fdec = inc
          else
            inc_2fdec = dec
          end
          local new_offset = clamp(inc_2fdec(group_offset), 0, max_offset)
          return loop(new_offset, false)
        else
          return input
        end
      else
        return nil
      end
    end
    return loop(0, true)
  end
  exec_user_autocmds("LeapEnter")
  local function _240_(...)
    local _241_, _242_ = ...
    if ((nil ~= _241_) and true) then
      local in1 = _241_
      local _3fin2 = _242_
      local function _243_(...)
        local _244_ = ...
        if (nil ~= _244_) then
          local targets = _244_
          local function _245_(...)
            local _246_ = ...
            if (nil ~= _246_) then
              local in2 = _246_
              if dot_repeat_3f then
                local _247_ = targets[state["dot-repeat"]["target-idx"]]
                if (nil ~= _247_) then
                  local target = _247_
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    jump_to_21(target)
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                elseif true then
                  local _ = _247_
                  if change_op_3f then
                    handle_interrupted_change_op_21()
                  else
                  end
                  do
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return nil
                end
              elseif ((in2 == spec_keys.next_match) and not bidirectional_3f) then
                local in20 = targets[1].pair[2]
                update_state({["repeat"] = {in1 = in1, in2 = in20}})
                jump_to_21(targets[1])
                if (op_mode_3f or (#targets == 1)) then
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    update_state({["dot-repeat"] = {in1 = in1, in2 = in20, ["target-idx"] = 1}})
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return traverse(targets, 1, {["force-no-labels?"] = true})
                end
              else
                update_state({["repeat"] = {in1 = in1, in2 = in2}})
                local update_dot_repeat_state
                local function _253_(_241)
                  return update_state({["dot-repeat"] = {in1 = in1, in2 = in2, ["target-idx"] = _241}})
                end
                update_dot_repeat_state = _253_
                local _254_
                local function _255_(...)
                  if change_op_3f then
                    handle_interrupted_change_op_21()
                  else
                  end
                  do
                    echo_not_found((in1 .. in2))
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                end
                _254_ = (targets.sublists[in2] or _255_(...))
                if ((_G.type(_254_) == "table") and (nil ~= (_254_)[1]) and ((_254_)[2] == nil)) then
                  local only = (_254_)[1]
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    update_dot_repeat_state(1)
                    jump_to_21(only)
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                elseif (nil ~= _254_) then
                  local sublist = _254_
                  if sublist["autojump?"] then
                    jump_to_21(sublist[1])
                  else
                  end
                  local _259_ = post_pattern_input_loop(sublist)
                  local function _260_(...)
                    return not bidirectional_3f
                  end
                  if ((_259_ == spec_keys.next_match) and _260_(...)) then
                    local new_idx
                    if sublist["autojump?"] then
                      new_idx = 2
                    else
                      new_idx = 1
                    end
                    jump_to_21(sublist[new_idx])
                    if op_mode_3f then
                      if dot_repeatable_op_3f then
                        set_dot_repeat()
                      else
                      end
                      do
                        update_dot_repeat_state(1)
                      end
                      exec_user_autocmds("LeapLeave")
                      return nil
                    else
                      return traverse(sublist, new_idx, {["force-no-labels?"] = not sublist["autojump?"]})
                    end
                  elseif (nil ~= _259_) then
                    local input = _259_
                    local _264_ = get_target_with_active_primary_label(sublist, input)
                    if ((_G.type(_264_) == "table") and (nil ~= (_264_)[1]) and (nil ~= (_264_)[2])) then
                      local idx = (_264_)[1]
                      local target = (_264_)[2]
                      if dot_repeatable_op_3f then
                        set_dot_repeat()
                      else
                      end
                      do
                        update_dot_repeat_state(idx)
                        jump_to_21(target)
                      end
                      exec_user_autocmds("LeapLeave")
                      return nil
                    elseif true then
                      local _ = _264_
                      if sublist["autojump?"] then
                        if dot_repeatable_op_3f then
                          set_dot_repeat()
                        else
                        end
                        do
                          vim.fn.feedkeys(input, "i")
                        end
                        exec_user_autocmds("LeapLeave")
                        return nil
                      else
                        if change_op_3f then
                          handle_interrupted_change_op_21()
                        else
                        end
                        do
                        end
                        exec_user_autocmds("LeapLeave")
                        return nil
                      end
                    else
                      return nil
                    end
                  else
                    return nil
                  end
                else
                  return nil
                end
              end
            elseif true then
              local __60_auto = _246_
              return ...
            else
              return nil
            end
          end
          local function _274_(...)
            do
              local _275_ = targets
              populate_sublists(_275_)
              set_sublist_attributes(_275_, {["force-no-autojump?"] = force_no_autojump_3f})
              set_labels(_275_)
            end
            return (_3fin2 or get_second_pattern_input(targets))
          end
          return _245_(_274_(...))
        elseif true then
          local __60_auto = _244_
          return ...
        else
          return nil
        end
      end
      local function _277_(...)
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_not_found((in1 .. (_3fin2 or "")))
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
      return _243_((get_targets(in1, {["reverse?"] = reverse_3f, ["target-windows"] = _3ftarget_windows}) or _277_(...)))
    elseif true then
      local __60_auto = _241_
      return ...
    else
      return nil
    end
  end
  local function _280_()
    if dot_repeat_3f then
      return state["dot-repeat"].in1, state["dot-repeat"].in2
    else
      return get_first_pattern_input()
    end
  end
  return _240_(_280_())
end
local function set_default_keymaps(force_3f)
  for _, _281_ in ipairs({{"n", "s", "<Plug>(leap-forward)"}, {"n", "S", "<Plug>(leap-backward)"}, {"x", "s", "<Plug>(leap-forward)"}, {"x", "S", "<Plug>(leap-backward)"}, {"o", "z", "<Plug>(leap-forward)"}, {"o", "Z", "<Plug>(leap-backward)"}, {"o", "x", "<Plug>(leap-forward-x)"}, {"o", "X", "<Plug>(leap-backward-x)"}, {"n", "gs", "<Plug>(leap-cross-window)"}, {"x", "gs", "<Plug>(leap-cross-window)"}, {"o", "gs", "<Plug>(leap-cross-window)"}}) do
    local _each_282_ = _281_
    local mode = _each_282_[1]
    local lhs = _each_282_[2]
    local rhs = _each_282_[3]
    if (force_3f or ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0))) then
      vim.keymap.set(mode, lhs, rhs, {silent = true})
    else
    end
  end
  return nil
end
local temporary_editor_opts = {["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_284_ = vim.split(opt, ".", true)
    local _0 = _let_284_[1]
    local scope = _let_284_[2]
    local name = _let_284_[3]
    saved_editor_opts[opt] = _G.vim[scope][name]
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_285_ = vim.split(opt, ".", true)
    local _ = _let_285_[1]
    local scope = _let_285_[2]
    local name = _let_285_[3]
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
local function _286_()
  save_editor_opts()
  return set_temporary_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LeapEnter", callback = _286_, group = "LeapDefault"})
api.nvim_create_autocmd("User", {pattern = "LeapLeave", callback = restore_editor_opts, group = "LeapDefault"})
return {opts = opts, setup = setup, state = state, leap = leap, init_highlight = init_highlight, set_default_keymaps = set_default_keymaps}
