###  
Copyright (c) 2013 Iain Hamilton & Edward Smyth

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. 
###

###
	Pathfind Worker
###

self.addEventListener 'message', ((evt) ->
  # Initial passed values
  s = evt.data.s
  e = evt.data.e
  m = evt.data.m
  d = if evt.data.d == false then false else true
  # Allow Diagonal Movement

  ###
  	Nodes -
  	x: x position
  	y: y position
  	p: Index of the parent node (Stored in closed array)
  	g: Cost from start to current node
  	h: Heuristic cost from current node to destination
  	f: Cost from start to desination going through current node
  ###

  node = (x, y, p, g, h, f) ->
    @x = x
    @y = y
    @p = p
    @g = g
    @h = h
    @f = f
    return

  ###
  	Heuristic - Estimated movement cost from current square to end position
  ###

  heuristic = (current, end) ->
    x = current.x - (end.x)
    y = current.y - (end.y)
    x ** 2 + y ** 2

  ###
  	Difference
  ###

  diff = (a, b) ->
    Math.abs if a > b then a - b else b - a

  # Set-up Nodes
  s = new node(s[0], s[1], -1, -1, -1, -1)
  # Start Node
  e = new node(e[0], e[1], -1, -1, -1, -1)
  # End Node

  ###
  	Set-up Variables
  ###

  cols = m.length - 1
  rows = m[0].length - 1
  o = []
  c = []
  mn = new Array(rows * cols)
  g = 0
  h = heuristic(s, e)
  f = g + h
  # Place start node onto list of open nodes
  o.push s
  # Initiate Search Loop, keep going while there are nodes in the open list
  while o.length > 0
    # Locate Best Node
    best = 
      c: o[0].f
      n: 0
    i = 1
    len = o.length
    while i < len
      if o[i].f < best.c
        best.c = o[i].f
        best.n = i
      i++
    # Set current to best
    current = o[best.n]
    # Check if end point has been reached
    if current.x == e.x and current.y == e.y
      path = [ {
        x: e.x
        y: e.y
      } ]
      # Create Path 
      # Loop back through parents to complete the path
      while current.p != -1
        current = c[current.p]
        path.unshift
          x: current.x
          y: current.y
      self.postMessage path
      # Return the path
      return true
    # Remove current node from open list
    o.splice best.n, 1
    mn[current.x + current.y * rows * cols] = false
    # Set bit to closed
    c.push current
    # Search new nodes in all directions
    x = Math.max(0, current.x - 1)
    lenx = Math.min(cols, current.x + 1)
    while x <= lenx
      y = Math.max(0, current.y - 1)
      leny = Math.min(rows, current.y + 1)
      while y <= leny
        if d or diff(current.x, x) + diff(current.y, y) <= 1
          # Check if location square is open
          if Number(m[x][y]) == 0
            # Check if square is in closed list
            if mn[x + y * rows * cols] == false
              y++
              continue
            # If square not in open list use it
            if mn[x + y * rows * cols] != true
              n = new node(x, y, c.length - 1, -1, -1, -1)
              # Create new node
              n.g = current.g + Math.floor(Math.sqrt((n.x - (current.x)) ** 2 + (n.y - (current.y)) ** 2))
              n.h = heuristic(n, e)
              n.f = n.g + n.h
              o.push n
              # Push node onto open list
              mn[x + y * rows * cols] = true
              # Set bit into open list
        y++
      x++
  self.postMessage []
  # No Path Found!
  true
), false
