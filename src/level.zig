const std = @import("std");

pub const Level = struct {
    width: u32,
    height: u32,
    tiles: []u16,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !Level {
        return Level{
            .width = width,
            .height = height,
            .tiles = try allocator.alloc(u16, width * height)
        };
    }
};
