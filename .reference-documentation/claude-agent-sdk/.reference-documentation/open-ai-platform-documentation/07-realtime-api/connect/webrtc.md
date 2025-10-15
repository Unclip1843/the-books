# OpenAI Platform - WebRTC Connection

**Source:** https://platform.openai.com/docs/guides/realtime/webrtc
**Fetched:** 2025-10-11

## Overview

Connect to Realtime API using WebRTC for browser-based applications.

---

## Setup

```javascript
// Initialize WebRTC connection
const pc = new RTCPeerConnection();

// Get ephemeral token
const tokenResponse = await fetch('/session');
const data = await tokenResponse.json();
const EPHEMERAL_KEY = data.client_secret.value;

// Add audio track
const ms = await navigator.mediaDevices.getUserMedia({ audio: true });
pc.addTrack(ms.getTracks()[0]);

// Create and set local description
const offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// Connect to OpenAI
const baseUrl = "https://api.openai.com/v1/realtime";
const model = "gpt-4o-realtime-preview-2024-12-17";

const sdpResponse = await fetch(`${baseUrl}?model=${model}`, {
    method: "POST",
    body: offer.sdp,
    headers: {
        Authorization: `Bearer ${EPHEMERAL_KEY}`,
        "Content-Type": "application/sdp"
    },
});

const answer = {
    type: "answer",
    sdp: await sdpResponse.text(),
};
await pc.setRemoteDescription(answer);
```

---

**Source:** https://platform.openai.com/docs/guides/realtime/webrtc
