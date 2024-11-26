import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["all", "checkbox"]

  toggleAll() {
    const checked = this.allTarget.checked
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
  }
}
