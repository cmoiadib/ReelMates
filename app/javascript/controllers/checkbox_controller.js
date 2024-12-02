import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["all", "checkbox"]

  connect() {
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', () => {
        checkbox.parentElement.classList.toggle('selected', checkbox.checked);
      });
    });
  }
  // toggleAll() {
  //   const checked = this.allTarget.checked;
  //   this.checkboxTargets.forEach(checkbox => {
  //     checkbox.checked = checked;
  //     checkbox.parentElement.classList.toggle('selected', checked);
  //   });
  // }
}
