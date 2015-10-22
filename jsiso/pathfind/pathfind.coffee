###**

  jsiso/pathdind/pathfind

  Using the A* Pathfind method

  item: - The item being tracked, allows us to assign a webworker to them
  s: start  array [x,y]
  e: end array [x,y] 
  m: map array of map tiles
    - 0 = Clear
    - 1 or bigger = block

**
###

###**
# 18.10.15 ����������(����� ����). ���� ���� �� ���� �� ����� s �� e. ����� ����������, ��� ���������� �� �������
# ��� ��� ��������.
#*
###

define [ 'module' ], (self) ->
  workers = []
  (id, start, end, map, diagonal, force) ->
    if workers[id] == undefined
      workers[id] = new Worker(self.uri.replace('pathfind.js', 'worker.js?') + Math.random())
    new Promise((resolve, reject) ->
      if start[0] != end[0] or start[1] != end[1]
        pathfind = 
          worker: workers[id]
          end: end
          path: undefined
          active: false
        # Event Listener
        pathfind.worker.addEventListener 'message', ((e) ->
          if typeof e.data[0] != 'function'
            pathfind.active = false
            pathfind.path = e.data
            resolve e.data
            # Pass data to resolve function
          return
        ), false

        pathfindWorker = (p) ->
          if !p.active
            p.end = end
            p.active = true
            p.worker.postMessage
              s: start
              e: end
              m: map
              d: diagonal
            # Initiate WebWorker  
          return

        # Check if end location is same as previous loop
        if force != undefined and !force and pathfind.end[0] == end[0] and pathfind.end[1] == end[1] and pathfind.path != undefined
          # Loop through current path
          i = 0
          len = pathfind.path.length
          while i < len
            if pathfind.path[i].x == start[0] and pathfind.path[i].y == start[1]
              pathfind.path.splice 0, i
              resolve pathfind.path
              return true
            i++
          # If location not located
          pathfindWorker pathfind
        else
          pathfind.end = end
          pathfind.path = undefined
          # Perform Search
          pathfindWorker pathfind
      else
        workers[id].terminate()
        workers[id] = undefined
        return false
        # No need for pathfind required
      return
)
