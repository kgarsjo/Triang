// Triangulation
// Author: Kevin Garsjo

// LICENSE:
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


/* ------------------------------------------------------------ //
  Class Demonstration Functions
      Setup and Draw in this sketch are implemented only to show
      features of the Triangulation class. Implement your
      own to your own thing.
// ------------------------------------------------------------ */

PVector playerAbsPos= new PVector(0,0,0);
PVector playerPos= new PVector(0,0,0);
PVector targetPos= new PVector(-100, 40, 0);
Triangulation t;

boolean debug= true;


void setup() {
  size(800, 600);
  
  playerAbsPos.x= width / 2;
  playerAbsPos.y= height / 2;
  
  t= new Triangulation(playerAbsPos, targetPos);
  t.setHudScale(1);
}

void draw() {
  clear();
  background(255,255,255);
  
  drawPlayer(playerAbsPos);
  drawPlayer(targetPos);
  t.update();
  targetPos.y += 1;
  targetPos.x += 1;
  
  if (debug) {
   textSize(16);
   fill(0,0,0);
   text("Target: (" + targetPos.x + ", " + targetPos.y + ")", 20, 20);
  }
}

void drawPlayer(PVector absPos) {
    float playerSize= 15.0;
    color playerColor= color(200, 0, 0);
    color playerBorder= color(0, 0, 0);
    
    stroke(playerBorder);
    fill(playerColor);
    ellipse(absPos.x, absPos.y, playerSize, playerSize);
}


/* ------------------------------------------------------------ //
  Triangulation Class:
      Provides a HUD-like GUI tracking class that uses
      vector manipulations to target a set objective.
// ------------------------------------------------------------ */
class Triangulation {
   PVector source;
   PVector dest;
   
   float hudScale= 1.0;
   float hudBezel= 5.0;
   
   color hudStroke= color(0,0,0);
   color hudFillBright= color(0, 255, 0);
   color hudFillDark= color(0, 128, 0);
   
   boolean shrinkHud= false;
   float shrinkBezel= 400;
   float minScale= 0.25;
   float maxDist= 1000;
   
   Triangulation(PVector source, PVector dest) {
     this.source= source;
     this.dest= dest;
   }
   
   void setDestination(PVector dest) {
     this.dest= dest; 
   }
   
   void setHudBezel(float bezel) {
     hudBezel= bezel;
   }
   
   void setHudFillBright(color c) {
     hudFillBright= c;
   }
   
   void setHudFillDark(color c) {
     hudFillDark= c;
   }
   
   void setHudScale(float scale) {
     hudScale= scale;
   }
   
   void setHudStroke(color c) {
     hudStroke= c;
   }
   
   void setShrinkingHud(boolean flag) {
     shrinkHud= flag;
   }
   
   void update() {
     // Fetch distance vec between two points
     PVector vdist= PVector.sub(dest, source); 
     
     // If target is offscreen, scale distance vec 
     // and reconstruct appropriate dest vector
     float scale= 1;
     float scaleX= abs( (width / 2.0 - hudBezel) / vdist.x );
     float scaleY= abs( (height / 2.0 - hudBezel) / vdist.y );
     scale= min(scaleX, scaleY);
     if (scale > 1) { scale = 1; }
     
     PVector s_vdist= PVector.mult(vdist, scale);
     PVector s_vdest= PVector.add(s_vdist, source);
     drawTriangle(s_vdest, s_vdist.heading(), s_vdist.mag());
     
     if (debug) {
       textSize(16);
       fill(0,0,0);
       text("Hudpos: (" + s_vdest.x + ", " + s_vdest.y + ")", 20, 35);
       text("Hudangle: " + degrees(s_vdist.heading()), 20, 50);
     }
   }
   
   private void drawTriangle(PVector pos_startPoint, float angle, float dist) {
     // Assume start point is the origin, with points p1, p2 aligned
     // to make the triangle point right (0-degrees). Then, rotate p1,
     // p2 by the angle and add the start-point vector to make the
     // triangle's position absolute.
     
     PVector p1= new PVector(-8.0, 10.0, 0.0);
     PVector p2= new PVector(-8.0, -10.0, 0.0);
     
     p1.mult(hudScale);
     p2.mult(hudScale);
     
     if (shrinkHud) {
       float mod= (minScale + 1) / (maxDist - shrinkBezel);
       float scale= (1.0 - (dist - shrinkBezel) * mod);
       scale= max(scale, minScale);
       
       p1.mult(scale);
       p2.mult(scale);
     }
     
     p1.rotate(angle);
     p2.rotate(angle);
     
     p1.add(pos_startPoint);
     p2.add(pos_startPoint);
     
     color hudColor= color(0, 200, 0);
     color hudBorder= color(0,0,0);
     
     stroke(hudBorder);
     fill(hudColor);
     triangle(pos_startPoint.x, pos_startPoint.y, p1.x, p1.y, p2.x, p2.y);
   }
}
