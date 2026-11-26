import SwiftUI
import WebKit
import UniformTypeIdentifiers
import Security

private enum Theme {
    static let background = Color(red: 0.035, green: 0.035, blue: 0.055)
    static let panel = Color(red: 0.085, green: 0.075, blue: 0.12)
    static let purple = Color(red: 0.63, green: 0.35, blue: 1.0)
    static let pink = Color(red: 0.95, green: 0.28, blue: 0.73)
    static let muted = Color.white.opacity(0.62)
}

struct ImportedFile: Identifiable {
    let id = UUID()
    let name: String
    let kind: String
    let size: Int64
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showImporter = false
    @State private var importedFiles: [ImportedFile] = []
    @State private var notice: String?

    private var supportedTypes: [UTType] {
        var types: [UTType] = [.data]
        if let ipa = UTType(filenameExtension: "ipa") { types.append(ipa) }
        if let p12 = UTType(filenameExtension: "p12") { types.append(p12) }
        if let profile = UTType(filenameExtension: "mobileprovision") { types.append(profile) }
        return types
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Group {
                    switch selectedTab {
                    case 0: homeView
                    case 1: catalogueView
                    case 2: filesView
                    default: settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                tabBar
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: supportedTypes, allowsMultipleSelection: true) { result in
            handleImport(result)
        }
        .alert("Unknown Source Signer", isPresented: Binding(
            get: { notice != nil },
            set: { if !$0 { notice = nil } }
        )) {
            Button("OK", role: .cancel) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 13).fill(
                    LinearGradient(colors: [Theme.purple, Theme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 43, height: 43)
            VStack(alignment: .leading, spacing: 2) {
                Text("Unknown Source").font(.system(size: 18, weight: .bold))
                Text("SIGNER").font(.system(size: 10, weight: .heavy, design: .rounded)).tracking(2.5).foregroundStyle(Theme.purple)
            }
            Spacer()
            Circle().fill(Color.green).frame(width: 7, height: 7)
            Text("LOCAL").font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(LinearGradient(colors: [Color(red: 0.22, green: 0.09, blue: 0.37), Color(red: 0.10, green: 0.07, blue: 0.18), Theme.panel], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Circle().fill(Theme.purple.opacity(0.25)).frame(width: 180).blur(radius: 20).offset(x: 180, y: -45)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("IPA WORKSPACE").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(Theme.purple)
                        Text("Your apps.\nYour workflow.").font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("Manage IPA files and signing assets in one place.").font(.system(size: 13)).foregroundStyle(Theme.muted)
                        Button { showImporter = true } label: {
                            Label("Import files", systemImage: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16).padding(.vertical, 11)
                                .background(Theme.purple, in: Capsule())
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 4)
                    }
                    .padding(22)
                }
                .frame(height: 245)
                HStack {
                    Text("Quick actions").font(.system(size: 18, weight: .bold))
                    Spacer()
                    Text("\(importedFiles.count) files").font(.system(size: 12)).foregroundStyle(Theme.muted)
                }
                HStack(spacing: 12) {
                    actionCard("Import IPA", subtitle: "Choose an app", icon: "shippingbox", color: Theme.purple) { showImporter = true }
                    actionCard("Certificates", subtitle: "P12 & profiles", icon: "checkmark.seal", color: Theme.pink) { selectedTab = 2 }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Label("Security first", systemImage: "lock.shield")
                        .font(.system(size: 15, weight: .semibold))
                    Text("This starter app never asks for or stores your Apple Account password. File imports stay on-device in this prototype.")
                        .font(.system(size: 12)).foregroundStyle(Theme.muted)
                }
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(18)
        }
    }

    private var catalogueView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unknown Source").font(.system(size: 22, weight: .bold))
                    Text("Official website catalogue").font(.system(size: 12)).foregroundStyle(Theme.muted)
                }
                Spacer()
                Button { selectedTab = 0 } label: { Image(systemName: "house.fill").foregroundStyle(Theme.purple).padding(10).background(Theme.panel, in: Circle()) }
            }.padding(.horizontal, 18).padding(.vertical, 12)
            WebsiteView(url: URL(string: "https://unknown-source-ios.web.app/")!)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 10).padding(.bottom, 10)
        }
    }

    private var filesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Files & assets").font(.system(size: 25, weight: .bold)).padding(.top, 6)
                Text("Imported items are listed for review. This prototype does not sign or install apps by itself.")
                    .font(.system(size: 12)).foregroundStyle(Theme.muted)
                Button { showImporter = true } label: {
                    Label("Import IPA / P12 / profile", systemImage: "tray.and.arrow.down.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(14)
                        .background(Theme.purple, in: RoundedRectangle(cornerRadius: 14))
                }
                if importedFiles.isEmpty {
                    emptyState(icon: "doc.on.doc", title: "No imported files", detail: "Choose an IPA, P12 certificate, or provisioning profile.")
                } else {
                    ForEach(importedFiles) { file in
                        HStack(spacing: 12) {
                            Image(systemName: icon(for: file.kind)).font(.system(size: 20)).foregroundStyle(Theme.purple)
                                .frame(width: 44, height: 44).background(Theme.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.name).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                                Text("\(file.kind.uppercased()) · \(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))")
                                    .font(.system(size: 11)).foregroundStyle(Theme.muted)
                            }
                            Spacer()
                        }
                        .padding(12).background(Theme.panel, in: RoundedRectangle(cornerRadius: 15))
                    }
                }
            }.padding(18)
        }
    }

    private var settingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings").font(.system(size: 25, weight: .bold)).padding(.top, 6)
                settingRow(icon: "moon.stars.fill", title: "Dopamine dark theme", detail: "Purple accents and deep dark surfaces", value: "Enabled")
                settingRow(icon: "globe", title: "Unknown Source", detail: "unknown-source-ios.web.app", value: "Connected")
                settingRow(icon: "person.crop.circle.badge.checkmark", title: "Apple Account", detail: "Use Apple's supported sign-in flows", value: "Not connected")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signing status").font(.system(size: 15, weight: .semibold))
                    Text("IPA signing requires valid signing assets, provisioning, and a supported signing workflow. No signing bypass is included.")
                        .font(.system(size: 12)).foregroundStyle(Theme.muted)
                }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Theme.panel, in: RoundedRectangle(cornerRadius: 16))
            }.padding(18)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tab("house.fill", title: "Home", index: 0)
            tab("globe", title: "Source", index: 1)
            tab("folder.fill", title: "Files", index: 2)
            tab("gearshape.fill", title: "Settings", index: 3)
        }
        .padding(.top, 10).padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1) }
    }

    private func tab(_ symbol: String, title: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 18, weight: .semibold))
                Text(title).font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? Theme.purple : Theme.muted)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func actionCard(_ title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundStyle(color)
                    .frame(width: 42, height: 42).background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                Text(title).font(.system(size: 14, weight: .bold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(15)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain)
    }

    private func settingRow(icon: String, title: String, detail: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(Theme.purple).frame(width: 38, height: 38).background(Theme.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(detail).font(.system(size: 11)).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 8)
            Text(value).font(.system(size: 10, weight: .semibold)).foregroundStyle(Theme.muted)
        }.padding(13).background(Theme.panel, in: RoundedRectangle(cornerRadius: 15))
    }

    private func emptyState(icon: String, title: String, detail: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 30)).foregroundStyle(Theme.purple)
            Text(title).font(.system(size: 15, weight: .semibold))
            Text(detail).font(.system(size: 12)).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(28).background(Theme.panel, in: RoundedRectangle(cornerRadius: 18))
    }

    private func icon(for kind: String) -> String {
        switch kind {
        case "ipa": return "shippingbox.fill"
        case "p12": return "checkmark.seal.fill"
        default: return "doc.badge.gearshape"
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let ext = url.pathExtension.lowercased()
                let kind: String
                if ext == "ipa" { kind = "ipa" }
                else if ext == "p12" { kind = "p12" }
                else if ext == "mobileprovision" { kind = "mobileprovision" }
                else { continue }
                let values = try? url.resourceValues(forKeys: [.fileSizeKey])
                let item = ImportedFile(name: url.lastPathComponent, kind: kind, size: Int64(values?.fileSize ?? 0))
                if !importedFiles.contains(where: { $0.name == item.name && $0.kind == item.kind }) {
                    importedFiles.append(item)
                }
            }
            if urls.isEmpty { notice = "No files were selected." }
        case .failure(let error):
            notice = "Import failed: \(error.localizedDescription)"
        }
    }
}

private struct WebsiteView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0.035, green: 0.035, blue: 0.055, alpha: 1)
        view.scrollView.backgroundColor = view.backgroundColor
        view.load(URLRequest(url: url))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
