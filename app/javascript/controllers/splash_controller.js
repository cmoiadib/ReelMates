import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["splash", "content"];

  connect() {
    // console.log(window.location.pathname)
    if (window.location.pathname === "/") {
      setTimeout(() => {
        this.splashTarget.classList.add("d-none");
        this.contentTarget.classList.remove("d-none");
      }, 3000);
    } else {
      this.splashTarget.classList.add("d-none");
      this.contentTarget.classList.remove("d-none");
    }
  }
}
