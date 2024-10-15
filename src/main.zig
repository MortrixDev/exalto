const std = @import("std");
const r = @import("raylib");

const SUBPIXELS: i32 = 16;
const TILE_SIZE: i32 = 16;
const VIEW_SIZE: i32 = 16 * TILE_SIZE;

pub fn main() !void {
    const screenWidth = 1200;
    const screenHeight = 800;
    
    r.setTraceLogLevel(r.TraceLogLevel.log_warning);
    r.setConfigFlags(r.ConfigFlags{
        .window_resizable = true
    });
    r.initWindow(screenWidth, screenHeight, "Exalto");
    defer r.closeWindow();

    var g = GameState.init();
    var rend = Renderer.init();

    r.setTargetFPS(60);
    while (!r.windowShouldClose()) {
        g.update();
        try g.render(&rend);
    }
}

const Vec2 = struct {
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

const Renderer = struct {
    canvas: r.RenderTexture,
    atlas: r.Texture,

    pub fn init() Renderer {
        return Renderer {
            .canvas = r.RenderTexture.init(VIEW_SIZE, VIEW_SIZE),
            .atlas = r.loadTextureFromImage(r.loadImage("assets/atlas.png"))
        };
    }
};

const GameState = struct {
    step_count: u64 = 0,

    camera_pos: Vec2,

    player_pos: Vec2,
    player_vel: Vec2,

    pub fn init() GameState {
        return GameState {
            .camera_pos = .{ .x = 0, .y = 0 },

            .player_pos = .{ .x = 0, .y = 0 },
            .player_vel = .{ .x = 0, .y = 0 },
        };
    }

    pub fn update(g: *GameState) void {
        if (r.isKeyDown(r.KeyboardKey.key_right)) g.player_vel.x = 20
        else if (r.isKeyDown(r.KeyboardKey.key_left)) g.player_vel.x = -20
        else g.player_vel.x = 0;

        if (r.isKeyDown(r.KeyboardKey.key_up)) g.player_vel.y = 20
        else if (r.isKeyDown(r.KeyboardKey.key_down)) g.player_vel.y = -20
        else g.player_vel.y = 0;

        g.player_pos.x += g.player_vel.x;
        g.player_pos.y += g.player_vel.y;
        
        g.camera_pos = .{
            .x = g.player_pos.x + TILE_SIZE * SUBPIXELS / 2,
            .y = g.player_pos.y + TILE_SIZE * SUBPIXELS / 2,
        };
        g.step_count += 1;
    }

    pub fn render(g: *GameState, rend: *Renderer) !void {
        r.beginDrawing();

        r.beginTextureMode(rend.canvas);
        r.clearBackground(r.Color.init(0x22, 0x22, 0x22, 0xFF));

        g.draw_rect_v(Vec2.init(0, 0), Vec2.init(TILE_SIZE, TILE_SIZE), r.Color.white);
        g.draw_rect_v(g.player_pos, Vec2.init(TILE_SIZE, TILE_SIZE), r.Color.orange);

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

    fn to_screen_x(g: *GameState, x: i32) i32 {
        return @divTrunc(x - g.camera_pos.x, SUBPIXELS) + VIEW_SIZE / 2;
    }

    fn to_screen_y(g: *GameState, x: i32) i32 {
        return @divTrunc(x - g.camera_pos.y, SUBPIXELS) + VIEW_SIZE / 2;
    }

    fn to_screen_v(g: *GameState, pos: Vec2) r.Vector2 {
        return r.Vector2.init(
            @floatFromInt(g.to_screen_x(pos.x)),
            @floatFromInt(g.to_screen_y(pos.y))
        );
    }

    fn draw_rect_v(g: *GameState, pos: Vec2, size: Vec2, color: r.Color) void {
        r.drawRectangleV(
            g.to_screen_v(pos),
            size.to_ray(),
            color);
    }
};
