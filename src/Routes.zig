//!                 Server.zig
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
const std = @import("std");
const http = std.http;
const stream = std.net.StreamServer;
const address = std.net.Address;
const index = @embedFile("index.html");

pub fn Routes() !void {

    // std.net.tcpConnectToHost()
}
