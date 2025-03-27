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

    // 状态判断
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


//main
ArrayList<Flight> flights;
int rowsPerPage = 5;  // 每页显示的航班数
int currentPage = 0;  // 当前页索引
int totalPages;       // 总页数
int page = 1;         // 当前显示的页面 (1=搜索,2=详情,3=相关,4=热力图,5=航线图)

// 航班状态按钮
boolean onTimeSelected = false;   
boolean delayedSelected = false;  
boolean cancelledSelected = false; 

// 搜索框文本和焦点状态
String inputText1 = "";  // Origin
String inputText2 = "";  // Destination
boolean isTyping1 = false;  
boolean isTyping2 = false;
String inputText3 = "";  // Fly Date Range (起始日期)
String inputText4 = "";  // Arrive Date Range (结束日期)
boolean isTyping3 = false;  
boolean isTyping4 = false;

// 图表按钮
boolean heatmapSelected = false;
boolean routeMapSelected = false;

PImage routeMapImage, heatMapImage;
Flight selectedFlight = null; // 选中的航班

// -----------------------------------------------------
// setup() / draw()
// -----------------------------------------------------
void setup() {
  size(800, 600);
  flights = new ArrayList<Flight>();
  loadFlightData("flights100k.csv");
  fill(255);
  textSize(14);
  // 计算总页数
  totalPages = (int) ceil(flights.size() / (float) rowsPerPage);

  // 加载图像文件
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
// Page1：搜索界面
// -----------------------------------------------------
void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flight Research", width / 2, 50);

  // 搜索面板
  drawPanel(50, 80, 700, 310, "Search Criteria");
  drawSearchCriteria();

  // 航班列表面板
  drawPanel(50, 400, 700, 150, "");
  drawFlightInformation();
  drawPaginationButtons();
}

// -----------------------------------------------------
// Page2：航班详情
// -----------------------------------------------------
void drawPage2() {
  // 浅蓝色背景方块
  fill(255, 255, 255, 180);
  noStroke();
  rect(50, 80, width - 100, height - 170, 20);

  // 主标题
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
// Page3：示例的“相关信息”页面
// -----------------------------------------------------
void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
}

// -----------------------------------------------------
// Page4：热力图页面
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
// Page5：航线图页面
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
// 绘制搜索条件区域
// -----------------------------------------------------
void drawSearchCriteria() {
  fill(0);
  textSize(20);
  text("Airport", 80, 140);
  text("Origin:", 80, 165);
  text("Destination:", 80, 190);

  // 输入框1（Origin）和输入框2（Destination）
  drawSearchBar(240, 160, 250, 30, inputText1, isTyping1);
  drawSearchBar(240, 195, 250, 30, inputText2, isTyping2);

  text("Date Range", 80, 230);
  text("Fly Date Range:", 80, 255);
  text("Arrive Date Range:", 80, 280);

  // 航班状态按钮 + 日期输入框
  text("Flight", 80, 330);
  text("Chart", 520, 330);
  drawLatenessButtons();

  drawSearchBar(240, 250, 250, 30, inputText3, isTyping3);  // 起始日期
  drawSearchBar(240, 285, 250, 30, inputText4, isTyping4);  // 结束日期

  drawChartButtons();
}

// -----------------------------------------------------
// 绘制图表按钮
// -----------------------------------------------------
void drawChartButtons() {
  drawToggleButton(520, 350, "Heatmap", heatmapSelected); 
  drawToggleButton(640, 350, "Route Map", routeMapSelected);
}

// -----------------------------------------------------
// 绘制航班状态按钮
// -----------------------------------------------------
void drawLatenessButtons() {
  textSize(16);
  // 用于检测是否发生点击
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
// 通用：绘制半透明面板
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
// 绘制航班列表
// -----------------------------------------------------
void drawFlightInformation() {
  fill(0);
  textSize(16);
  textAlign(LEFT);

  // 获取筛选后的航班列表
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
    float y = 430 + (i - start) * 25; // 每行间隔25
    float w = panelWidth - 2 * padding;

    // 鼠标悬停高亮
    if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + 10) {
      fill(200);
      rect(x, y - 20, w, 30, 8);
      fill(0);
      for (int e = 0; e < fields.length; e++) {
        text(fields[e], x + e * 150, y - 5);
      }
      // 如果点击则进入详情页面
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
// 绘制分页按钮
// -----------------------------------------------------
void drawPaginationButtons() {
  fill(255, 165, 0);
  // Previous
  if (currentPage > 0) {
    rect(50, 560, 120, 30, 8);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Previous Page", 110, 578);
  }

  // Next
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
// 绘制交互按钮（白色方块）
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

  // 点击检测
  if (mouseX > x && mouseX < x + 250 && mouseY > y - 20 && mouseY < y + 10 && mousePressed) {
    return true;
  }
  return false;
}

// -----------------------------------------------------
// 绘制切换按钮（灰白色切换）
// -----------------------------------------------------
boolean drawToggleButton(int x, int y, String label, boolean selected) {
  int buttonWidth = 100;
  int buttonHeight = 30;

  if (selected) {
    fill(150); // 激活状态
  } else if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
    fill(200); // 鼠标悬停
  } else {
    fill(255); // 默认
  }

  rect(x, y, buttonWidth, buttonHeight, 8);
  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2);

  return selected; // 注意：返回值仍然没变
}


// -----------------------------------------------------
// 绘制输入框
// -----------------------------------------------------
void drawSearchBar(int x, int y, int w, int h, String inputText, boolean isTyping) {
  fill(255);
  // 如果点击框内则进入输入状态
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
// 绘制返回按钮
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
// mouseReleased()：处理分页和按钮点击
// -----------------------------------------------------
void mouseReleased() {
  // 热力图 / 分页等按钮逻辑...
  
  // 航班状态按钮区域：
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

  // 输入框焦点
  setInputFocus(mouseX, mouseY);
}


// -----------------------------------------------------
// 根据鼠标位置确定哪个输入框获得焦点
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
  // 点击其它区域，取消所有焦点
  else {
    isTyping1 = false; 
    isTyping2 = false; 
    isTyping3 = false; 
    isTyping4 = false;
  }
}

// -----------------------------------------------------
// 键盘输入
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
// 加载CSV数据
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
// 获取筛选后的航班列表 (Origin / Destination / 日期范围)
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
// 将 "M/D/YYYY" 转为 int(YYYYMMDD)
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
