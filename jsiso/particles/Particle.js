﻿/*  
Copyright (c) 2014 Iain Hamilton

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
*/

define([
  'jsiso/utils'
],

function(utils) {

  var age = 0;

  this.active = true; // draw or not

  this.drawdelay = -1; // how old before the particle can start drawing

  this.life = 1.0;    // particle lifespan

  this.fade = 0.01;   // fade speed

  this.r = 255;       // red intensity

  this.g = 0;         // green intensity

  this.b = 0;         // blue intensity

  this.x = 0.0;       // x position

  this.y = 0.0;       // y position

  this.xi = 0.1;      // x axis speed

  this.yi = 0.0;      // y axis speed

  this.xg = 0.0;      // x gravity strength

  this.yg = 0.0;      // y gravity strength

  this.radius = 5.0;  // particle radius

  this.slowdown = 2.0; // particle speed slowdown

  this.minxb = -1;     // min x axis boundry

  this.maxxb = 999999; // max x axis boundry

  this.minyb = -1;     // min y axis boundry

  this.maxyb = 999999; // max y axis boundry


  return function() {

    return {

      Draw: function(context) {

        if (this.active) {

          if (this.drawdelay == -1 || age > this.drawdelay) {

            // Determine alpha based on life

            var alpha = this.life > 1.0 ? 1 : this.life < 0.0 ? 0 : this.life;

            var rgbstr = "rgba(" + this.r + ", " + this.g + ", " + this.b + ", " + utils.roundTo(alpha, 1) + ")";

            var rgbbgstr = "rgba(" +  Math.floor(this.r / 3) +  ", " +  Math.floor(this.g / 3) +  ", " +  Math.floor(this.b / 3) +  ", 0)";

            // Draw the particle

            if (Number(this.x) &&  Number(this.y)) {
              context.save();
              var p = context.createRadialGradient(this.x, this.y, 0, this.x, this.y, this.radius);

              p.addColorStop(0, rgbstr);

              p.addColorStop(1, rgbbgstr);

              context.fillStyle = p;

              context.fillRect(this.x - this.radius, this.y - this.radius, this.radius * 2, this.radius * 2);

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

              if (this.life <= 0 || this.x < this.minxb || this.x > this.maxxb || this.y < this.minyb || this.y > this.maxyb) {

                  this.active = false;

              }
              context.restore();
            }
          }

          // Increment the particle age
          age++;
        }
      }
    };
  };
});