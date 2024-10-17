const std = @import("std");
const r = @import("raylib");

const global = @import("global.zig");

const SUBPIXELS = global.SUBPIXELS;
const TILE_SIZE = global.TILE_SIZE;

pub const Vec2 = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Vec2 {
        return .{ .x = x, .y = y };
    }

    pub fn to_ray(self: Vec2) r.Vector2 {
        return r.Vector2.init(
            @floatFromInt(self.x),
            @floatFromInt(self.y),
        );
    }
};

pub const State = struct {
    step_count: u64 = 0,

    camera_pos: Vec2,

    player_pos: Vec2,
    player_vel: Vec2,

    pub fn init() State {
        return State {
            .camera_pos = .{ .x = 0, .y = 0 },

            .player_pos = .{ .x = 0, .y = 0 },
            .player_vel = .{ .x = 0, .y = 0 },
        };
    }

    pub fn update(g: *State) void {
        if (r.isKeyDown(r.KeyboardKey.key_right)) g.player_vel.x = 2 * SUBPIXELS
        else if (r.isKeyDown(r.KeyboardKey.key_left)) g.player_vel.x = -2 * SUBPIXELS
        else g.player_vel.x = 0;

        if (r.isKeyDown(r.KeyboardKey.key_up)) g.player_vel.y = 2 * SUBPIXELS
        else if (r.isKeyDown(r.KeyboardKey.key_down)) g.player_vel.y = -2 * SUBPIXELS
        else g.player_vel.y = 0;

        g.player_pos.x += g.player_vel.x;
        g.player_pos.y += g.player_vel.y;
        
        g.camera_pos = .{
            .x = g.player_pos.x + TILE_SIZE * SUBPIXELS / 2,
            .y = g.player_pos.y + TILE_SIZE * SUBPIXELS / 2,
        };
        g.step_count += 1;
    }
};
