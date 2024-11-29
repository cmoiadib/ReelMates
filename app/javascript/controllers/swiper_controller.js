import { Controller } from "@hotwired/stimulus"
import EffectTinder from '../tinder-effect';

export default class extends Controller {
  static values = {
    partyId: String,
    partyPlayerId: String
  }


  connect() {
    console.log("HHEEELLLOOO");

    this.swiper = new Swiper(this.element, {
      // pass EffectTinder module to modules
      modules: [EffectTinder],
      // specify "tinder" effect
      effect: 'tinder',
      grabCursor: true,
      // loop is also supported
      // loop: true,
      on: {
        yes: () => this.rightSwipe(),
        no: () => this.leftSwipe()
      }
    });
    console.log(this.swiper.visibleSlides);
  }

  // showResults() {
  //   document.getElementById('loading-screen').style.display = 'block';

  //   fetch(`/parties/${this.partyIdValue}/swipes/result`, {
  //     method: 'GET',
  //     headers: {
  //       'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
  //       'Accept': 'application/json'
  //     }
  //   }).then(response => {
  //     setTimeout(function() {
  //       document.getElementById('loading-screen').style.display = 'none';
  //       document.getElementById('results-content').style.display = 'block';
  //     }, 5000);
  //   });
  // }

  handleSwipe(event) {
    const direction = event.detail.swipeDirection;

    if (direction === 'right') {
      this.rightSwipe();
    } else {
      this.leftSwipe();
    }
  }

  rightSwipe() {
    fetch(`/parties/${this.partyIdValue}/swipes`, {
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      method: 'POST',
      body: JSON.stringify({ swipe: { movie_id: this.swiper.visibleSlides[0].dataset.movieId, is_liked: true, party_player_id: this.partyPlayerIdValue, tags: JSON.parse(this.swiper.visibleSlides[0].dataset.movieTags || "[]") } })
    }).then(response => response.json())
      .then(data => {
        if (data.last_swipe) {
          window.location.href = `/parties/${this.partyIdValue}/result`;
        }
      })
  }

  leftSwipe() {
    fetch(`/parties/${this.partyIdValue}/swipes`, {
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      method: 'POST',
      body: JSON.stringify({ swipe: { movie_id: this.swiper.visibleSlides[0].dataset.movieId, is_liked: false, party_player_id: this.partyPlayerIdValue, tags: JSON.parse(this.swiper.visibleSlides[0].dataset.movieTags || "[]") } })
    }).then(response => response.json())
    .then(data => {
      if (data.last_swipe) {
        window.location.href = `/parties/${this.partyIdValue}/result`;
      }
    })
  }

  disconnect() {
    this.swiper.destroy(true, true);
  }
}
