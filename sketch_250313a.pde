import processing.data.*;

Table table;
int currentView = 0;

void setup() {
  size(1000, 650); // 设置窗口大小
  textAlign(CENTER);
  table = loadTable("flights100k.csv", "header"); // 加载数据表（如果需要）
}

void draw() {
  background(240);
  
  // 这里是添加图像的地方
  drawCurrentView(); // 根据 currentView 显示对应的可视化图表
  
  drawButtons(); // 绘制底部按钮
}

// 根据 currentView 显示相应的可视化图表
void drawCurrentView() {
  if (currentView == 0) {
    drawAirportFlightComparison(); // 机场航班数量对比
  } else if (currentView == 1) {
    drawAirlineDelayComparison(); // 航空公司延迟对比
  } else if (currentView == 2) {
    drawDailyFlightTrend(); // 每日航班量趋势
  } else if (currentView == 3) {
    drawFlightCancellationDiversion(); // 航班取消或改道统计
  } else if (currentView == 4) {
    drawFlightDistanceDistribution(); // 航班飞行距离分布
  }
}

// 绘制底部按钮
void drawButtons() {
  int buttonWidth = width / 5;
  int buttonHeight = 50;
  for (int i = 0; i < 5; i++) {
    if (i == currentView) {
      fill(50, 150, 250); // 选中的按钮高亮
    } else {
      fill(200);
    }
    rect(i * buttonWidth, height - buttonHeight, buttonWidth, buttonHeight);
    
    fill(0);
    textSize(14);
    String[] labels = {"Airport Flights", "Airline Delays", "Daily Flights", "Cancellations", "Flight Distance"};
    text(labels[i], i * buttonWidth + buttonWidth / 2, height - buttonHeight / 2);
  }
}

// 处理鼠标点击事件，点击按钮切换视图
void mousePressed() {
  int buttonWidth = width / 5;
  int buttonHeight = 50;
  if (mouseY > height - buttonHeight) {
    currentView = mouseX / buttonWidth; // 计算点击的是哪个按钮
  }
}

// 下面是不同的可视化函数，需要在这里添加具体的绘图代码
void drawAirportFlightComparison() {
  // 在这里添加机场航班数量对比的可视化代码
}

void drawAirlineDelayComparison() {
  // 在这里添加航空公司延迟对比的可视化代码
}

void drawDailyFlightTrend() {
  // 在这里添加每日航班量趋势的可视化代码
}

void drawFlightCancellationDiversion() {
  // 在这里添加航班取消或改道统计的可视化代码
}

void drawFlightDistanceDistribution() {
  // 在这里添加航班飞行距离分布的可视化代码
}
