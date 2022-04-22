//
//  FunGenTemplates.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation


let stateTemplate =
"""
import Foundation
import ComposableArchitecture

public struct {{name}}State: {% for protocol in protocols %}{{ protocol }}{% if protocols.last != protocol  %}, {% endif %}{% endfor %} {
{% for state in states %}
    {{ state.accessLevel }} {{ state.mutable }} {{ state.name }}: {{ state.type }}
{% endfor %}
    public init({% for state in states %}{{ state.name }}: {{ state.type }}{% if states.last.name != state.name  %}, {% endif %}{% endfor %}) {
    {% for state in states %}
        self.{{ state.name }} = {{ state.name }}
    {% endfor %}
    }
}
"""



let actionTemplate =
"""
import Foundation
import ComposableArchitecture
import Combine

enum {{name}}Action: Equatable {
{% for action in actions %}
    case {{ action.name }}{% if action.subtypes.count > 0 %}({% for subtype in action.subtypes %}{{ subtype.name }}: {{ subtype.type }}{% if action.subtypes.last.name != subtype.name  %}, {% endif %}{% endfor %}){% endif %}
{% endfor %}
{% if submodules.count > 0 %}
    // Submodule Actions
{% for submodule in submodules %}
    case {{ submodule.caseName }}Action({{ submodule.name}}Action)
{% endfor %}
{% endif %}
}
"""


let stateExtensionTemplate =
"""
import Foundation
import ComposableArchitecture

extension {{name}}State  {
{% for submodule in submodules where submodule.identifiable == false %}
    {{ submodule.states.first.name }}
    public var {{ submodule.caseName }}State: {{submodule.name}}State {
        get {
            .init({% for state in submodule.statesArray %}{{ state.name }}: {{ state.name }}{% if submodule.statesArray.last.name != state.name  %},{% endif %}{% endfor %})
        }
        set {
        {% for state in submodule.statesArray %}
            {{ state.name }} = newValue.{{ state.name }}
        {% endfor %}
        }
    }
{% endfor %}
}
"""
