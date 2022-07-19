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
local _3cbs_3e = replace_keycodes("<bs>")
local _3ccr_3e = replace_keycodes("<cr>")
local _3cesc_3e = replace_keycodes("<esc>")
local function user_forced_autojump_3f()
  return (not opts.labels or empty_3f(opts.labels))
end
local function user_forced_noautojump_3f()
  return (not opts.safe_labels or empty_3f(opts.safe_labels))
end
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
local function get_input()
  local ok_3f, ch = pcall(vim.fn.getcharstr)
  if (ok_3f and (ch ~= _3cesc_3e)) then
    return ch
  else
    return nil
  end
end
local function get_input_by_keymap(prompt)
  local function echo_prompt(seq)
    return api.nvim_echo({{prompt.str}, {(seq or ""), "ErrorMsg"}}, false, {})
  end
  local function accept(ch)
    prompt.str = (prompt.str .. ch)
    echo_prompt()
    return ch
  end
  local function loop(seq)
    local _7cseq_7c = #(seq or "")
    if (function(_6_,_7_,_8_) return (_6_ <= _7_) and (_7_ <= _8_) end)(1,_7cseq_7c,5) then
      echo_prompt(seq)
      local rhs_candidate = vim.fn.mapcheck(seq, "l")
      local rhs = vim.fn.maparg(seq, "l")
      if (rhs_candidate == "") then
        return accept(seq)
      elseif (rhs == rhs_candidate) then
        return accept(rhs)
      else
        local _9_ = get_input()
        if (_9_ == _3cbs_3e) then
          local function _10_()
            if (_7cseq_7c >= 2) then
              return seq:sub(1, dec(_7cseq_7c))
            else
              return seq
            end
          end
          return loop(_10_())
        elseif (_9_ == _3ccr_3e) then
          if (rhs ~= "") then
            return accept(rhs)
          elseif (_7cseq_7c == 1) then
            return accept(seq)
          else
            return loop(seq)
          end
        elseif (nil ~= _9_) then
          local ch = _9_
          return loop((seq .. ch))
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  if (vim.bo.iminsert ~= 1) then
    return get_input()
  else
    echo_prompt()
    local _15_ = loop(get_input())
    if (nil ~= _15_) then
      local _in = _15_
      return _in
    elseif true then
      local _ = _15_
      return echo("")
    else
      return nil
    end
  end
end
local function set_autojump(targets, force_noautojump_3f)
  targets["autojump?"] = (not (force_noautojump_3f or user_forced_noautojump_3f()) and (user_forced_autojump_3f() or (#opts.safe_labels >= dec(#targets))))
  return nil
end
local function attach_label_set(targets)
  local _18_
  if user_forced_autojump_3f() then
    _18_ = opts.safe_labels
  elseif user_forced_noautojump_3f() then
    _18_ = opts.labels
  elseif targets["autojump?"] then
    _18_ = opts.safe_labels
  else
    _18_ = opts.labels
  end
  targets["label-set"] = _18_
  return nil
end
local function set_labels(targets)
  local _local_20_ = targets
  local autojump_3f = _local_20_["autojump?"]
  local label_set = _local_20_["label-set"]
  for i, target in ipairs(targets) do
    local i_2a
    if autojump_3f then
      i_2a = dec(i)
    else
      i_2a = i
    end
    if (i_2a > 0) then
      local _23_
      do
        local _22_ = (i_2a % #label_set)
        if (_22_ == 0) then
          _23_ = label_set[#label_set]
        elseif (nil ~= _22_) then
          local n = _22_
          _23_ = label_set[n]
        else
          _23_ = nil
        end
      end
      target["label"] = _23_
    else
    end
  end
  return nil
end
local function set_label_states(targets, _28_)
  local _arg_29_ = _28_
  local group_offset = _arg_29_["group-offset"]
  local _7clabel_set_7c = #targets["label-set"]
  local offset = (group_offset * _7clabel_set_7c)
  local primary_start
  local function _30_()
    if targets["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _30_())
  local primary_end = (primary_start + dec(_7clabel_set_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabel_set_7c)
  for i, target in ipairs(targets) do
    if (target.label and (target["label-state"] ~= "selected")) then
      local _31_
      if (function(_32_,_33_,_34_) return (_32_ <= _33_) and (_33_ <= _34_) end)(primary_start,i,primary_end) then
        _31_ = "active-primary"
      elseif (function(_35_,_36_,_37_) return (_35_ <= _36_) and (_36_ <= _37_) end)(secondary_start,i,secondary_end) then
        _31_ = "active-secondary"
      elseif (i > secondary_end) then
        _31_ = "inactive"
      else
        _31_ = nil
      end
      target["label-state"] = _31_
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
  targets.sublists = {}
  local function _43_()
    local __3ecommon_key
    local function _40_(_241)
      local function _41_()
        if not opts.case_sensitive then
          return _241:lower()
        else
          return nil
        end
      end
      return (opts.character_class_of[_241] or _41_() or _241)
    end
    __3ecommon_key = _40_
    local function _44_(t, k)
      return rawget(t, __3ecommon_key(k))
    end
    local function _45_(t, k, v)
      return rawset(t, __3ecommon_key(k), v)
    end
    return {__index = _44_, __newindex = _45_}
  end
  setmetatable(targets.sublists, _43_())
  for _, _46_ in ipairs(targets) do
    local _each_47_ = _46_
    local _each_48_ = _each_47_["pair"]
    local _0 = _each_48_[1]
    local ch2 = _each_48_[2]
    local target = _each_47_
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    else
    end
    table.insert(targets.sublists[ch2], target)
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
  local _let_50_ = target
  local _let_51_ = _let_50_["pair"]
  local ch1 = _let_51_[1]
  local ch2 = _let_51_[2]
  local edge_pos_3f = _let_50_["edge-pos?"]
  local function _52_()
    if edge_pos_3f then
      return 0
    else
      return ch2:len()
    end
  end
  return (ch1:len() + _52_())
end
local function set_beacon_for_labeled(target, _53_)
  local _arg_54_ = _53_
  local user_given_targets_3f = _arg_54_["user-given-targets?"]
  local aot_3f = _arg_54_["aot?"]
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
  local text = (target.label .. pad)
  local virttext
  do
    local _57_ = target["label-state"]
    if (_57_ == "selected") then
      virttext = {{text, hl.group["label-selected"]}}
    elseif (_57_ == "active-primary") then
      virttext = {{text, hl.group["label-primary"]}}
    elseif (_57_ == "active-secondary") then
      virttext = {{text, hl.group["label-secondary"]}}
    elseif (_57_ == "inactive") then
      if not opts.highlight_unlabeled then
        virttext = {{(" " .. pad), hl.group["label-secondary"]}}
      else
        virttext = nil
      end
    else
      virttext = nil
    end
  end
  local _60_
  if virttext then
    _60_ = {offset, virttext}
  else
    _60_ = nil
  end
  target["beacon"] = _60_
  return nil
end
local function set_beacon_to_match_hl(target)
  local _let_62_ = target
  local _let_63_ = _let_62_["pair"]
  local ch1 = _let_63_[1]
  local ch2 = _let_63_[2]
  local virttext = {{(ch1 .. ch2), hl.group.match}}
  target["beacon"] = {0, virttext}
  return nil
end
local function set_beacon_to_empty_label(target)
  target["beacon"][2][1][1] = " "
  return nil
end
local function resolve_conflicts(targets)
  local unlabeled_match_positions = {}
  local label_positions = {}
  for i, target in ipairs(targets) do
    local _let_64_ = target
    local _let_65_ = _let_64_["pos"]
    local lnum = _let_65_[1]
    local col = _let_65_[2]
    local _let_66_ = _let_64_["pair"]
    local ch1 = _let_66_[1]
    local _ = _let_66_[2]
    local _let_67_ = _let_64_["wininfo"]
    local bufnr = _let_67_["bufnr"]
    local winid = _let_67_["winid"]
    if (not target.beacon or (opts.highlight_unlabeled and (target.beacon[2][1][2] == hl.group.match))) then
      local keys = {(bufnr .. " " .. winid .. " " .. lnum .. " " .. col), (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + ch1:len()))}
      for _0, k in ipairs(keys) do
        do
          local _68_ = label_positions[k]
          if (nil ~= _68_) then
            local other = _68_
            other.beacon = nil
            set_beacon_to_match_hl(target)
          else
          end
        end
        unlabeled_match_positions[k] = target
      end
    else
      local label_offset = target.beacon[1]
      local k = (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + label_offset))
      do
        local _70_ = unlabeled_match_positions[k]
        if (nil ~= _70_) then
          local other = _70_
          target.beacon = nil
          set_beacon_to_match_hl(other)
        elseif true then
          local _0 = _70_
          local _71_ = label_positions[k]
          if (nil ~= _71_) then
            local other = _71_
            target.beacon = nil
            set_beacon_to_empty_label(other)
          else
          end
        else
        end
      end
      label_positions[k] = target
    end
  end
  return nil
end
local function set_beacons(targets, _75_)
  local _arg_76_ = _75_
  local force_no_labels_3f = _arg_76_["force-no-labels?"]
  local user_given_targets_3f = _arg_76_["user-given-targets?"]
  local aot_3f = _arg_76_["aot?"]
  if (force_no_labels_3f and not user_given_targets_3f) then
    for _, target in ipairs(targets) do
      set_beacon_to_match_hl(target)
    end
    return nil
  else
    for _, target in ipairs(targets) do
      if target.label then
        set_beacon_for_labeled(target, {["user-given-targets?"] = user_given_targets_3f, ["aot?"] = aot_3f})
      elseif (aot_3f and opts.highlight_unlabeled) then
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
local function light_up_beacons(targets, _3fstart)
  for i = (_3fstart or 1), #targets do
    local target = targets[i]
    local _80_ = target.beacon
    if ((_G.type(_80_) == "table") and (nil ~= (_80_)[1]) and (nil ~= (_80_)[2])) then
      local offset = (_80_)[1]
      local virttext = (_80_)[2]
      local bufnr = target.wininfo.bufnr
      local _let_81_ = map(dec, target.pos)
      local lnum = _let_81_[1]
      local col = _let_81_[2]
      local id = api.nvim_buf_set_extmark(bufnr, hl.ns, lnum, (col + offset), {virt_text = virttext, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.label})
      table.insert(hl.extmarks, {bufnr, id})
    else
    end
  end
  return nil
end
local state = {["repeat"] = {in1 = nil, in2 = nil}, dot_repeat = {in1 = nil, in2 = nil, target_idx = nil, backward = nil, inclusive_op = nil, offset = nil}, args = nil}
local function leap(kwargs)
  do
    local _83_ = kwargs.target_windows
    if ((_G.type(_83_) == "table") and ((_83_)[1] == nil)) then
      echo("no targetable windows")
      return
    else
    end
  end
  local _let_85_ = kwargs
  local dot_repeat_3f = _let_85_["dot_repeat"]
  local target_windows = _let_85_["target_windows"]
  local user_given_targets = _let_85_["targets"]
  local user_given_action = _let_85_["action"]
  local multi_select_3f = _let_85_["multiselect"]
  local function _87_()
    if dot_repeat_3f then
      return state.dot_repeat
    else
      return kwargs
    end
  end
  local _let_86_ = _87_()
  local backward_3f = _let_86_["backward"]
  local inclusive_op_3f = _let_86_["inclusive_op"]
  local offset = _let_86_["offset"]
  local _
  state.args = kwargs
  _ = nil
  local __3ewininfo
  local function _88_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  __3ewininfo = _88_
  local current_window = __3ewininfo(vim.fn.win_getid())
  local _0
  if (user_given_targets and not user_given_targets[1].wininfo) then
    local function _89_(t)
      t.wininfo = current_window
      return nil
    end
    _0 = map(_89_, user_given_targets)
  else
    _0 = nil
  end
  local _3ftarget_windows
  do
    local _91_ = target_windows
    if (_91_ ~= nil) then
      _3ftarget_windows = map(__3ewininfo, _91_)
    else
      _3ftarget_windows = _91_
    end
  end
  local hl_affected_windows = {current_window}
  local _1
  for _2, w in ipairs((_3ftarget_windows or {})) do
    table.insert(hl_affected_windows, w)
  end
  _1 = nil
  local directional_3f = not target_windows
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and directional_3f and (vim.v.operator ~= "y"))
  local force_noautojump_3f = (multi_select_3f or user_given_action or op_mode_3f or not directional_3f)
  local prompt = {str = ">"}
  local spec_keys
  local function _93_(_2, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _93_})
  local aot_3f = not (multi_select_3f or user_given_targets or (opts.max_aot_targets == 0))
  local function echo_not_found(s)
    return echo(("not found: " .. s))
  end
  local function expand_to_user_defined_character_class(_in)
    local _94_ = opts.character_class_of[_in]
    if (nil ~= _94_) then
      local chars = _94_
      return ("\\(" .. table.concat(chars, "\\|") .. "\\)")
    else
      return nil
    end
  end
  local function prepare_pattern(in1, _3fin2)
    local function _96_()
      if opts.case_sensitive then
        return "\\C"
      else
        return "\\c"
      end
    end
    return ("\\V" .. _96_() .. (expand_to_user_defined_character_class(in1) or in1:gsub("\\", "\\\\")) .. (expand_to_user_defined_character_class(_3fin2) or _3fin2 or "\\_."))
  end
  local function get_target_with_active_primary_label(sublist, input)
    local res = nil
    for idx, _97_ in ipairs(sublist) do
      local _each_98_ = _97_
      local label = _each_98_["label"]
      local label_state = _each_98_["label-state"]
      local target = _each_98_
      if (res or (label_state == "inactive")) then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      else
      end
    end
    return res
  end
  local function update_state(state_2a)
    if not (dot_repeat_3f or user_given_targets) then
      if state_2a["repeat"] then
        state["repeat"] = state_2a["repeat"]
      else
      end
      if state_2a.dot_repeat then
        state.dot_repeat = vim.tbl_extend("error", state_2a.dot_repeat, {["backward?"] = backward_3f, offset = offset, ["inclusive-op?"] = inclusive_op_3f})
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function set_dot_repeat(in1, in2, target_idx)
    if dot_repeatable_op_3f then
      update_state({dot_repeat = {in1 = in1, in2 = in2, target_idx = target_idx}})
      return set_dot_repeat_2a()
    else
      return nil
    end
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _104_(target)
      local jump = require("leap.jump")
      jump["jump-to!"](target.pos, {winid = target.wininfo.winid, ["add-to-jumplist?"] = first_jump_3f, mode = mode, offset = offset, ["backward?"] = backward_3f, ["inclusive-op?"] = inclusive_op_3f})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _104_
  end
  local function get_first_pattern_input()
    do
      hl:cleanup(hl_affected_windows)
      if not (user_given_targets and not _3ftarget_windows) then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        echo("")
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    end
    local _106_
    local function _107_()
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
    _106_ = (get_input_by_keymap(prompt) or _107_())
    if (_106_ == spec_keys.repeat_search) then
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
    elseif (nil ~= _106_) then
      local in1 = _106_
      return in1
    else
      return nil
    end
  end
  local function get_second_pattern_input(targets)
    if (#targets <= (opts.max_aot_targets or math.huge)) then
      hl:cleanup(hl_affected_windows)
      if not (user_given_targets and not _3ftarget_windows) then
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
    local function _114_()
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
    return (get_input_by_keymap(prompt) or _114_())
  end
  local function get_full_pattern_input()
    local _116_, _117_ = get_first_pattern_input()
    if ((nil ~= _116_) and (nil ~= _117_)) then
      local in1 = _116_
      local in2 = _117_
      return in1, in2
    elseif ((nil ~= _116_) and (_117_ == nil)) then
      local in1 = _116_
      local _118_ = get_input_by_keymap(prompt)
      if (nil ~= _118_) then
        local in2 = _118_
        return in1, in2
      elseif true then
        local _2 = _118_
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
  local function post_pattern_input_loop(sublist, _3fgroup_offset, first_invoc_3f)
    local function loop(group_offset, first_invoc_3f0)
      do
        local _122_ = sublist
        set_label_states(_122_, {["group-offset"] = group_offset})
        set_beacons(_122_, {["user-given-targets?"] = user_given_targets, ["aot?"] = aot_3f})
      end
      do
        hl:cleanup(hl_affected_windows)
        if not (user_given_targets and not _3ftarget_windows) then
          hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
        else
        end
        do
          local function _124_()
            if sublist["autojump?"] then
              return 2
            else
              return nil
            end
          end
          light_up_beacons(sublist, _124_())
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
      _125_ = (get_input() or _126_())
      if (nil ~= _125_) then
        local input = _125_
        if (((input == spec_keys.next_group) or ((input == spec_keys.prev_group) and not first_invoc_3f0)) and (not sublist["autojump?"] or user_forced_autojump_3f())) then
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
        elseif "else" then
          return input, group_offset
        else
          return nil
        end
      else
        return nil
      end
    end
    local function _131_()
      if (nil == first_invoc_3f) then
        return true
      else
        return first_invoc_3f
      end
    end
    return loop((_3fgroup_offset or 0), _131_())
  end
  local multi_select_loop
  do
    local res = {}
    local group_offset = 0
    local first_invoc_3f = true
    local function loop(targets)
      local _132_, _133_ = post_pattern_input_loop(targets, group_offset, first_invoc_3f)
      if (_132_ == spec_keys.multi_accept) then
        if next(res) then
          return res
        else
          return loop(targets)
        end
      elseif (_132_ == spec_keys.multi_revert) then
        do
          local _135_ = table.remove(res)
          if (nil ~= _135_) then
            _135_["label-state"] = nil
          else
          end
        end
        return loop(targets)
      elseif ((nil ~= _132_) and (nil ~= _133_)) then
        local _in = _132_
        local group_offset_2a = _133_
        group_offset = group_offset_2a
        first_invoc_3f = false
        do
          local _137_ = get_target_with_active_primary_label(targets, _in)
          if ((_G.type(_137_) == "table") and (nil ~= (_137_)[1]) and (nil ~= (_137_)[2])) then
            local idx = (_137_)[1]
            local target = (_137_)[2]
            if not contains_3f(res, target) then
              table.insert(res, target)
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
  local function traversal_loop(targets, idx, _141_)
    local _arg_142_ = _141_
    local force_no_labels_3f = _arg_142_["force-no-labels?"]
    if force_no_labels_3f then
      inactivate_labels(targets)
    else
    end
    set_beacons(targets, {["force-no-labels?"] = force_no_labels_3f, ["aot?"] = aot_3f, ["user-given-targets?"] = user_given_targets})
    do
      hl:cleanup(hl_affected_windows)
      if not (user_given_targets and not _3ftarget_windows) then
        hl["apply-backdrop"](hl, backward_3f, _3ftarget_windows)
      else
      end
      do
        light_up_beacons(targets, inc(idx))
      end
      hl["highlight-cursor"](hl)
      vim.cmd("redraw")
    end
    local _145_
    local function _146_()
      do
      end
      hl:cleanup(hl_affected_windows)
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _145_ = (get_input() or _146_())
    if (nil ~= _145_) then
      local input = _145_
      if ((input == spec_keys.next_match) or (input == spec_keys.prev_match)) then
        local new_idx
        do
          local _147_ = input
          if (_147_ == spec_keys.next_match) then
            new_idx = min(inc(idx), #targets)
          elseif (_147_ == spec_keys.prev_match) then
            new_idx = max(dec(idx), 1)
          else
            new_idx = nil
          end
        end
        local _150_
        do
          local t_149_ = targets
          if (nil ~= t_149_) then
            t_149_ = (t_149_)[new_idx]
          else
          end
          if (nil ~= t_149_) then
            t_149_ = (t_149_).pair
          else
          end
          if (nil ~= t_149_) then
            t_149_ = (t_149_)[2]
          else
          end
          _150_ = t_149_
        end
        update_state({["repeat"] = {in1 = state["repeat"].in1, in2 = _150_}})
        jump_to_21(targets[new_idx])
        return traversal_loop(targets, new_idx, {["force-no-labels?"] = force_no_labels_3f})
      else
        local _154_ = get_target_with_active_primary_label(targets, input)
        if ((_G.type(_154_) == "table") and true and (nil ~= (_154_)[2])) then
          local _2 = (_154_)[1]
          local target = (_154_)[2]
          do
            jump_to_21(target)
          end
          hl:cleanup(hl_affected_windows)
          exec_user_autocmds("LeapLeave")
          return nil
        elseif true then
          local _2 = _154_
          do
            vim.fn.feedkeys(input, "i")
          end
          hl:cleanup(hl_affected_windows)
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
  local do_action = (user_given_action or jump_to_21)
  exec_user_autocmds("LeapEnter")
  local function _158_(...)
    local _159_, _160_ = ...
    if ((nil ~= _159_) and true) then
      local in1 = _159_
      local _3fin2 = _160_
      local function _161_(...)
        local _162_ = ...
        if (nil ~= _162_) then
          local targets = _162_
          local function _163_(...)
            local _164_ = ...
            if (nil ~= _164_) then
              local in2 = _164_
              if ((in2 == spec_keys.next_match) and directional_3f) then
                local in20 = targets[1].pair[2]
                update_state({["repeat"] = {in1 = in1, in2 = in20}})
                do_action(targets[1])
                if ((#targets == 1) or op_mode_3f or user_given_action) then
                  do
                    set_dot_repeat(in1, in20, 1)
                  end
                  hl:cleanup(hl_affected_windows)
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return traversal_loop(targets, 1, {["force-no-labels?"] = true})
                end
              else
                update_state({["repeat"] = {in1 = in1, in2 = in2}})
                local _166_
                local function _167_(...)
                  if targets.sublists then
                    return targets.sublists[in2]
                  else
                    return targets
                  end
                end
                local function _168_(...)
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
                _166_ = (_167_(...) or _168_(...))
                if (nil ~= _166_) then
                  local targets_2a = _166_
                  if multi_select_3f then
                    local _170_ = multi_select_loop(targets_2a)
                    if (nil ~= _170_) then
                      local targets_2a_2a = _170_
                      do
                        do
                          hl:cleanup(hl_affected_windows)
                          if not (user_given_targets and not _3ftarget_windows) then
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
                    local function _173_(idx)
                      do
                        set_dot_repeat(in1, in2, idx)
                        do_action((targets_2a)[idx])
                      end
                      hl:cleanup(hl_affected_windows)
                      exec_user_autocmds("LeapLeave")
                      return nil
                    end
                    exit_with_action = _173_
                    if (#targets_2a == 1) then
                      return exit_with_action(1)
                    else
                      if targets_2a["autojump?"] then
                        do_action((targets_2a)[1])
                      else
                      end
                      local _175_ = post_pattern_input_loop(targets_2a)
                      if (nil ~= _175_) then
                        local in_final = _175_
                        if ((in_final == spec_keys.next_match) and directional_3f) then
                          if (op_mode_3f or user_given_action) then
                            return exit_with_action(1)
                          else
                            local new_idx
                            if targets_2a["autojump?"] then
                              new_idx = 2
                            else
                              new_idx = 1
                            end
                            do_action((targets_2a)[new_idx])
                            return traversal_loop(targets_2a, new_idx, {["force-no-labels?"] = not targets_2a["autojump?"]})
                          end
                        else
                          local _178_ = get_target_with_active_primary_label(targets_2a, in_final)
                          if ((_G.type(_178_) == "table") and (nil ~= (_178_)[1]) and true) then
                            local idx = (_178_)[1]
                            local _2 = (_178_)[2]
                            return exit_with_action(idx)
                          elseif true then
                            local _2 = _178_
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
              local __60_auto = _164_
              return ...
            else
              return nil
            end
          end
          local function _198_(...)
            if dot_repeat_3f then
              local _189_ = targets[state.dot_repeat.target_idx]
              if (nil ~= _189_) then
                local target = _189_
                do
                  do_action(target)
                end
                hl:cleanup(hl_affected_windows)
                exec_user_autocmds("LeapLeave")
                return nil
              elseif true then
                local _2 = _189_
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
              local function _192_(_241)
                local _193_ = _241
                set_autojump(_193_, force_noautojump_3f)
                attach_label_set(_193_)
                set_labels(_193_)
                return _193_
              end
              prepare_targets = _192_
              if _3fin2 then
                prepare_targets(targets)
              else
                populate_sublists(targets)
                for _2, sublist in pairs(targets.sublists) do
                  prepare_targets(sublist)
                end
              end
              if (#targets > (opts.max_aot_targets or math.huge)) then
                aot_3f = false
              else
              end
              local function _196_(...)
                do
                  local _197_ = targets
                  set_initial_label_states(_197_)
                  set_beacons(_197_, {["aot?"] = aot_3f})
                end
                return get_second_pattern_input(targets)
              end
              return (_3fin2 or _196_(...))
            end
          end
          return _163_(_198_(...))
        elseif true then
          local __60_auto = _162_
          return ...
        else
          return nil
        end
      end
      local function _200_(...)
        local search = require("leap.search")
        local pattern = prepare_pattern(in1, _3fin2)
        local kwargs0 = {["backward?"] = backward_3f, ["target-windows"] = _3ftarget_windows}
        return search["get-targets"](pattern, kwargs0)
      end
      local function _201_(...)
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
      return _161_((user_given_targets or _200_(...) or _201_(...)))
    elseif true then
      local __60_auto = _159_
      return ...
    else
      return nil
    end
  end
  local function _204_()
    if dot_repeat_3f then
      return state.dot_repeat.in1, state.dot_repeat.in2
    elseif user_given_targets then
      return true, true
    elseif aot_3f then
      return get_first_pattern_input()
    else
      return get_full_pattern_input()
    end
  end
  return _158_(_204_())
end
local temporary_editor_opts = {["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_205_ = vim.split(opt, ".", true)
    local _0 = _let_205_[1]
    local scope = _let_205_[2]
    local name = _let_205_[3]
    saved_editor_opts[opt] = _G.vim[scope][name]
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_206_ = vim.split(opt, ".", true)
    local _ = _let_206_[1]
    local scope = _let_206_[2]
    local name = _let_206_[3]
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
local _207_
do
  local t = {}
  for _, cc in ipairs((opts.character_classes or {})) do
    local cc_2a
    if (type(cc) == "string") then
      local tbl_15_auto = {}
      local i_16_auto = #tbl_15_auto
      for char in cc:gmatch(".") do
        local val_17_auto = char
        if (nil ~= val_17_auto) then
          i_16_auto = (i_16_auto + 1)
          do end (tbl_15_auto)[i_16_auto] = val_17_auto
        else
        end
      end
      cc_2a = tbl_15_auto
    else
      cc_2a = cc
    end
    for _0, char in ipairs(cc_2a) do
      t[char] = cc_2a
    end
  end
  _207_ = t
end
opts["character_class_of"] = _207_
hl["init-highlight"](hl)
api.nvim_create_augroup("LeapDefault", {})
local function _210_()
  return hl["init-highlight"](hl)
end
api.nvim_create_autocmd("ColorScheme", {callback = _210_, group = "LeapDefault"})
local function _211_()
  save_editor_opts()
  return set_temporary_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LeapEnter", callback = _211_, group = "LeapDefault"})
api.nvim_create_autocmd("User", {pattern = "LeapLeave", callback = restore_editor_opts, group = "LeapDefault"})
return {state = state, leap = leap}
