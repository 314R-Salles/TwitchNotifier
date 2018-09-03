import http.requests.GetRequest;
import java.util.List;
import processing.serial.*; 


Serial myPort;
byte[] leds = new byte[5];

// All the objects declared on top of the program are global, and thus can be accessible in the entire program.

// Api url constants
final String STREAMS_BASE_URL = "https://api.twitch.tv/helix/streams?";
final String USERS_BASE_URL = "https://api.twitch.tv/helix/users?";
final String TWITCH_BASE_URL = "https://www.twitch.tv/";

// Twitch token: it has to be your own. This one is valid but won't work if too many people use it. 
final String TWITCH_TOKEN = "048o30kiq54suyv43jio7boaknv8e2";

// Refresh interval between two streams requests, in milliseconds.
final int WAIT_TIME = 10 * 1000; // could be faster, but requests slow the app (synchronous)

// Usernames array. Array, not List, because of the loadStrings method
String usernames[];

// streamerData contains only found streamers. 
List<Streamer> streamerData = new ArrayList();

// Vertical position of mouseCursor, updated in mouseMoved() and used in draw()
int selectorY = 0;

// True if the mouse cursor is above the streamers list, updated in mouseMoved() and used in draw()
boolean isMouseCursorOnStreamerName;

// Stores time, used to trigger the api requests
int startTime;

// Default bakground if streamer hasn't set an offline wallpaper
PImage notFound;


// Setup method. Run once when the program starts.
void setup() {


  // Start the connection with your arduino.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);


  startTime = millis();
  size(500, 500);
  background(255);

  usernames = loadStrings("usernames.txt");

  if (usernames == null) {
    println("Property file is missing");
    exit();
  }

  try {
    GetRequest get = new GetRequest(getUrlWithQueryParams(USERS_BASE_URL, "login"));
    get.addHeader("Client-ID", TWITCH_TOKEN);
    get.send();

    JSONArray jsonData = parseJSONObject(get.getContent()).getJSONArray("data");

    // loop on the size of the response instead of users.length in case some users were not found
    for (int index=0; index<jsonData.size(); index++) {
      Streamer streamer = new Streamer(jsonData.getJSONObject(index));
      streamerData.add(streamer);
    }
  }
  catch(Exception e) {
    println("Failed to get basic data of your streamers");
    exit();
  }

  notFound = loadImage("display404.jpg");
}

void draw() {
  background(0);
  stroke(255);
  strokeWeight(4);
  noFill();
  if (isMouseCursorOnStreamerName) {
    rect(0, 50*selectorY, 200, 50);
    try {
      displayProfilePicture(streamerData.get(selectorY).profileImage);
      if (streamerData.get(selectorY).isStreaming) {
        displayThumbnail(streamerData.get(selectorY).thumbnail);
      } else {
        displayOfflinePicture(streamerData.get(selectorY).offlineImage);
      }
    }

    catch(Exception e) {
      println("data hasn't been initialized yet, or user isn't streaming");
    }
  }

  // Update the streamerData
  if (clockTick()) {

    try {
      GetRequest get = new GetRequest(getUrlWithQueryParams(STREAMS_BASE_URL, "user_login"));
      get.addHeader("Client-ID", TWITCH_TOKEN);
      get.send();

      JSONObject json  = parseJSONObject(get.getContent());
      JSONArray data = json.getJSONArray("data");

      for (Streamer user : streamerData) {
        user.isStreaming = false;
        for (int index = 0; index<data.size(); index++) {
          if (data.getJSONObject(index).get("user_id").equals(user.userId)) {
            user.isStreaming = true;
            user.thumbnailUrl = data.getJSONObject(index).get("thumbnail_url").toString();
            user.setThumbnail(user.thumbnailUrl);
          }
        }
      }
      startTime = millis();
    }

    catch(Exception e) {
      println("Failed to get stream data for your streamers");
    }

    updateLeds();
  }

  // Streaming status display, with red/green lights.
  for (int index=0; index<streamerData.size(); index++) {
    strokeWeight(2); 

    if (streamerData.get(index).isStreaming) {
      leds[index] = 1;
      fill(255); 
      text( streamerData.get(index).displayName + " is streaming", 10, 50*index+30); 
      fill(0, 255, 0); 
      ellipse(175, 50*index+27, 10, 10);
    } else { 
      leds[index] = 0;
      fill(255); 
      text( streamerData.get(index).displayName + " is offline", 10, 50*index+30); 
      fill(255, 0, 0); 
      ellipse(175, 50*index+27, 10, 10);
    }
  }
}


void displayThumbnail(PImage thumbnail) {
  image(thumbnail, 12, 255);
}

// Display offlinePicture if available, or your default notFound image.
void displayOfflinePicture(PImage thumbnail) {
  if (thumbnail != null) image(thumbnail, 12, 255, 475, 240);
  else image(notFound, 12, 255, 475, 240);
}

void displayProfilePicture(PImage thumbnail) {
  image(thumbnail, 300, 75, 100, 100);
}

void mouseMoved() {
  if (mouseX > 0 && mouseX < 180 && mouseY>0 && mouseY<50*streamerData.size()) {
    selectorY = mouseY/50; 
    isMouseCursorOnStreamerName = true;
  } else {
    isMouseCursorOnStreamerName = false;
  }
}

// Open streamer channel in your default browser
void mousePressed() {
  if (isMouseCursorOnStreamerName) link(TWITCH_BASE_URL + streamerData.get(selectorY).username);
}

void serialEvent(Serial myPort) {
  int readValue = myPort.read();
  link(TWITCH_BASE_URL + streamerData.get(readValue).username);
}


// Produces a 'tick' every WAIT_TIME milliseconds
boolean clockTick() {
  return millis() - startTime > WAIT_TIME;
}


// Return the URL correctly formatted with queryParams.
String getUrlWithQueryParams(String url, String field) {
  for (String user : usernames) {
    url += field + "=" + user + "&";
  }
  return url;
}


void updateLeds() {
  myPort.write(leds);
}