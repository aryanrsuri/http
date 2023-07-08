//!                 Routes.zig
//!     DATE CREATED    July 6, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!
const Server = @import("Server.zig").Server;
const Handler = @import("Server.zig").Handler;
const Request = @import("Request.zig").Request;
const Response = @import("Response.zig").Response;
const Payload = @import("Response.zig").Payload;
const Status = @import("Response.zig").Status;
const std = @import("std");
const http = std.http;
const stream = std.net.StreamServer;
const address = std.net.Address;
const @"404" = @embedFile("404.html");
const index = @embedFile("index.html");
const about = @embedFile("index.html");

pub const Accept = enum {
    @"text/html",
    @"text/plain",
    @"application/json",
};
pub const radix = std.ComptimeStringMap([]const u8, .{
    .{
        "/",
        index,
    },
    .{
        "/about",
        about,
    },
});

pub const Routes = struct {
    pub fn init(req: *Request, path: []const u8) !void {
        switch (req.Method) {
            .GET => {
                const r = radix.get(path);
                if (r) |p| {
                    var status = Status.Ok;
                    var payload = Payload.init(p, status, req.Headers);
                    return try req.Response.response(payload, "text/html");
                }
                if (std.mem.eql(u8, "/aryan", path)) {
                    var status = Status.Ok;
                    var payload = Payload.init(" { aryan }", status, req.Headers);
                    return try req.Response.response(payload, "application/json");
                } else {
                    var status = Status.NotFound;
                    var payload = Payload.init(@"404", status, req.Headers);
                    return try req.Response.response(payload, "text/html");
                }
            },
            else => unreachable,
        }
    }
};
