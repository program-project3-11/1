ArrayList<Flight> flights;

void setup() {
  size(900, 600);
  flights = new ArrayList<Flight>();
  loadFlightData("flights2k.csv");
  noLoop();
}

void draw() {
  background(255);
  stroke(0, 100);
  fill(0);
  textSize(10);

  for (int i = 0; i < flights.size(); i += 20) { // 每隔20个航班绘制一次，防止过密
    Flight f = flights.get(i);
    float x1 = random(width);
    float y1 = random(height);
    float x2 = random(width);
    float y2 = random(height);
    
    line(x1, y1, x2, y2);
    ellipse(x1, y1, 4, 4);
    ellipse(x2, y2, 4, 4);
  }
}

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
  println("Loaded " + flights.size() + " flights.");
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
