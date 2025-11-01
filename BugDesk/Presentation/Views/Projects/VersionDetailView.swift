import SwiftUI
import SwiftData

struct VersionDetailView: View {
    let version: Version
    let project: Project

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var viewModel = BugReportViewModel()

    @State private var bugToDelete: StoredBugReport?
    @State private var showDeleteAlert = false
    @State private var isGenerating = false

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                if version.bugReports.isEmpty {
                    emptyStateView
                } else {
                    bugListContent
                }
            }

            if isGenerating {
                generatingOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("result.error".localized, isPresented: $viewModel.showError) {
            Button("action.ok".localized, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("bugList.title".localized, isPresented: $viewModel.showSuccess) {
            Button("result.openSheet".localized) {
                if let url = viewModel.spreadsheetURL {
                    openURL(url)
                }
            }
            Button("result.openAttachments".localized) {
                if let url = viewModel.attachmentsFolderURL {
                    openURL(url)
                }
            }
            Button("action.ok".localized, role: .cancel) {}
        } message: {
            Text("result.successMessage".localized)
        }
        .alert("action.delete".localized, isPresented: $showDeleteAlert, presenting: bugToDelete) { bug in
            Button("action.cancel".localized, role: .cancel) {}
            Button("action.delete".localized, role: .destructive) {
                deleteBug(bug)
            }
        } message: { _ in
            Text("action.delete".localized)
        }
    }

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

            VStack(alignment: .leading, spacing: 4) {
                Text(version.name)
                    .font(FontManager.largeTitle())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text(project.name)
                    .font(FontManager.callout())
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            if !version.bugReports.isEmpty {
                Button(action: generateReport) {
                    HStack(spacing: Constants.Spacing.small) {
                        Image(systemName: "doc.text.fill")
                            .font(FontManager.body())
                        Text("bugList.generateList".localized)
                            .font(FontManager.body())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.Spacing.medium)
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

                Image(systemName: "ladybug")
                    .font(.system(size: 60))
                    .foregroundColor(theme.accentColor.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: Constants.Spacing.small) {
                Text("bugList.empty".localized)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                Text("bugList.emptyDesc".localized)
                    .font(FontManager.body())
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(destination: BugReportFormView(version: version, project: project).environmentObject(authViewModel)) {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "plus.circle.fill")
                    Text("bugList.add".localized)
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
            #if os(iOS)
            .buttonStyle(.plain)
            #endif

            Spacer()
        }
        .padding(Constants.Spacing.large)
        .fadeIn(delay: 0.1)
    }

    private var bugListContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.medium) {
                    ForEach(Array(version.bugReports.enumerated()), id: \.element.id) { index, bug in
                        BugReportCard(bug: bug, onDelete: {
                            bugToDelete = bug
                            showDeleteAlert = true
                        })
                        .fadeIn(delay: Double(index) * 0.05)
                    }
                }
                .padding(Constants.Spacing.large)
            }

            addButton
        }
    }

    private var addButton: some View {
        NavigationLink(destination: BugReportFormView(version: version, project: project).environmentObject(authViewModel)) {
            HStack(spacing: Constants.Spacing.small) {
                Image(systemName: "plus.circle.fill")
                    .font(FontManager.body())
                Text("bugList.add".localized)
                    .font(FontManager.body())
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.medium)
            .background(
                LinearGradient(
                    colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Constants.CornerRadius.medium)
            .shadow(color: theme.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        #if os(iOS)
        .buttonStyle(.plain)
        #endif
        .padding(Constants.Spacing.large)
        .background(theme.primaryBackground)
    }

    private var generatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: Constants.Spacing.large) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("bugList.generating".localized)
                    .font(FontManager.body())
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .padding(Constants.Spacing.xxlarge)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }

    private func generateReport() {
        isGenerating = true

        Task {
            let bugReports = version.bugReports.map { $0.toBugReportEntity() }
            let accessToken = authViewModel.accessToken ?? ""

            await viewModel.generateBatchReport(
                bugReports: bugReports,
                projectName: project.name,
                versionName: version.name,
                accessToken: accessToken
            )

            await MainActor.run {
                isGenerating = false
            }
        }
    }

    private func deleteBug(_ bug: StoredBugReport) {
        withAnimation(AnimationManager.spring) {
            modelContext.delete(bug)
            try? modelContext.save()
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

struct BugReportCard: View {
    let bug: StoredBugReport
    let onDelete: () -> Void

    @EnvironmentObject private var theme: ThemeManager
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            criticalityIndicator

            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                Text(bug.summary)
                    .font(FontManager.body())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.medium)
                    .lineLimit(2)

                HStack(spacing: Constants.Spacing.medium) {
                    if !bug.bugTypes.isEmpty {
                        HStack(spacing: Constants.Spacing.tiny) {
                            Image(systemName: "tag.fill")
                                .font(FontManager.caption2())
                            Text(bug.bugTypes.joined(separator: ", "))
                                .font(FontManager.caption())
                                .lineLimit(1)
                        }
                        .foregroundColor(theme.secondaryText)
                    }

                    if !bug.screenModule.isEmpty {
                        HStack(spacing: Constants.Spacing.tiny) {
                            Image(systemName: "app.fill")
                                .font(FontManager.caption2())
                            Text(bug.screenModule)
                                .font(FontManager.caption())
                                .lineLimit(1)
                        }
                        .foregroundColor(theme.secondaryText)
                    }
                }

                if !bug.devices.isEmpty {
                    HStack(spacing: Constants.Spacing.tiny) {
                        Image(systemName: "iphone")
                            .font(FontManager.caption2())
                        Text(bug.devices.joined(separator: ", "))
                            .font(FontManager.caption())
                            .lineLimit(1)
                    }
                    .foregroundColor(theme.secondaryText.opacity(0.7))
                }
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

    private var criticalityIndicator: some View {
        let criticality = Criticality(rawValue: bug.criticality) ?? .medium

        return RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
            .fill(criticalityColor(criticality))
            .frame(width: 4, height: 60)
    }

    private func criticalityColor(_ criticality: Criticality) -> Color {
        switch criticality {
        case .highest: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .lowest: return .green
        }
    }
}
