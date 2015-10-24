#define [
#  'jsiso/particles/Particle'
#  'jsiso/utils'
#],
(Particle, utils) ->
  (ctx, x, y, pcount, loopJs, xboundRange, yboundRange) ->
    {
      particles: []
      xshiftOffset: 0
      yshiftOffset: 0
      loaded: false
      xOffset: 0
      yOffset: 0
      pause: false
      composite: 'lighter'
      xRange: utils.range(0, 0)
      yRange: utils.range(0, 0)
      drawdelayRange: utils.range(-1, -1)
      lifeRange: utils.range(1, 1)
      fadeRange: utils.range(1, 1)
      redRange: utils.range(255, 255)
      greenRange: utils.range(0, 0)
      blueRange: utils.range(0, 0)
      xiRange: utils.range(10, 10)
      yiRange: utils.range(10, 10)
      xgRange: utils.range(0, 0)
      ygRange: utils.range(0, 0)
      slowdownRange: utils.range(1, 1)
      radiusRange: utils.range(10, 10)
      scale: 1
      x: x
      y: y
      Load: (x, y) ->
        @particles = []
        i = 0
        while i < pcount
          @particles.push @CreateParticle(false, false, x, y)
          i++
        @loaded = true
        return
      ShiftTo: (x, y) ->
        @ShiftBy x - (@x), y - (@y)
        return
      Scale: (scale) ->
        @scale = scale
        return
      ShiftBy: (xoffset, yoffset) ->
        @xshiftOffset += xoffset
        @yshiftOffset += yoffset
        @x += xoffset
        @y += yoffset
        return
      Draw: (x, y) ->
        if x
          @x = x
        if y
          @y = y
        if @loaded and !@pause
          ctx.save()
          ctx.globalCompositeOperation = @composite
          i = 0
          tmpsize = @particles.length
          while i < tmpsize
            @particles[i].x += @xshiftOffset
            @particles[i].y += @yshiftOffset
            @particles[i].Draw ctx
            if loopJs and loopJs != 'false' and !@particles[i].active
              @particles[i] = @CreateParticle(@particles[i], true)
            i++
          ctx.restore()
          @xshiftOffset = 0
          @yshiftOffset = 0
        return
      CreateParticle: (reload, draw, x, y) ->
        p = undefined
        if reload
          p = reload
        else
          p = new Particle
        if draw or loopJs == false or loopJs == 'false'
          p.active = true
          if x
            p.x = x + utils.rand(@xRange.from * @scale, @xRange.to * @scale) + @xOffset * @scale
          else
            p.x = @x + utils.rand(@xRange.from * @scale, @xRange.to * @scale) + @xOffset * @scale
          if y
            p.y = y + utils.rand(@yRange.from * @scale, @yRange.to * @scale) + @yOffset * @scale
          else
            p.y = @y + utils.rand(@yRange.from * @scale, @yRange.to * @scale) + @yOffset * @scale
          p.drawdelay = 0
          p.life = utils.rand(@lifeRange.from * 1000, @lifeRange.to * 1000) / 1000
          p.fade = utils.rand(@fadeRange.from * 1000, @fadeRange.to * 1000) / 1000
          p.r = utils.rand(@redRange.from, @redRange.to)
          p.b = utils.rand(@blueRange.from, @blueRange.to)
          p.g = utils.rand(@greenRange.from, @greenRange.to)
          p.xi = utils.rand(@xiRange.from * @scale, @xiRange.to * @scale)
          p.yi = utils.rand(@yiRange.from * @scale, @yiRange.to * @scale)
          p.xg = utils.rand(@xgRange.from * @scale, @xgRange.to * @scale)
          p.yg = utils.rand(@ygRange.from * @scale, @ygRange.to * @scale)
          p.slowdown = utils.rand(@slowdownRange.from * 1000, @slowdownRange.to * 1000) / 1000
          p.radius = utils.rand(@radiusRange.from * @scale, @radiusRange.to * @scale)
          p.minxb = xboundRange.from * @scale
          p.maxxb = xboundRange.to * @scale
          p.minyb = yboundRange.from * @scale
          p.maxyb = yboundRange.to * @scale
        p

    }
