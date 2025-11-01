import Foundation
import SwiftData

final class ProjectRepository: ProjectRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [ProjectEntity] {
        let descriptor = FetchDescriptor<Project>()
        let projects = try modelContext.fetch(descriptor)
        return projects.map { project in
            ProjectEntity(
                id: project.id,
                name: project.name,
                description: project.projectDescription,
                createdAt: project.createdAt,
                versions: project.versions.map { version in
                    VersionEntity(
                        id: version.id,
                        name: version.name,
                        createdAt: version.createdAt,
                        bugReports: version.bugReports.map { $0.toBugReportEntity() }
                    )
                }
            )
        }
    }

    func create(name: String, description: String) async throws -> ProjectEntity {
        let project = Project(name: name, projectDescription: description)
        modelContext.insert(project)
        try modelContext.save()

        return ProjectEntity(
            id: project.id,
            name: project.name,
            description: project.projectDescription,
            createdAt: project.createdAt,
            versions: []
        )
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.id == id })
        if let project = try modelContext.fetch(descriptor).first {
            modelContext.delete(project)
            try modelContext.save()
        }
    }
}
