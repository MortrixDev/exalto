const r = @import("raylib");
const global = @import("global.zig");

const TILE_SIZE = global.TILE_SIZE;

const Tile_Shape = enum {
    NONE,
    SOLID,
    SEMI_SOLID,
    SLOPE_100_LEFT,
    SLOPE_100_RIGHT,
    SLOPE_50_LEFT_BOTTOM,
    SLOPE_50_LEFT_TOP,
    SLOPE_50_RIGHT_BOTTOM,
    SLOPE_50_RIGHT_TOP
};

const Tile_Info = struct {
    index: i32,
    shape: Tile_Shape,
    frame_count: u32,

    pub fn init(index: i32, shape: Tile_Shape) Tile_Info {
        return Tile_Info {
            .index = index,
            .shape = shape,
            .frame_count = 1
        };
    }

    pub fn init_animated(index: i32, frame_count: u32, shape: Tile_Shape) Tile_Info {
        return Tile_Info {
            .index = index,
            .shape = shape,
            .frame_count = frame_count
        };
    }

    pub fn get_rect(self: Tile_Info) r.Rectangle {
        return r.Rectangle.init(
            @floatFromInt(@mod(self.index, 16) * 16),
            @floatFromInt(@divFloor(self.index, 16) * 16),
            TILE_SIZE,
            TILE_SIZE
        );
    }
};

pub const TILE_LOOKUP = [_]Tile_Info {
    // 000 - air
    Tile_Info.init(-1, Tile_Shape.NONE),
    // 001 - brick
    Tile_Info.init(1, Tile_Shape.SOLID)
};
