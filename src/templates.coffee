import FS from "fs/promises"
import Path from "path"
import Handlebars from "handlebars"
# import { globby as glob } from "globby"
import glob from "fast-glob"
import * as _ from "@dashkite/joy"

registerHelpers = (self) ->
  self._.h.registerHelper {
    _...
    empty: _.isEmpty
    templateCase: _.pipe [ _.normalize, _.camelCase, _.capitalize ]
  }

registerPartials = (self) ->
  for path in await glob "**/_*.hbs", cwd: self.root
    name = path.replace /\.\w+$/, ""
    console.log name
    self._.h.registerPartial name, await self.read name

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
    Path.resolve @root, "#{name}.hbs"


export default Templates