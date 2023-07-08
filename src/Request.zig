//!                 Request.zig
//!     DATE CREATED    July 7, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!
const std = @import("std");
const http = std.http;
const net = std.net;
const Method = http.Method;
const Response = @import("Response.zig");

pub const Request = struct {
    Method: Method,
    Uri: []const u8,
    Version: Version,
    Reader: net.Stream.Reader,
    Writer: net.Stream.Writer,
    Headers: std.StringHashMap([]const u8) = undefined,
    Response: Response.Response,

    /// Create a new Request
    /// @param {std.mem.Allocator} allocator for hash map
    /// @param {net.Stream.reader} reader
    /// @returns Request or error
    pub fn init(allocator: std.mem.Allocator, writer: net.Stream.Writer, reader: net.Stream.Reader) !Request {
        const request = try reader.readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
        var iter = std.mem.tokenize(u8, request, " ");
        var map = std.StringHashMap([]const u8).init(allocator);
        var M = try parse_method(iter.next().?);
        var U = iter.next().?;
        var V = try Version.parse(iter.next().?);

        while (true) {
            const headers = try reader.readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
            if (headers.len == 1 and std.mem.eql(u8, headers, "\r")) break;
            var iter_h = std.mem.tokenize(u8, headers, ":");
            try map.put(iter_h.next().?, iter_h.rest());
        }

        return .{
            .Method = M,
            .Uri = U,
            .Version = V,
            .Writer = writer,
            .Reader = reader,
            .Headers = map,
            .Response = Response.Response.init(
                writer,
                V,
            ),
        };
    }

    pub fn print(self: *Request, writer: net.Stream.Writer) !void {
        try std.io.getStdOut().writer().print("\n    {s} {s} {s}\n", .{ to_string_method(&self.Method), self.Uri, self.Version.to_string() });
        _ = writer;
        // // try writer.print(" \n REQUEST \n Method: {s} \n Uri: {s} \n Version: {s} \n", .{ to_string_method(&self.Method), self.Uri, self.Version.to_string() });
        // var iter_v = self.Headers.iterator();
        // while (iter_v.next()) |val| {
        //     try std.io.getStdOut().writer().print(" {s}: {s}\n", .{ val.key_ptr.*, val.value_ptr.* });
        // }
    }
};

/// This could be using stringtoenum but I am not sure which is faster ...
pub const Map_Method = std.ComptimeStringMap(Method, .{
    .{ "GET", .GET },
    .{ "HEAD", .HEAD },
    .{ "POST", .POST },
    .{ "PUT", .PUT },
    .{ "DELETE", .DELETE },
    .{ "CONNECT", .CONNECT },
    .{ "OPTIONS", .OPTIONS },
    .{ "TRACE", .TRACE },
    .{ "PATCH", .PATCH },
});

/// From string
/// @param {[]const u8} buffer string
/// @returns parsed Method or error
pub fn parse_method(buffer: []const u8) !Method {
    return Map_Method.get(buffer) orelse error.InvalidMethod;
}

/// To string method
/// @param{Method} method type
/// @returns string or error
pub fn to_string_method(method: *Method) []const u8 {
    return @tagName(method.*);
}

/// Version enum
pub const Version = enum {
    @"HTTP/1.0",
    @"HTTP/1.1",
    @"HTTP/2.0",

    /// From string to Version
    /// @param {[]const u8} buffer string
    /// @returns parsed Version or error
    pub fn parse(buffer: []const u8) !Version {
        var trim = std.mem.trim(u8, buffer, " \r");
        return std.meta.stringToEnum(Version, trim) orelse error.InvalidVersion;
    }

    pub fn to_string(version: *Version) []const u8 {
        return @tagName(version.*);
    }
};

//     var req: Request = .{
//         .uri = uri,
//         .client = client,
//         .connection = conn,
//         .headers = headers,
//         .method = method,
//         .version = options.version,
//         .redirects_left = options.max_redirects,
//         .handle_redirects = options.handle_redirects,
//         .response = .{
//             .status = undefined,
//             .reason = undefined,
//             .version = undefined,
//             .headers = http.Headers{ .allocator = client.allocator, .owned = false },
//             .parser = switch (options.header_strategy) {
//                 .dynamic => |max| proto.HeadersParser.initDynamic(max),
//                 .static => |buf| proto.HeadersParser.initStatic(buf),
//             },
//         },
//         .arena = undefined,
//     };
//     errdefer req.deinit();
//
//     req.arena = std.heap.ArenaAllocator.init(client.allocator);
//
//     return req;
// }
