var AG = (function() {
  function Asteroid(pos, ctx, fill) {
    var self = this;

    self.x = pos['x'];
    self.y = pos['y'];
    self.rad = 20;
    self.fill = fill;

    self.vel = function() {
      var randX = Math.random() * 10 + -5;
      var randY = Math.random() * 10 + -5;

      return {x: randX, y:randY}
    }();

    self.draw = function() {
      ctx.fillStyle = self.fill;

      ctx.beginPath();
      ctx.arc(self.x, self.y, self.rad, 0, 2 * Math.PI, true)
      ctx.fill();
    };

    self.update = function(maxX, maxY) {
      self.offScreenX(maxX);
      self.offScreenY(maxY);

      self.x += self.vel['x'];
      self.y += self.vel['y'];
    };

    self.offScreenX = function(maxX) {
      if (self.x > maxX){
        self.x = 0;
      } else if (self.x < 0){
        self.x = maxX;
      }
    };

    self.offScreenY = function(maxY) {
      if (self.y > maxY){
        self.y = 0;
      } else if (self.y < 0){
        self.y = maxY;
      }
    };
  }

  // Asteroid Class Methods

  Asteroid.randomAsteroid = function(maxX, maxY, ctx) {
    var randX = Math.floor(Math.random() * maxX);
    var randY = Math.floor(Math.random() * maxY);
    var pos = {x: randX, y: randY};

    return new Asteroid(pos, ctx, "#000");
  }

  function Ship(pos, ctx) {
    var self = this;

    self.x = pos['x'];
    self.y = pos['y'];
    self.vel = {x: 0, y: 0};
    self.directions = {
      up: [0, -1],
      down: [0, 1],
      left: [-1, 0],
      right: [1, 0]
    };
    self.firedBullets = [];

    self.draw = function() {
      ctx.fillStyle = "#FF0000";

      // Create ship
      ctx.beginPath();
      ctx.moveTo(self.x, self.y);
      ctx.lineTo(self.x+12, self.y+30);
      ctx.lineTo(self.x-12, self.y+30);
      ctx.lineTo(self.x, self.y);
      ctx.fill();

      // Create forcefield
      ctx.beginPath();
      ctx.arc(self.x, self.y+17, 20, 0, 2 * Math.PI, true)
      ctx.strokeStyle = '#5ac3b6'
      ctx.stroke();
    };

    self.isHit = function(asteroids) {
      for(var i = 0; i < asteroids.length; i++){
        var astr = asteroids[i];
        var astrX = astr.x;
        var astrY = astr.y;

        var deltX = Math.pow(astrX - self.x, 2);

        // Center of forcefield circle is at (self.x, self.y+17)
        var deltY = Math.pow(astrY - (self.y + 17), 2);

        d = Math.sqrt(deltX + deltY);
        if (d < (astr.rad + 20)) {
          return true;
        }
      }
    };

    self.update = function(maxX, maxY) {
      self.offScreenX(maxX);
      self.offScreenY(maxY);

      self.x += self.vel['x'];
      self.y += self.vel['y'];
    };

    self.power = function(dir) {
      self.vel['x'] += dir[0];
      self.vel['y'] += dir[1];
    };

    self.fireBullet = function(pos, dir, ctx){
      var bullet = new Bullet(pos, dir, ctx);
      console.log(bullet);
      self.firedBullets.push(bullet);
      console.log(self.firedBullets);
    }

    self.keyBindings = function() {
      key('up', function() {
        self.power(self.directions['up']);
      });
      key('down', function() {
        self.power(self.directions['down']);
      });
      key('left', function() {
        self.power(self.directions['left']);
      });
      key('right', function() {
        self.power(self.directions['right']);
      });
      key('space', function(){
        self.fireBullet({x: self.x, y: self.y}, self.directions['up'], ctx);
      });
    };

    self.offScreenX = function(maxX) {
      if (self.x > maxX){
        self.x = 0;
      } else if (self.x < 0){
        self.x = maxX;
      }
    };

    self.offScreenY = function(maxY) {
      if (self.y > maxY){
        self.y = 0;
      } else if (self.y < 0){
        self.y = maxY;
      }
    };
  }

  function Bullet(shipPos, dir, ctx) {
    self.dir = dir;               //Always shooting up for now
    self.x = shipPos['x'];
    self.y = shipPos['y'];
    self.vel = {x: 0, y:-7};

    self.draw = function(){
      ctx.fillStyle = '#CCC';

      ctx.beginPath();
      ctx.arc(self.x, self.y, 3, 0, 2 * Math.PI, true)
      ctx.fill();
    };

    self.update = function(){
      // Here we would multiply by dir if we had one

      self.x += self.vel['x'];
      self.y += self.vel['y'];
    };
  }

  function Game(ctx, canvasWidth, canvasHeight){
    var self = this;

    self.asteroids = [];
    self.maxX = canvasWidth;
    self.maxY = canvasHeight;
    self.ship = new Ship(
      {x: (self.maxX / 2), y: (self.maxY / 2)},
      ctx,
      self.asteroids);

    self.start = function() {
      self.getAsteroids();
      self.ship.keyBindings();
      self.gameInt = setInterval(self.step, 1000/24);
    };

    self.step = function() {
      self.update();
      self.draw();

      if (self.ship.isHit(self.asteroids)) {
        alert("YOU GOT HIT!");
        clearInterval(self.gameInt);
      }
    }

    self.draw = function(){
      ctx.clearRect(0, 0, 900, 600);
      self.ship.draw();

      for (var i=0; i<self.asteroids.length; i++) {
        var a = self.asteroids[i];
        a.draw();
      }

      for (var j=0; j<self.ship.firedBullets.length; j++) {
        var b = self.ship.firedBullets[j];
        b.draw();
      }
    };

    self.update = function() {
      for (var i=0; i<self.asteroids.length; i++) {
        var a = self.asteroids[i];
        a.update(self.maxX, self.maxY);
      }

      self.ship.update(self.maxX, self.maxY);

      for (var j=0; j<self.ship.firedBullets.length; j++) {
        var b = self.ship.firedBullets[j];
        console.log(self, b);
        b.update();
      }
    }

    self.getAsteroids = function() {
      for (var i=0; i<10; i++) {
        var a = Asteroid.randomAsteroid(self.maxX, self.maxY, ctx)
        self.asteroids.push(a);
      }
    };
  }

  return {
    Asteroid: Asteroid,
    Game: Game,
    Ship: Ship
  }
})();


(function() {
  var canvas = $("canvas")[0]
  canvas.width = 900;
  canvas.height = 600;
  var ctx = canvas.getContext("2d");

  var g = new AG.Game(ctx, 900, 600);
  g.start();
})();
