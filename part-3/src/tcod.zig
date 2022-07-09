//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const models = @import("models.zig");
const expect = std.testing.expect;

const c = @cImport({
    @cInclude("libtcod.h");
});

pub const TcodConsole = *c.TCOD_Console;
pub const TcodColorRGBA = c.TCOD_ColorRGBA;
pub const TcodColorRGB = c.TCOD_ColorRGB;
pub const TcodKey = c.TCOD_key_t;
pub const TcodMouse = c.TCOD_mouse_t;
pub const KeyEscape = c.TCODK_ESCAPE;
pub const KeyUp = c.TCODK_UP;
pub const KeyDown = c.TCODK_DOWN;
pub const KeyLeft = c.TCODK_LEFT;
pub const KeyRight = c.TCODK_RIGHT;
pub const KeyNone = c.TCODK_NONE;

pub fn consoleInitRoot(width: i32, height: i32, title: [*]const u8, fullscreen: bool) void {
    _ = c.TCOD_console_init_root(width, height, title, fullscreen, c.TCOD_RENDERER_SDL2);
}

pub fn quit() void {
    c.TCOD_quit();
}

pub fn consoleSetCustomFont(filepath: [*]const u8) void {
    _ = c.TCOD_console_set_custom_font(filepath, c.TCOD_FONT_TYPE_GREYSCALE | c.TCOD_FONT_LAYOUT_TCOD, 0, 0);
}

pub fn consoleNew(width: i32, height: i32) TcodConsole {
    return c.TCOD_console_new(width, height);
}

pub fn consoleIsWindowClosed() bool {
    return c.TCOD_console_is_window_closed();
}

pub fn consolePutCharEx(con: TcodConsole, x: i32, y: i32, character: u8, fore: TcodColorRGB, back: TcodColorRGB) void {
    c.TCOD_console_put_char_ex(con, x, y, character, fore, back);
}

pub fn consoleClear(con: TcodConsole) void {
    c.TCOD_console_clear(con);
}

pub fn consoleBlit(con: TcodConsole, width: i32, height: i32) void {
    c.TCOD_console_blit(con,0,0,width,height,null,0,0,1.0,1.0);
}

pub fn sysCheckForEvent(key: *TcodKey) void {
    _ = c.TCOD_sys_check_for_event(c.TCOD_EVENT_KEY_PRESS, key, null);
}

pub fn consoleFlush() void {
    _ = c.TCOD_console_flush();
}

pub fn renderMap(console: TcodConsole, map: *models.Map) void {
    for (map.tiles) |t, index| {
        console.tiles[index].ch = t.dark.ch;
        console.tiles[index].fg = t.dark.fg;
        console.tiles[index].bg = t.dark.bg;
    }
}