const std = @import("std");
const r = @import("raylib");

const game = @import("game.zig");
const global = @import("global.zig");
const assets = @import("assets.zig");

const Vec2 = game.Vec2;

const SUBPIXELS = global.SUBPIXELS;
const TILE_SIZE = global.TILE_SIZE;
const VIEW_SIZE = global.VIEW_SIZE;

pub const Renderer = struct {
    camera_pos: *Vec2,
    canvas: r.RenderTexture,
    atlas: r.Texture,

    pub fn init(camera_pos: *Vec2) Renderer {
        return Renderer {
            .canvas = r.RenderTexture.init(VIEW_SIZE, VIEW_SIZE),
            .camera_pos = camera_pos,
            .atlas = r.loadTextureFromImage(r.loadImage("assets/atlas.png"))
        };
    }

    pub fn render(rend: *Renderer, g: *game.State) !void {
        r.beginDrawing();

        r.beginTextureMode(rend.canvas);
        r.clearBackground(r.Color.init(0x22, 0x22, 0x22, 0xFF));

        rend.draw_rect_v(Vec2.init(0, 0), Vec2.init(TILE_SIZE, TILE_SIZE), r.Color.white);
        rend.draw_tile(rend.atlas, Vec2.init(0, 0), 1);
        rend.draw_rect_v(g.player_pos, Vec2.init(TILE_SIZE, TILE_SIZE), r.Color.orange);

        r.endTextureMode();

        const aspect_ratio: f32 = @as(f32, @floatFromInt(r.getScreenWidth())) / @as(f32, @floatFromInt(r.getScreenHeight()));

        const width: f32 = if (aspect_ratio > 1) VIEW_SIZE else @as(f32, @floatFromInt(VIEW_SIZE)) * aspect_ratio;
        const height: f32 = if (aspect_ratio > 1) @as(f32, @floatFromInt(VIEW_SIZE)) / aspect_ratio else VIEW_SIZE;

        const offset_x: f32 = if (aspect_ratio > 1) 0 else (VIEW_SIZE - width) / 2;
        const offset_y: f32 = if (aspect_ratio > 1) (VIEW_SIZE - height) / 2 else 0;
        
        r.drawTexturePro(
            rend.canvas.texture,
            r.Rectangle.init(offset_x, offset_y, width, height),
            r.Rectangle.init(0, 0, @floatFromInt(r.getScreenWidth()), @floatFromInt(r.getScreenHeight())),
            r.Vector2.init(0, 0),
            0,
            r.Color.white);

        var debug_info_buffer: [1000]i8 = undefined;
        @memset(&debug_info_buffer, 0);

        _ = try std.fmt.bufPrint(@ptrCast(&debug_info_buffer),
            "x: {}\n" ++
            "y: {}",
            .{
                @divTrunc(g.player_pos.x, SUBPIXELS),
                @divTrunc(g.player_pos.y, SUBPIXELS)
            });

        r.drawText(@ptrCast(&debug_info_buffer), 10, 10, 20, r.Color.white);

        r.endDrawing();
    }

    fn to_screen_x(rend: *Renderer, x: i32) i32 {
        return @divTrunc(x - rend.camera_pos.x, SUBPIXELS) + VIEW_SIZE / 2;
    }

    fn to_screen_y(rend: *Renderer, x: i32) i32 {
        return @divTrunc(x - rend.camera_pos.y, SUBPIXELS) + VIEW_SIZE / 2;
    }

    fn to_screen_v(rend: *Renderer, pos: Vec2) r.Vector2 {
        return r.Vector2.init(
            @floatFromInt(rend.to_screen_x(pos.x)),
            @floatFromInt(rend.to_screen_y(pos.y))
        );
    }

    fn draw_rect_v(rend: *Renderer, pos: Vec2, size: Vec2, color: r.Color) void {
        r.drawRectangleV(
            rend.to_screen_v(pos),
            size.to_ray(),
            color);
    }

    fn draw_tile(rend: *Renderer, atlas: r.Texture, pos: Vec2, tile_id: u32) void {
        r.drawTextureRec(
            atlas,
            assets.TILE_LOOKUP[tile_id].get_rect(),
            rend.to_screen_v(pos),
            r.Color.white);
    }
};
