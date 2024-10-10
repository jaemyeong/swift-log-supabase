import Foundation
import Logging

extension Logger.MetadataValue: Codable {
    
    public init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
        } else if let dictionary = try? decoder.singleValueContainer().decode(Logger.Metadata.self) {
            self = .dictionary(dictionary)
        } else if let array = try? decoder.singleValueContainer().decode([Logger.MetadataValue].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported \(Logger.MetadataValue.self) type."))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .stringConvertible(let value):
            try container.encode(value.description)
        case .dictionary(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}
