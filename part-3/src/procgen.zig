//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const models = @import("models.zig");
const tcod = @import("tcod.zig");
const RndGen = std.rand.DefaultPrng;
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
        while (xi < self.x2) : (xi += 1) {
            var yi: i32 = self.y1 + 1;
            while (yi < self.y2) : (yi += 1) {
                try innerList.append(.{ .x = xi, .y = yi });
            }
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

    pub fn intersects(self: RectangularRoom, other: RectangularRoom) bool {
        return self.x1 <= other.x2 and self.x2 >= other.x1 and self.y1 <= other.y2 and self.y2 >= other.y1;
    }
};

pub fn tunnelBetween(start: Coord, end: Coord, allocator: Allocator) ![]Coord {
    var rnd = RndGen.init(0);
    rnd.seed(@intCast(u64, std.time.milliTimestamp()));

    var innerList = ArrayList(Coord).init(allocator);
    defer innerList.deinit();

    var cornerX: i32 = undefined;
    var cornerY: i32 = undefined;
    if (rnd.random().intRangeAtMost(i32, 0, 1) == 0) {
        cornerX = end.x;
        cornerY = start.y;
    } else {
        cornerX = start.x;
        cornerY = end.y;
    }

    try line(start, .{.x=cornerX,.y=cornerY}, &innerList);
    try line(.{.x=cornerX,.y=cornerY}, end, &innerList);

    return innerList.toOwnedSlice();
}

test "tunnelBetween" {
    var t = try tunnelBetween(.{.x=0,.y=0}, .{.x=5,.y=5}, std.testing.allocator);
    defer std.testing.allocator.free(t);
    // std.debug.print("tunnel: {s}\n", .{t});
    try expect(t.len == 10);
    try expect(std.meta.eql(t[4], .{.x=0,.y=5}) or std.meta.eql(t[5], .{.x=5,.y=0}));
}

pub fn line(start: Coord, end: Coord, innerList: *ArrayList(Coord)) !void {
    var x: i32 = undefined;
    var y: i32 = undefined;
    tcod.lineInit(start.x, start.y, end.x, end.y);
    _ = tcod.lineStep(&x, &y); // todo: replace this with lineStep returning a coord instead?
    try innerList.append(.{ .x = x, .y = y });
    while (!tcod.lineStep(&x, &y)) {
        try innerList.append(.{ .x = x, .y = y });
    }
    // return innerList.toOwnedSlice();
}

pub fn generateDungeon(max_rooms: usize, room_min_size: i32, room_max_size: i32, width: i32, height: i32, player: *models.Entity, allocator: Allocator) !models.Map {
    var map = try models.Map.init(width, height, allocator);

    var rooms = try allocator.alloc(RectangularRoom, max_rooms);
    defer allocator.free(rooms);
    
    var rnd = RndGen.init(0);
    rnd.seed(@intCast(u64, std.time.milliTimestamp()));

    var i: usize = 0;
    while (i < max_rooms) : (i += 1) {
        const roomWidth = rnd.random().intRangeAtMost(i32, room_min_size, room_max_size);
        const roomHeight = rnd.random().intRangeAtMost(i32, room_min_size, room_max_size);

        const x = rnd.random().intRangeAtMost(i32, 0, width - roomWidth - 1);
        const y = rnd.random().intRangeAtMost(i32, 0, height - roomHeight - 1);

        var room = RectangularRoom.init(x,y,roomWidth, roomHeight);

        // intersections

        // carve out the room insides
        var roomInner = try room.inner(allocator);
        defer allocator.free(roomInner);
        for (roomInner) |coord| {
            map.set(coord.x, coord.y, models.FLOOR);
        }

        if (i == 0) {
            const center = room.center();
            player.x = center.x;
            player.y = center.y;
        } else {
            // tunnels
        }

        rooms[i] = room;
    }

    //     # Run through the other rooms and see if they intersect with this one.
    //     if any(new_room.intersects(other_room) for other_room in rooms):
    //         continue  # This room intersects, so go to the next attempt.
    //     # If there are no intersections then the room is valid.

    //     if len(rooms) == 0:
    //         # The first room, where the player starts.
    //         player.x, player.y = new_room.center
    //     else:  # All rooms after the first.
    //         # Dig out a tunnel between this room and the previous one.
    //         for x, y in tunnel_between(rooms[-1].center, new_room.center):
    //             dungeon.tiles[x, y] = tile_types.floor

    return map;
}

test "line" {
    var innerList = ArrayList(Coord).init(std.testing.allocator);
    defer innerList.deinit();
    try line(.{.x=0,.y=0}, .{.x=2,.y=2}, &innerList);
    try expect(innerList.items.len == 2);
    try expect(std.meta.eql(innerList.items[0], Coord{.x=1,.y=1}));
    try expect(std.meta.eql(innerList.items[1], Coord{.x=2,.y=2}));
}

test "rectangularroom.intersects true" {
    const r1 = RectangularRoom.init(1, 1, 5, 5);
    const r2 = RectangularRoom.init(3,3, 5, 5);
    try expect(r1.intersects(r2) == true);
}

test "rectangularroom.intersects false" {
    const r1 = RectangularRoom.init(1, 1, 5, 5);
    const r2 = RectangularRoom.init(8, 8, 5, 5);
    try expect(r1.intersects(r2) == false);
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
    try expect(std.meta.eql(inner[1], Coord{ .x = 2, .y = 3 }));
    try expect(inner.len == 4);
}
