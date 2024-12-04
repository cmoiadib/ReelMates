import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('click', this.toggleFlip.bind(this))
  }

  toggleFlip() {
    this.element.querySelector('.flip-card-inner').classList.toggle('is-flipped')
  }

  disconnect() {
    this.element.removeEventListener('click', this.toggleFlip.bind(this))
  }
} 
