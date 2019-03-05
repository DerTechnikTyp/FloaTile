boolean recording = false;

int tileCountX = 40;
int tileCountY = 60;
float tileHeight = 0.1;
float tileWidth = 5;
float tileSpacing = 7.5;
int totalTileCount = tileCountX * tileCountY;

float maxHeight = 150;
float currentHeight = 0;
float newHeight = 0;
final float closeEnoughThreshhold = 0.05;

final float minimumDropChance = 0.02;
final float risingSpeed = 0.3;
final float droppingSpeedFactor = 0.06;

final color richtigesGrau = color(22, 22, 24);
final color tileWhite = color(200, 200, 200);
final color tileReddish = color(240, 200, 200);

Tile[] tiles;

float leftMostPosition;
float centerPosition;
float backPosition;

class Tile {
  float currentHeight;
  boolean falling;

  Tile() {
    currentHeight = 0;
    falling = false;
  }
}

void setup() {
  frameRate(165);
  size(1056, 594, P3D); // 16:9 - we W I D E S C R E E N boys
  smooth(10);
  background(richtigesGrau);

  setupVariables();

  normalStroke();
}

void setupVariables() {
  tiles = new Tile[totalTileCount];

  leftMostPosition = (width - (tileCountX * tileSpacing)) / 2;
  centerPosition = height / 4;
  backPosition = -(height / tileSpacing);

  setZero();
}

void setZero() {
  for (int i = 0; i < totalTileCount; i++) {
    tiles[i] = new Tile();
  }
}

void normalStroke() {
  stroke(0);
  fill(tileWhite);
}

void fallingStroke() {
  stroke(0);
  fill(tileReddish);
}

void draw() {
  background(richtigesGrau);
  // initial translate
  translate(leftMostPosition, centerPosition, backPosition);
  rotateX(-PI/10);

  drawTiles();
  
  if (recording) {
    saveFrame("frames\\f####.tif");
  }
  
  makeProgress();
}

void drawTiles() {
  pushMatrix();

  int positionX = 0;
  int positionY = 0;
  for (int i = 0; i < totalTileCount; i++) {
    positionX = i % tileCountX;
    positionY = i / tileCountX;

    drawTile(tiles[i], positionX, positionY);
  }
  popMatrix();
}

void drawTile(Tile tile, int posX, int posY) {
  pushMatrix();
  //if (tile.falling) {
  //  fallingStroke();
  //} else {
  //  normalStroke();
  //}
  translate(posX * tileSpacing, -tile.currentHeight, posY * tileSpacing);
  box(tileWidth, tileHeight, tileWidth);
  popMatrix();
}

void makeProgress() {
  for (int i = 0; i < totalTileCount; i++) {
    if (tiles[i].falling) {
      if (isCloseToGround(tiles[i].currentHeight)) {
        //tiles[i].falling = false;
        tiles[i].currentHeight = newHeight;
      } else {
        tiles[i].currentHeight -= getFallingDistance(tiles[i].currentHeight);
      }
    } else {
      tiles[i].currentHeight = currentHeight;
      if (randomFallingChance()) {
        tiles[i].falling = true;
      }
    }
  }

  currentHeight = (currentHeight + risingSpeed);
  if (currentHeight > maxHeight) {
    if (recording) {
      exit();
    }
    currentHeight %= maxHeight;
    setZero();
  }
  newHeight = currentHeight - maxHeight;
  //println(currentHeight + " / " + newHeight);
}

float getFallingDistance(float current) {
  float distanceCeiling = abs(currentHeight - current);
  float distanceGround = abs(newHeight - current);
  float inbetween = min(distanceCeiling, distanceGround);
  float withSpeedApplied = inbetween * droppingSpeedFactor;
  return min(distanceCeiling, min(distanceGround, withSpeedApplied)); // floor or ceiling cap
}

boolean isCloseToGround(float current) {
  boolean closeToGround = abs(newHeight - current) < closeEnoughThreshhold;
  boolean belowGround = current < newHeight;
  return closeToGround || belowGround;
}

boolean randomFallingChance() {
  // actually quite nice
  float randomValue = random(currentHeight, maxHeight);
  return randomValue / maxHeight > 1 - minimumDropChance;
  // kinda early
  //return random(0, maxHeight) < currentHeight - minimumDropChance;
}
