//主程序类（初始化，调用其他类的方法，处理用户输入并管理界面切换）
ArrayList<Flight> flights = new ArrayList<Flight>();
FlightDataManager flightDataManager = new FlightDataManager();
void setup() {
    size(400, 400); // 设置窗口大小
    background(255); // 设置背景颜色

    // 读取CSV文件
    flightDataManager.loadFlights("flights_full.csv");
    // 打印所有航班信息
    for (Flight flight : flightDataManager.flights) {
        flight.display();
    }
}

void draw() {
    // 空的draw函数，避免窗口闪烁
}



//数据表示类（存储航班信息，提供字段数据的访问方法，提供自身展示数据）
class Flight {
    String flDate; // 航班日期
    String mkCarrier; // 航空公司代码
    int mkCarrierFlNum; // 航班号
    String origin; // 起飞机场代码
    String dest; // 目的地机场代码
    int distance; // 航程距离

    // 构造函数
    Flight(String flDate, String mkCarrier, int mkCarrierFlNum, String origin, String dest, int distance) {
        this.flDate = flDate;
        this.mkCarrier = mkCarrier;
        this.mkCarrierFlNum = mkCarrierFlNum;
        this.origin = origin;
        this.dest = dest;
        this.distance = distance;
    }

    // 打印航班信息
    void display() {
        println("Flight Date: " + flDate);
        println("Carrier: " + mkCarrier);
        println("Flight Number: " + mkCarrierFlNum);
        println("Origin: " + origin);
        println("Destination: " + dest);
        println("Distance: " + distance + " miles");
        println("----------------------------");
    }
}

//数据管理类（加载数据到内存，实现航班数据查询，提供查询结果返回给主程序）
class FlightDataManager {
    ArrayList<Flight> flights = new ArrayList<Flight>();
    void loadFlights(String fileName) {        // 数据加载
        String[] lines = loadStrings(fileName);

        // 跳过标题行
        for (int i = 1; i < lines.length; i++) {
            String[] columns = split(lines[i], ',');
            if (columns.length >= 25) {
                try {
                    String flDate = columns[0];
                    String mkCarrier = columns[1];
                    int mkCarrierFlNum = Integer.parseInt(columns[2]);
                    String origin = columns[4];
                    String dest = columns[6];
                    int distance = Integer.parseInt(columns[24]);
                    flights.add(new Flight(flDate, mkCarrier, mkCarrierFlNum, origin, dest, distance));
                } catch (Exception e) {
                    println("Error processing line " + i + ": " + lines[i]);
                    println("Exception: " + e.getMessage());
                }
            } else {
                println("Line " + i + " has insufficient columns: " + columns.length);
                println("Data: " + lines[i]);
            }
        }
    }
    ArrayList<Flight> getFlightsByAirport(String airportCode) {  //返回指定机场的航班
        ArrayList<Flight> result = new ArrayList<Flight>();
        for (Flight flight : flights) {
            if (flight.origin.equals(airportCode) || flight.dest.equals(airportCode)) {
                result.add(flight);
            }
        }
        return result;
    }
    ArrayList<Flight> getFlightsByDateRange(String startDate, String endDate) {    //返回指定日期范围的航班
        ArrayList<Flight> result = new ArrayList<Flight>();
        for (Flight flight : flights) {
            if (flight.flDate.compareTo(startDate) >= 0 && flight.flDate.compareTo(endDate) <= 0) {
                result.add(flight);
            }
        }
        return result;
    }

    ArrayList<Flight> getFlightsSortedByDelay() {       //返回按延误排序的航班列表
        flights.sort((f1, f2) -> (f2.mkCarrierFlNum - f1.mkCarrierFlNum)); // 示例排序
        return flights;
    }
}


//用户界面类（绘制图形等可视化内容，响应用户交互例如点击和选择以及筛选）
class UIManager {
    void drawBarChart(ArrayList<Flight> data) {    // 绘制柱状图
      
    }
    void drawHeatmap(ArrayList<Flight> data) {    // 绘制热力图
      
    }
    
    void draw2DMap(ArrayList<Flight> data) {            // 绘制2D地图表示航线
      
    }
}

//工具类（提供静态方法用于日期格式转换，检测数据的有效性，处理异常情况等）
class Utils {
    static String formatDate(String date) {
        // 日期格式转换
        return date;
    }
    static boolean isValidData(String[] data) {
        // 检查数据的有效性
        return data.length >= 25;
    }
    static void handleException(Exception e) {
        // 处理异常情况
        println("Exception: " + e.getMessage());
    }
}
