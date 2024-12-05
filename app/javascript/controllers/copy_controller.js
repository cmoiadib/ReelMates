import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "value", "box"]

  copy(event) {
    // Get the text to copy (either from value target or box content)
    const textToCopy = this.valueTarget?.value || this.boxTarget?.textContent;

    navigator.clipboard.writeText(textToCopy).then(() => {
      alert("Copied to clipboard!");
    });

    // Handle button feedback if button exists
    if (this.hasButtonTarget) {
      this.buttonTarget.innerText = "Copied!";
      this.buttonTarget.setAttribute("disabled", "");
    }
  }
}
