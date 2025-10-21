//
//  ContentView.swift
//  TahoeSafariBundleNotRecognizedDropBug
//
//  Created by Guillaume Leclerc on 21/10/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .onDrop(of: [.fileURL], delegate: AppsDropDelegate())
            Text("Hello, world!")
        }
        .padding()
    }
}

private struct AppsDropDelegate: DropDelegate {

    func validateDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.fileURL]) else { return false }

        let providers = info.itemProviders(for: [.fileURL])
        var result = false

        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                let group = DispatchGroup()
                group.enter()

                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    let itemIsAnApplicationBundle = try? url?.resourceValues(forKeys: [.contentTypeKey]).contentType == .applicationBundle
                    result = result || (itemIsAnApplicationBundle ?? false)    
                    group.leave()
                }
                                
                _ = group.wait(timeout: .now() + 0.5)
            }
        }

        return result
    }

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [.fileURL])
        var result = false

        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                let group = DispatchGroup()
                group.enter()

                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    let itemIsAnApplicationBundle = (try? url?.resourceValues(forKeys: [.contentTypeKey]).contentType == .applicationBundle) ?? false
                    
                    if itemIsAnApplicationBundle {
                        DispatchQueue.main.async {
                            print("dropped")
                        }
                        
                        result = result || true
                    }
                                        
                    group.leave()
                }

                _ = group.wait(timeout: .now() + 0.5)
            }
        }
        
        return result
    }
    
}
