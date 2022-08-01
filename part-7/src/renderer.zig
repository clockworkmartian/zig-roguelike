//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const tcod = @import("tcod.zig");
const map = @import("map.zig");
const color = @import("color.zig");
const ent = @import("entity.zig");
const Allocator = std.mem.Allocator;

pub fn render(console: tcod.TcodConsole, m: *map.Map, player: *ent.Entity) void {
    tcod.consoleClear(console);
    renderMap(console, m);
    renderBar(console, player.component.fighter.hp, player.component.fighter.maxHp, 20, m.allocator);
    tcod.consoleBlit(console, m.width, m.height);
    tcod.consoleFlush();
}

fn renderBar(console: tcod.TcodConsole, curValue: i32, maxValue: i32, totWidth: i32, allocator: Allocator) void {
    var barWidth = @floatToInt(i32, @intToFloat(f32, curValue) / @intToFloat(f32, maxValue) * @intToFloat(f32, totWidth)); // cast?

    tcod.consoleDrawRectRgb(console, 0, 45, totWidth, 1, 1, color.Bar_empty, color.Bar_empty);

    if (barWidth > 0) {
        tcod.consoleDrawRectRgb(console, 0, 45, barWidth, 1, 1, color.Bar_filled, color.Bar_filled);
    }

    var msg = std.fmt.allocPrint(allocator, "hp: {d}/{d}", 
        .{curValue, maxValue}) catch @panic("eom");
    tcod.consolePrintFg(console, 1, 45, msg, color.White_rgb);
    allocator.free(msg);
}

fn renderMap(console: tcod.TcodConsole, m: *map.Map) void {
    var x: i32 = 0;
    var y: i32 = 0;
    for (m.cells) |t, index| {
        if (tcod.mapIsInFov(m.tcMap, x, y)) {
            m.cells[index].visible = true;
            m.cells[index].explored = true;
        } else {
            m.cells[index].visible = false;
        }

        if (t.visible) {
            console.tiles[index].ch = t.light.ch;
            console.tiles[index].fg = t.light.fg;
            console.tiles[index].bg = t.light.bg;
        } else if (t.explored) {
            console.tiles[index].ch = t.dark.ch;
            console.tiles[index].fg = t.dark.fg;
            console.tiles[index].bg = t.dark.bg;
        } else {
            console.tiles[index].ch = color.SHROUD.ch;
            console.tiles[index].fg = color.SHROUD.fg;
            console.tiles[index].bg = color.SHROUD.bg;
        }

        x += 1;
        if (@mod(x,m.width) == 0) {
            y += 1;
            x = 0;
        }
    }

    var orderedEntities = m.getRenderOrderedEntities();

    for (orderedEntities) |e| {
        var tile = m.get(e.x,e.y);
        if (tile.visible) {
            var bg = .{.r=tile.light.bg.r,.g=tile.light.bg.g,.b=tile.light.bg.b};
            tcod.consolePutCharEx(console, e.x, e.y, e.glyph, e.color, bg);
        }
    }

    m.allocator.free(orderedEntities);
}