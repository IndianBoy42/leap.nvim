local hl = require("leap.highlight")
local opts = require("leap.opts")
local _local_1_ = require("leap.util")
local inc = _local_1_["inc"]
local dec = _local_1_["dec"]
local clamp = _local_1_["clamp"]
local echo = _local_1_["echo"]
local replace_keycodes = _local_1_["replace-keycodes"]
local get_cursor_pos = _local_1_["get-cursor-pos"]
local push_cursor_21 = _local_1_["push-cursor!"]
local get_eq_class_of = _local_1_["get-eq-class-of"]
local __3erepresentative_char = _local_1_["->representative-char"]
local get_input = _local_1_["get-input"]
local get_input_by_keymap = _local_1_["get-input-by-keymap"]
local api = vim.api
local contains_3f = vim.tbl_contains
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local _local_2_ = math
local abs = _local_2_["abs"]
local ceil = _local_2_["ceil"]
local max = _local_2_["max"]
local min = _local_2_["min"]
local pow = _local_2_["pow"]
local function exec_user_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {pattern = pattern, modeline = false})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _3_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _3_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
end
local function set_dot_repeat_2a()
  local op = vim.v.operator
  local cmd = replace_keycodes("<cmd>lua require'leap'.leap { dot_repeat = true }<cr>")
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
local function eq_classes__3emembership_lookup(eqcls)
  local res = {}
  for _, eqcl in ipairs(eqcls) do
    local eqcl_2a
    if (type(eqcl) == "string") then
      eqcl_2a = vim.fn.split(eqcl, "\\zs")
    else
      eqcl_2a = eqcl
    end
    for _0, ch in ipairs(eqcl_2a) do
      res[ch] = eqcl_2a
    end
  end
  return res
end
local function set_autojump(targets, force_noautojump_3f)
  targets["autojump?"] = (not (force_noautojump_3f or empty_3f(opts.safe_labels)) and (empty_3f(opts.labels) or (#opts.safe_labels >= dec(#targets))))
  return nil
end
local function attach_label_set(targets)
  local _6_
  if empty_3f(opts.labels) then
    _6_ = opts.safe_labels
  elseif empty_3f(opts.safe_labels) then
    _6_ = opts.labels
  elseif targets["autojump?"] then
    _6_ = opts.safe_labels
  else
    _6_ = opts.labels
  end
  targets["label-set"] = _6_
  return nil
end
local function set_labels(targets, multi_select_3f)
  if ((#targets > 1) or multi_select_3f) then
    local _local_8_ = targets
    local autojump_3f = _local_8_["autojump?"]
    local label_set = _local_8_["label-set"]
    for i, target in ipairs(targets) do
      local i_2a
      if autojump_3f then
        i_2a = dec(i)
      else
        i_2a = i
      end
      if (i_2a > 0) then
        local _11_
        do
          local _10_ = (i_2a % #label_set)
          if (_10_ == 0) then
            _11_ = label_set[#label_set]
          elseif (nil ~= _10_) then
            local n = _10_
            _11_ = label_set[n]
          else
            _11_ = nil
          end
        end
        target["label"] = _11_
      else
      end
    end
    return nil
  else
    return nil
  end
end
local function set_label_states(targets, _17_)
  local _arg_18_ = _17_
  local group_offset = _arg_18_["group-offset"]
  local _7clabel_set_7c = #targets["label-set"]
  local offset = (group_offset * _7clabel_set_7c)
  local primary_start
  local function _19_()
    if targets["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _19_())
  local primary_end = (primary_start + dec(_7clabel_set_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabel_set_7c)
  for i, target in ipairs(targets) do
    if (target.label and (target["label-state"] ~= "selected")) then
      local _20_
      if (function(_21_,_22_,_23_) return (_21_ <= _22_) and (_22_ <= _23_) end)(primary_start,i,primary_end) then
        _20_ = "active-primary"
      elseif (function(_24_,_25_,_26_) return (_24_ <= _25_) and (_25_ <= _26_) end)(secondary_start,i,secondary_end) then
        _20_ = "active-secondary"
      elseif (i > secondary_end) then
        _20_ = "inactive"
      else
        _20_ = nil
      end
      target["label-state"] = _20_
    else
    end
  end
  return nil
end
local function inactivate_labels(targets)
  for _, target in ipairs(targets) do
    target["label-state"] = "inactive"
  end
  return nil
end
local function populate_sublists(targets)
  local function _29_(self, ch)
    return rawget(self, __3erepresentative_char(ch))
  end
  local function _30_(self, ch, sublist)
    return rawset(self, __3erepresentative_char(ch), sublist)
  end
  targets["sublists"] = setmetatable({}, {__index = _29_, __newindex = _30_})
  for _, _31_ in ipairs(targets) do
    local _each_32_ = _31_
    local _each_33_ = _each_32_["chars"]
    local _0 = _each_33_[1]
    local ch2 = _each_33_[2]
    local target = _each_32_
    local ch20 = (ch2 or "\n")
    if not targets.sublists[ch20] then
      targets.sublists[ch20] = {}
    else
    end
    table.insert(targets.sublists[ch20], target)
  end
  return nil
end
local function set_initial_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function get_label_offset(target)
  local _let_35_ = target
  local _let_36_ = _let_35_["chars"]
  local ch1 = _let_36_[1]
  local ch2 = _let_36_[2]
  if target["empty-line?"] then
    return 0
  elseif target["edge-pos?"] then
    return ch1:len()
  else
    return (ch1:len() + ch2:len())
  end
end
local function set_beacon_for_labeled(target, _38_)
  local _arg_39_ = _38_
  local user_given_targets_3f = _arg_39_["user-given-targets?"]
  local aot_3f = _arg_39_["aot?"]
  local offset
  if aot_3f then
    offset = get_label_offset(target)
  else
    offset = 0
  end
  local pad
  if (user_given_targets_3f or aot_3f) then
    pad = ""
  else
    pad = " "
  end
  local label = (opts.substitute_chars[target.label] or target.label)
  local text = (label .. pad)
  local virttext
  do
    local _42_ = target["label-state"]
    if (_42_ == "selected") then
      virttext = {{text, hl.group["label-selected"]}}
    elseif (_42_ == "active-primary") then
      virttext = {{text, hl.group["label-primary"]}}
    elseif (_42_ == "active-secondary") then
      virttext = {{text, hl.group["label-secondary"]}}
    elseif (_42_ == "inactive") then
      if (aot_3f and not opts.highlight_unlabeled_phase_one_targets) then
        virttext = {{(" " .. pad), hl.group["label-secondary"]}}
      elseif "else" then
        virttext = nil
      else
        virttext = nil
      end
    else
      virttext = nil
    end
  end
  local _45_
  if virttext then
    _45_ = {offset, virttext}
  else
    _45_ = nil
  end
  target["beacon"] = _45_
  return nil
end
local function set_beacon_to_match_hl(target)
  local virttext
  local function _47_(_241)
    return (opts.substitute_chars[_241] or _241)
  end
  virttext = table.concat(map(_47_, target.chars))
  do end (target)["beacon"] = {0, {{virttext, hl.group.match}}}
  return nil
end
local function set_beacon_to_empty_label(target)
  target["beacon"][2][1][1] = " "
  return nil
end
local function resolve_conflicts(targets)
  local pos_unlabeled_match = {}
  local pos_labeled_match = {}
  local pos_label = {}
  for _, target in ipairs(targets) do
    if not target["empty-line?"] then
      local _local_48_ = target.wininfo
      local bufnr = _local_48_["bufnr"]
      local winid = _local_48_["winid"]
      local _local_49_ = target.pos
      local lnum = _local_49_[1]
      local col = _local_49_[2]
      local col_ch2 = (col + string.len(target.chars[1]))
      if (target.label and target.beacon) then
        local label_offset = target.beacon[1]
        local col_label = (col + label_offset)
        local shifted_label_3f = (col_label == col_ch2)
        do
          local _50_ = pos_unlabeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)]
          if (nil ~= _50_) then
            local other = _50_
            target.beacon = nil
            set_beacon_to_match_hl(other)
          else
          end
        end
        if shifted_label_3f then
          local _52_ = pos_unlabeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col)]
          if (nil ~= _52_) then
            local other = _52_
            set_beacon_to_match_hl(other)
          else
          end
        else
        end
        do
          local _55_ = pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)]
          if (nil ~= _55_) then
            local other = _55_
            target.beacon = nil
            set_beacon_to_empty_label(other)
          else
          end
        end
        pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_label)] = target
        pos_labeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col)] = target
        if not shifted_label_3f then
          pos_labeled_match[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_ch2)] = target
        else
        end
      elseif not target.label then
        for _0, key in ipairs({(bufnr .. " " .. winid .. " " .. lnum .. " " .. col), (bufnr .. " " .. winid .. " " .. lnum .. " " .. col_ch2)}) do
          pos_unlabeled_match[key] = target
          local _58_ = pos_label[key]
          if (nil ~= _58_) then
            local other = _58_
            other.beacon = nil
            set_beacon_to_match_hl(target)
          else
          end
        end
        local col_after = (col_ch2 + string.len(target.chars[2]))
        local _60_ = pos_label[(bufnr .. " " .. winid .. " " .. lnum .. " " .. col_after)]
        if (nil ~= _60_) then
          local other = _60_
          set_beacon_to_match_hl(target)
        else
        end
      else
      end
    else
    end
  end
  return nil
end
local function set_beacons(targets, _64_)
  local _arg_65_ = _64_
  local no_labels_3f = _arg_65_["no-labels?"]
  local user_given_targets_3f = _arg_65_["user-given-targets?"]
  local aot_3f = _arg_65_["aot?"]
  if (no_labels_3f and targets[1].chars) then
    for _, target in ipairs(targets) do
      set_beacon_to_match_hl(target)
    end
    return nil
  else
    for _, target in ipairs(targets) do
      if target.label then
        set_beacon_for_labeled(target, {["user-given-targets?"] = user_given_targets_3f, ["aot?"] = aot_3f})
      elseif (aot_3f and opts.highlight_unlabeled_phase_one_targets) then
        set_beacon_to_match_hl(target)
      else
      end
    end
    if aot_3f then
      return resolve_conflicts(targets)
    else
      return nil
    end
  end
end
local function light_up_beacons(targets, _3fstart, _3fend)
  for i = (_3fstart or 1), (_3fend or #targets) do
    local target = targets[i]
    local _69_ = target.beacon
    if ((_G.type(_69_) == "table") and (nil ~= (_69_)[1]) and (nil ~= (_69_)[2])) then
      local offset = (_69_)[1]
      local virttext = (_69_)[2]
      local bufnr = target.wininfo.bufnr
      local _let_70_ = map(dec, target.pos)
      local lnum = _let_70_[1]
      local col = _let_70_[2]
      local id = api.nvim_buf_set_extmark(bufnr, hl.ns, lnum, (col + offset), {virt_text = virttext, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.label})
      table.insert(hl.extmarks, {bufnr, id})
    else
    end
  end
  return nil
end
local state = {args = nil, source_window = nil, ["repeat"] = {in1 = nil, in2 = nil}, dot_repeat = {in1 = nil, in2 = nil, target_idx = nil, backward = nil, inclusive_op = nil, offset = nil}, saved_editor_opts = {}}
local function leap(kwargs)
  local _let_72_ = kwargs
  local dot_repeat_3f = _let_72_["dot_repeat"]
  local target_windows = _let_72_["target_windows"]
  local user_given_opts = _let_72_["opts"]
  local user_given_targets = _let_72_["targets"]
  local user_given_action = _let_72_["action"]
  local multi_select_3f = _let_72_["multiselect"]
  local function _74_()
    if dot_repeat_3f then
      return state.dot_repeat
    else
      return kwargs
    end
  end
  local _let_73_ = _74_()
  local backward_3f = _let_73_["backward"]
  local match_last_overlapping_3f = _let_73_["match_last_overlapping"]
  local inclusive_op_3f = _let_73_["inclusive_op"]
  local offset = _let_73_["offset"]
  local _
  state.args = kwargs
  _ = nil
  local _0
  opts.current_call = (user_given_opts or {})
  _0 = nil
  local _1
  local _76_
  do
    local _75_ = opts.current_call.equivalence_classes
    if (nil ~= _75_) then
      _76_ = eq_classes__3emembership_lookup(_75_)
    else
      _76_ = _75_
    end
  end
  opts.current_call["eq_class_of"] = _76_
  _1 = nil
  local id__3ewininfo
  local function _78_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  id__3ewininfo = _78_
  local curr_winid = vim.fn.win_getid()
  local _2
  state.source_window = curr_winid
  _2 = nil
  local curr_win = id__3ewininfo(curr_winid)
  local _3ftarget_windows
  do
    local _79_ = target_windows
    if (_79_ ~= nil) then
      _3ftarget_windows = map(id__3ewininfo, _79_)
    else
      _3ftarget_windows = _79_
    end
  end
  local hl_affected_windows
  do
    local tbl_17_auto = {curr_win}
    local i_18_auto = #tbl_17_auto
    for _3, w in ipairs((_3ftarget_windows or {})) do
      local val_19_auto = w
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    hl_affected_windows = tbl_17_auto
  end
  local directional_3f = not target_windows
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and directional_3f and (vim.v.operator ~= "y"))
  local no_labels_3f = (empty_3f(opts.labels) and empty_3f(opts.safe_labels))
  local count
  if not directional_3f then
    count = nil
  elseif (vim.v.count == 0) then
    if (op_mode_3f and no_labels_3f) then
      count = 1
    else
      count = nil
    end
  else
    count = vim.v.count
  end
  local force_noautojump_3f = (op_mode_3f or multi_select_3f or not directional_3f or user_given_action)
  local max_phase_one_targets = (opts.max_phase_one_targets or math.huge)
  local user_given_targets_3f = user_given_targets
  local prompt = {str = ">"}
  local spec_keys
  local function _84_(_3, k)
    local _85_ = opts.special_keys[k]
    if (nil ~= _85_) then
      local v = _85_
      if ((k == "next_target") or (k == "prev_target")) then
        local _86_ = type(v)
        if (_86_ == "table") then
          local tbl_17_auto = {}
          local i_18_auto = #tbl_17_auto
          for _4, str in ipairs(v) do
            local val_19_auto = replace_keycodes(str)
            if (nil ~= val_19_auto) then
              i_18_auto = (i_18_auto + 1)
              do end (tbl_17_auto)[i_18_auto] = val_19_auto
            else
            end
          end
          return tbl_17_auto
        elseif (_86_ == "string") then
          return {replace_keycodes(v)}
        else
          return nil
        end
      else
        return replace_keycodes(v)
      end
    else
      return nil
    end
  end
  spec_keys = setmetatable({}, {__index = _84_})
  if (target_windows and empty_3f(target_windows)) then
    echo("no targetable windows")
    return
  else
  end
  if (not directional_3f and no_labels_3f) then
    echo("no labels to use")
    return
  else
  end
  local aot_3f = not ((max_phase_one_targets == 0) or count or no_labels_3f or multi_select_3f or user_given_targets_3f)
  local current_idx = 0
  local function echo_not_found(s)
    return echo(("not found: " .. s))
  end
  local function fill_wininfo(targets)
    if not empty_3f(targets) then
      if not targets[1].wininfo then
        for _3, t in ipairs(targets) do
          t.wininfo = curr_win
        end
      else
      end
      return targets
    else
      return nil
    end
  end
  local function get_user_given_targets(targets)
    local _95_
    do
      local _96_ = targets
      if (_G.type(_96_) == "table") then
        local tbl = _96_
        _95_ = tbl
      elseif (nil ~= _96_) then
        local func = _96_
        _95_ = func()
      else
        _95_ = nil
      end
    end
    if (nil ~= _95_) then
      return fill_wininfo(_95_)
    else
      return _95_
    end
  end
  local function expand_to_equivalence_class(_in)
    local _99_ = get_eq_class_of(_in)
    if (nil ~= _99_) then
      local chars = _99_
      local chars_2a
      local function _100_(_241)
        local _101_ = _241
        if (_101_ == "\n") then
          return "\\n"
        elseif (_101_ == "\\") then
          return "\\\\"
        elseif true then
          local _3 = _101_
          return _241
        else
          return nil
        end
      end
      chars_2a = map(_100_, chars)
      return ("\\(" .. table.concat(chars_2a, "\\|") .. "\\)")
    else
      return nil
    end
  end
  local function prepare_pattern(in1, _3fin2)
    local function _104_()
      if opts.case_sensitive then
        return "\\C"
      else
        return "\\c"
      end
    end
    local function _105_()
      local _106_ = _3fin2
      if (nil ~= _106_) then
        return expand_to_equivalence_class(_106_)
      else
        return _106_
      end
    end
    return ("\\V" .. _104_() .. (expand_to_equivalence_class(in1) or in1:gsub("\\", "\\\\")) .. (_105_() or _3fin2 or "\\_."))
  end
  local function get_target_with_active_primary_label(sublist, input)
    local res = nil
    for idx, _108_ in ipairs(sublist) do
      local _each_109_ = _108_
      local label = _each_109_["label"]
      local label_state = _each_109_["label-state"]
      local target = _each_109_
      if (res or (label_state == "inactive")) then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      else
      end
    end
    return res
  end
  local function update_repeat_state(state_2a)
    if not user_given_targets_3f then
      state["repeat"] = state_2a
      return nil
    else
      return nil
    end
  end
  local function set_dot_repeat(in1, in2, target_idx)
    if (dot_repeatable_op_3f and not (dot_repeat_3f or (type(user_given_targets) == "table"))) then
      local function _112_()
        if user_given_targets then
          return {callback = user_given_targets}
        else
          return {in1 = in1, in2 = in2}
        end
      end
      state.dot_repeat = vim.tbl_extend("error", {target_idx = target_idx, backward = backward_3f, inclusive_op = inclusive_op_3f, offset = offset}, _112_())
      return set_dot_repeat_2a()
    else
      return nil
    end
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _114_(target)
      local jump = require("leap.jump")
      jump["jump-to!"](target.pos, {winid = target.wininfo.winid, ["add-to-jumplist?"] = first_jump_3f, mode = mode, offset = offset, ["backward?"] = backward_3f, ["inclusive-op?"] = inclusive_op_3f})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _114_
  end
  local function get_number_of_highlighted_targets()
    local _115_ = opts.max_highlighted_traversal_targets
    if (nil ~= _115_) then
      local group_size = _115_
      local consumed = (dec(current_idx) % group_size)
      local remaining = (group_size - consumed)
      if (remaining == 1) then
        return inc(group_size)
      elseif (remaining == 0) then
        return group_size
      else
        return remaining
      end
    else
      return nil
    end
  end
  local function get_highlighted_idx_range(targets, no_labels_3f0)
    if (no_labels_3f0 and (opts.max_highlighted_traversal_targets == 0)) then
      return 0, -1
    else
      local start = inc(current_idx)
      local _end
      if no_labels_3f0 then
        local _118_ = get_number_of_highlighted_targets()
        if (nil ~= _118_) then
          local _119_ = (_118_ + dec(start))
          if (nil ~= _119_) then
            _end = min(_119_, #targets)
          else
            _end = _119_
          end
        else
          _end = _118_
        end
      else
        _end = nil
      end
      return start, _end
    end
  end
  local function get_first_pattern_input()
    do
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        echo("")
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    end
    local _125_
    local function _126_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _125_ = (get_input_by_keymap(prompt) or _126_())
    if (_125_ == spec_keys.repeat_search) then
      if state["repeat"].in1 then
        aot_3f = false
        return state["repeat"].in1, state["repeat"].in2
      else
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo("no previous search")
        end
        hl:cleanup(hl_affected_windows)
        exec_user_autocmds("LeapLeave")
        return nil
      end
    elseif (nil ~= _125_) then
      local in1 = _125_
      return in1
    else
      return nil
    end
  end
  local function get_second_pattern_input(targets)
    if (#targets <= max_phase_one_targets) then
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        light_up_beacons(targets)
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    else
    end
    local function _133_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return nil
    end
    return (get_input_by_keymap(prompt) or _133_())
  end
  local function get_full_pattern_input()
    local _135_, _136_ = get_first_pattern_input()
    if ((nil ~= _135_) and (nil ~= _136_)) then
      local in1 = _135_
      local in2 = _136_
      return in1, in2
    elseif ((nil ~= _135_) and (_136_ == nil)) then
      local in1 = _135_
      local _137_ = get_input_by_keymap(prompt)
      if (nil ~= _137_) then
        local in2 = _137_
        return in1, in2
      elseif true then
        local _3 = _137_
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        hl:cleanup(hl_affected_windows)
        exec_user_autocmds("LeapLeave")
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function post_pattern_input_loop(targets, _3fgroup_offset, first_invoc_3f)
    local function loop(group_offset, first_invoc_3f0)
      if targets["label-set"] then
        set_label_states(targets, {["group-offset"] = group_offset})
      else
      end
      set_beacons(targets, {["aot?"] = aot_3f, ["no-labels?"] = no_labels_3f, ["user-given-targets?"] = user_given_targets_3f})
      do
        hl:cleanup(hl_affected_windows)
        if not count then
          hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
        else
        end
        do
          local start, _end = get_highlighted_idx_range(targets, no_labels_3f)
          light_up_beacons(targets, start, _end)
        end
        hl["highlight-cursor"](hl)
        vim.cmd("redraw")
      end
      local _143_
      local function _144_()
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        hl:cleanup(hl_affected_windows)
        exec_user_autocmds("LeapLeave")
        return nil
      end
      _143_ = (get_input() or _144_())
      if (nil ~= _143_) then
        local input = _143_
        if (((input == spec_keys.next_group) or ((input == spec_keys.prev_group) and not first_invoc_3f0)) and (not targets["autojump?"] or empty_3f(opts.labels))) then
          local inc_2fdec
          if (input == spec_keys.next_group) then
            inc_2fdec = inc
          else
            inc_2fdec = dec
          end
          local _7cgroups_7c = ceil((#targets / #targets["label-set"]))
          local max_offset = dec(_7cgroups_7c)
          local group_offset_2a = clamp(inc_2fdec(group_offset), 0, max_offset)
          return loop(group_offset_2a, false)
        else
          return input, group_offset
        end
      else
        return nil
      end
    end
    return loop((_3fgroup_offset or 0), ((nil == first_invoc_3f) or first_invoc_3f))
  end
  local multi_select_loop
  do
    local selection = {}
    local group_offset = 0
    local first_invoc_3f = true
    local function loop(targets)
      local _149_, _150_ = post_pattern_input_loop(targets, group_offset, first_invoc_3f)
      if (_149_ == spec_keys.multi_accept) then
        if next(selection) then
          return selection
        else
          return loop(targets)
        end
      elseif (_149_ == spec_keys.multi_revert) then
        do
          local _152_ = table.remove(selection)
          if (nil ~= _152_) then
            _152_["label-state"] = nil
          else
          end
        end
        return loop(targets)
      elseif ((nil ~= _149_) and (nil ~= _150_)) then
        local _in = _149_
        local group_offset_2a = _150_
        group_offset = group_offset_2a
        first_invoc_3f = false
        do
          local _154_ = get_target_with_active_primary_label(targets, _in)
          if ((_G.type(_154_) == "table") and true and (nil ~= (_154_)[2])) then
            local _3 = (_154_)[1]
            local target = (_154_)[2]
            if not contains_3f(selection, target) then
              table.insert(selection, target)
              do end (target)["label-state"] = "selected"
            else
            end
          else
          end
        end
        return loop(targets)
      else
        return nil
      end
    end
    multi_select_loop = loop
  end
  local function traversal_loop(targets, idx, _158_)
    local _arg_159_ = _158_
    local no_labels_3f0 = _arg_159_["no-labels?"]
    current_idx = idx
    if no_labels_3f0 then
      inactivate_labels(targets)
    else
    end
    set_beacons(targets, {["no-labels?"] = no_labels_3f0, ["aot?"] = aot_3f, ["user-given-targets?"] = user_given_targets_3f})
    do
      hl:cleanup(hl_affected_windows)
      if not count then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        local start, _end = get_highlighted_idx_range(targets, no_labels_3f0)
        light_up_beacons(targets, start, _end)
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    end
    local _162_
    local function _163_()
      do
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _162_ = (get_input() or _163_())
    if (nil ~= _162_) then
      local input = _162_
      local _164_
      if contains_3f(spec_keys.next_target, input) then
        _164_ = min(inc(idx), #targets)
      elseif contains_3f(spec_keys.prev_target, input) then
        _164_ = max(dec(idx), 1)
      else
        _164_ = nil
      end
      if (nil ~= _164_) then
        local new_idx = _164_
        local _167_
        do
          local t_166_ = targets
          if (nil ~= t_166_) then
            t_166_ = (t_166_)[new_idx]
          else
          end
          if (nil ~= t_166_) then
            t_166_ = (t_166_).chars
          else
          end
          if (nil ~= t_166_) then
            t_166_ = (t_166_)[2]
          else
          end
          _167_ = t_166_
        end
        update_repeat_state({in1 = state["repeat"].in1, in2 = _167_})
        jump_to_21(targets[new_idx])
        return traversal_loop(targets, new_idx, {["no-labels?"] = no_labels_3f0})
      elseif true then
        local _3 = _164_
        local _171_ = get_target_with_active_primary_label(targets, input)
        if ((_G.type(_171_) == "table") and true and (nil ~= (_171_)[2])) then
          local _4 = (_171_)[1]
          local target = (_171_)[2]
          do
            jump_to_21(target)
          end
          hl:cleanup(hl_affected_windows)
          exec_user_autocmds("LeapLeave")
          return nil
        elseif true then
          local _4 = _171_
          do
            vim.fn.feedkeys(input, "i")
          end
          hl:cleanup(hl_affected_windows)
          exec_user_autocmds("LeapLeave")
          return nil
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
  local do_action = (user_given_action or jump_to_21)
  exec_user_autocmds("LeapEnter")
  local function _175_(...)
    local _176_, _177_ = ...
    if ((nil ~= _176_) and true) then
      local in1 = _176_
      local _3fin2 = _177_
      local function _178_(...)
        local _179_ = ...
        if (nil ~= _179_) then
          local targets = _179_
          local function _180_(...)
            local _181_ = ...
            if (nil ~= _181_) then
              local in2 = _181_
              if (in2 == spec_keys.next_phase_one_target) then
                local in20 = targets[1].chars[2]
                update_repeat_state({in1 = in1, in2 = in20})
                do_action(targets[1])
                if ((#targets == 1) or op_mode_3f or not directional_3f or user_given_action) then
                  do
                    set_dot_repeat(in1, in20, 1)
                  end
                  hl:cleanup(hl_affected_windows)
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return traversal_loop(targets, 1, {["no-labels?"] = true})
                end
              else
                update_repeat_state({in1 = in1, in2 = in2})
                local _183_
                local function _184_(...)
                  if targets.sublists then
                    return targets.sublists[in2]
                  else
                    return targets
                  end
                end
                local function _185_(...)
                  if change_op_3f then
                    handle_interrupted_change_op_21()
                  else
                  end
                  do
                    echo_not_found((in1 .. in2))
                  end
                  hl:cleanup(hl_affected_windows)
                  exec_user_autocmds("LeapLeave")
                  return nil
                end
                _183_ = (_184_(...) or _185_(...))
                if (nil ~= _183_) then
                  local targets_2a = _183_
                  if multi_select_3f then
                    local _187_ = multi_select_loop(targets_2a)
                    if (nil ~= _187_) then
                      local targets_2a_2a = _187_
                      do
                        do
                          hl:cleanup(hl_affected_windows)
                          if not count then
                            hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
                          else
                          end
                          do
                            light_up_beacons(targets_2a_2a)
                          end
                          hl["highlight-cursor"](hl)
                          vim.cmd("redraw")
                        end
                        do_action(targets_2a_2a)
                      end
                      hl:cleanup(hl_affected_windows)
                      exec_user_autocmds("LeapLeave")
                      return nil
                    else
                      return nil
                    end
                  else
                    local exit_with_action
                    local function _190_(idx)
                      do
                        set_dot_repeat(in1, in2, idx)
                        do_action((targets_2a)[idx])
                      end
                      hl:cleanup(hl_affected_windows)
                      exec_user_autocmds("LeapLeave")
                      return nil
                    end
                    exit_with_action = _190_
                    local _7ctargets_2a_7c = #targets_2a
                    if count then
                      if (count <= _7ctargets_2a_7c) then
                        return exit_with_action(count)
                      else
                        if change_op_3f then
                          handle_interrupted_change_op_21()
                        else
                        end
                        do
                        end
                        hl:cleanup(hl_affected_windows)
                        exec_user_autocmds("LeapLeave")
                        return nil
                      end
                    elseif (_7ctargets_2a_7c == 1) then
                      return exit_with_action(1)
                    else
                      if targets_2a["autojump?"] then
                        current_idx = 1
                        do_action((targets_2a)[1])
                      else
                      end
                      local _194_ = post_pattern_input_loop(targets_2a)
                      if (nil ~= _194_) then
                        local in_final = _194_
                        if contains_3f(spec_keys.next_target, in_final) then
                          if (op_mode_3f or not directional_3f or user_given_action) then
                            return exit_with_action(1)
                          else
                            local new_idx = inc(current_idx)
                            do_action((targets_2a)[new_idx])
                            if (empty_3f(opts.labels) and not empty_3f(opts.safe_labels)) then
                              for i = (#opts.safe_labels + 2), _7ctargets_2a_7c do
                                targets_2a[i]["label"] = nil
                                targets_2a[i]["beacon"] = nil
                              end
                            else
                            end
                            return traversal_loop(targets_2a, new_idx, {["no-labels?"] = (no_labels_3f or not targets_2a["autojump?"])})
                          end
                        else
                          local _197_ = get_target_with_active_primary_label(targets_2a, in_final)
                          if ((_G.type(_197_) == "table") and (nil ~= (_197_)[1]) and true) then
                            local idx = (_197_)[1]
                            local _3 = (_197_)[2]
                            return exit_with_action(idx)
                          elseif true then
                            local _3 = _197_
                            if targets_2a["autojump?"] then
                              do
                                vim.fn.feedkeys(in_final, "i")
                              end
                              hl:cleanup(hl_affected_windows)
                              exec_user_autocmds("LeapLeave")
                              return nil
                            else
                              if change_op_3f then
                                handle_interrupted_change_op_21()
                              else
                              end
                              do
                              end
                              hl:cleanup(hl_affected_windows)
                              exec_user_autocmds("LeapLeave")
                              return nil
                            end
                          else
                            return nil
                          end
                        end
                      else
                        return nil
                      end
                    end
                  end
                else
                  return nil
                end
              end
            elseif true then
              local __63_auto = _181_
              return ...
            else
              return nil
            end
          end
          local function _216_(...)
            if dot_repeat_3f then
              local _208_ = targets[state.dot_repeat.target_idx]
              if (nil ~= _208_) then
                local target = _208_
                do
                  do_action(target)
                end
                hl:cleanup(hl_affected_windows)
                exec_user_autocmds("LeapLeave")
                return nil
              elseif true then
                local _3 = _208_
                if change_op_3f then
                  handle_interrupted_change_op_21()
                else
                end
                do
                end
                hl:cleanup(hl_affected_windows)
                exec_user_autocmds("LeapLeave")
                return nil
              else
                return nil
              end
            else
              local prepare_targets
              local function _211_(_241)
                set_autojump(_241, force_noautojump_3f)
                attach_label_set(_241)
                set_labels(_241, multi_select_3f)
                return _241
              end
              prepare_targets = _211_
              if _3fin2 then
                if no_labels_3f then
                  targets["autojump?"] = true
                else
                  prepare_targets(targets)
                end
              else
                populate_sublists(targets)
                for _3, sublist in pairs(targets.sublists) do
                  prepare_targets(sublist)
                end
              end
              if (#targets > max_phase_one_targets) then
                aot_3f = false
              else
              end
              local function _215_(...)
                do
                  set_initial_label_states(targets)
                  set_beacons(targets, {["aot?"] = aot_3f})
                end
                return get_second_pattern_input(targets)
              end
              return (_3fin2 or _215_(...))
            end
          end
          return _180_(_216_(...))
        elseif true then
          local __63_auto = _179_
          return ...
        else
          return nil
        end
      end
      local function _223_(...)
        if (dot_repeat_3f and state.dot_repeat.callback) then
          return get_user_given_targets(state.dot_repeat.callback)
        elseif user_given_targets_3f then
          local function _218_(...)
            if change_op_3f then
              handle_interrupted_change_op_21()
            else
            end
            do
              echo("no targets")
            end
            hl:cleanup(hl_affected_windows)
            exec_user_autocmds("LeapLeave")
            return nil
          end
          return (get_user_given_targets(user_given_targets) or _218_(...))
        else
          local function _220_(...)
            local search = require("leap.search")
            local pattern = prepare_pattern(in1, _3fin2)
            local kwargs0 = {["backward?"] = backward_3f, ["match-last-overlapping?"] = match_last_overlapping_3f, ["target-windows"] = _3ftarget_windows}
            return search["get-targets"](pattern, kwargs0)
          end
          local function _221_(...)
            if change_op_3f then
              handle_interrupted_change_op_21()
            else
            end
            do
              echo_not_found((in1 .. (_3fin2 or "")))
            end
            hl:cleanup(hl_affected_windows)
            exec_user_autocmds("LeapLeave")
            return nil
          end
          return (_220_(...) or _221_(...))
        end
      end
      return _178_(_223_(...))
    elseif true then
      local __63_auto = _176_
      return ...
    else
      return nil
    end
  end
  local function _226_()
    if dot_repeat_3f then
      if state.dot_repeat.callback then
        return true, true
      else
        return state.dot_repeat.in1, state.dot_repeat.in2
      end
    elseif user_given_targets_3f then
      return true, true
    elseif aot_3f then
      return get_first_pattern_input()
    else
      return get_full_pattern_input()
    end
  end
  return _175_(_226_())
end
local _228_
do
  local _227_ = opts.default.equivalence_classes
  if (nil ~= _227_) then
    _228_ = eq_classes__3emembership_lookup(_227_)
  else
    _228_ = _227_
  end
end
opts.default["eq_class_of"] = _228_
api.nvim_create_augroup("LeapDefault", {})
hl["init-highlight"](hl)
local function _230_()
  return hl["init-highlight"](hl)
end
api.nvim_create_autocmd("ColorScheme", {callback = _230_, group = "LeapDefault"})
local function set_editor_opts(t)
  state.saved_editor_opts = {}
  local wins = (state.args.target_windows or {state.source_window})
  for opt, val in pairs(t) do
    local _let_231_ = vim.split(opt, ".", {plain = true})
    local scope = _let_231_[1]
    local name = _let_231_[2]
    local _232_ = scope
    if (_232_ == "w") then
      for _, w in ipairs(wins) do
        state.saved_editor_opts[{"w", w, name}] = api.nvim_win_get_option(w, name)
        api.nvim_win_set_option(w, name, val)
      end
    elseif (_232_ == "b") then
      for _, w in ipairs(wins) do
        local b = api.nvim_win_get_buf(w)
        do end (state.saved_editor_opts)[{"b", b, name}] = api.nvim_buf_get_option(b, name)
        api.nvim_buf_set_option(b, name, val)
      end
    elseif true then
      local _ = _232_
      state.saved_editor_opts[name] = api.nvim_get_option(name)
      api.nvim_set_option(name, val)
    else
    end
  end
  return nil
end
local function restore_editor_opts()
  for key, val in pairs(state.saved_editor_opts) do
    local _234_ = key
    if ((_G.type(_234_) == "table") and ((_234_)[1] == "w") and (nil ~= (_234_)[2]) and (nil ~= (_234_)[3])) then
      local w = (_234_)[2]
      local name = (_234_)[3]
      api.nvim_win_set_option(w, name, val)
    elseif ((_G.type(_234_) == "table") and ((_234_)[1] == "b") and (nil ~= (_234_)[2]) and (nil ~= (_234_)[3])) then
      local b = (_234_)[2]
      local name = (_234_)[3]
      api.nvim_buf_set_option(b, name, val)
    elseif (nil ~= _234_) then
      local name = _234_
      api.nvim_set_option(name, val)
    else
    end
  end
  return nil
end
local temporary_editor_opts = {["w.conceallevel"] = 0, ["g.scrolloff"] = 0, ["w.scrolloff"] = 0, ["g.sidescrolloff"] = 0, ["w.sidescrolloff"] = 0, ["b.modeline"] = false}
local function _236_()
  return set_editor_opts(temporary_editor_opts)
end
api.nvim_create_autocmd("User", {pattern = "LeapEnter", callback = _236_, group = "LeapDefault"})
local function _237_()
  return restore_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LeapLeave", callback = _237_, group = "LeapDefault"})
return {state = state, leap = leap}
