//! zig-roguelike, by @clockworkmartian

const std = @import("std");
const tcod = @import("tcod.zig");
const act = @import("actions.zig");
const ent = @import("entity.zig");
const map = @import("map.zig");
const renderer = @import("renderer.zig");
const ai = @import("ai.zig");
const expect = std.testing.expect;

const Entity = ent.Entity;
const Map = map.Map;

pub const Engine = struct {
    player: *Entity,
    console: tcod.TcodConsole,
    map: *Map,
    isQuit: bool = false,

    pub fn handleEvents(self: *Engine) void {
        var key = tcod.initEmptyKey();
        tcod.sysCheckForEvent(&key);

        if (self.player.component.fighter.hp > 0) {
            const optionalAction = evKeydown(key);
            if (optionalAction) |action| {
                act.perform(action, self);
                if (!self.isQuit) {
                    self.handleEnemyTurns();
                }
            }
        } else {
            const optionalAction = evDeadKeydown(key);
            if (optionalAction) |action| {
                act.perform(action, self);
                // no enemy turns with a dead player
            }
        }
        
        tcod.computeFov(self.map.tcMap, self.player.x, self.player.y);
    }

    pub fn handleEnemyTurns(self: *Engine) void {
        for (self.map.entities.items) |e| {
            if (e != self.player) {
                if (e.ai) |aiType| {
                    ai.act(e, self.player, aiType, self.map);
                }
            }
        }
    }

    pub fn init(player: *Entity, console: tcod.TcodConsole, m: *Map) Engine {
        return Engine{
            .player=player,
            .console=console,
            .map=m,
        };
    }
    
    pub fn quit(self: *Engine) void {
        self.isQuit = true;
    }

    pub fn run(self: *Engine) void {
        while (!tcod.consoleIsWindowClosed() and !self.isQuit) {
            renderer.render(self.console, self.map, self.player);
            self.handleEvents();
        }
    }
};

fn bump(dx: i32, dy: i32) act.ActionType {
    return act.ActionType{ .bumpAction = act.BumpAction{ .dx = dx, .dy = dy }};
}

fn up() act.ActionType { return bump(0,-1); }
fn down() act.ActionType { return bump(0,1); }
fn left() act.ActionType { return bump(-1,0); }
fn right() act.ActionType { return bump(1,0); }
fn upleft() act.ActionType { return bump(-1,-1); }
fn upright() act.ActionType { return bump(1,-1); }
fn downleft() act.ActionType { return bump(-1,1); }
fn downright() act.ActionType { return bump(1,1); }

fn evKeydown(key: tcod.TcodKey) ?act.ActionType {
    if (key.vk == 65) {
        // A regular character was pressed
        if (key.c == 'j') return right()
        else if (key.c == 'h') return left()
        else if (key.c == 'u') return up()
        else if (key.c == 'n') return down()
        else if (key.c == 'k') return right()
        else if (key.c == 'y') return upleft()
        else if (key.c == 'i') return upright()
        else if (key.c == 'b') return downleft()
        else if (key.c == 'm') return downright()
        else return null;
    } else {
        return switch (key.vk) {
            tcod.KeyEscape => act.ActionType{ .escapeAction = act.EscapeAction{} },
            tcod.KeyUp => up(),
            tcod.KeyDown => down(),
            tcod.KeyLeft => left(),
            tcod.KeyRight => right(),
            else => null,
        };
    }
}

fn evDeadKeydown(key: tcod.TcodKey) ?act.ActionType {
    return switch (key.vk) {
        tcod.KeyEscape => act.ActionType{ .escapeAction = act.EscapeAction{} },
        else => null,
    };
}

test "evKeydown up" {
    const action = evKeydown(tcod.initKeyWithVk(tcod.KeyUp)).?;
    try expect(action.bumpAction.dx == 0);
    try expect(action.bumpAction.dy == -1);
}
