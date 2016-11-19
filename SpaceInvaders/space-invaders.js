var SI = (function() {

  function Ship(ctx, pos) {
    var self = this;

    self.x = pos.x;
    self.y = pos.y;
    self.gunPoint = { x: self.x + Ship.GUNPOINT_OFFSET, y: self.y };
    self.firedBullets = [];

    self.fire = function() {
      var bullet = new Bullet(ctx, self.gunPoint, "ship");

      if (self.firedBullets.length < 7) {
        self.firedBullets.push(bullet);
      }
    };

    self.draw = function() {
      self.drawBackground();
      self.drawShip();
      self.drawGun();
    };

    self.drawShip = function() {
      ctx.beginPath();
      ctx.fillStyle = "#800080";

      ctx.rect(self.x, self.y, Ship.WIDTH, Ship.HEIGHT);
      ctx.fill();
    };

    self.drawGun = function() {
      ctx.beginPath();
      ctx.fillStyle = "#e6c200";

      ctx.rect(self.gunPoint.x-4, self.gunPoint.y-5, 10, 5);
      ctx.fill();
    };

    self.drawBackground = function() {
      ctx.beginPath();
      ctx.fillStyle = "#c0ed9e";

      ctx.rect(0, Game.DIM.height-30, Game.DIM.width, 30);
      ctx.fill();
    };

    self.update = function(val) {
      if (!self.blocked(val)){
        self.x += val;
        self.gunPoint.x += val;
      }
    };

    self.blocked = function(val) {
      var temp = self.x + val;

      if (((temp + 40) >= Game.DIM.width) || (temp <= 0)) {
        return true;
      }

      return false;
    };

    self.keyBindings = function() {
      key("left", function() {
        self.update(-30);
      });

      key("right", function() {
        self.update(30);
      });

      key("space", function() {
        self.fire();
      });
    };
  }

  Ship.WIDTH = 40;
  Ship.HEIGHT = 20;
  Ship.GUNPOINT_OFFSET = 20;


  function Bullet(ctx, pos, vehicle) {
    var self = this;

    self.x = pos.x;
    self.y = pos.y;

    self.speed = 2;
    self.vehicles = {
      "ship": -4,
      "alien": 2
    };
    self.velocity = self.vehicles[vehicle];

    self.draw = function() {
      ctx.beginPath();
      ctx.fillStyle = "#ff0000";

      ctx.rect(self.x, self.y, 5, 10);
      ctx.fill();
    };

    self.update = function() {
      self.y += (self.velocity * self.speed);
    };
  }

  function Alien(ctx, pos) {
    var self = this;

    self.x = pos.x;
    self.y = pos.y;
    self.speed = 1;
    self.firedBullets = [];

    self.draw = function() {
      ctx.beginPath();
      ctx.fillStyle = "#e6c200";
      ctx.stroke

      ctx.rect(self.x, self.y, Ship.WIDTH, Ship.HEIGHT);
      ctx.fill();
    };

    self.update = function(direction) {
      self.x += direction * self.speed;
    };

    self.isHit = function(bullets) {
      for (var i = 0; i < bullets.length; i++) {
        if (bullets[i].y <= (self.y + Ship.HEIGHT)
            && (bullets[i])
            && (bullets[i].x ) >= self.x
            && bullets[i].x <= (self.x + Ship.WIDTH)) {
          return true;
        }

        return false;
      };
    };

    self.fire = function() {

    };

  }

  Alien.buildAlienRow = function(ctx, firstPos) {
    var alienRow = [];

    var firstPosx = firstPos.x;
    var firstPosy = firstPos.y;

    for(var i = 1; i<=10; i++) {
      var pos = {
        x: (firstPosx * i),
        y: (firstPosy)
      }

      var a = new Alien(ctx, pos);
      alienRow.push(a);
    }

    return alienRow;
  };

  Alien.wallHit = function(aliens) {
    var firstAlien = aliens[0];
    var lastAlien = aliens[aliens.length - 1];


    if (lastAlien != null && (lastAlien.x + Ship.WIDTH) >= Game.DIM.width) {
      return true;
    } else if (firstAlien != null && firstAlien.x <= 0) {
      return true;
    }

    return false;
  };

  function Game(ctx) {
    var self = this;

    self.ship = new Ship(ctx, Ship.STARTING_POS);
    self.shipBullets = self.ship.firedBullets;
    self.aliens = Alien.buildAlienRow(ctx, { x:80, y:40 });
    self.alienDirection = 2;

    self.start = function() {
      self.ship.keyBindings();
      setInterval(self.gameLoop, 1000/24)
    };

    self.gameLoop = function() {
      ctx.clearRect(0, 0, 900, 600);
      self.update();
      self.draw();
    };

    self.draw = function() {
      self.ship.draw();

      for (var i = 0; i < self.aliens.length; i++) {
        var a = self.aliens[i];
        a.draw();
      }

      for (var i = 0; i < self.shipBullets.length; i++) {
        var b = self.shipBullets[i];
        b.draw();
      }
    };

    self.update = function() {
      for (var i = 0; i < self.shipBullets.length; i++) {
        var b = self.shipBullets[i];
        b.update();

        if (b.y < 0) {
          self.shipBullets.splice(i, 1);
        }
      }

      if (Alien.wallHit(self.aliens)) {
        self.alienDirection *= -1

        for (var i = 0; i<self.aliens.length; i++){
          var a = self.aliens[i];
          a.y += 20;
        }
      }

      for (var i = 0; i < self.aliens.length; i++) {
        var a = self.aliens[i];
        a.update(self.alienDirection);
        if (a.isHit(self.shipBullets)) {
          self.aliens.splice(i, 1);
        }
      }
    };

    // self.alienHit = function() {
    //   for (var i = 0; i < self.aliens.length; i++) {
    //     for (var j = 0; j < self.shipBullets.lenght; j++) {
    //       if (self.aliens[i].isHit(self.shipBullets[j])) {
    //         console.log("hit");
    //         self.aliens.splice(i, 1);
    //         self.shipBullets.splice(j, 1);
    //       }
    //     }
    //   }
    // };

  }

  Game.DIM = { width: 900, height: 600 }
  Ship.STARTING_POS = { x: (Game.DIM.width/2 - 20), y: Game.DIM.height -50 }

  // Game class
  // moves aliens from left to right
  // Moves aliens closer once they get to some area of screen
  // random alien randomly shoots
  // array of fired bullets
  // array of aliens
  // game#draw
  // game#update

  return {
    Ship: Ship,
    Bullet: Bullet,
    Alien: Alien,
    Game: Game
  }

})();


(function() {
  var canvas = $("canvas")[0];
  canvas.width = 900;
  canvas.height = 600;

  var ctx = canvas.getContext("2d");
  // var shipStartPos = { x: (DIM.width/2 - 20), y: DIM.height -50 }
  var game = new SI.Game(ctx)
  game.start();

  // var ship = new SI.Ship(ctx, shipStartPos, DIM);
  // ship.keyBindings();
  // ship.draw();

  // setInterval(ship.draw, 1000/24);
})();
