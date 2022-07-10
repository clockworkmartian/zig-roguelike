//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const models = @import("models.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const expect = std.testing.expect;

const Coord = struct {
    x: i32,
    y: i32,
};

pub const RectangularRoom = struct {
    x1: i32,
    y1: i32,
    x2: i32,
    y2: i32,

    pub fn center(self: RectangularRoom) Coord {
        return Coord{
            .x = @divTrunc(self.x1 + self.x2, 2),
            .y = @divTrunc(self.y1 + self.y2, 2),
        };
    }

    pub fn inner(self: RectangularRoom, allocator: Allocator) ![]Coord {
        var innerList = ArrayList(Coord).init(allocator);
        defer innerList.deinit();
        var xi: i32 = self.x1 + 1;
        var yi: i32 = self.y1 + 1;
        while (xi < self.x2) : ({
            xi += 1;
            yi += 1;
        }) {
            try innerList.append(.{ .x = xi, .y = yi });
        }
        return innerList.toOwnedSlice();
    }

    pub fn init(x: i32, y: i32, width: i32, height: i32) RectangularRoom {
        return RectangularRoom{
            .x1 = x,
            .y1 = y,
            .x2 = width + x,
            .y2 = height + y,
        };
    }
};

pub fn generateDungeon(width: i32, height: i32, allocator: Allocator) !models.Map {
    var map = try models.Map.init(width, height, allocator);

    var room1 = RectangularRoom.init(10, 15, 5, 5);
    // var room2 = RectangularRoom.init(25, 15, 5, 5);

    var room1Inner = try room1.inner(allocator);
    // var room2Inner = try room2.inner(allocator);

    for (room1Inner) |coord| {
        map.set(coord.x, coord.y, models.FLOOR);
    }

    // for (room2Inner) |coord| {
    //     map.set(coord.x, coord.y, models.FLOOR);
    // }

    return map;
}

test "rectangularroom.init" {
    const rr = RectangularRoom.init(1, 2, 10, 8);
    try expect(rr.x1 == 1);
    try expect(rr.y1 == 2);
    try expect(rr.x2 == 11);
    try expect(rr.y2 == 10);
}

test "rectangularroom.center" {
    const rr = RectangularRoom.init(1, 1, 11, 11);
    const center = rr.center();
    try expect(center.x == 6);
    try expect(center.y == 6);
}

test "rectangularroom.inner" {
    const rr = RectangularRoom.init(1, 1, 3, 3);
    var inner = try rr.inner(std.testing.allocator);
    defer std.testing.allocator.free(inner);
    try expect(std.meta.eql(inner[0], Coord{ .x = 2, .y = 2 }));
    try expect(std.meta.eql(inner[1], Coord{ .x = 3, .y = 3 }));
    try expect(inner.len == 2);
}
