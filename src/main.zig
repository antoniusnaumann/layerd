const std = @import("std");

const layerd = @import("keys.zig");

const c = @cImport({
    @cInclude("ApplicationServices/ApplicationServices.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});

var store: layerd.LayerStore = undefined;
var active: ?layerd.Key = null;

export fn eventTapCallback(
    _: c.CGEventTapProxy,
    etype: c.CGEventType,
    event: c.CGEventRef,
    _: ?*anyopaque,
) c.CGEventRef {
    const kDown = c.kCGEventKeyDown;
    const kUp = c.kCGEventKeyUp;

    // TODO: check if we need flag-checking
    // const kFlg = c.kCGEventFlagsChanged;
    // if (etype == kFlg) {
    //     const code: u16 = @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode));
    //     if (code == 57) { // CapsLock
    //         // const flags = c.CGEventGetFlags(event);
    //         // const caps_on = (flags & c.kCGEventFlagMaskAlphaShift) != 0;
    //         // active_layer.layer_active = caps_on;
    //         return null; // swallow: prevent OS caps toggle/LED
    //     }
    //     return event;
    // }

    const code: u16 = @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode));
    const pressed = layerd.Key.initFromKeycode(code) catch unreachable;

    if (active) |layer_key| {
        if (etype == kUp and pressed == layer_key) active = null;
    }
    // TODO: check if there is a layer with that keycode and only then set active
    if (etype == kDown and active == null) active = pressed;

    if (etype == kDown or etype == kUp) {
        if (active) |layer_key| {
            if (store.find(layer_key)) |layer| {
                if (layer.map.get(pressed)) |new_key| {
                    const new = c.CGEventCreateKeyboardEvent(null, new_key.keycode(), etype == kDown);
                    // clear caps flag on synthesized event
                    const mask: u64 = @intCast(c.kCGEventFlagMaskAlphaShift);
                    const flags = c.CGEventGetFlags(event) & ~mask;
                    c.CGEventSetFlags(new, flags);
                    c.CGEventPost(c.kCGHIDEventTap, new);
                    c.CFRelease(new);
                    return null;
                }
            }
        }
        return event;
    }

    return event;
}

fn defaultConfigPath(alloc: std.mem.Allocator) ![]u8 {
    const home = try std.process.getEnvVarOwned(alloc, "HOME");
    defer alloc.free(home);
    return std.fs.path.join(alloc, &.{ home, ".config", "layerd", "config.toml" });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var cfg_path: []const u8 = undefined;
    var free_cfg = false;
    if (args.len >= 2) {
        cfg_path = args[1];
    } else {
        cfg_path = try defaultConfigPath(alloc);
        free_cfg = true;
    }
    defer if (free_cfg) alloc.free(cfg_path);

    var file = try std.fs.cwd().openFile(cfg_path, .{});
    defer file.close();
    const data = try file.readToEndAlloc(alloc, 1 << 16);
    defer alloc.free(data);

    store = try layerd.LayerStore.init(alloc, data);
    defer store.deinit();

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
