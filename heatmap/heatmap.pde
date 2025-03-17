ArrayList<Flight> flights;
HashMap<String, Integer> airportDelays;

int cols = 10;  // 每行10个方块
int spacing = 5;
int size = 50;
int marginX, marginY;

void setup() {
  size(900, 700);
  flights = new ArrayList<Flight>();
  airportDelays = new HashMap<String, Integer>();
  marginX = (width - cols * (size + spacing)) / 2;
  marginY = 100;

  loadFlightData("flights100k.csv");
  calculateDelays();
  noLoop();
}

void draw() {
  background(255);
  drawLegend();
  drawHeatmap();
}

// 绘制热力图（网格形式）
void drawHeatmap() {
  int count = 0;
  int x, y;

  for (String airport : airportDelays.keySet()) {
    int delayCount = airportDelays.get(airport);

    int colorFill;
    if (delayCount < 3) colorFill = color(69, 117, 180);
    else if (delayCount < 7) colorFill = color(116, 173, 209);
    else if (delayCount < 15) colorFill = color(253, 174, 97);
    else colorFill = color(215, 48, 39);

    x = marginX + (count % cols) * (size + spacing);
    y = marginY + (count / cols) * (size + spacing);

    fill(colorFill);
    rect(x, y, size, size);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(airport, x + size / 2, y + size / 2);

    count++;
  }
}

// 防止字体重叠的顶部颜色图例
void drawLegend() {
  int legendX = 30;  // 稍微往左移动，留更多空间
  int legendY = 30;
  int spacingX = 210;  // 稍微减小一点，确保最后的图例完整显示

  textSize(13);
  textAlign(LEFT, CENTER);

  fill(69, 117, 180);
  rect(legendX, legendY, 15, 15);
  fill(0);
  text("Low delay (<3)", legendX + 20, legendY + 8);

  fill(116, 173, 209);
  rect(legendX + spacingX, legendY, 15, 15);
  fill(0);
  text("Medium delay (3-6)", legendX + spacingX + 20, legendY + 8);

  fill(253, 174, 97);
  rect(legendX + spacingX * 2, legendY, 15, 15);
  fill(0);
  text("Moderate delay (7-14)", legendX + spacingX * 2 + 20, legendY + 8);

  fill(215, 48, 39);
  rect(legendX + spacingX * 3, legendY, 15, 15);
  fill(0);
  text("Severe delay (≥15)", legendX + spacingX * 3 + 20, legendY + 8);
}


// 数据加载函数
void loadFlightData(String filename) {
  String[] lines = loadStrings(filename);
  if (lines == null || lines.length < 2) {
    println("Error loading file or empty dataset.");
    return;
  }

  flights.clear();
  for (int i = 1; i < lines.length; i++) {
    String[] cols = split(lines[i], ',');
    if (cols.length >= 18) {
      flights.add(new Flight(cols));
    }
  }
  println("Loaded " + flights.size() + " flights.");
}

// 延误数据计算函数
void calculateDelays() {
  airportDelays.clear();

  for (Flight f : flights) {
    if (f.arrTime > f.crsArrTime) {
      airportDelays.put(f.origin, airportDelays.containsKey(f.origin) ? airportDelays.get(f.origin) + 1 : 1);
    }
  }
  println("Calculated delays for " + airportDelays.size() + " airports.");
}

// 定义Flight类
class Flight {
  String date, airline, flightNum, origin, originCity, originState, dest, destCity, destState;
  int originWac, destWac, crsDepTime, depTime, crsArrTime, arrTime, cancelled, diverted, distance;

  Flight(String[] data) {
    date = data[0]; airline = data[1]; flightNum = data[2]; origin = data[3];
    originCity = data[4]; originState = data[5]; originWac = int(data[6]); dest = data[7];
    destCity = data[8]; destState = data[9]; destWac = int(data[10]); crsDepTime = int(data[11]);
    depTime = int(data[12]); crsArrTime = int(data[13]); arrTime = int(data[14]);
    cancelled = int(data[15]); diverted = int(data[16]); distance = int(data[17]);
  }
}
