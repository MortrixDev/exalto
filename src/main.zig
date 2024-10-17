const std = @import("std");
const r = @import("raylib");

const game = @import("game.zig");
const Renderer = @import("render.zig").Renderer;

pub fn main() !void {
    const screenWidth = 1200;
    const screenHeight = 800;
    
    r.setTraceLogLevel(r.TraceLogLevel.log_warning);
    r.setConfigFlags(r.ConfigFlags{
        .window_resizable = true
    });
    r.initWindow(screenWidth, screenHeight, "Exalto");
    defer r.closeWindow();

    var g = game.State.init();
    var rend = Renderer.init(&g.camera_pos);

    r.setTargetFPS(60);
    while (!r.windowShouldClose()) {
        g.update();
        try rend.render(&g);
    }
}
