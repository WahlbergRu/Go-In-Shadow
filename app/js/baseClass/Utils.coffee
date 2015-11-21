class Utils
  constructor: () ->
    return {
      roundTo: (num, dec) ->
        Math.round(num * 10 ** dec) / 10 ** dec

      rand: (l, u) ->
        Math.floor Math.random() * (u - l + 1) + l

      remove: (from, to) ->
        rest = @slice((to or from) + 1 or @length)
        @length = if from < 0 then @length + from else from
        @push.apply this, rest

      range: (from, to) ->
        {
          from: from
          to: to
        }

      flipTwoDArray: (arrayLayout, direction) ->
        tempArray = []
        tempLine = []
        i = undefined
        j = undefined
        if direction == 'horizontal'
          i = arrayLayout.length - 1
          while i >= 0
            j = 0
            while j < arrayLayout[i].length
              tempLine.push arrayLayout[i][j]
              j++
            tempArray.push tempLine
            tempLine = []
            i--
          return tempArray
        else if direction == 'vertical'
          i = 0
          while i < arrayLayout.length
            j = arrayLayout[i].length - 1
            while j >= 0
              tempLine.push arrayLayout[i][j]
              j--
            tempArray.push tempLine
            tempLine = []
            i++
          return tempArray

      rotateTwoDArray: (arrayLayout, direction) ->
        tempArray = []
        tempLine = []
        i = undefined
        j = undefined
        w = arrayLayout.length
        h = if arrayLayout[0] then arrayLayout[0].length else 0
        if direction == 'left'
          i = 0
          while i < h
            j = 0
            while j < w
              if !tempArray[i]
                tempArray[i] = []
              tempArray[i][j] = arrayLayout[w - j - 1][i]
              j++
            i++
          return tempArray
        else if direction == 'right'
          i = 0
          while i < h
            j = 0
            while j < w
              if !tempArray[i]
                tempArray[i] = []
              tempArray[i][j] = arrayLayout[j][h - i - 1]
              j++
            i++
          return tempArray

      lineSplit: (ctx, text, width) ->
        textLines = []
        elements = ''
        line = ''
        tempLine = ''
        lastword = null
        if ctx.measureText(text).width > width
          elements = text.split(' ')
          i = 0
          while i < elements.length
            tempLine += elements[i] + ' '
            if ctx.measureText(tempLine).width < width
              line += elements[i] + ' '
              lastword = elements[i]
            else
              if lastword and lastword != elements[i]
                # Prevent getitng locked in a large word
                i--
                textLines.push line
              else
                textLines.push tempLine
              line = ''
              tempLine = ''
            i++
        else
          textLines[0] = text
        if line != ''
          textLines.push line
        textLines
    }

#console.log(new Utils())