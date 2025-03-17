ArrayList<Flight> flights;
HashMap<String, Integer> routeCounts;
ArrayList<Route> topRoutes;

void setup() {
  size(900, 600);
  flights = new ArrayList<Flight>();
  routeCounts = new HashMap<String, Integer>();
  topRoutes = new ArrayList<Route>();

  loadFlightData("flights100k.csv");
  calculateTopRoutes();
  noLoop();
}

void draw() {
  background(255);
  stroke(0, 150);
  textSize(10);
  textAlign(CENTER, CENTER);

  for (Route r : topRoutes) {
    float x1 = random(100, width - 100);
    float y1 = random(100, height - 100);
    float x2 = random(100, width - 100);
    float y2 = random(100, height - 100);

    line(x1, y1, x2, y2);
    
    fill(0, 150, 255);
    ellipse(x1, y1, 6, 6);
    ellipse(x2, y2, 6, 6);

    fill(0);
    text(r.origin, x1, y1 - 10);
    text(r.dest, x2, y2 - 10);
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

void calculateTopRoutes() {
  for (Flight f : flights) {
    String routeKey = f.origin + "-" + f.dest;
    routeCounts.put(routeKey, routeCounts.getOrDefault(routeKey, 0) + 1);
  }

  for (int i = 0; i < 50; i++) {
    String maxRoute = "";
    int maxCount = -1;

    for (String route : routeCounts.keySet()) {
      int count = routeCounts.get(route);
      if (count > maxCount && !containsRoute(topRoutes, route)) {
        maxRoute = route;
        maxCount = count;
      }
    }

    if (!maxRoute.equals("")) {
      String[] airports = split(maxRoute, "-");
      topRoutes.add(new Route(airports[0], airports[1], maxCount));
    }
  }
}

boolean containsRoute(ArrayList<Route> routes, String routeKey) {
  for (Route r : routes) {
    if ((r.origin + "-" + r.dest).equals(routeKey)) return true;
  }
  return false;
}

class Route {
  String origin, dest;
  int count;

  Route(String origin, String dest, int count) {
    this.origin = origin;
    this.dest = dest;
    this.count = count;
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
