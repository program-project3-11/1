ArrayList<Flight> flights;
int rowsPerPage = 5;  // 每页显示的航班数
int currentPage = 0;
int totalPages;
int page = 1;  // 控制当前显示的页面
boolean onTimeSelected = false;    // "On-time" button selection state
boolean delayedSelected = false;   // "Delayed" button selection state
boolean cancelledSelected = false; // "Cancelled" button selection state

String inputText1 = "";  // 用于存储第一个搜索框的输入文本
String inputText2 = "";  // 用于存储第二个搜索框的输入文本
boolean isTyping1 = false;  // 是否正在输入第一个搜索框
boolean isTyping2 = false;  // 是否正在输入第二个搜索框
String inputText3 = "";  // 存储 Fly Date Range 输入框的文本
String inputText4 = "";  // 存储 Arrive Date Range 输入框的文本
boolean isTyping3 = false;  // 是否正在输入 Fly Date Range
boolean isTyping4 = false;  // 是否正在输入 Arrive Date Range

boolean heatmapSelected = false;  // 热力图按钮选中状态
boolean routeMapSelected = false; // 航线图按钮选中状态

PImage routeMapImage, heatMapImage;
String status;
void setup() {
  size(800, 600);
  flights = new ArrayList<Flight>();
  loadFlightData("flights100k.csv");
  fill(255);
  textSize(14);
  totalPages = (int) ceil(flights.size() / (float) rowsPerPage);
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
  }else if (page == 4) {
    drawPage4();  // 绘制热力图页面
  }else if(page == 5){
    drawPage5();
  }
}

void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flight Research", width / 2, 50);
  drawPanel(50, 80, 700, 310, "Search Criteria");
  drawSearchCriteria();
  
  // 显示航班信息
  drawPanel(50, 400, 700, 150, "");
  drawFlightInformation();
  drawPaginationButtons();
}

void drawPage2() {
  // 浅蓝色背景小方块 
  fill(255, 255, 255, 180); // 浅蓝色（与第一界面的颜色一致）
  noStroke();
  rect(50, 80, width - 100, height - 170, 20); // 整体背景小方块 
 
  // 主标题 
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Detailed flight information", width / 2, 50);
 
  // Airline Information 
  fill(0);
  textSize(20);
  textAlign(LEFT); // 让标题左对齐 
  text("Airline Information", 100, 100);
  textSize(16);
  textAlign(LEFT); // 让内容左对齐 
  text("Flight Date: " + selectedFlight.date,  100, 130);
  text("Carrier: " + selectedFlight.airline,  100, 160);
  text("Flight Number: " + selectedFlight.flightNum,  100, 190);
 
  // Time Information 
  fill(0);
  textSize(20);
  textAlign(LEFT); // 让标题左对齐 
  text("Time Information", width / 2 + 50, 100);
  textSize(16);
  textAlign(LEFT); // 让内容左对齐 
  text("Scheduled Departure: " + selectedFlight.crsDepTime,  width / 2 + 50, 130);
  text("Actual Departure: " + selectedFlight.depTime,  width / 2 + 50, 160);
  text("Scheduled Arrival: " + selectedFlight.crsArrTime,  width / 2 + 50, 190);
  text("Actual Arrival: " + selectedFlight.arrTime,  width / 2 + 50, 220);
 
  // Origin Information 
  fill(0);
  textSize(20);
  textAlign(LEFT); // 让标题左对齐 
  text("Origin Information", 100, 270);
  textSize(16);
  textAlign(LEFT); // 让内容左对齐 
  // 绘制 Origin Airport Code 方块按钮 
  if (drawInteractiveButton(100, 300, "Airport Code: " + selectedFlight.origin))  {
    page = 3; // 点击后跳转到第三界面 
  }
  text("City & State: " + selectedFlight.originCity  + ", " + selectedFlight.originState,  100, 330);
  text("State Abbreviation: " + selectedFlight.originState,  100, 360);
  text("Region Code: " + selectedFlight.originState,  100, 390);
 
  // Destination Information 
  fill(0);
  textSize(20);
  textAlign(LEFT); // 让标题左对齐 
  text("Destination Information", width / 2 + 50, 270);
  textSize(16);
  textAlign(LEFT); // 让内容左对齐 
  // 绘制 Destination Airport Code 方块按钮 
  if (drawInteractiveButton(width / 2 + 50, 300, "Airport Code: " + selectedFlight.dest))  {
    page = 3; // 点击后跳转到第三界面 
  }
  text("City & State: " + selectedFlight.destCity  + ", " + selectedFlight.destState,  width / 2 + 50, 330);
  text("State Abbreviation: " + selectedFlight.destState,  width / 2 + 50, 360);
  text("Region Code: " + selectedFlight.destState,  width / 2 + 50, 390);
 
  // Add status and distance information at the bottom 
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text("Status: " + selectedFlight.status,  100, height - 140);  // 添加status 
  text("Distance: " + selectedFlight.distance  + " miles", 100, height - 110);  // 添加distance 
 
 if (selectedFlight == null) {
    text("No flight selected", width / 2, height / 2);
    return;
  }
  drawBackButton();
}
void drawSection(int x, int y, String title, String... lines) {
  fill(255, 255, 255, 180);
  rect(x, y, 600, 150, 15);
  fill(0);
  textSize(22);
  textAlign(LEFT);
  text(title, x + 20, y + 30);
  
  textSize(16);
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], x + 20, y + 60 + (i * 25));
  }
}String formatTime(int time) {
  if (time == 0) return "N/A";
  int hours = time / 100;
  int minutes = time % 100;
  return nf(hours, 2) + ":" + nf(minutes, 2);
}


void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
}

void drawPage4() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  // 在此绘制热力图
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Heat Map", width / 2, 50);
  
  // 显示航线图图片
  if (heatMapImage != null) {
    image(heatMapImage, 50, 80, width - 100, height - 160);
  } else {
    text("Error loading Heat Map image.", width / 2, height / 2);
  }

  drawBackButton();
  
  drawBackButton();  // 添加返回按钮
}

void drawPage5() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  // 在此绘制热力图
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Route Map", width / 2, 50);
  
  // 显示航线图图片
  if (routeMapImage != null) {
    image(routeMapImage, 50, 80, width - 100, height - 160);
  } else {
    text("Error loading Route Map image.", width / 2, height / 2);
  }

  drawBackButton();
  
  drawBackButton();  // 添加返回按钮
}


Flight selectedFlight = null; // 用于存储选中的航班

void drawFlightInformation() {
  fill(0);
  textSize(16);
  textAlign(LEFT);

  ArrayList<Flight> filteredFlights = getFilteredFlights();  // 使用筛选后的航班列表
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
    float y = 430 + (i - start) * 25;
    float width = panelWidth - 2 * padding;

    if (mouseX > x && mouseX < x + width && mouseY > y - 20 && mouseY < y + 10) {
      fill(200);
      rect(x, y - 20, width, 30, 8);
      fill(0);
      for (int e = 0; e < fields.length; e++) {
        text(fields[e], x + e * 150, y - 5);
      }

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


void drawPaginationButtons() {
  fill(255, 165, 0);
  
  if (currentPage > 0) {
    rect(50, 560, 120, 30, 8);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Previous Page", 110, 578);  // 确保文本在按钮框内
  }

  if (currentPage < totalPages - 1) {
    fill(255, 165, 0);
    rect(630, 560, 120, 30, 8);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Next Page", 690, 578);  // 确保文本在按钮框内
  }
}


void drawFlightDetails() {
  fill(0);
  textSize(20);
  
  if (selectedFlight != null) {
    text("Airline: " + selectedFlight.airline, 120, 170);
    text("Flight Number: " + selectedFlight.flightNum, 120, 200);
    
    int buttonX = 120;
    if (drawInteractiveButton(buttonX, 230, "Departure: " + selectedFlight.origin)) {
      page = 3;
    }
    if (drawInteractiveButton(buttonX, 260, "Arrival: " + selectedFlight.dest)) {
      page = 3;
    }
    if (drawInteractiveButton(buttonX, 290, "Distance: " + selectedFlight.distance + " miles")) {
      page = 3;
    }
  } else {
    text("No flight selected", 120, 170);
  }
}


boolean drawInteractiveButton(int x, int y, String label) {
 // 计算文字的宽度 
 // textSize(16); // 确保与按钮文本的字体大小一致 
  float textWidth = textWidth(label);
  // 设置按钮背景的宽度为文字宽度 + 20（留出一定的边距）
  float buttonWidth = textWidth + 20; 
  // 绘制白色背景 
  fill(255);  // 填充白色背景 
  rect(x, y - 20, buttonWidth, 30, 8);
  // 绘制黑色边框，类似于搜索框的样式
  stroke(0);  // 设置边框颜色为黑色
  strokeWeight(1);  // 设置边框的粗细
  noFill();  // 不填充颜色，保持透明的边框
  rect(x, y - 20, buttonWidth, 30, 8);  // 画出黑色边框
  noStroke();  // 取消边框描边
  // 绘制文本
  fill(0);
  textAlign(LEFT, CENTER);
  text(label, x + 10, y - 5);
  // 检查是否点击了按钮
  if (mouseX > x && mouseX < x + 250 && mouseY > y - 20 && mouseY < y + 10 && mousePressed) {
    return true;  // 返回true表示按钮被点击
  }
    return false;
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
  // 使用 inputText1 和 inputText2 来显示用户输入的内容
  drawSearchBar(240, 160, 250, 30, inputText1, isTyping1);
  drawSearchBar(240, 195, 250, 30, inputText2, isTyping2);  
  textSize(20);
  text("Date Range", 80, 230);
  text("Fly Date Range:", 80, 255);
  text("Arrive Date Range:", 80, 280);
  
  textSize(20);
  text("Flight", 80, 330);
  text("Chart", 520, 330);  // 在 Flight 后添加 "Chart" 文本
  
  drawLatenessButtons(); // Draw the three toggle buttons for flight status
  
  drawSearchBar(240, 250, 250, 30, inputText3, isTyping3);
  drawSearchBar(240, 285, 250, 30, inputText4, isTyping4);
  drawChartButtons();
}


void drawChartButtons() {
  // 绘制热力图按钮
  drawToggleButton(520, 350, "Heatmap", heatmapSelected); 
  // 绘制航线图按钮
  drawToggleButton(640, 350, "Route Map", routeMapSelected);
}


void drawLatenessButtons() {
  textSize(16);
  onTimeSelected = drawToggleButton(80, 350, "On-time", onTimeSelected);
  delayedSelected = drawToggleButton(200, 350, "Delayed", delayedSelected);
  cancelledSelected = drawToggleButton(320, 350, "Cancelled", cancelledSelected);
  // 更新 status 
 if (selectedFlight != null) {
    selectedFlight.status  = updateStatus(onTimeSelected, delayedSelected, cancelledSelected);
  }
}
String updateStatus(boolean onTimeSelected, boolean delayedSelected, boolean cancelledSelected) {
  if (onTimeSelected) {
    return "On-time";
  } else if (delayedSelected) {
    return "Delayed";
  } else if (cancelledSelected) {
    return "Cancelled";
  } else {
    return "Unknown"; // 默认状态 
  }
}

boolean drawToggleButton(int x, int y, String label, boolean selected) {
  int buttonWidth = 100;
  int buttonHeight = 30;

  // 检查是否点击了按钮 
  if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight && mousePressed) {
    selected = !selected; // 切换锁定状态 
  }

  // 根据锁定状态设置按钮颜色 
  if (selected) {
    fill(150); // 锁定状态为灰色 
  } else if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
    fill(200); // 鼠标悬停效果 
  } else {
    fill(255); // 默认颜色为白色 
  }

  rect(x, y, buttonWidth, buttonHeight, 8); // 绘制按钮 
  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2); // 绘制文本 

  return selected; // 返回当前的锁定状态 
}


void drawSearchBar(int x, int y, int w, int h, String inputText, boolean isTyping) {
  fill(255);
  if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + h && mousePressed) {
    isTyping = true; // 更新全局变量 
  }
  // 绘制输入框背景和边框
  if (mouseX > x && mouseX < x + w && mouseY > y - 20 && mouseY < y + h) {
    stroke(255, 0, 0);  // 红色边框
    strokeWeight(2);
    if (mousePressed && !isTyping) {
      inputText = "";  // 点击清空文本框
      isTyping = true; // 设为输入状态
    }
  } else {
    stroke(0);  // 默认边框为黑色
    strokeWeight(1);
  }
  rect(x, y - 20, w, h, 8);  // 绘制矩形框
  noStroke();
  
  fill(0);
  textSize(16);
  textAlign(LEFT, CENTER);
  
  if (isTyping) {
    text(inputText, x + 10, y);
  } else {
    text(inputText.isEmpty() ? "Enter text" : inputText, x + 10, y);  // 空文本时显示提示文字
  }
}

void drawBackButton() {
  fill(255, 165, 0);
  rect(50, height - 80, 100, 40, 8);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Back", 100, height - 60);
}

void mouseReleased() {
  // 处理返回按钮的逻辑 
  if (mouseX > 50 && mouseX < 150 && mouseY > height - 80 && mouseY < height - 40) {
    page = (page == 3) ? 2 : 1;
  }

  if (mouseX > 50 && mouseX < 170 && mouseY > 560 && mouseY < 590 && currentPage > 0) {
    currentPage--;
  }
  if (mouseX > 630 && mouseX < 750 && mouseY > 560 && mouseY < 590 && currentPage < totalPages - 1) {
    currentPage++;
  }

  // 处理热力图按钮点击 
  if (mouseX > 520 && mouseX < 620 && mouseY > 350 && mouseY < 380) {
    page = 4;  // 进入热力图页面 
  }

  // 处理航线图按钮点击 
  if (mouseX > 640 && mouseX < 740 && mouseY > 350 && mouseY < 380) {
    page = 5;  // 进入航线图页面 
  }

  // 设置输入框焦点 
  setInputFocus(mouseX, mouseY);
}


void setInputFocus(int mx, int my) {
  if (mx > 220 && mx < 470 && my > 160 - 20 && my < 160 + 30 - 20) {
    isTyping1 = true;
    isTyping2 = false;
    isTyping3 = false;
    isTyping4 = false;
  } else if (mx > 220 && mx < 470 && my > 195 - 20 && my < 195 + 30 - 20) {
    isTyping2 = true;
    isTyping1 = false;
    isTyping3 = false;
    isTyping4 = false;
  } else if (mx > 220 && mx < 470 && my > 250 - 20 && my < 250 + 30 - 20) {
    isTyping3 = true;
    isTyping1 = false;
    isTyping2 = false;
    isTyping4 = false;
  } else if (mx > 220 && mx < 470 && my > 285 - 20 && my < 285 + 30 - 20) {
    isTyping4 = true;
    isTyping1 = false;
    isTyping2 = false;
    isTyping3 = false;
  } else {
    isTyping1 = false;
    isTyping2 = false;
    isTyping3 = false;
    isTyping4 = false;
  }
}


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


void loadFlightData(String filename) {
  try {
    String[] lines = loadStrings(filename);
    if (lines == null || lines.length  < 2) {
      println("Error loading file or empty dataset.");
      return;
    }
    for (int i = 1; i < lines.length;  i++) {
      String[] cols = split(lines[i], ',');
      if (cols.length  >= 18) {
        flights.add(new  Flight(cols));
      }
    }
  } catch (Exception e) {
    println("Error loading flight data: " + e.getMessage()); 
  }
}


class Flight {
  String date, airline, flightNum, origin, originCity, originState;
  String dest, destCity, destState;
  int crsDepTime, crsArrTime, distance;
  float depTime, arrTime;
  int cancelled, diverted;
  String status;

  Flight(String[] data) {
    date = data[0];                         // FL_DATE
    airline = data[1];                      // MKT_CARRIER
    flightNum = data[2];                    // MKT_CARRIER_FL_NUM
    origin = data[3];                       // ORIGIN
    originCity = data[4];                   // ORIGIN_CITY_NAME
    originState = data[5];                  // ORIGIN_STATE_ABR
    dest = data[7];                         // DEST
    destCity = data[8];                     // DEST_CITY_NAME
    destState = data[9];                    // DEST_STATE_ABR
    crsDepTime = int(data[11]);             // CRS_DEP_TIME
    depTime = parseOptionalFloat(data[12]); // DEP_TIME
    crsArrTime = int(data[13]);             // CRS_ARR_TIME
    arrTime = parseOptionalFloat(data[14]); // ARR_TIME
    cancelled = int(float(data[15]));       // CANCELLED
    diverted = int(float(data[16]));        // DIVERTED
    distance = int(float(data[17]));        // DISTANCE
    status = "Unknown";
  }

  float parseOptionalFloat(String val) {
    try {
      return float(val);
    } catch (Exception e) {
      return -1;
    }
  }

  String[] toArray() {
    return new String[]{
      date, airline, flightNum, origin, dest,
      str(crsDepTime), (arrTime < 0 ? "N/A" : str(arrTime))
    };
  }
}

ArrayList<Flight> getFilteredFlights() {
  ArrayList<Flight> filtered = new ArrayList<Flight>();
  String originInput = inputText1.trim().toLowerCase(); // 改为小写统一比较
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

    if (matchesOrigin && matchesDest) {
      filtered.add(flight);
    }
  }

  return filtered;
}
