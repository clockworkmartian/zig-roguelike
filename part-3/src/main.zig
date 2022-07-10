//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const tcod = @import("tcod.zig");
const models = @import("models.zig");
const engine = @import("engine.zig");
const constants = @import("constants.zig");
const expect = std.testing.expect;

// import tests from dependency modules
test {
    _ = @import("tcod.zig");
    _ = @import("engine.zig");
    _ = @import("models.zig");
    _ = @import("procgen.zig");
}

pub fn main() anyerror!void {
    tcod.consoleInitRoot(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, "Zig Roguelike", true);
    defer {
        tcod.quit();
    }
    tcod.consoleSetCustomFont("../dejavu10x10_gs_tc.png");

    var console = tcod.consoleNew(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT);

    var player = models.Entity{ .x = constants.SCREEN_WIDTH / 2, .y = constants.SCREEN_HEIGHT / 2, .glyph = constants.ASCII_AT, .color = tcod.TcodColorRGB{ .r = 255, .g = 255, .b = 255 } };

    var npc = models.Entity{ .x = constants.SCREEN_WIDTH / 2 - 5, .y = constants.SCREEN_HEIGHT / 2, .glyph = constants.ASCII_AT, .color = tcod.TcodColorRGB{ .r = 255, .g = 255, .b = 0 } };

    var entities = [_]*models.Entity{ &player, &npc };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const leaked = gpa.deinit();
        if (leaked) expect(false) catch @panic("FAIL");
    }

    var map = try models.Map.init(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, allocator);
    defer {
        map.deinit();
    }

    var eng = engine.Engine.init(&entities, &player, console, &map);

    while (!tcod.consoleIsWindowClosed()) {
        eng.render();
        eng.handleEvents();
    }
}
