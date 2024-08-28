# scrypted without Scrypted NVR (your frigate is recording)

Big Note: I'm not using Scrypted NVR. I'm using Frigate and MQTT to control my cameras.
Scrypted is my HKSV rebroadcaster.

When using MQTT and Frigate it's possible to setup HKSV (HomeKit Security Video).

With an already working setup of Frigate, all you need to do is rebroadcast the video stream to Scrypted and use a few things.

# Installation

1. Install scrypted
2. Install the plugins
    1. `mqtt plugin`
    2. `rtsp plugin`
    3. `homekit plugin`
    4. If you're using coral for detection, you'll also need `dummy switch plugin` to attach a switch to your camera

## MQTT Plugin config

1. Click providing things -> Add New
2. enter 

```javascript
mqtt.subscribe({
    // this example expects the device to publish either ON or OFF text values
    // to the mqtt endpoint.
    'frigate/<camera>/motion': value => {
        return device.motionDetected = value.text === 'ON';
    },
});

mqtt.handleTypes(ScryptedInterface.MotionSensor);
```

where camera is the value you have set in frigate.

In the subscription URL, if you're using k8s and inside the same namespace:

* mqtt://mosquitto.home.svc/
* user: <your user>
* password: <your user password>

### Home Assistant Testing

1. Go to your MQTT Integration and click `Configure`
2. in the `Publish a packet` section enter: <your-frigate-topic|default is frigate>/<camera name from frigate>/motion
3. in `Payload` enter `ON` then press `PUBLISH`
4. then in `Payload` enter `OFF` then press `PUBLISH`

## RTSP / HomeKit configuration

Follow the guides provided by Scrypted developer