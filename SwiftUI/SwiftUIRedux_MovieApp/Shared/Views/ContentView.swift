//
//  ContentView.swift
//  Shared
//
//  Created by Yilong Chen on 9/14/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var store: Store<AppState>
    @State private var searchText = ""
    struct Props {
        let movies: [Movie]
        let onSearch: (String) -> Void
    }
    
    func map(state: AppState, dispatch: @escaping Dispatcher) -> Props {
        Props(movies: state.moviesState.movies, onSearch: { search in
            dispatch(FetchMoviesAction(search: search))
        })
    }
    
    var body: some View {
        
        let props = map(state: store.state, dispatch: store.dispatch)
        
        VStack {
            TextField("search", text: $searchText, onEditingChanged: { _ in }, onCommit: {
                props.onSearch(searchText)
            }).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            List(props.movies, id: \.imdbId) { movie in
                NavigationLink(destination: MovieDetailsView(movie: movie), label: {
                    MovieCell(movie: movie)
                })
            }.listStyle(PlainListStyle())
        }
        .navigationTitle("Movies")
        .embedInNavigationView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let store = Store(reducer: appReducer, state: AppState(),
                          middlewares: [moviesMiddleware()])
        return ContentView().environmentObject(store)
    }
}

struct MovieCell: View {
    let movie: Movie
    var body: some View {
        HStack {
            URLImage(url: movie.poster)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            Text(movie.title)
        }
    }
}
