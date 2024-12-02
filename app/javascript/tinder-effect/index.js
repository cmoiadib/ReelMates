export default function EffectTinder({ swiper, on }) {
  let draggableSlide;
  let preventInteraction;
  let isTouched;

  let touchStartIndex;
  let isSlideChangeTouched;
  let emitTransitionEnd;

  let swipeDirection;
  swiper.tinder = {
    no() {
      swiper.touches.currentX = 0;
      swiper.touches.startX = swiper.size / 2;
      const slideEl = swiper.slides[swiper.activeIndex];
      slideEl.translateY = 0;
      slideEl.style.transformOrigin = `center bottom`;
      slideEl.transformOrigin = 'bottom';
      swiper.slideNext();
      swiper.animating = false;
      swiper.emit("no")
    },
    yes() {
      swiper.touches.currentX = swiper.size;
      swiper.touches.startX = swiper.size / 2;
      const slideEl = swiper.slides[swiper.activeIndex];
      slideEl.translateY = 0;
      slideEl.style.transformOrigin = `center bottom`;
      slideEl.transformOrigin = 'bottom';
      swiper.slideNext();
      swiper.animating = false;
      swiper.emit("yes")
    },
  };
  const withElement = (el, cb) => {
    if (el) cb(el);
  };

  const setSlidesOrigin = (o, pos) => {
    swiper.slides.forEach((el, index) => {
      if (index < swiper.activeIndex) return;
      el.style.transformOrigin = o;
      el.transformOrigin = pos;
    });
  };

  const setSlideButtonsLabels = (
    slideEl,
    progress,
    diff,
    isLastSlide,
    force,
  ) => {
    if (!isTouched && !force) return;
    if (!isLastSlide) {
      const labelOpacity = Math.max(Math.min(-0.5 + progress * 10, 1), 0);
      withElement(
        slideEl.querySelector('.swiper-tinder-label-yes'),
        (el) => (el.style.opacity = diff > 0 ? labelOpacity : 0),
      );
      withElement(
        slideEl.querySelector('.swiper-tinder-label-no'),
        (el) => (el.style.opacity = diff < 0 ? labelOpacity : 0),
      );
      withElement(document.querySelector('.swiper-tinder-button-yes'), (el) =>
        el.classList.remove('swiper-tinder-button-hidden'),
      );
      withElement(document.querySelector('.swiper-tinder-button-no'), (el) =>
        el.classList.remove('swiper-tinder-button-hidden'),
      );
      if (progress >= swiper.params.longSwipesRatio && !isLastSlide) {
        if (diff > 0) {
          withElement(
            document.querySelector('.swiper-tinder-button-yes'),
            (el) => el.classList.add('swiper-tinder-button-active'),
          );

          withElement(
            document.querySelector('.swiper-tinder-button-no'),
            (el) => el.classList.remove('swiper-tinder-button-active'),
          );
        } else {
          withElement(
            document.querySelector('.swiper-tinder-button-yes'),
            (el) => el.classList.remove('swiper-tinder-button-active'),
          );

          withElement(
            document.querySelector('.swiper-tinder-button-no'),
            (el) => el.classList.add('swiper-tinder-button-active'),
          );
        }
      } else {
        withElement(document.querySelector('.swiper-tinder-button-yes'), (el) =>
          el.classList.remove('swiper-tinder-button-active'),
        );
        withElement(document.querySelector('.swiper-tinder-button-no'), (el) =>
          el.classList.remove('swiper-tinder-button-active'),
        );
      }
    } else {
      withElement(document.querySelector('.swiper-tinder-button-yes'), (el) =>
        el.classList.add('swiper-tinder-button-hidden'),
      );
      withElement(document.querySelector('.swiper-tinder-button-no'), (el) =>
        el.classList.add('swiper-tinder-button-hidden'),
      );
    }
  };
  on('beforeInit', () => {
    if (swiper.params.effect !== 'tinder') return;
    swiper.classNames.push(`${swiper.params.containerModifierClass}tinder`);
    swiper.classNames.push(`${swiper.params.containerModifierClass}3d`);
    const overwriteParams = {
      watchSlidesProgress: true,
      virtualTranslate: true,
      longSwipesRatio: 0.1,
      oneWayMovement: true,
    };

    Object.assign(swiper.params, overwriteParams);
    Object.assign(swiper.originalParams, overwriteParams);
  });
  on('init', () => {
    if (swiper.el && swiper.el.addEventListener) {
      swiper.el.addEventListener('click', (e) => {
        if (e.target.closest('.swiper-tinder-button-yes')) swiper.tinder.yes();
        if (e.target.closest('.swiper-tinder-button-no')) swiper.tinder.no();
      });
    }
  });
  on('touchStart', (s, e) => {
    if (swiper.params.effect !== 'tinder') return;
    isTouched = true;
    isSlideChangeTouched = true;
    emitTransitionEnd = true;
    const { clientY } = e;
    const { top, height } = swiper.el.getBoundingClientRect();
    preventInteraction = false;
    const slideEl = e.target.closest('.swiper-slide, swiper-slide');
    if (!slideEl) return;
    if (!slideEl.classList.contains('swiper-slide-active')) return;
    draggableSlide = slideEl;
    touchStartIndex = swiper.activeIndex;

    if (clientY - top > height / 2) {
      setSlidesOrigin('center top', 'top');
    } else {
      setSlidesOrigin('center bottom', 'bottom');
    }
  });
  on('touchMove', (s) => {
    if (swiper.params.effect !== 'tinder') return;
    const diffY = s.touches.currentY - s.touches.startY;
    const diffX = s.touches.currentX - s.touches.startX;
    if (Math.abs(diffX) > swiper.size * 0.95) {
      preventInteraction = false;
    } else {
      preventInteraction = false;
    }
    if (!draggableSlide) return;
    draggableSlide.translateY = diffY;
  });

  on('touchEnd', () => {
    if (swiper.params.effect !== 'tinder') return;
    preventInteraction = false;
    isSlideChangeTouched = false;

    const customEvent = new CustomEvent('swiper:tinderSwipe', {
      detail: {
        swipeDirection: swipeDirection < 0 ? 'left' : 'right'
      }
    });
    document.dispatchEvent(customEvent);

    requestAnimationFrame(() => {
      isTouched = false;
    });
  });

  on('setTransition', (s, duration) => {
    if (swiper.params.effect !== 'tinder') return;
    s.slides.forEach((slideEl) => {
      slideEl.style.transitionDuration = `${duration}ms`;
      slideEl.querySelectorAll('.swiper-tinder-label').forEach((labelEl) => {
        labelEl.style.transitionDuration = `${duration}ms`;
        if (slideEl.progress <= 0) {
          labelEl.style.opacity = 0;
        }
      });
    });
    requestAnimationFrame(() => {
      withElement(document.querySelector('.swiper-tinder-button-yes'), (el) =>
        el.classList.remove('swiper-tinder-button-active'),
      );
      withElement(document.querySelector('.swiper-tinder-button-no'), (el) =>
        el.classList.remove('swiper-tinder-button-active'),
      );
    });
  });

  on('slideChange', () => {
    const isLastSlide =
      swiper.activeIndex === swiper.slides.length - 1 && !swiper.params.loop;
    if (isLastSlide) {
      const slideEl = swiper.slides[swiper.slides.length - 1];
      const slideProgress = slideEl.progress;
      const progress = Math.min(Math.max(slideProgress, -2), 2);
      const diff = swiper.touches.currentX - swiper.touches.startX;
      setSlideButtonsLabels(slideEl, progress, diff, true, true);
    }
    if (!isSlideChangeTouched) {
      emitTransitionEnd = false;
      swiper.emit('tinderSwipe', swipeDirection < 0 ? 'left' : 'right');
    }
  });

  on('transitionStart', () => {
    if (emitTransitionEnd && swiper.activeIndex !== touchStartIndex) {
      emitTransitionEnd = false;
      swiper.emit('tinderSwipe', swipeDirection < 0 ? 'left' : 'right');
    }
  });

  on('setTranslate', (s, currentTranslate) => {
    if (swiper.params.effect !== 'tinder') return;
    if (preventInteraction) return;
    if (
      isSlideChangeTouched &&
      typeof touchStartIndex !== 'undefined' &&
      typeof swiper.snapGrid[touchStartIndex + 1] !== 'undefined'
    ) {
      const currentSlideTranslate = Math.abs(swiper.snapGrid[touchStartIndex]);
      const maxTranslate = Math.abs(currentSlideTranslate + swiper.size) - 8;

      if (Math.abs(currentTranslate) > maxTranslate) {
        swiper.setTranslate(-maxTranslate);
        return;
      }
    }

    const diff = swiper.touches.currentX - swiper.touches.startX;
    swipeDirection = diff;
    const { slides } = swiper;
    const isLastSlide =
      swiper.activeIndex === slides.length - 1 && !swiper.params.loop;
    slides.forEach((slideEl, slideIndex) => {
      const slideProgress = slideEl.progress;
      const progress = Math.min(Math.max(slideProgress, -2), 2);
      const offset = slideEl.swiperSlideOffset;
      let tX = -offset;
      let tY = 0;
      let tZ = 100 * progress;
      let rotate = 0;
      let opacity = 1;
      if (progress > 0 || (progress === 0 && isTouched)) {
        tZ = 0;
        rotate = 45 * progress * (diff < 0 ? -1 : 1);
        tX = swiper.size * (diff < 0 ? -1 : 1) * progress + tX;

        if (typeof slideEl.translateY !== 'undefined') {
          tY = slideEl.translateY;
        }

        setSlideButtonsLabels(slideEl, progress, diff, isLastSlide);
      }
      if (slideEl.transformOrigin === 'top') {
        rotate = -rotate;
      }

      if (progress > 1) {
        opacity = (1.2 - progress) * 5;
      }
      const transform = `
        translate3d(${tX}px, ${tY}px, ${tZ}px)
        rotateZ(${rotate}deg)
      `;
      if (progress >= 1 && !slideEl.tinderTransform) {
        slideEl.tinderTransform = transform;
        slideEl.tinderTransformSlideIndex = slideIndex;
      }
      if (
        (slideEl.tinderTransform &&
          slideEl.tinderTransformSlideIndex !== slideIndex) ||
        !isTouched
      ) {
        slideEl.tinderTransform = '';
      }
      slideEl.style.zIndex =
        -Math.abs(Math.round(slideProgress)) + slides.length;
      slideEl.style.transform = slideEl.tinderTransform || transform;
      slideEl.style.opacity = opacity;
    });
  });
}
