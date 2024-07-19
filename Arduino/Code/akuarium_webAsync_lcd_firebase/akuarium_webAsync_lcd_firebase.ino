// --- TO DO LIST ---
// LCD Show Time List Alarm

// --- COMPLETED ---
// WiFi Profisioning
// SPIFF
// Get Data From DS18B20
// LCD Monitoring
// Servo Control
// NTP Time Zone
// Web Async Get Temp DS18B20
// Web Async Send Button Feed Manual and Get Feedback
// LCD Show Status Feed
// Web Async Send and Get List Time Alarm
// Open Servo When the Alarm Occurs
// Firebase RTDB Integration
// Web Interfaces
// Send Alarm From Web Async to Firebase
// Get and Update Alarm from Firebase
// Get and Reset Servo Status


// ----- Library -----
// WiFi Manager
#include <WiFiManager.h> 
#include "WiFi.h"
// Web Async
#include "ESPAsyncWebServer.h"
// SPIFF
#include "SPIFFS.h"
// DS18B20
#include <OneWire.h>
#include <DallasTemperature.h>
// LCD I2C
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
// Servo
#include <ESP32Servo.h>
// NTP for Timer
#include <Time.h>
// Firebase
#include <FirebaseESP32.h>

// ----- Variabel dan pendefinisian objek -----
// Firebase url RTDB dan auth key
#define USER_EMAIL "esp32_firebase@aquabase.com"
#define USER_PASSWORD "aquabase"
#define FB_RTDB_URL "https://firesp32-e32221274-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define FB_AUTH_KEY "AIzaSyD07DTu4bgv6SWd6a-_YZeNFlRyTcPvhXM"
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Mendefinisikan ds18b20
const int pin_sensor = 4;             // Menggunakan pin 4 untuk data ds18b20
OneWire oneWire(pin_sensor);          // Setup onewire untuk berkomunikasi terhadap data sensor
DallasTemperature DS18B20(&oneWire);  // Memberikan onewire kepada dallas temperature sensor

// Set address sesuai address i2c-nya, jumlah baris dan kolom
LiquidCrystal_I2C lcd(0x27,16,2);

// Indikator led wifi
const int led_wifi = 27;
String ledState_wifi;

// Servo
Servo katupPakan;
const int pinServo = 13;                // menggunakan pin 13 untuk data servo
bool beriPakan = false;                 // untuk menghentikan pemberian pakan
unsigned long currentMillisPakan = 0;
unsigned long intervalPakan = 1500;     // waktu katup terbuka (1.5 sekon)

// Membuat AsyncWebServer objek pada port 80
AsyncWebServer server(80);

// Millis untuk mengirim data dengan interval 2 detik pada web
unsigned long currentMillisDisplay = 0;
unsigned long intervalDisplay = 2000;

// Millis untuk mengirim data dengan interval 10 detik pada firebase
unsigned long currentMillisFirebase = 0;
unsigned long intervalFirebase = 10000;
String timestampNTP = "0000-00-00 00:00:00";

// NTP Server
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 25200;         // Timezone WIB Indonesia
const int daylightOffset_sec = 0;

// Timer
String timeNTP = "00:00";
String timer[3] = {"06:00", "14:00", "22:00"};  // Data Timer default
int arrSize = sizeof(timer) / sizeof(timer[0]);
int defArrSize = 0;
bool openOnce = false;                          // Buka katup sekali pada saat waktu pakan
String lastTimer = "00:00";                     // variabel bantu untuk membuka kembali katup

// Kontrol dari Firebase
String timerFirebase;

// ----- Fungsi -----
// Fungsi membaca data suhu DS18B20
String readDS18B20Temp() {
  DS18B20.requestTemperatures();              // Mengirim perintah untuk mendapatkan nilai suhu
  float temp = DS18B20.getTempCByIndex(0);    // Membaca suhu dalam celcius

  if(temp == -127.00) {
    Serial.println("Failed to read from DS18B20 sensor");
    return "--";
  } else {
    // Serial.print(temp);
    return String(temp);
  }
}

// Fungsi Buka Katup
void bukaKatup() {
  currentMillisPakan = millis();
  katupPakan.attach(pinServo);
  katupPakan.write(130);
  delay(500);
  katupPakan.write(55);
  delay(500);
  beriPakan = true;
}

// Fungsi Tutup Katup
void tutupKatup() {
  katupPakan.write(95);
  delay(50);
  katupPakan.detach();
  beriPakan = false;
  printAllLCD(4, 2, "Menutup", "Katup Pakan");
  Serial.println("Tutup Katup Pakan");
}

// Fungsi untuk menampilkan data ke semua kolom LCD
void printAllLCD(int xColZero, int xColOne, String ColZero, String ColOne) {
  lcd.clear();
  lcd.setCursor(xColZero,0);
  lcd.print(ColZero);
  lcd.setCursor(xColOne,1);
  lcd.print(ColOne);
}

// Fungsi menampilkan waktu lokal WIB
void printLocalTime(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  char fullHour[6];
  strftime(fullHour, 6, "%R", &timeinfo);
  char fullDate[11];
  strftime(fullDate, 11, "%F", &timeinfo);
  char fullTime[9];
  strftime(fullTime, 9, "%T", &timeinfo);
  
  timeNTP = String(fullHour);
  timestampNTP = String(fullDate) + " " + String(fullTime);
  
  Serial.print("Waktu saat ini: ");
  Serial.println(timestampNTP);
}

// Fungsi merubah array timer ke string
String arrTimerToStr(String arrayString[], int panjangArray, char pemisah) {
  String hasil = "";

  for (int i = 0; i < panjangArray; i++) {
    hasil += arrayString[i];
    // Tambahkan pemisah kecuali untuk elemen terakhir
    if (i < panjangArray - 1) {
      hasil += pemisah;
    }
  }
  return hasil;
}

// Fungsi merubah string timer ke array
void strTimerToArr(String kalimat, String arrayString[], int &panjangArray, char pemisah) {
  int index = 0;  // Indeks array
  int posisiAwal = 0;
  
  for (int i = 0; i < kalimat.length(); i++) {
    if (kalimat.charAt(i) == pemisah) {
      arrayString[index] = kalimat.substring(posisiAwal, i);
      posisiAwal = i + 1;
      index++;
    }
  }
  // Menangani kata terakhir (tanpa pemisah di akhir)
  arrayString[index] = kalimat.substring(posisiAwal);
  index++;
  // Mengupdate panjang array
  panjangArray = index;
}

// Fungsi SPIFF read file
String readFile(fs::FS &fs, const char * path){
  Serial.printf("Reading file: %s ", path);
  File file = fs.open(path, "r");
  if(!file || file.isDirectory()){
    Serial.println("- empty file or failed to open file");
    return String();
  }
  Serial.print("- file value: ");
  String fileContent;
  while(file.available()){
    fileContent+=String((char)file.read());
  }
  Serial.println(fileContent);
  return fileContent;
}

// Fungsi SPIFF write file
void writeFile(fs::FS &fs, const char * path, const char * message){
  Serial.printf("Writing file: %s ", path);
  File file = fs.open(path, "w");
  if(!file){
    Serial.println("- failed to open file for writing");
    return;
  }
  if(file.print(message)){
    Serial.println("- file written");
  } else {
    Serial.println("- write failed");
  }
}

// Fungsi mengirim data saat user mengakses web
String processor(const String& var){
  // Serial.println(var);
  if(var == "TEMP"){
    return readDS18B20Temp();
  }
  if(var == "TIMER"){
    Serial.print("Mengirim: ");
    Serial.println(arrTimerToStr(timer, arrSize, ';'));
    return readFile(SPIFFS, "/dataTimer.txt");
  }
  return String();
}

void setup(){
  // Inisialisasi serial monitor
  Serial.begin(115200);

  // Inisialisasi pin led
  pinMode(led_wifi, OUTPUT);
  
  // Inisialisasi ds18b20
  DS18B20.begin();

  // Inisialisasi servo
  katupPakan.attach(pinServo);
  tutupKatup();

  // Memulai dan membersihkan lcd serta menyalakan lampu backlight
  lcd.init();
  lcd.clear();
  lcd.backlight();
  lcd.setCursor(0,0);
  lcd.print("Connect to WiFi");
 
  // inisialisasi wifimanager 
  WiFiManager wm;  
  // wm.resetSettings();  // for reset 
  bool res;
  res = wm.autoConnect("Kelompok_1","password"); // password protected ap
  if(!res) {
    Serial.println("Failed to connect");
    // ESP.restart();   // for reset
    // delay(2000);
  } 
  else {
    // ESP32 terkoneksi dengan wifi   
    Serial.print("Wifi Connected : ");
    Serial.println(WiFi.localIP());
    digitalWrite(led_wifi, HIGH);

    // Memberikan informasi alamat ip address web async ke user
    printAllLCD(0, 0, "Akses IP berikut", WiFi.localIP().toString());
  }

  // Inisialisasi NTP
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  printLocalTime();

  // Inisialisasi firebase
  config.database_url = FB_RTDB_URL;
  config.api_key = FB_AUTH_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  Firebase.begin(&config, &auth);                             // Memulai koneksi RTDB
  Serial.println("Berhasil terintegrasi dengan Firebase");

  // Inisialisasi SPIFF
  if(!SPIFFS.begin(true)){
    Serial.println("An Error has occurred while mounting SPIFFS");
    return;
  }

  // Mengecek apakah Data Timer sudah tersedia atau belum
  File file = SPIFFS.open("/dataTimer.txt", "r");
  if(!file || file.isDirectory()){
    Serial.println("Memasukkan Data Timer default pada SPIFF!");
    writeFile(SPIFFS, "/dataTimer.txt", arrTimerToStr(timer, arrSize, ';').c_str());
  } else {
    Serial.println("Data Timer sudah Tersedia pada SPIFF");
    strTimerToArr(readFile(SPIFFS, "/dataTimer.txt"), timer, defArrSize, ';');
    timerFirebase = readFile(SPIFFS, "/dataTimer.txt");
  }
  
  // Route untuk root / web page
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(SPIFFS, "/index.html", String(), false, processor);
  });
  // Route untuk load css file
  server.on("/style.css", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(SPIFFS, "/style.css", "text/css");
  });

  // Web otomatis memperbarui data dengan delay 5 detik sesuai interval pada fungsi javascript
  server.on("/temperature", HTTP_GET, [](AsyncWebServerRequest *request){
    Serial.println("Web Async Update DS18B20 Temperature!");
    request->send(200, "text/plain", readDS18B20Temp().c_str());
  });

  // ESP32 menerima dan mengupdate data waktu dari web
  server.on("/timer_pakan", HTTP_GET, [](AsyncWebServerRequest *request){
    printAllLCD(1, 2, "Memperbaharui", "Waktu Timer");
    String getTimer;
    if (request->hasParam("timer")) {
      getTimer = request->getParam("timer")->value();
      Serial.print("Menerima: ");
      Serial.println(getTimer);
    }
    // Update Timer pada SPIFFs
    writeFile(SPIFFS, "/dataTimer.txt", getTimer.c_str());
    // Mengirim data Alarm ke Firebase
    Serial.printf("Mengirim data Alarm ke Firebase... %s\n", Firebase.setString(fbdo, "/control/alarm", getTimer) ? "OK" : fbdo.errorReason().c_str());
    strTimerToArr(getTimer, timer, defArrSize, ';');
    request->send(200, "text/plain", "Berhasil Memperbaharui Timer Pakan Otomatis");
  });

  // ESP32 membuka katup manual dari web
  server.on("/buka_katup", HTTP_GET, [](AsyncWebServerRequest *request){
    printAllLCD(3, 5, "Buka Katup", "Manual");
    bukaKatup();
    Serial.println("Buka Katup Manual");
    request->send(200, "text/plain", "Berhasil Memberi Pakan Secara Manual");
  });

  // Inisialisasi server
  server.begin();
}

void loop(){
  // Menutup katup otomatis berdasarkan interval
  if (beriPakan && (millis() - currentMillisPakan >= intervalPakan)) {
    tutupKatup();
  }
  
  // Update display berdasarkan interval
  if (millis() - currentMillisDisplay >= intervalDisplay) {
    printLocalTime();     // Menampilkan waktu saat ini (WIB)
    
    // Mengambil data fungsi dan mengubah ke bentuk float
    float temp = readDS18B20Temp().toFloat();

    // Buka katup otomatis berdasarkan timer
    if ((timeNTP == timer[0] || timeNTP == timer[1] || timeNTP == timer[2]) && !openOnce) {
      printAllLCD(3, 4, "Buka Katup", "Otomatis");
      bukaKatup();
      Serial.println("Buka Katup Otomatis");
      openOnce = true;
      lastTimer = timeNTP;
    }

    // Hanya membuka katup sekali saat waktunya tiba
    if (lastTimer != timeNTP) {
      openOnce = false;
    }

    // Menampikan display ke LCD
    if (!beriPakan) {
      // Menampilkan ke display
      Serial.print("Temp DS18B20: ");
      Serial.print(temp);
      Serial.println("°C");
      
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("Temp: ");lcd.print(temp);lcd.print((char)223);lcd.print("C");
      lcd.setCursor(0,1);
      lcd.print("Time: ");lcd.print(timeNTP);lcd.print(" WIB");
    }
    
    // Update waktu display millis terbaru
    currentMillisDisplay = millis();
  }

  // Mengirim data ke Firebase berdasarkan interval
  if (Firebase.ready() && (millis() - currentMillisFirebase >= intervalFirebase)) {
    // Mengambil data Alarm dari Firebase
    if (Firebase.getString(fbdo, "/control/alarm")) {
      String getTimerFirebase = fbdo.stringData();
      Serial.print("Get data Alarm Firebase: ");
      Serial.println(getTimerFirebase);
      if (getTimerFirebase != timerFirebase) {
        // Mengupdate Timer pada SPIFFs
        writeFile(SPIFFS, "/dataTimer.txt", getTimerFirebase.c_str());
        strTimerToArr(getTimerFirebase, timer, defArrSize, ';');
      }
      timerFirebase = getTimerFirebase;
    }

    // Mengambil data Katup dari Firebase
    if (Firebase.getString(fbdo, "/control/valve")) {
      String getKatupFirebase = fbdo.stringData();
      Serial.print("Get data Katup Firebase: ");
      Serial.println(getKatupFirebase);
      if (getKatupFirebase != "OFF") {
        printAllLCD(3, 5, "Buka Katup", "Manual");
        bukaKatup();
        Serial.println("Buka Katup Manual");
        // mengirim data katup ke RTDB
        Serial.printf("Mengirim data Katup ke Firebase... %s\n", Firebase.setString(fbdo, "/control/valve", "OFF") ? "OK" : fbdo.errorReason().c_str());
      }
    }
    
    // Mengambil data fungsi dan mengubah ke bentuk float
    float temp = readDS18B20Temp().toFloat();

    // path tujuan data suhu
    String path = "/temperature/";
    path += timestampNTP;
    
    // mengirim data Suhu ke RTDB
    Serial.printf("Mengirim data Suhu ke Firebase... %s\n", Firebase.setFloat(fbdo, path, temp) ? "OK" : fbdo.errorReason().c_str());

    // Update waktu firebase millis terbaru
    currentMillisFirebase = millis();
  }
}
