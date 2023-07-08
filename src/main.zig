//!                 Main.zig
//!     DATE CREATED    July 6, 2023
//!     LICENSE        MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!

const std = @import("std");
const Server = @import("Server.zig").Server;

pub fn main() !void {
    var heap = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = heap.allocator();
    var http = Server.init(gpa, "127.0.0.1", 6969);
    defer http.deinit();
    _ = try http.accept();
}
