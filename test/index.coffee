import Templates from "../src"
import assert from "@dashkite/assert"

do ->
  t = Templates.create "#{__dirname}/templates"
  assert.equal "This is a test.",
    await t.render "test", noun: "test"