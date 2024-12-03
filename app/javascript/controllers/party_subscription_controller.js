import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

export default class extends Controller {
  static targets = ["content"]
  static values = { partyId: String }

  connect() {
    this.channel = consumer.subscriptions.create(
      { channel: "PartyChannel", id: this.partyIdValue },
      {
        received: data => {
          if (data.action === "game_started") {
            document.querySelector('.loading-screen').classList.remove('d-none');
            document.querySelector('[data-party-subscription-target="content"]').classList.add('d-none');
            setTimeout(() => {
              window.location.href = `/parties/${this.partyIdValue}/swipes`;
            }, 2000);
          } else if (data.action === "all_completed") {
            document.getElementById('generating-screen').classList.remove('d-none');
            document.getElementById('waiting-screen').classList.add('d-none');
            document.getElementById('swiper-container').classList.add('d-none');
            document.querySelector('.swiper-tinder-buttons').classList.add('d-none');

            setTimeout(() => {
              window.location.href = data.redirect_url;
            }, 2000);
          }
        }
      }
    )
  }

  showLoading() {
    document.querySelector('.loading-screen').classList.remove('d-none');
    document.querySelector('[data-party-subscription-target="content"]').classList.add('d-none');
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }
}
