import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  select(event) {
    const avatarName = event.currentTarget.dataset.avatarName
    this.inputTarget.value = avatarName

    // Optional: Add visual feedback for selection
    document.querySelectorAll('.avatar-option').forEach(img => {
      img.classList.remove('selected')
    })
    event.currentTarget.classList.add('selected')

    console.log('Selected avatar:', avatarName)
  }
}
