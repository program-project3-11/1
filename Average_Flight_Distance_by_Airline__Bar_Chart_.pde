import processing.data.*;  

Table table;
HashMap<String, Float> airlineDistances;
HashMap<String, Integer> airlineCounts;

void setup() {
  size(1000, 600);
  background(240);
  textAlign(CENTER);
  
  table = loadTable("flights100k.csv", "header"); 
  airlineDistances = new HashMap<String, Float>();
  airlineCounts = new HashMap<String, Integer>();

  // Process data
  for (TableRow row : table.rows()) {
    String airline = row.getString("MKT_CARRIER");
    float distance = row.getFloat("DISTANCE");

    if (!airlineDistances.containsKey(airline)) {
      airlineDistances.put(airline, distance);
      airlineCounts.put(airline, 1);
    } else {
      airlineDistances.put(airline, airlineDistances.get(airline) + distance);
      airlineCounts.put(airline, airlineCounts.get(airline) + 1);
    }
  }
  
  // Compute average distances
  for (String key : airlineDistances.keySet()) {
    airlineDistances.put(key, airlineDistances.get(key) / airlineCounts.get(key));
  }
  
  drawBarChart();
}

void drawBarChart() {
  background(240);
  int numAirlines = airlineDistances.size();
  float barWidth = width / numAirlines;
  int index = 0;

  for (String airline : airlineDistances.keySet()) {
    float avgDistance = airlineDistances.get(airline);
    float barHeight = map(avgDistance, 0, 3000, 0, height - 100);  // Scale height

    fill(100, 150, 255);
    rect(index * barWidth + 20, height - barHeight - 50, barWidth - 10, barHeight);
    
    fill(0);
    textSize(12);
    text(airline, index * barWidth + barWidth / 2, height - 30);
    
    index++;
  }
  
  // Title
  fill(0);
  textSize(20);
  text("Average Flight Distance by Airline", width / 2, 30);
}
