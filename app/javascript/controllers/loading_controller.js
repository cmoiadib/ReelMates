import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["loading", "content", "generating"];

  // Method to be called when everyone has finished swiping
  startLoading() {
    // Show the loading screen
    this.loadingTarget.classList.remove('d-none');

    // After 5 seconds, hide loading and show content
    setTimeout(() => {
      this.loadingTarget.classList.add('d-none');
      this.contentTarget.classList.remove('d-none');
    }, 5000);
  }

  // New method for final movies generation
  startGenerating() {
    // Hide current content
    this.contentTarget.classList.add('d-none');
    // Show generating screen
    this.generatingTarget.classList.remove('d-none');

    // After 5 seconds, hide generating and show final content
    setTimeout(() => {
      this.generatingTarget.classList.add('d-none');
      this.contentTarget.classList.remove('d-none');
    }, 5000);
  }
}
