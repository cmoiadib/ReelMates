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
    this.previousCards = []; // Array to store previous cards
    this.currentIndex = 0;
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
    const { movieId, isLiked } = event.detail;
    // Store current card info before the swipe
    this.previousCards.push({
      movieId: movieId,
      index: this.currentIndex
    });
    this.currentIndex++;
    if (isLiked) {
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
  undoSwipe(event) {
    event.preventDefault();
    if (this.previousCards.length > 0 && this.currentIndex > 0) {
      const lastCard = this.previousCards.pop();
      this.currentIndex--;
      // Reset transform and opacity of the current slide
      if (this.swiper.slides[this.currentIndex]) {
        this.swiper.slides[this.currentIndex].style.transform = 'translate3d(0px, 0px, 0px) rotateZ(0deg)';
        this.swiper.slides[this.currentIndex].style.opacity = '1';
      }
      // Go back to previous slide
      this.swiper.slideTo(this.currentIndex, 300); // 300ms animation duration
      // Delete the last swipe from the database
      fetch(`/parties/${this.partyIdValue}/swipes/undo`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          movie_id: lastCard.movieId
        })
      });
    }
  }
  disconnect() {
    this.swiper.destroy(true, true);
  }
}
