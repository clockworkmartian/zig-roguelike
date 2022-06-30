const std = @import("std");
const c = @cImport({
    @cInclude("libtcod.h");
});
const SCREEN_WIDTH = 40;
const SCREEN_HEIGHT = 25;
const ASCII_AT = 64;

const MovementAction = struct { dx: i8, dy: i8 };

fn initKey() c.TCOD_key_t {
    return c.TCOD_key_t{ .vk = c.TCODK_NONE, .c = 0, .text = undefined, .pressed = undefined, .lalt = undefined, .lctrl = undefined, .lmeta = undefined, .ralt = undefined, .rctrl = undefined, .rmeta = undefined, .shift = undefined };
}

pub fn main() anyerror!void {
    _ = c.TCOD_console_init_root(SCREEN_WIDTH, SCREEN_HEIGHT, "Zig Roguelike", true, c.TCOD_RENDERER_SDL2);
    defer { // Make sure the quit function is called when main() exits
        c.TCOD_quit();
    }

    var key = initKey(); // key variable for holding event key data
    var playerX: u8 = SCREEN_WIDTH / 2; // initial player x position
    var playerY: u8 = SCREEN_HEIGHT / 2; // initial player y position
    std.log.info("player x: {d}, y: {d}", .{ playerX, playerY });

    _ = c.TCOD_console_set_custom_font("../dejavu10x10_gs_tc.png", c.TCOD_FONT_TYPE_GREYSCALE | c.TCOD_FONT_LAYOUT_TCOD, 0, 0);

    while (!c.TCOD_console_is_window_closed()) {
        // Clear
        c.TCOD_console_clear(null);

        // Render
        c.TCOD_console_set_char(null, playerX, playerY, ASCII_AT); // draw the player symbol
        _ = c.TCOD_console_flush(); // render the drawn console to the screen

        // Events
        _ = c.TCOD_sys_check_for_event(c.TCOD_EVENT_KEY_PRESS, &key, null);

        switch (key.vk) {
            c.TCODK_ESCAPE => {
                return;
            },
            c.TCODK_UP => {
                playerY -= 1;
            },
            c.TCODK_DOWN => {
                playerY += 1;
            },
            c.TCODK_LEFT => {
                playerX -= 1;
            },
            c.TCODK_RIGHT => {
                playerX += 1;
            },
            else => {},
        }
    }
}
