//
//  FunGenTemplates.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation


let stateTemplate =
"""
{% for import in imports %}
import {{ import }}
{% endfor %}

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
{% for import in imports %}
import {{ import }}
{% endfor %}

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
{% for import in imports %}
import {{ import }}
{% endfor %}

extension {{name}}State {
{% for submodule in submodules %}
    public var {{ submodule.caseName }}State: {{submodule.name}}State {
        get {
            .init({% for state in submodule.states %}{{ state.name }}: {{ state.name }}{% if submodule.states.last.name != state.name  %}, {% endif %}{% endfor %})
        }
        set {
        {% for state in submodule.states %}
            {{ state.name }} = newValue.{{ state.name }}
        {% endfor %}
        }
    }
{% endfor %}
}
"""
