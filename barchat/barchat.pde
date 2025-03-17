ArrayList<Flight> flights;
HashMap<String, Integer> airportCounts;
ArrayList<String> topAirports;

void setup() {
  size(900, 650);
  flights = new ArrayList<Flight>();
  airportCounts = new HashMap<String, Integer>();
  topAirports = new ArrayList<String>();

  loadFlightData("flights100k.csv");
  calculateAirportCounts();
  selectTopAirports();
  noLoop();
}

void draw() {
  background(255);
  drawBarChart();
  drawLegend();
}

// 加载数据
void loadFlightData(String filename) {
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
}

// 统计机场出现次数
void calculateAirportCounts() {
  for (Flight f : flights) {
    if (airportCounts.containsKey(f.origin)) {
      airportCounts.put(f.origin, airportCounts.get(f.origin) + 1);
    } else {
      airportCounts.put(f.origin, 1);
    }
  }
}

// 选择排名前10的机场
void selectTopAirports() {
  for (int i = 0; i < 10; i++) {
    String topAirport = "";
    int maxCount = -1;
    for (String airport : airportCounts.keySet()) {
      int count = airportCounts.get(airport);
      if (count > maxCount && !topAirports.contains(airport)) {
        maxCount = count;
        topAirport = airport;
      }
    }
    if (!topAirport.equals("")) {
      topAirports.add(topAirport);
    }
  }
}

// 绘制柱状图
void drawBarChart() {
  int barWidth = 40;
  int spacing = 20;
  int maxValue = airportCounts.get(topAirports.get(0));
  
  for (int i = 0; i < topAirports.size(); i++) {
    String airport = topAirports.get(i);
    int val = airportCounts.get(airport);
    float barHeight = map(val, 0, maxValue, 0, 350);

    fill(100, 150, 255);
    rect(100 + i * (barWidth + spacing), height - barHeight - 120, barWidth, barHeight);

    fill(0);
    textAlign(CENTER);
    textSize(12);
    text(airport, 100 + i * (barWidth + spacing) + barWidth / 2, height - 90);
    text(val, 100 + i * (barWidth + spacing) + barWidth / 2, height - barHeight - 130);
  }
}

// 绘制图例
void drawLegend() {
  fill(100, 150, 255);
  rect(width/2 - 80, 20, 20, 10);
  
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Number of Flights", width/2 - 50, 25);
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
