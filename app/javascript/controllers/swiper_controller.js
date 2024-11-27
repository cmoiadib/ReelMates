import { Controller } from "@hotwired/stimulus";
import Swiper from 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs';

export default class extends Controller {
  static targets = ["container", "pagination", "prevButton", "nextButton"];

  connect() {
    console.log('coucou')
    const swiper = new Swiper(".swiper", {
      effect: "cards",
      grabCursor: true,
    });
  }
}
