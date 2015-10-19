/***

  jsiso/pathdind/pathfind

  Using the A* Pathfind method
  
  item: - The item being tracked, allows us to assign a webworker to them
  s: start  array [x,y]
  e: end array [x,y] 
  m: map array of map tiles
    - 0 = Clear
    - 1 or bigger = block

***/

/***
 * 18.10.15 Пасфайндер(Поиск пути). Ищет путь по карт от точки s до e. Может пригодится, для следования за игроком
 * для НПЦ монстров.
 ***/

define(['module'], function(self) {

  var workers = [];

  return function (id, start, end, map, diagonal, force) {

    if (workers[id] === undefined) {
      workers[id] = (new Worker(self.uri.replace("pathfind.js", "worker.js?") + Math.random()));
    }

    return new Promise(function(resolve, reject) {

      if (start[0] != end[0] || start[1] != end[1]) {

        var pathfind = {
          worker: workers[id], // Fix to get web worker path from any location
          end: end,
          path: undefined,
          active: false
        };

        // Event Listener
        pathfind.worker.addEventListener('message', function(e) {
          if (typeof e.data[0] !== 'function') {
            pathfind.active = false;
            pathfind.path = e.data;
            resolve(e.data); // Pass data to resolve function
          }
        }, false);

        var pathfindWorker = function (p) {
            if (!p.active) {
              p.end = end;
              p.active = true;
              p.worker.postMessage({s: start, e: end, m: map, d: diagonal}); // Initiate WebWorker  
            }
          };

        // Check if end location is same as previous loop
        if ((force !== undefined && !force) && pathfind.end[0] == end[0] && pathfind.end[1] == end[1] && pathfind.path !== undefined) {

          // Loop through current path
          for (var i = 0, len = pathfind.path.length; i < len; i++) {
            if (pathfind.path[i].x == start[0] && pathfind.path[i].y == start[1]) {
              pathfind.path.splice(0, i);
              resolve(pathfind.path);
              return true;
            }
          }

          // If location not located
          pathfindWorker(pathfind);

        }
        else {
          pathfind.end = end;
          pathfind.path = undefined;

          // Perform Search
          pathfindWorker(pathfind);
        }

      } else {
        workers[id].terminate();
        workers[id] = undefined;
        return false; // No need for pathfind required
      }
    });
  };
});