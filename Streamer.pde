/*
Streamer Class

  username, actually the String used to reach the channel.
  id, because the streams request answers with id, not username.
  isStreaming, boolean.
 
  PImage: profile image, stream thumbnail, offline thumbnail.
 
 Override of toString for debugging purposes.
 */

public class Streamer {

  public String username;

  public String displayName;

  public String userId;

  public boolean isStreaming;

  // set is streamer is online
  public String thumbnailUrl;
  public PImage thumbnail;

  // set in setup(), whether user online or not.
  public PImage profileImage;
  public PImage offlineImage;

  public Streamer(JSONObject json) {
    this.userId = json.get("id").toString();
    this.username = json.get("login").toString();
    this.displayName = json.get("display_name").toString();
    this.profileImage = loadImage(json.get("profile_image_url").toString());
    this.offlineImage = loadImage(json.get("offline_image_url").toString());
  }
  
  public void setThumbnail(String url) {
  url = url.replace("{width}", "475").replace("{height}", "240"); 
  thumbnail = loadImage(url);
}

  public String toString() {
    return "username: "+username +", userId: "+userId +", isStreaming:" + isStreaming ;
  }
}