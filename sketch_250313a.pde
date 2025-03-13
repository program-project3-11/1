String[] flightData;    

int rowsPerPage = 20;    
int currentPage = 0;
int totalPages;         

void setup() {
  size(2000, 800);                       
  flightData = loadStrings("flights2k.csv"); 
  fill(255);                              
  textSize(14);                           

  totalPages = flightData.length / rowsPerPage;  
}

void draw() {
  background(0);                         
  
 
  int start = currentPage * rowsPerPage; 
  int end = min(start + rowsPerPage, flightData.length);
  
  
  for (int i = start; i < end; i++) {
    String[] fields = split(flightData[i], ',');
    
    for (int e = 0; e < fields.length; e++) {
      text(fields[e], 10 + e * 150, 30 + (i - start) * 25);
    }
  }
  
  
  textSize(16);
  fill(255, 200, 0);
  text( (currentPage + 1) + " page " + (totalPages + 1) , 10, height - 20);
}


void keyPressed() {
  if (keyCode == DOWN) {
    currentPage = min(currentPage + 1, totalPages);
  } else if (keyCode == UP) {
    currentPage = max(currentPage - 1, 0); 
  }
}
