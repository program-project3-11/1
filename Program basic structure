int page = 1;
boolean onTimeSelected = false;
boolean delayedSelected = false;
boolean cancelledSelected = false;

void setup() {
  size(800, 600);
  textFont(createFont("Arial", 20));
}

void draw() {
  background(0, 102, 204); 
  if (page == 1) {
    drawPage1();
  } else if (page == 2) {
    drawPage2();
  } else if (page == 3) {
    drawPage3();
  }
}

void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flight Research", width / 2, 50);
  drawPanel(50, 80, 700, 300, "Search Criteria");
  drawSearchCriteria();
  drawPanel(50, 400, 700, 150, "");
  drawFlightRecommendations();
}

void drawPage2() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Detailed flight informations", width / 2, 50);
  drawPanel(100, 100, 600, 300, "Flight Details");
  drawFlightDetails();
  drawBackButton();
}

void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
}

void drawFlightRecommendations() {
  fill(255);
  rect(300, 450, 200, 40, 8);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Select Flight", 400, 470);
}

void drawFlightDetails() {
  fill(0);
  textSize(20);
  text("Airline: Example Air", 120, 170);
  text("Flight Number: EX123", 120, 200);
  drawInteractiveButton(120, 230, "Departure: XYZ Airport");
  drawInteractiveButton(120, 260, "Arrival: ABC Airport");
  drawInteractiveButton(120, 290, "Distance: 500 miles");
}

void drawInteractiveButton(int x, int y, String label) {
  fill(255);
  rect(x, y - 20, 250, 30, 8);
  fill(0);
  textAlign(LEFT, CENTER);
  text(label, x + 10, y - 5);
}

void drawPanel(int x, int y, int w, int h, String title) {
  fill(255, 255, 255, 180);
  rect(x, y, w, h, 15);
  fill(0);
  textSize(22);
  textAlign(LEFT);
  text(title, x + 20, y + 30);
}

void drawSearchCriteria() {
  fill(0);
  textSize(20);
  text("Airport", 80, 140);
  text("Origin:", 80, 165);
  text("Destination:", 80, 190);
  
  text("Date Range", 80, 230);
  text("Fly Date Range:", 80, 255);
  text("Arrive Date Range:", 80, 280);
  
  text("Lateness", 80, 320);
  drawLatenessButtons();
}

void drawLatenessButtons() {
  drawToggleButton(80, 350, "On-time", onTimeSelected);
  drawToggleButton(200, 350, "Delayed", delayedSelected);
  drawToggleButton(320, 350, "Cancelled", cancelledSelected);
}

void drawToggleButton(int x, int y, String label, boolean selected) {
  if (selected) {
    fill(150); 
  } else if (mouseX > x && mouseX < x + 100 && mouseY > y - 20 && mouseY < y + 10) {
    fill(200); 
  } else {
    fill(255);
  }
  rect(x, y - 20, 100, 30, 8);
  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + 50, y - 5);
}

void drawBackButton() {
  fill(255, 165, 0); 
  rect(50, 500, 100, 40, 8);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Back", 100, 520);
}

void mousePressed() {
  if (page == 1) {
    if (mouseX > 300 && mouseX < 500 && mouseY > 450 && mouseY < 490) {
      page = 2;
    }
    if (mouseX > 80 && mouseX < 180 && mouseY > 330 && mouseY < 360) {
      onTimeSelected = !onTimeSelected;
    } else if (mouseX > 200 && mouseX < 300 && mouseY > 330 && mouseY < 360) {
      delayedSelected = !delayedSelected;
    } else if (mouseX > 320 && mouseX < 420 && mouseY > 330 && mouseY < 360) {
      cancelledSelected = !cancelledSelected;
    }
  }
  if (page == 2) {
    if (mouseX > 120 && mouseX < 370 && mouseY > 180 && mouseY < 210) {
      page = 3; 
    } else if (mouseX > 120 && mouseX < 370 && mouseY > 210 && mouseY < 240) {
      page = 3; 
    } else if (mouseX > 120 && mouseX < 370 && mouseY > 240 && mouseY < 270) {
      page = 3; 
    } else if (mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) {
      page = 1; 
    }
  }
  if (page == 3 && mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) {
    page = 2; 
  }
}
