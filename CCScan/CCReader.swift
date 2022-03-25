//
//  CCReader.swift
//  CCScan
//
//  Created by Egehan Acar on 23.03.2022.
//

import Foundation
import UIKit
import Vision

struct CCResult {
    let cardNo: String?
    let name: String?
    let expirationDate: String?
}

final class CCReader {
    let helper = CCReaderHelper()
    private var namePredictions = [String]()
    private var expirationDatePredictions = [String]()
    private var cardNumberPredictions = [String]()

    private var expirationDateCustomStopWords = [String]()
    private var nameCustomStopWords = [String]()
    private var cardNumberCustomStopWords = [String]()

    func read(from image: UIImage) -> CCResult? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let recognizedTexts = OCR.recognizeTexts(on: cgImage)
        let recognizedTextsAsString = recognizedTexts
            .map { $0.string }
            .joined(separator: "\n")

        if let cardNumber = helper.extractCardNumber(from: recognizedTextsAsString),
           !cardNumberCustomStopWords.contains(cardNumber)
        {
            cardNumberPredictions.append(cardNumber)
        }
        
        if let expirationDate = helper.extractExpirationDate(from: recognizedTextsAsString),
           !expirationDateCustomStopWords.contains(expirationDate)
        {
            expirationDatePredictions.append(expirationDate)
        }

        if let name = helper.extractName(from: recognizedTexts),
           !nameCustomStopWords.contains(name)
        {
            namePredictions.append(name)
        }

        return getResultFromPredictions()
    }
    
    func read(from pixelBuffer: CVPixelBuffer) -> CCResult? {
        let recognizedTexts = OCR.recognizeTexts(on: pixelBuffer)
        let recognizedTextsAsString = recognizedTexts
            .map { $0.string }
            .joined(separator: "\n")

        if let cardNumber = helper.extractCardNumber(from: recognizedTextsAsString),
           !cardNumberCustomStopWords.contains(cardNumber)
        {
            cardNumberPredictions.append(cardNumber)
        }
        
        if let expirationDate = helper.extractExpirationDate(from: recognizedTextsAsString),
           !expirationDateCustomStopWords.contains(expirationDate)
        {
            expirationDatePredictions.append(expirationDate)
        }

        if let name = helper.extractName(from: recognizedTexts),
           !nameCustomStopWords.contains(name)
        {
            namePredictions.append(name)
        }

        return getResultFromPredictions()
    }
    
    func getResultFromPredictions() -> CCResult {
        let cardNumberPredict = cardNumberPredictions.mostRepetitive()
        let namePredict = namePredictions.mostRepetitive()
        let expirationDatePredict = expirationDatePredictions.mostRepetitive()
        return CCResult(cardNo: cardNumberPredict,
                        name: namePredict,
                        expirationDate: expirationDatePredict)
    }
    
    func addCardNumberToStopWords(_ string: String) -> CCResult {
        self.cardNumberCustomStopWords.append(string)
        self.cardNumberPredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }
    
    func addNameToStopWords(_ string: String) -> CCResult {
        self.nameCustomStopWords.append(string)
        self.namePredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }
    
    func addExpirationDateToStopWords(_ string: String) -> CCResult {
        self.expirationDateCustomStopWords.append(string)
        self.expirationDatePredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }
}

final class CCReaderHelper {
    private let expirationDateRegex = "\\b(0[1-9]|1[0-2]|[1-9])([/]|[-])(20[2-9][0-9]|[2-9][0-9])\\b"
    private let nameRegex = "^\\b([A-Z]{2,})\\s([A-Z]{2,})((\\s[A-Z]{2,}){0,})\\b$"
    private let stopWords: [String] = [
    ]

    func extractExpirationDate(from text: String) -> String? {
        if let range = text.range(of: expirationDateRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }

    func extractName(from recognizedTexts: [VNRecognizedText]) -> String? {
        return recognizedTexts.last { recognizedText in
            recognizedText.string.range(of: nameRegex, options: .regularExpression) != nil
        }?.string
    }
    
    
    
    func extractCardNumber(from text: String) -> String? {
        //let onlyNumericText = text.filter("0123456789".contains)
        print(text)
//        for regex in CreditCardNumberRegex.allCases {
//            if let cardNumberRange = onlyNumericText.range(of: regex.rawValue, options: .regularExpression) {
//                return String(onlyNumericText[cardNumberRange])
//            }
//        }
        
        if let cardNumberRange = text.range(of: "\\d{4}\\s\\d{4}\\s\\d{4}\\s\\d{4}", options: .regularExpression) {
            return String(text[cardNumberRange]).replacingOccurrences(of: "\n", with: " ")
        }
        
        return nil
    }
}




enum CreditCardNumberRegex: String, CaseIterable {
    case maestro = "(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}"
    case mastercard = "(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))"
    case visa = "4[0-9]{12}(?:[0-9]{3})?"
    case visaMaster = "(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})"
    case unionPay = "(62[0-9]{14,17})"
    case amex = "3[47][0-9]{13}"
}
