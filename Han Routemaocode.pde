ArrayList<Route> topRoutes;
HashMap<String, PVector> airportLocs;

void setup() {
  size(1200, 600);
  topRoutes = new ArrayList<Route>();
  airportLocs = new HashMap<String, PVector>();

  loadAirportLocations();
  loadTopRoutes();

  smooth();
  noLoop();
}

void draw() {
  background(255);
  drawGrid();

  strokeWeight(1);
  fill(0);
  textSize(10);
  textAlign(CENTER, CENTER);

  for (String code : airportLocs.keySet()) {
    PVector loc = airportLocs.get(code);
    fill(30, 144, 255);
    ellipse(loc.x, loc.y, 8, 8);
    fill(0);
    text(code, loc.x, loc.y - 12);
  }

  for (Route r : topRoutes) {
    if (airportLocs.containsKey(r.origin) && airportLocs.containsKey(r.dest)) {
      PVector origin = airportLocs.get(r.origin);
      PVector dest = airportLocs.get(r.dest);

      noFill();
      stroke(0, 150, 200, 100);
      float midX = (origin.x + dest.x) / 2;
      float midY = (origin.y + dest.y) / 2 - dist(origin.x, origin.y, dest.x, dest.y) / 8;
      bezier(origin.x, origin.y, midX, midY, midX, midY, dest.x, dest.y);

      fill(255, 69, 0);
      text(r.count, midX, midY - 8);
    }
  }
}

void loadAirportLocations() {
  String[][] airports = {
    {"ATL","33.6407","-84.4277"},{"BOS","42.3656","-71.0096"},{"CLT","35.2140","-80.9431"},
    {"DCA","38.8512","-77.0402"},{"DEN","39.8561","-104.6737"},{"DFW","32.8998","-97.0403"},
    {"DTW","42.2124","-83.3534"},{"EWR","40.6895","-74.1745"},{"IAH","29.9902","-95.3368"},
    {"JFK","40.6413","-73.7781"},{"LAS","36.0840","-115.1537"},{"LAX","33.9416","-118.4085"},
    {"LGA","40.7769","-73.8740"},{"MCO","28.4312","-81.3081"},{"MIA","25.7959","-80.2870"},
    {"ORD","41.9742","-87.9073"},{"PHL","39.8744","-75.2424"},{"PHX","33.4342","-112.0116"},
    {"SEA","47.4502","-122.3088"},{"SFO","37.6213","-122.3790"}
  };

  for (String[] ap : airports) {
    addAirport(ap[0], float(ap[1]), float(ap[2]));
  }
}

void addAirport(String code, float lat, float lon) {
  float x = map(lon, -130, -65, 50, width - 50);
  float y = map(lat, 50, 25, 50, height - 50);
  airportLocs.put(code, new PVector(x, y));
}

void loadTopRoutes() {
  String[][] routes = {
    {"ATL","BOS","63"},{"ATL","CLT","77"},{"ATL","DCA","90"},{"ATL","DEN","72"},{"ATL","DFW","86"},
    {"ATL","DTW","73"},{"ATL","EWR","90"},{"ATL","IAH","77"},{"ATL","JFK","75"},{"ATL","LAS","76"},
    {"ATL","LAX","87"},{"ATL","LGA","122"},{"ATL","MCO","112"},{"ATL","MIA","107"},{"ATL","ORD","84"},
    {"ATL","PHL","81"},{"ATL","PHX","79"},{"ATL","SEA","75"},{"ATL","SFO","70"}
  };

  for (String[] r : routes) {
    topRoutes.add(new Route(r[0], r[1], int(r[2])));
  }
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

void drawGrid() {
  stroke(200);
  fill(0);
  for (int lon = -130; lon <= -65; lon += 5) {
    float x = map(lon, -130, -65, 50, width - 50);
    line(x, 50, x, height - 50);
    text(lon + "°", x, height - 35);
  }
  for (int lat = 25; lat <= 50; lat += 5) {
    float y = map(lat, 50, 25, 50, height - 50);
    line(50, y, width - 50, y);
    text(lat + "°", 35, y);
  }
}
