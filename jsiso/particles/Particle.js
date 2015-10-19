
define([
  'jsiso/utils'
],

function(utils) {

  return function () {

    var age = 0;

    return {
      active: false, // draw or not
      drawdelay: -1, // how old before the particle can start drawing
      life: 0,    // particle lifespan
      fade: 0.01,   // fade speed
      r: 255,       // red intensity
      g: 0,         // green intensity
      b: 0,         // blue intensity
      x: 0.0,       // x position
      y: 0.0,       // y position
      xi: 0.1,      // x axis speed
      yi: 0.0,      // y axis speed
      xg: 0.0,      // x gravity strength
      yg: 0.0,      // y gravity strength
      radius: 5.0,  // particle radius
      slowdown: 2.0, // particle speed slowdown
      minxb: -1,     // min x axis boundry
      maxxb: 999999, // max x axis boundry
      minyb: -1,     // min y axis boundry
      maxyb: 999999, // max y axis boundry

      Draw: function(context) {

        if (this.active) {

          if (this.drawdelay == -1 || age >= this.drawdelay) {

            // Determine alpha based on life
            var alpha = this.life > 1.0 ? 1 : this.life < 0.0 ? 0 : this.life;
            var rgbstr = "rgba(" + this.r + ", " + this.g + ", " + this.b + ", " + utils.roundTo(alpha, 1) + ")";
            var rgbbgstr = "rgba(" +  Math.floor(this.r / 3) +  ", " +  Math.floor(this.g / 3) +  ", " +  Math.floor(this.b / 3) +  ", 0)";

            // Draw the particle
            if (Number(this.x) !== undefined &&  Number(this.y) !== undefined) {

              if (this.x > this.minxb || this.x < this.maxxb || this.y > this.minyb || this.y < this.maxyb) {
                var p = context.createRadialGradient(this.x, this.y, 0, this.x, this.y, this.radius);
                p.addColorStop(0, rgbstr);
                p.addColorStop(1, rgbbgstr);
                context.fillStyle = p;
                context.fillRect(this.x - this.radius, this.y - this.radius, this.radius * 2, this.radius * 2);
              }

              // Update the position base on speed and direction
              this.x += this.xi / (this.slowdown * 100);
              this.y -= this.yi / (this.slowdown * 100); // canvas negative is up so flip the sign
              // Apply gravity to the speed and direction
              this.xi += this.xg;
              this.yi += this.yg;
              // Update the life based on fade
              this.life -= this.fade;
              this.radius -= (this.radius / 1) * this.fade;
              /// Kill dead or out of bound particles
              if (this.life <= 0) {
                  this.active = false;
              }

            }
          }

          // Increment the particle age
          age++;
        }
      }
    };
  };
});