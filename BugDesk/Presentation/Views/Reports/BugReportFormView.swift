import SwiftUI
import PhotosUI
import SwiftData

struct BugReportFormView: View {
    let version: Version
    let project: Project

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var vm = BugReportViewModel()

    @State private var appPickerItems: [PhotosPickerItem] = []
    @State private var designPickerItems: [PhotosPickerItem] = []
    @State private var showLogoutConfirmation = false
    @State private var showSuccessAlert = false

    @FocusState var focusedField: FormField?

    enum FormField: Hashable {
        case screenModule
        case summary
        case description
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.primaryBackground
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                VStack(spacing: 0) {
                    customNavBar

                    ScrollView {
                        VStack(spacing: Constants.Spacing.xlarge) {
                            headerSection

                            contentSection(geometry: geometry)
                        }
                        .padding(.horizontal, adaptiveHorizontalPadding(geometry))
                        .padding(.vertical, Constants.Spacing.xlarge)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .dismissKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
        .alert("auth.signOut".localized, isPresented: $showLogoutConfirmation, actions: {
            Button("auth.cancel".localized, role: .cancel) {}
            Button("auth.signOut".localized, role: .destructive) {
                authViewModel.signOut()
            }
        }, message: {
            Text("auth.signOutConfirm".localized)
        })
        .alert("result.saved".localized, isPresented: $showSuccessAlert) {
            Button("action.ok".localized, role: .cancel) {
                dismiss()
            }
        }
        .alert("validation.error".localized, isPresented: $vm.showError) {
            Button("action.ok".localized, role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
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
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)

                Text(project.name)
                    .font(FontManager.caption())
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            logoutButton
        }
        .padding(.horizontal, Constants.Spacing.large)
        .padding(.vertical, Constants.Spacing.medium)
        .background(
            theme.secondaryBackground
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            HStack(spacing: Constants.Spacing.small) {
                if let email = authViewModel.userEmail {
                    Text(email)
                        .font(FontManager.caption())
                        .foregroundColor(theme.secondaryText)
                        .lineLimit(1)
                }

                ZStack {
                    Circle()
                        .fill(theme.accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(FontManager.callout())
                        .foregroundColor(theme.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
    }

    private var headerSection: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accentColor.opacity(0.2), theme.accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "ladybug.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(theme.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("header.createReport".localized)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)

                Text("header.fillDetails".localized)
                    .font(FontManager.callout())
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .fadeIn(delay: 0.1)
    }

    private func contentSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: Constants.Spacing.large) {
            ExpandableChipSelector(
                title: "device.title".localized,
                placeholder: "device.hint".localized,
                items: Device.allCases,
                selected: $vm.report.devices
            )
            .fadeIn(delay: 0.15)

            ImprovedTextField(
                text: $vm.report.screenModule,
                label: "screenModule.title".localized,
                placeholder: "screenModule.hint".localized,
                axis: .horizontal,
                field: .screenModule,
                focusedField: $focusedField
            )
            .fadeIn(delay: 0.2)

            ExpandableChipSelector(
                title: "bugType.title".localized,
                placeholder: "bugType.placeholder".localized,
                items: BugType.allCases,
                selected: $vm.report.bugTypes
            )
            .fadeIn(delay: 0.25)

            ImprovedTextField(
                text: $vm.report.summary,
                label: "summary.title".localized,
                placeholder: "summary.hint".localized,
                axis: .vertical,
                lineLimit: 3,
                field: .summary,
                focusedField: $focusedField
            )
            .fadeIn(delay: 0.3)

            ImprovedTextField(
                text: $vm.report.description,
                label: "description.title".localized,
                placeholder: "description.hint".localized,
                axis: .vertical,
                lineLimit: 6,
                field: .description,
                focusedField: $focusedField
            )
            .fadeIn(delay: 0.35)

            ModernAttachmentPicker(
                title: "attachments.appHint".localized,
                items: $appPickerItems,
                attachments: vm.report.appAttachments,
                onSelect: {
                    Task {
                        await loadAttachments(from: appPickerItems, into: \.appAttachments)
                    }
                }
            )
            .fadeIn(delay: 0.4)

            ModernAttachmentPicker(
                title: "attachments.designHint".localized,
                items: $designPickerItems,
                attachments: vm.report.designAttachments,
                onSelect: {
                    Task {
                        await loadAttachments(from: designPickerItems, into: \.designAttachments)
                    }
                }
            )
            .fadeIn(delay: 0.45)

            CriticalityPicker(
                title: "criticality.title".localized,
                selection: $vm.report.criticality
            )
            .fadeIn(delay: 0.5)

            PrimaryButton(
                title: "action.save".localized,
                icon: "checkmark.circle.fill",
                action: saveBugReport
            )
            .fadeIn(delay: 0.55)
            .padding(.top, Constants.Spacing.medium)
        }
        .frame(maxWidth: min(geometry.size.width, Constants.Layout.maxFormWidth))
        .frame(maxWidth: .infinity)
    }

    private func adaptiveHorizontalPadding(_ geometry: GeometryProxy) -> CGFloat {
        #if os(iOS)
        return Constants.Spacing.large
        #elseif os(macOS)
        let contentWidth = min(geometry.size.width, Constants.Layout.maxFormWidth)
        return max(Constants.Spacing.large, (geometry.size.width - contentWidth) / 2)
        #endif
    }

    private func hideKeyboard() {
        focusedField = nil
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private func saveBugReport() {
        guard vm.isValid else {
            vm.errorMessage = "validation.error".localized
            vm.showError = true
            return
        }

        hideKeyboard()

        let storedBugReport = StoredBugReport(from: vm.report)
        storedBugReport.version = version
        version.bugReports.append(storedBugReport)

        modelContext.insert(storedBugReport)
        try? modelContext.save()

        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif

        showSuccessAlert = true
    }

    private func loadAttachments(from items: [PhotosPickerItem], into keyPath: WritableKeyPath<BugReportEntity, [Attachment]>) async {
        var collected: [Attachment] = []

        for item in items.prefix(10) {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let baseName = (item.itemIdentifier ?? UUID().uuidString)
                        .split(separator: "/").last.map(String.init) ?? "file"
                    let tmp = try persistTemp(data: data, suggested: baseName)
                    let mime = guessMimeType(for: tmp)
                    collected.append(Attachment(url: tmp, filename: tmp.lastPathComponent, mimeType: mime))
                }
            } catch {
                print("⚠️ Failed to load item: \(error.localizedDescription)")
            }
        }

        await MainActor.run {
            vm.report[keyPath: keyPath] = collected
        }
    }

    private func persistTemp(data: Data, suggested: String) throws -> URL {
        let filename = suggested.isEmpty ? UUID().uuidString : suggested
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}
