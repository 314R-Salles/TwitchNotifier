byte inBuffer[5];
int previousState[5] = {0, 0, 0, 0, 0};

void setup() {
  Serial.begin(9600);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
}

void loop() {

  if (Serial.available()) {
    Serial.readBytes(inBuffer, 5);

    for (int i = 0; i < 5; i++) {
      digitalWrite(7 + i, inBuffer[i]);
    }
  }
  for (int i = 0; i < 5; i++) {
    if ( digitalRead(2 + i) != previousState[i]) {
      previousState[i] = 1 - previousState[i];
      if (previousState[i]) Serial.write(i);
    }
  }
}
