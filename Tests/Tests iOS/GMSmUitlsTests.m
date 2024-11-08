//
//  GMSmUitlsTests.m
//  Tests iOS
//
//  Created by lifei on 2024/11/8.
//

#import "GMBaseTests.h"

@interface GMSmUitlsTests : GMBaseTests

@end

@implementation GMSmUitlsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testHexStringFromString {
    for (NSInteger i = 0; i < 100; i++) {
        // Test with random mixed Chinese-English string
        NSString *mixedStr = [self randomZhEn:50];
        NSString *hexStr = [GMSmUtils hexStringFromString:mixedStr];
        NSString *decodedStr = [GMSmUtils stringFromHexString:hexStr];
        XCTAssertEqualObjects(mixedStr, decodedStr, @"Mixed string hex encoding/decoding failed");
        
        // Test with random English string
        NSString *enStr = [self randomEn:50];
        hexStr = [GMSmUtils hexStringFromString:enStr];
        decodedStr = [GMSmUtils stringFromHexString:hexStr];
        XCTAssertEqualObjects(enStr, decodedStr, @"English string hex encoding/decoding failed");
        
        // Test with random Chinese string
        NSString *zhStr = [self randomZh:50];
        hexStr = [GMSmUtils hexStringFromString:zhStr];
        decodedStr = [GMSmUtils stringFromHexString:hexStr];
        XCTAssertEqualObjects(zhStr, decodedStr, @"Chinese string hex encoding/decoding failed");
    }
    
    // Test edge cases
    NSString *nilStr = nil;
    XCTAssertNil([GMSmUtils hexStringFromString:nilStr], @"Nil input should return nil");
    XCTAssertNil([GMSmUtils hexStringFromString:@""], @"Empty string should return nil");
}

- (void)testHexStringFromData {
    for (NSInteger i = 0; i < 100; i++) {
        // Generate random data
        NSString *randomStr = [self randomAny:50];
        NSData *originalData = [randomStr dataUsingEncoding:NSUTF8StringEncoding];
        
        // Test encoding and decoding
        NSString *hexStr = [GMSmUtils hexStringFromData:originalData];
        NSData *decodedData = [GMSmUtils dataFromHexString:hexStr];
        
        XCTAssertNotNil(hexStr, @"Hex string should not be nil");
        XCTAssertNotNil(decodedData, @"Decoded data should not be nil");
        XCTAssertEqualObjects(originalData, decodedData, @"Data should match after hex encoding/decoding");
    }
    
    // Test edge cases
    NSData *nilData = nil;
    XCTAssertNil([GMSmUtils hexStringFromData:nilData], @"Nil input should return nil");
    XCTAssertNil([GMSmUtils hexStringFromData:[NSData data]], @"Empty data should return nil");
}

#pragma mark - Base64 Tests

- (void)testBase64EncodingDecoding {
    for (NSInteger i = 0; i < 100; i++) {
        // Generate random test data
        NSString *randomStr = [self randomAny:50];
        NSData *originalData = [randomStr dataUsingEncoding:NSUTF8StringEncoding];
        
        // Test encoding and decoding
        NSString *base64Str = [GMSmUtils base64EncodedStringWithData:originalData];
        NSData *decodedData = [GMSmUtils dataFromBase64EncodedString:base64Str];
        
        XCTAssertNotNil(base64Str, @"Base64 string should not be nil");
        XCTAssertNotNil(decodedData, @"Decoded data should not be nil");
        XCTAssertEqualObjects(originalData, decodedData, @"Data should match after base64 encoding/decoding");
    }
    
    // Test edge cases
    NSData *nilData = nil;
    XCTAssertNil([GMSmUtils base64EncodedStringWithData:nilData], @"Nil input should return nil");
    XCTAssertNil([GMSmUtils base64EncodedStringWithData:[NSData data]], @"Empty data should return empty base64 string");
}

#pragma mark - Validation Tests

- (void)testIsValidHexString {
    // Test valid hex strings
    XCTAssertTrue([GMSmUtils isValidHexString:@"0123456789abcdef"], @"Valid hex string should return YES");
    XCTAssertTrue([GMSmUtils isValidHexString:@"0123456789ABCDEF"], @"Valid hex string should return YES");
    
    // Test invalid hex strings
    XCTAssertFalse([GMSmUtils isValidHexString:@"0123456789abcdefg"], @"Invalid hex string should return NO");
    XCTAssertFalse([GMSmUtils isValidHexString:@""], @"Empty string should return NO");
    XCTAssertFalse([GMSmUtils isValidHexString:@"xyz"], @"Non-hex string should return NO");
}

- (void)testIsValidBase64String {
    // Test valid base64 strings
    XCTAssertTrue([GMSmUtils isValidBase64String:@"SGVsbG8gV29ybGQ="], @"Valid base64 string should return YES");
    XCTAssertTrue([GMSmUtils isValidBase64String:@"TWFuIGlzIGRpc3Rpbmd1aXNoZWQ="], @"Valid base64 string should return YES");
    
    // Test invalid base64 strings
    XCTAssertFalse([GMSmUtils isValidBase64String:@"Invalid!@#$"], @"Invalid base64 string should return NO");
    XCTAssertFalse([GMSmUtils isValidBase64String:@""], @"Empty string should return NO");
}

- (void)testCheckStringData {
    for (NSInteger i = 0; i < 100; i++) {
        // Test with regular string data
        NSString *randomStr = [self randomAny:50];
        NSData *originalData = [randomStr dataUsingEncoding:NSUTF8StringEncoding];
        NSData *checkedData = [GMSmUtils checkStringData:originalData];
        XCTAssertEqualObjects(originalData, checkedData, @"Regular string data should remain unchanged");
        
        // Test with base64 string data
        NSString *base64Str = [GMSmUtils base64EncodedStringWithData:originalData];
        NSData *base64Data = [base64Str dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decodedData = [GMSmUtils checkStringData:base64Data];
        XCTAssertEqualObjects(originalData, decodedData, @"Base64 string data should be properly decoded");
        
        // Test with hex string data
        NSString *hexStr = [GMSmUtils hexStringFromData:originalData];
        NSData *hexData = [hexStr dataUsingEncoding:NSUTF8StringEncoding];
        decodedData = [GMSmUtils checkStringData:hexData];
        XCTAssertNotEqualObjects(originalData, hexData, @"Hex string data should be properly decoded");
    }
    
    // Test edge cases
    NSData *nilData = nil;
    XCTAssertNil([GMSmUtils checkStringData:nilData], @"Nil input should return nil");
    XCTAssertEqualObjects([GMSmUtils checkStringData:[NSData data]], [NSData data], @"Empty data should return empty data");
}

- (void)testPrefixPaddingZero {
    // Test normal cases
    XCTAssertEqualObjects([GMSmUtils prefixPaddingZero:@"123" maxLen:5], @"00123", @"Should pad zeros correctly");
    XCTAssertEqualObjects([GMSmUtils prefixPaddingZero:@"abc" maxLen:6], @"000abc", @"Should pad zeros correctly");
    
    // Test edge cases
    XCTAssertEqualObjects([GMSmUtils prefixPaddingZero:@"123" maxLen:3], @"123", @"Should not pad when length matches");
    XCTAssertEqualObjects([GMSmUtils prefixPaddingZero:@"123" maxLen:2], @"123", @"Should not truncate when input longer than maxLen");
    XCTAssertEqualObjects([GMSmUtils prefixPaddingZero:@"" maxLen:3], @"", @"Should handle empty string");
}

@end
