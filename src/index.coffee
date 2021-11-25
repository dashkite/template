import FS from "fs/promises"
import Path from "path"
import Handlebars from "handlebars"
# import { globby as glob } from "globby"
import YAML from "js-yaml"
import glob from "fast-glob"
import * as _ from "@dashkite/joy"

registerHelpers = (self) ->
  self._.h.registerHelper {
    first: _.first
    rest: _.rest
    filter: _.select
    project: _.project
    join: _.join
    values: _.values
    equal: _.eq
    empty: _.isEmpty
    dashed: _.dashed
    camelCase: _.camelCase
    capitalize: _.capitalize
    titleCase: _.titleCase
    # TODO add wrap and indent to Joy?
    wrap: (width, text) ->
      text
        .match ///.{1,#{width}}(\s+|$)///g
        .join "\n"
    indent: (n, text) -> text.replace /\n/g, "\n#{ " ".repeat n }"
    yaml: (value) -> YAML.dump value
    json: (value) -> JSON.stringify value, null, 2
  }

registerPartials = (self) ->
  for path in await glob [ "**/_*/*.hbs", "**/_*.hbs" ], cwd: self.root
    name = path
      .replace /\.hbs$/, ""
      .replace /\/\_/, "/"
      .replace /^\_/, ""
    self._.h.registerPartial name, await self.read path

class Templates

  @create: (root) ->
    self = new Templates
    self.root = root
    registerHelpers self
    registerPartials self
    self

  constructor: ->
    @_ =
      h: Handlebars.create()
      cache: {}

  render: (name, context) ->
    @_.cache[ name ] ?= await @compile name
    @_.cache[ name ] context

  compile: (name) ->
    @_.h.compile await @read name

  read: (name) ->
    FS.readFile ( @resolve name ), "utf8"

  resolve: (name) ->
    Path.resolve @root,
      if _.endsWith ".hbs", name then name else "#{name}.hbs"

export default Templates