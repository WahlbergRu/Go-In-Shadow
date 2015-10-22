define ->
  (emitter) ->
    emitters = [ emitter ]
    @pause = false
    {
      AddEmitter: (emitter) ->
        emitters.push emitter
        return
      Draw: (x, y, scale) ->
        if !@pause
          i = 0
          tmpTotal = emitters.length
          while i < tmpTotal
            if !emitters[i].loaded
              emitters[i].x = x
              emitters[i].y = y
              emitters[i].Load()
            if scale
              emitters[i].Scale scale
            emitters[i].ShiftTo x, y
            emitters[i].Draw()
            i++
        return

    }
