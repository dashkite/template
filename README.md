# Template

```coffeescript
import Templates from "@dashkite/template"

template = Templates.create "./templates"
main = await template.render "main.yaml"
```