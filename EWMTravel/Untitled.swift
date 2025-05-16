//
//  Untitled.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 25.06.2024.
//

import SwiftUI
import UIKit

struct CustomSearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool
        
        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isEditing = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            isEditing = false
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage() // To remove the default background
        searchBar.backgroundColor = UIColor.white // Set the background color
        searchBar.searchTextField.backgroundColor = UIColor.white // Set the text field background color
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}
