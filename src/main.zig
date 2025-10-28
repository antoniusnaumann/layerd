const std = @import("std");

const layerd = @import("keys.zig");

const c = @cImport({
    @cInclude("ApplicationServices/ApplicationServices.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});

/// minimal line-based parser for:
/// [capslock]
/// key = "value"
fn parseConfig(alloc: std.mem.Allocator, text: []const u8) !std.AutoHashMap(u16, layerd.Key) {
    var map = std.AutoHashMap(u16, layerd.Key).init(alloc);
    var layer_key = "";

    var it = std.mem.splitScalar(u8, text, '\n');
    while (it.next()) |raw_line| {
        const line0 = std.mem.trim(u8, raw_line, " \t\r");
        if (line0.len == 0 or line0[0] == '#') continue;

        if (line0[0] == '[') {
            layer_key = std.mem.trim(u8, line0, "[]");
            continue;
        }

        if (std.mem.indexOfScalar(u8, line0, '=')) |eq| {
            const lhs = std.mem.trim(u8, line0[0..eq], " \t");
            if (lhs.len >= 2 and lhs[0] == '"' and lhs[lhs.len - 1] == '"') lhs = lhs[1 .. lhs.len - 1];

            var rhs = std.mem.trim(u8, line0[eq + 1 ..], " \t");
            if (rhs.len >= 2 and rhs[0] == '"' and rhs[rhs.len - 1] == '"') rhs = rhs[1 .. rhs.len - 1];

            if (layerd.Key.init(lhs)) |src| {
                if (layerd.Key.init(rhs).keycode()) |act| try map.put(src, act);
            }
        }
    }
    return map;
}

var active_layer: layerd.Layer = undefined;

export fn eventTapCallback(
    _: c.CGEventTapProxy,
    etype: c.CGEventType,
    event: c.CGEventRef,
    _: ?*anyopaque,
) c.CGEventRef {
    const kDown = c.kCGEventKeyDown;
    const kUp = c.kCGEventKeyUp;
    const kFlg = c.kCGEventFlagsChanged;

    if (etype == kFlg) {
        const code: u16 = @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode));
        if (code == 57) { // CapsLock
            const flags = c.CGEventGetFlags(event);
            const caps_on = (flags & c.kCGEventFlagMaskAlphaShift) != 0;
            active_layer.layer_active = caps_on;
            return null; // swallow: prevent OS caps toggle/LED
        }
        return event;
    }

    if (etype == kDown or etype == kUp) {
        const code: u16 = @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode));
        if (active_layer.layer_active) {
            if (active_layer.map.get(code)) |act| {
                const new = c.CGEventCreateKeyboardEvent(null, act.keycode(), etype == kDown);
                // clear caps flag on synthesized event
                const flags = c.CGEventGetFlags(event) & ~c.kCGEventFlagMaskAlphaShift;
                c.CGEventSetFlags(new, flags);
                c.CGEventPost(c.kCGHIDEventTap, new);
                c.CFRelease(new);
                return null;
            }
        }
        return event;
    }

    return event;
}

fn defaultConfigPath(alloc: std.mem.Allocator) ![]u8 {
    const home = try std.process.getEnvVarOwned(alloc, "HOME");
    defer alloc.free(home);
    return std.fs.path.join(alloc, &.{ home, ".config", "layerd", "layer.toml" });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var cfg_path: []const u8 = undefined;
    if (args.len >= 2) {
        cfg_path = args[1];
    } else {
        cfg_path = try defaultConfigPath(alloc);
        defer alloc.free(cfg_path);
    }

    // read config
    var file = try std.fs.cwd().openFile(cfg_path, .{});
    defer file.close();
    const data = try file.readToEndAlloc(alloc, 1 << 16);
    defer alloc.free(data);

    g_caps = .{ .layer_active = false, .map = try parseConfig(alloc, data) };
    defer g_caps.map.deinit();

    // tap
    const mask: c.CGEventMask =
        (1 << c.kCGEventKeyDown) | (1 << c.kCGEventKeyUp) | (1 << c.kCGEventFlagsChanged);

    const tap = c.CGEventTapCreate(
        c.kCGHIDEventTap,
        c.kCGHeadInsertEventTap,
        c.kCGEventTapOptionDefault,
        mask,
        eventTapCallback,
        null,
    );
    if (tap == null) {
        std.log.err("Failed to create event tap. Please grant Accessibility permissions!", .{});
        return;
    }
    const src = c.CFMachPortCreateRunLoopSource(null, tap, 0);
    const rl = c.CFRunLoopGetCurrent();
    c.CFRunLoopAddSource(rl, src, c.kCFRunLoopCommonModes);
    c.CGEventTapEnable(tap, true);
    std.log.info("layerd running. CapsLock hold → nav layer.", .{});
    c.CFRunLoopRun();
}
