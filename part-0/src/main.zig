const std = @import("std");

const c = @cImport({
    @cInclude("libtcod.h");
});

pub fn main() anyerror!void {
    // Note that info level log messages are by default printed only in Debug
    // and ReleaseSafe build modes.
    std.log.info("tcod red: {s}", .{c.TCOD_red});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
