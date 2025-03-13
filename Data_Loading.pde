ArrayList<Flight> flights;
int rowsPerPage = 20;
int currentPage = 0;
int totalPages;

void setup() {
  size(2000, 800);
  flights = new ArrayList<Flight>();
  loadFlightData("flights2k.csv");
  fill(255);
  textSize(14);
  totalPages = flights.size() / rowsPerPage;
}

void draw() {
  background(0);
  int start = currentPage * rowsPerPage;
  int end = min(start + rowsPerPage, flights.size());

  for (int i = start; i < end; i++) {
    Flight flight = flights.get(i);
    String[] fields = flight.toArray();
    
    for (int e = 0; e < fields.length; e++) {
      text(fields[e], 10 + e * 150, 30 + (i - start) * 25);
    }
  }

  textSize(16);
  fill(255, 200, 0);
  text((currentPage + 1) + " page " + (totalPages + 1), 10, height - 20);
}

void keyPressed() {
  if (keyCode == DOWN) {
    currentPage = min(currentPage + 1, totalPages);
  } else if (keyCode == UP) {
    currentPage = max(currentPage - 1, 0);
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
      Flight flight = new Flight(cols);
      flights.add(flight);
    }
  }
}

class Flight {
  String date, airline, flightNum, origin, originCity, originState, dest, destCity, destState;
  int originWac, destWac, crsDepTime, depTime, crsArrTime, arrTime, cancelled, diverted, distance;
  
  Flight(String[] data) {
    date = data[0];
    airline = data[1];
    flightNum = data[2];
    origin = data[3];
    originCity = data[4];
    originState = data[5];
    originWac = int(data[6]);
    dest = data[7];
    destCity = data[8];
    destState = data[9];
    destWac = int(data[10]);
    crsDepTime = int(data[11]);
    depTime = int(data[12]);
    crsArrTime = int(data[13]);
    arrTime = int(data[14]);
    cancelled = int(data[15]);
    diverted = int(data[16]);
    distance = int(data[17]);
  }
  
  String[] toArray() {
    return new String[]{date, airline, flightNum, origin, originCity, originState, dest, destCity, destState, 
                        str(originWac), str(destWac), str(crsDepTime), str(depTime), 
                        str(crsArrTime), str(arrTime), str(cancelled), str(diverted), str(distance)};
  }
}
