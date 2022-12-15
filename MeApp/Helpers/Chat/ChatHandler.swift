import NIO
import Foundation

final class LineDelimiterCodec: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = ByteBuffer
    public var length = -1
    public var cumulationBuffer: ByteBuffer?

    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        let readable = buffer.withUnsafeReadableBytes { $0.firstIndex(of: "|".utf8.first!) }
        if self.length == -1, let r = readable {
            let str = buffer.readString(length: r)!
            _ = buffer.readString(length: 1)
            self.length = Int(str) ?? 0
        }
        if buffer.readableBytes >= self.length && self.length != -1 {
            var buf = context.channel.allocator.buffer(capacity: self.length)
            guard let data = buffer.readString(length: self.length) else {return .continue}
            buf.writeString(data)
            context.fireChannelRead(self.wrapInboundOut(buf))
            self.length = -1
            return .continue
        }
        return .needMoreData
    }
}

internal final class ChatHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    public var onReceive: ((Data) -> ())? = nil
    public var onClose: (() -> ())? = nil
    public var onActive: (() -> ())? = nil
    private func printByte(_ byte: UInt8) {
        #if os(Android)
        print(Character(UnicodeScalar(byte)),  terminator:"")
        #else
        fputc(Int32(byte), stdout)
        #endif
    }
    public func channelActive(context: ChannelHandlerContext) {
        onActive?()
    }
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        var data = Data()
        data.append(contentsOf: buffer.readBytes(length: buffer.readableBytes)!)
        print(String(data: data, encoding: .utf8))
        DispatchQueue.main.async {
            self.onReceive?(data)
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        onClose?()
        context.close(promise: nil)
    }
    public func channelInactive(context: ChannelHandlerContext) {
        print("InActive")
        onClose?()
        context.close(promise: nil)
    }
}
