ArrayList<Flight> flights;
HashMap<String, Integer> airportDelays;

void setup() {
  size(900, 600);
  flights = new ArrayList<Flight>();
  airportDelays = new HashMap<String, Integer>();
  loadFlightData("flights100k.csv");
  calculateDelays();
  noLoop();
}

void draw() {
  background(255);
  noStroke();
  textAlign(CENTER);
  textSize(10);

  for (String airport : airportDelays.keySet()) {
    int delayCount = airportDelays.get(airport);
    
    float x = random(width);
    float y = random(height);
    float radius = map(delayCount, 0, 20, 15, 70);
    
    // 延误数量映射到颜色 (蓝→绿→黄→红)
    if (delayCount < 3) {
      fill(0, 0, 255, 120);  // 蓝色 (少)
    } else if (delayCount < 7) {
      fill(0, 255, 0, 150);  // 绿色 (中等少)
    } else if (delayCount < 15) {
      fill(255, 255, 0, 180);  // 黄色 (中等多)
    } else {
      fill(255, 0, 0, 200);  // 红色 (严重)
    }

    ellipse(x, y, radius, radius);
    fill(0);
    text(airport, x, y);
  }
}

void loadFlightData(String filename) {
  String[] lines = loadStrings(filename);
  if (lines == null || lines.length < 2) {
    println("Error loading file or empty dataset.");
    return;
  }

  flights = new ArrayList<Flight>();
  for (int i = 1; i < lines.length; i++) {
    String[] cols = split(lines[i], ',');
    if (cols.length >= 18) {
      flights.add(new Flight(cols));
    }
  }
  println("Loaded " + flights.size() + " flights.");
}

void calculateDelays() {
  airportDelays = new HashMap<String, Integer>();

  for (Flight f : flights) {
    if (f.arrTime > f.crsArrTime) {
      if (airportDelays.containsKey(f.origin)) {
        airportDelays.put(f.origin, airportDelays.get(f.origin) + 1);
      } else {
        airportDelays.put(f.origin, 1);
      }
    }
  }
  println("Calculated delays for " + airportDelays.size() + " airports.");
}

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
