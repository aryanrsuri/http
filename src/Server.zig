//!                 Server.zig
//!     DATE CREATED    July 6, 2023
//!     LICENSE       MIT
//!     COPYRIGHT (C) 2023 aryanrsuri
//!
//!
//!
const Request = @import("Request.zig").Request;
const ParseVersion = @import("Request.zig").parse_version;
const Response = @import("Response.zig").Response;
const Payload = @import("Response.zig").Payload;
const Routes = @import("Routes.zig").Routes;
const std = @import("std");
const http = std.http;
const stream = std.net.StreamServer;
const address = std.net.Address;

pub const Server = struct {
    const Self = @This();
    port: u16,
    serve: stream,
    addr: address,
    connection: stream.Connection = undefined,
    allocator: std.mem.Allocator,

    /// Create a new HTTP Server
    /// @param {std.mem.Allocator} allocator for server and mappings
    /// @param {[]const u8} address string
    /// @param {u8} port for resolving IP
    /// @returns {HTTP Server} does not err due to @panic instead
    pub fn init(allocator: std.mem.Allocator, address_string: []const u8, port: u16) Self {
        var serve = stream.init(.{});
        const addr = address.resolveIp(address_string, port) catch {
            @panic("IP failed to resolve");
        };
        serve.listen(addr) catch {
            @panic("Server listen failed!");
        };

        std.io.getStdOut().writer().print("\nListening on Port: {} \n", .{port}) catch {
            @panic("Stdout failed to allocate");
        };
        return .{
            .port = port,
            .serve = serve,
            .addr = addr,
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Self) void {
        self.serve.close();
        self.serve.deinit();
        self.* = undefined;
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

    pub fn handler(self: *Self) !void {
        defer self.connection.stream.close();
        var request: Request = try Request.init(self.allocator, self.connection.stream.writer(), self.connection.stream.reader());
        try request.print(self.connection.stream.writer());
        _ = try Handler.Fn(&request);

        // return HTTPContext;
    }
};

pub const Handler = struct {
    const Self = @This();
    res: *Response = undefined,
    pub fn Fn(req: *Request) !Self {
        _ = try Routes.init(req, req.Uri);
        return .{ .res = &req.Response };
    }
};
