//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const Key = enum {
    // ANSI-dependent (letters, digits, symbols, keypad)
    a,
    s,
    d,
    f,
    h,
    g,
    z,
    x,
    c,
    v,
    b,
    q,
    w,
    e,
    r,
    y,
    t,
    num1,
    num2,
    num3,
    num4,
    num6,
    num5,
    equal,
    num9,
    num7,
    minus,
    num8,
    num0,
    right_bracket,
    o,
    u,
    left_bracket,
    i,
    p,
    l,
    j,
    quote,
    k,
    semicolon,
    backslash,
    comma,
    slash,
    n,
    m,
    period,
    grave,
    keypad_decimal,
    keypad_multiply,
    keypad_plus,
    keypad_clear,
    keypad_divide,
    keypad_enter,
    keypad_minus,
    keypad_equals,
    keypad_0,
    keypad_1,
    keypad_2,
    keypad_3,
    keypad_4,
    keypad_5,
    keypad_6,
    keypad_7,
    keypad_8,
    keypad_9,

    // Layout-independent
    return_key,
    tab,
    space,
    delete,
    esc,
    command,
    shift,
    caps_lock,
    option,
    control,
    right_shift,
    right_option,
    right_control,
    function_key,
    f17,
    volume_up,
    volume_down,
    mute,
    f18,
    f19,
    f20,
    f5,
    f6,
    f7,
    f3,
    f8,
    f9,
    f11,
    f13,
    f16,
    f14,
    f10,
    f12,
    f15,
    help,
    home,
    page_up,
    forward_delete,
    f4,
    end,
    f2,
    page_down,
    f1,
    arrow_left,
    arrow_right,
    arrow_down,
    arrow_up,

    pub fn keycode(self: Key) u16 {
        return switch (self) {
            // ANSI-dependent
            .a => 0x00, // ANSI
            .s => 0x01, // ANSI
            .d => 0x02, // ANSI
            .f => 0x03, // ANSI
            .h => 0x04, // ANSI
            .g => 0x05, // ANSI
            .z => 0x06, // ANSI
            .x => 0x07, // ANSI
            .c => 0x08, // ANSI
            .v => 0x09, // ANSI
            .b => 0x0B, // ANSI
            .q => 0x0C, // ANSI
            .w => 0x0D, // ANSI
            .e => 0x0E, // ANSI
            .r => 0x0F, // ANSI
            .y => 0x10, // ANSI
            .t => 0x11, // ANSI
            .num1 => 0x12, // ANSI
            .num2 => 0x13, // ANSI
            .num3 => 0x14, // ANSI
            .num4 => 0x15, // ANSI
            .num6 => 0x16, // ANSI
            .num5 => 0x17, // ANSI
            .equal => 0x18, // ANSI
            .num9 => 0x19, // ANSI
            .num7 => 0x1A, // ANSI
            .minus => 0x1B, // ANSI
            .num8 => 0x1C, // ANSI
            .num0 => 0x1D, // ANSI
            .right_bracket => 0x1E, // ANSI
            .o => 0x1F, // ANSI
            .u => 0x20, // ANSI
            .left_bracket => 0x21, // ANSI
            .i => 0x22, // ANSI
            .p => 0x23, // ANSI
            .l => 0x25, // ANSI
            .j => 0x26, // ANSI
            .quote => 0x27, // ANSI
            .k => 0x28, // ANSI
            .semicolon => 0x29, // ANSI
            .backslash => 0x2A, // ANSI
            .comma => 0x2B, // ANSI
            .slash => 0x2C, // ANSI
            .n => 0x2D, // ANSI
            .m => 0x2E, // ANSI
            .period => 0x2F, // ANSI
            .grave => 0x32, // ANSI
            .keypad_decimal => 0x41, // ANSI
            .keypad_multiply => 0x43, // ANSI
            .keypad_plus => 0x45, // ANSI
            .keypad_clear => 0x47, // ANSI
            .keypad_divide => 0x4B, // ANSI
            .keypad_enter => 0x4C, // ANSI
            .keypad_minus => 0x4E, // ANSI
            .keypad_equals => 0x51, // ANSI
            .keypad_0 => 0x52, // ANSI
            .keypad_1 => 0x53, // ANSI
            .keypad_2 => 0x54, // ANSI
            .keypad_3 => 0x55, // ANSI
            .keypad_4 => 0x56, // ANSI
            .keypad_5 => 0x57, // ANSI
            .keypad_6 => 0x58, // ANSI
            .keypad_7 => 0x59, // ANSI
            .keypad_8 => 0x5B, // ANSI
            .keypad_9 => 0x5C, // ANSI

            // Layout-independent
            .return_key => 0x24,
            .tab => 0x30,
            .space => 0x31,
            .delete => 0x33,
            .esc => 0x35,
            .command => 0x37,
            .shift => 0x38,
            .caps_lock => 0x39,
            .option => 0x3A,
            .control => 0x3B,
            .right_shift => 0x3C,
            .right_option => 0x3D,
            .right_control => 0x3E,
            .function_key => 0x3F,
            .f17 => 0x40,
            .volume_up => 0x48,
            .volume_down => 0x49,
            .mute => 0x4A,
            .f18 => 0x4F,
            .f19 => 0x50,
            .f20 => 0x5A,
            .f5 => 0x60,
            .f6 => 0x61,
            .f7 => 0x62,
            .f3 => 0x63,
            .f8 => 0x64,
            .f9 => 0x65,
            .f11 => 0x67,
            .f13 => 0x69,
            .f16 => 0x6A,
            .f14 => 0x6B,
            .f10 => 0x6D,
            .f12 => 0x6F,
            .f15 => 0x71,
            .help => 0x72,
            .home => 0x73,
            .page_up => 0x74,
            .forward_delete => 0x75,
            .f4 => 0x76,
            .end => 0x77,
            .f2 => 0x78,
            .page_down => 0x79,
            .f1 => 0x7A,
            .arrow_left => 0x7B,
            .arrow_right => 0x7C,
            .arrow_down => 0x7D,
            .arrow_up => 0x7E,
        };
    }

    pub fn init(name: []const u8) !Key {
        if (std.mem.eql(u8, name, "1")) return .num1;
        if (std.mem.eql(u8, name, "2")) return .num2;
        if (std.mem.eql(u8, name, "3")) return .num3;
        if (std.mem.eql(u8, name, "4")) return .num4;
        if (std.mem.eql(u8, name, "5")) return .num5;
        if (std.mem.eql(u8, name, "6")) return .num6;
        if (std.mem.eql(u8, name, "7")) return .num7;
        if (std.mem.eql(u8, name, "8")) return .num8;
        if (std.mem.eql(u8, name, "9")) return .num9;
        if (std.mem.eql(u8, name, "0")) return .num0;
        if (std.mem.eql(u8, name, "=")) return .equal;
        if (std.mem.eql(u8, name, "-")) return .minus;
        if (std.mem.eql(u8, name, "[")) return .right_bracket;
        if (std.mem.eql(u8, name, "]")) return .left_bracket;
        if (std.mem.eql(u8, name, ";")) return .semicolon;
        if (std.mem.eql(u8, name, "\"")) return .quote;
        if (std.mem.eql(u8, name, "\\")) return .backslash;
        if (std.mem.eql(u8, name, ",")) return .comma;
        if (std.mem.eql(u8, name, ".")) return .period;
        if (std.mem.eql(u8, name, "/")) return .slash;
        if (std.mem.eql(u8, name, "`")) return .grave;

        return std.meta.stringToEnum(Key, name) orelse {
            return error.InvalidChoice;
        };
    }

    pub fn initFromKeycode(code: u16) !Key {
        return switch (code) {
            // ---------- ANSI ----------
            0x00 => .a,
            0x01 => .s,
            0x02 => .d,
            0x03 => .f,
            0x04 => .h,
            0x05 => .g,
            0x06 => .z,
            0x07 => .x,
            0x08 => .c,
            0x09 => .v,
            0x0B => .b,
            0x0C => .q,
            0x0D => .w,
            0x0E => .e,
            0x0F => .r,
            0x10 => .y,
            0x11 => .t,
            0x12 => .num1,
            0x13 => .num2,
            0x14 => .num3,
            0x15 => .num4,
            0x16 => .num6,
            0x17 => .num5,
            0x18 => .equal,
            0x19 => .num9,
            0x1A => .num7,
            0x1B => .minus,
            0x1C => .num8,
            0x1D => .num0,
            0x1E => .right_bracket,
            0x1F => .o,
            0x20 => .u,
            0x21 => .left_bracket,
            0x22 => .i,
            0x23 => .p,
            0x25 => .l,
            0x26 => .j,
            0x27 => .quote,
            0x28 => .k,
            0x29 => .semicolon,
            0x2A => .backslash,
            0x2B => .comma,
            0x2C => .slash,
            0x2D => .n,
            0x2E => .m,
            0x2F => .period,
            0x32 => .grave,
            0x41 => .keypad_decimal,
            0x43 => .keypad_multiply,
            0x45 => .keypad_plus,
            0x47 => .keypad_clear,
            0x4B => .keypad_divide,
            0x4C => .keypad_enter,
            0x4E => .keypad_minus,
            0x51 => .keypad_equals,
            0x52 => .keypad_0,
            0x53 => .keypad_1,
            0x54 => .keypad_2,
            0x55 => .keypad_3,
            0x56 => .keypad_4,
            0x57 => .keypad_5,
            0x58 => .keypad_6,
            0x59 => .keypad_7,
            0x5B => .keypad_8,
            0x5C => .keypad_9,

            // ---------- Layout-independent ----------
            0x24 => .return_key,
            0x30 => .tab,
            0x31 => .space,
            0x33 => .delete,
            0x35 => .esc,
            0x37 => .command,
            0x38 => .shift,
            0x39 => .caps_lock,
            0x3A => .option,
            0x3B => .control,
            0x3C => .right_shift,
            0x3D => .right_option,
            0x3E => .right_control,
            0x3F => .function_key,
            0x40 => .f17,
            0x48 => .volume_up,
            0x49 => .volume_down,
            0x4A => .mute,
            0x4F => .f18,
            0x50 => .f19,
            0x5A => .f20,
            0x60 => .f5,
            0x61 => .f6,
            0x62 => .f7,
            0x63 => .f3,
            0x64 => .f8,
            0x65 => .f9,
            0x67 => .f11,
            0x69 => .f13,
            0x6A => .f16,
            0x6B => .f14,
            0x6D => .f10,
            0x6F => .f12,
            0x71 => .f15,
            0x72 => .help,
            0x73 => .home,
            0x74 => .page_up,
            0x75 => .forward_delete,
            0x76 => .f4,
            0x77 => .end,
            0x78 => .f2,
            0x79 => .page_down,
            0x7A => .f1,
            0x7B => .arrow_left,
            0x7C => .arrow_right,
            0x7D => .arrow_down,
            0x7E => .arrow_up,

            else => return error.InvalidChoice,
        };
    }
};

pub const Layer = struct {
    // it is also possible to remap keys on the base layer
    trigger: ?Key,
    map: std.AutoHashMap(Key, Key),
};

pub const LayerStore = struct {
    layers: std.ArrayList(Layer),
    alloc: std.mem.Allocator,

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, config: []const u8) !Self {
        const layers = try parseConfig(alloc, config);

        return .{ .layers = layers, .alloc = alloc };
    }

    pub fn deinit(self: *Self) void {
        for (self.layers.items) |*layer| {
            layer.map.deinit();
        }
        self.alloc.free(self.layers);
    }

    pub fn find(self: *Self, trigger: Key) ?*Layer {
        for (self.layers.items) |*layer| {
            if (layer.trigger == trigger) return layer;
        }

        return null;
    }
};

/// minimal line-based parser for:
/// [key]
/// key = "value"
fn parseConfig(alloc: std.mem.Allocator, config: []const u8) !std.AutoHashMap(Key, Key) {
    var layers = try std.ArrayList(Layer).initCapacity(alloc, 4);
    var layer_key: ?Key = null;
    var index: u8 = 0;

    try layers.append(alloc, .{
        .trigger = layer_key,
        // SAFETY: we are populating this in the parseLayerMappings method
        .map = undefined,
    });

    var it = std.mem.splitScalar(u8, config, '\n');
    while (true) {
        const mappings = try parseLayerMappings(alloc, &it);
        layers[index].map = mappings;

        if (it.next()) |raw_line| {
            const line0 = std.mem.trim(u8, raw_line, " \t\r");
            std.debug.assert(line0[0] == '[');
            const key_name = std.mem.trim(u8, line0, "[]");
            layer_key = try Key.init(key_name);
            layers.append(alloc, .{
                .trigger = layer_key,
                // SAFETY: we are populating this in the parseLayerMappings method
                .map = undefined,
            });
            index += 1;
        } else {
            break;
        }
    }
}

fn parseLayerMappings(alloc: std.mem.Allocator, lines: anytype) !std.AutoHashMap(Key, Key) {
    var map = std.AutoHashMap(Key, Key).init(alloc);

    while (lines.peek()) |raw_line| {
        const line0 = std.mem.trim(u8, raw_line, " \t\r");
        if (line0.len == 0 or line0[0] == '#') {
            _ = lines.next();
            continue;
        }
        if (line0[0] == '[') {
            break;
        }
        _ = lines.next();

        if (std.mem.indexOfScalar(u8, line0, '=')) |eq| {
            var lhs = std.mem.trim(u8, line0[0..eq], " \t");
            if (lhs.len >= 2 and lhs[0] == '"' and lhs[lhs.len - 1] == '"') lhs = lhs[1 .. lhs.len - 1];

            var rhs = std.mem.trim(u8, line0[eq + 1 ..], " \t");
            if (rhs.len >= 2 and rhs[0] == '"' and rhs[rhs.len - 1] == '"') rhs = rhs[1 .. rhs.len - 1];

            if (Key.init(lhs)) |src| {
                if (Key.init(rhs)) |act| try map.put(src, act);
            }
        }
    }
    return map;
}
