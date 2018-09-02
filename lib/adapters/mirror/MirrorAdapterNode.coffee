[AdapterNode] = require('../../AdapterNode')

module.exports = class MirrorAdapterNode extends AdapterNode
  processData: (data) ->
    @setValid data.valid
    for aspectId, aspect of (data.aspects or {})
      unless @hasAspect(aspectId) then @addAspect(aspectId, {})
      @getAspect(aspectId).setData aspect.data
    for childData in (data.children or [])
      child = @children.get(childData.id)
      unless child?
        child = new MirrorAdapterNode({id: childData.id}, {adapter: this})
        @children.add child
      child.processData childData