define [ 'jsiso/utils' ], (utils) ->
  ->
    age = 0
    {
      active: false
      drawdelay: -1
      life: 0
      fade: 0.01
      r: 255
      g: 0
      b: 0
      x: 0.0
      y: 0.0
      xi: 0.1
      yi: 0.0
      xg: 0.0
      yg: 0.0
      radius: 5.0
      slowdown: 2.0
      minxb: -1
      maxxb: 999999
      minyb: -1
      maxyb: 999999
      Draw: (context) ->
        if @active
          if @drawdelay == -1 or age >= @drawdelay
            # Determine alpha based on life
            alpha = if @life > 1.0 then 1 else if @life < 0.0 then 0 else @life
            rgbstr = 'rgba(' + @r + ', ' + @g + ', ' + @b + ', ' + utils.roundTo(alpha, 1) + ')'
            rgbbgstr = 'rgba(' + Math.floor(@r / 3) + ', ' + Math.floor(@g / 3) + ', ' + Math.floor(@b / 3) + ', 0)'
            # Draw the particle
            if Number(@x) != undefined and Number(@y) != undefined
              if @x > @minxb or @x < @maxxb or @y > @minyb or @y < @maxyb
                p = context.createRadialGradient(@x, @y, 0, @x, @y, @radius)
                p.addColorStop 0, rgbstr
                p.addColorStop 1, rgbbgstr
                context.fillStyle = p
                context.fillRect @x - (@radius), @y - (@radius), @radius * 2, @radius * 2
              # Update the position base on speed and direction
              @x += @xi / (@slowdown * 100)
              @y -= @yi / (@slowdown * 100)
              # canvas negative is up so flip the sign
              # Apply gravity to the speed and direction
              @xi += @xg
              @yi += @yg
              # Update the life based on fade
              @life -= @fade
              @radius -= @radius / 1 * @fade
              #/ Kill dead or out of bound particles
              if @life <= 0
                @active = false
          # Increment the particle age
          age++
        return

    }
