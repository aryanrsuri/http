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
        Body: []const u8,
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
            try self.handler();
        }
    }

    pub fn handler(self: *Self) !void {
        defer self.connection.stream.close();
        const res = try self.connection.stream.reader().readUntilDelimiterAlloc(self.alloc, '\n', std.math.maxInt(usize));
        var iter = std.mem.tokenize(u8, res, " ");
        var req: Request = .{
            .Method = try parse_method(iter.next().?),
            .Uri = iter.next().?,
            .Version = iter.next().?,
            .Body = iter.rest(),
        };
        try self.connection.stream.writer().print("{any} \n", .{req});
        // try std.io.getStdOut().writer().print(" }\n", .{port});
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
    .{ "POST", .POST },
    .{ "PUT", .PUT },
    .{ "DELETE", .DELETE },
});
