import { Controller } from "@hotwired/stimulus";
import Swiper from 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs';

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Initialisation de Swiper
    const swiper = new Swiper(this.containerTarget, {
      effect: "cards",  // Utilisation de l'effet de carte
      grabCursor: true,
      loop: false,  // Pas de boucle infinie
    })

    // Gérer le changement de slide (lors du swipe)
    swiper.on("slideChange", () => {
      const activeSlide = swiper.slides[swiper.activeIndex]
      const itemId = activeSlide.dataset.itemId
      const category = activeSlide.dataset.category

      // Détecter la direction du swipe
      const isLiked = swiper.swipeDirection === "next" // Droite = like, gauche = dislike

      // Envoyer l'action "like" ou "dislike" au backend
      this.sendLikeAction(itemId, isLiked, category)
    })
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
