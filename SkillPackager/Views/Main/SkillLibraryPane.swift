//
//  SkillLibraryPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI
import SwiftSkyllKit


struct SkillLibraryPane: View {
    @Environment(InterfaceManager.self) var interface
    @Environment(SkillComposerModel.self) var model: SkillComposerModel

    let service = SkyllService.shared

    @Binding var isImporting: Bool

    @State private var query: String = ""
    @State private var showSettings = false
    @State private var isFetching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var searchError: String?

    var body: some View {
        VStack {
            HStack {
                TextField("Search for skills...", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit {
                        startSearch()
                    }

                Button(isFetching ? "Stop search" : "Search") {
                    if let searchTask {
                        searchTask.cancel()
                        self.searchTask = nil
                        isFetching = false
                    } else {
                        startSearch()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isFetching)
            }
            .padding(5)

            if isFetching {
                ProgressView()
            }

            if let searchError {
                Text(searchError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 5)
            }

            List(model.libraryState.library) { skill in
                Button {
                    model.toggleSelection(for: skill)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: model.libraryState.selectedSkillIDs.contains(skill.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(model.libraryState.selectedSkillIDs.contains(skill.id) ? Color.green : Color.blue)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(skill.name)
                                .font(.headline)
                            Text(skill.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)

                            if !skill.declaredInputs.isEmpty || !skill.declaredOutputs.isEmpty {
                                Text(portSummary(for: skill))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(interface)
                .presentationDetents([.large])
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.glass)
                .padding(.top, 10)
            }

            ToolbarItemGroup(placement: .automatic) {
                Button {
                    isImporting = true
                } label: {
                    VStack {
                        Image(systemName: "sparkles.rectangle.stack")
                        Text("Import").font(.caption)
                    }
                }
                .buttonStyle(.glass)
                .padding(.top, 12)
            }
        }
    }

    private func startSearch() {
        searchError = nil
        isFetching = true

        searchTask = Task {
            defer {
                Task { @MainActor in
                    isFetching = false
                    searchTask = nil
                }
            }

            do {
                let results = try await service.searchSkills(query: query)

                try Task.checkCancellation()

                let arr = results.map { $0.asSkillDefinition() }

                await MainActor.run {
                    model.libraryState.library.append(contentsOf: arr)
                }
            } catch is CancellationError {
                // Expected when user stops the search.
            } catch {
                await MainActor.run {
                    searchError = error.localizedDescription
                }
            }
        }
    }

    private func portSummary(for skill: SkillDefinition) -> String {
        let inputs = skill.declaredInputs.map(\.name).joined(separator: ", ")
        let outputs = skill.declaredOutputs.map(\.name).joined(separator: ", ")

        return switch (inputs.isEmpty, outputs.isEmpty) {
        case (false, false): "In: \(inputs)  Out: \(outputs)"
        case (false, true): "In: \(inputs)"
        case (true, false): "Out: \(outputs)"
        case (true, true): ""
        }
    }
}
