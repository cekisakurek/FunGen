# Fungen

Fungen is a swift command line tool for generating an Action and State definitions for [The Composable Architecture.](https://github.com/pointfreeco/swift-composable-architecture) 

## Usage

```
OPTIONS:
  --input <input>         The file path for input file. Please check out the
                          examples for the definitions
  --output <output>       Output file directory. Required to be already
                          existing.
  --templates <templates> Templates directory
  --verbose

```

## Default Template

For States
```
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
```

For Actions
```
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
```

For State extension
```
{% for import in imports %}
import {{ import }}
{% endfor %}

extension {{name}}State {
{% for submodule in submodules %}
    {{ submodule.test }}
    public var {{ submodule.caseName }}State: {{submodule.name}}State {
        get {
            .init({% for state in submodule.statesArrayForStencil %}{{ state.name }}: {{ state.name }}{% if submodule.statesArrayForStencil.last.name != state.name  %}, {% endif %}{% endfor %})
        }
        set {
        {% for state in submodule.statesArrayForStencil %}
            {{ state.name }} = newValue.{{ state.name }}
        {% endfor %}
        }
    }
{% endfor %}
}
```

You can use your own template if you pass a folder path with --templates argument.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
