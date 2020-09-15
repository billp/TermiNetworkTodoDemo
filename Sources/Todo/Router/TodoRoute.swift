//
//  TodoRoute.swift
//  Example-iOS
//
//  Created by Vasilis Panagiotopoulos on 15/9/20.
//  Copyright © 2020 Ryo Aoyama. All rights reserved.
//

import Foundation
import TermiNetwork

enum TodoRoute: TNRouteProtocol {
    case todos
    case todo(id: Int)
    case addTodo(text: String)
    case updateTodo(id: Int, text: String)
    case deleteTodo(id: Int)

    func configure() -> TNRouteConfiguration {
        switch self {
        case .todos:
            return TNRouteConfiguration(method: .get, path: .path(["todos"]), mockFilePath: .path(["Todos", "index.json"])) // Generates: http(s)://.../todos
        case .todo(let id):
            return TNRouteConfiguration(method: .get, path: .path(["todos", String(id)]))
        case .addTodo(let text):
            return TNRouteConfiguration(method: .post, path: .path(["todos"]), params: ["text": text])
        case .updateTodo(let id, let text):
            return TNRouteConfiguration(method: .post, path: .path(["todos", String(id)]), params: ["text": text])
        case .deleteTodo(let id):
            return TNRouteConfiguration(method: .delete, path: .path(["todos", String(id)]))
        }
    }
}
