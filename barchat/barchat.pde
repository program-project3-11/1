ArrayList<Flight> flights;
HashMap<String, Integer> airportCounts;
String[] topAirports;
int[] topCounts;

void setup() {
  size(900, 600);
  flights = new ArrayList<Flight>();
  airportCounts = new HashMap<String, Integer>();

  loadFlightData("flights100k.csv");
  calculateTopAirports();
  noLoop();
}

void draw() {
  background(255);
  drawBarChart();
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

void calculateTopAirports() {
  for (Flight f : flights) {
    if (airportCounts.containsKey(f.origin)) {
      airportCounts.put(f.origin, airportCounts.get(f.origin) + 1);
    } else {
      airportCounts.put(f.origin, 1);
    }
  }
  
  topAirports = new String[10];
  topCounts = new int[10];
  
  for (int i = 0; i < 10; i++) {
    String maxAirport = "";
    int maxCount = -1;
    for (String airport : airportCounts.keySet()) {
      int count = airportCounts.get(airport);
      if (count > maxCount && !arrayContains(topAirports, airport)) {
        maxAirport = airport;
        maxCount = count;
      }
    }
    topAirports[i] = maxAirport;
    topCounts[i] = maxCount;
  }
}

boolean arrayContains(String[] arr, String value) {
  for (String s : arr) {
    if (s != null && s.equals(value)) return true;
  }
  return false;
}

void drawBarChart() {
  int barWidth = 50, spacing = 15, x = 100;
  int maxValue = topCounts[0];

  textSize(12);
  textAlign(CENTER);

  for (int i = 0; i < topAirports.length; i++) {
    float barHeight = map(topCounts[i], 0, maxValue, 0, 400);
    fill(100, 150, 255);
    rect(x + i*(barWidth + spacing), height - barHeight - 100, barWidth, barHeight);
    fill(0);
    text(topAirports[i], x + i*(barWidth + spacing) + barWidth/2, height - 80);
    text(topCounts[i], x + i*(barWidth + spacing) + barWidth/2, height - barHeight - 110);
  }
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
