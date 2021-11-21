//
//  Food.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import Foundation

struct Food: Hashable {
    enum Rating: String {
        case one
        case two
        case three
        case four
        case five
        case zero
        
        var image: String{
            switch self {
            case .one:
                return "angry"
            case .two:
                return "sad"
            case .three:
                return "cool"
            case .four:
                return "happy"
            case .five:
                return "love"
            case .zero:
                return ""
            }
        }
    }
    var foodID: String
    var restaurantID: String
    var name: String
    var image: String
    var price: String
    var cpVale: String
    var descriptioin: String
    var rating: Rating?
}
