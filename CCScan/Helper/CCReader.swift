//
//  CCReader.swift
//  CCScan
//
//  Created by Egehan Acar on 23.03.2022.
//

import UIKit
import Vision

final class CCReader {
    private let helper = CCReaderHelper()
    private let ocr = OCR()

    private var namePredictions = [String]()
    private var expirationDatePredictions = [String]()
    private var cardNumberPredictions = [String]()

    private var expirationDateStopWords = [String]()
    private var nameStopWords = [String]()
    private var cardNumberStopWords = [String]()

    func read(from pixelBuffer: CVPixelBuffer) -> CCResult? {
        let recognizedTexts = ocr.recognizeTexts(on: pixelBuffer)
        let recognizedTextsAsString = recognizedTexts
            .map { $0.string }
            .joined(separator: "\n")

        if let cardNumber = helper.extractCardNumber(from: recognizedTextsAsString),
           !cardNumberStopWords.contains(cardNumber)
        {
            cardNumberPredictions.append(cardNumber)
        }

        if let expirationDate = helper.extractExpirationDate(from: recognizedTextsAsString),
           !expirationDateStopWords.contains(expirationDate)
        {
            expirationDatePredictions.append(expirationDate)
        }

        if let name = helper.extractName(from: recognizedTexts),
           !nameStopWords.contains(name)
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
        cardNumberStopWords.append(string)
        cardNumberPredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }

    func addNameToStopWords(_ string: String) -> CCResult {
        nameStopWords.append(string)
        namePredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }

    func addExpirationDateToStopWords(_ string: String) -> CCResult {
        expirationDateStopWords.append(string)
        expirationDatePredictions.removeAll { $0 == string }
        return getResultFromPredictions()
    }
}

final class CCReaderHelper {
    private let expirationDateRegex = "\\b(0[1-9]|1[0-2]|[1-9])([/]|[-])(20[2-9][0-9]|[2-9][0-9])\\b"
    private let nameRegex = "^\\b([A-Z]{2,})\\s([A-Z]{2,})((\\s[A-Z]{2,}){0,})\\b$"
    private let cardNumberRegex = "(\\b[4-6]\\d{3}\\s\\d{4}\\s\\d{4}\\s\\d{4}\\b)|(\\b3\\d{3}\\s\\d{6}\\s\\d{5}\\b)"

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
        if let cardNumberRange = text.range(of: cardNumberRegex, options: .regularExpression) {
            return String(text[cardNumberRange]).replacingOccurrences(of: "\n", with: " ")
        }

        return nil
    }
}
