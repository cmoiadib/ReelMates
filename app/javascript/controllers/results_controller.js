import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

export default class extends Controller {
  static targets = ["splash", "content"]
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
          if (data.action === 'all_completed') {
            this.splashTarget.classList.add("d-none")

            const loadingController = this.application.getControllerForElementAndIdentifier(
              this.element,
              'loading'
            )

            if (loadingController) {
              loadingController.startLoading()
            } else {
              console.error("Loading controller not found")
              this.contentTarget.classList.remove('d-none')
            }
          }
        }
      }
    )

    this.checkCompletionStatus()
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  checkCompletionStatus() {
    fetch(`/parties/${this.partyIdValue}/check_completion`)
      .then(response => response.json())
      .then(data => {
        if (!data.all_completed) {
          setTimeout(() => this.checkCompletionStatus(), 2000)
        }
      })
  }
}
