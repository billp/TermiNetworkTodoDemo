//
//  TodoRoute.swift
//  Example-iOS
//
//  Created by Vasilis Panagiotopoulos on 15/9/20.
//  Copyright © 2020 Ryo Aoyama. All rights reserved.
//

import Foundation
import TermiNetwork

enum TodoRoute: RouteProtocol {
    case todos
    case todo(id: Int)
    case addTodo(text: String)
    case updateTodo(id: Int, text: String, completed: Bool)
    case deleteTodo(id: Int)

    func configure() -> RouteConfiguration {
        switch self {
        case .todos:
            return RouteConfiguration(method: .get,
                                        path: .path(["todos"]),
                                        mockFilePath: .path(["Todos", "index.json"]))
        case .todo(let id):
            return RouteConfiguration(method: .get,
                                        path: .path(["todos", String(id)]))
        case .addTodo(let text):
            return RouteConfiguration(method: .post,
                                        path: .path(["todos"]),
                                        params: ["text": text],
                                        mockFilePath: .path(["GenericResponse", "generic-success.json"]))
        case .updateTodo(let id, let text, let completed):
            return RouteConfiguration(method: .patch,
                                        path: .path(["todos", String(id)]),
                                        params: ["text": text, "completed": completed],
                                        mockFilePath: .path(["GenericResponse", "generic-success.json"]))
        case .deleteTodo(let id):
            return RouteConfiguration(method: .delete,
                                        path: .path(["todos", String(id)]),
                                        mockFilePath: .path(["GenericResponse", "generic-success.json"]))
        }
    }
}
