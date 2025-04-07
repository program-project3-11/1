
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;
import processing.event.*;

void drawPage1() {
  fill(255);
  textSize(36);
  textAlign(CENTER);
  text("Flight Research", width / 2, 50);
  drawPanel(50, 80, 700, 300, "Search Criteria");
  drawSearchCriteria();
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
  
  // Origin 输入框（筛选依据：文件中第 E 栏，即 originCity）
  text("Origin:", 80, 165);
  drawInputField(140, 145, 200, 30, originText, focusedField == 1);
  
  // Destination 输入框（筛选依据：文件中目的城市，对应栏目 I 的数据）
  text("Destination:", 80, 190);
  drawInputField(190, 175, 200, 30, destinationText, focusedField == 2);
  
  text("Date Range", 80, 230);
  
  // Fly Date Range 分段输入：三个部分（Month, Day, Year），用于筛选文件中 flDate（栏目A）
  text("Fly Date Range:", 80, 255);
  drawInputField(225, 240, 40, 30, flyDateLeft, focusedField == 3);
  drawInputField(275, 240, 40, 30, flyDateMid, focusedField == 4);
  drawInputField(325, 240, 70, 30, flyDateRight, focusedField == 5);
  
  // Arrive Date Range 分段输入：三个部分，用于筛选到达日期
  text("Arrive Date Range:", 80, 280);
  drawInputField(250, 270, 40, 30, arriveDateLeft, focusedField == 6);
  drawInputField(300, 270, 40, 30, arriveDateMid, focusedField == 7);
  drawInputField(350, 270, 70, 30, arriveDateRight, focusedField == 8);
  
  text("Lateness", 80, 320);
  drawLatenessButtons();
}

void drawInputField(int x, int y, int w, int h, String content, boolean focused) {
  // 输入框获得焦点时描边颜色改为绿色
  stroke(focused ? color(0, 255, 0) : color(0));
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

void drawFlightInfoPanel() {
  // 每次重绘时调用筛选函数，确保状态和日期条件改变时航班列表同步更新
  filteredFlights = filterFlights();
  
  drawPanel(flightPanelX, flightPanelY, flightPanelW, flightPanelH, "");
  clip(flightPanelX, flightPanelY, flightPanelW, flightPanelH);
  
  int startIndex = scrollY / flightItemHeight;
  int endIndex = min(filteredFlights.size(), startIndex + flightPanelH / flightItemHeight + 1);
  
  // 新增：记录鼠标悬停的航班
  Flight hoveredFlight = null;
  
  for (int i = startIndex; i < endIndex; i++) {
    Flight f = filteredFlights.get(i);
    int yPos = flightPanelY + (i * flightItemHeight - scrollY);
    String flightInfo = f.flDate + "   " + f.mktCarrierFlNum + "    " + f.originCity + " to " + f.destCity;
    
    // 如果鼠标位于当前航班的显示区域内，则记录该航班并改变背景色
    if (mouseX > flightPanelX && mouseX < flightPanelX + flightPanelW &&
        mouseY > yPos && mouseY < yPos + flightItemHeight) {
      fill(200);
      hoveredFlight = f;
    } else {
      fill(255);
    }
    rect(flightPanelX, yPos, flightPanelW, flightItemHeight);
    fill(0);
    textAlign(LEFT, CENTER);
    text(flightInfo, flightPanelX + 5, yPos + flightItemHeight / 2);
  }
  noClip();
  
  // 如果有悬停的航班，显示 tooltip（相对于鼠标指针偏移15像素）
  if (hoveredFlight != null) {
    drawFlightTooltip(hoveredFlight, mouseX + 15, mouseY + 15);
  }
}

ArrayList<Flight> flights;
ArrayList<Flight> filteredFlights;  // 过滤后的航班列表
int flightPanelX = 50, flightPanelY = 400, flightPanelW = 700, flightPanelH = 150;
int flightItemHeight = 30;
int scrollY = 0;

int page = 1;
boolean onTimeSelected = false;
boolean delayedSelected = false;
boolean cancelledSelected = false;

String originText = "";
String destinationText = "";
// Fly Date Range 输入框：依次代表 Month, Day, Year
String flyDateLeft = "";
String flyDateMid = "";
String flyDateRight = "";
// Arrive Date Range 输入框：依次代表 Month, Day, Year
String arriveDateLeft = "";
String arriveDateMid = "";
String arriveDateRight = "";
int focusedField = 0;

Flight selectedFlight;

class Flight {
  String flDate, mktCarrier, mktCarrierFlNum;
  String originCode, originCity, originState, originWac;
  String destCode, destCity, destState, destWac;
  String crsDepTime, depTime, crsArrTime, arrTime;
  // 状态字段：cancelled 与 diverted 对应文件中栏目17和18
  int cancelled, diverted;
  String distance;

  Flight(String[] data) {
    flDate = data[0];
    mktCarrier = data[1].replace("\"", "");
    mktCarrierFlNum = data[2].replace("\"", "");
    originCode = data[3].replace("\"", "");
    originCity = data[4].replace("\"", "");
    originState = data[5].replace("\"", "");
    originWac = data[7].replace("\"", "");
    destCode = data[8].replace("\"", "");
    destCity = data[9].replace("\"", "");
    destState = data[10].replace("\"", "");
    destWac = data[12].replace("\"", "");
    crsDepTime = data[13].replace("\"", "");
    depTime = data[14].replace("\"", "");
    crsArrTime = data[15].replace("\"", "");
    // 将 arrTime 与状态字段分离，假定文件中 arrTime 在 index 16，状态字段分别在 index 17 和 index 18
    arrTime = data[16].replace("\"", "");
    cancelled = int(data[17]);
    diverted = int(data[18]);
    try {
      distance = data[19].replace("\"", "").trim();
    } catch (Exception e) {
      distance = "N/A";
    }
  }
}

void loadFlightData() {
  String[] lines = loadStrings("flights100k.csv");
  flights = new ArrayList<Flight>();
  for (int i = 1; i < lines.length; i++) {
    String[] fields = split(lines[i], ',');
    if (fields.length >= 20) {
      flights.add(new Flight(fields));
    }
  }
}

void setup() {
  size(800, 600);
  textFont(createFont("Arial", 20));
  loadFlightData();
}

void draw() {
  background(0, 102, 204);
  if (page == 1) drawPage1();
  else if (page == 2) drawPage2();
  else if (page == 3) drawPage3();
}

void mousePressed() {
  if (page == 1) {
    // Origin 输入框
    if (mouseX > 140 && mouseX < 340 && mouseY > 145 && mouseY < 175) {
      focusedField = 1;
      return;
    }
    // Destination 输入框
    if (mouseX > 190 && mouseX < 390 && mouseY > 175 && mouseY < 205) {
      focusedField = 2;
      return;
    }
    // Fly Date Range 分段输入框
    if (mouseX > 225 && mouseX < 225 + 40 && mouseY > 240 && mouseY < 240 + 30) {
      focusedField = 3;
      return;
    }
    if (mouseX > 275 && mouseX < 275 + 40 && mouseY > 240 && mouseY < 240 + 30) {
      focusedField = 4;
      return;
    }
    if (mouseX > 325 && mouseX < 325 + 70 && mouseY > 240 && mouseY < 240 + 30) {
      focusedField = 5;
      return;
    }
    // Arrive Date Range 分段输入框
    if (mouseX > 250 && mouseX < 250 + 40 && mouseY > 270 && mouseY < 270 + 30) {
      focusedField = 6;
      return;
    }
    if (mouseX > 300 && mouseX < 300 + 40 && mouseY > 270 && mouseY < 270 + 30) {
      focusedField = 7;
      return;
    }
    if (mouseX > 350 && mouseX < 350 + 70 && mouseY > 270 && mouseY < 270 + 30) {
      focusedField = 8;
      return;
    }
    focusedField = 0;

    // 使用过滤后的航班列表进行点击判断
    if (mouseX > flightPanelX && mouseX < flightPanelX + flightPanelW && mouseY > flightPanelY && mouseY < flightPanelY + flightPanelH) {
      int clickedIndex = (mouseY - flightPanelY + scrollY) / flightItemHeight;
      if (clickedIndex >= 0 && clickedIndex < filteredFlights.size()) {
        selectedFlight = filteredFlights.get(clickedIndex);
        page = 2;
        return;
      }
    }

    // 点击状态按钮时，互斥选择，同时触发筛选条件更新
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

  if (page == 2) {
    if (mouseX > 20 && mouseX < 120 && mouseY > height - 50 && mouseY < height - 10) {
      page = 1;
      return;
    }
  }

  if (page == 3 && mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) {
    page = 2;
  }
}

void keyPressed() {
  if (focusedField != 0) {
    if (key == BACKSPACE) {
      if (focusedField == 1 && originText.length() > 0) originText = originText.substring(0, originText.length() - 1);
      else if (focusedField == 2 && destinationText.length() > 0) destinationText = destinationText.substring(0, destinationText.length() - 1);
      else if (focusedField == 3 && flyDateLeft.length() > 0) flyDateLeft = flyDateLeft.substring(0, flyDateLeft.length() - 1);
      else if (focusedField == 4 && flyDateMid.length() > 0) flyDateMid = flyDateMid.substring(0, flyDateMid.length() - 1);
      else if (focusedField == 5 && flyDateRight.length() > 0) flyDateRight = flyDateRight.substring(0, flyDateRight.length() - 1);
      else if (focusedField == 6 && arriveDateLeft.length() > 0) arriveDateLeft = arriveDateLeft.substring(0, arriveDateLeft.length() - 1);
      else if (focusedField == 7 && arriveDateMid.length() > 0) arriveDateMid = arriveDateMid.substring(0, arriveDateMid.length() - 1);
      else if (focusedField == 8 && arriveDateRight.length() > 0) arriveDateRight = arriveDateRight.substring(0, arriveDateRight.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      focusedField = 0;
    } else if (key != CODED) {
      if (focusedField == 1) originText += key;
      else if (focusedField == 2) destinationText += key;
      else if (focusedField == 3) flyDateLeft += key;
      else if (focusedField == 4) flyDateMid += key;
      else if (focusedField == 5) flyDateRight += key;
      else if (focusedField == 6) arriveDateLeft += key;
      else if (focusedField == 7) arriveDateMid += key;
      else if (focusedField == 8) arriveDateRight += key;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollY += e * 10;
  scrollY = constrain(scrollY, 0, max(0, filteredFlights.size() * flightItemHeight - flightPanelH));
}

// 修改后的筛选函数：当用户在 Arrive Date Range 有输入时，只以到达日期进行筛选；否则以飞行日期筛选
ArrayList<Flight> filterFlights() {
  // 若取消状态被选中且Arrive Date Range中有任何输入，则返回空列表
  if (cancelledSelected && (!arriveDateLeft.equals("") || !arriveDateMid.equals("") || !arriveDateRight.equals(""))) {
    return new ArrayList<Flight>();
  }
  
  ArrayList<Flight> result = new ArrayList<Flight>();
  // 遍历所有航班
  for (Flight f : flights) {
    // 根据 Origin 筛选：若输入框不为空，则判断 f.originCity 是否包含输入内容（忽略大小写）
    boolean matchOrigin = originText.equals("") || f.originCity.toLowerCase().indexOf(originText.toLowerCase()) != -1;
    // 根据 Destination 筛选：若输入框不为空，则判断 f.destCity 是否包含输入内容（忽略大小写）
    boolean matchDest = destinationText.equals("") || f.destCity.toLowerCase().indexOf(destinationText.toLowerCase()) != -1;
    
    // 根据状态按钮筛选
    boolean matchStatus = true;
    if (onTimeSelected) {
      matchStatus = (f.cancelled == 0 && f.diverted == 0);
    } else if (delayedSelected) {
      matchStatus = (f.cancelled == 0 && f.diverted == 1);
    } else if (cancelledSelected) {
      matchStatus = (f.cancelled == 1 && f.diverted == 0);
    }
    
    // 根据 Fly Date Range 筛选（仅当Arrive Date Range未填写时使用）
    boolean matchFlyDate = true;
    String[] dateParts = split(f.flDate, "/");
    if (!flyDateLeft.equals("") && dateParts.length >= 1) {
      matchFlyDate &= dateParts[0].trim().indexOf(flyDateLeft.trim()) != -1;
    }
    if (!flyDateMid.equals("") && dateParts.length >= 2) {
      matchFlyDate &= dateParts[1].trim().indexOf(flyDateMid.trim()) != -1;
    }
    if (!flyDateRight.equals("") && dateParts.length >= 3) {
      matchFlyDate &= dateParts[2].trim().indexOf(flyDateRight.trim()) != -1;
    }
    
    // 根据 Arrive Date Range 筛选
    // 如果 f.arrTime 以单引号开头，则认为到达日期为 flDate 加一天；否则直接使用 f.arrTime
    String arrDateStr;
    if (f.arrTime.startsWith("'")) {
      arrDateStr = addOneDay(f.flDate);
    } else {
      arrDateStr = f.arrTime;
    }
    
    boolean matchArrDate = true;
    String[] arrDateParts = split(arrDateStr, "/");
    if (!arriveDateLeft.equals("") && arrDateParts.length >= 1) {
      matchArrDate &= arrDateParts[0].trim().indexOf(arriveDateLeft.trim()) != -1;
    }
    if (!arriveDateMid.equals("") && arrDateParts.length >= 2) {
      matchArrDate &= arrDateParts[1].trim().indexOf(arriveDateMid.trim()) != -1;
    }
    if (!arriveDateRight.equals("") && arrDateParts.length >= 3) {
      matchArrDate &= arrDateParts[2].trim().indexOf(arriveDateRight.trim()) != -1;
    }
    
    // 当用户对 Arrive Date Range 有输入时，只以到达日期筛选；否则以飞行日期筛选
    boolean dateMatch;
    if (!arriveDateLeft.equals("") || !arriveDateMid.equals("") || !arriveDateRight.equals("")) {
      dateMatch = matchArrDate;
    } else {
      dateMatch = matchFlyDate;
    }
    
    if (matchOrigin && matchDest && matchStatus && dateMatch) {
      result.add(f);
    }
  }
  return result;
}

void drawPage2() {
  textFont(createFont("Arial", 14));
  fill(255);
  textSize(14);
  textAlign(CENTER);
  text("Detailed Flight Information", width / 2, 30);

  int leftMargin = 50, topMargin = 50, panelWidth = 340, panelHeight = 180, gap = 20, subSpacing = 25;
  int subStartOffset = 45;

  drawPanelPage2(leftMargin, topMargin, panelWidth, panelHeight, "Airline Information");
  int subY = topMargin + subStartOffset;
  textAlign(LEFT);
  text("Flight Date: " + selectedFlight.flDate, leftMargin + 10, subY);
  text("Carrier: " + selectedFlight.mktCarrier, leftMargin + 10, subY + subSpacing);
  text("Flight Number: " + selectedFlight.mktCarrierFlNum, leftMargin + 10, subY + 2 * subSpacing);

  drawPanelPage2(leftMargin + panelWidth + gap, topMargin, panelWidth, panelHeight, "Origin Information");
  subY = topMargin + subStartOffset;
  drawWhiteButton(leftMargin + panelWidth + gap + 10, subY - 10, "Airport Code: " + selectedFlight.originCode);
  text("City & State: " + selectedFlight.originCity, leftMargin + panelWidth + gap + 10, subY + subSpacing);
  text("State Abbreviation: " + selectedFlight.originState, leftMargin + panelWidth + gap + 10, subY + 2 * subSpacing);
  text("Region Code: " + selectedFlight.originWac, leftMargin + panelWidth + gap + 10, subY + 3 * subSpacing);

  int secondRowTop = topMargin + panelHeight + gap;
  drawPanelPage2(leftMargin, secondRowTop, panelWidth, panelHeight, "Dest Information");
  subY = secondRowTop + subStartOffset;
  drawWhiteButton(leftMargin + 10, subY - 10, "Airport Code: " + selectedFlight.destCode);
  text("City & State: " + selectedFlight.destCity, leftMargin + 10, subY + subSpacing);
  text("State Abbreviation: " + selectedFlight.destState, leftMargin + 10, subY + 2 * subSpacing);
  println("Debug - destWac = " + selectedFlight.destWac);
  text("Region Code: " + selectedFlight.destWac, leftMargin + 10, subY + 3 * subSpacing);

  drawPanelPage2(leftMargin + panelWidth + gap, secondRowTop, panelWidth, panelHeight, "Time Information");
  subY = secondRowTop + subStartOffset;
  text("Scheduled Departure: " + selectedFlight.crsDepTime, leftMargin + panelWidth + gap + 10, subY);
  text("Actual Departure: " + selectedFlight.depTime, leftMargin + panelWidth + gap + 10, subY + subSpacing);
  text("Scheduled Arrival: " + selectedFlight.crsArrTime, leftMargin + panelWidth + gap + 10, subY + 2 * subSpacing);
  text("Actual Arrival: " + selectedFlight.arrTime, leftMargin + panelWidth + gap + 10, subY + 3 * subSpacing);

  int thirdRowTop = secondRowTop + panelHeight + gap;
  int smallPanelWidth = (width - leftMargin * 2 - gap) / 2;
  int smallPanelHeight = 50;
  drawPanelPage2(leftMargin, thirdRowTop, smallPanelWidth, smallPanelHeight, "Status");
  textAlign(LEFT);
  text(getFlightStatus(selectedFlight), leftMargin + 120, thirdRowTop + 30);

  drawPanelPage2(leftMargin + smallPanelWidth + gap, thirdRowTop, smallPanelWidth, smallPanelHeight, "Distance");
  drawWhiteButton(leftMargin + smallPanelWidth + gap + 120, thirdRowTop + 12, selectedFlight.distance + " miles");

  drawBackButtonPage2();
}

void drawPage3() {
  fill(255);
  textSize(32);
  textAlign(CENTER);
  text("Related flight information", width / 2, 50);
  drawBackButton();
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
  if (f.cancelled == 0 && f.diverted == 1) return "Delayed";
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

  if (mousePressed && mouseX >= x && mouseX <= x + textWidth(label) + 20 && mouseY >= y && mouseY <= y + 24) {
    page = 3;
  }
}

void drawBackButtonPage2() {
  int btnX = 20;
  int btnY = height - 50;
  int btnW = 100;
  int btnH = 40;
  fill((mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) ? color(200,130,0) : color(255,165,0));
  rect(btnX, btnY, btnW, btnH, 8);
  fill(0);
  textSize(14);
  textAlign(CENTER, CENTER);
  text("Back", btnX + btnW/2, btnY + btnH/2);
}

void drawBackButton() {
  if (mouseX > 50 && mouseX < 150 && mouseY > 500 && mouseY < 540) fill(200, 130, 0);
  else fill(255, 165, 0);
  rect(50, 500, 100, 40, 8);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Back", 100, 520);
}

// 辅助函数：对传入的日期字符串（格式 M/d/yyyy）加一天，返回新的日期字符串
String addOneDay(String dateStr) {
  SimpleDateFormat sdf = new SimpleDateFormat("M/d/yyyy");
  try {
    Date date = sdf.parse(dateStr);
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    cal.add(Calendar.DATE, 1);
    return sdf.format(cal.getTime());
  } catch(Exception e) {
    return dateStr;
  }
}

// 绘制鼠标悬停时的提示框
void drawFlightTooltip(Flight flight, float x, float y) {
  // 构造提示文本内容
  String tooltipText = "Date: " + flight.flDate + "\n" +
                       "Flight: " + flight.mktCarrierFlNum + "\n" +
                       "From: " + flight.originCity + "\n" +
                       "To: " + flight.destCity + "\n" +
                       "Status: " + getFlightStatus(flight);
  
  // 按行拆分文本，计算文本框宽度和高度
  String[] lines = split(tooltipText, "\n");
  float maxWidth = 0;
  for (int i = 0; i < lines.length; i++) {
    float lineWidth = textWidth(lines[i]);
    if (lineWidth > maxWidth) {
      maxWidth = lineWidth;
    }
  }
  float tooltipWidth = maxWidth + 10;  // 左右各5像素边距
  float lineHeight = 18;
  float tooltipHeight = lines.length * lineHeight + 10;  // 上下各5像素边距
  
  // 绘制半透明背景框
  fill(255, 255, 255, 200);
  rect(x, y, tooltipWidth, tooltipHeight, 8);
  
  // 绘制文本
  fill(0);
  textAlign(LEFT, TOP);
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], x + 5, y + 5 + i * lineHeight);
  }
}
