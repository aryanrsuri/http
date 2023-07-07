//!                 main.zig
//!     DATE CREATED    July 6, 2023
//!     LICENSE        MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!     Main.zig implements http application
//!
const std = @import("std");
const server = @import("http.zig");
var s = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = s.allocator();

pub fn main() !void {
    var http = server.http_server.init(gpa, "127.0.0.1", 8080);
    defer http.deinit();
    _ = try http.accept();
}
