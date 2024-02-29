//
//  XCTestCaseExtension.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import XCTest

extension XCTestCase
{
    // When dealing with non int rates, we suffer from some floating point precision
    // Compared to Int64 Rational match in CMTime
    // In these cases, we check our our accuracy

    static let accuracy = 0.00000001
}
