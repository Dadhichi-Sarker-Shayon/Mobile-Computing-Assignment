//
//  TaskListView.swift
//  SwiftTodo
//

import SwiftUI

private enum TaskSegment: String, CaseIterable {
    case active = "Active"
    case completed = "Completed"
}

struct TaskListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel: TaskViewModel

    @State private var showingNewTask = false
    @State private var taskToEdit: TodoTask?
    @State private var selectedSegment: TaskSegment = .active

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if visibleTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.stopListening()
                            auth.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.tint)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("Tasks", selection: $selectedSegment) {
                        ForEach(TaskSegment.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
            .sheet(isPresented: $showingNewTask) {
                TaskEditorView(task: nil) { title, description in
                    try await viewModel.addTask(title: title, description: description)
                }
            }
            .sheet(item: $taskToEdit) { task in
                TaskEditorView(task: task) { title, description in
                    try await viewModel.updateTask(task, title: title, description: description)
                }
            }
            .alert("Error",
                   isPresented: Binding(get: { viewModel.errorMessage != nil },
                                        set: { if !$0 { viewModel.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(selectedSegment == .active ? "No Active Tasks" : "No Completed Tasks",
                  systemImage: selectedSegment == .active ? "checklist" : "checkmark.seal")
        } description: {
            Text(selectedSegment == .active
                 ? "Tap the plus button to add your first task."
                 : "Tasks you complete will appear here.")
        }
    }

    private var taskList: some View {
        List {
            Section {
                ForEach(visibleTasks) { task in
                    TaskRow(task: task) {
                        Task { await viewModel.toggleCompletion(task) }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { taskToEdit = task }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteTask(task) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } footer: {
                Text(footerText)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .animation(.snappy(duration: 0.25), value: visibleTasks)
    }

    private var footerText: String {
        let completed = viewModel.tasks.filter(\.isCompleted).count
        let active = viewModel.tasks.count - completed
        switch selectedSegment {
        case .active:
            return active == 1 ? "1 task to do" : "\(active) tasks to do"
        case .completed:
            return completed == 1 ? "1 task completed" : "\(completed) tasks completed"
        }
    }

    private var visibleTasks: [TodoTask] {
        viewModel.tasks.filter { $0.isCompleted == (selectedSegment == .completed) }
    }
}

private struct TaskRow: View {
    let task: TodoTask
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .animation(.snappy(duration: 0.2), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskListView(userId: "preview")
        .environmentObject(AuthViewModel())
}
