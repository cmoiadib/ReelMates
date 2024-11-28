import { Controller } from "@hotwired/stimulus"
import EffectTinder from '../tinder-effect';

export default class extends Controller {
  static values = {
    partyId: String,
    partyPlayerId: String
  }

  connect() {
    this.swiper = new Swiper(this.element, {
      // pass EffectTinder module to modules
      modules: [EffectTinder],
      // specify "tinder" effect
      effect: 'tinder',
      grabCursor: true,
      // loop is also supported
      // loop: true,
      on: {
        yes: (event) => {
          fetch(`/parties/${this.partyId}/swipes`, {
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            method: 'POST',
            body: JSON.stringify({ swipe: { movie_id: this.swiper.visibleSlides[0].dataset.movieId, is_liked: true, party_player_id: this.partyPlayerId } })
          })
        },
        no: (event) => {
          fetch(`/parties/${this.partyId}/swipes`, {
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            method: 'POST',
            body: JSON.stringify({ swipe: { movie_id: this.swiper.visibleSlides[0].dataset.movieId, is_liked: false, party_player_id: this.partyPlayerId } })
          })
        }
      }
    });
  }
}
