import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  async checkAvailability() {
    const username = this.inputTarget.value

    const response = await fetch(`/check_username_availability?username=${username}`)
    const data = await response.json()

    if (!data.available) {
      this.inputTarget.setCustomValidity("Ce pseudo est déjà utilisé dans cette partie")
    } else {
      this.inputTarget.setCustomValidity("")
    }
  }
} 
