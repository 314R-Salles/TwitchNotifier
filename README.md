# TwitchNotifier
## Project

Using the Twitch API to know if a list of users are streaming.

Displaying the streaming users in a desktop app with Processing.

## Documentation

#### Processing

Library managing http requests: https://github.com/runemadsen/HTTP-Requests-for-Processing

Your user list is saved in the data folder, in the usernames.txt file.

The current version doens't manage in-app modifications of the streamers list.
You have to edit the txt file manually.

The Twitch token:
For this app to work, you have to edit the code and fill the TWITCH_TOKEN field with your own valid token.
You can generate one for free on the Twitch dev website.
https://dev.twitch.tv/docs/authentication/#registration

Why can't you use mine? A single token without proper authentification can only send 30 requests per minute.
If too many apps use the same token, they'll receive warnings instead of useful data.
I leave a valid token in the code, so it can run, but that must be for a temporary use only.


##### How does the code work?

Processing runs on Java 1.6. It's a rather old version, so don't expect anything great.
Comments in the code describe the main parts.

On top of the code, there are imports. It is required to list all extra component you want to add in your program.
Then, we declare a set of variables. Being declared outside the setup or main methods, these variables are said "global".
They are accessible in the whole program. 

###### Setup

In the setup() block, we read the property file, to set values to these variables. 
We read streamers usernames from the txt file. 

Then we ask twitch to give us data about the loaded usernames.
We get many informations, like ids and the pictures the streamer uses: its profile picture, its offline picture.

Lastly, we load a specific picture from the data folder, that we will display when data is missing.
Some users don't set an offline picture, we'll display this 404 picture instead. (Taken from Jira)


The property file:
loadStrings is the method used to read the txt file with your streamers list.
It can't produce any kind of errors, even if the file is missing. It will only return null. 
If that's the case, we need to stop the program. Even if by any chance it would run, it would be completely useless without 
the initial data of your file. 

Exceptions:
If you check the setup() code, you'll notice an association of try and catch blocks surrounding the http request.
Indeed, accessing a network is usually a "dangerous" operation in a program.
What happen if you forgot to turn on your wifi? 

Java will produce "Exceptions". You can consider them as some big error messages. 

There are different kind of Exceptions, some are more critical than the others and may crash your program.
If an Exception occurs, you need to handle it.
That's what try/catch are for.
You TRY to execute a block of code. If everything is fine, you skip the catch block.

If something goes wrong, we say that "Java throws an Exception". In that case, you need to CATCH it. 
If you are not familiar with the different families of Exceptions, you can just Not specify the type of Exceptions you want to catch.
catch(Exception e) will catch (almost) everything. 
Usually developpers try to write code like this : catch(IOException e), or catch(NullPointerException e).
You can choose to write a catch block for every Exception you code might throw, meaning you can react in a different way for each of them.

If an Exception is thrown then we print a specific error message (in the console of the Processing IDE only, because there aren't any logs in the exported app).

If your property file was fine, the program entered the try block to execute the first Http request, but there may be some problems with your internet network. 
The request isn't sent correctly. Or, I don't know, Twitch failed to answer your request, or answered with data we didn't expected and the creation of objects of the Streamer Class failed.

I don't know what kind of Exception might be thrown here, so I'll catch everything. A method documentation usually tells you what kind of Exception it can throw.

Note : 
Try/catch blocks may be used to prevent your program from stopping. 
You encountered a problem, but you were prepared for it, so you managed to repair the damages, and you keep going.
Here, what would be the effects of the Exceptions?
If the Get request failed, the streamerData list is left empty, the app will fail later, or at least, won't do anything.

It's fatal for the program, so even if we handled the Exceptions, we have to terminate it.

###### Draw

The draw() block contains code that updates the streamers list and display the results.
There is a try/catch block around the get request, for the reasons detailed earlier. 

Remember the limitation of our token. We "only" have 30 requests a minute.
As we retrieve our data for all users in a single request, the number of valid usernames in your property file doesn't matter.

We could send a request every 2 seconds, but there isn't really a need for that many requests. 
Everytime we send a request, we update the state of our streamer list, and we also reload their thumbnail picture.
It has a cost, and this data is not a matter of life and death, so we can set the time interval to 10 seconds.

You can change it to anything, but that has to stay greater than 2 seconds.
The clockTick() method trigger the request according to the value you choose.

Then for every streamer, we display a red/green dot and the mention "is not streaming" or "is streaming".

###### Events

On the mouseMoved event, the program retrieve the coordinates of the cursor.
This data is used in the draw() to create a white rectangle around the corresponding user.
If your mouse is above a user, it will also display its thumbnail or offline picture and its 
profile picture.

On the mousePressed event, if the mouse is above an element of the streamers list, we use the selectorY value to get the corresponding streamer
in our data list. And then we use the link() function to open its Twitch channel in your browser.

