# Zoom Pin-Watcher

### Requirements
Python 3.8.0 / Scapy 2.5.0

### Usage

While running a Zoom meeting

```bash
$ python3 ./pinwatcher.py

Options
    -i Interface name (default=eth0)
```

The script would automatically detect the UDP connection for Zoom Video

---

**Who's Watching You?**
* Infers the viewers of your video and their video quality
* with the received Type32 messages

**Who You're Watching**
* Shows the SSRCs of the videos displayed on your Zoom screen
* Use it to match the SSRC with the actual participant