# Part 3: Generating a dungeon

## fill with wall instead of floor

`models.zig`:

```diff
@@ -102,16 +102,9 @@ pub const Map = struct {
         const size = width * height;
         var tiles = try allocator.alloc(Tile, @intCast(usize, size));
         var m = Map{.width=width, .height=height, .allocator=allocator, .tiles=tiles};
-        m.fill(FLOOR);
+        m.fill(WALL);
         return m;
     }
-
-    pub fn addSomeWalls(self: *Map) void {
-        self.tiles[200] = WALL;
-        self.tiles[201] = WALL;
-        self.tiles[505] = WALL;
-        self.tiles[550] = WALL;
-    }
 };
```

`main.zig`:

```diff
@@ -37,7 +37,6 @@ pub fn main() anyerror!void {
     }
 
     var map = try models.Map.init(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, allocator);
-    map.addSomeWalls();
     defer {
         map.deinit();
     }
```

## 