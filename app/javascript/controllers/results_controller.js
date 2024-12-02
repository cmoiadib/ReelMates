import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["splash", "content"]
  static values = {
    partyId: String
  }

  connect() {
    console.log("Results controller connected!")
    this.checkCompletionStatus()
  }

  checkCompletionStatus() {
    fetch(`/parties/${this.partyIdValue}/check_completion`)
      .then(response => response.json())
      .then(data => {
        if (data.all_completed) {
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
        } else {
          setTimeout(() => this.checkCompletionStatus(), 2000)
        }
      })
  }
}
