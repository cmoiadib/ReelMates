import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  shareCode(event) {
    const code = this.element.dataset.shareCode

    if (navigator.share) {
      navigator.share({
        title: 'Join my ReelMates party!',
        text: `Join my party with code: ${code}`,
        url: window.location.href
      }).then(() => {
        console.log('Thanks for sharing!');
      })
      .catch(console.error);
    } else {
      // Fallback for browsers that don't support the Web Share API
      navigator.clipboard.writeText(code).then(() => {
        alert('Code copied to clipboard!');
      });
    }
  }
}
