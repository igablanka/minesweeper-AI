import java.util.Deque;
import java.util.Iterator;
import java.util.LinkedList;
import java.math.BigInteger;

//number of tiles
int tilesX = 10;
int tilesY = 5;

//size of each tile
int tileSize = 50;


Tile[][] tiles = new Tile[tilesX][tilesY];

//self explanatory
int numberOfBombs = 10;
boolean gameOver = false;
AI ai;
//images used
PImage flag;
PImage cursor;
PImage hiddenSprite;
PImage bombSprite;
PImage unhiddenSprite;
PFont font;

//the number of bombs left
int bombsLeft = numberOfBombs;

//frame rate
int speed = 60;

//did the ai win or lose
boolean loser = false;
boolean winner = false;

//the amount of milliseconds it took to complete the game
int timer = 0;


boolean gameOverShow = true;

void setup() {
  frameRate(300);
  //fullScreen();
  size(900, 480);  ///<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<going to need to change this to match the amount to tiles and the tile size
  cursor = loadImage("cursor.png");
  flag = loadImage("flag300000.png");
  hiddenSprite  = loadImage("hidden10000.png");
  bombSprite = loadImage("bomb0000.png");
  unhiddenSprite = loadImage("unhidden0000.png");
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      tiles[i][j] = new Tile(i*tileSize, j*tileSize);
    }
  }

  for (int i = 0; i< numberOfBombs; i++) {
    int x  = floor(random(tilesX));
    int y  = floor(random(tilesY));
    while (tiles[x][y].bomb) {//find a tile which isnt a bomb
      x  = floor(random(tilesX));
      y  = floor(random(tilesY));
    }
    tiles[x][y].bomb = true;
  }
  calculateNumbers();
  ai = new AI();
  font = loadFont("AgencyFB-Bold-15.vlw");
}


void draw() {

  if (!gameOver) {
    //background(0);
    for (int i = 0; i< tilesX; i++) {
      for (int j = 0; j< tilesY; j++) {
        if (tiles[i][j].changed) {//only show changed tiles for efficiency
          tiles[i][j].show();
          tiles[i][j].changed = false;
        }
      }
    }
    
    ai.move();

  } else {
    if (gameOverShow) {//if game over then show the bombs if you didnt win
      for (int i = 0; i< tilesX; i++) {
        for (int j = 0; j< tilesY; j++) {
          tiles[i][j].show();
        }
      }
      if (winner) {
        println("Timer", millis() - timer);//print time

        gameOverShow = false;  
      } else {
        //if we lost then show then pause for a bit then reset the game

        delay(100);
        tiles = new Tile[tilesX][tilesY];
        gameOver = false;
        loser = false;
        winner = false;
        timer = millis();

        gameOverShow = true;

        bombsLeft = numberOfBombs;
        //reset tiles
        for (int i = 0; i< tilesX; i++) {
          for (int j = 0; j< tilesY; j++) {
            tiles[i][j] = new Tile(i*tileSize, j*tileSize);
          }
        }
        
        //randomise bomb locations
        for (int i = 0; i< numberOfBombs; i++) {
          int x  = floor(random(tilesX));
          int y  = floor(random(tilesY));
          while (tiles[x][y].bomb) {//find a tile which isnt a bomb
            x  = floor(random(tilesX));
            y  = floor(random(tilesY));
          }
          tiles[x][y].bomb = true;
        }
        
        calculateNumbers();
        ai = new AI();
      }
    }
  }

}
//---------------------------------------------------------------------------------------------------------------------------------------------
void keyPressed() {
  switch(key) {
  case '+':
    speed +=10;
    frameRate(speed);
    break;
  case '-':
    speed -=10;
    frameRate(speed);
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------

void mousePressed() {
  Tile temp = getTileNear(mouseX, mouseY);
  if (mouseButton == LEFT) {

    if (!temp.hidden || temp.flagged) {
      return;
    }
    if (temp.bomb) {
      gameOver=true;
      println("DEAD");
      return;
    }
    temp.hidden = false;
    if (temp.bombsNear ==0) {
      clickedZero(floor(temp.pos.x/tileSize), floor(temp.pos.y/tileSize));
    }
  } else if (mouseButton == RIGHT) {
    if (!temp.hidden ) {
      return;
    }
    temp.flagged = !temp.flagged;
    if (temp.flagged) {
      bombsLeft --;
      if (bombsLeft ==0) {
        println("winner");
        gameOver = true;
      }
    } else {
      bombsLeft++;
    }
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------
Tile getTileNear(float x, float y) {
  float min = 10000;
  int minIndexI = 0;
  int minIndexJ = 0;

  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      if (dist(x, y, tiles[i][j].pos.x +15, tiles[i][j].pos.y+15) < min) {
        min = dist(x, y, tiles[i][j].pos.x + 15, tiles[i][j].pos.y + 15);
        minIndexI = i;
        minIndexJ = j;
      }
    }
  }

  return tiles[minIndexI][minIndexJ];
}
//---------------------------------------------------------------------------------------------------------------------------------------------
void calculateNumbers() {
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      int n = 0;


      if ( i > 0 && tiles[i-1][j].bomb) n++;
      if (i < tilesX-1 && tiles[i+1][j].bomb) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].bomb) n++;
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].bomb) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].bomb) n++;
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].bomb) n++;
      if (j < tilesY-1 && tiles[i][j+1].bomb) n++;
      if (j > 0 &&  tiles[i][j-1].bomb) n++;
      tiles[i][j].bombsNear = n;
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------
//called when an empty square is clicked then we need to click all 0s near it
void clickedZero(int i, int j) {
  tiles[i][j].hidden = false;
  tiles[i][j].changed = true;

  //cheeky recursion
  if ( i > 0 && tiles[i-1][j].hidden && tiles[i-1][j].bombsNear ==0) clickedZero(i-1, j);
  if (i < tilesX-1 &&  tiles[i+1][j].hidden && tiles[i+1][j].bombsNear ==0) clickedZero(i+1, j);
  if (j < tilesY-1 &&  tiles[i][j+1].hidden && tiles[i][j+1].bombsNear ==0) clickedZero(i, j+1);
  if (j > 0 &&  tiles[i][j-1].hidden &&  tiles[i][j-1].bombsNear ==0) clickedZero(i, j-1);


  
  //click all non 0 tiles around it
  if ( i > 0 && tiles[i-1][j].hidden && tiles[i-1][j].bombsNear != 0) {
    tiles[i-1][j].hidden = false;
    tiles[i-1][j].changed = true;
  }
  if (i < tilesX-1 &&  tiles[i+1][j].hidden && tiles[i+1][j].bombsNear != 0) {
    tiles[i+1][j].hidden = false;
    tiles[i+1][j].changed = true;
  }
  if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden  && tiles[i-1][j-1].bombsNear != 0) {
    tiles[i-1][j-1].hidden = false;
    tiles[i-1][j-1].changed = true;
  }
  if (i < tilesX-1 &&j > 0 &&   tiles[i+1][j-1].hidden  && tiles[i+1][j-1].bombsNear != 0) {
    tiles[i+1][j-1].hidden = false;
    tiles[i+1][j-1].changed = true;
  }
  if (i > 0 && j < tilesY-1 &&   tiles[i-1][j+1].hidden && tiles[i-1][j+1].bombsNear != 0 ) {
    tiles[i-1][j+1].hidden = false;
    tiles[i-1][j+1].changed = true;
  }
  if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && tiles[i+1][j+1].bombsNear != 0) {
    tiles[i+1][j+1].hidden = false;
    tiles[i+1][j+1].changed = true;
  }
  if (j < tilesY-1 &&  tiles[i][j+1].hidden && tiles[i][j+1].bombsNear != 0 ) {
    tiles[i][j+1].hidden = false;
    tiles[i][j+1].changed = true;
  }
  if (j > 0 &&  tiles[i][j-1].hidden && tiles[i][j-1].bombsNear != 0) {
    tiles[i][j-1].hidden = false;
    tiles[i][j-1].changed = true;
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------

void setTileInfo() {
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {


      //count the number of hidden tiles near current tile
      int n = 0;
      if ( i > 0 && tiles[i-1][j].hidden) n++;
      if (i < tilesX-1 && tiles[i+1][j].hidden) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden) n++;
      if (i < tilesX-1 && j > 0 &&  tiles[i+1][j-1].hidden) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden) n++;
      if (i < tilesX-1 && j < tilesY-1 &&  tiles[i+1][j+1].hidden) n++;
      if (j < tilesY-1 && tiles[i][j+1].hidden) n++;
      if (j > 0 &&  tiles[i][j-1].hidden) n++;
      tiles[i][j].hiddenNear = n;


      //count the number of flagged tiles near the current tile
      n = 0;
      if ( i > 0 && tiles[i-1][j].flagged) n++;
      if (i < tilesX-1 && tiles[i+1][j].flagged) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].flagged) n++;
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].flagged) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].flagged) n++;
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].flagged) n++;
      if (j < tilesY-1 && tiles[i][j+1].flagged) n++;
      if (j > 0 &&  tiles[i][j-1].flagged) n++;
      tiles[i][j].flaggedNear = n;


      //for each non hidden tile set all adjacent hidden tiles
      ArrayList<Tile> temp = new ArrayList<Tile>();
      if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
        temp.add(tiles[i-1][j]);
      }
      if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
        temp.add(tiles[i+1][j]);
      }
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
        temp.add(tiles[i-1][j-1]);
      }
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
        temp.add(tiles[i+1][j-1]);
      }
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) { 
        temp.add(tiles[i-1][j+1]);
      }
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
        temp.add(tiles[i+1][j+1]);
      }
      if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) { 
        temp.add(tiles[i][j+1]);
      }
      if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
        temp.add(tiles[i][j-1]);
      }

      tiles[i][j].hiddensNear= (ArrayList)temp.clone();
    }
  }

  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {

      if (tiles[i][j].bombsNear - tiles[i][j].flaggedNear == 1 && tiles[i][j].hiddenNear != 1) {
        //if there is only 1 bomb left unflagged around it then all the hidden tiles near this tile are linked, which means that only one of them can be a bomb meaning that any subset of them can be at most 1

        ArrayList<Tile> temp = new ArrayList<Tile>();
        if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
          temp.add(tiles[i-1][j]);
        }
        if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
          temp.add(tiles[i+1][j]);
        }
        if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
          temp.add(tiles[i-1][j-1]);
        }
        if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
          temp.add(tiles[i+1][j-1]);
        }
        if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) { 
          temp.add(tiles[i-1][j+1]);
        }
        if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
          temp.add(tiles[i+1][j+1]);
        }
        if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) { 
          temp.add(tiles[i][j+1]);
        }
        if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
          temp.add(tiles[i][j-1]);
        }

        //link em
        if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
          tiles[i-1][j].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j].linked = true;
        }
        if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
          tiles[i+1][j].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j].linked = true;
        }
        if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
          tiles[i-1][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j-1].linked = true;
        }
        if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
          tiles[i+1][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j-1].linked = true;
        }
        if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) { 
          tiles[i-1][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j+1].linked = true;
        }
        if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
          tiles[i+1][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j+1].linked = true;
        }
        if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) { 
          tiles[i][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i][j+1].linked = true;
        }
        if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
          tiles[i][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i][j-1].linked = true;
        }
      }
    }
  }
}
