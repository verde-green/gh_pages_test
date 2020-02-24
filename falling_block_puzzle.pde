/* @pjs preload="https://github.com/verde-green/falling_block_puzzle/data/ARBONNIE-48.vlw"; */ 

final int TITLE = 0;                        // game mode
final int GAME = 1;
final int END = 2;

final int NSCORE = 6;

final int FWIDTH = 12;                      // width of field 
final int FHEIGHT = 22;                     // height of field
final int MWIDTH = 17;                      // one block's width
final int BSIZE = 5;                        // size of block array
final int NWIDTH = 70;                      // frame of next box
final int NHEIGHT = 150;
final int HHEIGHT = 40;                     // frame of hold box

final int CX = 2;                           // center of block array
final int CY = 2;
final int FCX = 4;

int state = 0;
int margin;

int field[][] = new int[FWIDTH][FHEIGHT];
int block[][] = new int[BSIZE][BSIZE];
int nblock[][][] = new int[3][BSIZE][BSIZE];     // next mino
int hblock[][] = new int[BSIZE][BSIZE];          // held mino
int sblock[][] = new int[BSIZE][BSIZE];          // mino's shadow
int score[] = new int[NSCORE];

int bnum;
int hold_lock = 0;                          // check you can hold
int spin_check = 0;                         // check mino spined
int through = 0;                            // check game mode

int x = 6, y = 2;                           // block's coordinate

int time_count = 0, line = 0, now_score = 0;

String[] string = {
  "HOLD", "NEXT", "LINE", "SCORE", "PENETRATIVE", "MODE"
};

PrintWriter output;
BufferedReader reader;
String rline = null;

void setup() {
  size(400, 375);
  smooth();
  
  PFont font = loadFont("ARBONNIE-48.vlw");
  textFont(font, 24);

  reader = createReader("scores.txt");
  
  try {
    rline = reader.readLine();
  }
  catch(Exception e) {
    rline = null;
  }

  if (rline == null) {        // make a text file
    output = createWriter("scores.txt");
    output.print("0 0 0 0 0 0");
    output.flush();
    output.close();
  }

  String list[] = loadStrings("scores.txt");   // load a text file
  score = int(split(list[0], " "));

  initialize();
}

void draw() {
  switch(state) {
  case TITLE:
    title();
    break;

  case GAME:
    background(170);
    stroke(1);
    drawFrame();                 // draw the frame

    drawMino(block, x, y);          // draw a mino 
    drawMino(hblock, 0, 0);
    drawnMino(nblock);
    drawsMino(block, x);

    if (frameCount % 60 == 0) {       // drop a mino
      if (collision(block, x, y+1))
        y++;
    }

    if (!collision(block, x, y+1)) { 
      if (spin_check == 1) {
        time_count -= 6;
        spin_check = 0;
      }

      if (time_count > 30) {
        setField(field, block, x, y);         // set the block's data to field
        dataClear(block);

        x=6;                                  // initialize block's coordinate
        y=1;

        setnMino();                           // set a next mino's information

        if (hold_lock == 1) hold_lock = 0;

        time_count = 0;
      }
      time_count++;
    }

    deleteLine();
    drawMino(field, 2, 2);

    for (int i = 0; i<FWIDTH - 1; i++)
      if (field[i][0] > 0) {
        state = END;
        time_count = 0;
      }
    break;

  case END:
    if (time_count == 0) {
      score[5] = now_score;
      scoreSort();
      time_count = 1;
    }

    output = createWriter("scores.txt");
    for (int i = 0; i < NSCORE; i++) {
      output.print(score[i]+" ");
    }
    output.flush();
    output.close();

    ending();
    break;
  }
}

/*--------------------------------------------------------------------------------*/
// game mode

int plaid[][] = new int[16][15];      
int flash = 0, f = 5;
void title() {   
  int pwidth = 0, pheight = 0;

  background(170);
  noStroke();

  if (frameCount % 60 == 0) {        // pattern of background
    pwidth = int(random(8));
    pheight = int(random(15));

    if (pheight % 2 != 0)
      plaid[pwidth*2][pheight] = 1;
    else plaid[pwidth*2+1][pheight] = 1;
  }

  fill(255, 100);
  for (int i = 0; i < plaid.length; i++) {
    for (int j = 0; j < plaid[i].length; j++) {
      if (plaid[i][j] > 0)
        rect(i * 25, j * 25, 25, 25);
    }
  }

  fill(255);
  textAlign(CENTER);
  textSize(56);
  text("falling block puzzle", width / 2, height / 2);
  textSize(24);

  fill(255, flash);
  text("press the  \" space \"  key and start game", width / 2, height / 2 + 30);

  flash += f;
  if (flash >= 255) f *= -1;
  else if (flash <= 0) f *= -1;

  initialize();

  if (keyPressed && key == ' ') state = GAME;
}

int state_ranking = 0, sflash = 255, sf = 5;
void ending() {
  noStroke();
  fill(30, 5);
  rect(0, 0, width, height);

  switch (state_ranking) {
  case 0:
    fill(252, 100, 50);
    textAlign(CENTER);
    textSize(48);
    text("GAME OVER", width / 2, height / 2);
    break;

  case 1:
    fill(255);
    textAlign(CENTER);
    textSize(48);
    text("ranking", width / 2, height / 2 - 60);

    int new1 = -1;
    for (int i = 0; i < NSCORE - 1; i++) {
      if (score[i] == now_score) {
        if (new1 == -1)
          new1 = i;

        fill(#D8F565, sflash);
        textSize(24);
        text("new score !!", 60, height / 2 + (new1 - 1) * 20);

        sflash -= sf;
        if (sflash >= 255) sf *= -1;
        if (sflash <= 0) sf *= -1;
      }
    }

    fill(255);
    textSize(40);
    text("1st ", width / 2 - 70, height / 2 - 20);

    textSize(24);
    text("2nd ", width / 2 - 70, height / 2);
    text("3rd ", width / 2 - 70, height / 2 + 20);
    text("4th ", width / 2 - 70, height / 2 + 40);
    text("5th ", width / 2 - 70, height / 2 + 60);

    for (int i = 0; i < NSCORE - 1; i++) {
      if (i == 0) textSize(40);
      else textSize(24);
      textAlign(LEFT);
      text(score[i], width / 2 - 40, height / 2 + (i - 1) * 20);
    }

    textAlign(CENTER);
    fill(255, flash);
    text("press the  \" space \"  key and go back title", width / 2, height - 70);

    flash += f;
    if (flash >= 255) f *= -1;
    else if (flash <= 0) f *= -1;

    break;

  case 2:
    state = TITLE;
    state_ranking = 0;
    now_score = 0;
    dataClear(plaid);
    break;
  }

  if (keyPressed && key == ' ') {
    state_ranking++;
    key = 0;
  }
}

void initialize() {
  dataClear(field);      
  dataClear(block);

  for (int i = 0; i < 3; i++)
    dataClear(nblock[i]);

  dataClear(hblock);

  margin = (width - FWIDTH * MWIDTH) / 2;  

  nextMino();

  for (int i=0; i<3; i++)
    setnMino();

  setMino(sblock, block[2][2]);

  now_score = 0;
  line = 0;
}

void scoreSort() {        // selection sort
  for (int j = 0; j < score.length; j++) {
    int maxIndex = j;
    int maxValue = score[j];

    for (int i = j + 1; i < score.length; i++) {
      if (maxValue < score[i]) {
        maxIndex = i;
        maxValue = score[i];
      }
    }

    int tmp = score[j];
    score[j] = score[maxIndex];
    score[maxIndex] = tmp;
  }
}

void dataClear(int[][] data) {        
  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      data[i][j] = 0;
    }
  }
}

/*-------------------------------------------------------------------------------*/
// game relations

void drawFrame() {  
  int m = (width + margin + MWIDTH * FWIDTH - NWIDTH) / 2;   // margin of NEXT rect

  for (int i = 0; i < field.length; i++) {
    for (int j = 0; j < field[i].length; j++) {
      if (i < 3 || i > 8) {
        field[i][0] = -1;
      }

      if (i == 0 || i == FWIDTH - 1) {
        field[i][j] = -1;
      }

      if (j == FHEIGHT - 1) {
        field[i][j] = -1;
      }

      if (field[i][j] == -1) {
        fill(255);
        rect(margin + MWIDTH * i, MWIDTH * j, MWIDTH, MWIDTH);
      }
    }
  }
  textAlign(LEFT);
  text(string[0], (margin - NWIDTH) / 2 + (NWIDTH - textWidth(string[0])) / 2, 23);
  rect((margin - NWIDTH) / 2, 30, NWIDTH, HHEIGHT);

  text(string[1], m + (NWIDTH - textWidth(string[1])) / 2, 23);
  rect(m, 30, NWIDTH, NHEIGHT);

  text(string[2], (margin - NWIDTH) / 2 + (NWIDTH - textWidth(string[2])) / 2, 280);
  text(string[3], (margin - NWIDTH) / 2 + (NWIDTH - textWidth(string[3])) / 2, 330);

  if (through == 1) {                // penetrative mode
    fill(252, 100, 50);
    text(string[4], m, 220);
    text(string[5], m+13, 240);
  }

  fill(255);
  textAlign(RIGHT);
  text(line, (margin - NWIDTH) / 2 + NWIDTH, 304);
  text(now_score, (margin - NWIDTH) / 2 + NWIDTH, 354);
}

void nextMino() {
  dataClear(nblock[2]);
  bnum = int(random(1, 8));
  setMino(nblock[2], bnum);
}

void setnMino() {
  setMino(block, nblock[0][2][2]);

  for (int i = 0; i < 2; i++) {
    dataClear(nblock[i]);
    setMino(nblock[i], nblock[i+1][2][2]);
  }

  nextMino();
}

void setMino(int[][] block, int bnum) {
  switch(bnum) {
  case 1:                // i_type
    for (int i = -1; i < 3; i++) {
      block[CX+i][CY] = 1;
    }
    break;

  case 2:                // o_type
    for (int i = 0; i < 2; i++) {
      block[CX+i][CY] = 2;
      block[CX+i][CY+1] = 2;
    }
    break;

  case 3:                // s_type
    for (int i = 0; i < 2; i++) {
      block[CX+i][CY-1] = 3;
      block[CX-i][CY] = 3;
    }
    break;

  case 4:                // z_type
    for (int i = 0; i < 2; i++) {
      block[CX-i][CY-1] = 4;
      block[CX+i][CY] = 4;
    }
    break;

  case 5:                // j_type
    for (int i = -1; i < 2; i++) {
      block[CX-1][CY-1] = 5;
      block[CX+i][CY] = 5;
    }
    break;

  case 6:                // l_type
    for (int i = -1; i < 2; i++) {
      block[CX+1][CY-1] = 6;
      block[CX+i][CY] = 6;
    }
    break;

  case 7:                // t_type
    for (int i = -1; i < 2; i++) {
      block[CX][CY-1] = 7;
      block[CX+i][CY] = 7;
    }
    break;
  }
}

void drawMino(int[][] data, int x, int y) {
  int m = (margin - NWIDTH) / 2;
  int mx = m + (NWIDTH - (MWIDTH - 3) * 4) / 2;
  int mx_2 = m + (NWIDTH - (MWIDTH - 3) * 2) / 2;
  int mx_3 = m + (NWIDTH - (MWIDTH - 3) * 3) / 2;
  int my = 30 + (HHEIGHT - (MWIDTH - 3)) / 2;
  int my_2 = 30 + (HHEIGHT - (MWIDTH - 3) * 2) / 2;

  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      if (data[i][j] > 0) {
        switch(data[i][j]) {
        case 1:
          fill(#87CEFA);
          break;

        case 2:
          fill(#FFFF00);
          break;

        case 3:
          fill(#ADFF2F);
          break;

        case 4:
          fill(#FF0000);
          break;

        case 5:
          fill(#0000FF);
          break;

        case 6:
          fill(#FFA500);
          break;

        case 7:
          fill(#BA55D3);
          break;
        }
        if (x == 0 && y == 0) {
          if (data[i][j] == 1) {
            rect(mx + (MWIDTH - 3)* (i - 1), my + (MWIDTH - 3) * (j - 2), MWIDTH - 3, MWIDTH - 3);
          } else if (data[i][j] == 2) {
            rect(mx_2 + (MWIDTH - 3)* (i - 2), my_2 + (MWIDTH - 3) * (j - 2), MWIDTH - 3, MWIDTH - 3);
          } else {
            rect(mx_3 + (MWIDTH - 3)* (i - 1), my_2 + (MWIDTH - 3) * (j - 1), MWIDTH - 3, MWIDTH - 3);
          }
        } else
          rect(margin + MWIDTH * (i + x - 2), MWIDTH * (j + y - 2), MWIDTH, MWIDTH);
      }
    }
  }
}

void drawnMino(int[][][] data) {      // draw a next mino
  int mino_place = 0;

  int m = (width + margin + MWIDTH * FWIDTH - NWIDTH) / 2; // margin of NEXT rect
  int mx = m + (NWIDTH - (MWIDTH - 3) * 4) / 2;
  int mx_2 = m + (NWIDTH - (MWIDTH - 3) * 2) / 2;
  int mx_3 = m + (NWIDTH - (MWIDTH - 3) * 3) / 2;
  int my = 30 + ((NHEIGHT / 3)  - (MWIDTH - 3)) / 2;
  int my_2 = 30 + ((NHEIGHT / 3)  - (MWIDTH - 3) * 2) / 2;

  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      for (int k = 0; k < data[i][j].length; k++) {
        if (data[i][j][k] > 0) {
          switch(data[i][j][k]) {
          case 1:
            fill(#87CEFA);
            break;

          case 2:
            fill(#FFFF00);
            break;

          case 3:
            fill(#ADFF2F);
            break;

          case 4:
            fill(#FF0000);
            break;

          case 5:
            fill(#0000FF);
            break;

          case 6:
            fill(#FFA500);
            break;

          case 7:
            fill(#BA55D3);
            break;
          }

          if (data[i][j][k] == 1) {
            rect(mx + (MWIDTH - 3) * (j - 1), my+(NHEIGHT / 3 * mino_place), MWIDTH - 3, MWIDTH - 3);
          } else if (nblock[i][j][k] == 2) {
            rect(mx_2 + (MWIDTH - 3) * (j - 2), my_2+(NHEIGHT / 3 * mino_place) + (MWIDTH - 3) * (k - 2), MWIDTH - 3, MWIDTH - 3);
          } else {
            rect(mx_3 + (MWIDTH - 3) * (j - 1), my_2 +(NHEIGHT / 3 * mino_place)+ (MWIDTH - 3) * (k - 1), MWIDTH - 3, MWIDTH - 3);
          }
        }
      }
    }
    mino_place++;
  }
}

void drawsMino(int[][] data, int x) {          // draw a mino's shadow
  for (int i=0; i<data.length; i++) {
    for (int j=0; j<data[i].length; j++) {
      if (data[i][j] > 0) {
        switch(data[i][j]) {
        case 1:
          fill(#87CEFA, 100);
          break;

        case 2:
          fill(#FFFF00, 100);
          break;

        case 3:
          fill(#ADFF2F, 100);
          break;

        case 4:
          fill(#FF0000, 100);
          break;

        case 5:
          fill(#0000FF, 100);
          break;

        case 6:
          fill(#FFA500, 100);
          break;

        case 7:
          fill(#BA55D3, 100);
          break;
        }

        int position = 0, tposition = 0;
        for (int s = FHEIGHT - 1; s > y; s--) {
          if (!collision(data, x, s) && collision(data, x, s - 1)) {
            position = s;
            if (tposition == 0) tposition = s;
          }
        }

        if (through == 0) {
          rect(margin + MWIDTH * (i + x - 2), MWIDTH * (j + position - 3), MWIDTH, MWIDTH);
        } else {
          rect(margin + MWIDTH * (i + x - 2), MWIDTH * (j + tposition - 3), MWIDTH, MWIDTH);
        }
      }
    }
  }
}

void setField(int[][] field, int[][] block, int x, int y) {
  for (int i = 0; i < block.length; i++) {
    for (int j = 0; j < block[i].length; j++) {
      if (j + y - 2 < 0) {
        state = END;
        break;
      }

      if (block[i][j] > 0)
        field[i+x-2][j+y-2] = block[i][j];
    }
  }
}

boolean collision(int[][] data, int x, int y) {
  int decision = 0;

  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      if (j + y - 2 > FHEIGHT - 1 || j + y - 2 < 0 || i + x - 2 > FWIDTH - 1 || i + x - 2 < 0) 
        break;

      if (data[i][j] > 0 && field[i+x-2][j+y-2] == 0) 
        decision++;
    }
  }

  if (decision == 4) return true;
  else return false;
}

void deleteLine() {
  int line_check = 0;

  for (int j = field[0].length - 1; j > 0; j--) {
    for (int i = 0; i < field.length; i++) {
      if (field[i][j] > 0) line_check++;
    }

    if (line_check == FWIDTH - 2) {
      for (int t = j; t > 0; t--) {
        for (int s = field.length - 1; s > 0; s--) {
          field[s][t] = field[s][t-1];

          if (t == 1) field[s][1] = 0;
        }
      }
      line++;
      if (through == 0) now_score += 100;
      else now_score += 10;
    }
    line_check = 0;
  }
}


/*----------------------------------------------------------------------------*/
// keyboard relations

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) lMove();
    if (keyCode == RIGHT) rMove();
    if (keyCode == DOWN) dMove();
    if (keyCode == UP) hardDrop();
    if (keyCode == SHIFT) hold();
  }
  if (key == ' ') minoSpin();
  if (key == '1') 
    if (through == 0) through = 1;
    else through = 0;
}

void lMove() {
  if (x > 3  && y == 1) x--;
  else if (collision(block, x - 1, y)) x--;
}

void rMove() {
  if ( x < 8 && y == 1) x++;
  else if (collision(block, x + 1, y)) x++;
}

void dMove() {
  if (collision(block, x, y + 1)) y++;
}

void hardDrop() {
  int position = 0, tposition = 0;
  for (int i = FHEIGHT - 1; i > y; i--) 
    if (!collision(block, x, i) && collision(block, x, i-1)) {
      position = i;
      if (tposition == 0) tposition = i;
    }

  if (through == 0) { 
    setField(field, block, x, position-1);
  } else {
    setField(field, block, x, tposition-1);
  }

  dataClear(block);

  x = 6;
  y = 1;

  setnMino();

  if (hold_lock == 1) hold_lock = 0;

  time_count = 0;
}

void minoSpin() {
  int copy_mino[][] = new int[BSIZE][BSIZE];

  if (block[CX][CY] != 2) {
    for (int i = 0; i < BSIZE; i++) {
      for (int j = 0; j < BSIZE; j++) {
        copy_mino[BSIZE-1-j][i] = block[i][j];
      }
    }

    if (collision(copy_mino, x, y)) {
      for (int i = 0; i < BSIZE; i++) {
        for (int j = 0; j < BSIZE; j++) {
          block[i][j] = copy_mino[i][j];
          sblock[i][j] = copy_mino[i][j];
        }
      }
    }
  }

  spin_check = 1;
}

void hold() {
  int copy_mino = 0;

  if (hold_lock == 0) {
    hold_lock = 1;

    copy_mino = hblock[2][2];

    dataClear(hblock);
    setMino(hblock, block[2][2]);
    dataClear(block);

    x=6;
    y=2;

    if (copy_mino > 0) {
      setMino(block, copy_mino);
    } else 
      setnMino();
  }
}
