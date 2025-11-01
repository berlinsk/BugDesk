import Foundation
import SwiftData

@MainActor
final class ProjectListViewModel: ObservableObject {
    @Published var projects: [ProjectEntity] = []
    @Published var errorMessage: String = ""
    @Published var showError = false

    private let repository: ProjectRepositoryProtocol

    init(repository: ProjectRepositoryProtocol) {
        self.repository = repository
    }

    func loadProjects() async {
        do {
            projects = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func createProject(name: String, description: String) async {
        do {
            let project = try await repository.create(name: name, description: description)
            projects.append(project)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func deleteProject(id: UUID) async {
        do {
            try await repository.delete(id: id)
            projects.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
