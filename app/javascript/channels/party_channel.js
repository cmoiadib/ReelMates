import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

consumer.subscriptions.create("PartyChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to PartyChannel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("Received data:", data)
  }
})
