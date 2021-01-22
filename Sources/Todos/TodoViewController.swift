import UIKit
import Carbon
import TermiNetwork

final class TodoViewController: UIViewController, UITextViewDelegate {
    enum ID {
        case task
        case completed
    }

    struct State {
        var todos = [Todo]()
        var completed = [Todo]()
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var inputContainerView: UIView!
    @IBOutlet var inputViewHidden: NSLayoutConstraint!
    @IBOutlet var inputViewBottom: NSLayoutConstraint!

    // Create Todo Router
    fileprivate var todoRouter = Router<TodoRoute>()

    var state = State() {
        didSet { render() }
    }

    private let renderer = Renderer(
        adapter: TodoSwipeCellKitAdapter(),
        updater: UITableViewUpdater()
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Todo App"
        addButton.layer.cornerRadius = addButton.bounds.height / 2
        inputTextView.textContainerInset = .zero
        inputContainerView.layer.cornerRadius = 24
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        tableView.contentInset.bottom = view.bounds.height - addButton.frame.minY
        renderer.target = tableView

        apiTodos(success: { (completed, uncompleted) in
            self.state.completed = completed
            self.state.todos = uncompleted
            self.render()
        })
    }

    func render() {
        renderer.render {
            if state.todos.isEmpty {
                Section(id: ID.task, header: TodoEmpty())
            }
            else {
                Section(
                    id: ID.task,
                    header: Header("TASKS (\(state.todos.count))"),
                    cells: {
                        Group(of: state.todos.enumerated()) { offset, todo in
                            TodoText(todo: todo, isCompleted: false) { [weak self] event in
                                switch event {
                                case .toggleCompleted:
                                    self?.completeTodo(todo, offset: offset)
                                case .delete:
                                    self?.deleteUncompletedTodo(todo, offset: offset)
                                }
                            }
                        }
                })
            }

            if !state.completed.isEmpty {
                Section(
                    id: ID.completed,
                    header: Header("COMPLETED (\(state.completed.count))"),
                    cells: {
                        Group(of: state.completed.enumerated()) { offset, todo in
                            TodoText(todo: todo, isCompleted: true) { [weak self] event in
                                switch event {
                                case .toggleCompleted:
                                    self?.uncompleteTodo(todo, offset: offset)
                                case .delete:
                                    self?.deleteCompletedTodo(todo, offset: offset)
                                }
                            }
                        }
                })
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n", let inputText = textView.text, !inputText.isEmpty  else {
            return true
        }

        let id = state.todos.count + 1
        let todo = Todo(id: id, text: inputText)

        apiAddTodo(todo: todo) {
            self.state.todos.append(todo)
            self.inputTextView.resignFirstResponder()
            textView.text = nil
        }

        return false
    }

    @IBAction func startInput() {
        inputTextView.text = nil
        inputTextView.becomeFirstResponder()

    }

    @objc func keyboardWillShow(notification: Notification) {
        KeyboardInfo(notification).animate { info in
            self.inputViewHidden.isActive = false
            self.inputViewBottom.constant = self.view.bounds.height - info.endFrame.minY
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        KeyboardInfo(notification).animate { _ in
            self.inputViewHidden.isActive = true
            self.inputViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Helpers
    private func completeTodo(_ todo: Todo, offset: Int) {
        apiToggleTodo(todo: todo) {
            self.state.todos.remove(at: offset)
            self.state.completed.append(todo)
        }
    }

    private func uncompleteTodo(_ todo: Todo, offset: Int) {
        apiToggleTodo(todo: todo) {
            self.state.completed.remove(at: offset)
            self.state.todos.append(todo)
        }
    }

    private func deleteCompletedTodo(_ todo: Todo, offset: Int) {
        apiDeleteTodo(todo: todo) {
            self.state.completed.remove(at: offset)
        }
    }

    private func deleteUncompletedTodo(_ todo: Todo, offset: Int) {
        apiDeleteTodo(todo: todo) {
            self.state.todos.remove(at: offset)
        }
    }

    // MARK: Networking Helpers
    private func apiTodos(success: (([Todo], [Todo])->())?) {
        todoRouter.request(for: .todos)
            .success(responseType: RSTodosResponse.self) { response in
                let todos = self.mapTodos(response.todos)
                success?(todos.completed, todos.uncompleted)
            }
            .failure { error in
                debugPrint(error.localizedDescription as Any)
            }
    }

    private func apiAddTodo(todo: Todo, success: (()->())?) {
        todoRouter.request(for: .addTodo(text: todo.text))
            .success(responseType: GenericSuccess.self) { response in
                success?()
            }
            .failure { error in
                debugPrint(error.localizedDescription as Any)
            }
    }

    private func apiDeleteTodo(todo: Todo, success: (()->())?) {
        todoRouter.request(for: .deleteTodo(id: todo.id))
            .success(responseType: GenericSuccess.self) { response in
                success?()
            }
            .failure { error in
                debugPrint(error.localizedDescription as Any)
            }
    }

    private func apiToggleTodo(todo: Todo, success: (()->())?) {
        let completed = !state.completed.contains(where: { $0.id == todo.id })
        todoRouter.request(for: .updateTodo(id: todo.id,
                                            text: todo.text,
                                            completed: completed))
            .success(responseType: GenericSuccess.self) { response in
                success?()
            }
            .failure { error in
                debugPrint(error.localizedDescription as Any)
            }
    }

    private func mapTodos(_ todos: [RSTodo]) -> (completed: [Todo], uncompleted: [Todo]) {
        let uncompleted = todos.filter({ !$0.completed }).map { Todo.init(id: $0.id, text: $0.title) }
        let completed = todos.filter({ $0.completed }).map { Todo.init(id: $0.id, text: $0.title) }

        return (completed: completed, uncompleted: uncompleted)
    }
}

private struct KeyboardInfo {
    var userInfo: [AnyHashable: Any]
    var endFrame: CGRect
    var animationDuration: TimeInterval
    var animationOptions: UIView.AnimationOptions

    init(_ notification: Notification) {
        userInfo = notification.userInfo!
        endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        animationOptions = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
    }

    func animate(_ animations: @escaping (KeyboardInfo) -> Void) {
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: animationOptions,
            animations: { animations(self) }
        )
    }
}
