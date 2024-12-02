import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["loading", "content"];

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
} 
