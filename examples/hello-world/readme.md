#### How to test the WebSocket interface
Once the server has been build & started, you can test the WebSocket connection by opening `http://localhost:3000` in your favorite browser and typing the following commands into the developer console:
```javascript
    var socket = new WebSocket("ws://localhost:3000")

    socket.onmessage = console.log

    socket.send("hi")

    socket.close()
```
The server code will print some output in the terminal as response to events in the server logic.