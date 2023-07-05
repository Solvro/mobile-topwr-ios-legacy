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

public struct ClubTagFilter: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var allTags: [Tag]
        var selectedTag: Tag? = nil
        
        let initialTag: Tag = .init(
            id: 0,
            name: "All"
        )
        
        public init(allTags: [Tag] = [], selectedTag: Tag? = nil) {
            self.allTags = allTags
            self.selectedTag = selectedTag
        }
    }
    
    // MARK: - Action
    public enum Action: Equatable {
        case updateTags([Tag])
        case choosedTag(Tag)
        case updateFilter(Tag?)
    }
    
    // MARK: - Reducer
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
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
    }
}

//MARK: - VIEW
public struct ClubTagFilterView: View {
    let store: StoreOf<ClubTagFilter>
    
    public init(store: StoreOf<ClubTagFilter>) {
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
						.strokeBorder(K.Colors.tagGrey, lineWidth: 1)
                )
            }
        }
    }
}

#if DEBUG
// MARK: - Mock
extension ClubTagFilter.State {
    static let mock: Self = .init()
}

// MARK: - Preview
private struct TemplateView_Preview: PreviewProvider {
    static var previews: some View {
        ClubTagFilterView(
            store: .init(
                initialState: .mock,
                reducer: ClubTagFilter()
            )
        )
    }
}

#endif

