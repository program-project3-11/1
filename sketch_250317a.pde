int currentView = 0; // 当前视图索引

void setup() {
  size(1000, 650); // 设置窗口大小
  textAlign(CENTER, CENTER);
}

void draw() {
  background(240);

  drawCurrentView(); // 根据 currentView 显示对应的界面内容
  drawButtons(); // 绘制底部按钮
}

// ✅ 这里添加绘制图像的代码
void drawCurrentView() {
  textSize(32);
  fill(50);
  
  if (currentView == 0) {
    text("Airport Flights", width / 2, height / 2 - 200);
    drawBarChart();  // 👉 在这里绘制柱状图
  } else if (currentView == 1) {
    text("Airline Delays", width / 2, height / 2 - 200);
    drawHeatmap();   // 👉 在这里绘制热力图
  } else if (currentView == 2) {
    text("Air Route", width / 2, height / 2 - 200);
    drawFlightRoutes(); // 👉 在这里绘制航线
  }
}

// ✅ 按钮绘制
void drawButtons() {
  int buttonWidth = width / 3;
  int buttonHeight = 50;
  String[] labels = {"Airport Flights", "Airline Delays", "Air Route"};

  for (int i = 0; i < 3; i++) {
    if (i == currentView) {
      fill(50, 150, 250); // 选中的按钮高亮
    } else {
      fill(200);
    }
    rect(i * buttonWidth, height - buttonHeight, buttonWidth, buttonHeight);

    fill(0);
    textSize(18);
    text(labels[i], i * buttonWidth + buttonWidth / 2, height - buttonHeight / 2);
  }
}

// ✅ 处理鼠标点击事件
void mousePressed() {
  int buttonWidth = width / 3;
  int buttonHeight = 50;
  if (mouseY > height - buttonHeight) {
    currentView = mouseX / buttonWidth; // 计算点击的是哪个按钮
  }
}

// ==============================
// ✅ 这里添加绘制代码
// ==============================

// 📊 绘制柱状图（航班数量）
void drawBarChart() {
  // ✅ 在这里绘制柱状图
  fill(100);
  textSize(20);
  
}

// 🔥 绘制热力图（航班延误）
void drawHeatmap() {
  // ✅ 在这里绘制热力图
  fill(100);
  textSize(20);
 
}

// 🛫 绘制 2D 航线图
void drawFlightRoutes() {
  // ✅ 在这里绘制航班线路图
  fill(100);
  textSize(20);

}
