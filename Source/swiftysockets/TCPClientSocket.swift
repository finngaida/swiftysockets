// TCPClientSocket.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Tide

#if os(Linux)
import Glibc
#else
import Darwin
#endif


public final class TCPClientSocket {
    private var socket: tcpsock
    public private(set) var closed = false

    public var fileDescriptor: Int32 {
        return tcpfd(socket)
    }

    public var ip: IP?

    init(socket: tcpsock) {
        self.socket = socket
    }

    public init(ip: IP) throws {
        self.ip = ip
        self.socket = tcpconnect(ip.address)

        if errno != 0 {
            closed = true
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }
    }

    public init(fileDescriptor: Int32) throws {
        self.socket = tcpattach(fileDescriptor, 0)

        if errno != 0 {
            closed = true
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }
    }

    deinit {
        close()
    }

    public func send(data: UnsafeMutableRawPointer, length: Int) throws {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        let bytesProcessed = tcpsend(socket, data, length)

        if errno != 0 {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description, bytesProcessed: bytesProcessed)
        }
    }

    public func flush() throws {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        tcpflush(socket)

        if errno != 0 {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }
    }

    public func receive(bufferSize: Int = 256) throws -> [UInt8] {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        // TODO: find out why this doesn't build in Xcode, but with SPM
        var buffer: [UInt8] = [UInt8](_unsafeUninitializedCapacity: bufferSize) { (buffer, finalSize) in
            for i in 0..<bufferSize {
                buffer[i] = 0
                finalSize = bufferSize
            }
        }

        let bytesProcessed = tcprecv(socket, &buffer, bufferSize)

        if errno != 0 {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description, bytesProcessed: bytesProcessed)
        }

        return Array(buffer[0 ..< bytesProcessed])
    }

    public func receive(bufferSize: Int = 256, untilDelimiter delimiter: String) throws -> [UInt8] {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        // TODO: find out why this doesn't build in Xcode, but with SPM
        var buffer: [UInt8] = [UInt8](_unsafeUninitializedCapacity: bufferSize) { (buffer, finalSize) in
            for i in 0..<bufferSize {
                buffer[i] = 0
                finalSize = bufferSize
            }
        }

        let bytesProcessed = tcprecvuntil(socket, &buffer, bufferSize, delimiter, delimiter.utf8.count)

        if errno != 0 && errno != ENOBUFS {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description, bytesProcessed: bytesProcessed)
        }

        return Array(buffer[0 ..< bytesProcessed])
    }

    public func attach(fileDescriptor: Int32) throws {
        if !closed {
            tcpclose(socket)
        }

        socket = tcpattach(fileDescriptor, 0)

        if errno != 0 {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }

        closed = false
    }

    public func detach() throws -> Int32 {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        closed = true
        return tcpdetach(socket)
    }

    public func close() {
        if !closed {
            closed = true
            tcpclose(socket)
        }
    }
}

extension TCPClientSocket {
    public func sendString(string: String) throws {
        var data = string.utf8.map { UInt8($0) }
        try send(data: &data, length: data.count)
    }

    public func send(data: inout [UInt8]) throws {
        try send(data: &data, length: data.count)
    }

    public func receiveString(bufferSize: Int = 256, untilDelimiter delimiter: String) throws -> String? {
        var response = try receive(bufferSize: bufferSize, untilDelimiter: delimiter)
        response.append(0)
        return String(response)
    }

    public func receiveString(bufferSize: Int = 256) throws -> String? {
        var response = try receive(bufferSize: bufferSize)
        response.append(0)
        return String(response)
    }
}
