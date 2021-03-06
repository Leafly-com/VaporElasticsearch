
import Foundation

/**
 When the built-in analyzers do not fulfill your needs, you can create a custom analyzer which uses the appropriate combination of:
 
 * a tokenizer
 * zero or more character filters
 * zero or more token filters.
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-custom-analyzer.html)
 */
public struct CustomAnalyzer: Analyzer, DefinesTokenizers, DefinesTokenFilters, DefinesCharacterFilters {
    /// :nodoc:
    public static var typeKey = AnalyzerType.custom
    
    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let tokenizer: Tokenizer
    public let charFilter: [CharacterFilter]?
    public let filter: [TokenFilter]?
    public let positionIncrementGap: Int?

    enum CodingKeys: String, CodingKey {
        case type
        case tokenizer
        case charFilter = "char_filter"
        case filter
        case positionIncrementGap = "position_increment_gap"
    }
    
    public init(name: String,
                tokenizer: Tokenizer,
                filter: [TokenFilter]? = nil,
                characterFilter: [CharacterFilter]? = nil,
                positionIncrementGap: Int? = nil) {

        self.name = name
        self.tokenizer = tokenizer
        self.filter = filter
        self.charFilter = characterFilter
        self.positionIncrementGap = positionIncrementGap
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(tokenizer.name, forKey: .tokenizer)
        
        if self.charFilter?.count ?? 0 > 0 {
            var charFilterContainer = container.nestedUnkeyedContainer(forKey: .charFilter)
            if let charFilter = self.charFilter {
                for filter in charFilter {
                    try charFilterContainer.encode(filter.name)
                }
            }
        }
        
        if self.filter?.count ?? 0 > 0 {
            var tokenFilterContainer = container.nestedUnkeyedContainer(forKey: .filter)
            if let tokenFilter = self.filter {
                for filter in tokenFilter {
                    try tokenFilterContainer.encode(filter.name)
                }
            }
        }
        
        try container.encodeIfPresent(positionIncrementGap, forKey: .positionIncrementGap)
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!
        
        self.positionIncrementGap = try container.decodeIfPresent(Int.self, forKey: .positionIncrementGap)
        
        if let analysis = decoder.analysis() {
            let tokenizer = try container.decode(String.self, forKey: .tokenizer)
            self.tokenizer = analysis.tokenizer(named: tokenizer)!
            
            if let charFilters = try container.decodeIfPresent([String].self, forKey: .charFilter) {
                self.charFilter = charFilters.map { analysis.characterFilter(named: $0)! }
            } else {
                self.charFilter = nil
            }
            if let tokenFilters = try container.decodeIfPresent([String].self, forKey: .filter) {
                self.filter = tokenFilters.map { analysis.tokenFilter(named: $0)! }
            } else {
                self.filter = nil
            }
        }
        else {
            // This should never be called
            self.tokenizer = StandardTokenizer()
            self.charFilter = nil
            self.filter = nil
        }
    }
    
    /// :nodoc:
    public func definedTokenizers() -> [Tokenizer] {
        return [self.tokenizer]
    }
    
    /// :nodoc:
    public func definedTokenFilters() -> [TokenFilter] {
        var filters = [TokenFilter]()
        if let tokenFilters = self.filter {
            for filter in tokenFilters {
                filters.append(filter)
            }
        }
        return filters
    }
    
    /// :nodoc:
    public func definedCharacterFilters() -> [CharacterFilter] {
        var filters = [CharacterFilter]()
        if let charFilters = self.charFilter {
            for filter in charFilters {
                filters.append(filter)
            }
        }
        return filters
    }
}
