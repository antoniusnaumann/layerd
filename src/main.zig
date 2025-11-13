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
    const kFlg = c.kCGEventFlagsChanged;

    const code: u16 = @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode));
    const pressed = layerd.Key.initFromKeycode(code) catch return event;

    // Handle modifier keys (caps_lock, shift, control, etc.) via flag changes
    if (etype == kFlg and pressed.isFlagKey()) {
        // Check if this is a layer trigger
        if (store.find(pressed)) |_| {
            // Determine if the key is pressed or released based on flags
            const flags = c.CGEventGetFlags(event);
            const is_pressed = switch (pressed) {
                .caps_lock => (flags & c.kCGEventFlagMaskAlphaShift) != 0,
                .shift, .right_shift => (flags & c.kCGEventFlagMaskShift) != 0,
                .control, .right_control => (flags & c.kCGEventFlagMaskControl) != 0,
                .option, .right_option => (flags & c.kCGEventFlagMaskAlternate) != 0,
                .command => (flags & c.kCGEventFlagMaskCommand) != 0,
                .function_key => (flags & c.kCGEventFlagMaskSecondaryFn) != 0,
                else => false,
            };

            if (is_pressed) {
                active = pressed;
                std.log.info("Layer activated: {s}", .{@tagName(pressed)});
                // Swallow the event to prevent caps_lock from toggling
                if (pressed == .caps_lock) return null;
            } else {
                if (active == pressed) {
                    std.log.info("Layer deactivated: {s}", .{@tagName(pressed)});
                    active = null;
                }
            }
        }
        return event;
    }

    // Handle regular key events (non-modifiers)
    if (etype == kDown or etype == kUp) {
        // If no layer is active and this is a keydown, check if it's a layer trigger
        if (active == null and etype == kDown and !pressed.isFlagKey()) {
            if (store.find(pressed)) |_| {
                active = pressed;
                std.log.info("Layer activated: {s}", .{@tagName(pressed)});
            }
        }

        // If a layer is active, check for remapping
        if (active) |layer_key| {
            // Release layer if the trigger key is released
            if (etype == kUp and pressed == layer_key) {
                std.log.info("Layer deactivated: {s}", .{@tagName(pressed)});
                active = null;
            }

            // Try to remap the current key
            if (store.find(layer_key)) |layer| {
                if (layer.map.get(pressed)) |new_key| {
                    std.log.info("Remapping: {s} -> {s}", .{ @tagName(pressed), @tagName(new_key) });
                    const new = c.CGEventCreateKeyboardEvent(null, new_key.keycode(), etype == kDown);
                    // Clear caps flag on synthesized event
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

    // Print registered layers
    std.log.info("Loaded {} layer(s):", .{store.layers.items.len});
    for (store.layers.items, 0..) |layer, i| {
        if (layer.trigger) |trigger| {
            std.log.info("  Layer {}: trigger={s} ({} mapping(s))", .{ i, @tagName(trigger), layer.map.count() });
            var it = layer.map.iterator();
            while (it.next()) |entry| {
                std.log.info("    {s} -> {s}", .{ @tagName(entry.key_ptr.*), @tagName(entry.value_ptr.*) });
            }
        } else {
            std.log.info("  Layer {}: base layer ({} mapping(s))", .{ i, layer.map.count() });
            var it = layer.map.iterator();
            while (it.next()) |entry| {
                std.log.info("    {s} -> {s}", .{ @tagName(entry.key_ptr.*), @tagName(entry.value_ptr.*) });
            }
        }
    }

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
