
define(function() {
  return function(emitter) {

    var emitters = [emitter];
    this.pause = false;

    return {
      AddEmitter: function (emitter) {
        emitters.push(emitter);
      },

      Draw: function (x, y, scale) {
        if (!this.pause) {
          for (var i = 0, tmpTotal = emitters.length; i < tmpTotal; i++) {
            if (!emitters[i].loaded) {
              emitters[i].x = x;
              emitters[i].y = y;
              emitters[i].Load();
            }
            if (scale) {
              emitters[i].Scale(scale);
            }
            emitters[i].ShiftTo(x, y);
            emitters[i].Draw();
          }
        }
      }
    };
  };
});