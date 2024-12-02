import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = {
    partyId: String
  }

  connect() {
    console.log("PartySubscription controller connected")
    this.channel = consumer.subscriptions.create(
      {
        channel: "PartyChannel",
        id: this.partyIdValue
      },
      {
        connected: () => {
          console.log("Connected to party channel", this.partyIdValue)
        },
        disconnected: () => {
          console.log("Disconnected from party channel")
        },
        received: (data) => {
          console.log("Received data:", data)
          if (data.action === 'game_started') {
            window.location.href = data.redirect_url
          }
        }
      }
    )
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  startGame(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute('href')

    fetch(url, {
      method: 'PUT',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
  }
}
