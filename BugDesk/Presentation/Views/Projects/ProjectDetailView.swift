import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    let project: Project

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showAddSheet = false
    @State private var versionToDelete: Version?
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                ScrollView {
                    VStack(spacing: Constants.Spacing.large) {
                        projectHeader

                        versionsSection
                    }
                    .padding(Constants.Spacing.large)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAddSheet) {
            AddVersionSheet(project: project)
                .environmentObject(theme)
                .environmentObject(locale)
                .environment(\.modelContext, modelContext)
        }
        .alert("versions.deleteConfirm".localized, isPresented: $showDeleteAlert, presenting: versionToDelete) { version in
            Button("action.cancel".localized, role: .cancel) {}
            Button("action.delete".localized, role: .destructive) {
                deleteVersion(version)
            }
        } message: { _ in
            Text("versions.deleteMessage".localized)
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

            Text(project.name)
                .font(FontManager.largeTitle())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)
                .lineLimit(1)

            Spacer()

            Button(action: {
                showAddSheet = true
            }) {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "plus.circle.fill")
                        .font(FontManager.title2())
                    Text("versions.add".localized)
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

    private var projectHeader: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            if !project.projectDescription.isEmpty {
                HStack {
                    Image(systemName: "doc.text")
                        .font(FontManager.body())
                        .foregroundColor(theme.accentColor)

                    Text(project.projectDescription)
                        .font(FontManager.body())
                        .foregroundColor(theme.secondaryText)
                        .lineLimit(3)

                    Spacer()
                }
            }

            HStack(spacing: Constants.Spacing.xlarge) {
                statItem(
                    icon: "rectangle.stack.fill",
                    value: "\(project.versions.count)",
                    label: "versions.title".localized.lowercased()
                )

                statItem(
                    icon: "ladybug.fill",
                    value: "\(project.versions.reduce(0) { $0 + $1.bugReports.count })",
                    label: "bugList.title".localized.lowercased()
                )
            }
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .fadeIn(delay: 0.1)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: Constants.Spacing.small) {
            Image(systemName: icon)
                .font(FontManager.callout())
                .foregroundColor(theme.accentColor)

            Text(value)
                .font(FontManager.title2())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)

            Text(label)
                .font(FontManager.callout())
                .foregroundColor(theme.secondaryText)
        }
    }

    private var versionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("versions.title".localized)
                .font(FontManager.title2())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)

            if project.versions.isEmpty {
                emptyVersionsView
            } else {
                versionsList
            }
        }
    }

    private var emptyVersionsView: some View {
        VStack(spacing: Constants.Spacing.large) {
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(theme.accentColor.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: Constants.Spacing.small) {
                Text("versions.empty".localized)
                    .font(FontManager.body())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                Text("versions.emptyDesc".localized)
                    .font(FontManager.callout())
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                showAddSheet = true
            }) {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "plus.circle.fill")
                    Text("versions.add".localized)
                }
                .font(FontManager.body())
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.vertical, Constants.Spacing.small)
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Spacing.xxlarge)
        .fadeIn(delay: 0.2)
    }

    private var versionsList: some View {
        LazyVStack(spacing: Constants.Spacing.medium) {
            ForEach(Array(project.versions.enumerated()), id: \.element.id) { index, version in
                NavigationLink(destination: VersionDetailView(version: version, project: project).environmentObject(authViewModel)) {
                    VersionCard(version: version, onDelete: {
                        versionToDelete = version
                        showDeleteAlert = true
                    })
                }
                #if os(iOS)
                .buttonStyle(.plain)
                #endif
                .fadeIn(delay: Double(index) * 0.05)
            }
        }
    }

    private func deleteVersion(_ version: Version) {
        withAnimation(AnimationManager.spring) {
            modelContext.delete(version)
            try? modelContext.save()
        }
    }
}

struct VersionCard: View {
    let version: Version
    let onDelete: () -> Void

    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Constants.Spacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(theme.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                Text(version.name)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "ladybug.fill")
                        .font(FontManager.caption2())
                    Text(String(format: "versions.bugCount".localized, version.bugReports.count))
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
        .padding(Constants.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
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

struct AddVersionSheet: View {
    let project: Project

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager

    @State private var name = ""
    @State private var showValidationError = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name
    }

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: Constants.Spacing.xlarge) {
                        ImprovedTextField(
                            text: $name,
                            label: "versions.name".localized,
                            placeholder: "versions.namePlaceholder".localized,
                            axis: .horizontal,
                            field: Field.name,
                            focusedField: $focusedField
                        )
                        .submitLabel(.done)
                        .onSubmit {
                            saveVersion()
                        }

                        PrimaryButton(
                            title: "versions.create".localized,
                            icon: "checkmark.circle.fill",
                            action: saveVersion
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
            Text("versions.add".localized)
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

    private func saveVersion() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationError = true
            return
        }

        let version = Version(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        version.project = project
        project.versions.append(version)

        modelContext.insert(version)
        try? modelContext.save()

        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif

        dismiss()
    }
}
