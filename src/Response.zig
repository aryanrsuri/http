//!                 Response.zig
//!     DATE CREATED    July 7, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!
const Version = @import("Request.zig").Version;
const Accept = @import("Routes.zig").Accept;
const Writer = std.net.Stream.Writer;
const std = @import("std");
const http = std.http;

pub const Response = struct {
    writer: Writer,
    version: Version,

    /// Create a new Response
    /// @param {std.net.Stream.Writer} for writing response to stream
    /// @param {Version} version for context
    /// @returns Response or error
    pub fn init(writer: Writer, version: Version) Response {
        return .{
            .writer = writer,
            .version = version,
        };
    }

    pub fn response(self: *Response, payload: Payload, headers: []const u8) !void {
        try std.io.getStdOut().writer().print("    {s} {any} \r\n", .{ self.version.to_string(), payload.status.code() });
        _ = try self.writer.print("{s} {any} \r\n", .{ self.version.to_string(), payload.status.code() });
        _ = try self.writer.print("{s}\r\n", .{headers});
        _ = try self.writer.write(payload.body);
        _ = try 

        var iter = payload.headers.?.iterator();
        while (iter.next()) |kv| {
            try std.io.getStdOut().writer().print(" {s} : {s} \r\n", .{ kv.key_ptr.*, kv.value_ptr.* });
        }
    }
};

pub const Payload = struct {
    body: []const u8,
    status: Status,
    headers: ?std.StringHashMap([]const u8) = undefined,

    pub fn init(buffer: []const u8, status: Status, headers: ?std.StringHashMap([]const u8)) Payload {
        return .{ .body = buffer, .status = status, .headers = headers };
    }
};

pub const Status = enum(u10) {
    Ok = 200,
    NotFound = 404,

    pub fn code(self: Status) u10 {
        return @intFromEnum(self);
    }

    pub fn string(self: Status) []const u8 {
        return @tagName(self);
    }
};
