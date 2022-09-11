//
//  File.swift
//  
//
//  Created by Jakub Legut on 09/09/2022.
//

import SwiftUI
import ComposableArchitecture
import Combine
import Common

//MARK: - STATE
public struct ClubTagFilterState: Equatable {
    var allTags: [Tag] = []
    var selectedTag: Tag? = nil
    
    let initialTag: Tag = .init(
        id: 0,
        name: "All"
    )
    
    public init(){}
}
//MARK: - ACTION
public enum ClubTagFilterAction: Equatable {
    case onAppear
    case updateTags([Tag])
    case choosedTag(Tag)
    case updateFilter(Tag?)
}

//MARK: - ENVIRONMENT
public struct ClubTagFilterEnvironment {
    public init(){}
}

//MARK: - REDUCER
public let clubTagFilterReducer = Reducer<
    ClubTagFilterState,
    ClubTagFilterAction,
    ClubTagFilterEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        if state.allTags.isEmpty {
            state.allTags.append(state.initialTag)
        }
        return .none
    case .updateTags(let tags):
        state.allTags = [state.initialTag]
        state.allTags.append(contentsOf: Array(Set(tags)))
        if state.selectedTag == nil {
            state.selectedTag = state.initialTag
        }
        return .none
    case .choosedTag(let tag):
        if tag == state.initialTag || state.selectedTag == tag {
            state.selectedTag = state.initialTag
            return .init(value: .updateFilter(nil))
        } else {
            state.selectedTag = tag
        }
        return .init(value: .updateFilter(state.selectedTag))
    case .updateFilter:
        return .none
    }
}

//MARK: - VIEW
public struct ClubTagFilterView: View {
    let store: Store<ClubTagFilterState, ClubTagFilterAction>
    
    public init(
        store: Store<ClubTagFilterState, ClubTagFilterAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                if viewStore.allTags.count > 0 {
                    HStack {
                        ForEach(viewStore.allTags, id: \.self) { tag in
                            TagItemView(
                                text: tag.name ?? String(tag.id),
                                isSelected: viewStore.selectedTag == tag,
                                action: { viewStore.send(.choosedTag(tag)) }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
    
    struct TagItemView: View {
        
        let text: String
        let isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            if isSelected {
                Button(action: { action() }) {
                    Text(text)
                        .font(.caption)
                        .padding(.small)
                        .foregroundColor(K.Colors.white)
                }
                .background(K.Colors.firstColorDark)
                .clipShape(Capsule())
            } else {
                Button(action: { action() }) {
                    Text(text)
                        .font(.caption)
                        .padding(.small)
                        .foregroundColor(Color.gray)
                }
                .background(
                    Capsule()
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
    }
}

#if DEBUG
struct ClubTagFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ClubTagFilterView(
            store: Store(
                initialState: .init(),
                reducer: clubTagFilterReducer,
                environment: .failing
            )
        )
    }
}

public extension ClubTagFilterEnvironment {
    static let failing: Self = .init()
}
#endif


