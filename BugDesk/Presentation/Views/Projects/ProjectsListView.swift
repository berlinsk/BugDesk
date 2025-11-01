import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]

    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showAddSheet = false
    @State private var projectToDelete: Project?
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                if projects.isEmpty {
                    emptyStateView
                } else {
                    projectsList
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAddSheet) {
            AddProjectSheet()
                .environmentObject(theme)
                .environmentObject(locale)
                .environment(\.modelContext, modelContext)
        }
        .alert("projects.deleteConfirm".localized, isPresented: $showDeleteAlert, presenting: projectToDelete) { project in
            Button("action.cancel".localized, role: .cancel) {}
            Button("action.delete".localized, role: .destructive) {
                deleteProject(project)
            }
        } message: { _ in
            Text("projects.deleteMessage".localized)
        }
    }

    @Environment(\.dismiss) private var dismiss

    private var customNavBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(FontManager.title2())
                    .foregroundColor(theme.accentColor)
            }
            .buttonStyle(.plain)

            Text("projects.title".localized)
                .font(FontManager.largeTitle())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                showAddSheet = true
            }) {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "plus.circle.fill")
                        .font(FontManager.title2())
                    Text("projects.add".localized)
                        .font(FontManager.body())
                }
                .foregroundColor(theme.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.large)
        .padding(.vertical, Constants.Spacing.medium)
        .background(
            theme.secondaryBackground
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.xlarge) {
            Spacer()

            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(theme.accentColor.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: Constants.Spacing.small) {
                Text("projects.empty".localized)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                Text("projects.emptyDesc".localized)
                    .font(FontManager.body())
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                showAddSheet = true
            }) {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "plus.circle.fill")
                    Text("projects.add".localized)
                }
                .font(FontManager.body())
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, Constants.Spacing.xlarge)
                .padding(.vertical, Constants.Spacing.medium)
                .background(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(Constants.CornerRadius.medium)
                .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(Constants.Spacing.large)
        .fadeIn(delay: 0.1)
    }

    private var projectsList: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.medium) {
                ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
                    NavigationLink(destination: ProjectDetailView(project: project).environmentObject(authViewModel)) {
                        ProjectCard(project: project, onDelete: {
                            projectToDelete = project
                            showDeleteAlert = true
                        })
                    }
                    #if os(iOS)
                    .buttonStyle(.plain)
                    #endif
                    .fadeIn(delay: Double(index) * 0.05)
                }
            }
            .padding(Constants.Spacing.large)
        }
    }

    private func deleteProject(_ project: Project) {
        withAnimation(AnimationManager.spring) {
            modelContext.delete(project)
            try? modelContext.save()
        }
    }
}

struct ProjectCard: View {
    let project: Project
    let onDelete: () -> Void

    @EnvironmentObject private var theme: ThemeManager
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Constants.Spacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(theme.accentColor.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: "folder.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                Text(project.name)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                if !project.projectDescription.isEmpty {
                    Text(project.projectDescription)
                        .font(FontManager.callout())
                        .foregroundColor(theme.secondaryText)
                        .lineLimit(2)
                }

                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(FontManager.caption2())
                    Text("\(project.versions.count) " + "versions.title".localized.lowercased())
                        .font(FontManager.caption())
                }
                .foregroundColor(theme.secondaryText.opacity(0.7))
            }

            Spacer()

            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("action.delete".localized, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(FontManager.title2())
                    .foregroundColor(theme.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationManager.spring, value: isPressed)
        #if os(iOS)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        #elseif os(macOS)
        .onHover { hovering in
            isPressed = hovering
        }
        #endif
    }
}

struct AddProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager

    @State private var name = ""
    @State private var projectDescription = ""
    @State private var showValidationError = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name
        case description
    }

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: Constants.Spacing.xlarge) {
                        ImprovedTextField(
                            text: $name,
                            label: "projects.name".localized,
                            placeholder: "projects.namePlaceholder".localized,
                            axis: .horizontal,
                            field: .name,
                            focusedField: $focusedField
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description
                        }

                        ImprovedTextField(
                            text: $projectDescription,
                            label: "projects.description".localized,
                            placeholder: "projects.descriptionPlaceholder".localized,
                            axis: .vertical,
                            lineLimit: 4,
                            field: .description,
                            focusedField: $focusedField
                        )
                        .submitLabel(.done)

                        PrimaryButton(
                            title: "projects.create".localized,
                            icon: "checkmark.circle.fill",
                            action: saveProject
                        )
                    }
                    .padding(Constants.Spacing.large)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .dismissKeyboardOnTap()
        .alert("validation.error".localized, isPresented: $showValidationError) {
            Button("action.ok".localized, role: .cancel) {}
        } message: {
            Text("validation.nameRequired".localized)
        }
    }

    private var header: some View {
        HStack {
            Text("projects.add".localized)
                .font(FontManager.title2())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(FontManager.title2())
                    .foregroundColor(theme.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(Constants.Spacing.large)
        .background(
            theme.secondaryBackground
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func hideKeyboard() {
        focusedField = nil
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private func saveProject() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationError = true
            return
        }

        let project = Project(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            projectDescription: projectDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(project)
        try? modelContext.save()

        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif

        dismiss()
    }
}
