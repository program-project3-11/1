import processing.event.*;

// -----------------------------------------------------
// 全局变量声明
// -----------------------------------------------------
ArrayList<Flight> flights;      // 当前显示在页面上的航班列表
ArrayList<Flight> allFlights;   // 存储原始数据（loadFlightData后不会改变）
int flightPanelX = 50, flightPanelY = 400, flightPanelW = 700, flightPanelH = 150;
int flightItemHeight = 30;
int scrollY = 0;

int page = 1;                   // 当前页面（1：查询；2：详情；3：其它信息）
boolean onTimeSelected = false;
boolean delayedSelected = false;
boolean cancelledSelected = false;

// 下面四个字段对应查询条件
String originText = "";         // 出发机场城市名或代码
String destinationText = "";    // 到达机场城市名或代码
String flyDateText = "";        // 筛选的最早日期
String arriveDateText = "";     // 筛选的最晚日期

int focusedField = 0;           // 当前聚焦的输入框

Flight selectedFlight;          // 在列表中选中的航班

// -----------------------------------------------------
// Flight 类定义
// -----------------------------------------------------
class Flight {
  String flDate;           // 原始字段（形如 "1/1/2022 12:00:00 AM"）
  String mktCarrier, mktCarrierFlNum;
  String originCode, originCity, originState, originWac;
  String destCode, destCity, destState, destWac;
  String crsDepTime, depTime, crsArrTime, arrTime;
  int cancelled, diverted;
  String distance;

  Flight(String[] data) {
    // 假设 CSV 第 0 列是日期，形如 "1/1/2022 12:00:00 AM"
    flDate = data[0];

    mktCarrier = data[1].replace("\"", "");
    mktCarrierFlNum = data[2].replace("\"", "");
    originCode = data[3].replace("\"", "");
    originCity = data[4].replace("\"", "");
    originState = data[5].replace("\"", "");
    // data[6] 可能是别的字段，这里略过
    originWac = data[7].replace("\"", "");
    destCode = data[8].replace("\"", "");
    destCity = data[9].replace("\"", "");
    destState = data[10].replace("\"", "");
    // data[11] 可能是别的字段，这里略过
    destWac = data[12].replace("\"", "");

    crsDepTime = data[13].replace("\"", "");
    depTime    = data[14].replace("\"", "");
    crsArrTime = data[15].replace("\"", "");
    arrTime    = data[16].replace("\"", "");

    // 以下索引要确认是否正确
    cancelled  = int(data[16]); 
    diverted   = int(data[17]);

    try {
      distance = data[19].replace("\"", "").trim();
    } catch (Exception e) {
      distance = "N/A";
    }
  }
}

// -----------------------------------------------------
// setup() / draw()
// -----------------------------------------------------
void setup() {
  size(800, 600);
  textFont(createFont("Arial", 20));
  loadFlightData();
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

// -----------------------------------------------------
// 加载航班数据
// -----------------------------------------------------
void loadFlightData() {
  String[] lines = loadStrings("flights100k.csv"); // 你的CSV文件
  flights = new ArrayList<Flight>();
  for (int i = 1; i < lines.length; i++) {
    String[] fields = split(lines[i], ',');
    if (fields.length >= 19) {
      flights.add(new Flight(fields));
    }
  }
  // 备份原始数据，用于后续筛选
  allFlights = new ArrayList<Flight>(flights);
}

// -----------------------------------------------------
// Page1：搜索界面
// -----------------------------------------------------
void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flight Research", width / 2, 50);

  // 绘制搜索条件面板
  drawPanel(50, 80, 700, 300, "Search Criteria");
  drawSearchCriteria();

  // 绘制搜索按钮
  drawSearchButton();

  // 绘制下方航班列表
  drawFlightInfoPanel();
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
  drawInputField(140, 145, 200, 30, originText, focusedField == 1);

  text("Destination:", 80, 190);
  drawInputField(190, 175, 200, 30, destinationText, focusedField == 2);

  text("Date Range", 80, 230);
  text("Fly Date Range:", 80, 255);
  drawInputField(225, 240, 200, 30, flyDateText, focusedField == 3);

  text("Arrive Date Range:", 80, 280);
  drawInputField(250, 270, 200, 30, arriveDateText, focusedField == 4);

  text("Lateness", 80, 320);
  drawLatenessButtons();
}

void drawInputField(int x, int y, int w, int h, String content, boolean focused) {
  stroke(focused ? color(255, 0, 0) : color(0));
  fill(255);
  rect(x, y, w, h, 8);
  noStroke();
  fill(0);
  textAlign(LEFT, CENTER);
  text(content, x + 5, y + h / 2);
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

void drawSearchButton() {
  int btnX = 600, btnY = 320, btnW = 100, btnH = 40;
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    fill(200, 130, 0);
  } else {
    fill(255, 165, 0);
  }
  rect(btnX, btnY, btnW, btnH, 8);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Search", btnX + btnW/2, btnY + btnH/2);
}

void drawFlightInfoPanel() {
  // 面板外框
  drawPanel(flightPanelX, flightPanelY, flightPanelW, flightPanelH, "");

  // 裁剪
  clip(flightPanelX, flightPanelY, flightPanelW, flightPanelH);

  int startIndex = scrollY / flightItemHeight;
  int endIndex = min(flights.size(), startIndex + flightPanelH / flightItemHeight + 1);

  for (int i = startIndex; i < endIndex; i++) {
    Flight f = flights.get(i);
    int yPos = flightPanelY + (i * flightItemHeight - scrollY);

    // 显示简要信息
    String flightInfo = f.flDate + "   " + f.mktCarrierFlNum + "    " + f.originCity + " to " + f.destCity;

    if (mouseX > flightPanelX && mouseX < flightPanelX + flightPanelW &&
        mouseY > yPos && mouseY < yPos + flightItemHeight) {
      fill(200);
    } else {
      fill(255);
    }
    rect(flightPanelX, yPos, flightPanelW, flightItemHeight);
    fill(0);
    textAlign(LEFT, CENTER);
    text(flightInfo, flightPanelX + 5, yPos + flightItemHeight / 2);
  }
  noClip();
}

// -----------------------------------------------------
// 事件响应
// -----------------------------------------------------
void mousePressed() {
  // Page1：搜索页面
  if (page == 1) {
    // 如果点击“Search”按钮则执行筛选
    if (mouseX > 600 && mouseX < 700 && mouseY > 320 && mouseY < 360) {
      applyFilters();
      return;
    }

    // 点击输入框判断
    if (mouseX > 140 && mouseX < 340 && mouseY > 145 && mouseY < 175) {
      focusedField = 1;
      return;
    }
    if (mouseX > 190 && mouseX < 390 && mouseY > 175 && mouseY < 205) {
      focusedField = 2;
      return;
    }
    if (mouseX > 225 && mouseX < 425 && mouseY > 240 && mouseY < 270) {
      focusedField = 3;
      return;
    }
    if (mouseX > 250 && mouseX < 450 && mouseY > 270 && mouseY < 300) {
      focusedField = 4;
      return;
    }
    focusedField = 0;

    // 点击航班列表，进入 Page2
    if (mouseX > flightPanelX && mouseX < flightPanelX + flightPanelW &&
        mouseY > flightPanelY && mouseY < flightPanelY + flightPanelH) {
      int clickedIndex = (mouseY - flightPanelY + scrollY) / flightItemHeight;
      if (clickedIndex >= 0 && clickedIndex < flights.size()) {
        selectedFlight = flights.get(clickedIndex);
        page = 2;
        return;
      }
    }

    // 航班状态按钮
    if (mouseX > 80 && mouseX < 180 && mouseY > 330 && mouseY < 360) {
      onTimeSelected = !onTimeSelected;
      delayedSelected = false;
      cancelledSelected = false;
    } else if (mouseX > 200 && mouseX < 300 && mouseY > 330 && mouseY < 360) {
      delayedSelected = !delayedSelected;
      onTimeSelected = false;
      cancelledSelected = false;
    } else if (mouseX > 320 && mouseX < 420 && mouseY > 330 && mouseY < 360) {
      cancelledSelected = !cancelledSelected;
      onTimeSelected = false;
      delayedSelected = false;
    }
  }

  // Page2：详情页面，返回按钮
  if (page == 2) {
    if (mouseX > 20 && mouseX < 120 && mouseY > height - 50 && mouseY < height - 10) {
      page = 1;
      return;
    }
  }

  // Page3：演示页面，返回按钮
  if (page == 3 && mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) {
    page = 2;
  }
}

void keyPressed() {
  // 根据当前聚焦的输入框，将输入字符放入对应字符串
  if (focusedField != 0) {
    if (key == BACKSPACE) {
      if (focusedField == 1 && originText.length() > 0) {
        originText = originText.substring(0, originText.length() - 1);
      } else if (focusedField == 2 && destinationText.length() > 0) {
        destinationText = destinationText.substring(0, destinationText.length() - 1);
      } else if (focusedField == 3 && flyDateText.length() > 0) {
        flyDateText = flyDateText.substring(0, flyDateText.length() - 1);
      } else if (focusedField == 4 && arriveDateText.length() > 0) {
        arriveDateText = arriveDateText.substring(0, arriveDateText.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      focusedField = 0;
    } else if (key != CODED) {
      if (focusedField == 1) {
        originText += key;
      } else if (focusedField == 2) {
        destinationText += key;
      } else if (focusedField == 3) {
        flyDateText += key;
      } else if (focusedField == 4) {
        arriveDateText += key;
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollY += e * 10;
  scrollY = constrain(scrollY, 0, max(0, flights.size() * flightItemHeight - flightPanelH));
}

// -----------------------------------------------------
// Page2：详情界面
// -----------------------------------------------------
void drawPage2() {
  textFont(createFont("Arial", 14));
  fill(255);
  textSize(14);
  textAlign(CENTER);
  text("Detailed Flight Information", width / 2, 30);

  int leftMargin = 50, topMargin = 50;
  int panelWidth = 340, panelHeight = 180;
  int gap = 20, subSpacing = 25;
  int subStartOffset = 45;

  // 航司信息
  drawPanelPage2(leftMargin, topMargin, panelWidth, panelHeight, "Airline Information");
  int subY = topMargin + subStartOffset;
  textAlign(LEFT);
  text("Flight Date: " + selectedFlight.flDate, leftMargin + 10, subY);
  text("Carrier: " + selectedFlight.mktCarrier, leftMargin + 10, subY + subSpacing);
  text("Flight Number: " + selectedFlight.mktCarrierFlNum, leftMargin + 10, subY + 2 * subSpacing);

  // 出发地信息
  drawPanelPage2(leftMargin + panelWidth + gap, topMargin, panelWidth, panelHeight, "Origin Information");
  subY = topMargin + subStartOffset;
  drawWhiteButton(leftMargin + panelWidth + gap + 10, subY - 10, "Airport Code: " + selectedFlight.originCode);
  text("City & State: " + selectedFlight.originCity, leftMargin + panelWidth + gap + 10, subY + subSpacing);
  text("State Abbreviation: " + selectedFlight.originState, leftMargin + panelWidth + gap + 10, subY + 2 * subSpacing);
  text("Region Code: " + selectedFlight.originWac, leftMargin + panelWidth + gap + 10, subY + 3 * subSpacing);

  // 到达地信息
  int secondRowTop = topMargin + panelHeight + gap;
  drawPanelPage2(leftMargin, secondRowTop, panelWidth, panelHeight, "Dest Information");
  subY = secondRowTop + subStartOffset;
  drawWhiteButton(leftMargin + 10, subY - 10, "Airport Code: " + selectedFlight.destCode);
  text("City & State: " + selectedFlight.destCity, leftMargin + 10, subY + subSpacing);
  text("State Abbreviation: " + selectedFlight.destState, leftMargin + 10, subY + 2 * subSpacing);
  println("Debug - destWac = " + selectedFlight.destWac);
  text("Region Code: " + selectedFlight.destWac, leftMargin + 10, subY + 3 * subSpacing);

  // 时间信息
  drawPanelPage2(leftMargin + panelWidth + gap, secondRowTop, panelWidth, panelHeight, "Time Information");
  subY = secondRowTop + subStartOffset;
  text("Scheduled Departure: " + selectedFlight.crsDepTime, leftMargin + panelWidth + gap + 10, subY);
  text("Actual Departure: " + selectedFlight.depTime, leftMargin + panelWidth + gap + 10, subY + subSpacing);
  text("Scheduled Arrival: " + selectedFlight.crsArrTime, leftMargin + panelWidth + gap + 10, subY + 2 * subSpacing);
  text("Actual Arrival: " + selectedFlight.arrTime, leftMargin + panelWidth + gap + 10, subY + 3 * subSpacing);

  // 航班状态 / 距离
  int thirdRowTop = secondRowTop + panelHeight + gap;
  int smallPanelWidth = (width - leftMargin * 2 - gap) / 2;
  int smallPanelHeight = 50;
  drawPanelPage2(leftMargin, thirdRowTop, smallPanelWidth, smallPanelHeight, "Status");
  textAlign(LEFT);
  text(getFlightStatus(selectedFlight), leftMargin + 120, thirdRowTop + 30);

  drawPanelPage2(leftMargin + smallPanelWidth + gap, thirdRowTop, smallPanelWidth, smallPanelHeight, "Distance");
  drawWhiteButton(leftMargin + smallPanelWidth + gap + 120, thirdRowTop + 12, selectedFlight.distance + " miles");

  // 返回按钮
  drawBackButtonPage2();
}

void drawPanelPage2(int x, int y, int w, int h, String title) {
  fill(255, 255, 255, 180);
  rect(x, y, w, h, 15);
  fill(0);
  textSize(14);
  textAlign(LEFT);
  text(title, x + 20, y + 25);
}

String getFlightStatus(Flight f) {
  if (f.cancelled == 1 && f.diverted == 0) return "Cancelled";
  if (f.cancelled == 0 && f.diverted == 1) return "Diverted";
  return "On time";
}

void drawWhiteButton(int x, int y, String label) {
  fill(255);
  stroke(180);
  rect(x, y, textWidth(label) + 20, 24, 6);
  noStroke();
  fill(0);
  textAlign(LEFT, CENTER);
  text(label, x + 10, y + 12);

  // 点击该按钮进入 Page3
  if (mousePressed && mouseX >= x && mouseX <= x + textWidth(label) + 20 &&
      mouseY >= y && mouseY <= y + 24) {
    page = 3;
  }
}

void drawBackButtonPage2() {
  int btnX = 20;
  int btnY = height - 50;
  int btnW = 100;
  int btnH = 40;
  fill((mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH)
       ? color(200,130,0) : color(255,165,0));
  rect(btnX, btnY, btnW, btnH, 8);
  fill(0);
  textSize(14);
  textAlign(CENTER, CENTER);
  text("Back", btnX + btnW/2, btnY + btnH/2);
}

// -----------------------------------------------------
// Page3：演示界面
// -----------------------------------------------------
void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
}

void drawBackButton() {
  if (mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) {
    fill(200, 130, 0);
  } else {
    fill(255, 165, 0);
  }
  rect(50, 500, 100, 40, 8);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Back", 100, 520);
}

// -----------------------------------------------------
// applyFilters()：筛选函数
// 只按 起始日期 / 结束日期、Origin、Destination、Lateness 做过滤
// -----------------------------------------------------
void applyFilters() {
  ArrayList<Flight> filtered = new ArrayList<Flight>();

  // 将用户输入的日期转换成数值(YYYYMMDD)
  int fromVal = -1;
  if (flyDateText.trim().length() > 0) {
    fromVal = parseDateToInt(flyDateText.trim());
  }

  int toVal = -1;
  if (arriveDateText.trim().length() > 0) {
    toVal = parseDateToInt(arriveDateText.trim());
  }

  // 遍历所有航班
  for (Flight f : allFlights) {
    boolean match = true;

    // 提取日期部分（只取空格前面，如 "1/1/2022"）
    String datePart = f.flDate.split(" ")[0]; 
    int flightVal = parseDateToInt(datePart);

    // 1) 起始日期判断
    if (fromVal != -1 && flightVal < fromVal) {
      match = false;
    }
    // 2) 结束日期判断
    if (toVal != -1 && flightVal > toVal) {
      match = false;
    }

    // 3) 根据 Origin 筛选（不区分大小写）
    if (originText.length() > 0) {
      String lowerOrigin = originText.toLowerCase();
      if (!(f.originCity.toLowerCase().contains(lowerOrigin) ||
            f.originCode.toLowerCase().contains(lowerOrigin))) {
        match = false;
      }
    }

    // 4) 根据 Destination 筛选（不区分大小写）
    if (destinationText.length() > 0) {
      String lowerDest = destinationText.toLowerCase();
      if (!(f.destCity.toLowerCase().contains(lowerDest) ||
            f.destCode.toLowerCase().contains(lowerDest))) {
        match = false;
      }
    }

    // 5) 根据航班状态进行筛选（On-time / Delayed / Cancelled）
    if (onTimeSelected) {
      // 简易判断：未取消、未转向，且 depTime == crsDepTime
      if (!(f.cancelled == 0 && f.diverted == 0 && f.depTime.equals(f.crsDepTime))) {
        match = false;
      }
    } else if (delayedSelected) {
      // 简易判断：未取消、未转向，且 depTime > crsDepTime
      // 需保证 depTime, crsDepTime 可转换为 int
      if (!(f.cancelled == 0 && f.diverted == 0 && safeParseInt(f.depTime) > safeParseInt(f.crsDepTime))) {
        match = false;
      }
    } else if (cancelledSelected) {
      // 航班取消
      if (f.cancelled != 1) {
        match = false;
      }
    }

    if (match) {
      filtered.add(f);
    }
  }

  flights = filtered;
  scrollY = 0; // 重置滚动位置
}

// -----------------------------------------------------
// 将 "1/1/2022" 转换为 int(20220101) 便于比较
// 若格式不对，返回 -1
// -----------------------------------------------------
int parseDateToInt(String dateStr) {
  // 假设 dateStr 形如 "1/1/2022" 或 "01/01/2022"
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

// 安全地把字符串转换为 int，若出错则返回 -1
int safeParseInt(String s) {
  try {
    return int(s);
  } catch(Exception e) {
    return -1;
  }
}
