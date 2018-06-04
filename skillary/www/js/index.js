/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function () {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function () {
        // app.receivedEvent('deviceready');
        document.getElementById("captureBtn").onclick = app.openCaptureScreen;
        document.getElementById("photoBtn").onclick = app.openPhotoScreen;
    },
    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    },

    openCaptureScreen: function() {      
        var win = function(d) {
            console.log("CaptureScreen Opened!");
        };
        var fail = function(e) {
                 console.log(e)
        }
        var capture = "30"
        var text = "test"
        cordova.exec(win, fail, "SKCapturePlugin", "openCaptureScreen", [capture, text]);
    },

    openPhotoScreen: function() {
        var win = function(d) {
            console.log("CaptureScreen Opened!");
        };
        var fail = function(e) {
            console.log(e)
        }
        var count = "3"
        cordova.exec(win, fail, "SKCapturePlugin", "openPhotoScreen", [count]);
    },

    finishCapturingScreen: function (path, duration) {
        var label = document.getElementById("captureLbl");
        label.value = "Capture result: " + path + " " + duration;
        console.log("Capturing finished! " + path + " " + duration);
    },

    finishAuthenticationWithPhoto: function (photos) {
        var label = document.getElementById("captureLbl");
        label.value = "Capture result: Finished Capturing" + photos;
        console.log("Capturing finished!" + photos);
    }
    
};

app.initialize();
