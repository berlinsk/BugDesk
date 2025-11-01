import Foundation

protocol ProjectRepositoryProtocol {
    func fetchAll() async throws -> [ProjectEntity]
    func create(name: String, description: String) async throws -> ProjectEntity
    func delete(id: UUID) async throws
}
