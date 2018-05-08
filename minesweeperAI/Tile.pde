class Tile {
  boolean bomb = false;
  boolean flagged = false;
  boolean hidden =  true;
  int bombsNear = 0;
  PVector pos;
  boolean changed = true;
  int hiddenNear = 8;
  int flaggedNear = 0;
  boolean targeted = false;
  boolean looksSexy = false;
  ArrayList<Tile> linkedWith = new ArrayList<Tile>();
  ArrayList<Tile> hiddensNear;//terribly named arrayList
  boolean linked = false;
  boolean unknown = false;
  BigInteger probabilityCount = BigInteger.ZERO;

  Tile(float x, float y) {
    pos = new PVector(x, y);
  }

//---------------------------------------------------------------------------------------------------------------------------------------
//shows the tile
  void show() {
    if (loser && bomb) {//if we lost then show all bombs
      hidden = false;
    }
    if (winner && !bomb) {//if we won then show all non bombs
      hidden = false;
    }
    fill(40);
    stroke(107);
    rect(pos.x, pos.y, tileSize, tileSize);    
    
    if (!hidden) {//show number
      fill(150);
      rect(pos.x, pos.y, tileSize, tileSize);    
      if (bomb) {//show bomb
        if (loser) {
          image(bombSprite, pos.x+1, pos.y+1, tileSize, tileSize);
        }
      } else {
        image(unhiddenSprite, pos.x+1, pos.y+1, tileSize ,tileSize);
        switch(bombsNear) {//set the colour
        case 0:
          return ;
        case 1:
          fill(0, 0, 240);
          break;
        case 2:
          fill(34, 150, 34);
          break;
        case 3:
          fill(240, 0, 0);
          break;
        case 4:
          fill(0, 0, 128);
          break;
        case 5:
          fill(178, 34, 34);
          break;
        case 6:
          fill(0, 206, 209);
          break;
        case 7:
          fill(0);
          break;
        case 8:
          fill(100);
          break;
        }
        textFont(font);
        textSize(15);
        //fill(0);
        textAlign(CENTER, CENTER);
        text(bombsNear, pos.x+tileSize/2, pos.y+tileSize/2) ;
      }
    } else {
      if (flagged) {
        image(flag, pos.x+1, pos.y+1, tileSize, tileSize);
      } else {
        image(hiddenSprite, pos.x+1, pos.y+1,tileSize,tileSize);
      }
    }
  }
}