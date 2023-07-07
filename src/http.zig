//!                 http.zig
//!     DATE CREATED    July 6, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!     http.zig http_server struct
//!
const std = @import("std");
const http = std.http;
const net = std.net;
const stream = net.StreamServer;
const address = net.Address;

pub const io_mode = .evented;
pub const http_server = struct {
    const Self = @This();
    port: u16,
    serve: stream,
    addr: address,
    connection: stream.Connection = undefined,
    alloc: std.mem.Allocator,
    pub const Request = struct {
        Method: http.Method,
        Uri: []const u8,
        Version: []const u8,
        Headers: std.StringHashMap([]const u8) = undefined,
        // Body: []const u8,
    };

    pub fn init(alloc: std.mem.Allocator, name: []const u8, port: u16) Self {
        var serve = stream.init(.{});
        const addr = address.resolveIp(name, port) catch {
            @panic("IP failed to resolve");
        };
        serve.listen(addr) catch {
            @panic("Server listen failed!");
        };

        std.io.getStdOut().writer().print("LISTENING ON PORT {} \n", .{port}) catch {
            @panic("Stdout failed to allocate");
        };
        return .{
            .port = port,
            .serve = serve,
            .addr = addr,
            .alloc = alloc,
        };
    }

    pub fn accept(self: *Self) !void {
        while (true) {
            const connection = self.serve.accept() catch {
                @panic("Connection attempt unsuccsesful");
            };
            self.connection = connection;
            _ = try self.handler();
        }
    }

    pub fn handler(self: *Self) !Request {
        defer self.connection.stream.close();
        const req = try self.connection.stream.reader().readUntilDelimiterAlloc(self.alloc, '\n', std.math.maxInt(usize));
        try self.connection.stream.writer().print("{s} \n {any}\n", .{ req, req });
        var iter = std.mem.tokenize(u8, req, " ");
        var map = std.StringHashMap([]const u8).init(self.alloc);

        while (true) {
            const headers = try self.connection.stream.reader().readUntilDelimiterAlloc(self.alloc, '\n', std.math.maxInt(usize));
            if (headers.len == 1 and std.mem.eql(u8, headers, "\r")) break;
            var iter_h = std.mem.tokenize(u8, headers, ":");
            try map.put(iter_h.next().?, iter_h.rest());
        }
        var Req: Request = .{ .Method = try parse_method(iter.next().?), .Uri = iter.next().?, .Version = iter.next().?, .Headers = map };

        // print block

        {
            try self.connection.stream.writer().print("Method: {any} \n uri: {any} \n version: {any} \n", .{ Req.Method, Req.Uri, Req.Version });
            // std.debug.print("\n ------new res ----- \nMethod: {any} \nUri: {s} \n Version: {s} \n", .{ Req.Method, Req.Uri, Req.Version });
            var iter_v = Req.Headers.iterator();
            while (iter_v.next()) |val| {
                std.debug.print("{s}: {s}\n", .{ val.key_ptr.*, val.value_ptr.* });
            }
        }

        return Req;
    }

    fn parse_method(buffer: []const u8) !http.Method {
        return Map.get(buffer) orelse error.UnknownMethod;
    }

    // pub fn request(self: *Self, req: Request) !void {
    //     switch (req.Method) {
    //         http.Method.GET => _ = 1,
    //         else => unreachable,
    //     }
    // }

    pub fn deinit(self: *Self) void {
        self.serve.close();
        self.serve.deinit();
        self.* = undefined;
    }
};

pub const Map = std.ComptimeStringMap(http.Method, .{
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
