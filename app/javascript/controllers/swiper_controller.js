import { Controller } from "@hotwired/stimulus";
import Swiper from 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs';

export default class extends Controller {
  static targets = ["container", "timer"]

  connect() {
    // Durée de la session en secondes (par exemple, 30 secondes)
    this.timerDuration = 20;
    this.timeRemaining = this.timerDuration; // Timer de départ
    this.timerTarget.innerText = this.timeRemaining;

    // Initialisation du Swiper
    this.swiper = new Swiper(this.containerTarget, {
      effect: "cards",  // Utilisation de l'effet "cards"
      grabCursor: true,
      loop: false, // Pas de boucle infinie
    })

    // Gérer le changement de slide (lors du swipe)
    this.swiper.on("slideChange", () => {
      const activeSlide = this.swiper.slides[this.swiper.activeIndex]
      const itemId = activeSlide.dataset.itemId
      const category = activeSlide.dataset.category

      // Détecter la direction du swipe
      const isLiked = this.swiper.swipeDirection === "next" // Droite = like, gauche = dislike

      // Envoyer l'action "like" ou "dislike" au backend
      this.sendLikeAction(itemId, isLiked, category)
    })

    // Démarrer le timer
    this.startTimer();
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      this.timeRemaining -= 1;

      this.timerTarget.innerText = this.timeRemaining;

      // Si le temps est écoulé, on arrête le swiper et désactive l'interaction
      if (this.timeRemaining <= 0) {
        clearInterval(this.timerInterval);
        this.stopSwiper();
        alert("Le temps est écoulé, la partie est terminée !");
      }
    }, 1000); // Le timer décompte chaque seconde
  }

  stopSwiper() {
    // Désactive le swiper en bloquant les actions de glissement
    this.swiper.disable();
  }

  sendLikeAction(itemId, isLiked, category) {
    fetch(`/swipes`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
      },
      body: JSON.stringify({
        movie_id: itemId,
        is_liked: isLiked,
        tags: [category]  // On envoie la catégorie en tant que tag
      })
    }).then(response => {
      if (!response.ok) {
        console.error("Erreur lors de l'enregistrement du swipe")
      }
    })
  }
}
