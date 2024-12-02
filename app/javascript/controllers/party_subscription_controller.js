import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = {
    partyId: String
  }

  connect() {
    this.channel = consumer.subscriptions.create(
      {
        channel: "PartyChannel",
        id: this.partyIdValue
      },
      {
        received: (data) => {
          console.log("Received data:", data)
          if (data.action === 'all_completed' || data.action === 'game_started') {
            console.log("Redirecting to:", data.redirect_url)
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
}
