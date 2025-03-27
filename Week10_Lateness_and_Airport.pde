// Class Flight: Store Flights Data
class Flight {
  String date, airline, flightNum, origin, originCity, originState;
  String dest, destCity, destState;
  int crsDepTime, crsArrTime, distance;
  float depTime, arrTime;
  int cancelled, diverted;
  String status;

  Flight(String[] data) {
    date = data[0];
    airline = data[1];
    flightNum = data[2];
    origin = data[3];
    originCity = data[4];
    originState = data[5];
    dest = data[7];
    destCity = data[8];
    destState = data[9];
    crsDepTime = int(data[11]);
    depTime    = parseOptionalFloat(data[12]);
    crsArrTime = int(data[13]);
    arrTime    = parseOptionalFloat(data[14]);
    cancelled  = int(float(data[15]));
    diverted   = int(float(data[16]));
    distance   = int(float(data[17]));

    // Lateness Judgement
    if (cancelled == 1) {
      status = "Cancelled";
    } else if (getDelayMinutes() >= 60) {
      status = "Delayed";
    } else {
      status = "On-time";
    }
  }

  int getDelayMinutes() {
    if (depTime < 0) return 0;
    int scheduled = (crsDepTime / 100) * 60 + (crsDepTime % 100);
    int actual = (int(depTime) / 100) * 60 + (int(depTime) % 100);
    return actual - scheduled;
  }

  float parseOptionalFloat(String val) {
    try {
      return float(val);
    } catch (Exception e) {
      return -1;
    }
  }

  String[] toArray() {
    return new String[] {
      date, airline, flightNum, origin, dest,
      str(crsDepTime), (arrTime < 0 ? "N/A" : str(arrTime))
    };
  }
}


// -----------------------------------------------------
// Main
// -----------------------------------------------------
// Section 1: Declarations, Setups and Data Loading
// -----------------------------------------------------
ArrayList<Flight> flights;
int rowsPerPage = 5;  // Number of lines of flight information displayed per page
int currentPage = 0;  // Current page index
int totalPages;       // Total page numbers
int page = 1;         // Page currently displayed (1= Search,2= Details,3= Related,4= Heat map,5= Route map)

// Lateness Filter Buttons
boolean onTimeSelected = false;   
boolean delayedSelected = false;  
boolean cancelledSelected = false; 

// Search bar text and status
String inputText1 = "";  // Origin
String inputText2 = "";  // Destination
boolean isTyping1 = false;  
boolean isTyping2 = false;
String inputText3 = "";  // Departure Date Range 
String inputText4 = "";  // Arrive Date Range 
boolean isTyping3 = false;  
boolean isTyping4 = false;

// Visualization Buttons
boolean heatmapSelected = false;
boolean routeMapSelected = false;

PImage routeMapImage, heatMapImage;
Flight selectedFlight = null; 


void setup() {
  size(800, 600);
  flights = new ArrayList<Flight>();
  loadFlightData("flights100k.csv");
  fill(255);
  textSize(14);

  // Calculating total page numbers
  totalPages = (int) ceil(flights.size() / (float) rowsPerPage);

  // Loading images
  routeMapImage = loadImage("Route Map.png");
  heatMapImage = loadImage("Heat Map.png");
}

void draw() {
  background(0, 102, 204);
  if (page == 1) {
    drawPage1();
  } else if (page == 2) {
    drawPage2();
  } else if (page == 3) {
    drawPage3();
  } else if (page == 4) {
    drawPage4();
  } else if (page == 5) {
    drawPage5();
  }
}

// -----------------------------------------------------
// Loading .csv File
// -----------------------------------------------------
void loadFlightData(String filename) {
  try {
    String[] lines = loadStrings(filename);
    if (lines == null || lines.length < 2) {
      println("Error loading file or empty dataset.");
      return;
    }
    for (int i = 1; i < lines.length; i++) {
      String[] cols = split(lines[i], ',');
      if (cols.length >= 18) {
        flights.add(new Flight(cols));
      }
    }
  } catch (Exception e) {
    println("Error loading flight data: " + e.getMessage());
  }
}

// -----------------------------------------------------
// Section 2: Interface
// -----------------------------------------------------
// Public method: Draw a translucent panel
// -----------------------------------------------------
void drawPanel(int x, int y, int w, int h, String title) {
  fill(255, 255, 255, 180);
  rect(x, y, w, h, 15);
  fill(0);
  textSize(22);
  textAlign(LEFT);
  text(title, x + 20, y + 30);
}

// -----------------------------------------------------
// Public method: Draw an interactive button
// -----------------------------------------------------
boolean drawInteractiveButton(int x, int y, String label) {
  float tw = textWidth(label);
  float buttonWidth = tw + 20;
  
  fill(255);
  rect(x, y - 20, buttonWidth, 30, 8);
  stroke(0);
  strokeWeight(1);
  noFill();
  rect(x, y - 20, buttonWidth, 30, 8);
  noStroke();
  
  fill(0);
  textAlign(LEFT, CENTER);
  text(label, x + 10, y - 5);

  // click detection
  if (mouseX > x && mouseX < x + 250 && mouseY > y - 20 && mouseY < y + 10 && mousePressed) {
    return true;
  }
  return false;
}


// -----------------------------------------------------
// Public method: Draw a toggle button (white and grey toggle)
// -----------------------------------------------------
boolean drawToggleButton(int x, int y, String label, boolean selected) {
  int buttonWidth = 100;
  int buttonHeight = 30;

  if (selected) {
    fill(150); // selected
  } else if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
    fill(200); // mouse hover
  } else {
    fill(255); // default
  }

  rect(x, y, buttonWidth, buttonHeight, 8);
  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2);

  return selected; 
}


// -----------------------------------------------------
// Draw search criteria
// -----------------------------------------------------
void drawSearchCriteria() {
  fill(0);
  textSize(20);
  text("Airport", 80, 140);
  text("Origin:", 80, 165);
  text("Destination:", 80, 190);

  // Input box 1（Origin）Input box 2（Destination）
  drawSearchBar(240, 160, 250, 30, inputText1, isTyping1);
  drawSearchBar(240, 195, 250, 30, inputText2, isTyping2);

  text("Date Range", 80, 230);
  text("Fly Date Range:", 80, 255);
  text("Arrive Date Range:", 80, 280);

  // Flights lateness buttons & Date input box
  text("Flight", 80, 330);
  text("Chart", 520, 330);
  drawLatenessButtons();

  drawSearchBar(240, 250, 250, 30, inputText3, isTyping3);  // Start date
  drawSearchBar(240, 285, 250, 30, inputText4, isTyping4);  // End date

  drawChartButtons();
}


// -----------------------------------------------------
// Draw search criteria input boxs
// -----------------------------------------------------
void drawSearchBar(int x, int y, int w, int h, String inputText, boolean isTyping) {
  fill(255);
  // If clicked, invoke input mode
  if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + h && mousePressed) {
    isTyping = true;
  }
  if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + h) {
    stroke(255, 0, 0);
    strokeWeight(2);
    if (mousePressed && !isTyping) {
      inputText = "";
      isTyping = true;
    }
  } else {
    stroke(0);
    strokeWeight(1);
  }
  rect(x, y - 20, w, h, 8);
  noStroke();

  fill(0);
  textSize(16);
  textAlign(LEFT, CENTER);
  if (isTyping) {
    text(inputText, x + 10, y);
  } else {
    text(inputText.isEmpty() ? "Enter text" : inputText, x + 10, y);
  }
}

// -----------------------------------------------------
// Draw visualisation buttons
// -----------------------------------------------------
void drawChartButtons() {
  drawToggleButton(520, 350, "Heatmap", heatmapSelected); 
  drawToggleButton(640, 350, "Route Map", routeMapSelected);
}

// -----------------------------------------------------
// Draw lateness buttons
// -----------------------------------------------------
void drawLatenessButtons() {
  textSize(16);
  // Detect if a click occurs
  drawToggleButton(80, 350, "On-time", onTimeSelected);
  drawToggleButton(200, 350, "Delayed", delayedSelected);
  drawToggleButton(320, 350, "Cancelled", cancelledSelected);
}

String updateStatus(boolean onTimeSelected, boolean delayedSelected, boolean cancelledSelected) {
  if (onTimeSelected) return "On-time";
  if (delayedSelected) return "Delayed";
  if (cancelledSelected) return "Cancelled";
  return "Unknown";
}


// -----------------------------------------------------
// Draw flights information list
// -----------------------------------------------------
void drawFlightInformation() {
  fill(0);
  textSize(16);
  textAlign(LEFT);

  // Get filtered flight list
  ArrayList<Flight> filteredFlights = getFilteredFlights();
  totalPages = (int) ceil(filteredFlights.size() / (float) rowsPerPage);

  int start = currentPage * rowsPerPage;
  int end = min(start + rowsPerPage, filteredFlights.size());

  float panelX = 50;
  float panelWidth = 700;
  float padding = 10;

  for (int i = start; i < end; i++) {
    Flight flight = filteredFlights.get(i);
    String[] fields = flight.toArray();

    float x = panelX + padding;
    float y = 430 + (i - start) * 25; // Set the interval between each row to 25
    float w = panelWidth - 2 * padding;

    // Highlight when mouse hover
    if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + 10) {
      fill(200);
      rect(x, y - 20, w, 30, 8);
      fill(0);
      for (int e = 0; e < fields.length; e++) {
        text(fields[e], x + e * 150, y - 5);
      }
      // If click, go to the details page
      if (mousePressed) {
        selectedFlight = flight;
        page = 2;
      }
    } else {
      fill(0);
      for (int e = 0; e < fields.length; e++) {
        text(fields[e], x + e * 150, y - 5);
      }
    }
  }
}

// -----------------------------------------------------
// Draw page flipping buttons
// -----------------------------------------------------
void drawPaginationButtons() {
  fill(255, 165, 0);
  // Previous Page
  if (currentPage > 0) {
    rect(50, 560, 120, 30, 8);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Previous Page", 110, 578);
  }

  // Next Page
  if (currentPage < totalPages - 1) {
    fill(255, 165, 0);
    rect(630, 560, 120, 30, 8);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Next Page", 690, 578);
  }
}


// -----------------------------------------------------
// Draw back button
// -----------------------------------------------------
void drawBackButton() {
  fill(255, 165, 0);
  rect(50, height - 80, 100, 40, 8);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Back", 100, height - 60);
}

// -----------------------------------------------------
// Page1：Homepage
// -----------------------------------------------------
void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flights Information Inquiry", width / 2, 50);

  // Search panel
  drawPanel(50, 80, 700, 310, "Search Criteria");
  drawSearchCriteria();

  // Flights information panel
  drawPanel(50, 400, 700, 150, "");
  drawFlightInformation();
  drawPaginationButtons();
}

// -----------------------------------------------------
// Page2：Flights Details
// -----------------------------------------------------
void drawPage2() {
  fill(255, 255, 255, 180);
  noStroke();
  rect(50, 80, width - 100, height - 170, 20);

  // Title
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Detailed flight information", width / 2, 50);

  // Airline Information
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text("Airline Information", 100, 100);
  textSize(16);
  text("Flight Date: " + selectedFlight.date,  100, 130);
  text("Carrier: " + selectedFlight.airline,   100, 160);
  text("Flight Number: " + selectedFlight.flightNum, 100, 190);

  // Time Information
  fill(0);
  textSize(20);
  text("Time Information", width / 2 + 50, 100);
  textSize(16);
  text("Scheduled Departure: " + selectedFlight.crsDepTime, width / 2 + 50, 130);
  text("Actual Departure: " + selectedFlight.depTime,       width / 2 + 50, 160);
  text("Scheduled Arrival: " + selectedFlight.crsArrTime,   width / 2 + 50, 190);
  text("Actual Arrival: " + selectedFlight.arrTime,         width / 2 + 50, 220);

  // Origin Information
  fill(0);
  textSize(20);
  text("Origin Information", 100, 270);
  textSize(16);
  if (drawInteractiveButton(100, 300, "Airport Code: " + selectedFlight.origin)) {
    page = 3;
  }
  text("City & State: " + selectedFlight.originCity  + ", " + selectedFlight.originState,  100, 330);
  text("State Abbreviation: " + selectedFlight.originState,  100, 360);
  text("Region Code: " + selectedFlight.originState,  100, 390);

  // Destination Information
  fill(0);
  textSize(20);
  text("Destination Information", width / 2 + 50, 270);
  textSize(16);
  if (drawInteractiveButton(width / 2 + 50, 300, "Airport Code: " + selectedFlight.dest)) {
    page = 3;
  }
  text("City & State: " + selectedFlight.destCity + ", " + selectedFlight.destState, width / 2 + 50, 330);
  text("State Abbreviation: " + selectedFlight.destState, width / 2 + 50, 360);
  text("Region Code: " + selectedFlight.destState, width / 2 + 50, 390);

  // Status & Distance
  fill(0);
  textSize(20);
  text("Status: " + selectedFlight.status, 100, height - 140);
  text("Distance: " + selectedFlight.distance + " miles", 100, height - 110);

  if (selectedFlight == null) {
    text("No flight selected", width / 2, height / 2);
    return;
  }

  drawBackButton();
}

// -----------------------------------------------------
// Page3：Related Flight Information
// -----------------------------------------------------
void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
}

// -----------------------------------------------------
// Page4：Heat Map
// -----------------------------------------------------
void drawPage4() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Heat Map", width / 2, 50);

  if (heatMapImage != null) {
    image(heatMapImage, 50, 80, width - 100, height - 160);
  } else {
    text("Error loading Heat Map image.", width / 2, height / 2);
  }

  drawBackButton();
}

// -----------------------------------------------------
// Page5：Routes Map
// -----------------------------------------------------
void drawPage5() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Route Map", width / 2, 50);

  if (routeMapImage != null) {
    image(routeMapImage, 50, 80, width - 100, height - 160);
  } else {
    text("Error loading Route Map image.", width / 2, height / 2);
  }

  drawBackButton();
}

// -----------------------------------------------------
// Section 3: Mouse logics
// -----------------------------------------------------
// mouseReleased(): Handles buttons click
// -----------------------------------------------------
void mouseReleased() {
  // Buttons logic
  if (mouseX > 50 && mouseX < 150 && mouseY > height - 80 && mouseY < height - 40) {
    page = (page == 3) ? 2 : 1;
  }

  if (mouseX > 50 && mouseX < 170 && mouseY > 560 && mouseY < 590 && currentPage > 0) {
    currentPage--;
  }
  if (mouseX > 630 && mouseX < 750 && mouseY > 560 && mouseY < 590 && currentPage < totalPages - 1) {
    currentPage++;
  }

  // Handle heat map button click
  if (mouseX > 520 && mouseX < 620 && mouseY > 350 && mouseY < 380) {
    page = 4;  
  }

  // Handle route chart button click
  if (mouseX > 640 && mouseX < 740 && mouseY > 350 && mouseY < 380) {
    page = 5;  
  }

  // Set input box focus
  setInputFocus(mouseX, mouseY);

  // Lateness buttons click
  if (mouseX > 80 && mouseX < 180 && mouseY > 350 && mouseY < 380) {
    // On-time
    onTimeSelected = !onTimeSelected;
    delayedSelected = false;
    cancelledSelected = false;
    if (!onTimeSelected) println("All status filters cleared.");
    else println("Filter: On-time");
  } else if (mouseX > 200 && mouseX < 300 && mouseY > 350 && mouseY < 380) {
    // Delayed
    delayedSelected = !delayedSelected;
    onTimeSelected = false;
    cancelledSelected = false;
    if (!delayedSelected) println("All status filters cleared.");
    else println("Filter: Delayed");
  } else if (mouseX > 320 && mouseX < 420 && mouseY > 350 && mouseY < 380) {
    // Cancelled
    cancelledSelected = !cancelledSelected;
    onTimeSelected = false;
    delayedSelected = false;
    if (!cancelledSelected) println("All status filters cleared.");
    else println("Filter: Cancelled");
  }

  setInputFocus(mouseX, mouseY);
}


// -----------------------------------------------------
// setInputFocus(): Determine which input field gets focus based on the mouse position
// -----------------------------------------------------
void setInputFocus(int mx, int my) {
  // Origin
  if (mx > 220 && mx < 470 && my > 160 - 20 && my < 160 + 30 - 20) {
    isTyping1 = true; 
    isTyping2 = false; 
    isTyping3 = false; 
    isTyping4 = false;
  }
  // Destination
  else if (mx > 220 && mx < 470 && my > 195 - 20 && my < 195 + 30 - 20) {
    isTyping2 = true; 
    isTyping1 = false; 
    isTyping3 = false; 
    isTyping4 = false;
  }
  // Fly Date Range
  else if (mx > 220 && mx < 470 && my > 250 - 20 && my < 250 + 30 - 20) {
    isTyping3 = true; 
    isTyping1 = false; 
    isTyping2 = false; 
    isTyping4 = false;
  }
  // Arrive Date Range
  else if (mx > 220 && mx < 470 && my > 285 - 20 && my < 285 + 30 - 20) {
    isTyping4 = true; 
    isTyping1 = false; 
    isTyping2 = false; 
    isTyping3 = false;
  }
  // Click on other areas to unfocus all
  else {
    isTyping1 = false; 
    isTyping2 = false; 
    isTyping3 = false; 
    isTyping4 = false;
  }
}

// -----------------------------------------------------
// keyboard input
// -----------------------------------------------------
void keyPressed() {
  if (isTyping1) {
    if (key == BACKSPACE && inputText1.length() > 0) {
      inputText1 = inputText1.substring(0, inputText1.length() - 1);
    } else if (key != ENTER && key != TAB) {
      inputText1 += key;
    }
  }
  else if (isTyping2) {
    if (key == BACKSPACE && inputText2.length() > 0) {
      inputText2 = inputText2.substring(0, inputText2.length() - 1);
    } else if (key != ENTER && key != TAB) {
      inputText2 += key;
    }
  }
  else if (isTyping3) {
    if (key == BACKSPACE && inputText3.length() > 0) {
      inputText3 = inputText3.substring(0, inputText3.length() - 1);
    } else if (key != ENTER && key != TAB) {
      inputText3 += key;
    }
  }
  else if (isTyping4) {
    if (key == BACKSPACE && inputText4.length() > 0) {
      inputText4 = inputText4.substring(0, inputText4.length() - 1);
    } else if (key != ENTER && key != TAB) {
      inputText4 += key;
    }
  }
}


// -----------------------------------------------------
// Section 4: Flights Information  Filtering
// -----------------------------------------------------
// Get filtered flights list (Origin/Destination/date range)
// -----------------------------------------------------
ArrayList<Flight> getFilteredFlights() {
  ArrayList<Flight> filtered = new ArrayList<Flight>();
  String originInput = inputText1.trim().toLowerCase();
  String destInput = inputText2.trim().toLowerCase();

  for (Flight flight : flights) {
    String originCode = flight.origin.toLowerCase();
    String destCode = flight.dest.toLowerCase();
    String originCity = flight.originCity.toLowerCase();
    String destCity = flight.destCity.toLowerCase();

    boolean matchesOrigin = originInput.isEmpty() ||
                            originCode.contains(originInput) ||
                            originCity.contains(originInput);

    boolean matchesDest = destInput.isEmpty() ||
                          destCode.contains(destInput) ||
                          destCity.contains(destInput);

    boolean matchesStatus = true;
    
    if (onTimeSelected) {
      matchesStatus = flight.status.equals("On-time");
    } else if (delayedSelected) {
      matchesStatus = flight.status.equals("Delayed");
    } else if (cancelledSelected) {
      matchesStatus = flight.status.equals("Cancelled");
    }

    if (matchesOrigin && matchesDest && matchesStatus) {
      filtered.add(flight);
    }
  }

  return filtered;
}


// -----------------------------------------------------
// Convert "M/D/YYYY" to int(YYYYMMDD)
// -----------------------------------------------------
int parseDateToInt(String dateStr) {
  String[] parts = split(dateStr, '/');
  if (parts.length < 3) {
    return -1;
  }
  try {
    int month = int(parts[0]);
    int day   = int(parts[1]);
    int year  = int(parts[2]);
    return year * 10000 + month * 100 + day;
  } catch (Exception e) {
    return -1;
  }
}
