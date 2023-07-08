//!                 Response.zig
//!     DATE CREATED    July 7, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!
const Version = @import("Request.zig").Version;
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

    pub fn response(self: *Response, payload: Payload) !void {
        try self.writer.print(" \n RESPONSE PAYLOAD \n Version: {s} \n Status: ({any}) ({s})\n", .{ self.version, payload.status.code(), payload.status.string() });
        if (payload.headers) |headers| {
            var iter = headers.iterator();
            while (iter.next()) |val| {
                try self.writer.print(" {s}: {s}\n", .{ val.key_ptr.*, val.value_ptr.* });
            }
        }
    }
};

pub const Payload = struct {
    body: []const u8,
    status: Status,
    headers: ?std.StringHashMap([]const u8) = undefined,
};
pub const Status = enum(u10) {
    Ok = 200,
    NotFound = 404,

    pub fn code(self: *Status) u10 {
        return @enumToInt(self);
    }

    pub fn string(self: *Status) []const u8 {
        return @tagName(self);
    }
};
